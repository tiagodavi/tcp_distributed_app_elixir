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
    unless reason === :normal do
      start_server(port)
    end
    {:noreply, port}
  end

  def handle_info({:nodedown, _node}, port) do
    start_server(port)
    {:noreply, port}
  end

  defp start_server(port) do
    unless Node.alive?, do: generate_node()
    monitor_nodes()
    nodes = Node.list()
    if(Enum.count(nodes) > 0) do
      node =
        [node() | nodes ]
        |> Enum.random()
      start_server(node, port)
    else
      start_server(node(), port)
    end
  end

  defp start_server(node, port) do
    Node.spawn_link(node, App.HttpServer, :start, [port])
  end

  defp monitor_nodes do
    Application.get_env(:app, :nodes)
    |> Enum.filter(&(&1 != node()))
    |> Enum.map(fn n ->
      Node.connect(n)
      n
    end)
    |> Enum.filter(&(Node.ping(&1) === :pong))
    |> Enum.map(&(Node.monitor(&1, true)))
  end

  defp generate_node do
    Application.get_env(:app, :nodes)
    |> Enum.find(fn n ->
      case Node.start(n) do
        {:ok, _} -> true
        _ -> false
      end
    end)
  end

end
