rm logs/*.log
erl -make
cd bin
erl -s client start_one -setcookie asd -sname client
cd ..
pause