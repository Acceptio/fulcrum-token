﻿# Fulcrum Token Base Contract (FulcrumTokenBase.sol)

**contract FulcrumTokenBase is [StandardToken](StandardToken.md), [CustomPausable](CustomPausable.md), [BurnableToken](BurnableToken.md)**

**FulcrumTokenBase**

The FULC is our native settlements token used across our marketplace, 
and will enable many important functions within the Accept global marketplace including: 
A medium of exchange (settlements) for Accept.io buyers and sellers A consumptive use (utility) token 
for marketplace users to access premium features in the Accept.io DApp An incentive for users to help 
improve the Accept Marketplace and contribute to the long-term development of Accept.io

## Contract Members
**Constants & Variables**

```js
//public members
uint8 public constant decimals;
string public constant name;
string public constant symbol;
bool public released;
uint256 public constant MAX_SUPPLY;
uint256 public constant INITIAL_SUPPLY;

//internal members
uint256 internal constant MILLION;
```

**Events**

```js
event BulkTransferPerformed(address[] _destinations, uint256[] _amounts);
event TokenReleased(bool _state);
event Mint(address indexed to, uint256 amount);
```

## Modifiers

- [canTransfer](#cantransfer)

### canTransfer

Checks if the supplied address is able to perform transfers.

```js
modifier canTransfer(address _from) internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _from | address | The address to check against if the transfer is allowed. | 

## Functions

- [mintTokens](#minttokens)
- [releaseTokenForTransfer](#releasetokenfortransfer)
- [disableTokenTransfers](#disabletokentransfers)
- [transfer](#transfer)
- [transferFrom](#transferfrom)
- [approve](#approve)
- [increaseApproval](#increaseapproval)
- [decreaseApproval](#decreaseapproval)
- [sumOf](#sumof)
- [bulkTransfer](#bulktransfer)
- [burn](#burn)

### mintTokens

```js
function mintTokens(address _to, uint256 _value) internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _to | address | The address which will receive the minted tokens. | 
| _value | uint256 | The amount of tokens to mint. | 

### releaseTokenForTransfer

This function enables token transfers for everyone.
Can only be enabled after the end of the ICO.

```js
function releaseTokenForTransfer() public onlyAdmin whenNotPaused
returns(bool)
```

### disableTokenTransfers

This function disables token transfers for everyone.

```js
function disableTokenTransfers() public onlyAdmin whenNotPaused
returns(bool)
```

### transfer

:small_red_triangle: overrides [BasicToken.transfer](BasicToken.md#transfer)

```js
function transfer(address _to, uint256 _value) public canTransfer
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _to | address | The destination wallet address to transfer funds to. | 
| _value | uint256 | The amount of tokens to send to the destination address. | 

### transferFrom

:small_red_triangle: overrides [StandardToken.transferFrom](StandardToken.md#transferfrom)

Transfers tokens from a specified wallet address.

```js
function transferFrom(address _from, address _to, uint256 _value) public canTransfer
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _from | address | The address to transfer funds from. | 
| _to | address | The address to transfer funds to. | 
| _value | uint256 | The amount of tokens to transfer. | 

### approve

:small_red_triangle: overrides [StandardToken.approve](StandardToken.md#approve)

Approves a wallet address to spend on behalf of the sender.

```js
function approve(address _spender, uint256 _value) public canTransfer
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _spender | address | The address which is approved to spend on behalf of the sender. | 
| _value | uint256 | The amount of tokens approve to spend. | 

### increaseApproval

:small_red_triangle: overrides [StandardToken.increaseApproval](StandardToken.md#increaseapproval)

Increases the approval of the spender.

```js
function increaseApproval(address _spender, uint256 _addedValue) public canTransfer
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _spender | address | The address which is approved to spend on behalf of the sender. | 
| _addedValue | uint256 | The added amount of tokens approved to spend. | 

### decreaseApproval

:small_red_triangle: overrides [StandardToken.decreaseApproval](StandardToken.md#decreaseapproval)

Decreases the approval of the spender.

```js
function decreaseApproval(address _spender, uint256 _subtractedValue) public canTransfer
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _spender | address | The address of the spender to decrease the allocation from. | 
| _subtractedValue | uint256 | The amount of tokens to subtract from the approved allocation. | 

### sumOf

Returns the sum of supplied values.

```js
function sumOf(uint256[] _values) private pure
returns(uint256)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _values | uint256[] | The collection of values to create the sum from. | 

### bulkTransfer

Allows only the admins and/or whitelisted applications to perform bulk transfer operation.

```js
function bulkTransfer(address[] _destinations, uint256[] _amounts) public onlyAdmin
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _destinations | address[] | The destination wallet addresses to send funds to. | 
| _amounts | uint256[] | The respective amount of fund to send to the specified addresses. | 

### burn

:small_red_triangle: overrides [BurnableToken.burn](BurnableToken.md#burn)

Burns the coins held by the sender.

```js
function burn(uint256 _value) public whenNotPaused
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| _value | uint256 | The amount of coins to burn. | 

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