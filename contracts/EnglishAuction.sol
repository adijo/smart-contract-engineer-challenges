// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IERC721 {
  function transferFrom(
    address from,
    address to,
    uint256 nftId
  ) external;
}

contract EnglishAuction {
  event Start();
  event Bid(address indexed sender, uint256 amount);
  event Withdraw(address indexed bidder, uint256 amount);
  event End(address winner, uint256 amount);

  IERC721 public immutable nft;
  uint256 public immutable nftId;

  address payable public immutable seller;
  uint256 public endAt;
  bool public started;
  bool public ended;

  address public highestBidder;
  uint256 public highestBid;
  // mapping from bidder to amount of ETH the bidder can withdraw
  mapping(address => uint256) public bids;

  constructor(
    address _nft,
    uint256 _nftId,
    uint256 _startingBid
  ) {
    nft = IERC721(_nft);
    nftId = _nftId;

    seller = payable(msg.sender);
    highestBid = _startingBid;
  }

  modifier onlySeller() {
    require(msg.sender == seller, "Only seller can call");
    _;
  }

  function start() external onlySeller {
    require(!started, "Auction has already started");

    started = true;
    endAt = block.timestamp + 7 days;

    nft.transferFrom(seller, address(this), nftId);

    emit Start();
  }

  function bid() external payable {
    require(started, "Auction has not yet started");
    require(block.timestamp < endAt, "Auction has expired");
    require(
      msg.value > highestBid,
      "Bid must be greater than previous highest bid"
    );

    bids[highestBidder] += highestBid;

    highestBidder = msg.sender;
    highestBid = msg.value;

    emit Bid(msg.sender, msg.value);
  }

  function withdraw() external {
    require(bids[msg.sender] > 0, "Not eligible to withdraw");

    uint256 canWithdraw = bids[msg.sender];

    bids[msg.sender] = 0;
    payable(msg.sender).transfer(canWithdraw);

    emit Withdraw(msg.sender, canWithdraw);
  }

  function end() external {
    require(!ended, "Already ended");
    require(started, "Auction has not yet started");
    require(block.timestamp >= endAt, "Auction has not expired");
    ended = true;

    nft.transferFrom(address(this), highestBidder, nftId);
    payable(seller).transfer(highestBid);

    emit End(highestBidder, highestBid);
  }
}
