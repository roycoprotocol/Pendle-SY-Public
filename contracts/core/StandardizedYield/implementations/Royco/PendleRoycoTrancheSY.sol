// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {PendleERC20SYUpgV2, PMath, IERC20Metadata, ArrayLib} from "../PendleERC20SYUpgV2.sol";
import {MerklRewardAbstract__NoStorage} from "../../../misc/MerklRewardAbstract__NoStorage.sol";
import {IRoycoVaultTranche, AssetClaims} from "../../../../interfaces/Royco/IRoycoVaultTranche.sol";
import {IRoycoKernel} from "../../../../interfaces/Royco/IRoycoKernel.sol";

/**
 * @title PendleRoycoTrancheSY
 * @author Waymont
 * @notice Pendle Standardized Yield wrapper for Royco tranche shares (Senior or Junior)
 */
contract PendleRoycoTrancheSY is PendleERC20SYUpgV2, MerklRewardAbstract__NoStorage {
    /// @dev Boolean indicating whether both tranches for this Royco market have the same base asset
    bool private immutable TRANCHES_HAVE_IDENTICAL_ASSETS;

    /**
     * @notice Constructs the Pendle SY for the Royco senior or junior tranche
     * @param _roycoTranche The address of the Royco tranche which constitutes the yield bearing token of this SY
     * @param _offchainRewardManager The address of the offchain reward manager (null address if none exists for this SY)
     */
    constructor(address _roycoTranche, address _offchainRewardManager)
        PendleERC20SYUpgV2(_roycoTranche)
        MerklRewardAbstract__NoStorage(_offchainRewardManager)
    {
        // The two tranches having identical base assets determines the units that the exchange rate will be expressed in
        IRoycoKernel kernel = IRoycoKernel(IRoycoVaultTranche(_roycoTranche).KERNEL());
        TRANCHES_HAVE_IDENTICAL_ASSETS = kernel.ST_ASSET() == kernel.JT_ASSET();
    }

    /**
     * @notice Returns the exchange rate of the tranche share in terms of underlying asset value
     * @dev If both tranches share the same base asset, returns the exchange rate in terms of the common base asset
     *      If tranches have different base assets, returns the exchange rate in terms of the market's NAV units
     * @return The exchange rate such that: exchangeRate * syBalance / 1e18 = asset value
     */
    function exchangeRate() public view override(PendleERC20SYUpgV2) returns (uint256) {
        // Royco tranche shares always have 18 decimals of precision (PMath.ONE == 1 whole tranche share)
        AssetClaims memory claims = IRoycoVaultTranche(yieldToken).convertToAssets(PMath.ONE);
        // If both tranches for this Royco market have identical base assets, sum the two constituent asset claims
        // Else, return the exchange rate in NAV units (always has 18 decimals of precision)
        return TRANCHES_HAVE_IDENTICAL_ASSETS ? claims.stAssets + claims.jtAssets : claims.nav;
    }

    /**
     * @notice Returns metadata about the asset that the exchange rate is denominated in
     * @return assetType TOKEN if both tranches for this market have identical base assets, LIQUIDITY otherwise
     * @return assetAddress The base asset address if both tranches for this market have identical base assets, the Royco tranche otherwise
     * @return assetDecimals Decimals of the asset (matches exchange rate denomination)
     */
    function assetInfo()
        external
        view
        override(PendleERC20SYUpgV2)
        returns (AssetType assetType, address assetAddress, uint8 assetDecimals)
    {
        if (TRANCHES_HAVE_IDENTICAL_ASSETS) {
            assetAddress = IRoycoVaultTranche(yieldToken).asset();
            return (AssetType.TOKEN, assetAddress, IERC20Metadata(assetAddress).decimals());
        } else {
            return (AssetType.LIQUIDITY, yieldToken, decimals);
        }
    }
}
