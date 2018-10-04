defmodule App.Server do
  @moduledoc """
  Module that implements Echo Server's public interface
  """
  require Logger

  @doc """
  Starts a new TCP Server

  ## Parameters
  - port: Port number you want to connect to

  ## Examples
  iex> App.Server.start 4001
  """

  @spec start(Integer.t()) :: any()
  def start(port) do
    tcp_options = [:binary, packet: :line, active: false, reuseaddr: true]
    {:ok, socket} = :gen_tcp.listen(port, tcp_options)
    Logger.info("Accepting connections on port #{port}")
    listen(socket)
  end

  defp listen(socket) do
    {:ok, conn} = :gen_tcp.accept(socket)
    open(conn)
    listen(socket)
  end

  defp open(conn) do
    conn
    |> read_line()
    |> write_line(conn)

    open(conn)
  end

  defp read_line(conn) do
    case :gen_tcp.recv(conn, 0) do
      {:ok, data} ->
        data

      {:error, _} ->
        "Closed..."
    end
  end

  defp write_line(line, conn) do
    :gen_tcp.send(conn, line)
  end
end
