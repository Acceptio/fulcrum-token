﻿# Migrations.sol

**Migrations**

## Contract Members
**Constants & Variables**

```js
address public owner;
uint256 public last_completed_migration;
```

## Modifiers

- [restricted](#restricted)

### restricted

```js
modifier restricted() internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|

## Functions

- [setCompleted](#setcompleted)
- [upgrade](#upgrade)

### setCompleted

```js
function setCompleted(uint256 completed) public restricted
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| completed | uint256 |  | 

### upgrade

```js
function upgrade(address new_address) public restricted
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| new_address | address |  | 

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
