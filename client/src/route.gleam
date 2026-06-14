import gleam/uri.{type Uri}

pub const home_route = Tasks

pub type Route {
  Tasks
  NewTask
  NotFound(uri: Uri)
}

pub fn to_path(route: Route) -> String {
  case route {
    Tasks -> "/task"
    NewTask -> "/task/new"
    NotFound(_) -> "/404"
  }
}

pub fn from_uri(uri: Uri) -> Route {
  case uri.path_segments(uri.path) {
    ["task"] -> Tasks
    ["task", "new"] -> NewTask
    [] -> home_route
    _ -> NotFound(uri:)
  }
}
