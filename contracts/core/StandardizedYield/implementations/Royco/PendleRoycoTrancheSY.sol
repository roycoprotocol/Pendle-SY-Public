// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

import {PendleERC20SYUpgV2, PMath, IERC20Metadata, ArrayLib} from "../PendleERC20SYUpgV2.sol";
import {MerklRewardAbstract__NoStorage} from "../../../misc/MerklRewardAbstract__NoStorage.sol";
import {IRoycoVaultTranche, AssetClaims, TrancheType} from "../../../../interfaces/Royco/IRoycoVaultTranche.sol";
import {IRoycoFactory} from "../../../../interfaces/Royco/IRoycoFactory.sol";
import {IRoycoKernel, ExecutionModel} from "../../../../interfaces/Royco/IRoycoKernel.sol";

/**
 * @title PendleRoycoTrancheSY
 * @author Waymont
 * @notice The SY for Royco's senior and junior tranche vault shares
 */
contract PendleRoycoTrancheSY is PendleERC20SYUpgV2, MerklRewardAbstract__NoStorage {
    /// @dev The address of the Royco market factory
    IRoycoFactory public immutable ROYCO_FACTORY;

    /// @dev The base asset of the Royco tranche for this SY
    address public immutable BASE_ASSET;

    /// @dev Boolean indicating whether both tranches for this Royco market have the same base asset
    bool private immutable TRANCHES_HAVE_IDENTICAL_ASSETS;

    /**
     * @notice Constructs the Pendle SY for the Royco senior or junior tranche
     * @param _roycoFactory The address of the Royco factory responsible for deploying Royco markets
     * @param _roycoTranche The address of the Royco tranche which constitutes the yield bearing token of this SY
     * @param _offchainRewardManager The address of the offchain reward manager (null address if none exists for this SY)
     */
    constructor(address _roycoFactory, address _roycoTranche, address _offchainRewardManager)
        PendleERC20SYUpgV2(_roycoTranche)
        MerklRewardAbstract__NoStorage(_offchainRewardManager)
    {
        // Set the immutable state
        ROYCO_FACTORY = IRoycoFactory(_roycoFactory);
        BASE_ASSET = IRoycoVaultTranche(_roycoTranche).asset();

        // Get the tranche corresponding to the specified tranche for this Royco market
        address correspondingTranche = IRoycoVaultTranche(_roycoTranche).TRANCHE_TYPE() == TrancheType.SENIOR
            ? ROYCO_FACTORY.seniorTrancheToJuniorTranche(_roycoTranche)
            : ROYCO_FACTORY.juniorTrancheToSeniorTranche(_roycoTranche);

        // The two tranches having identical base assets determines the units that the exchange rate will be expressed in
        TRANCHES_HAVE_IDENTICAL_ASSETS = BASE_ASSET == IRoycoVaultTranche(correspondingTranche).asset();
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
            ? (AssetType.TOKEN, BASE_ASSET, IERC20Metadata(BASE_ASSET).decimals())
            : (AssetType.LIQUIDITY, yieldToken, decimals);
    }
}
