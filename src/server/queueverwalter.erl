-module(queueverwalter).

-export([erzeuge_struktur/0, hole_nachricht/2, nachricht_einfuegen/3]).

erzeuge_struktur() ->
	% HBQ, DLQ
	{[], []}
.%

hole_nachricht(Nnr, Struktur) ->
	Nnr_neu = 2,
	Text = "T2",
	Terminated = true,
	{Nnr_neu, Text, Terminated}
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
	Struktur
.%