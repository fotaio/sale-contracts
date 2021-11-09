# FOTA sale-contracts

## Setup

### Install packages

```
yarn install
```

### Run local blockchain
Install `ganache-cli` to run local blockchain:
```
yarn global add ganache-cli
```

Then run local blockchain with 100 accounts:

```
ganache-cli -a 100
```

### Truffle

```
yarn global add truffle
```

## Run tests

Build the contracts:

```
truffle compile --all
```

Run PrivateSale test:
```
truffle test ./test/PrivateSale.js
```

Run SeedSale test:
```
truffle test ./test/SeedSale.js
```

Run StrategicSale test:
```
truffle test ./test/StrategicSale.js
```
