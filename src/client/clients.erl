-module(clients).
-export([start/0]).

-define(Config,  '../config/client.cfg').
-define(Logfile, '../logs/Clients.log').

%E: start client
start() ->
	log("Starte Clients"),
	start(1)
.%

start(6) -> halt();
start(X) ->
	Name = "Client" ++ integer_to_list(X),
	client:start(Name),
	start(X+1)
.%

log(Text) ->
	TextNewline = io_lib:format("~s~n", [Text]),
	werkzeug:logging(?Logfile, TextNewline)
.%