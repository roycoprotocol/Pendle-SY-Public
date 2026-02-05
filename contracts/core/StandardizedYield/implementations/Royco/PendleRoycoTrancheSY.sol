// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {PendleERC4626NoRedeemUpgSY, PMath, IERC4626, IERC20Metadata, ArrayLib} from "../PendleERC4626NoRedeemUpgSY.sol";
import {MerklRewardAbstract__NoStorage} from "../../../misc/MerklRewardAbstract__NoStorage.sol";
import {IRoycoVaultTranche, AssetClaims, TrancheType} from "../../../../interfaces/Royco/IRoycoVaultTranche.sol";
import {IRoycoFactory} from "../../../../interfaces/Royco/IRoycoFactory.sol";
import {IRoycoKernel, ExecutionModel} from "../../../../interfaces/Royco/IRoycoKernel.sol";

/**
 * @title PendleRoycoTrancheSY
 * @author Waymont
 * @notice The SY for Royco's senior and junior tranche vault shares
 */
contract PendleRoycoTrancheSY is PendleERC4626NoRedeemUpgSY, MerklRewardAbstract__NoStorage {
    /// @dev Address of the Royco market factory
    IRoycoFactory public immutable ROYCO_FACTORY;

    /// @dev Boolean indicating whether both tranches for this Royco market have the same base asset
    bool private immutable TRANCHES_HAVE_IDENTICAL_ASSETS;

    /// @dev Boolean indicating whether deposits into the tranche are synchronous
    bool private immutable DEPOSIT_IS_SYNC;

    /**
     * @notice Constructs the Pendle SY
     * @param _roycoFactory The address of the Royco factory responsible for deploying Royco markets
     * @param _roycoTranche The address of the Royco tranche which constitutes the yield token of this SY
     * @param _offchainRewardManager The address of the offchain reward manager (null address if none exists for this SY)
     */
    constructor(address _roycoFactory, address _roycoTranche, address _offchainRewardManager)
        PendleERC4626NoRedeemUpgSY(_roycoTranche)
        MerklRewardAbstract__NoStorage(_offchainRewardManager)
    {
        ROYCO_FACTORY = IRoycoFactory(_roycoFactory);
        // Get the tranche corresponding to the specified tranche for this Royco market
        TrancheType trancheType = IRoycoVaultTranche(_roycoTranche).TRANCHE_TYPE();
        address correspondingTranche = trancheType == TrancheType.SENIOR
            ? ROYCO_FACTORY.seniorTrancheToJuniorTranche(_roycoTranche)
            : ROYCO_FACTORY.juniorTrancheToSeniorTranche(_roycoTranche);
        // Set the remaining immutable state
        TRANCHES_HAVE_IDENTICAL_ASSETS = asset == IERC4626(correspondingTranche).asset();
        IRoycoKernel kernel = IRoycoKernel(IRoycoVaultTranche(_roycoTranche).kernel());
        DEPOSIT_IS_SYNC = trancheType == TrancheType.SENIOR
            ? kernel.ST_DEPOSIT_EXECUTION_MODEL() == ExecutionModel.SYNC
            : kernel.JT_DEPOSIT_EXECUTION_MODEL() == ExecutionModel.SYNC;
    }

    function _deposit(address tokenIn, uint256 amountDeposited) internal override returns (uint256 amountSharesOut) {
        if (tokenIn == yieldToken) {
            amountSharesOut = amountDeposited;
        } else {
            (amountSharesOut,) = IRoycoVaultTranche(yieldToken).deposit(amountDeposited, address(this), address(this));
        }
    }

    function exchangeRate() public view virtual override returns (uint256) {
        // Royco tranche shares always have 18 decimals of precision (PMath.ONE == 1 whole tranche share)
        AssetClaims memory claims = IRoycoVaultTranche(yieldToken).convertToAssets(PMath.ONE);
        // If both tranches for this Royco market have identical base assets, sum the two constituent asset claims
        // Else, return the exchange rate in NAV units (always has 18 decimals of precision)
        return TRANCHES_HAVE_IDENTICAL_ASSETS ? claims.stAssets + claims.jtAssets : claims.nav;
    }

    function assetInfo() external view override returns (AssetType, address, uint8) {
        // If both tranches for this Royco market have identical base assets, return the base asset and decimals
        // Else, return the tranche share and 18 decimals to match NAV precision
        return TRANCHES_HAVE_IDENTICAL_ASSETS
            ? (AssetType.TOKEN, asset, IERC20Metadata(asset).decimals())
            : (AssetType.LIQUIDITY, yieldToken, decimals);
    }

    function getTokensIn() public view virtual override returns (address[] memory res) {
        return _canDepositViaBaseAsset() ? ArrayLib.create(asset, yieldToken) : ArrayLib.create(yieldToken);
    }

    function isValidTokenIn(address token) public view virtual override returns (bool) {
        return token == yieldToken || (_canDepositViaBaseAsset() && token == asset);
    }

    /// @dev Internal helper which returns whether the SY can deposit the base asset directly into the tranche to mint tranche shares
    function _canDepositViaBaseAsset() internal view returns (bool) {
        // If the deposit execution model is async, deposits directly from the SY are disabled
        if (!DEPOSIT_IS_SYNC) return false;

        // Check if this SY contract can call deposit on the tranche with no delay
        (bool allowed, uint32 delay) =
            ROYCO_FACTORY.canCall(address(this), yieldToken, IRoycoVaultTranche.deposit.selector);

        return (allowed && delay == 0);
    }
}
