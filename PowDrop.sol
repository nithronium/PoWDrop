//SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

contract PoWDrop {

    address private _owner;
    uint private _depositAmount;
    uint private _airdropAmount;
    bytes32 private _salt;
    uint8 private _minDiff;
    mapping(address => mapping(uint => bool)) _nonces;

    constructor(uint depositAmount, uint airdropAmount, bytes32 salt, uint8 minDiff) {
        _owner = msg.sender;
        _depositAmount = depositAmount;
        _airdropAmount = airdropAmount;
        _salt = salt;
        _minDiff = minDiff;
    }

    function depositAsset() public payable {
        require(msg.sender == _owner,"not owner");
    }

    function claimPoWDrop(uint nonce) public payable {
        require(msg.value == _depositAmount,"invalid amount");
        _verifyPoW(nonce);
        _nonces[msg.sender][nonce] = true;
        payable(msg.sender).transfer(_airdropAmount);
    }

    function _verifyPoW(uint nonce) public view returns (bool) {
        require(!_nonces[msg.sender][nonce],"Nonce already used");
        bytes32 myPack = calculatePoW(msg.sender,_salt,nonce);
        for(uint8 i=0; i<_minDiff; i++) {
            require(myPack[i] == 0,"Invalid hash");
        }
        return true;
    }

    function calculatePoW(address user, bytes32 salt, uint nonce) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(user,salt,nonce));
    }

    function calculatePoWValid(address user, bytes32 salt) public view returns (uint) {
        for(uint8 i=0; i<1000; i++) {
            bytes32 calculatedPoW = calculatePoW(user,salt,i);
            if(calculatedPoW[0] == 0) {
                return i;
            }
        }
    }

}
