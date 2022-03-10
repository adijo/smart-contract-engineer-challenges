// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract MultiCall {
  function multiCall(address[] calldata targets, bytes[] calldata data)
    external
    view
    returns (bytes[] memory)
  {
    require(targets.length == data.length, "Targets must be equal to data");
    bytes[] memory results = new bytes[](data.length);

    for (uint256 i = 0; i < data.length; i++) {
      (bool success, bytes memory response) = targets[i].staticcall(data[i]);
      results[i] = response;
      require(success, "tx failed");
    }

    return results;
  }
}
