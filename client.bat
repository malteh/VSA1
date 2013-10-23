rm logs/*.log
erl -make
cd bin
erl -s client start_one -setcookie vsp -sname client
cd ..
pause