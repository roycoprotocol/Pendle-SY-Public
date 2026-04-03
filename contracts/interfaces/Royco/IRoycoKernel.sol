// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

/// @title IRoycoKernel
/// @dev An abridged interface for the Royco Kernel
interface IRoycoKernel {
    /**
     * @notice Retrieves the ST asset address
     * @return stAsset The senior tranche's base asset address
     */
    function ST_ASSET() external view returns (address stAsset);

    /**
     * @notice Retrieves the JT asset address
     * @return jtAsset The junior tranche's base asset address
     */
    function JT_ASSET() external view returns (address jtAsset);
}
