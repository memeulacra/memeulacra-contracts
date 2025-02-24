// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract MsimToken is ERC20, ERC20Burnable, Ownable {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) Ownable(msg.sender) {
        _mint(msg.sender, 100 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
