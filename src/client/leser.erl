-module(leser).
-export([start/3]).
-define(Else, true).

start(Name, Server, Bekannte_nachrichten) ->
	%client:log(Name, " ist jetzt im Lesermodus"),
	alle_nachrichten_holen(Name, Server, Bekannte_nachrichten, false)
.%

alle_nachrichten_holen(Name, _, _, true) ->
	_ = Name,
	client:log(Name, "..getmessages..Done..."),
	true;
alle_nachrichten_holen(Name, Server, Bekannte_nachrichten, false) ->
	% getmessages
	Server ! {getmessages, self()},
	receive
		
		{reply, Number1, Nachricht, Terminated} ->
			Ist_bekannt = tools:contains(Bekannte_nachrichten, Number1),
			if Ist_bekannt ->
				client:log(Name, Nachricht ++ "*****");
			?Else ->
				client:log(Name, Nachricht)
			end;
		stop -> 
			Terminated = true,
			halt()
	end,
	alle_nachrichten_holen(Name, Server, Bekannte_nachrichten, Terminated)
.%