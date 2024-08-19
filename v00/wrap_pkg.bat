@echo off
set versao=1.5.7
set pasta_plb=../../../PLB/v00/%1
set usuario=DWUP
set senha=DWUP
set servico=DESENV_PDB
echo ----------------------------------------------------------------------------------------
echo ----- Criando PLB - [%1] - na pasta [%pasta_plb%]   
echo ----------------------------------------------------------------------------------------
wrap iname=%1_head.sql oname=%pasta_plb%/%2_head.plb
wrap iname=%1.sql      oname=%pasta_plb%/%2.plb
echo ----------------------------------------------------------------------------------------
echo ---- Compilando package [%1] nas base [%servico%] usuario [%usuario%]
echo ----------------------------------------------------------------------------------------
sqlplus %usuario%/%senha%@%servico% @%pasta_plb%/%2_head.plb
sqlplus %usuario%/%senha%@%servico% @%pasta_plb%/%2.plb
pause



