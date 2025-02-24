// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract MsimToken is ERC20, ERC20Burnable, Ownable {

    mapping(address => bool) public hasClaimed;
    uint256 public paymentAmount;
    address public rewardSender;
    uint256 public maxRewardAmount;

    event PaymentReceived(address indexed sender, uint256 amount, string identifier);
    event MinPaymentAmountUpdated(uint256 newMinAmount);
    event RewardsSent(uint256 count, uint256 total, bool exceededMax);

    constructor(string memory name, string memory symbol) ERC20(name, symbol) Ownable(msg.sender) {
        _mint(msg.sender, 100 * 10 ** decimals());
        paymentAmount = 5 * 10 ** decimals(); // default cost
        maxRewardAmount = 1 * 10 ** decimals();
        rewardSender = msg.sender;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function contractTokenBalance() external view returns (uint256) {
        return balanceOf(address(this));
    }

    function updatePaymentAmount(uint256 _newAmount) external onlyOwner {
        paymentAmount = _newAmount;
        emit MinPaymentAmountUpdated(_newAmount);
    }

    function updateMaxRewardAmount(uint256 _newAmount) external onlyOwner {
        maxRewardAmount = _newAmount;
    }

    function removeClaim(address account) public onlyOwner {
        hasClaimed[account] = false;
    }

    // this can be configured to have gas fees covered via a paymaster
    function claimTokens() external {
        require(!hasClaimed[msg.sender], "Tokens already claimed");
        hasClaimed[msg.sender] = true;
        uint256 balance = balanceOf(address(this));
        if (balanceOf(address(this)) < 200 * 10 ** decimals()) {
            _mint(address(this), 200 * 10 ** decimals() - balance);
        }        
        _transfer(address(this), msg.sender, 200 * 10 ** decimals());
    }

    // emits PaymentReceived event for successful payment
    function receivePayment(uint256 amount, string memory identifier) external {
        require(amount >= paymentAmount, "Payment must be equal (or greater than) to the minimum amount");

        // Transfer the tokens from the sender to this contract
        _transfer(msg.sender, address(this), amount);

        // Emit an event with the payment details
        emit PaymentReceived(msg.sender, amount, identifier);
    }

    function setRewardSender(address _rewardSender) external onlyOwner {
        rewardSender = _rewardSender;
    }

    function sendRewards(address[] memory recipients, uint256[] memory amounts) external {
        require(msg.sender == rewardSender, "Only the reward sender can call this function");
        require(recipients.length == amounts.length, "Array lengths must match");
        bool exceededMax = false;
        uint256 sum = 0;
        if (balanceOf(address(this)) < (maxRewardAmount * recipients.length)) {
            _mint(address(this), maxRewardAmount * recipients.length);
        }
        for (uint256 i = 0; i < recipients.length; i++) {
            if (amounts[i] > maxRewardAmount) {
                amounts[i] = maxRewardAmount;
                exceededMax = true;
            }
            _transfer(rewardSender, recipients[i], amounts[i]);
            sum += amounts[i];
        }
        emit RewardsSent(recipients.length, sum, exceededMax);
    }

}
