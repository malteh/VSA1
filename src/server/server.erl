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
	Queuestruktur = queueverwalter:erzeuge_struktur(),
	Clientliste = clientverwalter:erzeuge_liste(),
	loop(nnr_erhoehen(0), Queuestruktur, Clientliste)	
.%

loop(Nnr, Queuestruktur, Clientliste) ->
	receive
		{getmessages, PID} ->
			log("getmessages empfangen"),
			{Letzte_nnr, Clientliste_neu} = clientverwalter:letzte_nnr(PID, Clientliste),
			{Nnr_neu, Nachricht, Terminated} = queueverwalter:hole_nachricht(Letzte_nnr, Queuestruktur),
			PID ! {reply, Nnr_neu, Nachricht, Terminated},
			loop(Nnr, Queuestruktur, Clientliste_neu);
		{dropmessage, {Nachricht, Number}} ->
			log("dropmessage empfangen" ++ Nachricht ++ integer_to_list(Number)),
			Queuestruktur_neu = queueverwalter:nachricht_einfuegen(Number, Nachricht, Queuestruktur),
			loop(Nnr, Queuestruktur_neu, Clientliste);
		{getmsgid, PID} ->
			log("getmsgid empfangen"),
			PID ! {nid, Nnr},
			loop(nnr_erhoehen(Nnr), Queuestruktur, Clientliste);
		stop ->
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