@echo off
set prefixo_arq=BI_156_
set pasta_release=v00
del /Q arquivos\*.*

echo --------------------------------------------------------------------------------
echo Versao %prefixo_arq%   Copiando Arquivos ..... 
echo --------------------------------------------------------------------------------
echo Packages  ..... 
copy ..\%pasta_release%\etl\plb\etl_head.plb       arquivos\%prefixo_arq%etl_head.plb
copy ..\%pasta_release%\bro\plb\bro_head.plb       arquivos\%prefixo_arq%bro_head.plb
copy ..\%pasta_release%\com\plb\com_head.plb       arquivos\%prefixo_arq%com_head.plb
copy ..\%pasta_release%\fcl\plb\fcl_head.plb       arquivos\%prefixo_arq%fcl_head.plb
copy ..\%pasta_release%\fun\plb\fun_head.plb       arquivos\%prefixo_arq%fun_head.plb
copy ..\%pasta_release%\gbl\plb\gbl_head.plb       arquivos\%prefixo_arq%gbl_head.plb
copy ..\%pasta_release%\imp\plb\imp_head.plb       arquivos\%prefixo_arq%imp_head.plb
copy ..\%pasta_release%\obj\plb\obj_head.plb       arquivos\%prefixo_arq%obj_head.plb
copy ..\%pasta_release%\sch\plb\sch_head.plb       arquivos\%prefixo_arq%sch_head.plb
copy ..\%pasta_release%\upq\plb\upquery_head.plb   arquivos\%prefixo_arq%upquery_head.plb
copy ..\%pasta_release%\upd\plb\upd_head.plb       arquivos\%prefixo_arq%upd_head.plb
copy ..\%pasta_release%\core\plb\core_head.plb     arquivos\%prefixo_arq%core_head.plb
copy ..\%pasta_release%\upload\plb\upload_head.plb arquivos\%prefixo_arq%upload_head.plb

copy ..\%pasta_release%\etl\plb\etl.plb            arquivos\%prefixo_arq%etl.plb
copy ..\%pasta_release%\bro\plb\bro.plb            arquivos\%prefixo_arq%bro.plb
copy ..\%pasta_release%\com\plb\com.plb            arquivos\%prefixo_arq%com.plb
copy ..\%pasta_release%\fcl\plb\fcl.plb            arquivos\%prefixo_arq%fcl.plb
copy ..\%pasta_release%\fun\plb\fun.plb            arquivos\%prefixo_arq%fun.plb
copy ..\%pasta_release%\gbl\plb\gbl.plb            arquivos\%prefixo_arq%gbl.plb
copy ..\%pasta_release%\imp\plb\imp.plb            arquivos\%prefixo_arq%imp.plb
copy ..\%pasta_release%\obj\plb\obj.plb            arquivos\%prefixo_arq%obj.plb
copy ..\%pasta_release%\sch\plb\sch.plb            arquivos\%prefixo_arq%sch.plb
copy ..\%pasta_release%\upq\plb\upquery.plb        arquivos\%prefixo_arq%upquery.plb
copy ..\%pasta_release%\upd\plb\upd.plb            arquivos\%prefixo_arq%upd.plb
copy ..\%pasta_release%\core\plb\core.plb          arquivos\%prefixo_arq%core.plb
copy ..\%pasta_release%\upload\plb\upload.plb      arquivos\%prefixo_arq%upload.plb

copy ..\..\..\up_rel\up_rel\1.3.10\up_rel.plb           arquivos\%prefixo_arq%up_rel.plb
copy ..\..\..\up_rel\up_rel\1.3.10\up_rel_head.plb      arquivos\%prefixo_arq%up_rel_head.plb
copy ..\..\..\auxi\auxi\ver1.5\aux.plb                 arquivos\%prefixo_arq%aux.plb
copy ..\..\..\auxi\auxi\ver1.5\aux_head.plb            arquivos\%prefixo_arq%aux_head.plb

echo Arquivos  ..... 
copy ..\%pasta_release%\web\default-min.js         arquivos\%prefixo_arq%default-min.js
copy ..\%pasta_release%\web\default-min.css        arquivos\%prefixo_arq%default-min.css
copy ..\..\..\plugins\xlsx.mini.min.js             arquivos\%prefixo_arq%xlsx.mini.min.js
copy ..\%pasta_release%\web\temas\dark.css         arquivos\%prefixo_arq%dark.css
copy ..\%pasta_release%\web\temas\evergreen.css    arquivos\%prefixo_arq%evergreen.css
copy ..\%pasta_release%\web\temas\florest.css      arquivos\%prefixo_arq%florest.css
copy ..\%pasta_release%\web\temas\ideativo.css     arquivos\%prefixo_arq%ideativo.css



echo Imagens ..... 
copy ..\..\..\imagens\arrow_new.svg                arquivos\%prefixo_arq%arrow_new.svg
copy ..\..\..\imagens\alteracao_lapis.svg          arquivos\%prefixo_arq%alteracao_lapis.svg

echo Padroes / Constantes / PLSQLs ..... 
copy ..\update_scripts\padroes_todos.sql              arquivos\%prefixo_arq%padroes_todos.sql
copy ..\update_scripts\constantes_todos.sql           arquivos\%prefixo_arq%constantes_todos.sql
copy ..\update_scripts\plsql_todos.sql                arquivos\%prefixo_arq%plsql_todos.sql

echo --------------------------------------------------------------------------------
echo Versao: %prefixo_arq%  Pasta Release: %pasta_release%  Transferindo arquivos ..... 
echo --------------------------------------------------------------------------------

"C:\Program Files (x86)\WinSCP\winscp" /ini=nul /script=ftp_script.txt

echo --------------------------------------------------------------------------------
echo Fim - Execute as procedures 
echo --------------------------------------------------------------------------------

echo FIM. 

pause


