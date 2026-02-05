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

    /// @dev Returns the address of the Royco kernel employed by this tranche
    function kernel() external view returns (address);

    /**
     * @notice Deposits the specified number of assets into the tranche and mints the specified receiver tranche shares
     * @dev The assets are expressed in the tranche's base asset
     * @param _assets The amount of assets to deposit and mint shares for
     * @param _receiver The address to mint the shares to
     * @param _controller The controller of the request
     * @return shares The number of shares that were minted
     * @return metadata The format prefixed metadata of the deposit or empty bytes if no metadata is shared
     */
    function deposit(uint256 _assets, address _receiver, address _controller)
        external
        returns (uint256 shares, bytes memory metadata);

    /**
     * @notice Returns the breakdown of assets that the shares have a claim on
     * @dev The shares are expressed in the tranche's base asset
     * @param _shares The number of shares to convert to assets
     * @return claims The breakdown of assets that the shares have a claim on
     */
    function convertToAssets(uint256 _shares) external view returns (AssetClaims memory claims);
}
