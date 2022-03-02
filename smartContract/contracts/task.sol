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
        bool deleted;
    }

    TaskStruct[] internal tasks;

    mapping(address => uint256[]) internal myTasks;

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
        require(tasks[_taskIndex].deleted == false, "task deleted");
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
            priority: _priority,
            deleted: false
        });
        tasks.push(_task);
        index = tasks.length - 1;
        myTasks[msg.sender].push(index);

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

    function removeTask(uint256 _taskIndex) external onlyValidIndex(_taskIndex) onlyOwner(_taskIndex) {
        tasks[_taskIndex].deleted = true;
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

    function listMyTasks() external view returns (TaskStruct[] memory) {
        uint256 myTotalTasks = myTasks[msg.sender].length;
        uint256 totalValid;
        
        for (uint i = 0; i < myTotalTasks; i++) {
            uint256 _taskIndex = myTasks[msg.sender][i];
            if (!tasks[_taskIndex].deleted) {
                totalValid++;
            }
        }

        TaskStruct[] memory _myTasks = new TaskStruct[](totalValid);
        uint256 count;
        for (uint i = 0; i < myTotalTasks; i++) {
            uint256 _taskIndex = myTasks[msg.sender][i];
            if (!tasks[_taskIndex].deleted) {
                _myTasks[count] = tasks[_taskIndex];
                count++;
            }
        }

        return _myTasks;
    }

    function listMyTodayTasks() external view returns (TaskStruct[] memory) {
        uint256 today = block.timestamp / 1 days;
        uint256 myTotalTasks = myTasks[msg.sender].length;
        uint256 totalValid;
        
        for (uint i = 0; i < myTotalTasks; i++) {
            uint256 _taskIndex = myTasks[msg.sender][i];
            uint256 taskDay = tasks[_taskIndex].date / 1 days;
            if (!tasks[_taskIndex].deleted  && taskDay == today) {
                totalValid++;
            }
        }

        TaskStruct[] memory _myTasks = new TaskStruct[](totalValid);
        uint256 count;
        for (uint i = 0; i < myTotalTasks; i++) {
            uint256 _taskIndex = myTasks[msg.sender][i];
            uint256 taskDay = tasks[_taskIndex].date / 1 days;
            if (!tasks[_taskIndex].deleted  && taskDay == today) {
                _myTasks[count] = tasks[_taskIndex];
                count++;
            }
        }

        return _myTasks;
    }
}
