// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/SavingsVault.sol";
import "../src/analytics/VaultAnalytics.sol";
import "../src/risk/RiskAssessment.sol";
import "../src/security/EmergencyPause.sol";
import "../src/insurance/VaultInsurance.sol";
import "../src/yield/AdvancedYieldFarming.sol";
import "../src/governance/MultiSigGovernance.sol";
import "../src/migration/VaultMigrationManager.sol";
import "../src/utils/GasOptimizer.sol";

contract DeployFullSuite is Script {
    struct DeploymentConfig {
        uint256 protocolFee;
        uint256 maxProtocolFee;
        address[] governors;
        uint256[] governorWeights;
        bool deployAnalytics;
        bool deployRiskAssessment;
        bool deployInsurance;
        bool deployYieldFarming;
        bool deployGovernance;
        bool deployMigration;
    }
    
    struct DeployedContracts {
        address savingsVault;
        address vaultAnalytics;
        address riskAssessment;
        address emergencyPause;
        address vaultInsurance;
        address yieldFarming;
        address governance;
        address migrationManager;
        address gasTracker;
    }
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("Deploying with account:", deployer);
        console.log("Account balance:", deployer.balance);
        
        vm.startBroadcast(deployerPrivateKey);
        
        DeploymentConfig memory config = getDeploymentConfig();
        DeployedContracts memory contracts = deployContracts(config);
        
        // Configure contracts
        configureContracts(contracts, config);
        
        // Verify deployments
        verifyDeployments(contracts);
        
        // Save deployment info
        saveDeploymentInfo(contracts);
        
        vm.stopBroadcast();
        
        console.log("Deployment completed successfully!");
    }
    
    function getDeploymentConfig() internal view returns (DeploymentConfig memory) {
        // Default governors for testnet
        address[] memory governors = new address[](3);
        governors[0] = vm.envAddress("GOVERNOR_1");
        governors[1] = vm.envAddress("GOVERNOR_2");
        governors[2] = vm.envAddress("GOVERNOR_3");
        
        uint256[] memory weights = new uint256[](3);
        weights[0] = 100;
        weights[1] = 100;
        weights[2] = 100;
        
        return DeploymentConfig({
            protocolFee: 50, // 0.5%
            maxProtocolFee: 200, // 2%
            governors: governors,
            governorWeights: weights,
            deployAnalytics: true,
            deployRiskAssessment: true,
            deployInsurance: true,
            deployYieldFarming: true,
            deployGovernance: true,
            deployMigration: true
        });
    }
    
    function deployContracts(DeploymentConfig memory config) internal returns (DeployedContracts memory) {
        DeployedContracts memory contracts;
        
        console.log("Deploying core SavingsVault...");
        contracts.savingsVault = address(new SavingsVault(
            config.protocolFee,
            config.maxProtocolFee
        ));
        console.log("SavingsVault deployed at:", contracts.savingsVault);
        
        if (config.deployAnalytics) {
            console.log("Deploying VaultAnalytics...");
            contracts.vaultAnalytics = address(new VaultAnalytics(contracts.savingsVault));
            console.log("VaultAnalytics deployed at:", contracts.vaultAnalytics);
        }
        
        if (config.deployRiskAssessment) {
            console.log("Deploying RiskAssessment...");
            contracts.riskAssessment = address(new RiskAssessment());
            console.log("RiskAssessment deployed at:", contracts.riskAssessment);
        }
        
        console.log("Deploying EmergencyPause...");
        contracts.emergencyPause = address(new EmergencyPause());
        console.log("EmergencyPause deployed at:", contracts.emergencyPause);
        
        if (config.deployInsurance) {
            console.log("Deploying VaultInsurance...");
            contracts.vaultInsurance = address(new VaultInsurance());
            console.log("VaultInsurance deployed at:", contracts.vaultInsurance);
        }
        
        if (config.deployYieldFarming) {
            console.log("Deploying AdvancedYieldFarming...");
            contracts.yieldFarming = address(new AdvancedYieldFarming());
            console.log("AdvancedYieldFarming deployed at:", contracts.yieldFarming);
        }
        
        if (config.deployGovernance) {
            console.log("Deploying MultiSigGovernance...");
            contracts.governance = address(new MultiSigGovernance(
                config.governors,
                config.governorWeights
            ));
            console.log("MultiSigGovernance deployed at:", contracts.governance);
        }
        
        if (config.deployMigration) {
            console.log("Deploying VaultMigrationManager...");
            contracts.migrationManager = address(new VaultMigrationManager());
            console.log("VaultMigrationManager deployed at:", contracts.migrationManager);
        }
        
        console.log("Deploying GasTracker...");
        contracts.gasTracker = address(new GasTracker());
        console.log("GasTracker deployed at:", contracts.gasTracker);
        
        return contracts;
    }
    
    function configureContracts(
        DeployedContracts memory contracts,
        DeploymentConfig memory config
    ) internal {
        console.log("Configuring contracts...");
        
        // Configure EmergencyPause operators
        EmergencyPause emergencyPause = EmergencyPause(contracts.emergencyPause);
        for (uint256 i = 0; i < config.governors.length; i++) {
            emergencyPause.addEmergencyOperator(config.governors[i]);
        }
        
        // Fund insurance contract if deployed
        if (contracts.vaultInsurance != address(0)) {
            VaultInsurance insurance = VaultInsurance(payable(contracts.vaultInsurance));
            insurance.depositToFund{value: 1 ether}(); // Initial funding
        }
        
        // Add initial yield strategies if deployed
        if (contracts.yieldFarming != address(0)) {
            AdvancedYieldFarming farming = AdvancedYieldFarming(contracts.yieldFarming);
            // Add mock strategies for testing
            farming.addStrategy(address(0x1), 500, 30); // 5% APY, low risk
            farming.addStrategy(address(0x2), 800, 50); // 8% APY, medium risk
        }
        
        console.log("Configuration completed!");
    }
    
    function verifyDeployments(DeployedContracts memory contracts) internal view {
        console.log("Verifying deployments...");
        
        require(contracts.savingsVault != address(0), "SavingsVault deployment failed");
        require(contracts.emergencyPause != address(0), "EmergencyPause deployment failed");
        require(contracts.gasTracker != address(0), "GasTracker deployment failed");
        
        // Verify contract code exists
        require(contracts.savingsVault.code.length > 0, "SavingsVault has no code");
        require(contracts.emergencyPause.code.length > 0, "EmergencyPause has no code");
        
        console.log("All deployments verified successfully!");
    }
    
    function saveDeploymentInfo(DeployedContracts memory contracts) internal {
        string memory deploymentInfo = string(abi.encodePacked(
            "{\n",
            '  "network": "', vm.toString(block.chainid), '",\n',
            '  "timestamp": "', vm.toString(block.timestamp), '",\n',
            '  "deployer": "', vm.toString(msg.sender), '",\n',
            '  "contracts": {\n',
            '    "SavingsVault": "', vm.toString(contracts.savingsVault), '",\n',
            '    "VaultAnalytics": "', vm.toString(contracts.vaultAnalytics), '",\n',
            '    "RiskAssessment": "', vm.toString(contracts.riskAssessment), '",\n',
            '    "EmergencyPause": "', vm.toString(contracts.emergencyPause), '",\n',
            '    "VaultInsurance": "', vm.toString(contracts.vaultInsurance), '",\n',
            '    "AdvancedYieldFarming": "', vm.toString(contracts.yieldFarming), '",\n',
            '    "MultiSigGovernance": "', vm.toString(contracts.governance), '",\n',
            '    "VaultMigrationManager": "', vm.toString(contracts.migrationManager), '",\n',
            '    "GasTracker": "', vm.toString(contracts.gasTracker), '"\n',
            '  }\n',
            '}'
        ));
        
        string memory filename = string(abi.encodePacked(
            "deployments/",
            vm.toString(block.chainid),
            "-",
            vm.toString(block.timestamp),
            ".json"
        ));
        
        vm.writeFile(filename, deploymentInfo);
        console.log("Deployment info saved to:", filename);
    }
}

contract DeployTestnet is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy minimal setup for testing
        SavingsVault vault = new SavingsVault(50, 200); // 0.5% fee, 2% max
        EmergencyPause pause = new EmergencyPause();
        GasTracker tracker = new GasTracker();
        
        console.log("Testnet deployment completed:");
        console.log("SavingsVault:", address(vault));
        console.log("EmergencyPause:", address(pause));
        console.log("GasTracker:", address(tracker));
        
        vm.stopBroadcast();
    }
}

contract DeployMainnet is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // Mainnet safety checks
        require(block.chainid == 8453, "Not Base mainnet");
        require(vm.addr(deployerPrivateKey).balance >= 0.1 ether, "Insufficient balance");
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy production configuration
        SavingsVault vault = new SavingsVault(50, 200);
        
        // Deploy security contracts
        EmergencyPause pause = new EmergencyPause();
        VaultInsurance insurance = new VaultInsurance();
        
        // Deploy governance
        address[] memory governors = new address[](5);
        governors[0] = 0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6; // Multisig 1
        governors[1] = 0x8ba1f109551bD432803012645Hac136c22C2c8b6; // Multisig 2
        governors[2] = 0x9ca2f209551bD432803012645Hac136c22C2c8b7; // Multisig 3
        governors[3] = 0xAdb3f309551bD432803012645Hac136c22C2c8b8; // Multisig 4
        governors[4] = 0xBec4f409551bD432803012645Hac136c22C2c8b9; // Multisig 5
        
        uint256[] memory weights = new uint256[](5);
        weights[0] = 200; // 20%
        weights[1] = 200; // 20%
        weights[2] = 200; // 20%
        weights[3] = 200; // 20%
        weights[4] = 200; // 20%
        
        MultiSigGovernance governance = new MultiSigGovernance(governors, weights);
        
        // Fund insurance with initial capital
        insurance.depositToFund{value: 5 ether}();
        
        console.log("Mainnet deployment completed:");
        console.log("SavingsVault:", address(vault));
        console.log("EmergencyPause:", address(pause));
        console.log("VaultInsurance:", address(insurance));
        console.log("MultiSigGovernance:", address(governance));
        
        vm.stopBroadcast();
    }
}
