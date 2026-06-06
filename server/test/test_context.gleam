import gleam/erlang/process
import pog
import server/context
import test_config
import test_db

pub fn get() -> context.Context {
  let config = test_config.load()
  let db_pool_name = test_db.db_pool_name()
  let assert Ok(_) = process.named(db_pool_name)
  let db_conn = pog.named_connection(db_pool_name)
  context.TestContext(config:, db_conn:)
}
