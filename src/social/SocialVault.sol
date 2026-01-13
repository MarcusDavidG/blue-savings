// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title SocialVault
 * @notice Group savings vault for friends/family
 */
contract SocialVault {
    struct GroupVault {
        string name;
        address creator;
        address[] members;
        uint256 goalAmount;
        uint256 totalDeposited;
        uint256 unlockTimestamp;
        bool isActive;
    }

    mapping(uint256 => GroupVault) public groupVaults;
    mapping(uint256 => mapping(address => uint256)) public memberDeposits;
    mapping(uint256 => mapping(address => bool)) public isMember;
    uint256 public vaultCounter;

    event GroupVaultCreated(uint256 indexed vaultId, string name, address creator);
    event MemberJoined(uint256 indexed vaultId, address member);
    event MemberDeposited(uint256 indexed vaultId, address member, uint256 amount);

    function createGroupVault(
        string calldata name,
        uint256 goalAmount,
        uint256 unlockTimestamp,
        address[] calldata initialMembers
    ) external returns (uint256 vaultId) {
        vaultId = vaultCounter++;

        GroupVault storage gv = groupVaults[vaultId];
        gv.name = name;
        gv.creator = msg.sender;
        gv.goalAmount = goalAmount;
        gv.unlockTimestamp = unlockTimestamp;
        gv.isActive = true;
        gv.members.push(msg.sender);
        isMember[vaultId][msg.sender] = true;

        for (uint256 i = 0; i < initialMembers.length; i++) {
            gv.members.push(initialMembers[i]);
            isMember[vaultId][initialMembers[i]] = true;
        }

        emit GroupVaultCreated(vaultId, name, msg.sender);
    }

    function deposit(uint256 vaultId) external payable {
        require(isMember[vaultId][msg.sender], "Not member");
        require(groupVaults[vaultId].isActive, "Not active");

        memberDeposits[vaultId][msg.sender] += msg.value;
        groupVaults[vaultId].totalDeposited += msg.value;

        emit MemberDeposited(vaultId, msg.sender, msg.value);
    }

    function getMembers(uint256 vaultId) external view returns (address[] memory) {
        return groupVaults[vaultId].members;
    }

    function getMemberDeposit(uint256 vaultId, address member) external view returns (uint256) {
        return memberDeposits[vaultId][member];
    }
}
