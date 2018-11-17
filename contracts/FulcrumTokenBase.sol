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


///@title Fulcrum Token Base Contract
///@author Binod Nirvan
///@notice The FULC is our native settlements token used across our marketplace, 
///and will enable many important functions within the Accept global marketplace including: 
///A medium of exchange (settlements) for Accept.io buyers and sellers A consumptive use (utility) token 
///for marketplace users to access premium features in the Accept.io DApp An incentive for users to help 
///improve the Accept Marketplace and contribute to the long-term development of Accept.io
contract FulcrumTokenBase is StandardToken, CustomPausable, BurnableToken {
  //solhint-disable
  uint8 public constant decimals = 18;
  string public constant name = "Fulcrum Token";
  string public constant symbol = "FULC";
  //solhint-enable

  bool public released = false;

  uint256 internal constant MILLION = 1000000 * 1 ether; 
  uint256 public constant MAX_SUPPLY = 200 * MILLION;
  uint256 public constant INITIAL_SUPPLY = 100 * MILLION;

  event BulkTransferPerformed(address[] _destinations, uint256[] _amounts);
  event TokenReleased(bool _state);
  event Mint(address indexed to, uint256 amount);

  constructor() public {
    mintTokens(msg.sender, INITIAL_SUPPLY);
  }

  ///@notice Checks if the supplied address is able to perform transfers.
  ///@param _from The address to check against if the transfer is allowed.
  modifier canTransfer(address _from) {
    if(paused || !released) {
      if(!isAdmin(_from)) {
        revert("Operation not allowed. The transfer state is restricted.");
      }
    }

    _;
  }

  ///@notice Transfers all Ether held by the contract to the owner.
  function reclaimEther() external onlyAdmin {
    msg.sender.transfer(address(this).balance);
  }

  ///@notice Transfers all ERC20 tokens held by the contract to the owner.
  ///@param _token The amount of token to reclaim.
  function reclaimToken(address _token) external onlyAdmin {
    ERC20 erc20 = ERC20(_token);
    uint256 balance = erc20.balanceOf(this);
    require(erc20.transfer(msg.sender, balance));
  }

  ///@notice This function enables token transfers for everyone.
  ///Can only be enabled after the end of the ICO.
  function releaseTokenForTransfer() external onlyAdmin whenNotPaused returns(bool) {
    require(!released, "Invalid operation. The transfer state is no more restricted.");

    released = true;

    emit TokenReleased(released);
    return true;
  }

  ///@notice This function disables token transfers for everyone.
  function disableTokenTransfers() external onlyAdmin whenNotPaused returns(bool) {
    require(released, "Invalid operation. The transfer state is already restricted.");

    released = false;

    emit TokenReleased(released);
    return true;
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
  
  ///@notice Allows only the admins and/or whitelisted applications to perform bulk transfer operation.
  ///@param _destinations The destination wallet addresses to send funds to.
  ///@param _amounts The respective amount of fund to send to the specified addresses. 
  function bulkTransfer(address[] _destinations, uint256[] _amounts) public onlyAdmin returns(bool) {
    require(_destinations.length == _amounts.length, "Invalid operation.");

    //Saving gas by determining if the sender has enough balance
    //to post this transaction.
    uint256 requiredBalance = sumOf(_amounts);
    require(balances[msg.sender] >= requiredBalance, "You don't have sufficient funds to transfer amount that large.");
    
    for (uint256 i = 0; i < _destinations.length; i++) {
      transfer(_destinations[i], _amounts[i]);
    }

    emit BulkTransferPerformed(_destinations, _amounts);
    return true;
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
  
  ///@notice Returns the sum of supplied values.
  ///@param _values The collection of values to create the sum from.  
  function sumOf(uint256[] _values) private pure returns(uint256) {
    uint256 total = 0;

    for (uint256 i = 0; i < _values.length; i++) {
      total = total.add(_values[i]);
    }

    return total;
  }
}