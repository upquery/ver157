declare 
    ws_passo   varchar2(20); 
    ws_count   number; 
begin 
    --
    -- Cria Job para baixar objetos e atualizar a UPD 
    --
    ws_passo := '1';   
    sch.execute_now('upd.AutoUpdate_job_baixa  ('''||gbl.getsistema||''', '''||gbl.getversion||''', ''DWU'')', 'N');
    --
exception when others then 
    insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values(sysdate, 'MANUT_UPDATE_UPD('||ws_Passo||'):'||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 'DWU', 'ERRO'); 
    commit; 
end; 