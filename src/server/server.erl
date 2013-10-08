-module(server).
-export([start/0, name/0]).

% Globale "Variablen"
-define(Config,  '../config/server.cfg').
-define(Logfile, '../logs/NServer.log').

%E: start server
start() ->
	register(server:name(), self()),
	global:register_name(server:name(), self()),
	log("Server gestartet"),
	loop()	
.%

loop() ->
	receive
		{hallo, PID} ->
			PID ! hallo,
			loop();
		stop ->
			stop()
	end
.%

stop() ->
	log("Server gestoppt"),
	werkzeug:logstop(),
	halt()
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
	{ok, Name} = werkzeug:get_config_value(servername, readConfig()),
	Name
.%