// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// @notice Using NatSpec standard for comments
/// @title An ERC20 contract named TestToken
/// @author Jether Rodrigues - jetherrodrigues@gmail.com
/// @notice Serves as a fungible token
/// @dev Inherits the OpenZepplin ERC20, ERC20Burnable, ERC20Permit, Ownable and ReentrancyGuard
contract TestToken is ERC20, ERC20Burnable, Ownable, ERC20Permit, ReentrancyGuard {
    /// @dev Constant variables
    string private constant MINTING_ERROR_MESSAGE = "Minting amount cannot be zero";
    string private constant WITHDRAW_ERROR_MESSAGE = "Insufficient contract balance";
    uint256 public constant TOKEN_PRICE = 0.02 ether;

    /// @dev Errors to use on transaction revert
    error MintingError(string message);
    error WithdrawError(string message);

    /// @dev Events to emit onchain
    event TokensMinted(address indexed to, uint256 amount);
    event Withdrawn(address indexed to, uint256 amount);

    /// @dev Provide a initial supply of TEST token
    constructor(uint256 initialSupply) 
        ERC20("Test", "TEST") 
        ERC20Permit("TestToken")
        Ownable(msg.sender)
    {
        _mint(msg.sender, initialSupply * 10 ** decimals());

        emit TokensMinted(msg.sender, initialSupply * 10**decimals());
    }

    /// @dev Mint token for `to` with quantity `amount`
    function mint(address to, uint256 amount) external onlyOwner {
        if (amount == 0) {
            revert MintingError(MINTING_ERROR_MESSAGE);
        }

        _mint(to, amount * 10 ** decimals());

        emit TokensMinted(to, amount * 10 ** decimals());
    }

    /// @dev Witdraw with parameters `to` and amount `amount`
    function withdraw(address payable to, uint256 amount) external onlyOwner nonReentrant {
        if (amount > getBalance()) {
            revert WithdrawError(WITHDRAW_ERROR_MESSAGE);
        }

        to.transfer(amount);

        emit Withdrawn(to, amount);
    }

    /// @dev Witdraw without parameters
    function withdraw() external onlyOwner nonReentrant {
        uint balance = getBalance();

        payable(owner()).transfer(balance);

        emit Withdrawn(owner(), balance);
    }

    /// @dev Override transfer function with reentrancy guard
    function transfer(address recipient, uint256 amount) public override nonReentrant returns (bool) {
        return super.transfer(recipient, amount);
    }

    /// @dev Retrieve the balance of contract
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /// @dev Accepts ETH transfers
    receive() external payable {}
}
