const { expect } = require('chai');

describe('Prepare tasks', async() => {
    let task, TaskContract, owner, Alice, Bob, Carol, addrs;
    const oneDay = 60 * 60 * 24;

    beforeEach(async() => {
        [owner, Alice, Bob, Carol, ...addrs] = await ethers.getSigners();
        TaskContract = await ethers.getContractFactory('Task');
        task = await TaskContract.deploy();
    });


    it('Create tasks to Alice and Bob', async() => {
        await task.connect(Alice).addTask(
            parseInt(Date.now() / 1000),
            'Title task 1 Alice',
            'Description task 1 from Alice',
            1
        );

        await task.connect(Alice).addTask(
            parseInt(Date.now() / 1000 + oneDay),
            'Title task 2 Alice',
            'Description task 2 from Alice',
            1
        );

        await task.connect(Bob).addTask(
            parseInt(Date.now() / 1000 + oneDay),
            'Title task 1 Bob',
            'Description task 1 from Bob',
            1
        );

        await task.connect(Bob).addTask(
            parseInt(Date.now() / 1000 + oneDay),
            'Title task 2 Bob',
            'Description task 2 from Bob',
            1
        );

        await task.connect(Bob).addTask(
            parseInt(Date.now() / 1000 + oneDay),
            'Title task 3 Bob',
            'Description task 3 from Bob',
            1
        );

        describe('Validate Tasks', async() => {
            it('Remove last task from Bob', async() => {
                await task.connect(Bob).removeTask(4);
                await expect(task.getTask(4)).to.be.revertedWith('task deleted');
            });

            it('Check invalid priority', async() => {
                await expect(task.connect(Alice).addTask(
                    parseInt(Date.now() / 1000),
                    'Title task 3 Alice',
                    'Description task 3 from Alice',
                    10
                )).to.be.revertedWith('priority must be between 1 and 3');
            });

            it('Validate title task', async() => {
                [date, title, description, wallet, status, priority] =
                await task.getTask(0);
                expect(title).to.be.equal('Title task 1 Alice');
            });

            it('Validate total tasks of Alice', async() => {
                AliceTasks = await task.connect(Alice).listMyTasks();
                expect(AliceTasks.length).to.be.equal(2);
            });

            it('Validate total tasks from day of Alice', async() => {
                AliceTasks = await task.connect(Alice).listMyTodayTasks();
                expect(AliceTasks.length).to.be.equal(1);
            });

            it('Validate total tasks at next day of Bob', async() => {
                await ethers.provider.send('evm_increaseTime', [oneDay]);
                await ethers.provider.send("evm_mine");
                BobTasks = await task.connect(Bob).listMyTodayTasks();
                expect(BobTasks.length).to.be.equal(2);
            });

            it('Check invalid priority in edit task', async() => {
                await expect(task.connect(Alice).editTask(
                    0,
                    parseInt(Date.now() / 1000),
                    'Title task 3 Alice',
                    'Description task 3 from Alice',
                    10
                )).to.be.revertedWith('priority must be between 1 and 3');
            });

            it('Check invalid owner in edit task', async() => {
                await expect(task.connect(Bob).editTask(
                    0,
                    parseInt(Date.now() / 1000),
                    'Title task 3 Alice',
                    'Description task 3 from Alice',
                    2
                )).to.be.revertedWith('only owner of the task');
            });

            it('Check invalid index in edit task', async() => {
                await expect(task.connect(Alice).editTask(
                    10,
                    parseInt(Date.now() / 1000),
                    'Title task 3 Alice',
                    'Description task 3 from Alice',
                    2
                )).to.be.revertedWith('not a valid index');
            });

            it('Validate priority change in edit task', async() => {
                await task.connect(Alice).editTask(
                    0,
                    parseInt(Date.now() / 1000),
                    'Title task 3 Alice',
                    'Description task 3 from Alice',
                    2
                );
                [date, title, description, wallet, status, priority] =
                await task.getTask(0);
                expect(priority).to.be.equal(2);
            });

            it('Validate date change in edit task', async() => {
                await task.connect(Bob).editTask(
                    2,
                    parseInt(Date.now() / 1000),
                    'Title task 1 Bob',
                    'Description task 1 from Bob',
                    1
                );
                [date, title, description, wallet, status, priority] =
                BobTasks = await task.connect(Bob).listMyTodayTasks();
                expect(BobTasks.length).to.be.equal(1);

                await task.connect(Bob).editTask(
                    3,
                    parseInt(Date.now() / 1000),
                    'Title task 1 Bob',
                    'Description task 1 from Bob',
                    1
                );
                [date, title, description, wallet, status, priority] =
                BobTasks = await task.connect(Bob).listMyTodayTasks();
                expect(BobTasks.length).to.be.equal(0);
            });

            it('Validate set task as complete', async() => {
                await task.connect(Alice).setTaskAsComplete(0);
                [date, title, description, wallet, status, priority] =
                await task.getTask(0);
                expect(status).to.be.equal(1);
            });
        });
    });
});