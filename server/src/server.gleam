import gleam/erlang/process
import mist
import server/config
import server/context
import server/db
import server/router
import wisp
import wisp/wisp_mist

pub fn main() -> Nil {
  let config = config.load()
  let db_pool_name = db.start(config)
  let context = context.Context(config:, db_pool_name:)

  wisp.configure_logger()

  let assert Ok(_) =
    // wisp_mist.handler(router.handle_request(_, context), secret_key_base)
    router.handle_request(_, context)
    |> wisp_mist.handler(config.secret_key_base)
    |> mist.new()
    |> mist.bind(config.server_host)
    |> mist.port(config.server_port)
    |> mist.start()

  process.sleep_forever()
}
