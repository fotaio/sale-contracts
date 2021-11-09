// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

library Math {

  function genRandomNumber(string calldata _seed) internal view returns (uint8) {
    return genRandomNumberInRange(_seed, 0, 99);
  }

  function genRandomNumberInRange(string calldata _seed, uint _from, uint _to) internal view returns (uint8) {
    require(_to > _from, 'Math: Invalid range');
    uint randomNumber = uint(
      keccak256(
        abi.encodePacked(
          keccak256(
            abi.encodePacked(
              block.number,
              block.difficulty,
              block.timestamp,
              msg.sender,
              _seed
            )
          )
        )
      )
    ) % (_to - _from + 1);
    return uint8(randomNumber + _from);
  }
}
