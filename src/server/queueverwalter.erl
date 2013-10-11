-module(queueverwalter).
-export([erzeuge_struktur/0, naechste_nachricht/2, nachricht_einfuegen/3]).
-define(Else, true).

erzeuge_struktur() ->
	% HBQ, DLQ
	{[], []}
.%

naechste_nachricht(Nnr, Struktur) ->
	{_, DLQ} = Struktur,
	[{FirstDLQ, Nachricht}|TDLQ] = DLQ,
	if FirstDLQ > Nnr ->
		if TDLQ=:=[] ->
			Flag = false;
		?Else ->
			[{Nr,_Nachr}|_Tail] = TDLQ,
			Flag = (Nr =:= FirstDLQ+1)
		end,
		{FirstDLQ, Nachricht, Flag};
	?Else ->
		naechste_nachricht(TDLQ, Nnr)
	end
.%

nachricht_einfuegen(Nnr, Nachricht, Struktur) ->
	{HBQ, DLQ} = Struktur,
	Eingang_HBQ = tools:now_seconds(),
	Eingang_DLQ = 0,
	Elem = {Nnr, {Nachricht, Eingang_HBQ, Eingang_DLQ}},
	HBQ_neu = werkzeug:pushSL(HBQ, Elem),
	umsortieren({HBQ_neu, DLQ})
.%

umsortieren(Struktur) ->
	{HBQ, DLQ} = Struktur,
	MaxDLQsize = dlqlimit(),
	if (length(HBQ) > MaxDLQsize/2) ->
		erzeugeFehlernachricht(HBQ, DLQ);
	?Else ->
		uebertrage(HBQ, DLQ)
	end,
	Struktur
.%

uebertrage([], DLQ) ->
	{[], DLQ};
uebertrage(HBQ, DLQ) ->
	if length(DLQ) =:= 0 ->
		Nr1 = 0;
	?Else ->
		{Nr1, _Nachricht1} = lists:last(DLQ)
	end,

	[{Nr2, Nachricht2}|HBQtail] = HBQ,
	if Nr1 =:= Nr2-1 ->
		client:log("", "Nachricht ~w jetzt in DLQ\n",[Nr2]),
		uebertrage(HBQtail, kuerzeWennDLQZuLang(DLQ++[{Nr2, Nachricht2}]));
	?Else ->
		{HBQ, DLQ}
	end
.%

erzeugeFehlernachricht(HBQ, DLQ) ->
	[{Nr,_Nachricht}|_T] = HBQ,
	if length(DLQ) =:= 0 ->
		Nr1 = 0;
	?Else ->
		{Nr1, _Nachricht1} = lists:last(DLQ)
	end,
	uebertrage(HBQ,	kuerzeWennDLQZuLang(DLQ++[{Nr - 1, io_lib:format("Fehlernachricht ~w bis ~w.", [Nr1, Nr - 1])}]))
.%

kuerzeWennDLQZuLang(List) ->
	MaxDLQsize = dlqlimit(),
	kuerzeWennDLQZuLang(List, MaxDLQsize).
kuerzeWennDLQZuLang([], _Max) ->
	[];
kuerzeWennDLQZuLang(DLQ, Max) ->
	if length(DLQ) > Max ->
		[_H|T]=DLQ,
		kuerzeWennDLQZuLang(T, Max);
	?Else ->
		DLQ
	end
.%

dlqlimit() ->
	{ok, Dlqlimit} = werkzeug:get_config_value(dlqlimit, tools:read_config(server:config_file())),
	Dlqlimit
.%