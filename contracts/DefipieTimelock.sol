// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

contract DefipieTimelock {
  using SafeERC20 for IERC20;

  // ERC20 basic token contract being held
  IERC20 private _token;

  struct LockBox {
    uint id;
    address beneficiary;
    uint amount;
    uint releaseTime;
  }

  LockBox[] public lockBox; // This could be a mapping by address, but these numbered lockBoxes support possibility of multiple tranches per address

  event LogLockBoxDeposit(address sender, uint amount, uint releaseTime);   
  event LogLockBoxWithdrawal(address sender, address beneficiary, uint id, uint amount);

  constructor(address tokenContract) public {
    _token = IERC20(tokenContract);
  }

  /**
   * @return the token being held.
   */
  function token() public view returns (IERC20) {
    return _token;
  }

  function getAllBoxes() external view returns (LockBox[] memory) {
    return lockBox;
  }

  function deposit(address beneficiary, uint amount, uint releaseTime) public returns(bool success) {
    _token.safeTransferFrom(msg.sender, address(this), amount);
    LockBox memory l;
    l.id = lockBox.length;
    l.beneficiary = beneficiary;
    l.amount = amount;
    l.releaseTime = releaseTime;
    lockBox.push(l);
    emit LogLockBoxDeposit(msg.sender, amount, releaseTime);
    return true;
  }

  function withdraw(uint id) public returns(bool success) {
    LockBox storage l = lockBox[id];
    require(l.releaseTime <= now, "Unlock time has not come yet");
    require(l.amount > 0, "This box is empty");
    uint amount = l.amount;
    l.amount = 0;
    emit LogLockBoxWithdrawal(msg.sender, l.beneficiary, id, amount);
    _token.safeTransfer(l.beneficiary, amount);
    return true;
  }

}