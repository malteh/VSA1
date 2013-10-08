-module(integrationstest).
-export([start/0]).

-define(Else, true).
-define(Logfile, '../logs/Integrationstest.log').

% start test
start() ->
	test_start_stop_server()
.%

test_start_stop_server() ->
	Server = spawn(fun() -> server:start() end),
	Status1 = process_info(Server),
	if Status1 /= undefined ->
		log("test_start_stop_server: gestartet"),
		server:name() ! stop,
		timer:sleep(100),
		Status2 = process_info(Server),
		if Status2 == undefined ->
			log("test_start_stop_server: gestoppt");
		?Else ->
			log("test_start_stop_server: FEHLER server nicht gestoppt")
		end;
	?Else ->
		log("test_start_stop_server: FEHLER server nicht gestartet")
	end
	
	
.%

log(Text) ->
	TextNewline = io_lib:format("~s~n", [Text]),
	werkzeug:logging(?Logfile, TextNewline)
.%