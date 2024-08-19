declare 
  ws_tp_objeto    varchar2(50);
  ws_nm_objeto    varchar2(50);
  cursor c1 is  
    select rowid from bi_auto_update_log 
      where tp_atualizacao = 'ATUALIZA'
        and tp_objeto      = ws_tp_objeto
        and nm_objeto      = ws_nm_objeto
        and id_situacao    = 'INICIO'
    order by id_auto_update desc;     
  --
  ws_rowid    rowid; 
  ws_count    number; 
  ws_count2    number; 
  ws_ds       varchar2(4000);       
  ws_ds2      varchar2(4000);       
  --
begin 
    --
    --
    --
    ws_tp_objeto := 'MANUTENCAO' ; 
    ws_nm_objeto := 'MANUT_SELECT'; 
    ---------------------------------------------------- 
    -- INICIO - select 
    ---------------------------------------------------- 
    select max(conteudo), min(conteudo) into ws_ds, ws_ds2 from var_conteudo where variavel in ('URL_AUTOUPDATE','URL_UPDATE');
    --
    ws_ds := 'URL : ' ||ws_ds||'  -  '||ws_ds2;
    ------------------------------------------------
    -- FIM - select 
    ------------------------------------------------
    --
    ---------------------------------------------------------------
    --  Atualiza Log do auto_update com o resultado da atualização 
    ---------------------------------------------------------------
    open  c1;
    fetch c1 into ws_rowid;
    close c1; 
    --
    update bi_auto_update_log set ds_atualizacao = ws_ds where rowid = ws_rowid;
    commit;
    --
exception when others then 
    ws_ds := 'Erro: '||substr(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,150); 
    update bi_auto_update_log set ds_atualizacao = ws_ds where rowid = ws_rowid;       
    insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values(sysdate, ws_nm_objeto||':'||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 'DWU', 'ERRO'); 
    commit; 
end; 