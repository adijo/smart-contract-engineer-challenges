// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract DeployWithCreate2 {
  address public owner;

  constructor(address _owner) {
    owner = _owner;
  }
}
