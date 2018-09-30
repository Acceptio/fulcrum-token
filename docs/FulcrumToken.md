# Fulcrum Token (FulcrumToken.sol)

**contract FulcrumToken is [FulcrumTokenBase](FulcrumTokenBase.md)**

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
uint256 public ICOEndDate;
uint256 public constant ALLOCATION_FOR_TEAM;
uint256 public constant ALLOCATION_FOR_INITIAL_STRATEGIC_PARTNERSHIPS;
uint256 public constant ALLOCATION_FOR_STRATEGIC_PARTNERSHIPS;
uint256 public constant ALLOCATION_FOR_RESERVE;
uint256 public constant ALLOCATION_FOR_COMMUNITY_REWARDS;
uint256 public constant ALLOCATION_FOR_USER_ADOPTION;
uint256 public constant ALLOCATION_FOR_MARKETING;
uint256 public constant ALLOCATION_FOR_ADVISORS;

//private members
mapping(bytes32 => bool) private mintingList;
```

**Events**

```js
event ICOEndDateSet(uint256 _date);
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

- [computeHash](#computehash)
- [setICOEndDate](#seticoenddate)
- [mintOnce](#mintonce)
- [mintTokensForTeam](#minttokensforteam)
- [mintTokensForInitialStrategicPartnerships](#minttokensforinitialstrategicpartnerships)
- [mintTokensForStrategicPartnerships](#minttokensforstrategicpartnerships)
- [mintTokensForAdvisors](#minttokensforadvisors)

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

### setICOEndDate

This function enables the whitelisted application (internal application) to set the ICO end date and can only be used once.

```js
function setICOEndDate(uint256 _date) public onlyAdmin
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _date | uint256 | The date to set as the ICO end date. | 

### mintOnce

Mints the tokens only once against the supplied key (category).

```js
function mintOnce(string _key, address _to, uint256 _amount) private whenNotPaused whenNotMinted
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _key | string | The key or the category of the allocation to mint the tokens for. | 
| _to | address | The address receiving the minted tokens. | 
| _amount | uint256 | The amount of tokens to mint. | 

### mintTokensForTeam

Mints the below-mentioned amount of tokens allocated to the Accept.io founders.

```js
function mintTokensForTeam() public onlyAdmin
returns(bool)
```

### mintTokensForInitialStrategicPartnerships

Mints the below-mentioned amount of tokens allocated to the first Strategic Partnership category.

```js
function mintTokensForInitialStrategicPartnerships() public onlyAdmin
returns(bool)
```

### mintTokensForStrategicPartnerships

Mints the below-mentioned amount of tokens allocated to the second Strategic Partnership category.

```js
function mintTokensForStrategicPartnerships() public onlyAdmin
returns(bool)
```

### mintTokensForAdvisors

Mints the below-mentioned amount of tokens allocated to the Accept.io advisors.

```js
function mintTokensForAdvisors() public onlyAdmin
returns(bool)
```

## Contracts

- [ERC20Basic](ERC20Basic.md)
- [SafeMath](SafeMath.md)
- [FulcrumToken](FulcrumToken.md)
- [FulcrumTokenBase](FulcrumTokenBase.md)
- [BasicToken](BasicToken.md)
- [StandardToken](StandardToken.md)
- [CustomPausable](CustomPausable.md)
- [BurnableToken](BurnableToken.md)
- [CustomAdmin](CustomAdmin.md)
- [Migrations](Migrations.md)
- [Ownable](Ownable.md)
- [ERC20](ERC20.md)
