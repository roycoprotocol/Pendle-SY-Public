// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

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
    /**
     * @notice Returns the breakdown of assets that the shares have a claim on
     * @param _shares The number of shares to convert to assets
     * @return claims The breakdown of assets that the shares have a claim on
     */
    function convertToAssets(uint256 _shares) external view returns (AssetClaims memory claims);
}
