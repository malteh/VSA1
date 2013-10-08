rm logs/*.log
erl -make
cd bin
erl -s server start -setcookie asd -sname server -name server
cd ..