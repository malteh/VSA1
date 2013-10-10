rm logs/*.log
erl -make
cd bin
erl -s clients start_multiple -setcookie asd -sname clients
cd ..