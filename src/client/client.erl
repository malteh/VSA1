-module(client).
-export([start_one/0, start_multi/0, log/2]).

% Globale "Variablen"
-define(Config,  '../config/client.cfg').
-define(Logfile, '../logs/Clients.log').

% EXPORTED ============================

% start multiple clients
start_multi() ->
	start_multi(5)
.%

% start one client
start_one() ->
	start_multi(1)
.%

%======================================

start_multi(0) -> halt();
start_multi(Number) ->
	Name = "Client" ++ integer_to_list(Number),
	start(Name),
	start_multi(Number-1)
.%

start(Name) ->
	log(Name, "Client gestartet"),
	Server = server_pid(),
	loop(Name, Server),
	stop(Name)
.%

loop(Name, Server) ->
	leser:start(Name, Server),
	redakteur:start(Name, Server)
.%

stop(Name) ->
	log(Name, "Client gestoppt"),
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

