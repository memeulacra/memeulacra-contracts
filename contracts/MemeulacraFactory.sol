// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.19;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./MemeToken.sol";


contract MemeulacraFactory is Initializable, OwnableUpgradeable, AccessControlUpgradeable {
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    event NewMemeTokenFactoryEvent(address indexed owner, address indexed nftAddress);

    function initialize() public initializer {
        __Ownable_init(msg.sender);
        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    function deployMemeToken(
        string memory name,
        string memory symbol,
        address ownerAddress,
        address[] memory contributors,
        uint256[] memory contributorProportions
    ) external {
        MemeToken newToken = new MemeToken(name, symbol, ownerAddress, contributors, contributorProportions);
        emit NewMemeTokenFactoryEvent(msg.sender, address(newToken));
    }
}