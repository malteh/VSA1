-module(clientverwalter).
-export([erzeuge_liste/0, letzte_nnr/2, aktualisiere/3]).
-define(Else, true).

erzeuge_liste() ->
	[]
.%

letzte_nnr(_, []) -> 0;
letzte_nnr(ClientPID, Clientliste) ->
	{_, LetzteNr, Timeout} = search_PID(ClientPID, Clientliste),
	Now = tools:now_seconds(),
	if (Now > Timeout) ->
		server:log(io_lib:format("Client :~w unbekannt", [ClientPID] )),
		0;
	?Else ->
		LetzteNr
	end
.%

aktualisiere(ClientPID, Nnr, Liste) ->
	deleteID(ClientPID, Liste) ++ [{ClientPID, Nnr, timeout()}]
.%

% Suche nach Tupel mit der PID, der Uhrzeit und der Nummer der letzten Nachricht.
% Nummer gefunden, gebe sie zurück.
search_PID(_, []) -> {0,0,0};
search_PID(ClientPID, [{HeadPID, LetzteNr, Timeout} | Tail]) ->
	if (HeadPID == ClientPID) ->
		{ClientPID, LetzteNr, Timeout};
	?Else ->
		search_PID(ClientPID, Tail)
	end
.%

% Lösche Element mit ClientPID
deleteID(ClientPID, Liste) ->
	lists:delete(search_PID(ClientPID, Liste), Liste)
.%

timeout() ->
	tools:now_seconds() + clientlifetime()
.%

% Clientlifetime aus Config auslesen
clientlifetime() ->
	{ok, Clientlifetime} = werkzeug:get_config_value(clientlifetime, tools:read_config(server:config_file())),
	Clientlifetime
.%