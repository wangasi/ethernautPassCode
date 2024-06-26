// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Privacy {
    bool public locked = true;
    uint256 public ID = block.timestamp;
    uint8 private flattening = 10;
    uint8 private denomination = 255;
    uint16 private awkwardness = uint16(block.timestamp);
    bytes32[3] private data;

    constructor(bytes32[3] memory _data) {
        data = _data;
    }

    function unlock(bytes16 _key) public {
        require(_key == bytes16(data[2]));
        locked = false;
    }

    /*
    A bunch of super advanced solidity algorithms...

      ,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`
      .,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,
      *.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^         ,---/V\
      `*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.    ~|__(o.o)
      ^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'  UU  UU
    */
}

/**
1、flattening 8bytes, denomination 8bytes, awkwardness 16bytes, 加在一起32bytes，存储在storage[2]
2、data[2]存储在storage[5]
    await web3.eth.getStorageAt("0x3fb959C4201912a1e6E108B255C6c350A5B9c2bC", 0)
    '0x0000000000000000000000000000000000000000000000000000000000000001'
    await web3.eth.getStorageAt("0x3fb959C4201912a1e6E108B255C6c350A5B9c2bC", 1)
    '0x00000000000000000000000000000000000000000000000000000000665bf7e8'
    await web3.eth.getStorageAt("0x3fb959C4201912a1e6E108B255C6c350A5B9c2bC", 2)
    '0x00000000000000000000000000000000000000000000000000000000f7e8ff0a'
    await web3.eth.getStorageAt("0x3fb959C4201912a1e6E108B255C6c350A5B9c2bC", 3)
    '0xe2d57ec49aac94d0e7d5a0d31936bae0a2ee814ce375b1d4065be82c1ca73616'
    await web3.eth.getStorageAt("0x3fb959C4201912a1e6E108B255C6c350A5B9c2bC", 4)
    '0xb2a167198a96f6b0d0f7f1aec05241de0b0ddf0fb1394213846f1937ab7d63bb'
    await web3.eth.getStorageAt("0x3fb959C4201912a1e6E108B255C6c350A5B9c2bC", 5)
    '0xc0cc4eb1618f4cfa9a53c6d1f66b9a1d515b38218e8bf130801d8d2727a8c364'
3、bytes16(data[2])从0xc0cc4eb1618f4cfa9a53c6d1f66b9a1d515b38218e8bf130801d8d2727a8c364高位开始数16bytes，即一半，
0xc0cc4eb1618f4cfa9a53c6d1f66b9a1d
 */
