// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

/// @title IRoycoFactory
/// @dev An abridged interface for the Royco Factory
interface IRoycoFactory {
    /// @dev Returns the corresponding junior tranche to the specified senior tranche
    function seniorTrancheToJuniorTranche(address _st) external view returns (address jt);

    /// @dev Returns the corresponding senior tranche to the specified junior tranche
    function juniorTrancheToSeniorTranche(address _jt) external view returns (address st);

    /**
     * @notice Returns whether the caller can call the target with the specified selector
     * @param _caller The address of the caller
     * @param _target The address of the target
     * @param _selector The selector of the function
     * @return allowed Whether the call is allowed without delay
     * @return delay The delay in seconds before the call can be executed (0 if immediate)
     */

    function canCall(address _caller, address _target, bytes4 _selector)
        external
        view
        returns (bool allowed, uint32 delay);
}
