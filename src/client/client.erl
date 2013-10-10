-module(client).
-export([start_one/0, start_multiple/0]).

% Globale "Variablen"
-define(Config,  '../config/client.cfg').
-define(Logfile, '../logs/Clients.log').

% EXPORTED ============================

% start multiple clients
start_multiple() ->
	start_multiple(5)
.%

% start one client
start_one() ->
	start_multiple(1)
.%

%======================================

start_multiple(0) -> halt();
start_multiple(Number) ->
	Name = "Client" ++ integer_to_list(Number),
	start(Name),
	start_multiple(Number-1)
.%

start(Clientname) ->
	log(Clientname, "Client gestartet"),
	Server = server_pid(),
	loop(Clientname, Server),
	stop(Clientname)
.%

loop(Clientname, Server) ->
	% getmessages
	Server ! {getmessages, self()},
	log(Clientname, "getmessages gesendet"),
	receive
		{reply, Number1, Nachricht, Terminated} ->
			log(Clientname, "reply" ++ integer_to_list(Number1) ++ Nachricht ++ atom_to_list(Terminated))
	end,
	
	% getmsgid
	Server ! {getmsgid, self()},
	log(Clientname, "getmsgid gesendet"),
	receive
		{nid, Number2} ->
			log(Clientname, "nid empfangen" ++ integer_to_list(Number2))
	end,
	
	% dropmessage
	{Nachricht1, Number} = {"Hallo", 1},
	Server ! {dropmessage, {Nachricht1, Number}},
	log(Clientname, "dropmessage gesendet")
.%

stop(Clientname) ->
	log(Clientname, "Client gestoppt"),
	werkzeug:logstop()
.%

server_pid() ->
	ConfigList = readConfig(),
	{ok, Servername} = werkzeug:get_config_value(servername, ConfigList),
	{ok, Serverhost} = werkzeug:get_config_value(serverhost, ConfigList),
	Host = list_to_atom(atom_to_list(Servername) ++ "@" ++ Serverhost),
	net_adm:ping(Host),
	{Servername, Host}
.%

readConfig() ->
	{ok, ConfigList} = file:consult(?Config),
	ConfigList
.%

log(Prefix, Text) ->
	TextNewline = io_lib:format("~s:~s~n", [Prefix, Text]),
	Logfile = io_lib:format("~s.log", [Prefix]),
	werkzeug:logging(Logfile, TextNewline)
.%

