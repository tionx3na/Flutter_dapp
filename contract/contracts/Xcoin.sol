// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Xcoin {
  int balance;

  constructor() public {
    balance = 0;
  }

  function getBalance() view public returns(int){
    return balance;
  }

  function depositBalance(int amount) public{
    balance = balance + amount;
  } 

  function withdrawBalance(int amount) public{
    balance = balance - amount;
  } 
}
