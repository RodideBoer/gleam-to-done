import gleam/erlang/process
import pog
import server/config

pub type DbPoolName =
  process.Name(pog.Message)

pub type Context {
  Context(config: config.Config, db_pool_name: DbPoolName)
  TestContext(config: config.Config, db_conn: pog.Connection)
}

pub fn db_conn(ctx: Context) -> pog.Connection {
  case ctx {
    Context(_, db_pool_name) -> pog.named_connection(db_pool_name)
    TestContext(_, db_conn) -> db_conn
  }
}
