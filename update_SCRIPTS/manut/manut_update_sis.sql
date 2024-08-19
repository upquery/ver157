declare 
    ws_passo   varchar2(20); 
    ws_count   number; 
begin 
    --
    -- Cria Job para baixar objetos e atualizar o SISTEMA ( não atualiza a UPD)
    ws_passo := '1';   
    sch.execute_now('UPD.AUTOUPDATE_JOB_ATUALIZA  ('''||gbl.getsistema||''', '''||gbl.getversion||''', ''DWU'')', 'N'); 
    --
exception when others then 
    insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values(sysdate, 'MANUT_UPDATE_SIS('||ws_Passo||'):'||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 'DWU', 'ERRO'); 
    commit; 
end; 