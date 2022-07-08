// SPDX-License-Identifier: GPL-3.0

import "@openzeppelin/contracts/access/Ownable.sol";

pragma solidity 0.8.7;

contract randomPicker is Ownable {
    bool called = false;
    uint[] tokenIds = [/*edited*/];
    mapping (address => uint) addressToAllowance;
    uint[] tempAllowance;
    address[] tempAddresses;
    address[9] Addresses = [/*edited*/];
    uint[] Allowances = [1,1,4,1,1,2,1,1,1];
    mapping (address => uint[]) addressToTokenIds;
    uint blockTimeStamp;
    struct result{
        address _ad;
        uint[] tokenIds;
    }

    constructor() { 
        for (uint i; i< Addresses.length;i++){
            addressToAllowance[Addresses[i]] = Allowances[i];
            tempAllowance.push(Allowances[i]);
            tempAddresses.push(Addresses[i]);
        }
    }

    function runPicker() external onlyOwner {
        require (called == false, "already runned");
        blockTimeStamp = block.timestamp; // store the block hash used as seed for the picker
        for (uint i; i<tokenIds.length;i++){

            uint random = randomNum(blockTimeStamp, i); // get a random number based on the remaining addresses with positive allowance

            addressToTokenIds[tempAddresses[random]].push(tokenIds[i]); // push the tokenId to the picked address 
            tempAllowance[random]--; // decrement the temporary allowance storage

            if (tempAllowance[random] ==0 && tempAddresses.length >1) // if the remaining allowance = 0, then delete the address from the array so it can't pick it anymore
                remove(random);
        }
        called = true;
    }

    // return a number between 0 and the number of remaining addresses
    function randomNum(uint _BTS, uint256 _tokenId) public view returns(uint256) { 
      if (tempAddresses.length == 1) return 0;
      uint256 num = uint(keccak256(abi.encodePacked(_BTS, _tokenId))) % tempAddresses.length;
      return num;
    }
    // return the initial allowance of a specific address
    function getAllowanceForAddress(address _ad) public view returns (uint) { 
        return addressToAllowance[_ad];
    }
    // remove an address from the array
    function remove(uint index) internal { 
        for (uint i = index; i<(tempAddresses.length-1); i++){
                tempAddresses[i] = tempAddresses[i+1];
                tempAllowance[i] = tempAllowance[i+1];
        }
        tempAddresses.pop();
        tempAllowance.pop();
    }
    // get the results of the picker
    function getResults() external view returns (result[9] memory){ 
        result[9] memory results;
        for (uint i;i<9;i++){
            results[i]._ad = Addresses[i];
            results[i].tokenIds = addressToTokenIds[Addresses[i]];
        }
        return results;
    }
    // return the hash used as seed
    function getUsedTimestamp () external view returns (uint){ 
        return blockTimeStamp;
    }
}
