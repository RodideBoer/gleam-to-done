import gleam/uri.{type Uri}
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html

pub type Model {
  Model(uri: Uri)
}

pub fn init(uri: Uri) -> #(Model, Effect(message)) {
  #(Model(uri:), effect.none())
}

pub fn update(model: Model, _msg: message) -> #(Model, Effect(message)) {
  #(model, effect.none())
}

pub fn view(model: Model) -> Element(message) {
  html.div([], [
    html.h1([], [element.text("Not found")]),
    html.p([], [html.text(uri.to_string(model.uri) <> " was not found.")]),
  ])
}
