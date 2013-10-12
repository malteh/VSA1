cd ..
rm logs/*.log
erl -make
cd bin
erl -s integrationstest start
pause