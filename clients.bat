rm logs/*.log
erl -make
cd bin
erl -s clients start -setcookie asd -sname clients
cd ..