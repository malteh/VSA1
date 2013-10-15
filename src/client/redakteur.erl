-module(redakteur).

-export([start/5]).
-define(Else, true).

start(Name, Server, Anzahl, Gesendete, Sendeintervall) ->
	% getmsgid
	Server ! {getmsgid, self()},
	receive
		{nid, Number} ->
			true
	end,
	Sendeintervall_neu = neues_sendeintervall(Sendeintervall, Gesendete, Anzahl),
	receive
		stop -> halt()
		after Sendeintervall_neu ->
			true
	end,
	{ok, Hostname} = inet:gethostname(),
	if (Anzahl =:= 0) ->
		client:log(Name, "Neues Sendeintervall: " ++ integer_to_list(Sendeintervall_neu) ++ " Sekunden (" ++ integer_to_list(Sendeintervall) ++ ")."),
		client:log(Name, Name ++ "@" ++ Hostname ++ ": " ++ integer_to_list(Number) ++ ". Nachricht um " ++ tools:time_string() ++ " vergessen zu senden *****"),
		client:log(Name, "..dropmessage..Done..."),
		Gesendete;
	?Else ->
		% dropmessage
		Nachricht = Name ++ "@" ++ Hostname ++ ": " ++ integer_to_list(Number) ++ ". Nachricht-" ++ "-Gruppe:" ++ integer_to_list(team:gruppe()) ++ "-Team:" ++ integer_to_list(team:nummer()) ++ "-Sendezeit:" ++ tools:time_string(),
		Server ! {dropmessage, {Nachricht, Number}},
		client:log(Name, Nachricht),
		start(Name, Server, Anzahl-1, Gesendete ++ [Number], Sendeintervall_neu)
	end
.%

neues_sendeintervall(Sendeintervall, Gesendete, Anz_pro_runde) ->
	Anz_gesendete = length(Gesendete),

	if ((Anz_gesendete rem Anz_pro_runde) =:= 0) and (Anz_gesendete =/= 0) ->
		D = tools:max_in_list([Sendeintervall/2, 1000]),
		Plus_Minus = random:uniform(2),
		
		if (Plus_Minus - 1 =:= 0) ->
			S_neu = Sendeintervall + D;
		?Else ->
			S_neu = Sendeintervall - D
		end,
		Sendeintervall_neu = tools:max_in_list([2000, S_neu]);
	?Else ->
		Sendeintervall_neu = Sendeintervall
	end,
	round(Sendeintervall_neu)
.%