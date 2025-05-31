// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// src/AIActRegistry.sol

/**
 * @title AIActRegistry
 * @dev Secure registry for AI systems under EU AI Act
 * @author Your Name - Building in Public
 *
 * SECURITY AUDIT COMPLETED ✅
 * - Fixed system existence validation
 * - Added overpayment refund protection
 * - Added maximum fee limits
 * - Enhanced input validation
 */

contract AIActRegistry {
    // State Variables
    address public owner;
    uint256 public registrationFee = 0.01 ether;
    uint256 public totalSystems;

    // Security: Maximum fee limit protection
    uint256 public constant MAX_REGISTRATION_FEE = 1 ether;

    // Enums
    enum RiskLevel { MINIMAL, LIMITED, HIGH, UNACCEPTABLE }
    enum ComplianceStatus { PENDING, COMPLIANT, NON_COMPLIANT, EXPIRED }

    // Structs
    struct AISystem {
        string name;
        string purpose;
        address provider;
        RiskLevel risk;
        ComplianceStatus status;
        uint256 registeredAt;
        uint256 lastUpdated;
        string ipfsHash;
        bool verified;
    }

    // Mappings
    mapping(uint256 => AISystem) public systems;
    mapping(address => uint256[]) public providerSystems;

    // Events
    event SystemRegistered(
        uint256 indexed systemId,
        address indexed provider,
        string name,
        RiskLevel indexed risk
    );

    event ComplianceUpdated(
        uint256 indexed systemId,
        ComplianceStatus oldStatus,
        ComplianceStatus newStatus
    );

    // Security: New event for refunds
    event RefundIssued(
        address indexed recipient,
        uint256 amount
    );

    event FeeUpdated(
        uint256 oldFee,
        uint256 newFee
    );

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    // Security: Fixed system existence check
    modifier onlyProvider(uint256 _systemId) {
        require(_systemId > 0 && _systemId <= totalSystems, "System does not exist");
        require(systems[_systemId].provider == msg.sender, "Not system provider");
        _;
    }

    // Constructor
    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Register a new AI system with enhanced security
     */
    function registerSystem(
        string memory _name,
        string memory _purpose,
        RiskLevel _risk,
        string memory _ipfsHash
    ) external payable returns (uint256) {
        // Enhanced input validation
        require(msg.value >= registrationFee, "Insufficient fee");
        require(bytes(_name).length > 0 && bytes(_name).length <= 100, "Invalid name length");
        require(bytes(_purpose).length > 0 && bytes(_purpose).length <= 500, "Invalid purpose length");
        require(bytes(_ipfsHash).length > 0 && bytes(_ipfsHash).length <= 100, "Invalid IPFS hash length");
        require(_risk != RiskLevel.UNACCEPTABLE, "Cannot register unacceptable risk AI");

        totalSystems++;
        uint256 systemId = totalSystems;

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

        emit SystemRegistered(systemId, msg.sender, _name, _risk);

        // SECURITY FIX: Overpayment refund protection
        if (msg.value > registrationFee) {
            uint256 refundAmount = msg.value - registrationFee;
            (bool refundSent, ) = msg.sender.call{value: refundAmount}("");

            if (refundSent) {
                emit RefundIssued(msg.sender, refundAmount);
            } else {
                // If refund fails, revert the entire transaction
                revert("Refund failed");
            }
        }

        return systemId;
    }

    /**
     * @dev Update compliance status with validation
     */
    function updateCompliance(
        uint256 _systemId,
        ComplianceStatus _newStatus,
        string memory _newIpfsHash
    ) external onlyProvider(_systemId) {
        require(bytes(_newIpfsHash).length > 0 && bytes(_newIpfsHash).length <= 100, "Invalid IPFS hash length");

        AISystem storage system = systems[_systemId];
        ComplianceStatus oldStatus = system.status;

        system.status = _newStatus;
        system.lastUpdated = block.timestamp;
        system.ipfsHash = _newIpfsHash;

        emit ComplianceUpdated(_systemId, oldStatus, _newStatus);
    }

    /**
     * @dev Get specific system details (safe getter)
     */
    function getSystem(uint256 _systemId) external view returns (AISystem memory) {
        require(_systemId > 0 && _systemId <= totalSystems, "System does not exist");
        return systems[_systemId];
    }

    /**
     * @dev Get all systems for a provider
     */
    function getProviderSystems(address _provider) external view returns (uint256[] memory) {
        return providerSystems[_provider];
    }

    /**
     * @dev Withdraw fees (only owner)
     */
    function withdrawFees() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No fees to withdraw");

        (bool sent, ) = owner.call{value: balance}("");
        require(sent, "Failed to send Ether");
    }

    /**
     * @dev Update registration fee with maximum limit protection
     */
    function updateFee(uint256 _newFee) external onlyOwner {
        require(_newFee <= MAX_REGISTRATION_FEE, "Fee exceeds maximum limit");

        uint256 oldFee = registrationFee;
        registrationFee = _newFee;

        emit FeeUpdated(oldFee, _newFee);
    }

    /**
     * @dev Transfer ownership (added for security)
     */
    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Invalid new owner");

        address oldOwner = owner;
        owner = _newOwner;

        emit OwnershipTransferred(oldOwner, _newOwner);
    }

    /**
     * @dev Get contract info (useful for frontends)
     */
    function getContractInfo() external view returns (
        address contractOwner,
        uint256 currentFee,
        uint256 systemCount,
        uint256 contractBalance
    ) {
        return (owner, registrationFee, totalSystems, address(this).balance);
    }
}

