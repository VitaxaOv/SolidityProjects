// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./OpenZeppelin/Ownable.sol";

contract SharedWallet is Ownable {
    event ChangeLimitForMember(
        address indexed _member,
        uint256 _prevLimit,
        uint256 _currentLimit
    );

    struct Member {
        string name;
        uint256 limit;
        bool isAdmin;
    }

    mapping(address => Member) public members;

    function addToMembers(address _memberAddress, uint256 _limit)
        internal
        returns (Member storage)
    {
        Member storage member = members[_memberAddress];
        member.limit = _limit;
        return member;
    }

    function changeLimitForMember(address _memberAddress, uint256 _limit)
        public
        onlyOwner
    {
        Member memory member = addToMembers(_memberAddress, _limit);

        emit ChangeLimitForMember(_memberAddress, member.limit, _limit);
    }

    function revokeAdmin(address _memberAddress) public onlyOwner {
        Member storage member = members[_memberAddress];
        member.isAdmin = false;
    }

    function makeAdmin(address _memberAddress) public onlyOwner {
        Member storage member = members[_memberAddress];
        member.isAdmin = true;
    }

    function removeMember(address _memberToDelete) public onlyOwner {
        delete members[_memberToDelete];
    }

    function isAdmin() internal view returns (bool) {
        return members[_msgSender()].isAdmin;
    }

    function isOwner() internal view returns (bool) {
        return _msgSender() == owner();
    }

    modifier ownerOrWithinLimits(uint256 _amount) {
        require(
            isOwner() ||
                members[_msgSender()].isAdmin ||
                members[_msgSender()].limit >= _amount,
            "Not allowed!"
        );
        _;
    }

    function duduceFromLimit(uint256 _amount) internal {
        members[_msgSender()].limit -= _amount;
    }

    function renounceOwnership() public view override onlyOwner {
        revert("Can't renounce!");
    }
}
