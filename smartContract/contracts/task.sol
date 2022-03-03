// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.12;

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

    modifier onlyOwner(uint256 taskIndex) {
        require(
            tasks[taskIndex].wallet == msg.sender,
            "only owner of the task"
        );
        _;
    }

    modifier onlyValidIndex(uint256 taskIndex) {
        require(taskIndex < tasks.length, "not a valid index");
        require(!tasks[taskIndex].deleted, "task deleted");
        _;
    }

    function addTask(
        uint256 dateTimeStampInSeconds,
        string memory title,
        string memory description,
        uint256 priority
    ) external returns (uint256 index) {
        require(
            priority >= 1 && priority <= 3,
            "priority must be between 1 and 3"
        );
        TaskStruct memory task = TaskStruct({
            date: dateTimeStampInSeconds,
            title: title,
            description: description,
            wallet: msg.sender,
            status: TaskStatus.ToDo,
            priority: priority,
            deleted: false
        });
        tasks.push(task);
        index = tasks.length - 1;
        myTasks[msg.sender].push(index);

        emit AddTask(dateTimeStampInSeconds, title, description, priority);
    }

    function editTask(
        uint256 taskIndex,
        uint256 dateTimeStampInSeconds,
        string memory title,
        string memory description,
        uint256 priority
    ) external onlyValidIndex(taskIndex) onlyOwner(taskIndex) {
        require(
            priority >= 1 && priority <= 3,
            "priority must be between 1 and 3"
        );
        TaskStruct storage task = tasks[taskIndex];

        task.date = dateTimeStampInSeconds;
        task.title = title;
        task.description = description;
        task.priority = priority;

        emit EditTask(
            taskIndex,
            dateTimeStampInSeconds,
            title,
            description,
            priority
        );
    }

    function removeTask(uint256 taskIndex)
        external
        onlyValidIndex(taskIndex)
        onlyOwner(taskIndex)
    {
        tasks[taskIndex].deleted = true;
    }

    function setTaskAsComplete(uint256 taskIndex)
        external
        onlyValidIndex(taskIndex)
        onlyOwner(taskIndex)
    {
        TaskStruct storage task = tasks[taskIndex];
        task.status = TaskStatus.Complete;

        emit SetTaskAsComplete(taskIndex);
    }

    function getTask(uint256 taskIndex)
        external
        view
        onlyValidIndex(taskIndex)
        returns (
            uint256 date,
            string memory title,
            string memory description,
            address wallet,
            TaskStatus status,
            uint256 priority
        )
    {
        date = tasks[taskIndex].date;
        title = tasks[taskIndex].title;
        description = tasks[taskIndex].description;
        wallet = tasks[taskIndex].wallet;
        status = tasks[taskIndex].status;
        priority = tasks[taskIndex].priority;
    }

    function listMyTasks() external view returns (TaskStruct[] memory) {
        uint256 myTotalTasks = myTasks[msg.sender].length;
        uint256 totalValid = 0;

        for (uint256 i = 0; i < myTotalTasks; i++) {
            uint256 taskIndex = myTasks[msg.sender][i];
            if (!tasks[taskIndex].deleted) {
                totalValid++;
            }
        }

        TaskStruct[] memory _myTasks = new TaskStruct[](totalValid);
        uint256 count = 0;
        for (uint256 i = 0; i < myTotalTasks; i++) {
            uint256 taskIndex = myTasks[msg.sender][i];
            if (!tasks[taskIndex].deleted) {
                _myTasks[count] = tasks[taskIndex];
                count++;
            }
        }

        return _myTasks;
    }

    function listMyTodayTasks() external view returns (TaskStruct[] memory) {
        uint256 today = block.timestamp / 1 days;
        uint256 myTotalTasks = myTasks[msg.sender].length;
        uint256 totalValid = 0;

        for (uint256 i = 0; i < myTotalTasks; i++) {
            uint256 taskIndex = myTasks[msg.sender][i];
            uint256 taskDay = tasks[taskIndex].date / 1 days;
            if (!tasks[taskIndex].deleted && taskDay == today) {
                totalValid++;
            }
        }

        TaskStruct[] memory _myTasks = new TaskStruct[](totalValid);
        uint256 count = 0;
        for (uint256 i = 0; i < myTotalTasks; i++) {
            uint256 taskIndex = myTasks[msg.sender][i];
            uint256 taskDay = tasks[taskIndex].date / 1 days;
            if (!tasks[taskIndex].deleted && taskDay == today) {
                _myTasks[count] = tasks[taskIndex];
                count++;
            }
        }

        return _myTasks;
    }
}
