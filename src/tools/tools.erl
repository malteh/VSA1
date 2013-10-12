-module(tools).
-export([now_milliseconds/0, now_seconds/0, read_config/1, contains/2]).

now_milliseconds() ->
	K = 1000,
	{Megasecs, Secs, Microsecs} = erlang:now(),
	MS = (Megasecs * K * K * K) + (Secs * K) + (Microsecs / K),
	MS
.%

now_seconds() ->
	now_milliseconds() / 1000
.%

read_config(Config) ->
	{ok, ConfigList} = file:consult(Config),
	ConfigList
.%

contains([], _) -> false;
contains([Elem|_], Elem) -> true;
contains([_|Tail],Elem ) -> contains(Tail, Elem)
.%