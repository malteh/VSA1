-module(server).
-export([start/0]).

% Globale "Variablen"
-define(Config,  '../config/server.cfg').
-define(Logfile, '../logs/NServer.log').

% start server
start() ->
	readConfig(),
	werkzeug:logstop()
.%

log(Text) ->
	werkzeug:logging(?Logfile, Text)
.%

readConfig() ->
	{ok, ConfigList} = file:consult(?Config),
	{ok, Server} = werkzeug:get_config_value(servername, ConfigList),
	S = io_lib:format("Hallo ~s~n", [Server]),
	log(S)
.%