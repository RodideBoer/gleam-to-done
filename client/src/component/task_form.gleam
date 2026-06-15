import gleam/option.{type Option, None, Some}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

pub type Msg {
  UserUpdatedTitle(String)
  UserUpdatedDescription(String)
  UserUpdatedCompleted(Bool)
}

pub fn view(
  title: String,
  description: String,
  completed: Option(Bool),
) -> Element(Msg) {
  html.div([], [
    html.div([], [
      html.label([], [element.text("Title")]),
      html.input([
        attribute.type_("text"),
        attribute.placeholder("Task title"),
        attribute.value(title),
        event.on_input(UserUpdatedTitle),
      ]),
    ]),
    html.div([], [
      html.label([], [element.text("Description")]),
      html.textarea(
        [
          attribute.placeholder("Optional description"),
          event.on_input(UserUpdatedDescription),
        ],
        description,
      ),
    ]),
    case completed {
      None -> element.none()
      Some(value) ->
        html.label([], [
          html.input([
            attribute.type_("checkbox"),
            attribute.checked(value),
            event.on_check(UserUpdatedCompleted),
          ]),
          element.text("Completed"),
        ])
    },
  ])
}
