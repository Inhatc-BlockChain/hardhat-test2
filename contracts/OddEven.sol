// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// 홀짝 게임: 0.001 ETH를 걸고 홀/짝 선택 → 컨트랙트가 1~100 숫자를 뽑음 → 맞추면 0.002 ETH
// 만든 사람이 상금 준비금을 넣어 둠
contract OddEven {
    address public owner;
    uint256 public constant BET = 0.001 ether;

    event Played(address indexed player, bool pickOdd, uint256 number, bool win);

    constructor() payable {
        owner = msg.sender;
    }

    function play(bool pickOdd) external payable {
        require(msg.value == BET, "send 0.001 ETH");
        require(address(this).balance >= 2 * BET, "not enough prize money");

        // 블록 정보로 만든 "가짜 랜덤" → 예측할 수 있음 (생각해 보기)
        uint256 number = uint256(
            keccak256(abi.encodePacked(block.prevrandao, block.timestamp, msg.sender))
        ) % 100 + 1;
        bool win = (number % 2 == 1) == pickOdd;
        emit Played(msg.sender, pickOdd, number, win);

        if (win) {
            (bool ok, ) = payable(msg.sender).call{value: 2 * BET}("");
            require(ok, "transfer failed");
        }
    }

    function withdraw() external {
        require(msg.sender == owner, "only owner");
        (bool ok, ) = payable(owner).call{value: address(this).balance}("");
        require(ok, "transfer failed");
    }

    // 준비금 추가
    receive() external payable {}
}
