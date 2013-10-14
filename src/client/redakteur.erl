-module(redakteur).

-export([start/5]).
-define(Else, true).

start(Name, Server, Anzahl, Gesendete, Sendeintervall) ->
	client:log(Name, ": Redakteurmodus"),
	
	% getmsgid
	Server ! {getmsgid, self()},
	client:log(Name, "getmsgid gesendet"),
	receive
		{nid, Number} ->
			client:log(Name, "nid empfangen" ++ integer_to_list(Number))
	end,	
	Sendeintervall_neu = neues_sendeintervall(Sendeintervall, Gesendete, Anzahl),
	receive
		after Sendeintervall_neu ->
			client:log(Name, "Sendeintervall_neu:" ++ integer_to_list(Sendeintervall_neu)),
			true
	end,
	if (Anzahl =:= 0) ->
		client:log(Name, integer_to_list(Number) ++ ". Nachricht um " ++ tools:time_string() ++ " vergessen zu senden *****"),
		Gesendete;
	?Else ->
		% dropmessage
		{ok, Hostname} = inet:gethostname(),
		Nachricht = integer_to_list(Number) ++ "-" ++ Name ++ "@" ++ Hostname ++ "-Gruppe:" ++ integer_to_list(team:gruppe()) ++ "-Team:" ++ integer_to_list(team:nummer()) ++ "-Sendezeit:" ++ tools:time_string(),
		Server ! {dropmessage, {Nachricht, Number}},
		client:log(Name, "dropmessage gesendet"),
		start(Name, Server, Anzahl-1, Gesendete ++ [Number], Sendeintervall_neu)
	end
.%

neues_sendeintervall(Sendeintervall, Gesendete, Anz_pro_runde) ->
	Anz_gesendete = length(Gesendete),

	if ((Anz_gesendete rem Anz_pro_runde) =:= 0) and (Anz_gesendete =/= 0) ->
		D = tools:max_in_list([Sendeintervall/2, 1]),
		Plus_Minus = random:uniform(2),
		
		if (Plus_Minus - 1 =:= 0) ->
			S_neu = Sendeintervall + D;
		?Else ->
			S_neu = Sendeintervall - D
		end,
		Sendeintervall_neu = tools:max_in_list([2, S_neu]);
	?Else ->
		Sendeintervall_neu = Sendeintervall
	end,
	round(Sendeintervall_neu)
.%