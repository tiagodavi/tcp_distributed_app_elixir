## TCP Server

**This is a TCP Server and distributed app example in Elixir**

## Running TCP Server on the console.
To run this open a console and start the server.

```
$ iex -S mix
iex> App.Server.start(4001)
```

The ```-S mix``` options will load your project into the current session.

Connect using telnet or netcat and try it out.

```
$ telnet 127.0.0.1 4001
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
hello
hello
is it me
is it me
you are looking for?
you are looking for?
```
