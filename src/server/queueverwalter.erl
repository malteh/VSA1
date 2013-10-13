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
	Elem = {Nnr, {Text ++ "Eingang HBQ:" ++ tools:time_string(), Eingang_HBQ, Eingang_DLQ}},
	HBQ_neu = werkzeug:pushSL(HBQ, Elem),
	hbq_pruefen({HBQ_neu, DLQ})
.%

hbq_pruefen(Struktur) ->
	{HBQ, DLQ} = Struktur,
	
	MaxDLQsize = dlqlimit(),
	if (length(HBQ) > MaxDLQsize/2) ->
		erzeugeFehlernachricht(HBQ, DLQ);
	?Else ->
		uebertrage(HBQ, DLQ)
	end
.%

uebertrage([], DLQ) ->
	{[], DLQ};
uebertrage(HBQ, DLQ) ->
	if length(DLQ) =:= 0 ->
		Nnr_DLQ_last = 0;
	?Else ->
		{Nnr_DLQ_last, _Nachricht} = lists:last(DLQ)
	end,

	[HBQ_first|HBQtail] = HBQ,
	{Nnr_HBQ_first, _Nachricht_HBQ_first} = HBQ_first,
	if Nnr_DLQ_last =:= Nnr_HBQ_first-1 ->
		server:log("Nachricht " ++ integer_to_list(Nnr_HBQ_first) ++ " jetzt in DLQ"),
		uebertrage(HBQtail, kuerzeWennDLQZuLang(DLQ++[HBQ_first]));
	?Else ->
		{HBQ, DLQ}
	end
.%

erzeugeFehlernachricht(HBQ, DLQ) ->
	[{Nnr_HBQ_first,_Nachricht}|_T] = HBQ,
	%if length(DLQ) =:= 0 ->
	%	Nr1 = 0;
	%?Else ->
	%	{Nr1, _Nachricht1} = lists:last(DLQ)
	%end,
	Fehlernachricht_text = io_lib:format("Fehlernachricht ~w bis ~w.", [letzte_nnr(DLQ), Nnr_HBQ_first - 1]),
	Nr = Nnr_HBQ_first - 1,
	Fehlernachricht = {Nr, {Fehlernachricht_text, 0, 0}},
	uebertrage(HBQ,	kuerzeWennDLQZuLang(DLQ++[Fehlernachricht]))
.%

letzte_nnr([]) ->
	0;
letzte_nnr(Q) ->
	{Nnr, _} = lists:last(Q),
	Nnr
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