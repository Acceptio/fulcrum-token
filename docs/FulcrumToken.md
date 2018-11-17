# Fulcrum Token (FulcrumToken.sol)

View Source: [contracts/FulcrumToken.sol](../contracts/FulcrumToken.sol)

**↗ Extends: [FulcrumTokenBase](FulcrumTokenBase.md)**

**FulcrumToken**

The FULC is our native settlements token used across our marketplace, 
and will enable many important functions within the Accept global marketplace including: 
A medium of exchange (settlements) for Accept.io buyers and sellers A consumptive use (utility) token 
for marketplace users to access premium features in the Accept.io DApp An incentive for users to help 
improve the Accept Marketplace and contribute to the long-term development of Accept.io

## Contract Members
**Constants & Variables**

```js
//public members
uint256 public icoEndDate;
uint256 public constant ALLOCATION_FOR_COMMUNITY_REWARDS;
uint256 public constant ALLOCATION_FOR_RESERVE;
uint256 public constant ALLOCATION_FOR_TEAM;
uint256 public constant ALLOCATION_FOR_ADVISORS;
uint256 public constant ALLOCATION_FOR_INITIAL_STRATEGIC_PARTNERSHIPS;
uint256 public constant ALLOCATION_FOR_STRATEGIC_PARTNERSHIPS;
bool public targetReached;

//private members
mapping(bytes32 => bool) private mintingList;

```

**Events**

```js
event ICOEndDateSet(uint256  _date);
event TargetReached();
```

## Modifiers

- [whenNotMinted](#whennotminted)

### whenNotMinted

Checks if the minting for the supplied key was already performed.

```js
modifier whenNotMinted(string _key) internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _key | string | The key or category name of minting. | 

## Functions

- [setSuccess()](#setsuccess)
- [setICOEndDate(uint256 _date)](#seticoenddate)
- [mintCommunityRewardTokens()](#mintcommunityrewardtokens)
- [mintReserveTokens()](#mintreservetokens)
- [mintTokensForTeam()](#minttokensforteam)
- [mintTokensForAdvisors()](#minttokensforadvisors)
- [mintTokensForInitialStrategicPartnerships()](#minttokensforinitialstrategicpartnerships)
- [mintTokensForStrategicPartnerships()](#minttokensforstrategicpartnerships)
- [computeHash(string _key)](#computehash)
- [mintOnce(string _key, address _to, uint256 _amount)](#mintonce)

### setSuccess

This function signifies that the minimum fundraising target was met.
Please note that this can only be called once.

```js
function setSuccess() external nonpayable onlyAdmin 
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### setICOEndDate

This function enables the whitelisted application (internal application) to set the 
 ICO end date and can only be used once.

```js
function setICOEndDate(uint256 _date) external nonpayable onlyAdmin 
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _date | uint256 | The date to set as the ICO end date. | 

### mintCommunityRewardTokens

Mints the below-mentioned amount of tokens allocated to rewarding the community.

```js
function mintCommunityRewardTokens() external nonpayable onlyAdmin 
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### mintReserveTokens

Mints the below-mentioned amount of tokens allocated to the operational reserves.

```js
function mintReserveTokens() external nonpayable onlyAdmin 
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### mintTokensForTeam

Mints the below-mentioned amount of tokens allocated to the Accept.io founders.

```js
function mintTokensForTeam() external nonpayable onlyAdmin 
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### mintTokensForAdvisors

Mints the below-mentioned amount of tokens allocated to the Accept.io advisors.

```js
function mintTokensForAdvisors() external nonpayable onlyAdmin 
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### mintTokensForInitialStrategicPartnerships

Mints the below-mentioned amount of tokens allocated to the first Strategic Partnership category.

```js
function mintTokensForInitialStrategicPartnerships() external nonpayable onlyAdmin 
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### mintTokensForStrategicPartnerships

Mints the below-mentioned amount of tokens allocated to the second Strategic Partnership category.

```js
function mintTokensForStrategicPartnerships() external nonpayable onlyAdmin 
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

### computeHash

Computes keccak256 hash of the supplied value.

```js
function computeHash(string _key) private pure
returns(bytes32)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _key | string | The string value to compute hash from. | 

### mintOnce

Mints the tokens only once against the supplied key (category).

```js
function mintOnce(string _key, address _to, uint256 _amount) private nonpayable whenNotPaused whenNotMinted 
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _key | string | The key or the category of the allocation to mint the tokens for. | 
| _to | address | The address receiving the minted tokens. | 
| _amount | uint256 | The amount of tokens to mint. | 

## Contracts

* [BasicToken](BasicToken.md)
* [BurnableToken](BurnableToken.md)
* [CustomAdmin](CustomAdmin.md)
* [CustomPausable](CustomPausable.md)
* [ERC20](ERC20.md)
* [ERC20Basic](ERC20Basic.md)
* [ERC20Mock](ERC20Mock.md)
* [ForceEther](ForceEther.md)
* [FulcrumToken](FulcrumToken.md)
* [FulcrumTokenBase](FulcrumTokenBase.md)
* [Migrations](Migrations.md)
* [Ownable](Ownable.md)
* [SafeMath](SafeMath.md)
* [StandardToken](StandardToken.md)
