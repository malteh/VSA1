cd ..
rm logs/*.log
erl -make
cd bin
erl -s server test
pause