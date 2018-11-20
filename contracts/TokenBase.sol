/*
Copyright 2018 Binod Nirvan @ Accept (http://accept.io)
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "openzeppelin-solidity/contracts/token/ERC20/BurnableToken.sol";
import "./CustomPausable.sol";
import "./TransferState.sol";
import "./BulkTransfer.sol";
import "./Reclaimable.sol";


///@title Fulcrum Token Base Contract
///@author Binod Nirvan
///@notice The FULC is our native settlements token used across our marketplace, 
///and will enable many important functions within the Accept global marketplace including: 
///A medium of exchange (settlements) for Accept.io buyers and sellers A consumptive use (utility) token 
///for marketplace users to access premium features in the Accept.io DApp An incentive for users to help 
///improve the Accept Marketplace and contribute to the long-term development of Accept.io
contract TokenBase is StandardToken, TransferState, BulkTransfer, Reclaimable, BurnableToken {
  //solhint-disable
  uint8 public constant decimals = 18;
  string public constant name = "Fulcrum Token";
  string public constant symbol = "FULC";
  //solhint-enable

  uint256 internal constant MILLION = 1000000 * 1 ether; 
  uint256 public constant MAX_SUPPLY = 200 * MILLION;
  uint256 public constant INITIAL_SUPPLY = 100 * MILLION;

  event Mint(address indexed to, uint256 amount);

  constructor() public {
    mintTokens(msg.sender, INITIAL_SUPPLY);
  }

  ///@notice Transfers the specified value of FULC tokens to the destination address. 
  //Transfers can only happen when the transfer state is enabled. 
  //Transfer state can only be enabled after the end of the crowdsale.
  ///@param _to The destination wallet address to transfer funds to.
  ///@param _value The amount of tokens to send to the destination address.
  function transfer(address _to, uint256 _value) public canTransfer(msg.sender) returns(bool) {
    require(_to != address(0), "Invalid address.");
    return super.transfer(_to, _value);
  }

  ///@notice Transfers tokens from a specified wallet address.
  ///@dev This function is overridden to leverage transfer state feature.
  ///@param _from The address to transfer funds from.
  ///@param _to The address to transfer funds to.
  ///@param _value The amount of tokens to transfer.
  function transferFrom(address _from, address _to, uint256 _value) public canTransfer(_from) returns(bool) {
    require(_to != address(0), "Invalid address.");
    return super.transferFrom(_from, _to, _value);
  }

  ///@notice Approves a wallet address to spend on behalf of the sender.
  ///@dev This function is overridden to leverage transfer state feature.
  ///@param _spender The address which is approved to spend on behalf of the sender.
  ///@param _value The amount of tokens approve to spend. 
  function approve(address _spender, uint256 _value) public canTransfer(msg.sender) returns(bool) {
    require(_spender != address(0), "Invalid address.");
    return super.approve(_spender, _value);
  }

  ///@notice Increases the approval of the spender.
  ///@dev This function is overridden to leverage transfer state feature.
  ///@param _spender The address which is approved to spend on behalf of the sender.
  ///@param _addedValue The added amount of tokens approved to spend.
  function increaseApproval(address _spender, uint256 _addedValue) public canTransfer(msg.sender) returns(bool) {
    require(_spender != address(0), "Invalid address.");
    return super.increaseApproval(_spender, _addedValue);
  }

  ///@notice Decreases the approval of the spender.
  ///@dev This function is overridden to leverage transfer state feature.
  ///@param _spender The address of the spender to decrease the allocation from.
  ///@param _subtractedValue The amount of tokens to subtract from the approved allocation.
  function decreaseApproval(address _spender, uint256 _subtractedValue) public canTransfer(msg.sender) returns(bool) {
    require(_spender != address(0), "Invalid address.");
    return super.decreaseApproval(_spender, _subtractedValue);
  }

  ///@notice Burns the coins held by the sender.
  ///@param _value The amount of coins to burn.
  ///@dev This function is overridden to leverage Pausable feature.
  function burn(uint256 _value) public whenNotPaused {
    super.burn(_value);
  }

  ///@notice Mints the supplied value of the tokens to the destination address.
  //Minting cannot be performed any further once the maximum supply is reached.
  //This function cannot be used by anyone except for this contract.
  ///@param _to The address which will receive the minted tokens.
  ///@param _value The amount of tokens to mint.
  function mintTokens(address _to, uint _value) internal returns(bool) {
    require(_to != address(0), "Invalid address.");
    require(totalSupply_.add(_value) <= MAX_SUPPLY, "Sorry but the total supply can't exceed the maximum supply.");

    balances[_to] = balances[_to].add(_value);
    totalSupply_ = totalSupply_.add(_value);

    emit Transfer(address(0), _to, _value);
    emit Mint(_to, _value);

    return true;
  }  
}