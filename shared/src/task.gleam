import gleam/dynamic/decode
import gleam/json

pub type Task {
  Task(id: Int, title: String, description: String, completed: Bool)
}

pub fn task_decoder() -> decode.Decoder(Task) {
  use id <- decode.field("id", decode.int)
  use title <- decode.field("title", decode.string)
  use description <- decode.field("description", decode.string)
  use completed <- decode.optional_field("completed", False, decode.bool)
  decode.success(Task(id:, title:, description:, completed:))
}

pub fn task_to_json(task: Task) -> json.Json {
  let Task(id:, title:, description:, completed:) = task
  json.object([
    #("id", json.int(id)),
    #("title", json.string(title)),
    #("description", json.string(description)),
    #("completed", json.bool(completed)),
  ])
}

pub fn to_task_input(task: Task) -> TaskInput {
  TaskInput(task.title, task.description, task.completed)
}

pub type TaskInput {
  TaskInput(title: String, description: String, completed: Bool)
}

pub fn task_input_decoder() -> decode.Decoder(TaskInput) {
  use title <- decode.field("title", decode.string)
  use description <- decode.field("description", decode.string)
  use completed <- decode.optional_field("completed", False, decode.bool)
  decode.success(TaskInput(title:, description:, completed:))
}

pub fn task_input_to_json(task_input: TaskInput) -> json.Json {
  let TaskInput(title:, description:, completed:) = task_input
  json.object([
    #("title", json.string(title)),
    #("description", json.string(description)),
    #("completed", json.bool(completed)),
  ])
}

pub fn to_task(input: TaskInput, id: Int) -> Task {
  Task(
    id:,
    title: input.title,
    description: input.description,
    completed: input.completed,
  )
}
