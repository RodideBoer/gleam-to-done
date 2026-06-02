import gleam/dynamic
import gleam/erlang/atom
import pog
import server/config
import server/context
import server/db

@external(erlang, "shell", "strings")
pub fn shell_strings(enabled: Bool) -> dynamic.Dynamic

@external(erlang, "application", "ensure_all_started")
pub fn ensure_all_started(app: atom.Atom) -> dynamic.Dynamic

pub fn init() -> pog.Connection {
  let _ = shell_strings(True)
  let _ = ensure_all_started(atom.create("pgo"))
  let config = config.load()
  let db_pool_name = db.start(config)
  let context = context.Context(config:, db_pool_name:)
  context.db_conn(context)
}
