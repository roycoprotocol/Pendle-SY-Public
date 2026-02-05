// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

/**
 * @title ExecutionModel
 * @dev Defines the execution semantics for the deposit or withdrawal flow of a vault
 * @custom:type SYNC - Refers to the flow being synchronous
 * @custom:type ASYNC - Refers to the flow being asynchronous
 */
enum ExecutionModel {
    SYNC,
    ASYNC
}

/// @title IRoycoKernel
/// @dev An abridged interface for Royco Kernel
interface IRoycoKernel {
    /**
     * @notice Returns the execution model for the senior tranche's increase NAV operation
     * @return The execution model for the senior tranche's increase NAV operation - SYNC or ASYNC
     */
    function ST_DEPOSIT_EXECUTION_MODEL() external pure returns (ExecutionModel);

    /**
     * @notice Returns the execution model for the junior tranche's increase NAV operation
     * @return The execution model for the junior tranche's increase NAV operation - SYNC or ASYNC
     */
    function JT_DEPOSIT_EXECUTION_MODEL() external pure returns (ExecutionModel);
}
