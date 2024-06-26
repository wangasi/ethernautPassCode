// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MagicNum {
    address public solver;

    constructor() {}

    function setSolver(address _solver) public {
        solver = _solver;
    }

    /*
    ____________/\\\_______/\\\\\\\\\_____        
     __________/\\\\\_____/\\\///////\\\___       
      ________/\\\/\\\____\///______\//\\\__      
       ______/\\\/\/\\\______________/\\\/___     
        ____/\\\/__\/\\\___________/\\\//_____    
         __/\\\\\\\\\\\\\\\\_____/\\\//________   
          _\///////////\\\//____/\\\/___________  
           ___________\/\\\_____/\\\\\\\\\\\\\\\_ 
            ___________\///_____\///////////////__
    */
}

/**

opcode:
PUSH1	0x0a
PUSH1	0x0c
PUSH1   0x00
CODECOPY

PUSH1 0x0a
PUSH1 0x0c
PUSH1 0x00
CODECOPY	
PUSH1	0x0a
PUSH1	0x00
RETURN

PUSH1 0x2a
PUSH0
MSTORE
PUSH1 0x20
PUSH0
RETURN

bytecode:
600a600c600039600a6000f3602a5f5260205ff3

let bytecode = "600a600c600039600a6000f3602a5f5260205ff3"
let txn = await web3.eth.sendTransaction({from: player, data: bytecode})
await contract.setSolver(txn.contractAddress)
*/