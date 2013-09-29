rm logs/*.log
erl -make
cd bin
erl -s server start