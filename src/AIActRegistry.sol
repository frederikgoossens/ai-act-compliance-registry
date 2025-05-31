// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title AIActRegistry
 * @dev Minimal viable registry for AI systems under EU AI Act
 * @author Your Name - Building in Public
 *
 * LEARNING NOTES:
 * - Start simple: just register AI systems with basic info
 * - Add complexity as you learn (oracles, governance, etc)
 * - This contract costs ~$50-200 to deploy on Ethereum mainnet
 * - Test on Sepolia testnet first (free)
 */

contract AIActRegistry {
    // LESSON 1: State Variables (stored on blockchain forever)
    address public owner;
    uint256 public registrationFee = 0.01 ether; // ~$25 at current prices
    uint256 public totalSystems;

    // LESSON 2: Enums (like dropdowns in forms)
    enum RiskLevel { MINIMAL, LIMITED, HIGH, UNACCEPTABLE }
    enum ComplianceStatus { PENDING, COMPLIANT, NON_COMPLIANT, EXPIRED }

    // LESSON 3: Structs (like objects in JavaScript)
    struct AISystem {
        string name;
        string purpose;
        address provider;
        RiskLevel risk;
        ComplianceStatus status;
        uint256 registeredAt;
        uint256 lastUpdated;
        string ipfsHash; // Link to detailed docs on IPFS
        bool verified;
    }

    // LESSON 4: Mappings (like dictionaries/hashmaps)
    mapping(uint256 => AISystem) public systems;
    mapping(address => uint256[]) public providerSystems;

    // LESSON 5: Events (for frontend to listen to)
    event SystemRegistered(
        uint256 indexed systemId,
        address indexed provider,
        string name,
        RiskLevel risk
    );

    event ComplianceUpdated(
        uint256 indexed systemId,
        ComplianceStatus oldStatus,
        ComplianceStatus newStatus
    );

    // LESSON 6: Modifiers (reusable security checks)
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier onlyProvider(uint256 _systemId) {
        require(systems[_systemId].provider == msg.sender, "Not system provider");
        _;
    }

    // LESSON 7: Constructor (runs once when deployed)
    constructor() {
        owner = msg.sender;
    }

    // LESSON 8: Main Functions

    /**
     * @dev Register a new AI system
     * @param _name Name of the AI system
     * @param _purpose What the AI system does
     * @param _risk Risk level according to AI Act
     * @param _ipfsHash IPFS hash containing detailed documentation
     */
    function registerSystem(
        string memory _name,
        string memory _purpose,
        RiskLevel _risk,
        string memory _ipfsHash
    ) external payable returns (uint256) {
        // LESSON 9: Require statements (validations)
        require(msg.value >= registrationFee, "Insufficient fee");
        require(bytes(_name).length > 0, "Name required");
        require(_risk != RiskLevel.UNACCEPTABLE, "Cannot register unacceptable risk AI");

        totalSystems++;
        uint256 systemId = totalSystems;

        // LESSON 10: Storage writes (expensive! ~20k gas each)
        systems[systemId] = AISystem({
            name: _name,
            purpose: _purpose,
            provider: msg.sender,
            risk: _risk,
            status: ComplianceStatus.PENDING,
            registeredAt: block.timestamp,
            lastUpdated: block.timestamp,
            ipfsHash: _ipfsHash,
            verified: false
        });

        providerSystems[msg.sender].push(systemId);

        // LESSON 11: Emit events for frontend
        emit SystemRegistered(systemId, msg.sender, _name, _risk);

        return systemId;
    }

    /**
     * @dev Update compliance status (only provider can update their own system)
     */
    function updateCompliance(
        uint256 _systemId,
        ComplianceStatus _newStatus,
        string memory _newIpfsHash
    ) external onlyProvider(_systemId) {
        AISystem storage system = systems[_systemId];
        ComplianceStatus oldStatus = system.status;

        system.status = _newStatus;
        system.lastUpdated = block.timestamp;
        system.ipfsHash = _newIpfsHash;

        emit ComplianceUpdated(_systemId, oldStatus, _newStatus);
    }

    /**
     * @dev Get all systems for a provider
     */
    function getProviderSystems(address _provider)
        external
        view
        returns (uint256[] memory)
    {
        return providerSystems[_provider];
    }

    /**
     * @dev Withdraw fees (only owner) - you need to make money!
     */
    function withdrawFees() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No fees to withdraw");

        (bool sent, ) = owner.call{value: balance}("");
        require(sent, "Failed to send Ether");
    }

    /**
     * @dev Update registration fee (only owner)
     */
    function updateFee(uint256 _newFee) external onlyOwner {
        registrationFee = _newFee;
    }
}

/**
 * NEXT STEPS FOR YOU:
 *
 * 1. Copy this into Remix IDE (https://remix.ethereum.org)
 * 2. Compile with Solidity 0.8.19
 * 3. Deploy to Sepolia testnet
 * 4. Register your first AI system!
 *
 * WHAT TO ADD NEXT:
 * - Verification by auditors (multi-sig)
 * - Time-based expiry (annual renewal)
 * - Risk assessment questionnaire on-chain
 * - Integration with ENS for readable names
 * - Governance token for decentralized verification
 *
 * LEARNING RESOURCES:
 * - https://solidity-by-example.org/
 * - https://speedrunethereum.com/
 * - Watch Austin Griffith's YouTube
 */
