// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./IFlashBorrower.sol";
import "./IFlashLender.sol";

contract FlashLoanExample is IFlashBorrower {
    IFlashLender public lender;
    IERC20 public token;

    constructor(IFlashLender lender_, IERC20 token_) {
        lender = lender_;
        token = token_;
    }

    function onFlashLoan(
        address initiator,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external override returns (bytes32) {
        require(
            msg.sender == address(lender),
            "FlashBorrower: Untrusted lender"
        );
        require(
            initiator == address(this),
            "FlashBorrower: Untrusted loan initiator"
        );

        // Write your logic here
        // make sure that this contract has a balance of (amount + fee) once you're done
        // the (amount + fee) is burnt off for the contract to succeed.

        return keccak256("FlashMinter.onFlashLoan");
    }

    /// @dev Initiate a flash loan
    function execute(uint256 amount) public {
        // calculate the fee
        uint256 _fee = lender.flashFee(amount);
        uint256 _repayment = amount + _fee;

        // encode the data you want to pass into the flash loan
        bytes memory data = abi.encode();

        // give approvals for the burn fn. to payback the flashloan
        uint256 _allowance = IERC20(token).allowance(
            address(this),
            address(lender)
        );
        IERC20(token).approve(address(lender), _allowance + _repayment);

        // execute the flashloan!
        lender.flashLoan(this, amount, data);
    }
}