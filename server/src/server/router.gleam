import server/web
import server/web/task
import wisp.{type Request, type Response}

pub fn handle_request(req: Request) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    ["task"] -> task.all(req)
    ["task", id] -> task.one(req, id)
    _ -> wisp.not_found()
  }
}
