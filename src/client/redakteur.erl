-module(redakteur).

-export([start/2]).

start(Name, Server) ->
	client:log(Name, " ist jetzt im Redakteurmodus"),
	% getmsgid
	Server ! {getmsgid, self()},
	client:log(Name, "getmsgid gesendet"),
	receive
		{nid, Number2} ->
			client:log(Name, "nid empfangen" ++ integer_to_list(Number2))
	end,
	% dropmessage
	{Nachricht1, Number} = {"Hallo", 1},
	Server ! {dropmessage, {Nachricht1, Number}},
	client:log(Name, "dropmessage gesendet")
.%

