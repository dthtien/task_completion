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

## Installation
### Requirements
- Ruby 3.4.4
- Bundler
OR
- Docker
### Setup
1. Clone the repository
   ```bash
   git clone git@github.com:dthtien/task_completion.git
    ```
2. Navigate to the project directory
    ```bash
    cd task_completion
    ```
3. Install dependencies
    ```bash
    bundle install
    ```
### Usage
To run the program with the sample test data in #https://github.com/visibuild/visibuild-coding-challenges/blob/master/task-completion/task-completion.data.md
```bash
rspec spec/task_integration_spec.rb
```
or using Docker:
```bash
docker build -t task_completion .
docker run -it --rm task_completion rspec spec/task_integration_spec.rb
```

To run the program with your own input data, create a JSON file (e.g., `input.json`) with the following format:
```json
[
  ["task_001", "open", null],
  ["task_002", "open", "task_001"],
  ["task_003", "closed", "task_002"],
  ["task_004", "closed", "task_001"],
  ["task_005", "closed", "task_004"]
]
```
or use the provided test data files in the `test_data` directory.
Then, execute the program using the command

```bash
ruby main.rb input.json
```

or using Docker:


```bash
docker run -it --rm -v $(pwd):/app task_completion ruby main.rb input.json
```

The output will be printed to the console in JSON format, showing the completion percentage for each task.

