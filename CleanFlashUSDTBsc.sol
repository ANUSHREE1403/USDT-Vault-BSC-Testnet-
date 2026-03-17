// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

/// @notice Clean, explicit helper for working with USDT (BEP‑20) and BNB on BSC.
/// Owner can deposit/withdraw BNB and tokens; no hidden addresses or obfuscation.
contract CleanFlashUSDTBsc {
    IERC20 public immutable usdt;   // BEP‑20 USDT on BSC
    address public immutable owner; // deployer / UI owner

    /// @notice Allow receiving plain BNB.
    receive() external payable {}

    constructor(address _usdt) {
        require(_usdt != address(0), "USDT required");
        usdt = IERC20(_usdt);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    // -------- BNB (native) helpers --------

    /// @notice Owner can withdraw BNB from this contract.
    function withdrawBNB(uint256 amount, address payable to) external onlyOwner {
        require(to != address(0), "zero addr");
        require(amount <= address(this).balance, "insufficient BNB");
        to.transfer(amount);
    }

    /// @notice View current BNB balance held by this contract.
    function bnbBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // -------- USDT (BEP‑20) helpers --------

    /// @notice Pull USDT from owner into this contract (requires prior approve).
    function depositUSDT(uint256 amount) external onlyOwner {
        require(amount > 0, "amount = 0");
        bool ok = usdt.transferFrom(msg.sender, address(this), amount);
        require(ok, "transferFrom failed");
    }

    /// @notice Owner can withdraw USDT from this contract.
    function withdrawUSDT(uint256 amount, address to) external onlyOwner {
        require(to != address(0), "zero addr");
        require(amount > 0, "amount = 0");
        require(amount <= usdt.balanceOf(address(this)), "insufficient USDT");
        bool ok = usdt.transfer(to, amount);
        require(ok, "transfer failed");
    }

    /// @notice View USDT balance held by this contract.
    function usdtBalance() external view returns (uint256) {
        return usdt.balanceOf(address(this));
    }
}

