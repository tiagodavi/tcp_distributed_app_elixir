defmodule App.KickStarter do
  @moduledoc "Start Point"

  use GenServer

  def start_link(port) do
    IO.puts('Starting the kickstarter...')
    GenServer.start_link(__MODULE__, port, name: __MODULE__)
  end

  def init(port) do
    Process.flag(:trap_exit, true)
    start_server(port)
    {:ok, port}
  end

  def handle_info({:EXIT, _pid, reason}, port) do
    IO.puts("HttpServer exited (#{inspect(reason)})")
    start_server(port)
    {:noreply, port}
  end

  defp start_server(port) do
    IO.puts("Starting the HTTP server on port #{port}")
    server_pid = spawn_link(App.HttpServer, :start, [port])
    Process.register(server_pid, :http_server)
    server_pid
  end
end
