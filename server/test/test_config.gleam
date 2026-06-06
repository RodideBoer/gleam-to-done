import envoy
import server/config

pub fn load() -> config.Config {
  let assert Ok(db_name) = envoy.get("TEST_DB_NAME")

  config.Config(..config.load(), db_name:)
}
