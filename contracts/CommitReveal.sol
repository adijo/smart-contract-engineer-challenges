// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract CommitReveal {
  event UserCommit(address);
  event UserReveal(address, Choice);

  struct Commitment {
    address sender;
    bool revealed;
    bytes32 commitment;
  }

  enum Choice {
    A,
    B
  }

  mapping(address => Commitment) public commitments;

  function commit(bytes32 commitment) external {
    require(commitments[msg.sender].sender == address(0), "Already committed");

    commitments[msg.sender] = Commitment({
      sender: msg.sender,
      revealed: false,
      commitment: commitment
    });

    emit UserCommit(msg.sender);
  }

  function reveal(Choice choice, bytes32 salt) external {
    require(
      commitments[msg.sender].sender != address(0),
      "No commitments for msg.sender"
    );
    Commitment storage commitment = commitments[msg.sender];
    require(!commitment.revealed, "Already revealed");
    require(
      getSaltedHash(msg.sender, choice, salt) == commitment.commitment,
      "Hash does not match"
    );

    commitment.revealed = true;

    emit UserReveal(msg.sender, choice);
  }

  function getSaltedHash(
    address sender,
    Choice choice,
    bytes32 salt
  ) public pure returns (bytes32) {
    return keccak256(abi.encodePacked(sender, choice, salt));
  }
}
