// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract EtherWallet {
  address payable public owner;

  constructor() {
    owner = payable(msg.sender);
  }

  receive() external payable {}

  function withdraw(uint256 _amount) external {
    require(msg.sender == owner, "Only owner can withdraw");

    payable(owner).transfer(_amount);
  }
}
