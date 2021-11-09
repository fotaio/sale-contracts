const BN = require('bn.js')
const value1String = '1000000000000000000'
const value1BN = new BN(value1String)
const value2String = '2000000000000000000'
const value2BN = new BN(value2String)
const value420MString = '420000000000000000000000000'
const value420MBN = new BN(value420MString)
const value500String = '500000000000000000000'
const value500BN = new BN(value500String)
const value100String = '100000000000000000000'
const value100BN = new BN(value100String)
const value1000String = '1000000000000000000000'
const value1000BN = new BN(value1000String)
const value5000String = '5000000000000000000000'
const value5000BN = new BN(value5000String)

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bn')(BN))
  .should()

function to(promise) {
  return promise.then((data) => {
    return [null, data]
  }).catch((error) => {
    console.log('error form to func:', error)
    try {
      return [JSON.parse(error.message)]
    } catch (e) {
      return [error]
    }
  })
}

function listenEvent(response, eventName, index = 0) {
  assert.equal(response.logs[index].event, eventName, eventName + ' event should fire.');
}

const accountsMap = {}

function getAccounts(accounts) {
  if (!accountsMap.mainAdmin) {
    accountsMap.zeroAddress = '0x0000000000000000000000000000000000000000'
    accountsMap.landNFTAddress = '0x0000000000000000000000000000000000000000'
    accountsMap.mainAdmin = accounts[0]
    accountsMap.contractAdmin = accounts[accounts.length - 1]
    accountsMap.liquidityPoolAddress = accounts[0]
    accountsMap.mainAdminOption = {
      from: accountsMap.mainAdmin
    }
    accountsMap.accountUnauthorizedOption = {
	    from: accounts[49]
    }
    accountsMap.validAccount1Option = {
	    from: accounts[1]
    }
    accountsMap.validAccount2Option = {
	    from: accounts[2]
    }
    for (let i = 1; i < accounts.length - 10; i += 1) {
      accountsMap[`user${i}`] = accounts[i]
    }
  }
  return accountsMap
}

module.exports = {
  getAccounts,
  accountsMap,
  BN,
  listenEvent,
  to,
  value1String,
  value1BN,
  value1000BN,
  value1000String,
  value2BN,
  value420MBN,
  value100BN,
  value500BN,
  value500String,
  value5000BN,
  value5000String
}
