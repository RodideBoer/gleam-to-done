import gleam/dynamic/decode
import gleam/http
import gleam/json
import server/router
import task
import test_context
import wisp/simulate

pub fn list_tasks_with_wrong_method_test() {
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
