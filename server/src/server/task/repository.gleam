import gleam/bool
import gleam/list
import gleam/result
import pog
import server/db
import server/task/sql
import task.{type Task, type TaskInput, Task}

pub fn all_tasks(
  db_conn: pog.Connection,
) -> Result(List(Task), db.DatabaseError) {
  let query_result =
    db_conn
    |> sql.all_tasks
    |> result.map_error(db.QueryError)
  // Just to explain what we're doing for real,
  //  here is the same code without pattern matching.
  //  Not sure which I prefer yet
  // use returned <- result.map(query_result)
  // use row <- list.map(returned.rows)
  use pog.Returned(_, rows) <- result.map(query_result)
  use row <- list.map(rows)
  Task(
    id: row.id,
    title: row.title,
    description: row.description,
    completed: row.completed,
  )
}

pub fn get_task(
  db_conn: pog.Connection,
  id: Int,
) -> Result(Task, db.DatabaseError) {
  let query_result =
    db_conn
    |> sql.get_task(id)
    |> result.map_error(db.QueryError)
  use pog.Returned(_, rows) <- result.try(query_result)
  let row_result =
    rows
    |> list.first
    |> result.replace_error(db.RecordNotFound)
  use row <- result.map(row_result)
  Task(
    id: row.id,
    title: row.title,
    description: row.description,
    completed: row.completed,
  )
}

pub fn create_task(
  db_conn: pog.Connection,
  input: TaskInput,
) -> Result(Task, db.DatabaseError) {
  let query_result =
    db_conn
    |> sql.create_task(input.title, input.description, input.completed)
    |> result.map_error(db.QueryError)
  use pog.Returned(_, rows) <- result.try(query_result)
  let row_result =
    rows
    |> list.first
    |> result.replace_error(db.RecordNotFound)
  use row <- result.map(row_result)
  Task(
    id: row.id,
    title: row.title,
    description: row.description,
    completed: row.completed,
  )
}

pub fn update_task(
  db_conn: pog.Connection,
  input: Task,
) -> Result(Task, db.DatabaseError) {
  let query_result =
    db_conn
    |> sql.update_task(
      input.id,
      input.title,
      input.description,
      input.completed,
    )
    |> result.map_error(db.QueryError)
  use pog.Returned(_, rows) <- result.try(query_result)
  let row_result =
    rows
    |> list.first
    |> result.replace_error(db.RecordNotFound)
  use row <- result.map(row_result)
  Task(
    id: row.id,
    title: row.title,
    description: row.description,
    completed: row.completed,
  )
}

pub fn delete_task(
  db_conn: pog.Connection,
  id: Int,
) -> Result(Nil, db.DatabaseError) {
  let query_result =
    db_conn
    |> sql.delete_task(id)
    |> result.map_error(db.QueryError)
  use pog.Returned(count, _) <- result.try(query_result)
  use <- bool.guard(count == 0, Error(db.RecordNotFound))
  Ok(Nil)
}
