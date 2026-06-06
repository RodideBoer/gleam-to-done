import gleam/dynamic/decode
import gleam/http
import gleam/int
import gleam/json
import gleam/list
import server/context
import server/router
import server/task/repository
import task
import tasks
import test_context
import test_db
import wisp/simulate

pub fn task_with_wrong_method_test() {
  let ctx = test_context.get()
  let response =
    simulate.request(http.Delete, "/api/task")
    |> router.handle_request(ctx)

  assert response.status == 405
  assert simulate.read_body(response) == "Method not allowed"
}

pub fn empty_list_tasks_test() {
  let ctx = test_context.get()
  let response =
    simulate.request(http.Get, "/api/task")
    |> router.handle_request(ctx)

  assert response.status == 200

  let body = simulate.read_body(response)
  let assert Ok(tasks) = json.parse(body, decode.list(task.task_decoder()))

  assert tasks == []
}

pub fn list_tasks_test() {
  let ctx = test_context.get()
  use ctx <- test_db.with_rollback(ctx)

  let db_conn = context.db_conn(ctx)
  let inputs =
    [tasks.task1, tasks.task2]
    |> list.map(task.to_task_input)
  inputs
  |> list.each(fn(input) { repository.create_task(db_conn, input) })

  let response =
    simulate.request(http.Get, "/api/task")
    |> router.handle_request(ctx)

  assert response.status == 200
  let body = simulate.read_body(response)
  let assert Ok(tasks) = json.parse(body, decode.list(task.task_decoder()))
  assert list.map(tasks, task.to_task_input) == list.reverse(inputs)
}

pub fn create_task_with_invalid_json_test() {
  let ctx = test_context.get()
  let body = json.object([#("foo", json.string("bar"))])

  let response =
    simulate.request(http.Post, "/api/task")
    |> simulate.json_body(body)
    |> router.handle_request(ctx)

  assert response.status == 422
  assert simulate.read_body(response) == "Unprocessable content"
}

pub fn create_task_with_no_json_test() {
  let ctx = test_context.get()

  let response =
    simulate.request(http.Post, "/api/task")
    |> simulate.string_body("This is not json")
    |> simulate.header("content-type", "application/json")
    |> router.handle_request(ctx)

  assert response.status == 400
  assert simulate.read_body(response) == "Bad request: Invalid JSON"
}

pub fn create_task_with_invalid_content_type_test() {
  let ctx = test_context.get()

  let response =
    simulate.request(http.Post, "/api/task")
    |> simulate.string_body("No json content type header")
    |> router.handle_request(ctx)

  assert response.status == 415
  assert simulate.read_body(response) == "Unsupported media type"
}

pub fn create_task_test() {
  let ctx = test_context.get()
  use ctx <- test_db.with_rollback(ctx)

  let body =
    tasks.task1
    |> task.to_task_input
    |> task.task_input_to_json

  let response =
    simulate.request(http.Post, "/api/task")
    |> simulate.json_body(body)
    |> router.handle_request(ctx)

  assert response.status == 201

  let body = simulate.read_body(response)
  let assert Ok(task) = json.parse(body, task.task_decoder())
  // Because the database generates the id's, assert without them
  assert task.to_task_input(task) == task.to_task_input(tasks.task1)
}

pub fn show_task_test() {
  let ctx = test_context.get()
  use ctx <- test_db.with_rollback(ctx)

  let db_conn = context.db_conn(ctx)
  let input =
    tasks.task42
    |> task.to_task_input
  let assert Ok(input_task) = repository.create_task(db_conn, input)

  let response =
    simulate.request(http.Get, "/api/task/" <> int.to_string(input_task.id))
    |> router.handle_request(ctx)

  assert response.status == 200
  let body = simulate.read_body(response)
  let assert Ok(task) = json.parse(body, task.task_decoder())
  assert task.to_task_input(task) == task.to_task_input(input_task)
}

pub fn update_task_test() {
  let ctx = test_context.get()
  use ctx <- test_db.with_rollback(ctx)

  let db_conn = context.db_conn(ctx)
  let input =
    tasks.task101
    |> task.to_task_input
  let assert Ok(input_task) = repository.create_task(db_conn, input)

  let completed_task = task.Task(..input_task, completed: True)
  let body =
    completed_task
    |> task.to_task_input
    |> task.task_input_to_json
  let response =
    simulate.request(http.Patch, "/api/task/" <> int.to_string(input_task.id))
    |> simulate.json_body(body)
    |> router.handle_request(ctx)

  assert response.status == 200
  let body = simulate.read_body(response)
  let assert Ok(task) = json.parse(body, task.task_decoder())
  assert task.to_task_input(task) == task.to_task_input(completed_task)
}

pub fn show_updated_task_test() {
  let ctx = test_context.get()
  use ctx <- test_db.with_rollback(ctx)

  let db_conn = context.db_conn(ctx)
  let input =
    tasks.task101
    |> task.to_task_input
  let assert Ok(input_task) = repository.create_task(db_conn, input)

  let completed_task = task.Task(..input_task, completed: True)
  let body =
    completed_task
    |> task.to_task_input
    |> task.task_input_to_json
  let _ =
    simulate.request(http.Patch, "/api/task/" <> int.to_string(input_task.id))
    |> simulate.json_body(body)
    |> router.handle_request(ctx)

  let response =
    simulate.request(http.Get, "/api/task/" <> int.to_string(input_task.id))
    |> router.handle_request(ctx)
  let body = simulate.read_body(response)
  let assert Ok(task) = json.parse(body, task.task_decoder())
  assert task.to_task_input(task) == task.to_task_input(completed_task)
}

pub fn delete_task_test() {
  let ctx = test_context.get()
  use ctx <- test_db.with_rollback(ctx)

  let db_conn = context.db_conn(ctx)
  let input =
    tasks.task42
    |> task.to_task_input
  let assert Ok(input_task) = repository.create_task(db_conn, input)

  let response =
    simulate.request(http.Delete, "/api/task/" <> int.to_string(input_task.id))
    |> router.handle_request(ctx)

  assert response.status == 204
}
