-module(redakteur).

-export([start/3]).
-define(Else, true).

start(Name, Server, Anzahl) ->
	start(Name, Server, Anzahl, [])
.%

start(Name, Server, Anzahl, Gesendete) ->
	client:log(Name, ": Redakteurmodus"),
	
	% getmsgid
	Server ! {getmsgid, self()},
	client:log(Name, "getmsgid gesendet"),
	receive
		{nid, Number} ->
			client:log(Name, "nid empfangen" ++ integer_to_list(Number))
	end,
	
	if (Anzahl =:= 0) ->
		client:log(Name, integer_to_list(Number) ++ ". Nachricht vergessen zu senden *****"),
		Gesendete;
	?Else ->
		% dropmessage
		Nachricht = "-" ++ Name ++ "Hallo",
		Server ! {dropmessage, {integer_to_list(Number) ++ Nachricht, Number}},
		client:log(Name, "dropmessage gesendet"),
		start(Name, Server, Anzahl-1, Gesendete ++ [Number])
	end
.%

