import gleam/json
import task

const task = task.Task(
  id: 42,
  title: "Do Gleam exercises",
  description: "Just do them",
  completed: False,
)

const task_input = task.TaskInput(
  title: "Do Gleam exercises",
  description: "Just do them",
  completed: False,
)

pub fn to_task_test() {
  assert task.to_task(task_input, 42) == task
}

pub fn to_task_input_test() {
  assert task.to_task_input(task) == task_input
}

pub fn task_to_json_test() {
  assert task
    |> task.task_to_json
    |> json.to_string
    |> json.parse(task.task_decoder())
    == Ok(task)
}

pub fn task_input_to_json_test() {
  assert task_input
    |> task.task_input_to_json
    |> json.to_string
    |> json.parse(task.task_input_decoder())
    == Ok(task_input)
}
