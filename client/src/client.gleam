import lustre
import lustre/element
import lustre/element/html
import lustre/event

pub fn main() -> Nil {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

type Model {
  Model(name: String, greeting: String, toggle: Bool)
}

type Msg {
  UserChangedName(name: String)
  UserClickedToggle
}

fn init(_flags) -> Model {
  Model(name: "", greeting: "", toggle: False)
}

fn update(model: Model, msg: Msg) -> Model {
  case msg {
    UserChangedName(name:) ->
      Model(..model, name:, greeting: "Hello " <> name <> "!")
    UserClickedToggle -> Model(..model, toggle: !model.toggle)
  }
}

fn view(model: Model) -> element.Element(Msg) {
  let greeting = html.p([], [html.text(model.greeting)])
  let greeting = case model.toggle {
    True -> html.strong([], [greeting])
    False -> greeting
  }
  html.div([], [
    html.input([event.on_input(UserChangedName)]),
    html.button([event.on_click(UserClickedToggle)], [html.text("Toggle")]),
    greeting,
  ])
}
