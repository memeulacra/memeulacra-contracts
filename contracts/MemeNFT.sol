// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.19;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract MemeNFT is Initializable, ERC721BurnableUpgradeable, OwnableUpgradeable, AccessControlUpgradeable {
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 public nextTokenId;
    mapping(uint256 => string) private _imageURLs;
    mapping(uint256 => bytes32) private _imageHashes;

    function initialize(string memory name, string memory symbol) public initializer {
        __ERC721_init(name, symbol);
        __Ownable_init(msg.sender);
        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function mint(address to, string memory imageURL, bytes32 imageHash) external {
        require(hasRole(MINTER_ROLE, msg.sender) || hasRole(UPGRADER_ROLE, msg.sender), "Caller is not a minter");
        uint256 tokenId = nextTokenId;
        _safeMint(to, tokenId);
        _imageURLs[tokenId] = imageURL;
        _imageHashes[tokenId] = imageHash;
        nextTokenId++;
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return bytes(_imageURLs[tokenId]).length != 0;
    }

    function getImageURL(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: Query for nonexistent token");
        return _imageURLs[tokenId];
    }

    function getImageHash(uint256 tokenId) external view returns (bytes32) {
        require(_exists(tokenId), "ERC721Metadata: Query for nonexistent token");
        return _imageHashes[tokenId];
    }

    // Override supportsInterface function
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Upgradeable, AccessControlUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}