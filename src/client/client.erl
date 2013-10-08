-module(client).
-export([start/1]).

% Globale "Variablen"
-define(Config, '../config/client.cfg').

%E: start client
start(Clientname) ->
	log(Clientname, "Client gestartet"),
	ConfigList = readConfig(),
	{ok, Servername} = werkzeug:get_config_value(servername, ConfigList),
	{ok, Serverhost} = werkzeug:get_config_value(serverhost, ConfigList),
	Ping = list_to_atom(atom_to_list(Servername) ++ "@" ++ Serverhost),
	net_adm:ping(Ping),
	%Pid = global:whereis_name(Servername),
	%log(Clientname, Pid),
	{Servername,  Ping} ! {hallo, self()},
	receive
		hallo ->
			log(Clientname, "hallo empfangen")
	end,
	%server:name() ! stop,
	stop(Clientname)
.%

stop(Clientname) ->
	log(Clientname, "Client gestoppt"),
	werkzeug:logstop()
.%

log(Clientname, Text) ->
	io:format("~s~n", [Clientname]),
	TextNewline = io_lib:format("~s:~s~n", [Clientname, Text]),
	Logfile = io_lib:format("~s.log", [Clientname]),
	werkzeug:logging(Logfile, TextNewline)
.%

readConfig() ->
	{ok, ConfigList} = file:consult(?Config),
	ConfigList
.%