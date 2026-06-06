import gleeunit
import test_db

pub fn main() -> Nil {
  test_db.start()

  gleeunit.main()
}
