import gleam/dynamic
import gleam/dynamic/decode
import gleam/json
import server/db
import task
import wisp

pub fn middleware(
  req: wisp.Request,
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  //todo authenticate and handle static?
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes()
  use req <- wisp.handle_head(req)
  handle_request(req)
}

pub fn map_result(
  result: Result(a, db.DatabaseError),
  next: fn(a) -> wisp.Response,
) -> wisp.Response {
  case result {
    Ok(value) -> next(value)
    Error(db.RecordNotFound) -> wisp.not_found()
    _ -> wisp.internal_server_error()
  }
}

pub fn decode_body(
  body: dynamic.Dynamic,
  decoder: decode.Decoder(a),
  next: fn(a) -> wisp.Response,
) -> wisp.Response {
  case decode.run(body, decoder) {
    Ok(value) -> next(value)
    _ -> wisp.unprocessable_content()
  }
}
