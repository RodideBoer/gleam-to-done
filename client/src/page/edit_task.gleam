import browser
import component/task_form.{
  UserUpdatedCompleted, UserUpdatedDescription, UserUpdatedTitle,
}
import error.{type ApiError}
import gleam/javascript/promise
import gleam/option.{type Option, None, Some}
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import modem
import route
import service/task_service
import task.{type Task, Task}

pub type Model {
  Model(task: Task, loading: Bool, submitting: Bool, error: Option(String))
}

pub type Msg {
  FormMsg(task_form.Msg)
  UserSubmittedForm
  UserClickedDelete
  UserClickedBack
  ApiReturnedTask(Result(Task, ApiError))
  ApiUpdatedTask(Result(Task, ApiError))
  ApiDeletedTask(Result(Nil, ApiError))
}

pub fn init(id: Int) -> #(Model, Effect(Msg)) {
  #(
    Model(
      task: Task(id: id, title: "", description: "", completed: False),
      loading: True,
      submitting: False,
      error: None,
    ),
    fetch_task(id),
  )
}

pub fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    FormMsg(UserUpdatedTitle(title)) -> #(
      Model(..model, task: task.Task(..model.task, title:)),
      effect.none(),
    )
    FormMsg(UserUpdatedDescription(description)) -> #(
      Model(..model, task: task.Task(..model.task, description:)),
      effect.none(),
    )
    FormMsg(UserUpdatedCompleted(completed)) -> #(
      Model(..model, task: task.Task(..model.task, completed:)),
      effect.none(),
    )
    UserSubmittedForm ->
      case model.task.title {
        "" -> #(Model(..model, error: Some("Title is required")), effect.none())
        _ -> #(
          Model(..model, submitting: True, error: None),
          patch_task(model.task),
        )
      }
    UserClickedDelete -> #(
      Model(..model, submitting: True, error: None),
      delete_task(model.task.id),
    )
    UserClickedBack -> #(model, effect.from(fn(_) { browser.history_back() }))
    ApiReturnedTask(Ok(task)) -> #(
      Model(..model, task:, loading: False),
      effect.none(),
    )
    ApiReturnedTask(Error(error)) -> #(
      Model(..model, loading: False, error: Some(error.message(error))),
      effect.none(),
    )
    ApiUpdatedTask(Ok(_)) -> #(
      model,
      modem.push(route.to_path(route.Tasks), None, None),
    )
    ApiUpdatedTask(Error(error)) -> #(
      Model(..model, submitting: False, error: Some(error.message(error))),
      effect.none(),
    )
    ApiDeletedTask(Ok(_)) -> #(
      model,
      modem.push(route.to_path(route.Tasks), None, None),
    )
    ApiDeletedTask(Error(error)) -> #(
      Model(..model, submitting: False, error: Some(error.message(error))),
      effect.none(),
    )
  }
}

pub fn view(model: Model) -> Element(Msg) {
  case model.loading {
    True -> html.p([], [element.text("Loading...")])
    False ->
      html.div([], [
        html.h1([], [element.text("Edit task")]),
        case model.error {
          None -> element.none()
          Some(err) -> html.p([], [element.text(err)])
        },
        element.map(
          task_form.view(
            model.task.title,
            model.task.description,
            Some(model.task.completed),
          ),
          FormMsg,
        ),
        html.div([], [
          html.button(
            [
              attribute.disabled(model.submitting),
              event.on_click(UserSubmittedForm),
            ],
            [
              element.text(case model.submitting {
                True -> "Saving..."
                False -> "Save"
              }),
            ],
          ),
          html.button(
            [
              attribute.disabled(model.submitting),
              event.on_click(UserClickedDelete),
            ],
            [element.text("Delete")],
          ),
          html.button([event.on_click(UserClickedBack)], [element.text("Back")]),
        ]),
      ])
  }
}

fn fetch_task(id: Int) -> Effect(Msg) {
  use dispatch <- effect.from()
  id
  |> task_service.fetch_task
  |> promise.map(ApiReturnedTask)
  |> promise.tap(dispatch)
  Nil
}

fn patch_task(task: Task) -> Effect(Msg) {
  use dispatch <- effect.from()
  task
  |> task_service.patch_task
  |> promise.map(ApiUpdatedTask)
  |> promise.tap(dispatch)
  Nil
}

fn delete_task(id: Int) -> Effect(Msg) {
  use dispatch <- effect.from()
  id
  |> task_service.delete_task
  |> promise.map(ApiDeletedTask)
  |> promise.tap(dispatch)
  Nil
}
