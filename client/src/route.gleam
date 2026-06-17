import gleam/int
import gleam/result
import gleam/uri.{type Uri}

pub const home_route = Tasks

pub type Route {
  Tasks
  NewTask
  EditTask(id: Int)
  NotFound(uri: Uri)
}

pub fn to_path(route: Route) -> String {
  case route {
    Tasks -> "/task"
    NewTask -> "/task/new"
    EditTask(id) -> "/task/" <> int.to_string(id) <> "/edit"
    NotFound(_) -> "/404"
  }
}

pub fn from_uri(uri: Uri) -> Route {
  case uri.path_segments(uri.path) {
    ["task"] -> Tasks
    ["task", "new"] -> NewTask
    ["task", id, "edit"] -> {
      int.parse(id)
      |> result.map(EditTask)
      |> result.unwrap(NotFound(uri:))
    }
    [] -> home_route
    _ -> NotFound(uri:)
  }
}
