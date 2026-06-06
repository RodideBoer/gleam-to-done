import gleam/option
import pog
import server/context
import test_config

const test_db_pool_name = "test_db_pool"

@external(erlang, "erlang", "binary_to_atom")
fn binary_to_atom(name: String) -> context.DbPoolName

pub fn db_pool_name() -> context.DbPoolName {
  binary_to_atom(test_db_pool_name)
}

pub fn start() -> context.DbPoolName {
  let config = test_config.load()
  let assert Ok(_) =
    db_pool_name()
    |> pog.default_config
    |> pog.host(config.db_host)
    |> pog.port(config.db_port)
    |> pog.database(config.db_name)
    |> pog.user(config.db_user)
    |> pog.password(option.Some(config.db_password))
    |> pog.start
  db_pool_name()
}

pub fn with_rollback(
  ctx: context.Context,
  next: fn(context.Context) -> Nil,
) -> Nil {
  let _ =
    pog.transaction(context.db_conn(ctx), fn(db_conn) {
      next(context.TestContext(config: ctx.config, db_conn:))
      Error("rollback")
    })
  Nil
}
