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

pragma solidity 0.4.24;

import "./FulcrumTokenBase.sol";

///@title Fulcrum Token
///@author Binod Nirvan
///@notice The FULC is our native settlements token used across our marketplace, 
///and will enable many important functions within the Accept global marketplace including: 
///A medium of exchange (settlements) for Accept.io buyers and sellers A consumptive use (utility) token 
///for marketplace users to access premium features in the Accept.io DApp An incentive for users to help 
///improve the Accept Marketplace and contribute to the long-term development of Accept.io
contract FulcrumToken is FulcrumTokenBase {
  uint256 public ICOEndDate;

  uint256 public constant ALLOCATION_FOR_TEAM = 50 * MILLION;
  uint256 public constant ALLOCATION_FOR_INITIAL_STRATEGIC_PARTNERSHIPS = 20 * MILLION;
  uint256 public constant ALLOCATION_FOR_STRATEGIC_PARTNERSHIPS = 20 * MILLION;
  uint256 public constant ALLOCATION_FOR_RESERVE = 40 * MILLION;
  uint256 public constant ALLOCATION_FOR_COMMUNITY_REWARDS = 30 * MILLION;
  uint256 public constant ALLOCATION_FOR_USER_ADOPTION = 20 * MILLION;
  uint256 public constant ALLOCATION_FOR_MARKETING = 20 * MILLION;
  uint256 public constant ALLOCATION_FOR_ADVISORS = 50 * MILLION;

  mapping(bytes32 => bool) private mintingList;

  event ICOEndDateSet(uint256 _date);


  ///@notice Computes keccak256 hash of the supplied value.
  ///@param _key The string value to compute hash from.
  function computeHash(string _key) private pure returns(bytes32){
    return keccak256(abi.encodePacked(_key));
  }

  ///@notice Checks if the minting for the supplied key was already performed.
  ///@param _key The key or category name of minting.
  modifier whenNotMinted(string _key) {
    if(mintingList[computeHash(_key)]) {
      revert();
    }

    _;
  }

  ///@notice This function enables the whitelisted application (internal application) to set the ICO end date and can only be used once.
  ///@param _date The date to set as the ICO end date.
  function setICOEndDate(uint _date) public onlyAdmin returns(bool) {
    require(ICOEndDate == 0);
    require(_date > now);

    ICOEndDate = _date;
    
    emit ICOEndDateSet(_date);
    return true;
  }

  ///@notice Mints the tokens only once against the supplied key (category).
  ///@param _key The key or the category of the allocation to mint the tokens for.
  ///@param _to The address receiving the minted tokens.
  ///@param _amount The amount of tokens to mint.
  function mintOnce(string _key, address _to, uint256 _amount) private whenNotPaused whenNotMinted(_key) returns(bool) {
    mintTokens(_to, _amount);
    mintingList[computeHash(_key)] = true;
    return true;
  }

  ///@notice Mints the below-mentioned amount of tokens allocated to the Accept.io founders.
  //The tokens are only available to the founders after 2 year of the ICO end.
  function mintTokensForTeam() public onlyAdmin returns(bool) {
    require(ICOEndDate != 0);
    require(now > (ICOEndDate + 730 days));

    return mintOnce("founders", msg.sender, ALLOCATION_FOR_TEAM);
  }

  ///@notice Mints the below-mentioned amount of tokens allocated to the first Strategic Partnership category.
  //The tokens are only available to the first strategic partners after 180 days of the ICO end.
  function mintTokensForInitialStrategicPartnerships() public onlyAdmin returns(bool) {
    require(ICOEndDate != 0);
    require(now > (ICOEndDate + 180 days));

    return mintOnce("initialStrategicPartners", msg.sender, ALLOCATION_FOR_INITIAL_STRATEGIC_PARTNERSHIPS);
  }

  ///@notice Mints the below-mentioned amount of tokens allocated to the second Strategic Partnership category.
  //The tokens are only available to the second strategic partners after 365 days of the ICO end.
  function mintTokensForStrategicPartnerships() public onlyAdmin returns(bool) {
    require(ICOEndDate != 0);
    require(now > (ICOEndDate + 365 days));

    return mintOnce("strategicPartners", msg.sender, ALLOCATION_FOR_STRATEGIC_PARTNERSHIPS);
  }


  ///@notice Mints the below-mentioned amount of tokens allocated to the Accept.io advisors.
  //The tokens are only available to the advisors after 1 year of the ICO end.
  function mintTokensForAdvisors() public onlyAdmin returns(bool) {
    require(ICOEndDate != 0);
    require(now > (ICOEndDate + 365 days));

    return mintOnce("strategicPartners", msg.sender, ALLOCATION_FOR_ADVISORS);
  }
}