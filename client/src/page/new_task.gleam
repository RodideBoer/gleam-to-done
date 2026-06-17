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
        "" -> #(Model(..model, error: Some("Title is required")), effect.none())
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
  html.div([attribute.class("min-h-screen bg-base-200")], [
    html.div([attribute.class("container p-4 mx-auto max-w-2xl")], [
      html.div([attribute.class("flex gap-2 items-center mb-6")], [
        html.button(
          [
            attribute.class("btn btn-ghost btn-sm btn-circle"),
            event.on_click(UserClickedBack),
          ],
          [
            html.span(
              [attribute.class("icon-[heroicons--arrow-left] size-5")],
              [],
            ),
          ],
        ),
        html.h1([attribute.class("text-2xl font-bold")], [
          element.text("New Task"),
        ]),
      ]),
      html.div([attribute.class("shadow card bg-base-100")], [
        html.div([attribute.class("card-body")], [
          case model.error {
            None -> element.none()
            Some(err) ->
              html.div([attribute.class("mb-4 alert alert-error")], [
                element.text(err),
              ])
          },
          task_form.view(model.title, model.description, None)
            |> element.map(FormMsg),
          html.div([attribute.class("flex gap-2 mt-6")], [
            html.button(
              [
                attribute.disabled(model.submitting),
                attribute.class("btn btn-primary"),
                event.on_click(UserSubmittedForm),
              ],
              [
                case model.submitting {
                  True ->
                    html.span(
                      [attribute.class("loading loading-spinner loading-sm")],
                      [],
                    )
                  False ->
                    html.span(
                      [
                        attribute.class(
                          "icon-[heroicons--document-check] size-5",
                        ),
                      ],
                      [],
                    )
                },
                element.text(case model.submitting {
                  True -> "Saving..."
                  False -> "Save"
                }),
              ],
            ),
          ]),
        ]),
      ]),
    ]),
  ])
}
