# Task Completion

At Visibuild, we help our customers complete large volumes of tasks out on their construction sites.

For this coding challenge we’re looking at the completion percentage of those tasks. Tasks have an ID (e.g. `task_001`), a status (either `open` or `closed`), and a parent task (`null` or the parent task’s ID).

Given the input, your program should should output the completion percentage (from 0 to 100 to 2 decimal places) of each task. The completion percentage of a task is calculated as the number of closed tasks in its subtree (including itself) divided by the total number of tasks in its subtree (including itself) as percentage.

To calculate a task's completion percentage:

1. Count all tasks in the task's subtree (the task itself plus all its descendants)
2. Count how many of those tasks are closed
3. Divide closed count by total count multiplied by 100

For example, if we had a structure of tasks like this:

```
task_001 [open]
├─ task_002 [open]
│  └─ task_003 [closed]
└─ task_004 [closed]
   └─ task_005 [closed]
```

The example input would be:

```json
[
  ["task_001", "open", null],
  ["task_002", "open", "task_001"],
  ["task_003", "closed", "task_002"],
  ["task_004", "closed", "task_001"],
  ["task_005", "closed", "task_004"]
]
```

And the expected output would be:

```json5
{
  "task_001": 60,  // 3 closed tasks / 5 total tasks
  "task_002": 50,  // 1 closed task  / 2 total tasks
  "task_003": 100, // 1 closed task  / 1 total task
  "task_004": 100, // 2 closed tasks / 2 total task
  "task_005": 100, // 1 closed task  / 1 total task
}
```
