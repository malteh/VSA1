-module(server).
-export([start/0, name/0, config_file/0, log/1, test/0]).

% Globale "Variablen"
-define(Config,  '../config/server.cfg').
-define(Logfile, '../logs/NServer.log').

%E: start server
start() ->
	register(name(), self()),
	global:register_name(name(), self()),
	log("Server Startzeit: " ++ tools:time_string() ++ " mit PID " ++ io_lib:format("~p", [self()])),
	Queuestruktur = queueverwalter:erzeuge_struktur(),
	Clientliste = clientverwalter:erzeuge_liste(),
	loop(nnr_erhoehen(0), Queuestruktur, Clientliste, laufzeit())	
.%

loop(Nnr, Queuestruktur, Clientliste, Laufzeit) ->
	receive
		{getmessages, ClientPID} ->
			Letzte_nnr = clientverwalter:letzte_nnr(ClientPID, Clientliste),
			{Nnr_neu, Nachricht, Terminated} = queueverwalter:naechste_nachricht(Letzte_nnr, Queuestruktur),
			ClientPID ! {reply, Nnr_neu, Nachricht, Terminated},
			Clientliste_neu = clientverwalter:aktualisiere(ClientPID, Nnr_neu, Clientliste),
			log(Nachricht ++ "-getmessages"),
			loop(Nnr, Queuestruktur, Clientliste_neu, Laufzeit);
		{dropmessage, {Text, Number}} ->
			log(Text ++ "-dropmessage"),
			Queuestruktur_neu = queueverwalter:nachricht_einfuegen(Number, Text, Queuestruktur),
			loop(Nnr, Queuestruktur_neu, Clientliste, Laufzeit);
		{getmsgid, ClientPID} ->
			ClientPID ! {nid, Nnr},
			log("Nachrichtennummer " ++ integer_to_list(Nnr) ++ " an " ++ io_lib:format("~p", [ClientPID]) ++ " gesendet"),
			loop(nnr_erhoehen(Nnr), Queuestruktur, Clientliste, Laufzeit);
		stop ->
			stop()
		after Laufzeit ->
			stop()
	end
.%

% Nachrichtennummerverwalter
nnr_erhoehen(0) -> 1;
nnr_erhoehen(Nummer) ->
	Nummer + 1
.%

stop() ->
	log("Server gestoppt"),
	werkzeug:logstop(),
	halt()
.%

%E:
log(Text) ->
	TextNewline = io_lib:format("~s~n", [Text]),
	werkzeug:logging(?Logfile, TextNewline)
.%

config_file() ->
	?Config
.%

%E: Servername aus Config auslesen
name() ->
	{ok, Name} = werkzeug:get_config_value(servername, tools:read_config(?Config)),
	Name
.%

laufzeit() ->
	{ok, Laufzeit} = werkzeug:get_config_value(laufzeit, tools:read_config(?Config)),
	Laufzeit * 1000
.%

test() ->
	Server = spawn(fun() -> start() end),
	
	%1
	Number1 = test_getmsgid(Server),
	test_dropmessage(Server, Number1),
	
	%2
	test_getmsgid(Server),
	
	%3
	Number3 = test_getmsgid(Server),
	test_dropmessage(Server, Number3),
	
	%4
	Number4 = test_getmsgid(Server),
	test_dropmessage(Server, Number4),
	
	%5
	Number5 = test_getmsgid(Server),
	test_dropmessage(Server, Number5),
	
	%6
	Number6 = test_getmsgid(Server),
	test_dropmessage(Server, Number6),
	
	%7
	Number7 = test_getmsgid(Server),
	test_dropmessage(Server, Number7),
	
	test_getmessages(Server),
	test_getmessages(Server),
	test_getmessages(Server),
	test_getmessages(Server),
	test_getmessages(Server),
	test_getmessages(Server),
	
	Server ! stop
.%

test_dropmessage(Server, Number) ->
	Server ! {dropmessage, {integer_to_list(Number) ++ "test", Number}}
.%

test_getmessages(Server) ->
	Server ! {getmessages, self()},
	receive
		{reply, _Number, Nachricht1, Terminated1} ->
			log(Nachricht1 ++ atom_to_list(Terminated1))
	end
.%

test_getmsgid(Server) ->
	Server ! {getmsgid, self()},
	receive
		{nid, Number} ->
			log("nid empfangen" ++ integer_to_list(Number))
	end,
	Number
.%