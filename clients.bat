rm logs/*.log
erl -make
cd bin
erl -s client start_multi -setcookie vsp -sname clients
cd ..