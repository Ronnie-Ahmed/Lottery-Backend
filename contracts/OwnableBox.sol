// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";

contract OwnableBox is Ownable {
    uint256 private value;
    event AddValue(uint256 value);

    function changeValue(uint256 _value) external onlyOwner {
        value = _value;
        emit AddValue(value);
    }

    function retrievevalue() public view returns (uint256) {
        return value;
    }
}
