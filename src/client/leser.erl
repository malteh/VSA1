-module(leser).

-export([start/2]).

start(Name, Server) ->
	client:log(Name, " ist jetzt im Lesermodus"),
	alle_nachrichten_holen(Name, Server, true)
.%

alle_nachrichten_holen(Name, _, true) ->
	client:log(Name, " Server hat keine Nachrichten mehr");
alle_nachrichten_holen(Name, Server, false) ->
	% getmessages
	Server ! {getmessages, self()},
	client:log(Name, "getmessages gesendet"),
	receive
		{reply, Number1, Nachricht, Terminated} ->
			client:log(Name, "reply" ++ integer_to_list(Number1) ++ Nachricht ++ atom_to_list(Terminated))
	end,
	alle_nachrichten_holen(Name, Server, Terminated)
.%