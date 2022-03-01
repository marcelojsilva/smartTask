// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Task {
    enum TaskStatus {
        ToDo,
        InProgress,
        Done,
        Canceled
    }

    struct TaskStruct {
        int256 date;
        string title;
        string description;
        address wallet;
        TaskStatus status;
        uint256 priority;
    }

    TaskStruct[] private tasks;

    mapping(address=>uint256[]) public myTasks;
}
