//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract staking {
    address public owner;

    struct Position {
        uint256 positionId;
        address walletAddress;
        uint256 createDate;
        uint256 unlockDate;
        uint256 percentInterest;
        uint256 WEIstaked;
        uint256 WEIInterest;
        bool open;
    }

    Position position;

    uint256 public currentPositionId;
    mapping(uint256 => Position) public positions;
    mapping(address => uint[]) public positionIdsByAddress;
    mapping(uint256 => uint256) public tiers;
    uint[] public lockPeriods;

    constructor() payable {
        owner = msg.sender;
        currentPositionId = 0;

        tiers[0] = 700;
        tiers[30] = 800;
        tiers[60] = 900;
        tiers[90] = 1200;

        lockPeriods.push(0);
        lockPeriods.push(30);
        lockPeriods.push(60);
        lockPeriods.push(90);
    }

    function stakeEther(uint numDays) external payable {
        require(tiers[numDays] > 0, "Mapping not Found");
        positions[currentPositionId] = Position(
            currentPositionId,
            msg.sender,
            block.timestamp,
            block.timestamp + (numDays * 1 days),
            tiers[numDays],
            msg.value,
            calculateInterest(tiers[numDays], msg.value),
            true
        );
        positionIdsByAddress[msg.sender].push(currentPositionId);
        currentPositionId += 1;
    }

    function calculateInterest(
        uint256 basisPoints,
        uint256 weiAmount
    ) private pure returns (uint256) {
        return (basisPoints * weiAmount) / 10000;
    }

    function getLockPeriods() external view returns (uint256[] memory) {
        return lockPeriods;
    }

    function getInterestRate(uint256 numDays) external view returns (uint256) {
        return tiers[numDays];
    }

    function getPositionById(
        uint256 positionId
    ) external view returns (Position memory) {
        return positions[positionId];
    }

    function getPositionIdsForAddress(
        address walletAddress
    ) external view returns (uint[] memory) {
        return positionIdsByAddress[walletAddress];
    }

    function closePosition(uint positionId) external {
        require(
            positions[positionId].walletAddress == msg.sender,
            "Only position creator may modify position"
        );
        require(positions[positionId].open == true, "Position is closed");

        positions[positionId].open = false;
        uint256 amount = positions[positionId].WEIstaked +
            positions[positionId].WEIInterest;
        payable(msg.sender).call{value: amount}("");
    }
}
