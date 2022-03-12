// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IFunctionSelector {
  function execute(bytes4 func) external;
}

contract FunctionSelectorExploit {
  IFunctionSelector public target;

  constructor(address _target) {
    target = IFunctionSelector(_target);
  }

  function pwn() external {
    // write your code here
  }
}
