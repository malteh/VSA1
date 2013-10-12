-module(queueverwalter).
-export([erzeuge_struktur/0, naechste_nachricht/2, nachricht_einfuegen/3, test/0]).
-define(Else, true).

erzeuge_struktur() ->
	% HBQ, DLQ
	{[], []}
.%

naechste_nachricht(Nnr, {_, DLQ}) ->
	naechste_nachricht(Nnr, DLQ);
naechste_nachricht(Nnr, []) ->
	{Nnr, "Nichts da", true};
naechste_nachricht(Nnr, DLQ) ->
	[{FirstDLQ, {Text, _EHBQ, _EDLQ}}|TDLQ] = DLQ,
	if FirstDLQ > Nnr ->
		Flag = (TDLQ=:=[]),
	%	%if TDLQ=:=[] ->
	%	%	Flag = false;
	%	%?Else ->
	%	%	[{Nr,_Nachr}|_Tail] = TDLQ,
	%	%	Flag = (Nr =:= FirstDLQ+1)
	%	%end,
		{FirstDLQ, Text, Flag};
	?Else ->
		naechste_nachricht(Nnr, TDLQ)
	end
.%

nachricht_einfuegen(Nnr, Text, Struktur) ->
	{HBQ, DLQ} = Struktur,
	Eingang_HBQ = tools:now_seconds(),
	Eingang_DLQ = 0,
	Elem = {Nnr, {Text, Eingang_HBQ, Eingang_DLQ}},
	HBQ_neu = werkzeug:pushSL(HBQ, Elem),
	hbq_pruefen({HBQ_neu, DLQ})
.%

hbq_pruefen(Struktur) ->
	{HBQ, DLQ} = Struktur,
	
	MaxDLQsize = dlqlimit(),
	%if (length(HBQ) > MaxDLQsize/2) ->
	%	erzeugeFehlernachricht(HBQ, DLQ);
	%?Else ->
	%	uebertrage(HBQ, DLQ)
	%end
	
	{HBQ, DLQ}
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
		server:log("Nachricht " ++ integer_to_list(Nr2) ++ " jetzt in DLQ"),
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
	Fehlernachricht = io_lib:format("Fehlernachricht ~w bis ~w.", [Nr1, Nr - 1]),
	uebertrage(HBQ,	kuerzeWennDLQZuLang(DLQ++[{Nr - 1, Fehlernachricht}]))
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

%%% TESTS

test() ->
	test_naechste_nachricht(),
	io:format("ok~n",[]),
	halt()
.%

test_naechste_nachricht() ->
	HBQ = [],
	DLQ = [{1, {"", 1, 2}}, {2, {"", 1, 2}}, {3, {"", 1, 2}}, {4, {"", 1, 2}}, {5, {"", 1, 2}}, {6, {"", 1, 2}}],
	{1, _, false} = naechste_nachricht( 0, {HBQ, DLQ}),
	{2, _, false} = naechste_nachricht( 1, {HBQ, DLQ}),
	{3, _, false} = naechste_nachricht( 2, {HBQ, DLQ}),
	{4, _, false} = naechste_nachricht( 3, {HBQ, DLQ}),
	{5, _, false} = naechste_nachricht( 4, {HBQ, DLQ}),
	{6, _, true} = naechste_nachricht( 5, {HBQ, DLQ})
.%