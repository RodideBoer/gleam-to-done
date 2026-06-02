pub type Task {
  Task(id: Int, title: String, description: String, completed: Bool)
}

pub fn to_task_input(task: Task) -> TaskInput {
  TaskInput(task.title, task.description, task.completed)
}

pub type TaskInput {
  TaskInput(title: String, description: String, completed: Bool)
}

pub fn to_task(input: TaskInput, id: Int) -> Task {
  Task(
    id:,
    title: input.title,
    description: input.description,
    completed: input.completed,
  )
}
