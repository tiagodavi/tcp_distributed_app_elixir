defmodule App.Handler do
  @moduledoc "Handles HTTP requests."

  alias App.Conv
  import App.Parser, only: [parse: 1]

  @doc "Transforms the request into a response."
  def handle(request) do
    request
    |> parse
    |> route
    |> format_response
  end

  def route(%Conv{method: "GET", path: "/"} = conv) do
    pid = %{conv | status: 200, resp_body: "I am the server #{inspect(self())}"}
  end

  def route(%Conv{method: "GET", path: "/kaboom"}) do
    raise "Kaboom!"
  end

  def route(%Conv{path: path} = conv) do
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
