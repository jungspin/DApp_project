// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "MintAnimalToken.sol";

contract SaleAnimalToken {
    MintAnimalToken public mintAnimalTokenAddress;

    constructor (address _mintAnimalTokenAddress) {
        mintAnimalTokenAddress = MintAnimalToken(_mintAnimalTokenAddress);
    }

    mapping(uint256 => uint256) public animalTokenPrices;

    // 프론트에서 어떤게 판매중인지 알기 위함
    uint256[] public onSaleAnimalTokenArray;

    /*
     * 판매 등록 함수
     */
    function setSaleAnimalToken(uint256 _animalTokenId, uint256 _price) public {
        address animalTokenOwner = mintAnimalTokenAddress.ownerOf(_animalTokenId);

        require(animalTokenOwner == msg.sender, "Caller is not animal token owner");
        require(_price > 0, "Price is zero or lower.");   
        require(animalTokenPrices[_animalTokenId] == 0, "This animal token is already on sale.");
        // 이 주인이 이 판매계약서에 이 판매권한을 넘겼는지
        require(mintAnimalTokenAddress.isApprovedForAll(animalTokenOwner, address(this)), "Animal token owner did not approve token.");

        animalTokenPrices[_animalTokenId] = _price;

        // 판매중이면 토큰 아이디를 해당 배열에 집어 넣음
        onSaleAnimalTokenArray.push(_animalTokenId);
    }

    // payable : 메틱이 왔다갔다 하는 함수를 실행할 수 있다
    function purchaseAnimalToken(uint256 _animalTokenId) public payable {
        uint256 price = animalTokenPrices[_animalTokenId];
        address animalTokenOwner = mintAnimalTokenAddress.ownerOf(_animalTokenId);

        require(price > 0, "Animal token not sale");
        require(price <= msg.value, "Caller sent lower than price.");
        require(animalTokenOwner != msg.sender, "Caller is animal token owner.");

        // msg.value 가 토큰 주인에게로 간다.
        payable(animalTokenOwner).transfer(msg.value);
        // 토큰 주인, 구매자, 토큰 아이디
        mintAnimalTokenAddress.safeTransferFrom(animalTokenOwner, msg.sender, _animalTokenId);
        animalTokenPrices[_animalTokenId] = 0;

        for (uint256 i = 0; i<onSaleAnimalTokenArray.length; i++) {
            if (animalTokenPrices[onSaleAnimalTokenArray[i]] == 0) {
                // 판매된 애를 제거해줄 것임
                // 맨뒤에 있던 친구를 0원 자리에 넣어주고 마지막 자리는 지워버림
                onSaleAnimalTokenArray[i] = onSaleAnimalTokenArray[onSaleAnimalTokenArray.length - 1];
                onSaleAnimalTokenArray.pop();
            }
        }
    }

    // 읽기 전용이기 때문에 view 
    function getOnSaleAnimalTokenArrayLength() view public returns (uint256) {
        return onSaleAnimalTokenArray.length;
    }
}