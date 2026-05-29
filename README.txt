Decentralised Credential Verification Platform

Overview

The Decentralised Credential Verification Platform is a blockchain-based application designed to issue, manage, and verify sports and fitness credentials using Ethereum smart contracts.

The platform addresses common issues associated with traditional paper and centralised digital certificates, including:
- Lost or damaged certificates
- Credential fraud and forgery
- Slow manual verification processes
- Dependence on a central authority
- Limited control over credential sharing

By using blockchain technology, credential ownership, access permissions, and verification outcomes are managed through smart contracts, providing a transparent and tamper-resistant verification process.



Project Objectives

The primary objective of this project is to create a secure and decentralised system that allows:
- Organisations to issue digital credentials
- Credential holders to control access to their credentials
- Employers and event organisers to verify credentials
- Reward sponsors to validate achievements for rewards and incentives

The platform demonstrates how blockchain technology can be applied to real-world credential verification scenarios.



Why Blockchain?

Traditional credential systems generally rely on a central organisation to store and verify records.

This creates several challenges:
- Single point of failure
- Manual verification delays
- Trust dependency on one organisation
- Difficult interoperability between institutions

Blockchain is suitable because:
- Multiple stakeholders interact with the system
- Stakeholders do not fully trust one another
- Verification records must be tamper resistant
- Credential status must remain transparent and auditable
- Smart contracts can automate verification processes



Stakeholders

The system contains five stakeholder roles.

1. Administrator
The Administrator manages the platform and controls role assignment.

Responsibilities:
- Assign Issuer role
- Assign Verifier role
- Assign Reward Sponsor role
- Remove stakeholder permissions
- Recover credential ownership when required



2. Issuer
Issuers are trusted organisations responsible for creating credentials.

Examples:
- Universities
- Sports organisations
- Fitness certification providers

Responsibilities:
- Issue credentials
- Revoke credentials
- Manage credential lifecycle



3. Holder
The Holder is the owner of the credential.

Examples:
- Athletes
- Trainers
- Students

Responsibilities:
- Receive credentials
- Grant verification access
- Revoke verification access
- Control credential visibility



4. Verifier
Verifiers validate credentials.

Examples:
- Employers
- Event organisers
- Educational institutions

Responsibilities:
- Request verification
- Validate credentials
- Review verification results



5. Reward Sponsor
Reward Sponsors provide benefits to users who hold verified credentials.

Examples:
- Sporting brands
- Fitness companies
- Membership organisations

Responsibilities:
- Verify credential eligibility
- Confirm reward qualification



Smart Contract Architecture

The system is built using three Solidity smart contracts.



AccessControlContract

Responsible for role management and access permissions.

Functions include:
- Assign Issuer
- Remove Issuer
- Assign Verifier
- Remove Verifier
- Assign Sponsor
- Remove Sponsor
- Check Access Permissions

Purpose:
Ensures that only authorised users can perform specific actions.



CredentialRegistryContract

Responsible for storing credential information.

Functions include:
- Issue Credential
- Revoke Credential
- Transfer Credential Ownership
- Store Credential Hash
- Store Metadata Reference

Purpose:
Acts as the central credential repository.



VerificationContract

Responsible for validating credentials.

Functions include:
- Verify Credential
- Verify Reward Eligibility
- Log Verification Results

Purpose:
Provides automated verification and reward validation functionality.



System Features

The platform provides the following functionality.

Wallet Integration
- MetaMask connection
- Ethereum account authentication
- Network validation

Role Management
- Assign stakeholder roles
- Remove stakeholder roles
- Check role permissions

Credential Issuance
- Create credentials
- Define metadata
- Set expiry dates

Credential Revocation
- Revoke credentials
- Prevent invalid credentials from being verified

Access Control
- Grant verifier access
- Revoke verifier access
- Check permission status

Verification
- Verify credential validity
- Confirm credential ownership
- Confirm access authorisation

Reward Validation
- Verify eligibility for rewards
- Validate sponsor access

Credential Lookup
- View credential information
- Check credential existence
- Check credential validity
- View issuer information
- View holder information

Recovery Management
- Transfer credential ownership
- Support recovery scenarios



User Guide
Step 1: Connect MetaMask
1. Install MetaMask.
2. Open the application.
3. Click "Connect MetaMask".
4. Approve the connection request.

Once connected, your wallet address and network information will appear.



Step 2: Load Smart Contracts
Enter the deployed addresses for:
- AccessControlContract
- CredentialRegistryContract
- VerificationContract

Click:
Load Contracts

The system will connect the frontend to the deployed smart contracts.



Step 3: Assign Roles
Using the Administrator account:
1. Enter an Issuer wallet address.
2. Click Assign Issuer.

Repeat for:
- Verifier
- Reward Sponsor

The selected accounts will now have access to their respective functions.



Step 4: Issue a Credential
Using the Issuer account:
1. Enter Holder Address.
2. Enter Credential Hash.
3. Enter Metadata URI.
4. Enter Expiry Date.
5. Click Issue Credential.

The credential is recorded on the blockchain.



Step 5: Grant Access
Using the Holder account:
1. Enter Credential ID.
2. Enter Verifier Address.
3. Click Grant Access.

The verifier can now validate the credential.



Step 6: Verify Credential
Using the Verifier account:
1. Enter Credential ID.
2. Click Verify Credential.

The system checks:
- Credential existence
- Credential validity
- Access permissions
- Verification authority

A verification result is returned.



Step 7: Verify Reward Eligibility
Using the Reward Sponsor account:
1. Enter Credential ID.
2. Click Verify for Reward.

The platform determines whether the holder is eligible for sponsor rewards.



Step 8: Lookup Credential Information
The Lookup section allows users to:
- View credential details
- Check validity
- Confirm existence
- View issuer
- View holder

This functionality provides transparency and auditing capability.



Example Workflow

The following example demonstrates the complete system.

1. Administrator assigns Issuer role to Queensland Athletics Federation.
2. Issuer creates a coaching certification credential.
3. Holder receives credential ownership.
4. Holder grants verification access to an employer.
5. Employer verifies credential authenticity.
6. Reward sponsor confirms reward eligibility.
7. Credential status is recorded on-chain.



Technology Stack

Blockchain
- Ethereum
- Solidity

Development Environment
- Remix IDE

Wallet Integration
- MetaMask

Frontend
- HTML
- CSS
- JavaScript
- Ethers.js

Network
- Ethereum Sepolia Testnet

Future Storage
- IPFS (planned)



Future Improvements

Potential future enhancements include:
- IPFS integration
- QR code credential sharing
- Mobile application support
- Multi-chain deployment
- Enhanced privacy controls
- W3C Verifiable Credential compliance
- Automated reward distribution
- Improved user onboarding



Repository Structure

CredentialVerification.sol / index.html / BPMN diagrams / README.md 



Authors

Group 110

Hussain Mohammadi – 11435925

Sin Yu Fung – 11828889

Queensland University of Technology (QUT)

IFB452 Blockchain Technology
