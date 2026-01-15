// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title SavingsChallenge
 * @notice Gamified savings challenges
 */
contract SavingsChallenge {
    struct Challenge {
        string name;
        uint256 targetAmount;
        uint256 duration;
        uint256 startTime;
        uint256 participantCount;
        uint256 prizePool;
        bool isActive;
    }

    struct Participant {
        uint256 deposited;
        uint256 joinedAt;
        bool completed;
        bool claimed;
    }

    Challenge[] public challenges;
    mapping(uint256 => mapping(address => Participant)) public participants;
    mapping(uint256 => address[]) public challengeParticipants;

    event ChallengeCreated(uint256 indexed challengeId, string name, uint256 target);
    event JoinedChallenge(uint256 indexed challengeId, address participant);
    event ChallengeCompleted(uint256 indexed challengeId, address participant);

    function createChallenge(
        string calldata name,
        uint256 targetAmount,
        uint256 duration
    ) external payable returns (uint256 challengeId) {
        challengeId = challenges.length;

        challenges.push(Challenge({
            name: name,
            targetAmount: targetAmount,
            duration: duration,
            startTime: block.timestamp,
            participantCount: 0,
            prizePool: msg.value,
            isActive: true
        }));

        emit ChallengeCreated(challengeId, name, targetAmount);
    }

    function joinChallenge(uint256 challengeId) external payable {
        require(challenges[challengeId].isActive, "Not active");
        require(participants[challengeId][msg.sender].joinedAt == 0, "Already joined");

        participants[challengeId][msg.sender] = Participant({
            deposited: msg.value,
            joinedAt: block.timestamp,
            completed: false,
            claimed: false
        });

        challengeParticipants[challengeId].push(msg.sender);
        challenges[challengeId].participantCount++;
        challenges[challengeId].prizePool += msg.value;

        emit JoinedChallenge(challengeId, msg.sender);

        if (msg.value >= challenges[challengeId].targetAmount) {
            participants[challengeId][msg.sender].completed = true;
            emit ChallengeCompleted(challengeId, msg.sender);
        }
    }

    function addDeposit(uint256 challengeId) external payable {
        require(participants[challengeId][msg.sender].joinedAt > 0, "Not participant");

        participants[challengeId][msg.sender].deposited += msg.value;
        challenges[challengeId].prizePool += msg.value;

        if (participants[challengeId][msg.sender].deposited >= challenges[challengeId].targetAmount) {
            participants[challengeId][msg.sender].completed = true;
            emit ChallengeCompleted(challengeId, msg.sender);
        }
    }

    event PrizeClaimed(uint256 indexed challengeId, address indexed winner, uint256 amount);

    /// @notice Claim prize after completing challenge
    function claimPrize(uint256 challengeId) external {
        Challenge storage challenge = challenges[challengeId];
        Participant storage participant = participants[challengeId][msg.sender];

        require(participant.completed, "Not completed");
        require(!participant.claimed, "Already claimed");
        require(block.timestamp >= challenge.startTime + challenge.duration, "Challenge not ended");

        participant.claimed = true;

        // Calculate share of prize pool
        uint256 completedCount = getCompletedCount(challengeId);
        uint256 prize = challenge.prizePool / completedCount;

        payable(msg.sender).transfer(prize);
        emit PrizeClaimed(challengeId, msg.sender, prize);
    }

    /// @notice Get count of completed participants
    function getCompletedCount(uint256 challengeId) public view returns (uint256 count) {
        address[] memory parts = challengeParticipants[challengeId];
        for (uint256 i = 0; i < parts.length; i++) {
            if (participants[challengeId][parts[i]].completed) count++;
        }
    }

    /// @notice Get challenge stats
    function getChallengeStats(uint256 challengeId) external view returns (
        uint256 participantCount,
        uint256 completedCount,
        uint256 prizePool,
        uint256 timeRemaining
    ) {
        Challenge memory c = challenges[challengeId];
        participantCount = c.participantCount;
        completedCount = getCompletedCount(challengeId);
        prizePool = c.prizePool;
        uint256 endTime = c.startTime + c.duration;
        timeRemaining = block.timestamp < endTime ? endTime - block.timestamp : 0;
    }
}
