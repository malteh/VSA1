-module(server).
-export([start/0, name/0]).

% Globale "Variablen"
-define(Config,  '../config/server.cfg').
-define(Logfile, '../logs/NServer.log').
-define(Name, servername).

%E: start server
start() ->
	log("Server gestartet"),
	receive
		stop -> stop()
	end
.%

stop() ->
	log("Server gestoppt"),
	werkzeug:logstop()
.%

log(Text) ->
	TextNewline = io_lib:format("~s~n", [Text]),
	werkzeug:logging(?Logfile, TextNewline)
.%

readConfig() ->
	{ok, ConfigList} = file:consult(?Config),
	ConfigList
.%

%E: Servername aus Config auslesen
name() ->
	{ok, Name} = werkzeug:get_config_value(?Name, readConfig()),
	Name
.%