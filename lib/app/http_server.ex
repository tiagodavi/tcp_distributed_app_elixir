defmodule App.HttpServer do
  @moduledoc "Module that implements HTTP Server processes."

  alias App.Handler

  @doc """
  Starts the server on the given `port` of localhost.
  """
  def start(port) when is_integer(port) and port > 1023 do
    # Socket options:
    # `:binary` - open the socket in "binary" mode and deliver data as binaries
    # `packet: :raw` - deliver the entire binary without doing any packet handling
    # `active: false` - receive data when we're ready by calling `:gen_tcp.recv/2`
    # `reuseaddr: true` - allows reusing the address if the listener crashes

    tcp_options = [:binary, packet: :raw, active: false, reuseaddr: true]

    # Creates a socket to listen for client connections.
    # `listen_socket` is bound to the listening socket.

    case :gen_tcp.listen(port, tcp_options) do
      {:ok, listen_socket} ->
        IO.puts("\n🎧  Listening for connection requests on port #{port}...\n")
        accept_loop(listen_socket)

      _ ->
        nil
    end
  end

  @doc """
  Accepts client connections on the `listen_socket`.
  """
  def accept_loop(listen_socket) do
    IO.puts("⌛️  Waiting to accept a client connection...\n")

    # Suspends (blocks) and waits for a client connection. When a connection
    # is accepted, `client_socket` is bound to a new client socket.
    {:ok, client_socket} = :gen_tcp.accept(listen_socket)

    IO.puts("⚡️  Connection accepted!\n")

    http_server = self()

    # Receives the request and sends a response over the client socket.
    spawn(fn -> serve(client_socket, http_server) end)

    # Loop back to wait and accept the next connection.
    accept_loop(listen_socket)
  end

  @doc """
  Receives the request on the `client_socket` and
  sends a response back over the same socket.
  """
  def serve(client_socket, http_server) do
    IO.puts("#{inspect(self())}: Working on it!")

    client_socket
    |> read_request
    |> Handler.handle(http_server)
    |> write_response(client_socket)
  end

  @doc """
  Receives a request on the `client_socket`.
  """
  def read_request(client_socket) do
    # all available bytes

    case :gen_tcp.recv(client_socket, 0) do
      {:ok, request} ->
        IO.puts("➡️  Received request:\n")
        IO.puts(request)

        request

      {:error, reason} ->
        generate_response(reason)
    end
  end

  @doc """
  Returns a generic HTTP response.
  """
  def generate_response(_request) do
    """
    HTTP/1.1 200 OK\r
    Content-Type: text/plain\r
    Content-Length: 6\r
    \r
    Hello!
    """
  end

  @doc """
  Sends the `response` over the `client_socket`.
  """
  def write_response(response, client_socket) do
    :ok = :gen_tcp.send(client_socket, response)

    IO.puts("⬅️  Sent response:\n")
    IO.puts(response)

    # Closes the client socket, ending the connection.
    # Does not close the listen socket!
    :gen_tcp.close(client_socket)
  end
end
