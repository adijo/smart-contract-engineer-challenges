// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract MultiDelegatecall {
  function multiDelegatecall(bytes[] memory data)
    external
    payable
    returns (bytes[] memory)
  {
    bytes[] memory results = new bytes[](data.length);
    for (uint256 i = 0; i < data.length; i++) {
      (bool success, bytes memory result) = address(this).delegatecall(data[i]);
      require(success, "tx failed");
      results[i] = result;
    }
    return results;
  }
}

contract TestMultiDelegatecall is MultiDelegatecall {
  event Log(address caller, string func, uint256 i);

  function func1(uint256 x, uint256 y) external {
    emit Log(msg.sender, "func1", x + y);
  }

  function func2() external returns (uint256) {
    emit Log(msg.sender, "func2", 2);
    return 111;
  }
}
