import server/task
import server/web
import wisp.{type Request, type Response}

pub fn handle_request(req: Request) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    ["api", ..path] -> api(req, path)
    _ -> wisp.not_found()
  }
}

fn api(req: Request, path: List(String)) -> Response {
  case path {
    ["task"] -> task.tasks(req)
    ["task", id] -> task.task(req, id)
    _ -> wisp.not_found()
  }
}
