import browser
import component/task_form.{UserUpdatedDescription, UserUpdatedTitle}
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
import task.{type Task, TaskInput}

pub type Model {
  Model(
    title: String,
    description: String,
    submitting: Bool,
    error: Option(String),
  )
}

pub type Msg {
  FormMsg(task_form.Msg)
  UserClickedBack
  UserSubmittedForm
  ApiCreatedTask(Result(Task, ApiError))
}

pub fn init() -> #(Model, Effect(Msg)) {
  #(
    Model(title: "", description: "", submitting: False, error: None),
    effect.none(),
  )
}

pub fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    FormMsg(UserUpdatedTitle(title)) -> #(Model(..model, title:), effect.none())
    FormMsg(UserUpdatedDescription(description)) -> #(
      Model(..model, description:),
      effect.none(),
    )
    FormMsg(task_form.UserUpdatedCompleted(_)) -> #(model, effect.none())
    UserClickedBack -> #(model, effect.from(fn(_) { browser.history_back() }))
    UserSubmittedForm ->
      case model.title {
        "" -> #(Model(..model, error: Some("Name is required")), effect.none())
        _ -> #(
          Model(..model, submitting: True, error: None),
          post_task(model.title, model.description),
        )
      }
    ApiCreatedTask(Ok(_)) -> #(
      model,
      modem.push(route.to_path(route.Tasks), None, None),
    )
    ApiCreatedTask(Error(error)) -> #(
      Model(..model, submitting: False, error: Some(error.message(error))),
      effect.none(),
    )
  }
}

fn post_task(title: String, description: String) -> Effect(Msg) {
  use dispatch <- effect.from()
  TaskInput(title:, description:, completed: False)
  |> task_service.post_task
  |> promise.map(ApiCreatedTask)
  |> promise.tap(dispatch)
  Nil
}

pub fn view(model: Model) -> Element(Msg) {
  html.div([], [
    html.h1([], [element.text("New Task")]),
    case model.error {
      None -> element.none()
      Some(error) -> html.p([], [element.text(error)])
    },
    element.map(task_form.view(model.title, model.description, None), FormMsg),
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
      html.button([event.on_click(UserClickedBack)], [element.text("Back")]),
    ]),
  ])
}
