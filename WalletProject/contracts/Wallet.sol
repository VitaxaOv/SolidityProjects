// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./SharedWallet.sol";

contract Wallet is SharedWallet {
    event MoneyWithdrawn(address indexed _to, uint256 _amount);
    event MoneyReceived(address indexed _from, uint256 _amount);

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function sendMoney() public payable {
        payable(this).transfer(msg.value);
        emit MoneyReceived(_msgSender(), msg.value);
    }

    function withdrawalMoney(uint256 _amount)
        public
        ownerOrWithinLimits(_amount)
    {
        require(
            address(this).balance >= _amount,
            "Not enough money in the wallet"
        );
        if (!isOwner()) {
            duduceFromLimit(_amount);
        }
        address payable _to = payable(_msgSender());
        _to.transfer(_amount);

        emit MoneyWithdrawn(_to, _amount);
    }

    fallback() external payable {}

    receive() external payable {
        emit MoneyReceived(_msgSender(), msg.value);
    }
}
