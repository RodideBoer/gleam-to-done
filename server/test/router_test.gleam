import gleam/http
import server/router
import test_context
import wisp/simulate

pub fn unknown_route_test() {
  let ctx = test_context.get()
  let response =
    simulate.request(http.Get, "/unknown")
    |> router.handle_request(ctx)

  assert response.status == 404
  assert simulate.read_body(response) == "Not found"
}
