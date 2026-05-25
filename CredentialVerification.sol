// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
    IFB452 Assessment 3B - Decentralised Credential Verification Platform
    Group 110

    This file contains three interacting smart contracts:
    1. AccessControlContract
    2. CredentialRegistryContract
    3. VerificationContract

    The design follows the project proposal:
    - Issuers create credentials for holders.
    - Holders control which verifiers can access their credentials.
    - Verifiers and reward sponsors verify credential validity.
    - Admin can support key recovery by transferring credential ownership after off-chain checks.
*/

contract AccessControlContract {
    address public admin;

    mapping(address => bool) private issuers;
    mapping(address => bool) private verifiers;
    mapping(address => bool) private sponsors;

    // credentialId => verifier/sponsor address => access allowed
    mapping(uint256 => mapping(address => bool)) private credentialAccess;

    event IssuerAssigned(address indexed issuer);
    event IssuerRemoved(address indexed issuer);
    event VerifierAssigned(address indexed verifier);
    event VerifierRemoved(address indexed verifier);
    event SponsorAssigned(address indexed sponsor);
    event SponsorRemoved(address indexed sponsor);
    event CredentialAccessGranted(uint256 indexed credentialId, address indexed authorisedParty);
    event CredentialAccessRevoked(uint256 indexed credentialId, address indexed authorisedParty);

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    function assignIssuer(address issuer) public onlyAdmin {
        require(issuer != address(0), "Invalid issuer address");
        issuers[issuer] = true;
        emit IssuerAssigned(issuer);
    }

    function removeIssuer(address issuer) public onlyAdmin {
        issuers[issuer] = false;
        emit IssuerRemoved(issuer);
    }

    function assignVerifier(address verifier) public onlyAdmin {
        require(verifier != address(0), "Invalid verifier address");
        verifiers[verifier] = true;
        emit VerifierAssigned(verifier);
    }

    function removeVerifier(address verifier) public onlyAdmin {
        verifiers[verifier] = false;
        emit VerifierRemoved(verifier);
    }

    function assignSponsor(address sponsor) public onlyAdmin {
        require(sponsor != address(0), "Invalid sponsor address");
        sponsors[sponsor] = true;
        emit SponsorAssigned(sponsor);
    }

    function removeSponsor(address sponsor) public onlyAdmin {
        sponsors[sponsor] = false;
        emit SponsorRemoved(sponsor);
    }

    function isAdmin(address user) public view returns (bool) {
        return user == admin;
    }

    function isIssuer(address user) public view returns (bool) {
        return issuers[user];
    }

    function isVerifier(address user) public view returns (bool) {
        return verifiers[user];
    }

    function isSponsor(address user) public view returns (bool) {
        return sponsors[user];
    }

    function grantCredentialAccess(uint256 credentialId, address authorisedParty) public {
        require(authorisedParty != address(0), "Invalid authorised party address");
        credentialAccess[credentialId][authorisedParty] = true;
        emit CredentialAccessGranted(credentialId, authorisedParty);
    }

    function revokeCredentialAccess(uint256 credentialId, address authorisedParty) public {
        credentialAccess[credentialId][authorisedParty] = false;
        emit CredentialAccessRevoked(credentialId, authorisedParty);
    }

    function hasCredentialAccess(uint256 credentialId, address authorisedParty) public view returns (bool) {
        return credentialAccess[credentialId][authorisedParty];
    }
}

contract CredentialRegistryContract {
    AccessControlContract public accessControl;
    address public admin;
    uint256 public nextCredentialId;

    struct Credential {
        uint256 id;
        address issuer;
        address holder;
        string credentialHash;
        string metadataURI;
        uint256 issuedAt;
        uint256 expiryDate;
        bool revoked;
        bool exists;
    }

    mapping(uint256 => Credential) private credentials;

    event CredentialIssued(
        uint256 indexed credentialId,
        address indexed issuer,
        address indexed holder,
        string credentialHash,
        string metadataURI,
        uint256 expiryDate
    );

    event CredentialRevoked(uint256 indexed credentialId, address indexed issuer);
    event CredentialAccessGranted(uint256 indexed credentialId, address indexed holder, address indexed authorisedParty);
    event CredentialAccessRevoked(uint256 indexed credentialId, address indexed holder, address indexed authorisedParty);
    event CredentialHolderRecovered(uint256 indexed credentialId, address indexed oldHolder, address indexed newHolder);

    constructor(address accessControlAddress) {
        require(accessControlAddress != address(0), "Invalid AccessControl address");
        accessControl = AccessControlContract(accessControlAddress);
        admin = msg.sender;
        nextCredentialId = 1;
    }

    modifier onlyIssuer() {
        require(accessControl.isIssuer(msg.sender), "Only approved issuer can perform this action");
        _;
    }

    modifier onlyCredentialHolder(uint256 credentialId) {
        require(credentials[credentialId].exists, "Credential does not exist");
        require(credentials[credentialId].holder == msg.sender, "Only credential holder can perform this action");
        _;
    }

    modifier onlyAdmin() {
        require(accessControl.isAdmin(msg.sender), "Only admin can perform this action");
        _;
    }

    function issueCredential(
        address holder,
        string memory credentialHash,
        string memory metadataURI,
        uint256 expiryDate
    ) public onlyIssuer returns (uint256) {
        require(holder != address(0), "Invalid holder address");
        require(bytes(credentialHash).length > 0, "Credential hash is required");
        require(expiryDate == 0 || expiryDate > block.timestamp, "Expiry date must be in the future or zero");

        uint256 credentialId = nextCredentialId;

        credentials[credentialId] = Credential({
            id: credentialId,
            issuer: msg.sender,
            holder: holder,
            credentialHash: credentialHash,
            metadataURI: metadataURI,
            issuedAt: block.timestamp,
            expiryDate: expiryDate,
            revoked: false,
            exists: true
        });

        nextCredentialId++;

        emit CredentialIssued(
            credentialId,
            msg.sender,
            holder,
            credentialHash,
            metadataURI,
            expiryDate
        );

        return credentialId;
    }

    function revokeCredential(uint256 credentialId) public onlyIssuer {
        require(credentials[credentialId].exists, "Credential does not exist");
        require(credentials[credentialId].issuer == msg.sender, "Only original issuer can revoke this credential");
        require(!credentials[credentialId].revoked, "Credential is already revoked");

        credentials[credentialId].revoked = true;
        emit CredentialRevoked(credentialId, msg.sender);
    }

    function grantAccess(uint256 credentialId, address authorisedParty) public onlyCredentialHolder(credentialId) {
        require(
            accessControl.isVerifier(authorisedParty) || accessControl.isSponsor(authorisedParty),
            "Authorised party must be verifier or sponsor"
        );

        accessControl.grantCredentialAccess(credentialId, authorisedParty);
        emit CredentialAccessGranted(credentialId, msg.sender, authorisedParty);
    }

    function revokeAccess(uint256 credentialId, address authorisedParty) public onlyCredentialHolder(credentialId) {
        accessControl.revokeCredentialAccess(credentialId, authorisedParty);
        emit CredentialAccessRevoked(credentialId, msg.sender, authorisedParty);
    }

    function transferCredentialHolder(uint256 credentialId, address newHolder) public onlyAdmin {
        require(credentials[credentialId].exists, "Credential does not exist");
        require(newHolder != address(0), "Invalid new holder address");

        address oldHolder = credentials[credentialId].holder;
        credentials[credentialId].holder = newHolder;

        emit CredentialHolderRecovered(credentialId, oldHolder, newHolder);
    }

    function credentialExists(uint256 credentialId) public view returns (bool) {
        return credentials[credentialId].exists;
    }

    function getCredential(uint256 credentialId)
        public
        view
        returns (
            uint256 id,
            address issuer,
            address holder,
            string memory credentialHash,
            string memory metadataURI,
            uint256 issuedAt,
            uint256 expiryDate,
            bool revoked,
            bool exists
        )
    {
        Credential memory credential = credentials[credentialId];
        return (
            credential.id,
            credential.issuer,
            credential.holder,
            credential.credentialHash,
            credential.metadataURI,
            credential.issuedAt,
            credential.expiryDate,
            credential.revoked,
            credential.exists
        );
    }

    function isCredentialValid(uint256 credentialId) public view returns (bool) {
        if (!credentials[credentialId].exists) {
            return false;
        }

        if (credentials[credentialId].revoked) {
            return false;
        }

        if (credentials[credentialId].expiryDate != 0 && block.timestamp > credentials[credentialId].expiryDate) {
            return false;
        }

        return true;
    }

    function getCredentialHolder(uint256 credentialId) public view returns (address) {
        require(credentials[credentialId].exists, "Credential does not exist");
        return credentials[credentialId].holder;
    }

    function getCredentialIssuer(uint256 credentialId) public view returns (address) {
        require(credentials[credentialId].exists, "Credential does not exist");
        return credentials[credentialId].issuer;
    }
}

contract VerificationContract {
    AccessControlContract public accessControl;
    CredentialRegistryContract public credentialRegistry;

    enum VerificationStatus {
        Valid,
        InvalidCredential,
        AccessDenied,
        NotAuthorisedVerifier,
        NotAuthorisedSponsor
    }

    event CredentialVerified(
        uint256 indexed credentialId,
        address indexed verifier,
        bool result,
        VerificationStatus status
    );

    event RewardEligibilityChecked(
        uint256 indexed credentialId,
        address indexed sponsor,
        bool result,
        VerificationStatus status
    );

    constructor(address accessControlAddress, address credentialRegistryAddress) {
        require(accessControlAddress != address(0), "Invalid AccessControl address");
        require(credentialRegistryAddress != address(0), "Invalid CredentialRegistry address");

        accessControl = AccessControlContract(accessControlAddress);
        credentialRegistry = CredentialRegistryContract(credentialRegistryAddress);
    }

    function verifyCredential(uint256 credentialId) public returns (bool) {
        if (!accessControl.isVerifier(msg.sender)) {
            emit CredentialVerified(credentialId, msg.sender, false, VerificationStatus.NotAuthorisedVerifier);
            return false;
        }

        if (!accessControl.hasCredentialAccess(credentialId, msg.sender)) {
            emit CredentialVerified(credentialId, msg.sender, false, VerificationStatus.AccessDenied);
            return false;
        }

        bool valid = credentialRegistry.isCredentialValid(credentialId);

        if (!valid) {
            emit CredentialVerified(credentialId, msg.sender, false, VerificationStatus.InvalidCredential);
            return false;
        }

        emit CredentialVerified(credentialId, msg.sender, true, VerificationStatus.Valid);
        return true;
    }

    function verifyCredentialView(uint256 credentialId, address verifier) public view returns (bool) {
        if (!accessControl.isVerifier(verifier)) {
            return false;
        }

        if (!accessControl.hasCredentialAccess(credentialId, verifier)) {
            return false;
        }

        return credentialRegistry.isCredentialValid(credentialId);
    }

    function verifyCredentialForReward(uint256 credentialId) public returns (bool) {
        if (!accessControl.isSponsor(msg.sender)) {
            emit RewardEligibilityChecked(credentialId, msg.sender, false, VerificationStatus.NotAuthorisedSponsor);
            return false;
        }

        if (!accessControl.hasCredentialAccess(credentialId, msg.sender)) {
            emit RewardEligibilityChecked(credentialId, msg.sender, false, VerificationStatus.AccessDenied);
            return false;
        }

        bool valid = credentialRegistry.isCredentialValid(credentialId);

        if (!valid) {
            emit RewardEligibilityChecked(credentialId, msg.sender, false, VerificationStatus.InvalidCredential);
            return false;
        }

        emit RewardEligibilityChecked(credentialId, msg.sender, true, VerificationStatus.Valid);
        return true;
    }

    function verifyCredentialForRewardView(uint256 credentialId, address sponsor) public view returns (bool) {
        if (!accessControl.isSponsor(sponsor)) {
            return false;
        }

        if (!accessControl.hasCredentialAccess(credentialId, sponsor)) {
            return false;
        }

        return credentialRegistry.isCredentialValid(credentialId);
    }
}
