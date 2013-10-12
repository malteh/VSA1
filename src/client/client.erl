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

start_multi(0) -> io:format("asd",[]);%halt();
start_multi(Number) ->
	Name = "Client" ++ integer_to_list(Number),
	spawn(fun() -> start(Name) end),
	start_multi(Number-1)
.%

start(Name) ->
	log(Name, "Client gestartet"),
	Server = server_pid(),
	loop(Name, Server, []),
	stop(Name)
.%

loop(Name, Server, Nachrichtennummern) ->
	Neue_nummern = redakteur:start(Name, Server, anzahl()),
	leser:start(Name, Server, Nachrichtennummern ++ Neue_nummern)
.%

stop(Name) ->
	log(Name, "Client gestoppt"),
	werkzeug:logstop()
.%

server_pid() ->
	ConfigList = tools:read_config(?Config),
	{ok, Servername} = werkzeug:get_config_value(servername, ConfigList),
	{ok, Serverhost} = werkzeug:get_config_value(serverhost, ConfigList),
	Host = list_to_atom(atom_to_list(Servername) ++ "@" ++ Serverhost),
	net_adm:ping(Host),
	{Servername, Host}
.%

log(Prefix, Text) ->
	TextNewline = io_lib:format("~s:~s~n", [Prefix, Text]),
	Logfile = io_lib:format("../logs/~s.log", [Prefix]),
	werkzeug:logging(Logfile, TextNewline)
.%

anzahl() ->
	ConfigList = tools:read_config(?Config),
	{ok, Anzahl} = werkzeug:get_config_value(anzahl, ConfigList),
	Anzahl
.%