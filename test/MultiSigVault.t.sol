// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/multisig/MultiSigVault.sol";

contract MultiSigVaultTest is Test {
    MultiSigVault public msVault;

    address public signer1;
    address public signer2;
    address public signer3;
    address public nonSigner;
    address public recipient;

    function setUp() public {
        signer1 = makeAddr("signer1");
        signer2 = makeAddr("signer2");
        signer3 = makeAddr("signer3");
        nonSigner = makeAddr("nonSigner");
        recipient = makeAddr("recipient");

        msVault = new MultiSigVault();

        vm.deal(signer1, 100 ether);
    }

    function test_CreateMultiSigVault() public {
        address[] memory signers = new address[](3);
        signers[0] = signer1;
        signers[1] = signer2;
        signers[2] = signer3;

        uint256 vaultId = msVault.createMultiSigVault(signers, 2);

        MultiSigTypes.MultiSigConfig memory config = msVault.getConfig(vaultId);
        assertEq(config.signers.length, 3);
        assertEq(config.threshold, 2);
        assertTrue(config.isActive);
    }

    function test_DepositETH() public {
        address[] memory signers = new address[](2);
        signers[0] = signer1;
        signers[1] = signer2;

        uint256 vaultId = msVault.createMultiSigVault(signers, 2);

        vm.prank(signer1);
        msVault.depositETH{value: 10 ether}(vaultId);

        assertEq(msVault.ethBalances(vaultId), 10 ether);
    }

    function test_ProposeAndApproveTransaction() public {
        address[] memory signers = new address[](2);
        signers[0] = signer1;
        signers[1] = signer2;

        uint256 vaultId = msVault.createMultiSigVault(signers, 2);

        vm.prank(signer1);
        msVault.depositETH{value: 10 ether}(vaultId);

        // Propose
        vm.prank(signer1);
        uint256 txId = msVault.proposeTransaction(vaultId, recipient, 1 ether, "");

        MultiSigTypes.Transaction memory txn = msVault.getTransaction(vaultId, txId);
        assertEq(txn.approvalCount, 1);
        assertEq(uint256(txn.status), uint256(MultiSigTypes.TxStatus.Pending));

        // Approve
        vm.prank(signer2);
        msVault.approveTransaction(vaultId, txId);

        txn = msVault.getTransaction(vaultId, txId);
        assertEq(txn.approvalCount, 2);
    }

    function test_ExecuteTransaction() public {
        address[] memory signers = new address[](2);
        signers[0] = signer1;
        signers[1] = signer2;

        uint256 vaultId = msVault.createMultiSigVault(signers, 2);

        vm.prank(signer1);
        msVault.depositETH{value: 10 ether}(vaultId);

        vm.prank(signer1);
        uint256 txId = msVault.proposeTransaction(vaultId, recipient, 1 ether, "");

        vm.prank(signer2);
        msVault.approveTransaction(vaultId, txId);

        uint256 recipientBalanceBefore = recipient.balance;

        vm.prank(signer1);
        msVault.executeTransaction(vaultId, txId);

        assertEq(recipient.balance - recipientBalanceBefore, 1 ether);

        MultiSigTypes.Transaction memory txn = msVault.getTransaction(vaultId, txId);
        assertEq(uint256(txn.status), uint256(MultiSigTypes.TxStatus.Executed));
    }

    function test_RevertNonSignerPropose() public {
        address[] memory signers = new address[](2);
        signers[0] = signer1;
        signers[1] = signer2;

        uint256 vaultId = msVault.createMultiSigVault(signers, 2);

        vm.prank(nonSigner);
        vm.expectRevert(MultiSigVault.NotSigner.selector);
        msVault.proposeTransaction(vaultId, recipient, 1 ether, "");
    }

    function test_RevertInsufficientApprovals() public {
        address[] memory signers = new address[](3);
        signers[0] = signer1;
        signers[1] = signer2;
        signers[2] = signer3;

        uint256 vaultId = msVault.createMultiSigVault(signers, 3);

        vm.prank(signer1);
        msVault.depositETH{value: 10 ether}(vaultId);

        vm.prank(signer1);
        uint256 txId = msVault.proposeTransaction(vaultId, recipient, 1 ether, "");

        vm.prank(signer2);
        msVault.approveTransaction(vaultId, txId);

        // Only 2 approvals, need 3
        vm.prank(signer1);
        vm.expectRevert(MultiSigVault.InsufficientApprovals.selector);
        msVault.executeTransaction(vaultId, txId);
    }
}
