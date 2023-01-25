// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./OpenZeppelin/Ownable.sol";

contract SharedWallet is Ownable {
    mapping(address => uint) members;

    function addLimitToMember(address _member, uint _limit) public onlyOwner {
        members[_member] = _limit;
    }

    function isOwner() internal view returns (bool) {
        return _msgSender() == owner();
    }

    modifier ownerOrWithinLimits(uint amount) {
        require(isOwner() || members[_msgSender()] >= amount, "Not allowed!");
        _;
    }

    function duduceFromLimit(uint _amount) internal {
        members[_msgSender()] -= _amount;
    }

    function renounceOwnership() public view override onlyOwner {
        revert("Can't renounce!");
    }
}
