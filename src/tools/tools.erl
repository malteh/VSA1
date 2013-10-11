-module(tools).
-export([now_milliseconds/0, now_seconds/0]).

now_milliseconds() ->
	K = 1000,
	{Megasecs, Secs, Microsecs} = erlang:now(),
	MS = (Megasecs * K * K * K) + (Secs * K) + (Microsecs / K),
	MS
.%

now_seconds() ->
	now_milliseconds() / 1000
.%