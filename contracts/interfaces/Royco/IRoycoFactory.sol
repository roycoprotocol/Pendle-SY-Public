// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.28;

/// @title IRoycoFactory
/// @dev An abridged interface for the Royco Factory
interface IRoycoFactory {
    /// @dev Returns the corresponding junior tranche to the specified senior tranche
    function seniorTrancheToJuniorTranche(address _st) external view returns (address jt);

    /// @dev Returns the corresponding senior tranche to the specified junior tranche
    function juniorTrancheToSeniorTranche(address _jt) external view returns (address st);
}
