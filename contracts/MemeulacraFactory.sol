// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.19;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract MemeToken is ERC20Burnable, Ownable {

    string public memeURL;

    constructor(
        string memory name,
        string memory symbol,
        string memory urlToMeme,
        address ownerAddress,
        address[] memory contributors,
        uint256[] memory contributorProportions
    ) ERC20(name, symbol) Ownable(msg.sender) {
        uint256 supply = 100000040  * 10 ** decimals(); // 100 million + 40
        require(supply >= (1000  * 10 ** decimals()), "MemeToken: initial supply cannot be < 1000.0");
        uint256 proportionSum = 0;
        for (uint256 i = 0; i < contributorProportions.length; i++) {
            proportionSum += contributorProportions[i];
        }
        require(proportionSum <= 100, "MemeToken: proportions must sum to 100");
        _mint(msg.sender, supply);
        uint256 callerProportion = supply / 10;        
        uint256 ownerProportion = supply / 70;
        uint256 remainingSupply = supply - callerProportion - ownerProportion;
        for (uint256 i = 0; i < contributors.length; i++) {
            uint256 contributorProportion = (remainingSupply * contributorProportions[i]) / 100;
            _transfer(msg.sender, contributors[i], contributorProportion);
        }
        uint256 ownerBalance = balanceOf(msg.sender) - callerProportion;
        memeURL = urlToMeme;
        _transfer(msg.sender, ownerAddress, ownerBalance);        
        _transferOwnership(ownerAddress);
    }

}

contract MemeulacraFactory is Initializable, OwnableUpgradeable, AccessControlUpgradeable {
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    event NewMemeTokenFactoryEvent(address indexed owner, address indexed newTokenAddress);

    function initialize() public initializer {
        __Ownable_init(msg.sender);
        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function deployMemeToken(
        string memory name,
        string memory symbol,
        string memory urlToMeme,
        address ownerAddress,
        address[] memory contributors,
        uint256[] memory contributorProportions
    ) external returns (address) {
        require(hasRole(MINTER_ROLE, msg.sender) || hasRole(UPGRADER_ROLE, msg.sender), "Caller is not a minter");
        MemeToken newToken = new MemeToken(name, symbol, urlToMeme, ownerAddress, contributors, contributorProportions);
        address tokenAddress = address(newToken);
        emit NewMemeTokenFactoryEvent(msg.sender, tokenAddress);
        return tokenAddress;
    }
}