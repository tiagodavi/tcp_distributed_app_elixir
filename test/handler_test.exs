defmodule HandlerTest do
  use ExUnit.Case, async: true

  import App.Handler, only: [handle: 2]

  test "GET /" do
    request = """
    GET / HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = handle(request, :http_server)

    assert response =~ "I am the node"
  end
end
