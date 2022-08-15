// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  uint256 public deadline = block.timestamp + 72 seconds;

  mapping ( address => uint256 ) public balances;
  
  bool openForWithdraw = false;

  bool complete = false;

  uint256 public constant threshold = 1 ether;

  event Stake( address sender, uint256 value);

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  function stake() public payable notCompleted {
    balances[msg.sender] = msg.value;

    emit Stake(msg.sender, msg.value);
  }

  function execute() external {
    require (deadline < block.timestamp, 'Deadline not completed');
    if(address(this).balance > threshold) {
      exampleExternalContract.complete{value: address(this).balance}();
    }else {
       openForWithdraw = true;
    }
  }

  function timeLeft() public view returns (uint256) {
    if(block.timestamp >= deadline){
      return 0;
    }else {
      return deadline-block.timestamp;
    }
  }

  function receive() public payable {
    stake();
  }

  function withdraw() public {

    uint stakerBalance = balances[msg.sender];

    require(timeLeft() == 0, "Cannot call 'withdraw' before the deadline ends!");
    require(stakerBalance > 0, "No ETH staked!");

    balances[msg.sender] = 0;

    (bool success, ) = msg.sender.call{value: stakerBalance}("");
    require(success, "function 'withdraw' failed!");

  }

  modifier notCompleted {
    require(complete == false, 'This is already complete');
    _;
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )


  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`


  // If the `threshold` was not met, allow everyone to call a `withdraw()` function


  // Add a `withdraw()` function to let users withdraw their balance


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend


  // Add the `receive()` special function that receives eth and calls stake()


}
