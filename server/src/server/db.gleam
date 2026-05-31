import gleam/erlang/process
import gleam/option
import gleam/otp/static_supervisor
import pog
import server/config
import server/context

pub fn start(config: config.Config) -> context.DbPoolName {
  let db_pool_name = process.new_name("db")
  let db_pool =
    db_pool_name
    |> pog.default_config
    |> pog.host(config.db_host)
    |> pog.port(config.db_port)
    |> pog.database(config.db_name)
    |> pog.user(config.db_user)
    |> pog.password(option.Some(config.db_password))
    |> pog.supervised
  let assert Ok(_) =
    static_supervisor.new(static_supervisor.RestForOne)
    |> static_supervisor.add(db_pool)
    |> static_supervisor.start()
  db_pool_name
}
