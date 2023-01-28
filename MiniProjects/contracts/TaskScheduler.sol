// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./OpenZeppelin/Ownable.sol";

contract TaskScheduler is Ownable {
    address internal admin;

    struct Task {
        address executor;
        TaskStatus status;
        uint256 cost;
        bool isConfirmedFromExecutor;
        bool isConfirmedFromAdmin;
    }

    enum TaskStatus {
        ToDo,
        InDev,
        Done
    }

    modifier onlyAdmin() {
        require(isAdmin(), "Forbidden");
        _;
    }

    modifier onlyExecutor(uint256 _taskId) {
        require(isExecutor(_taskId), "Available only to the executor");
        _;
    }

    uint256 internal borrowedFunds;
    uint256 internal latestTaskId;

    mapping(uint256 => Task) internal tasks;

    function sendMoney() public payable {
        payable(address(this)).transfer(msg.value);
    }

    fallback() external payable {}

    receive() external payable {}

    function getTaskById(uint256 _taskId)
        public
        view
        onlyAdmin
        returns (Task memory)
    {
        return tasks[_taskId];
    }

    function setAdmin(address _addressAdmin) public onlyOwner {
        admin = _addressAdmin;
    }

    function addTask(uint256 _cost) public returns (uint256) {
        Task memory task = Task({
            cost: _cost,
            status: TaskStatus.ToDo,
            executor: admin,
            isConfirmedFromAdmin: false,
            isConfirmedFromExecutor: false
        });

        tasks[latestTaskId] = task;
        latestTaskId++;
        return latestTaskId;
    }

    function setExecutor(uint256 _taskId, address _executor) public onlyAdmin {
        tasks[_taskId].executor = _executor;
    }

    function startTask(uint256 _taskId) public onlyExecutor(_taskId) {
        Task storage task = tasks[_taskId];
        addBorrowedFunds(task.cost);
        task.status = TaskStatus.InDev;
    }

    function finishTask(uint256 _taskId) public onlyExecutorOrAdmin(_taskId) {
        Task storage task = tasks[_taskId];
        if (isAdmin()) {
            task.isConfirmedFromAdmin = true;
        } else {
            task.isConfirmedFromExecutor = true;
        }

        if (task.isConfirmedFromAdmin && task.isConfirmedFromExecutor) {
            address payable _to = payable(task.executor);
            _to.transfer(task.cost);
            borrowedFunds -= task.cost;
            task.status = TaskStatus.Done;
        }
    }

    function getBalance() public view onlyAdmin returns (uint256) {
        return address(this).balance;
    }

    modifier onlyExecutorOrAdmin(uint256 _taskId) {
        require(
            isAdmin() || isExecutor(_taskId),
            "Ownable: caller is not the owner"
        );
        _;
    }

    function isAdmin() internal view returns (bool) {
        return _msgSender() == admin;
    }

    function isExecutor(uint256 _taskId) internal view returns (bool) {
        return _msgSender() == tasks[_taskId].executor;
    }

    function addBorrowedFunds(uint256 _funds) internal {
        uint256 sum = _funds + borrowedFunds;
        require(
            address(this).balance >= sum,
            "Insufficient funds for future payment"
        );

        borrowedFunds = sum;
    }
}
