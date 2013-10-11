-module(clientverwalter).
-export([erzeuge_liste/0, letzte_nnr/2]).
erzeuge_liste() ->
	[]
.%

letzte_nnr(ClientPID, []) ->
	{0, [{ClientPID, 0, tools:now_seconds()}]};
letzte_nnr(ClientPID, Clientliste) ->
	{0, [{ClientPID, 0, tools:now_seconds()}]}
.%