// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./ReferralStorage.sol";
import "./ReferralEvents.sol";
import "./ReferralErrors.sol";
import "./interfaces/IERC721.sol";

/**
 * @title ReferralSystem
 * @notice Referral tracking and rewards for vault deposits
 * @dev Implements tiered referral rewards based on referral count
 */
contract ReferralSystem is ReferralStorage, ReferralEvents, ReferralErrors {
    /// @notice Contract owner
    address public owner;

    /// @notice Basis points denominator
    uint256 public constant BPS_DENOMINATOR = 10000;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /// @notice Register as a referrer with a unique code
    function registerAsReferrer(bytes32 code) external {
        if (code == bytes32(0)) revert InvalidReferralCode();
        if (codeToReferrer[code] != address(0)) revert CodeAlreadyTaken(code);
        if (referrers[msg.sender].referralCode != bytes32(0)) revert AlreadyRegistered(msg.sender);

        referrers[msg.sender] = Referrer({
            referralCode: code,
            totalReferrals: 0,
            totalRewardsEarned: 0,
            unclaimedRewards: 0,
            tier: ReferralTier.Bronze,
            joinedAt: block.timestamp,
            isActive: true
        });

        codeToReferrer[code] = msg.sender;

        emit ReferrerRegistered(msg.sender, code);
    }

    /// @notice Record a referral when new user joins
    function recordReferral(address referee, bytes32 code) external {
        if (referee == address(0)) revert InvalidReferralCode();
        if (refereeToReferrer[referee] != address(0)) revert AlreadyHasReferrer(referee);

        address referrer = codeToReferrer[code];
        if (referrer == address(0)) revert CodeNotFound(code);
        if (referrer == referee) revert CannotReferSelf();
        if (!referrers[referrer].isActive) revert ReferrerNotActive(referrer);

        refereeToReferrer[referee] = referrer;
        referrers[referrer].totalReferrals++;

        referrals.push(Referral({
            referrer: referrer,
            referee: referee,
            timestamp: block.timestamp,
            rewardAmount: 0,
            rewardClaimed: false
        }));

        referrerReferrals[referrer].push(referrals.length - 1);

        _updateTier(referrer);

        emit ReferralRecorded(referrer, referee, 0);
    }

    /// @notice Credit rewards to referrer based on deposit
    function creditReward(address referee, uint256 depositAmount) external {
        address referrer = refereeToReferrer[referee];
        if (referrer == address(0)) return; // No referrer, skip

        uint256 rewardBps = _getRewardBps(referrers[referrer].tier);
        uint256 reward = (depositAmount * rewardBps) / BPS_DENOMINATOR;

        if (reward > rewardsPool) {
            reward = rewardsPool; // Cap at available pool
        }

        if (reward > 0) {
            rewardsPool -= reward;
            referrers[referrer].unclaimedRewards += reward;
            referrers[referrer].totalRewardsEarned += reward;
        }
    }

    /// @notice Claim accumulated rewards
    function claimRewards() external {
        uint256 amount = referrers[msg.sender].unclaimedRewards;
        if (amount == 0) revert NoRewardsToClaim();

        referrers[msg.sender].unclaimedRewards = 0;

        (bool success,) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");

        emit RewardsClaimed(msg.sender, amount);
    }

    /// @notice Fund the rewards pool
    function fundRewardsPool() external payable {
        rewardsPool += msg.value;
        emit RewardsPoolFunded(msg.sender, msg.value);
    }

    /// @notice Get reward BPS for tier
    function _getRewardBps(ReferralTier tier) internal pure returns (uint256) {
        if (tier == ReferralTier.Diamond) return DIAMOND_REWARD_BPS;
        if (tier == ReferralTier.Platinum) return PLATINUM_REWARD_BPS;
        if (tier == ReferralTier.Gold) return GOLD_REWARD_BPS;
        if (tier == ReferralTier.Silver) return SILVER_REWARD_BPS;
        return BRONZE_REWARD_BPS;
    }

    /// @notice Update referrer tier based on referral count
    function _updateTier(address referrer) internal {
        uint256 count = referrers[referrer].totalReferrals;
        ReferralTier oldTier = referrers[referrer].tier;
        ReferralTier newTier;

        if (count >= DIAMOND_THRESHOLD) {
            newTier = ReferralTier.Diamond;
        } else if (count >= PLATINUM_THRESHOLD) {
            newTier = ReferralTier.Platinum;
        } else if (count >= GOLD_THRESHOLD) {
            newTier = ReferralTier.Gold;
        } else if (count >= SILVER_THRESHOLD) {
            newTier = ReferralTier.Silver;
        } else {
            newTier = ReferralTier.Bronze;
        }

        if (newTier != oldTier) {
            referrers[referrer].tier = newTier;
            emit TierUpgraded(referrer, oldTier, newTier);
        }
    }

    /// @notice Receive ETH for rewards pool
    receive() external payable {
        rewardsPool += msg.value;
        emit RewardsPoolFunded(msg.sender, msg.value);
    }

    /// @notice NFT contract for referral badges
    address public referralBadgeNFT;

    /// @notice Track minted badges per tier per user
    mapping(address => mapping(ReferralTier => bool)) public mintedBadges;

    event ReferralBadgeMinted(address indexed referrer, ReferralTier tier, uint256 tokenId);

    /// @notice Set the referral badge NFT contract
    function setReferralBadgeNFT(address nft) external onlyOwner {
        referralBadgeNFT = nft;
    }

    /// @notice Mint referral badge NFT when reaching new tier
    function claimTierBadge(ReferralTier tier) external {
        require(referralBadgeNFT != address(0), "Badge NFT not set");
        require(uint8(referrers[msg.sender].tier) >= uint8(tier), "Tier not reached");
        require(!mintedBadges[msg.sender][tier], "Badge already claimed");

        mintedBadges[msg.sender][tier] = true;

        // Mint NFT (assumes NFT contract has mint function)
        (bool success, bytes memory data) = referralBadgeNFT.call(
            abi.encodeWithSignature("mint(address,uint256)", msg.sender, uint256(tier))
        );
        require(success, "Badge mint failed");

        uint256 tokenId = abi.decode(data, (uint256));
        emit ReferralBadgeMinted(msg.sender, tier, tokenId);
    }

    /// @notice Check if user can claim a badge
    function canClaimBadge(address referrer, ReferralTier tier) external view returns (bool) {
        return uint8(referrers[referrer].tier) >= uint8(tier) && !mintedBadges[referrer][tier];
    }
}
