// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Vault {
    // Mapping for whitelisted addresses
    mapping(address => bool) public whitelist;
    address public owner;

    // Modifier: only the contract owner can call
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        whitelist[owner] = true; // Add owner to whitelist by default
    }

    /// @notice Function to receive ETH
    receive() external payable {}

    /// @notice Deposit ERC20 tokens
    /// @param token Address of the token to deposit
    /// @param amount Amount of tokens to deposit
    function depositToken(address token, uint256 amount) external {
        require(amount > 0, "Invalid amount");
        require(IERC20(token).transferFrom(msg.sender, address(this), amount), "Deposit failed");
    }

    /// @notice Withdraw ERC20 tokens
    /// @param token Address of the token to withdraw
    /// @param recipient Address to receive the tokens
    /// @param amount Amount of tokens to withdraw
    function withdrawToken(address token, address recipient, uint256 amount) external {
        require(amount > 0, "Invalid amount");
        require(recipient != address(0), "Invalid recipient");
        require(IERC20(token).transfer(recipient, amount), "Withdraw failed");
    }

    /// @notice Deposit ETH
    function depositETH() external payable {
        require(msg.value > 0, "No ETH sent");
    }

    /// @notice Withdraw ETH
    /// @param recipient Address to receive the ETH
    /// @param amount Amount of ETH to withdraw
    function withdrawETH(address recipient, uint256 amount) external {
        require(amount > 0, "Invalid amount");
        require(recipient != address(0), "Invalid recipient");
        require(address(this).balance >= amount, "Insufficient ETH balance");
        (bool success,) = recipient.call{value: amount}("");
        require(success, "Withdraw failed");
    }

    // /// @notice Add an address to the whitelist
    // /// @param addr Address to add to the whitelist
    // function addToWhitelist(address addr) external onlyOwner {
    //     require(addr != address(0), 'Invalid address');
    //     whitelist[addr] = true;
    // }

    // /// @notice Remove an address from the whitelist
    // /// @param addr Address to remove from the whitelist
    // function removeFromWhitelist(address addr) external onlyOwner {
    //     require(addr != address(0), 'Invalid address');
    //     whitelist[addr] = false;
    // }

    /// @notice Update the contract owner
    /// @param newOwner Address of the new owner
    function updateOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
        whitelist[newOwner] = true; // Ensure the new owner is in the whitelist
    }
}
