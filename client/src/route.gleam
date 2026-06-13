import gleam/uri.{type Uri}

pub const home_route = Tasks

pub type Route {
  Tasks
  NotFound(uri: Uri)
}

pub fn to_path(route: Route) -> String {
  case route {
    Tasks -> "/task"
    NotFound(_) -> "/404"
  }
}

pub fn from_uri(uri: Uri) -> Route {
  case uri.path_segments(uri.path) {
    ["task"] -> Tasks
    [] -> home_route
    _ -> NotFound(uri:)
  }
}
