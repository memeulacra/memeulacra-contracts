// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.19;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract MsimToken is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, OwnableUpgradeable, AccessControlUpgradeable {

    mapping(address => bool) public hasClaimed;
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    uint256 public paymentAmount;
    address public rewardSender;
    uint256 public maxRewardAmount;

    event PaymentReceived(address indexed sender, uint256 amount, string identifier);
    event MinPaymentAmountUpdated(uint256 newMinAmount);
    event RewardsSent(uint256 count, uint256 total, bool exceededMax);

    function initialize(string memory name, string memory symbol) public initializer {
        __ERC20_init(name, symbol);
        __ERC20Burnable_init();
        __Ownable_init(msg.sender);
        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
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
