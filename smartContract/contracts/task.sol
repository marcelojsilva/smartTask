// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Task {
    enum TaskStatus {
        ToDo,
        Complete
    }

    struct TaskStruct {
        uint256 date;
        string title;
        string description;
        address wallet;
        TaskStatus status;
        uint256 priority;
    }

    TaskStruct[] private tasks;

    mapping(address => uint256[]) private myTasks;
    mapping(uint256 => mapping(address => uint256[])) private myDayTasks;

    event AddTask(
        uint256 dateTimeStampInSeconds,
        string title,
        string description,
        uint256 priority
    );

    event EditTask(
        uint256 taskIndex,
        uint256 dateTimeStampInSeconds,
        string title,
        string description,
        uint256 priority
    );

    event SetTaskAsComplete(uint256 taskIndex);

    modifier onlyOwner(uint256 _taskIndex) {
        require(
            tasks[_taskIndex].wallet == msg.sender,
            "only owner of the task"
        );
        _;
    }

    modifier onlyValidIndex(uint256 _taskIndex) {
        require(_taskIndex < tasks.length, "not a valid index");
        _;
    }

    function addTask(
        uint256 _dateTimeStampInSeconds,
        string memory _title,
        string memory _description,
        uint256 _priority
    ) external returns (uint256 index) {
        require(
            _priority >= 1 && _priority <= 3,
            "priority must be between 1 and 3"
        );
        TaskStruct memory _task = TaskStruct({
            date: _dateTimeStampInSeconds,
            title: _title,
            description: _description,
            wallet: msg.sender,
            status: TaskStatus.ToDo,
            priority: _priority
        });
        tasks.push(_task);
        index = tasks.length - 1;
        myTasks[msg.sender].push(index);
        uint256 day = _dateTimeStampInSeconds / 1 days;
        myDayTasks[day][msg.sender].push(index);

        emit AddTask(_dateTimeStampInSeconds, _title, _description, _priority);
    }

    function editTask(
        uint256 _taskIndex,
        uint256 _dateTimeStampInSeconds,
        string memory _title,
        string memory _description,
        uint256 _priority
    ) external onlyValidIndex(_taskIndex) onlyOwner(_taskIndex) {
        require(
            _priority >= 1 && _priority <= 3,
            "priority must be between 1 and 3"
        );
        TaskStruct storage task = tasks[_taskIndex];

        uint256 dayFrom = task.date / 1 days;
        uint256 dayTo = _dateTimeStampInSeconds / 1 days;
        if (dayFrom != dayTo) {
            changeMyDayTask(_taskIndex, dayFrom, dayTo);
        }

        task.date = _dateTimeStampInSeconds;
        task.title = _title;
        task.description = _description;
        task.priority = _priority;

        emit EditTask(
            _taskIndex,
            _dateTimeStampInSeconds,
            _title,
            _description,
            _priority
        );
    }

    function setTaskAsComplete(uint256 _taskIndex)
        external
        onlyValidIndex(_taskIndex)
        onlyOwner(_taskIndex)
    {
        TaskStruct storage task = tasks[_taskIndex];
        task.status = TaskStatus.Complete;

        emit SetTaskAsComplete(_taskIndex);
    }

    function getTask(uint256 _taskIndex)
        external
        view
        onlyValidIndex(_taskIndex)
        returns (
            uint256 date,
            string memory title,
            string memory description,
            address wallet,
            TaskStatus status,
            uint256 priority
        )
    {
        date = tasks[_taskIndex].date;
        title = tasks[_taskIndex].title;
        description = tasks[_taskIndex].description;
        wallet = tasks[_taskIndex].wallet;
        status = tasks[_taskIndex].status;
        priority = tasks[_taskIndex].priority;
    }

    function listMyTasks() external view returns (uint256[] memory) {
        return myTasks[msg.sender];
    }

    function listMyDayTasks() external view returns (uint256[] memory) {
        uint256 today = block.timestamp / 1 days;
        return myDayTasks[today][msg.sender];
    }

    function changeMyDayTask(
        uint256 _taskIndex,
        uint256 dayFrom,
        uint256 dayTo
    ) internal {
        uint256 _startIndex;
        for (uint256 i = 0; i < myDayTasks[dayFrom][msg.sender].length; i++) {
            if (myDayTasks[dayFrom][msg.sender][i] == _taskIndex) {
                _startIndex = i;
                break;
            }
        }

        for (
            uint256 i = _startIndex;
            i < myDayTasks[dayFrom][msg.sender].length - 1;
            i++
        ) {
            myDayTasks[dayFrom][msg.sender][i] = myDayTasks[dayFrom][
                msg.sender
            ][i + 1];
        }
        myDayTasks[dayFrom][msg.sender].pop();
        myDayTasks[dayTo][msg.sender].push(_taskIndex);
    }
}
