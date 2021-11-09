const util = require('./index')
const { deployProxy } = require('@openzeppelin/truffle-upgrades')

const FOTAToken = artifacts.require('./FOTAToken.sol')
const MBUSDToken = artifacts.require('./MBUSDToken.sol')
const MUSDTToken = artifacts.require('./MUSDTToken.sol')
const PrivateSale = artifacts.require('./PrivateSale.sol')
const SeedSale = artifacts.require('./SeedSale.sol')
const StrategicSale = artifacts.require('./StrategicSale.sol')

async function initPrivateSaleInstance(accounts) {
  const {
    mainAdmin
  } = util.getAccounts(accounts)
  const fotaTokenInstance = await initFotaTokenInstance(accounts)
  await fotaTokenInstance.setGameAddress(mainAdmin, true)
  const { mbusdTokenInstance, musdtTokenInstance } = await initMockTokenInstance()
  const privateSaleInstance = await deployProxy(PrivateSale, [mainAdmin, mainAdmin, fotaTokenInstance.address])
  await privateSaleInstance.setUsdToken(mbusdTokenInstance.address, musdtTokenInstance.address)
  return privateSaleInstance
}

async function initSeedSaleInstance(accounts) {
  const {
    mainAdmin
  } = util.getAccounts(accounts)
  const fotaTokenInstance = await initFotaTokenInstance(accounts)
  await fotaTokenInstance.setGameAddress(mainAdmin, true)
  const { mbusdTokenInstance, musdtTokenInstance } = await initMockTokenInstance()
  const seedSaleInstance = await deployProxy(SeedSale, [mainAdmin, mainAdmin, fotaTokenInstance.address])
  await seedSaleInstance.setUsdToken(mbusdTokenInstance.address, musdtTokenInstance.address)
  return seedSaleInstance
}

async function initStrategicSaleInstance(accounts) {
  const {
    mainAdmin
  } = util.getAccounts(accounts)
  const fotaTokenInstance = await initFotaTokenInstance(accounts)
  await fotaTokenInstance.setGameAddress(mainAdmin, true)
  const { mbusdTokenInstance, musdtTokenInstance } = await initMockTokenInstance()
  const strategicSaleInstance = await deployProxy(StrategicSale, [mainAdmin, mainAdmin, fotaTokenInstance.address])
  await strategicSaleInstance.setUsdToken(mbusdTokenInstance.address, musdtTokenInstance.address)
  return strategicSaleInstance
}

async function initFotaTokenInstance(accounts) {
  const {
    liquidityPoolAddress,
  } = util.getAccounts(accounts)
  return FOTAToken.new(liquidityPoolAddress)
}

async function initMockTokenInstance() {
  const mbusdTokenInstance = await MBUSDToken.new()
  const musdtTokenInstance = await MUSDTToken.new()
  return {
    mbusdTokenInstance,
    musdtTokenInstance
  }
}

module.exports = {
  initPrivateSaleInstance,
  initSeedSaleInstance,
  initStrategicSaleInstance
}
