@echo off
dir /s *.plb > plb.log
dir /s *-min*.js >> plb.log
dir /s *-min*.css >> plb.log
find ".plb" plb.log |more 
find ".js" plb.log  |more
find ".css" plb.log |more
del plb.log
pause

