import api
import error.{type ApiError}
import gleam/dynamic/decode
import gleam/javascript/promise
import gleam/list
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import task.{type Task}

pub fn main() -> Nil {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

type Model {
  Model(tasks: Result(List(Task), ApiError), loading: Bool)
}

type Msg {
  ApiReturnedTasks(Result(List(Task), ApiError))
}

fn init(_flags) -> #(Model, Effect(Msg)) {
  #(Model(tasks: Ok([]), loading: True), fetch_tasks())
}

fn fetch_tasks() -> Effect(Msg) {
  use dispatch <- effect.from()
  api.get("/api/task", decode.list(task.task_decoder()))
  |> promise.map(ApiReturnedTasks)
  |> promise.tap(dispatch)
  Nil
}

fn update(_model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    ApiReturnedTasks(Ok(tasks)) -> #(
      Model(Ok(tasks), loading: False),
      effect.none(),
    )
    ApiReturnedTasks(Error(err)) -> #(
      Model(Error(err), loading: False),
      effect.none(),
    )
  }
}

fn view(model: Model) -> Element(Msg) {
  html.div([], [
    html.h1([], [element.text("Tasks")]),
    case model.tasks {
      Error(err) -> html.p([], [element.text(error.message(err))])
      Ok([]) if model.loading -> html.p([], [element.text("Loading...")])
      Ok([]) -> html.p([], [element.text("No tasks yet")])
      Ok(tasks) -> html.ul([], list.map(tasks, view_task))
    },
  ])
}

fn view_task(task: Task) -> Element(Msg) {
  html.li([], [
    html.input([
      attribute.type_("checkbox"),
      attribute.checked(task.completed),
      attribute.disabled(True),
    ]),
    element.text(task.title <> " — " <> task.description),
  ])
}
