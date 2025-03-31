// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract DeFiYieldLottery is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public usdc;

    struct Participant {
        uint256 depositAmount;
        bool hasParticipated;
    }

    mapping(address => Participant) public participants;
    address[] public participantList;

    constructor(address _usdcAddress) {
        usdc = IERC20(_usdcAddress);
    }

    // 예치
    function deposit(uint256 _amount) external {
        require(_amount > 0, "금액은 0보다 커야 합니다");

        usdc.safeTransferFrom(msg.sender, address(this), _amount);

        if (!participants[msg.sender].hasParticipated) {
            participantList.push(msg.sender);
            participants[msg.sender].hasParticipated = true;
        }

        participants[msg.sender].depositAmount += _amount;

        emit Deposited(msg.sender, _amount);
    }

    // 출금
    function withdraw() external {
        uint256 amount = participants[msg.sender].depositAmount;
        require(amount > 0, "출금할 예치금이 없습니다");

        participants[msg.sender].depositAmount = 0;
        usdc.safeTransfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

    // 참가자 수
    function getParticipantCount() external view returns (uint256) {
        return participantList.length;
    }

    // 참가자 목록
    function getAllParticipants() external view returns (address[] memory) {
        return participantList;
    }

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
}
