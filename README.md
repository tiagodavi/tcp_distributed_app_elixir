## TCP Server

*This is a TCP Server and distributed app example in Elixir*

* First install dependencies with `mix deps.get`
* Run tests with `mix test`

## Running TCP Server on the console.

Open a console and start the server.

```
$ iex -S mix
iex> App.Server.start(4001)
```

The ```-S mix``` options will load your project into the current session.

Open another console and connect using telnet.

```
$ telnet 127.0.0.1 4001
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
This is Tiago
This is Tiago
```

My particular telnet client can be exited by typing ctrl + ], typing quit, and pressing Enter, but your client may require different steps.

## Distributed HttpServer

Run the commands below on different terminals (The first will be the master node)

Machine A
```
$ iex -S mix
```

Machine B
```
$ iex -S mix
```

Machine C
```
$ iex -S mix
```

And so on...


Now you can visit [`localhost:8888`](http://localhost:8888) from your browser.

Use /kaboom to raise an exception and start a new process
(eventually running in new machines)
http://localhost:8888/kaboom

Then try to run again on the root:
http://localhost:8888
