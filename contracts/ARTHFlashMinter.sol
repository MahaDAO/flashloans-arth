// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";

import {IFlashBorrower} from "./IFlashBorrower.sol";
import {IFlashLender} from "./IFlashLender.sol";

interface ERC20MinterBurner is IERC20 {
    function burn(address from, uint256 amount) external;

    function mint(address to, uint256 amount) external;
}

/// @title A flash loan contract for minting/burning a large amount of ARTH
/// @author Steven Enamakel <enamakel@mahadao.com>
contract ARTHFlashMinter is IFlashLender, Pausable, Ownable {
    /// @notice This is the return value that must be returned by the contract that utilizes the flashloan upon success.
    bytes32 public constant CALLBACK_SUCCESS =
        keccak256("ARTHFlashMinter.onFlashLoan");

    /// @notice How much % of the flash loan is charged as fees
    uint256 public fee = 10000; //  10000 == 1 %.

    /// @notice The ARTH token from which the flashloan contract has permission to mint/burn
    ERC20MinterBurner public arth;

    /// @notice The address where all flashloan fees will go to
    address public ecosystemFund;

    event FeeChanged(uint256 amount);
    event EcosystemFundChanged(address fund_);
    event FlashloanMint(uint256 amount, address indexed to);
    event FlashloanPayback(uint256 amount, uint256 fee, address indexed by);

    /**
     * @param arth_ The token to mint/burn
     * @param fee_ The percentage of the loan `amount` that will be charged as fees
     * @param fund_ The destination for the flashloan fees
     * @param governance_ The address which can make changes to the protocol
     */
    constructor(
        address arth_,
        address fund_,
        uint256 fee_,
        address governance_
    ) {
        arth = ERC20MinterBurner(arth_);
        setEcosystemFund(fund_, fee_);
        _transferOwnership(governance_);
    }

    /**
     * @dev Sets the ecosystem fund and fee which recieves all the flashloan revenue. Cah be updated only by governance.
     * @param fee_ The percentage of the loan `amount` that will be charged as fees
     * @param fund_ The destination for the flashloan fees
     */
    function setEcosystemFund(address fund_, uint256 fee_) public onlyOwner {
        ecosystemFund = fund_;
        fee = fee_;
        emit FeeChanged(fee_);
        emit EcosystemFundChanged(fund_);
    }

    /**
     * @dev Pause/Unpause the flashloan contract. Meant to be called by governance.
     */
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

        arth.mint(address(receiver), amount);
        emit FlashloanMint(amount, address(receiver));

        require(
            receiver.onFlashLoan(msg.sender, amount, _fee, data) ==
                CALLBACK_SUCCESS,
            "ARTHFlashMinter: Callback failed"
        );

        arth.burn(address(receiver), amount);
        arth.transfer(ecosystemFund, _fee);

        emit FlashloanPayback(amount, _fee, address(receiver));
        return true;
    }

    /**
     * @dev The fee to be charged for a given loan. Internal function with no checks.
     * @param amount The amount of tokens lent.
     * @return ret The amount of `token` to be charged for the loan, on top of the returned principal.
     */
    function _flashFee(uint256 amount) internal view returns (uint256 ret) {
        ret = (amount * fee) / 10000;
    }
}
