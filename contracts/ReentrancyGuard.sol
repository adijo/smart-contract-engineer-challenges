// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract ReentrancyGuard {
  // Count stores number of times the function test was called
  uint256 public count;
  bool private isLocked;

  modifier monitor() {
    require(!isLocked, "Contract is locked");
    isLocked = true;
    _;
    isLocked = false;
  }

  function test(address _contract) external monitor {
    (bool success, ) = _contract.call("");
    require(success, "tx failed");
    count += 1;
  }
}
