// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {PendleERC20SYUpgV2, PMath} from "../PendleERC20SYUpgV2.sol";
import {MerklRewardAbstract__NoStorage} from "../../../misc/MerklRewardAbstract__NoStorage.sol";
import {IRoycoVaultTranche} from "../../../../interfaces/Royco/IRoycoVaultTranche.sol";

/**
 * @title PendleRoycoTrancheSY
 * @author Waymont
 * @notice Pendle Standardized Yield wrapper for Royco tranche shares (Senior or Junior)
 */
contract PendleRoycoTrancheSY is PendleERC20SYUpgV2, MerklRewardAbstract__NoStorage {
    /**
     * @notice Constructs the Pendle SY for the Royco senior or junior tranche
     * @param _roycoTranche The address of the Royco tranche which constitutes the yield bearing token of this SY
     * @param _offchainRewardManager The address of the offchain reward manager (null address if none exists for this SY)
     */
    constructor(address _roycoTranche, address _offchainRewardManager)
        PendleERC20SYUpgV2(_roycoTranche)
        MerklRewardAbstract__NoStorage(_offchainRewardManager)
    {}

    /**
     * @notice Returns the exchange rate of one tranche share in terms of the market's NAV units (USD, BTC, ETH, etc.)
     * @return The exchange rate such that: exchangeRate * syBalance / 1e18 = asset value
     */
    function exchangeRate() public view override(PendleERC20SYUpgV2) returns (uint256) {
        // Royco tranche shares always have 18 decimals of precision (PMath.ONE == 1 whole tranche share)
        // Return the exchange rate in NAV units (always has 18 decimals of precision)
        return IRoycoVaultTranche(yieldToken).convertToAssets(PMath.ONE).nav;
    }

    /**
     * @notice Returns metadata about the asset that the exchange rate is denominated in
     * @return assetType Always LIQUIDITY, as the exchange rate is denominated in the market's NAV units
     * @return assetAddress The Royco tranche address
     * @return assetDecimals Decimals of the asset (matches exchange rate denomination)
     */
    function assetInfo()
        external
        view
        override(PendleERC20SYUpgV2)
        returns (AssetType assetType, address assetAddress, uint8 assetDecimals)
    {
        return (AssetType.LIQUIDITY, yieldToken, decimals);
    }
}
