cd ..
erl -make
cd bin
erl -s queueverwalter test
cd ../tests
pause