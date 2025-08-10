// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * Subtle access control bug:
 * - Developer set up roles in the implementation's constructor (or forgot to disable initializers),
 *   but when used via a proxy the constructor DOES NOT run.
 * - The initializer is left callable (or never called in deployment), so ANYONE can call initialize()
 *   and become DEFAULT_ADMIN_ROLE, then grant themselves critical roles and upgrade the implementation.
 *
 * This mixes upgradeability + access control and relies on incorrect deployment assumptions.
 */
contract VaultV1 is Initializable, AccessControlUpgradeable, UUPSUpgradeable {
    bytes32 public constant KEEPER_ROLE = keccak256("KEEPER_ROLE");
    uint256 public secret; // sensitive state

    /// Developer mistakenly thought this runs for proxies (it doesn't)
    /// (If this were a non-upgradeable contract, constructor logic could be fine.)
    constructor() {
        // THIS DOES NOT RUN WHEN DEPLOYED AS THE PROXY'S IMPLEMENTATION
        // Some teams put role setup / ownership here — wrong for upgradeable patterns.
        _disableInitializers(); // developer may omit this line by mistake; if omitted -> vulnerability
    }

    /// Proper initializer (but may be left callable if deployment step forgot to call it)
    function initialize(address initialAdmin) public initializer {
        __AccessControl_init();
        __UUPSUpgradeable_init();

        // intended to be the only place to grant admin
        _grantRole(DEFAULT_ADMIN_ROLE, initialAdmin);
        _grantRole(KEEPER_ROLE, initialAdmin);
    }

    // sensitive action guarded by KEEPER_ROLE
    function setSecret(uint256 _secret) external onlyRole(KEEPER_ROLE) {
        secret = _secret;
    }

    // UUPS authorization: only DEFAULT_ADMIN_ROLE can upgrade
    function _authorizeUpgrade(address) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}
}
