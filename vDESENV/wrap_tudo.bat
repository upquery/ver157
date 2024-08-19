@echo off
set pasta_plb=z_plb
set filelog=wrap_tudo.log

echo .
echo Gerando PLBs (pasta : %pasta_plb%) .... 

echo %date% %time% > %filelog% 

rem  --------------------------------------------------------------------------------
rem                        WRAP dos Heads 
rem  --------------------------------------------------------------------------------
wrap iname=cfg/cfg_head.sql           oname=%pasta_plb%/cfg/cfg_head.plb         >> %filelog%     
wrap iname=etl/etl_head.sql           oname=%pasta_plb%/etl/etl_head.plb         >> %filelog%     
wrap iname=etf/etf_head.sql           oname=%pasta_plb%/etf/etf_head.plb         >> %filelog%     
wrap iname=bro/bro_head.sql           oname=%pasta_plb%/bro/bro_head.plb         >> %filelog%
wrap iname=com/com_head.sql           oname=%pasta_plb%/com/com_head.plb         >> %filelog%
wrap iname=fcl/fcl_head.sql           oname=%pasta_plb%/fcl/fcl_head.plb         >> %filelog%
wrap iname=fun/fun_head.sql           oname=%pasta_plb%/fun/fun_head.plb         >> %filelog%
wrap iname=gbl/gbl_head.sql           oname=%pasta_plb%/gbl/gbl_head.plb         >> %filelog%
wrap iname=imp/imp_head.sql           oname=%pasta_plb%/imp/imp_head.plb         >> %filelog%
wrap iname=obj/obj_head.sql           oname=%pasta_plb%/obj/obj_head.plb         >> %filelog%
wrap iname=sch/sch_head.sql           oname=%pasta_plb%/sch/sch_head.plb         >> %filelog%
wrap iname=upq/upquery_head.sql       oname=%pasta_plb%/upq/upquery_head.plb     >> %filelog%
wrap iname=upd/upd_head.sql           oname=%pasta_plb%/upd/upd_head.plb         >> %filelog%
wrap iname=core/core_head.sql         oname=%pasta_plb%/core/core_head.plb       >> %filelog%
wrap iname=upload/upload_head.sql     oname=%pasta_plb%/upload/upload_head.plb   >> %filelog%
wrap iname=as_read/as_read_head.sql   oname=%pasta_plb%/as_read/as_read_head.plb >> %filelog%

rem  --------------------------------------------------------------------------------
rem                        WRAP dos Bodys 
rem  --------------------------------------------------------------------------------
wrap iname=cfg/cfg.sql           oname=%pasta_plb%/cfg/cfg.plb         >> %filelog%     
wrap iname=etl/etl.sql           oname=%pasta_plb%/etl/etl.plb         >> %filelog%
wrap iname=etf/etf.sql           oname=%pasta_plb%/etf/etf.plb         >> %filelog%
wrap iname=bro/bro.sql           oname=%pasta_plb%/bro/bro.plb         >> %filelog%
wrap iname=com/com.sql           oname=%pasta_plb%/com/com.plb         >> %filelog%
wrap iname=fcl/fcl.sql           oname=%pasta_plb%/fcl/fcl.plb         >> %filelog%
wrap iname=fun/fun.sql           oname=%pasta_plb%/fun/fun.plb         >> %filelog%
wrap iname=gbl/gbl.sql           oname=%pasta_plb%/gbl/gbl.plb         >> %filelog%
wrap iname=imp/imp.sql           oname=%pasta_plb%/imp/imp.plb         >> %filelog%
wrap iname=obj/obj.sql           oname=%pasta_plb%/obj/obj.plb         >> %filelog%
wrap iname=sch/sch.sql           oname=%pasta_plb%/sch/sch.plb         >> %filelog%
wrap iname=upq/upquery.sql       oname=%pasta_plb%/upq/upquery.plb     >> %filelog%
wrap iname=upd/upd.sql           oname=%pasta_plb%/upd/upd.plb         >> %filelog%
wrap iname=core/core.sql         oname=%pasta_plb%/core/core.plb       >> %filelog%
wrap iname=upload/upload.sql     oname=%pasta_plb%/upload/upload.plb   >> %filelog%
wrap iname=as_read/as_read.sql   oname=%pasta_plb%/as_read/as_read.plb >> %filelog%

del %filelog% >nul
echo OK

if %1X neq NX pause

