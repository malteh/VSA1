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

start_multi(0) -> false;
start_multi(Number) ->
	Name = integer_to_list(Number) ++ "-client",
	spawn(fun() -> start(Name) end),
	start_multi(Number-1)
.%

start(Name) ->
	log(Name, "Client gestartet"),
	Server = server_pid(),
	timer:send_after(lifetime() * 1000, stop),
	loop(Name, Server, []),
	stop(Name)
.%

loop(Name, Server, Nachrichtennummern) ->
	Neue_nummern = redakteur:start(Name, Server, anzahl(), [], sendeintervall()),
	leser:start(Name, Server, Nachrichtennummern ++ Neue_nummern),
	loop(Name, Server, Nachrichtennummern)
.%

stop(Name) ->
	log(Name, "Client gestoppt"),
	halt()
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
	TextNewline = io_lib:format("~s~n", [Text]),
	Logfile = io_lib:format("../logs/~s.log", [Prefix]),
	werkzeug:logging(Logfile, TextNewline)
.%

anzahl() ->
	{ok, Anzahl} = werkzeug:get_config_value(anzahl, tools:read_config(?Config)),
	Anzahl
.%

lifetime() ->
	{ok, Lifetime} = werkzeug:get_config_value(lifetime, tools:read_config(?Config)),
	Lifetime
.%

sendeintervall() ->
	{ok, Sendeintervall} = werkzeug:get_config_value(sendeintervall, tools:read_config(?Config)),
	Sendeintervall * 1000
.%