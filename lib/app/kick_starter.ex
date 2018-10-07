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

    if(valid_node?()) do
      node =
        [node() | Node.list()]
        |> Enum.random()

      start_server(node, port)
    else
      start_server(port)
    end

    {:noreply, port}
  end

  defp start_server(port) do
    unless(valid_node?()) do
      IO.puts("Starting Master HTTP server on port #{port}")
      start_server(node(), port)
    end
  end

  defp start_server(node, port) do
    Node.spawn_link(node, App.HttpServer, :start, [port])
  end

  defp valid_node? do
    Application.get_env(:app, :nodes)
    |> Enum.filter(&(&1 != node()))
    |> Enum.map(&Node.connect/1)
    |> Enum.any?(&(&1 === true))
  end
end
