// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

/**
 * @title TrancheType
 * @dev Defines the two types of Royco tranches deployed per market.
 * @custom:type SENIOR - The identifier for the senior tranche (protected capital)
 * @custom:type JUNIOR - The identifier for the junior tranche (first-loss capital)
 */
enum TrancheType {
    SENIOR,
    JUNIOR
}

/**
 * @title AssetClaims
 * @dev A struct representing claims on senior tranche assets, junior tranche assets, and NAV
 * @custom:field stAssets - The claim on senior tranche assets denominated in ST's tranche units
 * @custom:field jtAssets - The claim on junior tranche assets denominated in JT's tranche units
 * @custom:field nav - The net asset value of these claims in NAV units
 */
struct AssetClaims {
    uint256 stAssets;
    uint256 jtAssets;
    uint256 nav;
}

/// @title IRoycoVaultTranche
/// @dev An abridged interface for Royco Vault Tranches
interface IRoycoVaultTranche {
    /// @dev Returns the type of this tranche (Senior or Junior)
    function TRANCHE_TYPE() external pure returns (TrancheType);

    /**
     * @notice Returns the address of the underlying base asset for this tranche
     * @return asset The address of the ERC20 token used as the base asset for deposits into this tranche
     */
    function asset() external view returns (address asset);

    /**
     * @notice Returns the breakdown of assets that the shares have a claim on
     * @dev The shares are expressed in the tranche's base asset
     * @param _shares The number of shares to convert to assets
     * @return claims The breakdown of assets that the shares have a claim on
     */
    function convertToAssets(uint256 _shares) external view returns (AssetClaims memory claims);
}
