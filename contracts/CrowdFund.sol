// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./IERC20.sol";

contract CrowdFund {
  event Launch(
    uint256 id,
    address indexed creator,
    uint256 goal,
    uint32 startAt,
    uint32 endAt
  );
  event Cancel(uint256 id);
  event Pledge(uint256 indexed id, address indexed caller, uint256 amount);
  event Unpledge(uint256 indexed id, address indexed caller, uint256 amount);
  event Claim(uint256 id);
  event Refund(uint256 id, address indexed caller, uint256 amount);

  struct Campaign {
    // Creator of campaign
    address creator;
    // Amount of tokens to raise
    uint256 goal;
    // Total amount pledged
    uint256 pledged;
    // Timestamp of start of campaign
    uint32 startAt;
    // Timestamp of end of campaign
    uint32 endAt;
    // True if goal was reached and creator has claimed the tokens.
    bool claimed;
  }

  IERC20 public immutable token;
  // Total count of campaigns created.
  // It is also used to generate id for new campaigns.
  uint256 public count;
  // Mapping from id to Campaign
  mapping(uint256 => Campaign) public campaigns;
  // Mapping from campaign id => pledger => amount pledged
  mapping(uint256 => mapping(address => uint256)) public pledgedAmount;

  constructor(address _token) {
    token = IERC20(_token);
  }

  function launch(
    uint256 _goal,
    uint32 _startAt,
    uint32 _endAt
  ) external {
    require(_startAt >= block.timestamp);
    require(_startAt <= _endAt);
    require(_endAt <= block.timestamp + 90 days);

    campaigns[++count] = Campaign({
      creator: msg.sender,
      goal: _goal,
      pledged: 0,
      startAt: _startAt,
      endAt: _endAt,
      claimed: false
    });

    emit Launch(count, msg.sender, _goal, _startAt, _endAt);
  }

  function cancel(uint256 _id) external {
    require(_id <= count, "Invalid campaign ID");
    require(
      campaigns[_id].creator == msg.sender,
      "Only the creator can cancel"
    );
    require(campaigns[_id].startAt > block.timestamp);

    delete campaigns[_id];

    emit Cancel(_id);
  }

  function pledge(uint256 _id, uint256 _amount) external {
    require(_id <= count, "Invalid campaign ID");
    Campaign storage campaign = campaigns[_id];

    require(campaign.startAt <= block.timestamp);
    require(campaign.endAt > block.timestamp);

    campaign.pledged += _amount;
    pledgedAmount[_id][msg.sender] += _amount;

    token.transferFrom(msg.sender, address(this), _amount);

    emit Pledge(_id, msg.sender, _amount);
  }

  function unpledge(uint256 _id, uint256 _amount) external {
    require(_id <= count, "Invalid campaign ID");
    Campaign storage campaign = campaigns[_id];
    require(campaign.endAt > block.timestamp);
    require(pledgedAmount[_id][msg.sender] >= _amount);

    campaign.pledged -= _amount;
    pledgedAmount[_id][msg.sender] -= _amount;

    token.transfer(msg.sender, _amount);

    emit Unpledge(_id, msg.sender, _amount);
  }

  function claim(uint256 _id) external {
    require(_id <= count, "Invalid campaign ID");
    Campaign storage campaign = campaigns[_id];
    require(campaign.endAt < block.timestamp);
    require(campaign.creator == msg.sender);
    require(campaign.pledged >= campaign.goal);
    require(!campaign.claimed);

    campaign.claimed = true;

    token.transfer(msg.sender, campaign.pledged);

    emit Claim(_id);
  }

  function refund(uint256 _id) external {
    require(_id <= count, "Invalid campaign ID");
    Campaign storage campaign = campaigns[_id];
    require(campaign.endAt < block.timestamp);
    require(campaign.pledged < campaign.goal);

    uint256 amountPledgedByUser = pledgedAmount[_id][msg.sender];
    delete pledgedAmount[_id][msg.sender];

    token.transfer(msg.sender, amountPledgedByUser);

    emit Refund(_id, msg.sender, amountPledgedByUser);
  }
}
