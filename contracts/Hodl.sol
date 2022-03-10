// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Hodl {
  uint256 private constant HODL_DURATION = 3 * 365 days;

  mapping(address => uint256) public balanceOf;
  mapping(address => uint256) public lockedUntil;

  function deposit() external payable {
    balanceOf[msg.sender] += msg.value;
    lockedUntil[msg.sender] = block.timestamp + HODL_DURATION;
  }

  function withdraw() external {
    require(
      block.timestamp >= lockedUntil[msg.sender],
      "Funds locked until HODL_DURATION"
    );

    payable(msg.sender).transfer(balanceOf[msg.sender]);

    delete balanceOf[msg.sender];
    delete lockedUntil[msg.sender];
  }
}
