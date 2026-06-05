import gleam/http
import gleam/json
import server/context.{type Context}
import server/task/repository
import server/web
import task
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

fn list_tasks(ctx: Context) -> Response {
  let db = context.db_conn(ctx)
  use tasks <- web.require_ok(repository.all_tasks(db))
  tasks
  |> json.array(task.task_to_json)
  |> json.to_string
  |> wisp.json_body(wisp.ok(), _)
}

fn create_task(req: Request, ctx: Context) -> Response {
  let db = context.db_conn(ctx)
  use json <- wisp.require_json(req)
  use input <- web.decode_body(json, task.task_input_decoder())
  use task <- web.require_ok(repository.create_task(db, input))
  task
  |> task.task_to_json
  |> json.to_string
  |> wisp.json_body(wisp.created(), _)
}

fn show_task(_req: Request, ctx: Context, id: String) -> Response {
  let db = context.db_conn(ctx)
  use id <- web.require_int(id)
  use task <- web.require_ok(repository.get_task(db, id))
  task
  |> task.task_to_json
  |> json.to_string
  |> wisp.json_body(wisp.ok(), _)
}

fn update_task(req: Request, ctx: Context, id: String) -> Response {
  let db = context.db_conn(ctx)
  use id <- web.require_int(id)
  use json <- wisp.require_json(req)
  use input <- web.decode_body(json, task.task_input_decoder())
  let task = task.to_task(input, id)
  use task <- web.require_ok(repository.update_task(db, task))
  task
  |> task.task_to_json
  |> json.to_string
  |> wisp.json_body(wisp.ok(), _)
}

fn delete_task(_req: Request, ctx: Context, id: String) -> Response {
  let db = context.db_conn(ctx)
  use id <- web.require_int(id)
  use _ <- web.require_ok(repository.delete_task(db, id))
  wisp.no_content()
}
