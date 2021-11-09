// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

import "./libs/fota/Auth.sol";
import "./libs/zeppelin/token/BEP20/IBEP20.sol";
import "./interfaces/IFOTAToken.sol";

contract PrivateSale is Auth {

  struct Buyer {
    uint allocated;
    uint price; // decimal 3
    uint boughtAtBlock;
    uint lastClaimed;
    uint totalClaimed;
  }
  enum USDCurrency {
    busd,
    usdt
  }

  address public fundAdmin;
  IFOTAToken public fotaToken;
  IBEP20 public busdToken;
  IBEP20 public usdtToken;
  uint public constant privateSaleAllocation = 21e24;
  uint public startVestingBlock;
  uint public constant blockInOneMonth = 864000; // 30 * 24 * 60 * 20
  uint constant decimal3 = 1000;
  uint public tgeRatio;
  uint public vestingTime;
  bool public adminCanUpdateAllocation;
  uint totalAllocated;
  mapping(address => Buyer) buyers;

  event UserAllocated(address indexed buyer, uint amount, uint price, uint timestamp);
  event Bought(address indexed buyer, uint amount, uint price, uint timestamp);
  event Claimed(address indexed buyer, uint amount, uint timestamp);
  event VestingStated(uint timestamp);

  function initialize(address _mainAdmin, address _fundAdmin, address _fotaToken) public initializer {
    Auth.initialize(_mainAdmin);
    fundAdmin = _fundAdmin;
    fotaToken = IFOTAToken(_fotaToken);
    vestingTime = 12;
    tgeRatio = 20;
    adminCanUpdateAllocation = true;
    busdToken = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    usdtToken = IBEP20(0x55d398326f99059fF775485246999027B3197955);
  }

  function startVesting() onlyMainAdmin external {
    require(startVestingBlock == 0, "PrivateSale: vesting had started");
    startVestingBlock = block.number;
    emit VestingStated(startVestingBlock);
  }

  function updateVestingTime(uint _month) onlyMainAdmin external {
    require(adminCanUpdateAllocation, "PrivateSale: user had bought");
    vestingTime = _month;
  }

  function updateTGERatio(uint _ratio) onlyMainAdmin external {
    require(adminCanUpdateAllocation, "PrivateSale: user had bought");
    require(_ratio < 100, "PrivateSale: invalid ratio");
    tgeRatio = _ratio;
  }

  function updateFundAdmin(address _address) onlyMainAdmin external {
    require(_address != address(0), "PrivateSale: invalid address");
    fundAdmin = _address;
  }

  function setUserAllocations(address[] calldata _buyers, uint[] calldata _amounts, uint[] calldata _prices) external onlyMainAdmin {
    require(_buyers.length == _amounts.length && _amounts.length == _prices.length, "PrivateSale: invalid data input");
    address buyer;
    uint amount;
    uint price;
    for(uint i = 0; i < _buyers.length; i++) {
      buyer = _buyers[i];
      amount = _amounts[i];
      price = _prices[i];
      if (_buyers[i] != address(0) && buyers[_buyers[i]].boughtAtBlock == 0) {
        if (buyers[buyer].allocated == 0) {
          totalAllocated += amount;
        } else {
          totalAllocated = totalAllocated - buyers[buyer].allocated + amount;
        }
        buyers[buyer] = Buyer(amount, price, 0, 0, 0);
        emit UserAllocated(buyer, amount, price, block.timestamp);
      }
    }
    require(totalAllocated <= privateSaleAllocation, "PrivateSale: amount invalid");
  }

  function removeBuyerAllocation(address _buyer) external onlyMainAdmin {
    require(buyers[_buyer].allocated > 0, "PrivateSale: User have no allocation");
    require(buyers[_buyer].boughtAtBlock == 0, "PrivateSale: User have bought already");
    delete buyers[_buyer];
  }

  function buy(USDCurrency _usdCurrency) external {
    Buyer storage buyer = buyers[msg.sender];
    require(buyer.allocated > 0, "PrivateSale: You have no allocation");
    require(buyer.boughtAtBlock == 0, "PrivateSale: You had bought");
    if (adminCanUpdateAllocation) {
      adminCanUpdateAllocation = false;
    }
    _takeFund(_usdCurrency, buyer.allocated * buyer.price / decimal3);
    buyer.boughtAtBlock = block.number;
    emit Bought(msg.sender, buyer.allocated, buyer.price, block.timestamp);
  }

  function claim() external {
    require(startVestingBlock > 0, "PrivateSale: please wait more time");
    Buyer storage buyer = buyers[msg.sender];
    require(buyer.boughtAtBlock > 0, "PrivateSale: You have no allocation");
    uint maxBlockNumber = startVestingBlock + blockInOneMonth * vestingTime;
    require(maxBlockNumber > buyer.lastClaimed, "PrivateSale: your allocation had released");
    uint blockPass;
    uint releaseAmount;
    if (buyer.lastClaimed == 0) {
      buyer.lastClaimed = startVestingBlock;
      releaseAmount = buyer.allocated * tgeRatio / 100;
    } else {
      if (block.number < maxBlockNumber) {
        blockPass = block.number - buyer.lastClaimed;
        buyer.lastClaimed = block.number;
      } else {
        blockPass = maxBlockNumber - buyer.lastClaimed;
        buyer.lastClaimed = maxBlockNumber;
      }
      releaseAmount = buyer.allocated * (100 - tgeRatio) / 100 * blockPass / (blockInOneMonth * vestingTime);
    }
    buyer.totalClaimed = buyer.totalClaimed + releaseAmount;
    require(fotaToken.releasePrivateSaleAllocation(msg.sender, releaseAmount), "PrivateSale: transfer token failed");
    emit Claimed(msg.sender, releaseAmount, block.timestamp);
  }

  function getBuyer(address _address) external view returns (uint, uint, uint, uint, uint) {
    Buyer storage buyer = buyers[_address];
    return(
      buyer.allocated,
      buyer.price,
      buyer.boughtAtBlock,
      buyer.lastClaimed,
      buyer.totalClaimed
    );
  }

  function _takeFund(USDCurrency _usdCurrency, uint _amount) private {
    IBEP20 usdToken = _usdCurrency == USDCurrency.busd ? busdToken : usdtToken;
    require(usdToken.allowance(msg.sender, address(this)) >= _amount, "PrivateSale: please approve usd token first");
    require(usdToken.balanceOf(msg.sender) >= _amount, "PrivateSale: please fund your account");
    require(usdToken.transferFrom(msg.sender, address(this), _amount), "PrivateSale: transfer usd token failed");
    require(usdToken.transfer(fundAdmin, _amount), "PrivateSale: transfer usd token failed");
  }

  // TODO for testing purpose
  function setUsdToken(address _busdToken, address _usdtToken) external onlyMainAdmin {
    busdToken = IBEP20(_busdToken);
    usdtToken = IBEP20(_usdtToken);
  }
}
