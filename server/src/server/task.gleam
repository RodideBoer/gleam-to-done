import gleam/http
import wisp.{type Request, type Response}

// TODO Might decide to move task.gleam into task folder
//  This will help with getting all task code together
//  But importing will have task/task (which isn't a big deal I guess)

pub fn tasks(req: Request) -> Response {
  case req.method {
    http.Get -> list_tasks()
    http.Post -> create_task(req)
    _ -> wisp.method_not_allowed([http.Get, http.Post])
  }
}

pub fn task(req: Request, id: String) -> Response {
  case req.method {
    http.Get -> show_task(id)
    http.Patch -> update_task(req, id)
    http.Delete -> delete_task(req, id)
    _ -> wisp.method_not_allowed([http.Get, http.Patch, http.Delete])
  }
}

fn list_tasks() -> Response {
  wisp.ok()
  |> wisp.json_body("[]")
}

fn create_task(_req: Request) -> Response {
  wisp.created()
  |> wisp.json_body("{}")
}

fn show_task(id: String) -> Response {
  wisp.ok()
  |> wisp.json_body("{'id': " <> id <> "}")
}

fn update_task(_req: Request, id: String) -> Response {
  wisp.ok()
  |> wisp.json_body("{'id': " <> id <> "}")
}

fn delete_task(_req: Request, _id: String) -> Response {
  wisp.no_content()
}
