-module(redakteur).

-export([start/2]).

start(Name, Server) ->
	client:log(Name, " ist jetzt im Redakteurmodus"),
	
	% getmsgid
	Server ! {getmsgid, self()},
	client:log(Name, "getmsgid gesendet"),
	receive
		{nid, Number} ->
			client:log(Name, "nid empfangen" ++ integer_to_list(Number))
	end,
	
	% dropmessage
	Nachricht = Name ++ "Hallo",
	Server ! {dropmessage, {Nachricht, Number}},
	client:log(Name, "dropmessage gesendet")
.%

