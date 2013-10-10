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
		{getmessages, PID} ->
			log("getmessages empfangen"),
			Number = 1,
			Nachricht = "",
			Terminated = true,
			PID ! {reply, Number, Nachricht, Terminated},
			loop();
		{dropmessage, {Nachricht, Number}} ->
			log("dropmessage empfangen" ++ Nachricht ++ integer_to_list(Number)),
			loop();
		{getmsgid, PID} ->
			log("getmsgid empfangen"),
			Number = 1,
			PID ! {nid, Number},
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