import gleam/option
import gleam/result
import gleam/uri.{type Uri}
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import modem
import page/not_found
import page/tasks
import route

pub type Page {
  TasksPage(tasks.Model)
}

pub type Msg {
  OnRouteChanged(route.Route)
  TasksPageSentMessage(tasks.Msg)
}

pub fn init(initial_uri: Result(Uri, Nil)) -> #(Page, Effect(Msg)) {
  initial_uri
  |> result.map(page_from_uri)
  |> result.unwrap(page_from_route(route.home_route))
}

pub fn update(page: Page, msg: Msg) -> #(Page, Effect(Msg)) {
  case page, msg {
    _, OnRouteChanged(route) -> page_from_route(route)
    TasksPage(model), TasksPageSentMessage(msg) -> {
      let #(model, effect) = tasks.update(model, msg)
      #(TasksPage(model), effect.map(effect, TasksPageSentMessage))
    }
  }
}

pub fn view(page: Page) -> Element(Msg) {
  case page {
    TasksPage(model) -> element.map(tasks.view(model), TasksPageSentMessage)
  }
}

pub fn on_url_change(uri: Uri) -> Msg {
  OnRouteChanged(route.from_uri(uri))
}

pub fn page_from_uri(uri: Uri) -> #(Page, Effect(Msg)) {
  let route = route.from_uri(uri)
  let #(page, effect) = page_from_route(route)
  let redirect = case uri.path_segments(uri.path) {
    [] -> modem.replace(route.to_path(route), option.None, option.None)
    _ -> effect.none()
  }
  #(page, effect.batch([effect, redirect]))
}

pub fn page_from_route(route: route.Route) -> #(Page, Effect(Msg)) {
  case route {
    route.Tasks -> {
      let #(model, effect) = tasks.init()
      #(TasksPage(model), effect.map(effect, TasksPageSentMessage))
    }
  }
}
