import gleam/http
import server/context.{type Context}
import wisp.{type Request, type Response}

// TODO Might decide to move task.gleam into task folder
//  This will help with getting all task code together
//  But importing will have task/task (which isn't a big deal I guess)

pub fn tasks(req: Request, ctx: Context) -> Response {
  case req.method {
    http.Get -> list_tasks(ctx)
    http.Post -> create_task(req, ctx)
    _ -> wisp.method_not_allowed([http.Get, http.Post])
  }
}

pub fn task(req: Request, ctx: Context, id: String) -> Response {
  case req.method {
    http.Get -> show_task(req, ctx, id)
    http.Patch -> update_task(req, ctx, id)
    http.Delete -> delete_task(req, ctx, id)
    _ -> wisp.method_not_allowed([http.Get, http.Patch, http.Delete])
  }
}

fn list_tasks(_ctx: Context) -> Response {
  wisp.ok()
  |> wisp.json_body("[]")
}

fn create_task(_req: Request, _ctx: Context) -> Response {
  wisp.created()
  |> wisp.json_body("{}")
}

fn show_task(_req: Request, _ctx: Context, id: String) -> Response {
  wisp.ok()
  |> wisp.json_body("{'id': " <> id <> "}")
}

fn update_task(_req: Request, _ctx: Context, id: String) -> Response {
  wisp.ok()
  |> wisp.json_body("{'id': " <> id <> "}")
}

fn delete_task(_req: Request, _ctx: Context, _id: String) -> Response {
  wisp.no_content()
}
