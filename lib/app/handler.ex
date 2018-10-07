defmodule App.Handler do
  @moduledoc "Handles HTTP requests."

  alias App.Conv
  import App.Parser, only: [parse: 1]

  @doc "Transforms the request into a response."
  def handle(request, http_server) do
    request
    |> parse
    |> route(http_server)
    |> format_response
  end

  def route(%Conv{method: "GET", path: "/"} = conv, http_server) do
    msg = """
    I am the node #{inspect(node())} on process #{inspect(http_server)}
    There are available these machines: #{inspect(Node.list())}
    """

    pid = %{conv | status: 200, resp_body: msg}
  end

  def route(%Conv{method: "GET", path: "/kaboom"} = conv, http_server) do
    Process.exit(http_server, :kill)
    %{conv | status: 200, resp_body: "Kaboom!"}
  end

  def route(%Conv{path: path} = conv, _http_server) do
    %{conv | status: 404, resp_body: "No #{path} here!"}
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    Content-Type: #{conv.resp_content_type}\r
    Content-Length: #{String.length(conv.resp_body)}\r
    \r
    #{conv.resp_body}
    """
  end
end
