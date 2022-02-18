// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "./IFlashBorrower.sol";
import "./IFlashLender.sol";

interface ERC20MinterBurner is IERC20 {
    function burnFrom(address from, uint256 amount) external;

    function mint(address from, uint256 amount) external;
}

contract FlashMinter is IFlashLender, Pausable, Ownable {
    bytes32 public constant CALLBACK_SUCCESS =
        keccak256("FlashMinter.onFlashLoan");

    uint256 public fee; //  1 == 0.0001 %.
    ERC20MinterBurner public token;

    event FeeChanged(uint256 amount);

    /**
     * @param token_ The token to mint/burn
     * @param fee_ The percentage of the loan `amount` that needs to be repaid, in addition to `amount`.
     */
    constructor(address token_, uint256 fee_) {
        token = ERC20MinterBurner(token_);
        fee = fee_;
    }

    function setFee(uint256 amount) external onlyOwner {
        fee = amount;
        emit FeeChanged(amount);
    }

    function toggle() external onlyOwner {
        if (paused()) _unpause();
        else _pause();
    }

    /**
     * @dev The fee to be charged for a given loan.
     * @param amount The amount of tokens lent.
     * @return The amount of `token` to be charged for the loan, on top of the returned principal.
     */
    function flashFee(uint256 amount) external view override returns (uint256) {
        return _flashFee(amount);
    }

    /**
     * @dev Loan `amount` tokens to `receiver`, and takes it back plus a `flashFee` after the ERC3156 callback.
     * @param receiver The contract receiving the tokens, needs to implement the `onFlashLoan(address user, uint256 amount, uint256 fee, bytes calldata)` interface.
     * @param amount The amount of tokens lent.
     * @param data A data parameter to be passed on to the `receiver` for any custom use.
     */
    function flashLoan(
        IFlashBorrower receiver,
        uint256 amount,
        bytes calldata data
    ) external override returns (bool) {
        uint256 _fee = _flashFee(amount);
        token.mint(address(receiver), amount);
        require(
            receiver.onFlashLoan(msg.sender, amount, _fee, data) ==
                CALLBACK_SUCCESS,
            "FlashMinter: Callback failed"
        );
        token.burnFrom(address(receiver), amount + _fee);
        return true;
    }

    /**
     * @dev The fee to be charged for a given loan. Internal function with no checks.
     * @param amount The amount of tokens lent.
     * @return The amount of `token` to be charged for the loan, on top of the returned principal.
     */
    function _flashFee(uint256 amount) internal view returns (uint256) {
        return (amount * fee) / 10000;
    }
}
