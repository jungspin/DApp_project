// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract MintAnimalToken is ERC721Enumerable {
    constructor() ERC721("pinAnimals", "HAS") {}

    // 1~5번까지 애니멀타입이 나온다.
    // 앞 256 : 애니멀토큰아이디 / 뒤 256 : 애니멀타입
    // 토큰아이디 입력 -> 애니멀타입 나옴 
    mapping(uint256 => uint256) public animalTypes;

    function mintAnimalToken () public {
        // animalTokenId : 우리 NFT가 가지는 유일한 값
        // totalSupply : 지금까지 발행된 NFT 양
        // 이 값이 유일해야 NFT (ERC721Enumerable.sol 제공)
        uint256 animalTokenId = totalSupply() + 1;

        // solidty 에서는 랜덤을 이렇게 뽑아낸다.
        uint256 animalType = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, animalTokenId))) % 5 + 1;

        animalTypes[animalTokenId] = animalType;

        // mint 하는 함수
        // msg.sender : 이 메세지를 실행한 사람. minting 누른 사람
        // animalTokenId : NFT 증명 토큰 아이디
        _mint(msg.sender, animalTokenId);
    }
}
