// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title IBasenameRegistry
 * @notice Interface for Base Name Service registry
 */
interface IBasenameRegistry {
    function owner(bytes32 node) external view returns (address);
    function resolver(bytes32 node) external view returns (address);
}

/**
 * @title IBasenameResolver
 * @notice Interface for Base Name Service resolver
 */
interface IBasenameResolver {
    function addr(bytes32 node) external view returns (address);
    function name(bytes32 node) external view returns (string memory);
}

/**
 * @title BasenameResolver
 * @notice Resolves .base names to addresses for BlueSavings vault operations
 * @dev Integrates with Base Name Service (Basenames) for human-readable addresses
 * @author BlueSavings Team
 */
contract BasenameResolver {
    /// @notice Base Name Service Registry on Base mainnet
    IBasenameRegistry public immutable registry;

    /// @notice The namehash of the .base TLD
    bytes32 public constant BASE_NODE = keccak256(abi.encodePacked(bytes32(0), keccak256("base")));

    /// @notice Cache of resolved names (name hash => address)
    mapping(bytes32 => address) public resolvedCache;

    /// @notice Cache timestamp
    mapping(bytes32 => uint256) public cacheTimestamp;

    /// @notice Cache duration (1 hour)
    uint256 public constant CACHE_DURATION = 1 hours;

    /// @notice Contract owner
    address public owner;

    event NameResolved(string indexed name, address indexed resolvedAddress);
    event CacheUpdated(bytes32 indexed node, address indexed resolvedAddress);

    error InvalidName();
    error NameNotFound();
    error ResolutionFailed();

    constructor(address _registry) {
        registry = IBasenameRegistry(_registry);
        owner = msg.sender;
    }

    /// @notice Compute the namehash for a .base name
    /// @param name The name without .base suffix (e.g., "alice" for alice.base)
    function namehash(string memory name) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(BASE_NODE, keccak256(bytes(name))));
    }

    /// @notice Resolve a .base name to an address
    /// @param name The name without .base suffix
    /// @return addr The resolved address
    function resolve(string memory name) public returns (address addr) {
        if (bytes(name).length == 0) revert InvalidName();

        bytes32 node = namehash(name);

        // Check cache first
        if (cacheTimestamp[node] > 0 && block.timestamp - cacheTimestamp[node] < CACHE_DURATION) {
            return resolvedCache[node];
        }

        // Get resolver from registry
        address resolverAddr = registry.resolver(node);
        if (resolverAddr == address(0)) revert NameNotFound();

        // Resolve address
        addr = IBasenameResolver(resolverAddr).addr(node);
        if (addr == address(0)) revert ResolutionFailed();

        // Update cache
        resolvedCache[node] = addr;
        cacheTimestamp[node] = block.timestamp;

        emit NameResolved(name, addr);
        emit CacheUpdated(node, addr);
    }

    /// @notice Resolve without caching (view only, may be stale)
    function resolveView(string memory name) external view returns (address) {
        bytes32 node = namehash(name);

        // Return cached if valid
        if (cacheTimestamp[node] > 0 && block.timestamp - cacheTimestamp[node] < CACHE_DURATION) {
            return resolvedCache[node];
        }

        // Try to resolve
        address resolverAddr = registry.resolver(node);
        if (resolverAddr == address(0)) return address(0);

        return IBasenameResolver(resolverAddr).addr(node);
    }

    /// @notice Check if a name is registered
    function isRegistered(string memory name) external view returns (bool) {
        bytes32 node = namehash(name);
        address resolverAddr = registry.resolver(node);
        if (resolverAddr == address(0)) return false;

        address addr = IBasenameResolver(resolverAddr).addr(node);
        return addr != address(0);
    }

    /// @notice Get the owner of a .base name
    function getNameOwner(string memory name) external view returns (address) {
        bytes32 node = namehash(name);
        return registry.owner(node);
    }

    /// @notice Batch resolve multiple names
    function batchResolve(string[] memory names) external returns (address[] memory addresses) {
        addresses = new address[](names.length);
        for (uint256 i = 0; i < names.length; i++) {
            addresses[i] = resolve(names[i]);
        }
    }

    /// @notice Clear cache for a name (anyone can call to refresh)
    function clearCache(string memory name) external {
        bytes32 node = namehash(name);
        delete resolvedCache[node];
        delete cacheTimestamp[node];
    }

    /// @notice Resolve name or return address if already an address
    /// @dev Useful for functions that accept either name or address
    function resolveOrPassthrough(string memory nameOrAddress) external returns (address) {
        // Check if it looks like an address (starts with 0x and is 42 chars)
        bytes memory b = bytes(nameOrAddress);
        if (b.length == 42 && b[0] == "0" && b[1] == "x") {
            return parseAddress(nameOrAddress);
        }

        // Otherwise treat as a name
        return resolve(nameOrAddress);
    }

    /// @notice Parse address string to address type
    function parseAddress(string memory str) internal pure returns (address) {
        bytes memory b = bytes(str);
        require(b.length == 42, "Invalid address length");

        uint160 result = 0;
        for (uint256 i = 2; i < 42; i++) {
            result *= 16;
            uint8 digit = uint8(b[i]);
            if (digit >= 48 && digit <= 57) {
                result += digit - 48;
            } else if (digit >= 65 && digit <= 70) {
                result += digit - 55;
            } else if (digit >= 97 && digit <= 102) {
                result += digit - 87;
            }
        }
        return address(result);
    }
}
