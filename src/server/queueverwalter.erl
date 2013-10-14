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
	[{FirstDLQ, Text}|TDLQ] = DLQ,
	if FirstDLQ > Nnr ->
		Flag = (TDLQ=:=[]),
	%	%if TDLQ=:=[] ->
	%	%	Flag = false;
	%	%?Else ->
	%	%	[{Nr,_Text}|_Tail] = TDLQ,
	%	%	Flag = (Nr =:= FirstDLQ+1)
	%	%end,
		{FirstDLQ, Text, Flag};
	?Else ->
		naechste_nachricht(Nnr, TDLQ)
	end
.%

nachricht_einfuegen(Nnr, Text, Struktur) ->
	{HBQ, DLQ} = Struktur,
	Elem = {Nnr, Text ++ "Eingang HBQ:" ++ tools:time_string()},
	HBQ_neu = tools:pushSL(HBQ, Elem),
	hbq_pruefen({HBQ_neu, DLQ})
.%

hbq_pruefen(Struktur) ->
	{HBQ, DLQ} = Struktur,
	
	%if (length(HBQ) > MaxDLQsize/2) ->
	%	erzeuge_fehlernachricht(HBQ, DLQ);
	%?Else ->
	%	uebertrage(HBQ, DLQ)
	%end
	
	MaxDLQsize = dlqlimit(),
	if (length(HBQ) > MaxDLQsize/2) ->
		uebertrage(HBQ, DLQ);
	?Else ->
		Struktur
	end
.%

uebertrage([], DLQ) ->
	{[], DLQ};
uebertrage(HBQ, DLQ) ->
	if length(DLQ) =:= 0 ->
		Nnr_DLQ_last = 0;
	?Else ->
		{Nnr_DLQ_last, _Text} = lists:last(DLQ)
	end,

	[HBQ_first|HBQtail] = HBQ,
	{Nnr_HBQ_first, Text_HBQ_first} = HBQ_first,
	Text_neu = Text_HBQ_first ++ "; Eingang DLQ:" ++ tools:time_string(),
	HBQ_first_neu = {Nnr_HBQ_first, Text_neu},
	if Nnr_DLQ_last =:= Nnr_HBQ_first-1 ->
		server:log(integer_to_list(Nnr_HBQ_first) ++ " jetzt in DLQ"),
		A = uebertrage(HBQtail, kuerzeWennDLQZuLang(DLQ++[HBQ_first_neu]));
	?Else ->
		A = erzeuge_fehlernachricht(HBQ, DLQ)
		%{HBQ, DLQ}
	end,
	hbq_pruefen(A)
.%

erzeuge_fehlernachricht(HBQ, DLQ) ->
	[{Nnr_HBQ_first,_Text}|_T] = HBQ,
	%if length(DLQ) =:= 0 ->
	%	Nr1 = 0;
	%?Else ->
	%	{Nr1, _Text1} = lists:last(DLQ)
	%end,
	Fehlernachricht_text = io_lib:format("***Fehlernachricht fuer Nachrichtennummern ~w bis ~w. ", [letzte_nnr(DLQ)+1, Nnr_HBQ_first - 1]),
	server:log(Fehlernachricht_text),
	Nr = Nnr_HBQ_first - 1,
	Fehlernachricht = {Nr, Fehlernachricht_text ++ tools:time_string()},
	{HBQ,	kuerzeWennDLQZuLang(DLQ++[Fehlernachricht])}
.%

letzte_nnr([]) ->
	0;
letzte_nnr(Q) ->
	{Nnr, _} = lists:last(Q),
	Nnr
.%

%kuerzeWennDLQZuLang(List) ->
%	List
%.%
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
	test_erzeuge_fehlernachricht(),
	test_nachricht_einfuegen(),
	io:format("ok~n",[]),
	halt()
.%

test_nachricht_einfuegen() ->
	S = erzeuge_struktur(),
	T1 = nachricht_einfuegen(1, "", S),
	{[], [{1,_}]} = T1,
	
	T2 = nachricht_einfuegen(3, "", T1),
	{[{3,_}], [{1,_}]} = T2,
	
	T3 = nachricht_einfuegen(5, "", T2),
	{[{3,_}, {5,_}], [{1,_}]} = T3,
	
	T4 = nachricht_einfuegen(4, "", T3),
	{[], [{1, _}, {2, _}, {3, _}, {4, _}, {5, _}]} = T4
.%

test_erzeuge_fehlernachricht() ->
	HBQ = [{5, ""}, {6, ""}],
	DLQ = [{1, ""}, {2, ""}],
	{[], [{1, ""}, {2, ""}, {4, _}, {5, _}, {6, _}]} = erzeuge_fehlernachricht(HBQ, DLQ)
.%

test_naechste_nachricht() ->
	HBQ = [],
	DLQ = [{1, ""}, {2, ""}, {3, ""}, {4, ""}, {5, ""}, {6, ""}],
	{1, _, false} = naechste_nachricht( 0, {HBQ, DLQ}),
	{2, _, false} = naechste_nachricht( 1, {HBQ, DLQ}),
	{3, _, false} = naechste_nachricht( 2, {HBQ, DLQ}),
	{4, _, false} = naechste_nachricht( 3, {HBQ, DLQ}),
	{5, _, false} = naechste_nachricht( 4, {HBQ, DLQ}),
	{6, _, true } = naechste_nachricht( 5, {HBQ, DLQ})
.%