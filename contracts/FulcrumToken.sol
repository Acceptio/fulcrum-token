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

import "./FulcrumTokenBase.sol";


///@title Fulcrum Token
///@author Binod Nirvan
///@notice The FULC is our native settlements token used across our marketplace, 
///and will enable many important functions within the Accept global marketplace including: 
///A medium of exchange (settlements) for Accept.io buyers and sellers A consumptive use (utility) token 
///for marketplace users to access premium features in the Accept.io DApp An incentive for users to help 
///improve the Accept Marketplace and contribute to the long-term development of Accept.io
contract FulcrumToken is FulcrumTokenBase {
  //solhint-disable not-rely-on-time
  //solium-disable security/no-block-members

  uint256 public icoEndDate;

  uint256 public constant ALLOCATION_FOR_COMMUNITY_REWARDS = 15 * MILLION;
  uint256 public constant ALLOCATION_FOR_RESERVE = 17 * MILLION;
  uint256 public constant ALLOCATION_FOR_TEAM = 40 * MILLION;
  uint256 public constant ALLOCATION_FOR_ADVISORS = 8 * MILLION;
  uint256 public constant ALLOCATION_FOR_INITIAL_STRATEGIC_PARTNERSHIPS = 10 * MILLION;
  uint256 public constant ALLOCATION_FOR_STRATEGIC_PARTNERSHIPS = 10 * MILLION;

  bool public targetReached = false;

  mapping(bytes32 => bool) private mintingList;

  event ICOEndDateSet(uint256 _date);
  event TargetReached();

  ///@notice Checks if the minting for the supplied key was already performed.
  ///@param _key The key or category name of minting.
  modifier whenNotMinted(string _key) {
    if(mintingList[computeHash(_key)]) {
      revert("Duplicate minting key supplied.");
    }

    _;
  }

  ///@notice This function signifies that the minimum fundraising target was met.
  ///Please note that this can only be called once.
  function setSuccess() external onlyAdmin returns(bool) {
    require(!targetReached, "Access is denied.");
    targetReached = true;

    emit TargetReached();
  }

  ///@notice This function enables the whitelisted application (internal application) to set the 
  /// ICO end date and can only be used once.
  ///@param _date The date to set as the ICO end date.
  function setICOEndDate(uint _date) external onlyAdmin returns(bool) {
    require(icoEndDate == 0, "The ICO end date was already set.");
    require(_date > now, "The ICO end date must be in the future.");

    icoEndDate = _date;
    
    emit ICOEndDateSet(_date);
    return true;
  }

  ///@notice Mints the below-mentioned amount of tokens allocated to rewarding the community.
  //The tokens are available to the community rewards pool only if the fundraiser was successful.
  function mintCommunityRewardTokens() external onlyAdmin returns(bool) {
    require(targetReached, "Sorry, you can't mint at this time because the target hasn't been reached yet.");

    return mintOnce("communityRewards", msg.sender, ALLOCATION_FOR_COMMUNITY_REWARDS);
  }

  ///@notice Mints the below-mentioned amount of tokens allocated to the operational reserves.
  //The tokens are only available in the reserves after 18 months of the ICO end.
  function mintReserveTokens() external onlyAdmin returns(bool) {
    require(targetReached, "Sorry, you can't mint at this time because the target hasn't been reached yet.");
    require(icoEndDate != 0, "You need to specify the ICO end date before minting the tokens.");
    require(now > (icoEndDate + 548 days), "Access is denied, it's too early to mint the reserve tokens.");

    return mintOnce("operationalReserve", msg.sender, ALLOCATION_FOR_RESERVE);
  }

  ///@notice Mints the below-mentioned amount of tokens allocated to the Accept.io founders.
  //The tokens are only available to the founders after 2 year of the ICO end.
  function mintTokensForTeam() external onlyAdmin returns(bool) {
    require(targetReached, "Sorry, you can't mint at this time because the target hasn't been reached yet.");
    require(icoEndDate != 0, "You need to specify the ICO end date before minting the tokens.");
    require(now > (icoEndDate + 730 days), "Access is denied, it's too early to mint team tokens.");

    return mintOnce("team", msg.sender, ALLOCATION_FOR_TEAM);
  }

  ///@notice Mints the below-mentioned amount of tokens allocated to the Accept.io advisors.
  //The tokens are only available to the advisors after 1 year of the ICO end.
  function mintTokensForAdvisors() external onlyAdmin returns(bool) {
    require(targetReached, "Sorry, you can't mint at this time because the target hasn't been reached yet.");
    require(icoEndDate != 0, "You need to specify the ICO end date before minting the tokens.");
    require(now > (icoEndDate + 365 days), "Access is denied, it's too early to mint advisory tokens.");

    return mintOnce("advisors", msg.sender, ALLOCATION_FOR_ADVISORS);
  }

  ///@notice Mints the below-mentioned amount of tokens allocated to the first Strategic Partnership category.
  //The tokens are available to the first strategic partners only if the fundraiser was successful.
  function mintTokensForInitialStrategicPartnerships() external onlyAdmin returns(bool) {
    require(targetReached, "Sorry, you can't mint at this time because the target hasn't been reached yet.");

    return mintOnce("initialStrategicPartners", msg.sender, ALLOCATION_FOR_INITIAL_STRATEGIC_PARTNERSHIPS);
  }

  ///@notice Mints the below-mentioned amount of tokens allocated to the second Strategic Partnership category.
  //The tokens are only available to the second strategic partners after 730 days of the ICO end.
  function mintTokensForStrategicPartnerships() external onlyAdmin returns(bool) {
    require(targetReached, "Sorry, you can't mint at this time because the target hasn't been reached yet.");
    require(icoEndDate != 0, "You need to specify the ICO end date before minting the tokens.");
    require(now > (icoEndDate + 730 days), "Access is denied, it's too early to mint the partnership tokens.");

    return mintOnce("strategicPartners", msg.sender, ALLOCATION_FOR_STRATEGIC_PARTNERSHIPS);
  }

  ///@notice Computes keccak256 hash of the supplied value.
  ///@param _key The string value to compute hash from.
  function computeHash(string _key) private pure returns(bytes32) {
    return keccak256(abi.encodePacked(_key));
  }

  ///@notice Mints the tokens only once against the supplied key (category).
  ///@param _key The key or the category of the allocation to mint the tokens for.
  ///@param _to The address receiving the minted tokens.
  ///@param _amount The amount of tokens to mint.
  function mintOnce(string _key, address _to, uint256 _amount) private whenNotPaused whenNotMinted(_key) returns(bool) {
    mintingList[computeHash(_key)] = true;
    return mintTokens(_to, _amount);
  }
}