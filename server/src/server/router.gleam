import server/context.{type Context}
import server/task
import server/web
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    ["api", ..path] -> api(path, req, ctx)
    _ -> wisp.not_found()
  }
}

fn api(path: List(String), req: Request, ctx: Context) -> Response {
  case path {
    ["task"] -> task.tasks(req, ctx)
    ["task", id] -> task.task(req, ctx, id)
    _ -> wisp.not_found()
  }
}
