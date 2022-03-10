// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract MultiSigWallet {
  event Deposit(address indexed sender, uint256 amount);
  event Submit(uint256 indexed txId);
  event Approve(address indexed owner, uint256 indexed txId);
  event Revoke(address indexed owner, uint256 indexed txId);
  event Execute(uint256 indexed txId);

  struct Transaction {
    address to;
    uint256 value;
    bytes data;
    bool executed;
  }

  address[] public owners;
  mapping(address => bool) public isOwner;
  uint256 public required;

  Transaction[] public transactions;
  // mapping from tx id => owner => bool
  mapping(uint256 => mapping(address => bool)) public approved;

  modifier onlyOwner() {
    require(isOwner[msg.sender], "not owner");
    _;
  }

  modifier txExists(uint256 _txId) {
    require(_txId < transactions.length, "tx does not exist");
    _;
  }

  modifier notApproved(uint256 _txId) {
    require(!approved[_txId][msg.sender], "tx already approved");
    _;
  }

  modifier notExecuted(uint256 _txId) {
    require(!transactions[_txId].executed, "tx already executed");
    _;
  }

  modifier isValidTx(uint256 _txId) {
    require(_txId < transactions.length, "Transaction does not exist");
    require(
      !transactions[_txId].executed,
      "Transaction has already been executed"
    );
    _;
  }

  constructor(address[] memory _owners, uint256 _required) {
    require(_owners.length > 0, "owners required");
    require(
      _required > 0 && _required <= _owners.length,
      "invalid required number of owners"
    );

    for (uint256 i; i < _owners.length; i++) {
      address owner = _owners[i];

      require(owner != address(0), "invalid owner");
      require(!isOwner[owner], "owner is not unique");

      isOwner[owner] = true;
      owners.push(owner);
    }

    required = _required;
  }

  receive() external payable {
    emit Deposit(msg.sender, msg.value);
  }

  function submit(
    address _to,
    uint256 _value,
    bytes calldata _data
  ) external onlyOwner {
    transactions.push(
      Transaction({ to: _to, value: _value, data: _data, executed: false })
    );

    emit Submit(transactions.length - 1);
  }

  function approve(uint256 _txId) external onlyOwner isValidTx(_txId) {
    require(
      !approved[_txId][msg.sender],
      "Transaction has already been approved by sender"
    );

    approved[_txId][msg.sender] = true;

    emit Approve(msg.sender, _txId);
  }

  function _getApprovalCount(uint256 _txId) private view returns (uint256) {
    uint256 currentApprovals = 0;
    for (uint256 i = 0; i < owners.length; i++) {
      if (approved[_txId][owners[i]]) {
        currentApprovals += 1;
      }
    }
    return currentApprovals;
  }

  function execute(uint256 _txId) external onlyOwner isValidTx(_txId) {
    uint256 currentApprovals = _getApprovalCount(_txId);

    Transaction storage transaction = transactions[_txId];
    transaction.executed = true;

    (bool success, ) = transaction.to.call{ value: transaction.value }(
      transaction.data
    );
    require(success, "Transaction failed");

    require(
      currentApprovals >= required,
      "Transaction does not have the required number of approvals"
    );
    emit Execute(_txId);
  }

  function revoke(uint256 _txId) external onlyOwner isValidTx(_txId) {
    require(
      approved[_txId][msg.sender],
      "Transaction has not been approved by sender"
    );

    approved[_txId][msg.sender] = false;

    emit Revoke(msg.sender, _txId);
  }
}
