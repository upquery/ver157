set define off;
PROMPT 
PROMPT ------------------------------- CFG ---------------- 

@cfg/cfg_head.plb
@cfg/cfg.plb
SELECT LINE||'/'||POSITION||' - '||TEXT AS "LINHA/COLUNA - MENSAGEM" FROM all_errors WHERE NAME='CFG' AND SEQUENCE=1;
PROMPT 
PROMPT ------------------------------- ETL ---------------- 

@etl/etl_head.plb
@etl/etl.plb
SELECT LINE||'/'||POSITION||' - '||TEXT AS "LINHA/COLUNA - MENSAGEM" FROM all_errors WHERE NAME='ETL' AND SEQUENCE=1;
PROMPT 
PROMPT ------------------------------- ETF ---------------- 

@etf/etf_head.plb
@etf/etf.plb
SELECT LINE||'/'||POSITION||' - '||TEXT AS "LINHA/COLUNA - MENSAGEM" FROM all_errors WHERE NAME='ETF' AND SEQUENCE=1;
PROMPT 
PROMPT ------------------------------- FUN ---------------- 

@fun/fun_head.plb
@fun/fun.plb
SELECT LINE||'/'||POSITION||' - '||TEXT AS "LINHA/COLUNA - MENSAGEM" FROM all_errors WHERE NAME='FUN' AND SEQUENCE=1;
PROMPT 
PROMPT ------------------------------- GBL ---------------- 

@gbl/gbl_head.plb
@gbl/gbl.plb
SELECT LINE||'/'||POSITION||' - '||TEXT AS "LINHA/COLUNA - MENSAGEM" FROM all_errors WHERE NAME='GBL' AND SEQUENCE=1;
PROMPT 
PROMPT ------------------------------- CORE ---------------- 

@core/core_head.plb
@core/core.plb
SELECT LINE||'/'||POSITION||' - '||TEXT AS "LINHA/COLUNA - MENSAGEM" FROM all_errors WHERE NAME='CORE' AND SEQUENCE=1;
PROMPT
PROMPT ------------------------------- BRO ---------------- 

@bro/bro_head.plb
@bro/bro.plb
SELECT LINE||'/'||POSITION||' - '||TEXT AS "LINHA/COLUNA - MENSAGEM" FROM all_errors WHERE NAME='BRO' AND SEQUENCE=1;
PROMPT 
PROMPT ------------------------------- COM ---------------- 

@com/com_head.plb
@com/com.plb
SELECT LINE||'/'||POSITION||' - '||TEXT AS "LINHA/COLUNA - MENSAGEM" FROM all_errors WHERE NAME='COM' AND SEQUENCE=1;
PROMPT 
PROMPT ------------------------------- IMP ---------------- 

@imp/imp_head.plb
@imp/imp.plb
SELECT LINE||'/'||POSITION||' - '||TEXT AS "LINHA/COLUNA - MENSAGEM" FROM all_errors WHERE NAME='IMP' AND SEQUENCE=1;
PROMPT 
PROMPT ------------------------------- AS_READ ------------ 

@as_read/as_read_head.plb
@as_read/as_read.plb
SELECT LINE||'/'||POSITION||' - '||TEXT AS "LINHA/COLUNA - MENSAGEM" FROM all_errors WHERE NAME='AS_READ' AND SEQUENCE=1;
PROMPT 
PROMPT ------------------------------- OBJ ---------------- 

@obj/obj_head.plb
@obj/obj.plb
SELECT LINE||'/'||POSITION||' - '||TEXT AS "LINHA/COLUNA - MENSAGEM" FROM all_errors WHERE NAME='OBJ' AND SEQUENCE=1;
PROMPT 
PROMPT ------------------------------- SCH ---------------- 

@sch/sch_head.plb
@sch/sch.plb
SELECT LINE||'/'||POSITION||' - '||TEXT AS "LINHA/COLUNA - MENSAGEM" FROM all_errors WHERE NAME='SCH' AND SEQUENCE=1;
PROMPT 
PROMPT ------------------------------- UPD ---------------- 

@upd/upd_head.plb
@upd/upd.plb
SELECT LINE||'/'||POSITION||' - '||TEXT AS "LINHA/COLUNA - MENSAGEM" FROM all_errors WHERE NAME='UPD' AND SEQUENCE=1;
PROMPT 
PROMPT ------------------------------- UPQ ---------------- 

@upq/upquery_head.plb
@upq/upquery.plb
SELECT LINE||'/'||POSITION||' - '||TEXT AS "LINHA/COLUNA - MENSAGEM" FROM all_errors WHERE NAME='UPQ' AND SEQUENCE=1;
PROMPT 
PROMPT ------------------------------- UPLOAD ---------------- 

@upload/upload_head.plb
@upload/upload.plb
SELECT LINE||'/'||POSITION||' - '||TEXT AS "LINHA/COLUNA - MENSAGEM" FROM all_errors WHERE NAME='UPLOAD' AND SEQUENCE=1;
PROMPT 
PROMPT ------------------------------- FCL ---------------- 

@fcl/fcl_head.plb
@fcl/fcl.plb 
SELECT LINE||'/'||POSITION||' - '||TEXT AS "LINHA/COLUNA - MENSAGEM" FROM all_errors WHERE NAME='FCL' AND SEQUENCE=1;

set define on
PROMPT --------------------------------------------------------------- 

PROMPT --- Atualizando packages no usuario/banco &1 / &2 .....   

PROMPT 

exit;


