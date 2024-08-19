create or replace package body  SCH  is

procedure main as

    ws_sysdate      date;
    ws_hora         varchar2(2);
    ws_quarter      varchar2(2);
    ws_auto         char(1);
    ws_hr_baixa     number;
    ws_dh_atu       date; 
    ws_hr_atu_aux   varchar2(20); 
    ws_hr_atu       number; 
    ws_mn_atu       number; 

    ws_req           varchar2(200);
    ws_res           varchar2(800);
    ws_ultimo        date;
    ws_atual         date;
    ws_dt_ultimo_job   date; 
    ws_dt_ultima_limp  date; 

    ws_count         number := 0;
    ws_count_job     number := 0; 
    ws_count_rel     number := 0;

    ws_conteudo     varchar2(80);
    ws_temp_rel     varchar2(80);
    ws_aux          VARCHAR2(20); 
    ws_jah_executou number; 
    --
    -------------------------------------------------------------------------------------------------------------------------
    PROCEDURE AUTOUPDATE_BAIXA_TODOS is 
    begin 
        begin ws_hr_baixa := to_number(trim(nvl(sch.ret_var('HR_AUTOUPDATE_BAIXA'),'19'))); 
        exception when others then ws_hr_baixa := 19; 
        end;  
        if ws_hr_baixa = ws_hora then 
            select count(*) into ws_jah_executou from bi_auto_update_log 
             where tp_objeto      = 'TODOS' 
               and nm_objeto      = 'TODOS'
               and tp_atualizacao = 'BAIXA'
               and id_situacao    = 'FIM'
               and dt_inicio     >= trunc(sysdate)
               and to_number(to_char(dt_inicio,'HH24')) >= ws_hr_baixa ;
            if ws_jah_executou = 0 then 
                sch.execute_now('upd.AutoUpdate_job_baixa  ('''||gbl.getsistema||''', '''||gbl.getversion||''', ''DWU'')', 'N');   -- Cria Job para baixar objetos e atualizar a UPD 
            end if;
        end if;
    end AUTOUPDATE_BAIXA_TODOS; 

begin

    ws_sysdate := sysdate; 
    ws_hora    := trim(to_char(sysdate,'HH24'));
    ws_quarter := to_char(sysdate,'MI');
    
    
    -- Processo para encerrar os relatórios trancados por mais de x tempo (designado em minutos na var_conteudo)
    -------------------------------------------------------------------------------------------------------------------
    ws_temp_rel := nvl(sch.ret_var('EXPIRA_REL','DWU'),0);
    select count(*) into ws_count_rel from all_jobs where what like 'SCH.FINALIZA_REL';
    if ((ws_count_rel = 0) and (ws_temp_rel <> 0)) then
        sch.execute_now('sch.finaliza_rel('||ws_temp_rel||')', 'N');         --Ainda em testes deixar comentado até garantir 100% que não tranca o sistema
    end if;
    

    -- Processo EMAIL de RELATÓRIOS/TELAS  - agendados para envio 
    --------------------------------------------------------------------------------------------
    begin    
        sch.execute_now('com.reportExec', 'N');   --   comunicação com email 
    exception when others then
        insert into bi_log_sistema values (sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - SCH', 'SYS', 'ERRO');
        commit;
    end;


    -- Limpa logs do sistema - roda somente uma vez por mês na virada do mês (quando a data da ultima atualização não for do mês corrente)  
    --------------------------------------------------------------------------------------------
    ws_dt_ultima_limp := null; 
    begin 
        ws_dt_ultima_limp := to_date(sch.ret_var('ULTIMA_LIMPEZA_LOG','DWU'), 'dd/mm/yyyy');  
    exception when others then null; 
    end;    
    ws_dt_ultima_limp := nvl(ws_dt_ultima_limp, (trunc(sysdate,'month')-1)) ;   -- Se não tem data parametrizada ainda ou deu erro na busca da var_conteudo, força a execução da limpeza colocando data do mês anterior 
    if trunc(ws_dt_ultima_limp,'month') < trunc(sysdate,'month') then
        sch.execute_now('sch.limpa_logs_sistema', 'N');
    end if;   
    

    -- Novo processo de execução de tarefas de integração (ETL)
    --------------------------------------------------------------------------------------------
    sch.execute_now('etf.exec_schdl', 'N');


    -- Envia status das últimas tarefas executadas para a base ADM da UPQ (a cada 10 minutos)
    if mod(to_number(ws_quarter), 10) = 0 then 
        sch.execute_now('etf.etl_envio_status', 'N');
    end if; 


    -- a cada 15 minutos -- Baixa atualização do sistema e Também atualiza UPD
    --------------------------------------------------------------------------------------------
    if mod(to_number(ws_quarter), 15) = 0 then 
        AUTOUPDATE_BAIXA_TODOS;  
    end if; 


    -- a cada 5 minutos - Atualiza versão do sistema (menos SCH, ETF e UPD) (se houver atualização disponível)
    --------------------------------------------------------------------------------------------
    if mod(to_number(ws_quarter), 5) = 0 then 
        if nvl(sch.ret_var('HR_AUTOUPDATE_ATU'),'N/A') <> 'N/A' then 
            sch.autoupdate_atualiza('BI'); 
            -- sch.autoupdate_atualiza('ETL','SCH'); 
            -- sch.autoupdate_atualiza('ETL','ETF'); -- Colocado no job_quarter 
        end if; 
    end if; 


    -- a cada 15 minutos - Executa o JOB_QUARTER a cada 15 minutos (se o o Job não estiver bloqueado)   
    --------------------------------------------------------------------------------------------
    if mod(to_number(ws_quarter), 15) = 0 then 
        if nvl(sch.ret_var('BLOQ_QUARTER'), 'N') = 'S' then -- -- ADICIONADO UMA CONDIÇÃO PARA BLOQUEAR O JOB_QUARTER PELO BI QUANDO NECESSARIO. 24/02/2022
            insert into bi_log_sistema values (sysdate,'JOB QUARTER BLOQUEADO','DWU','EVENTO');
            commit;
        else 
            sch.execute_now('sch.job_quarter', 'N');
        end if;
    end if; 
    
    -- a cada 15 minutos - Cria Job para busca e execução de novos SQLs de manutenção do sistem (se houver)
    --                   - Cria job para envio dos logs de atualização/manutenção do sistema (SE HOUVER)
    --------------------------------------------------------------------------------------------
    if mod(to_number(ws_quarter), 15) = 0 then 
        sch.execute_now('upd.AutoUpdate_job_manutencao  ('''||gbl.getsistema||''', '''||gbl.getversion||''', ''DWU'')', 'N'); 
        select count(*) into ws_count from bi_auto_update_log where nvl(id_enviado,'N') = 'N';
        if ws_count > 0 then 
            sch.execute_now('UPD.AutoUpdate_envia_log (''DWU'')', 'N');
        end if; 
    end if;


    delete from bi_token where dt_envio < sysdate-1 and status <> 'D';
    commit;

exception when others then
    insert into bi_log_sistema values (sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - SCH', 'SYS', 'ERRO');
    commit;
end main;

--CRIADA PARA MATAR OS JOBS DE RELATÓRIOS COM X TEMPO , TEMPO DEFINIDO NA VAR_CONTEUDO 25/04/22
PROCEDURE finaliza_rel (prm_tempo VARCHAR2 DEFAULT NULL) AS

     CURSOR crs_relatorios IS
            SELECT 	job,NEXT_DATE,TO_CHAR(SYSDATE,'dd/mon/yyyy HH24:MI:SS','NLS_DATE_LANGUAGE = AMERICAN') AS DATA1,
                        to_char(next_date,'dd/mm/yyyy hh24:mi:ss') AS DATA2,
                    substr(what,instr(what,'(',1)+2,instr(what,',',1)- instr(what,'(',1)-3) AS nm_objeto,
                    substr(what,instr(what,',',1,4)+2,instr(what,')',1)- instr(what,',',1,4)-3) AS nm_usuario
            FROM	all_jobs
            WHERE	what LIKE '%up_rel%'
            AND
                trunc((sysdate-to_date(to_char(next_date,'dd/mm/yyyy hh24:mi:ss'),'dd/mm/yyyy hh24:mi:ss'))*1440)>= prm_tempo;

        ws_variaveis	crs_relatorios%ROWTYPE;
        WS_COUNT        NUMBER;
        ws_kill_session varchar2(500);

BEGIN
    WS_COUNT :=0;

   /* SELECT 	COUNT(*) INTO WS_COUNT
      FROM	all_jobs
     WHERE	what LIKE '%up_rel%' 
       AND     trunc((sysdate-to_date(to_char(next_date,'dd/mm/yyyy hh24:mi:ss')))*1440)>= prm_tempo;*/
    
   -- IF WS_COUNT > 0 THEN
        OPEN crs_relatorios;
            LOOP
        

                FETCH crs_relatorios INTO ws_variaveis;
                EXIT WHEN crs_relatorios%notfound;
                
                ws_kill_session:=null;
                Select max('alter system kill session '||Chr(39)||Sid||','||Serial#||Chr(39)||'') into ws_kill_session From V$session Where action = 'DBMS_JOB$_'||ws_variaveis.job;

                dbms_job.remove(ws_variaveis.job);
                
                if ws_kill_session is not null then
                    begin
                        execute immediate ws_kill_session;
                    exception
                      when others then
                        INSERT INTO bi_log_sistema VALUES (sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - SCH.FINALIZA_REL-KILL-SESSION', 'SYS', 'ERRO');
                        COMMIT;
                    end; 
                end if;


                UPDATE TAB_DOCUMENTOS
                SET
                CONTENT_TYPE = 'ERROR'
                WHERE NAME LIKE 'REL_'||ws_variaveis.nm_objeto||'_'||ws_variaveis.nm_usuario||'_%';

                COMMIT;
            end loop;
        CLOSE crs_relatorios;
    --END IF;
    
EXCEPTION
  WHEN others THEN

  INSERT INTO bi_log_sistema VALUES (sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - SCH.FINALIZA_REL', 'SYS', 'ERRO');
  COMMIT;

END finaliza_rel;




procedure JOB_QUARTER ( prm_check varchar2 default null ) as 

    ws_reg_online       varchar2(100);
    ws_noact            exception;
    ws_timeout          exception;
    ws_erro             varchar2(4000);
    ws_vartemp          varchar2(100);
    ws_try              number;
    ws_check            number     := 0;
    ws_count            number;
    ws_aux              varchar2(20);   

    ws_owner      varchar2(90);
    ws_name       varchar2(90);
    ws_line       number;
    ws_caller     varchar2(90);
    ws_dh_inicio      date; 
    ws_comando_job    varchar2(10000);   

    procedure NESTED_STATUS_PROCESS ( prm_cd_processo varchar2,
                                      prm_ds_processo varchar2,
                                      prm_comando     varchar2) as

      ws_check_run      number := 0;
      ws_saida          varchar2(40);

    begin

        select count(*) into ws_check_run
        from   RUNNING_PROCESS
        where  cd_processo = prm_cd_processo and
                last_status = 'RUNNING';

        if  prm_comando = 'START' then
            if  ws_check_run>0 then
                ws_saida := 'RUNNING';
            else
                insert into RUNNING_PROCESS values (prm_cd_processo,prm_ds_processo,sysdate,null,'RUNNING');
                commit;
                NESTED_REG_ONLINE('004',prm_ds_processo,prm_comando);   -- Registra o Start do processo 
                ws_saida := 'OK';
            end if;
        else
            if  prm_comando = 'ERRO' then
                if  ws_check_run=0 then
                    ws_saida := 'NO_SENSE';
                else
                    update RUNNING_PROCESS set dt_final    = sysdate,
                                                last_status = 'ERRO'
                    where  cd_processo = prm_cd_processo and
                            last_status = 'RUNNING';
                    commit;
                    NESTED_REG_ONLINE('004',prm_ds_processo,prm_comando);  -- Registra Erro no processo 
                    ws_saida := 'OK';
                end if;
            else
                if  ws_check_run=0 then
                    ws_saida := 'NO_SENSE';
                else
                    update RUNNING_PROCESS set dt_final    = sysdate,
                                                last_status = 'END'
                    where  cd_processo = prm_cd_processo and
                            last_status = 'RUNNING';
                    commit;
                    NESTED_REG_ONLINE('004',prm_ds_processo,prm_comando);  -- Registra o final do processo 
                    ws_saida := 'OK';
                end if;
            END IF;
        end if;

    end NESTED_STATUS_PROCESS;

    -- Envia dados de monitoramento das tablespace - criado pl/sql DINAMICO para evitar erro na compilação da package caso o cliente não tenha grant nas tabelas do Oracle  
    procedure MONIT_TABLESPACES as 
        ws_sql            varchar2(30000);
        ws_sql2           varchar2(30000);
        ws_param          varchar2(4000); 
        ws_ts_files       varchar2(100);  
        ws_ts_bytes       varchar2(100);
        ws_ts_maxbytes    varchar2(100);
        ws_ex_extents     varchar2(100);
        ws_ex_segments    varchar2(100);
        ws_ex_bytes       varchar2(100);

        ws_ds_erro        varchar2(300); 
    begin 
        ws_sql :=  'select ts.files, ts.bytes, ts.maxbytes, ex.extents, ex.segments, ex.bytes
                     from (select tablespace_name, count(distinct file_name) as files,
                                  round(sum(bytes)/1024/1024) as bytes, 
                                  round(sum(decode(autoextensible,''NO'',bytes,maxbytes))/1024/1024) as maxbytes
                             from dba_data_files
                            group by tablespace_name ) ts,  
                          (select tablespace_name, count(*) as extents, count(distinct segment_name) as segments, round(sum(bytes)/1024/1024) as bytes
                             from dba_extents
                            group by tablespace_name) ex  
                    where ex.tablespace_name = ts.tablespace_name 
                      and ts.tablespace_name = :p1 
                      and rownum             = 1 '; 
        --
        ws_sql2:=  'select 0 ts_files,
                           round(me.tablespace_size * ts.block_size/1024/1024) as ts_bytes, 
                           round(me.tablespace_size * ts.block_size/1024/1024) as ts_maxbytes, 
                           0 ex_extents, 
                           0 ex_segments, 
                           round(me.used_space * ts.block_size/1024/1024) as ex_bytes 
                      from dba_tablespace_usage_metrics me, dba_tablespaces ts
                     where me.tablespace_name = ts.tablespace_name
                       and ts.contents = ''TEMPORARY'' 
                       and ts.tablespace_name = :p1 
                       and rownum             = 1'; 
        -- 
        for a in (select 'UPQUERY_DATA' as tablespace_name from dual union all 
                  select 'SYSTEM'      from dual union all 
                  select 'UNDOTBS1'    from dual union all 
                  select 'SYSAUX'      from dual union all 
                  select 'TEMP'        from dual 
                  order by 1 )
        loop 
            ws_ds_erro := ''; 
            begin 
                if a.tablespace_name = 'TEMP' then 
                    execute immediate ws_sql2 into ws_ts_files, ws_ts_bytes, ws_ts_maxbytes, ws_ex_extents, ws_ex_segments, ws_ex_bytes using a.tablespace_name;
                else 
                    execute immediate ws_sql  into ws_ts_files, ws_ts_bytes, ws_ts_maxbytes, ws_ex_extents, ws_ex_segments, ws_ex_bytes using a.tablespace_name;                    
                end if;     
            exception when others then 
                ws_ts_files       := '0';
                ws_ts_bytes       := '0'; 
                ws_ts_maxbytes    := '0';
                ws_ex_extents     := '0';
                ws_ex_segments    := '0';
                ws_ex_bytes       := '0';
                ws_ds_erro        := substr(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,200); 
            end;     
            ws_param :=    'TABLESPACE_NAME|'    ||a.tablespace_name 
                        ||'|TS_QT_FILES|'        ||ws_ts_files             
                        ||'|TS_QT_BYTES|'        ||ws_ts_bytes 
                        ||'|TS_QT_MAXBYTES|'     ||ws_ts_maxbytes 
                        ||'|EX_QT_EXTENTS|'      ||ws_ex_extents 
                        ||'|EX_QT_SEGMENTS|'     ||ws_ex_segments 
                        ||'|EX_QT_BYTES|'        ||ws_ex_bytes
                        ||'|DS_ERRP|'            ||ws_ds_erro; 
            nested_reg_online('101',null,null,null,ws_param);                     
        end loop;               
    end MONIT_TABLESPACES; 


BEGIN

    -- Aguarda processos em execução (status = RUNNING)  - Verifica 70 vezes, cada fez aguarda 15 segundos se ainda houver processos em execução 
    -------------------------------------------------------------------------------------------------------------------------------------------
    if aguardar_atualizacao  ('JOB_QUARTER', 70, 15) = 'TIMEOUT' then 
        RAISE WS_TIMEOUT;
    end if; 


    -- Aguarda AUTO UPDATE por 5 minutos ou até terminar - Necessário para não conflitar com o EXEC_QUARTER 
    -------------------------------------------------------------------------------------------------------------------------------------------    
    ws_dh_inicio := sysdate;
    loop
        select count(*) into ws_count from all_jobs where upper(what) like 'UPD.AUTOUPDATE_JOB_ATUALIZA%';
        exit when (ws_count = 0 or trunc((sysdate-ws_dh_inicio)*1440) > 5); 
        dbms_lock.sleep(5);  -- espera 5 segundos anters de verificar novamente 
    end loop;



    ---------------------------------------------------------------------        
    -- Log de START do Job Quarter 
    ---------------------------------------------------------------------    
    INSERT INTO LOG_EVENTOS VALUES(SYSDATE , '[QH]-INICIO PROCESSO!' , USER , 'CALCULO' , 'OK', '0');
    COMMIT;
    BEGIN
        NESTED_STATUS_PROCESS('000006','JOB_QUARTER','START');
    EXCEPTION WHEN OTHERS THEN
        INSERT INTO LOG_EVENTOS VALUES(SYSDATE , '[QH]-PROCESSO SEM REGISTRO!' , USER , 'CALCULO' , 'OK', '0');
        COMMIT; 
    END;

    ---------------------------------------------------------------------        
    -- Log RUNNING do Job Quarter - Atualiza a DATA_ATUAL do BI 
    ---------------------------------------------------------------------    
    INSERT INTO LOG_EVENTOS VALUES(SYSDATE , '[QH]-RUNNING PROCESS!' , USER , 'CALCULO' , 'OK', '0');
    UPDATE VAR_CONTEUDO SET CONTEUDO=TO_CHAR(SYSDATE,'dd/mon/yyyy','NLS_DATE_LANGUAGE = AMERICAN')
        WHERE VARIAVEL = 'DATA_ATUAL';
    COMMIT;


    ----------------------------------------------------------------------------
    -- Executa a procedure do job quarter 
    ----------------------------------------------------------------------------
    EXEC_QUARTER;   


    ----------------------------------------------------------------------------
    -- Realiza atualização pendente do SCH e ETF (se houver) 
    ----------------------------------------------------------------------------
    if nvl(sch.ret_var('HR_AUTOUPDATE_ATU'),'N/A') <> 'N/A' then 
        sch.autoupdate_atualiza('ETL', 'SCH'); 
        sch.autoupdate_atualiza('ETL', 'ETF'); 
    end if; 


    ------------------------------------------------------------------------------------------
    -- Na virada do dia - TROCA do dia 
    ------------------------------------------------------------------------------------------
    IF  TRUNC(SYSDATE) <> TO_DATE(sch.ret_var('DIA_TROCA'),'dd/mon/yyyy','NLS_DATE_LANGUAGE = AMERICAN') THEN


        INSERT INTO LOG_EVENTOS VALUES(SYSDATE , '[QH]-Novo Dia Início!' , USER , 'CALCULO' , 'OK', '0');
        COMMIT;

        -- Verifica/bloqueia Sistema 
        begin 
            NESTED_REG_ONLINE('003','VERIFY_DAY','OK');
        exception when others then
            INSERT INTO LOG_EVENTOS VALUES(SYSDATE , '[QH]-Erro no REG_ONLINE 003' , USER , 'CALCULO' , 'OK', '0');
            commit;
        end; 

        -- Cria job para envio de informações de acesso ao sistema 
        sch.execute_now('SCH.REG_ONLINE_ACESSOS', 'N'); 

        -- Envia registros de alteração de usuário 
        sch.execute_now('SCH.REG_ONLINE_USUARIOS', 'N'); 

        begin
            nested_reg_online('013','',null, null);  -- Envia informações do sistema  
        exception when others then
            INSERT INTO LOG_EVENTOS VALUES(SYSDATE , '[QH]-Erro no REG_ONLINE 013' , USER , 'CALCULO' , 'OK', '0');
            commit;
        end; 

        begin 
            monit_tablespaces ;                      -- Envia monitoramento da tablespace do BI  
        exception when others then
            INSERT INTO LOG_EVENTOS VALUES(SYSDATE , '[QH]-Erro no MONIT_TABLESPACES' , USER , 'CALCULO' , 'OK', '0');
            commit;
        end; 

        begin 
            select nvl((trunc(sysdate)-min(trunc(dt_registro))),0) into ws_count 
            from   pending_regs
            where  status = 'P';
            nested_reg_online('104',null,null,null,to_char(ws_count));              -- Envia montoramento da PENDING_REGS          
        exception when others then
            INSERT INTO LOG_EVENTOS VALUES(SYSDATE , '[QH]-Erro no PENDING_REGS' , USER , 'CALCULO' , 'OK', '0');
            commit;
        end; 

        BEGIN
            -- Atualiza variáveis de controle data, DATA_ATUAL e DIA TROCA
            SELECT  CONTEUDO INTO WS_VARTEMP
              FROM  VAR_CONTEUDO
             WHERE   VARIAVEL = 'DATA_ATUAL';
            UPDATE VAR_CONTEUDO SET CONTEUDO=TO_CHAR(SYSDATE,'dd/mon/yyyy','NLS_DATE_LANGUAGE = AMERICAN')
                WHERE VARIAVEL IN ('DIA_TROCA','DATA_ATUAL');
            COMMIT;

            EXEC_DAY;  -- Executa a procedure de EXEC_DAY (que roda uma vez por dia)

        EXCEPTION WHEN OTHERS THEN
            ROLLBACK;
            UPDATE VAR_CONTEUDO SET CONTEUDO=TO_CHAR(SYSDATE,'dd/mon/yyyy','NLS_DATE_LANGUAGE = AMERICAN')
            WHERE VARIAVEL = 'DATA_ATUAL';
            UPDATE VAR_CONTEUDO SET CONTEUDO=WS_VARTEMP
            WHERE VARIAVEL = 'DIA_TROCA';
            COMMIT;
        END;

        INSERT INTO LOG_EVENTOS VALUES(SYSDATE , '[QH]-Novo Dia Final!' , USER , 'CALCULO' , 'OK', '0');
        COMMIT;

        
        -- Obs.: Processo Antigo - vai ser descontinado quando todos estiverem utilizando a HR_AUTOUPDATE_ATU
        -- Cria Job de atualização do sistema (tudo menos UPD) - Se não tem hora de atualização definida 
        if nvl(sch.ret_var('HR_AUTOUPDATE_ATU'),'N/A') = 'N/A' then  
            begin
                sch.execute_now('UPD.AUTOUPDATE_JOB_ATUALIZA  ('''||gbl.getsistema||''', '''||gbl.getversion||''', ''DWU'', ''ATUALIZA'' )', 'N'); 
            exception when others then
                INSERT INTO LOG_EVENTOS VALUES(SYSDATE , '[QH]-Erro no UPD.AUTOUPDATE_JOB_ATUALIZA' , USER , 'CALCULO' , 'OK', '0');
                commit;
            end ;
        end if;
        
        ----------------------------------------------------------------------------
        -- Realiza atualização pendente do SCH e ETF (se houver) 
        ----------------------------------------------------------------------------
        if nvl(sch.ret_var('HR_AUTOUPDATE_ATU'),'N/A') <> 'N/A' then 
            sch.autoupdate_atualiza('ETL', 'SCH'); 
            sch.autoupdate_atualiza('ETL', 'ETF'); 
        end if; 


    END IF;

    ---------------------------------------------------------------------        
    -- Log de END do Job Quarter 
    ---------------------------------------------------------------------    
    INSERT INTO LOG_EVENTOS VALUES(SYSDATE , '[QH]-FINAL PROCESSO!' , USER , 'CALCULO' , 'OK', '0');
    COMMIT;
    BEGIN
        NESTED_STATUS_PROCESS('000006','JOB_QUARTER','END');
    EXCEPTION WHEN OTHERS THEN
        INSERT INTO LOG_EVENTOS VALUES(SYSDATE , '[QH]-PROCESSO SEM REGISTRO!' , USER , 'CALCULO' , 'OK', '0');
        COMMIT;
    END;

EXCEPTION
    WHEN WS_NOACT THEN
         INSERT INTO LOG_EVENTOS VALUES(SYSDATE , '[OK]-NO ACT!' , USER , 'CALCULO' , 'OK', '0');
         COMMIT;
    WHEN WS_TIMEOUT THEN
         WS_ERRO := SQLERRM;
         INSERT INTO LOG_EVENTOS VALUES(SYSDATE , '[QH]-TIME OUT!' , USER , 'CALCULO' , 'OK', '0');
         COMMIT;
         NESTED_STATUS_PROCESS('000006','JOB_QUARTER','ERRO');
         NESTED_REG_ONLINE('001','JOB_QUARTER','ERRO');
    WHEN OTHERS THEN
         WS_ERRO := SQLERRM;
         INSERT INTO LOG_EVENTOS VALUES(SYSDATE , '[QH]-ERRO PROCESSO!' , USER , 'CALCULO' , 'OK', '0');
         insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values(sysdate, 'Erro outros QH:'||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, USER, 'ERRO');
         COMMIT;
         NESTED_STATUS_PROCESS('000006','JOB_QUARTER','ERRO');
         NESTED_REG_ONLINE('001','JOB_QUARTER','ERRO');


END JOB_QUARTER;


-- Envia registros de acessos do dia anterior 
PROCEDURE REG_ONLINE_ACESSOS as 
    cursor crs_log_eventos_acesso  is
        select usuario, sch.ret_classe_tela(descricao,programa) cd_classe, count(*) acessos
          from log_eventos
         where data_evento >= trunc(sysdate-1) 
           and data_evento <  trunc(sysdate) 
           and tipo        = 'ACESSO'
           and programa   <> 'BROWSER'
         group by usuario, sch.ret_classe_tela(descricao,programa);
begin 
    INSERT INTO LOG_EVENTOS VALUES(SYSDATE , '[QH]- REG_ONLINE Acessos - INICIO', USER , 'CALCULO' , 'OK', '0');
    commit;
    for ac_user in crs_log_eventos_acesso loop
        nested_reg_online('002', ac_user.cd_classe, ac_user.acessos, ac_user.usuario);
    end loop;
    INSERT INTO LOG_EVENTOS VALUES(SYSDATE , '[QH]- REG_ONLINE Acessos - FIM', USER , 'CALCULO' , 'OK', '0');
    commit;
exception when others then
    INSERT INTO LOG_EVENTOS VALUES(SYSDATE , '[QH]-Erro REG_ONLINE Acessos', USER , 'CALCULO' , 'OK', '0');
    commit;
end REG_ONLINE_ACESSOS; 


-- Envia registros de alteração de usuário 
PROCEDURE REG_ONLINE_USUARIOS as 
    cursor crs_log_eventos (p_tipo varchar2) is
        select usuario, count(*) acessos
          from log_eventos
         where data_evento >= trunc(sysdate-1) 
           and data_evento <  trunc(sysdate) 
           and tipo        = p_tipo 
         group by usuario;
begin 
    INSERT INTO LOG_EVENTOS VALUES(SYSDATE , '[QH]- REG_ONLINE Usuarios - INICIO', USER , 'CALCULO' , 'OK', '0');
    commit;
    for ac_user in crs_log_eventos ('USUARIO') loop
        nested_reg_online('012','',ac_user.acessos,ac_user.usuario);
    end loop;
    INSERT INTO LOG_EVENTOS VALUES(SYSDATE , '[QH]- REG_ONLINE Usuarios - FIM', USER , 'CALCULO' , 'OK', '0');
    commit;
exception when others then
    INSERT INTO LOG_EVENTOS VALUES(SYSDATE , '[QH]-Erro REG_ONLINE Usuarios' , USER , 'CALCULO' , 'OK', '0');
    commit;
end REG_ONLINE_USUARIOS; 



-- Envia registros integração com a Upquery
PROCEDURE NESTED_REG_ONLINE ( prm_tipo     varchar2 default null,
                              prm_evento   varchar2 default null,
                              prm_status   varchar2 default null,
                              prm_usuario  varchar2 default null,
                              prm_qtde     varchar2 default null ) as

                cursor crs_pendings is
                    select   DT_REGISTRO, COMMAND, ROWID ID_LINHA
                    from     PENDING_REGS
                    where    STATUS='P'
                    order by dt_registro desc;

        ws_pendings        crs_pendings%rowtype;

        ws_count        number;
        ws_pending      number;
        ws_string       varchar2(4000);
        ws_command      varchar2(4000);
        ws_error_count  number := 0;
        ws_error        varchar2(200);
        ws_address      varchar2(200);
        ws_usuario      varchar2(80);
        ws_param        varchar2(1000); 
        ws_banner_version varchar2(100);      
        nao_enviar      exception;    

    begin

        ws_usuario := user;
        ws_count   := 0;

        if prm_tipo <> '101' and sch.tipo_ambiente in ('DESENV','HOMOLOGA') then  -- DESENV E HOMOLOGA, só envia acompanhamento das tablespaces 
            raise nao_enviar; 
        end if; 

        select NVL((TRUNC(SYSDATE)-MIN(TRUNC(DT_REGISTRO))),0) into ws_pending
        from   PENDING_REGS
        where  STATUS='P';

        if  ws_pending > 30 then
            update OBJECT_LOCATION set POSX='11px'   
             where OWNER='DWU' and
                   NAVEGADOR='DEFAULT' and
                   OBJECT_ID='CONFIG';
            commit;
        end if;

        -- Tenta enviar registros PENDENTES 
        open crs_pendings;
        loop
            fetch crs_pendings into ws_pendings;
            exit when crs_pendings%notfound;
            begin
                ws_string := utl_http.request(ws_pendings.command);
                begin
                    update PENDING_REGS set status = 'K' where rowid=ws_pendings.id_linha;
                    commit;
                    ws_count := ws_count+1;
                exception when others then
                    insert into log_eventos values(sysdate, '[RO]-FALHA UNSET PENDING!!', ws_usuario, 'REG_OFF', 'OFF', '01');
                    commit;
                end;
            exception
                when others then
                    insert into log_eventos values(sysdate, '[RO]-FALHA UNSET PENDING!', ws_usuario, 'REG_OFF', 'OFF', '01');
                    commit;
            end;
        end loop;
        close crs_pendings;

        if  ws_count > 0 then
            insert into log_eventos values(sysdate, '[RO]-OFFLINE REGS['||ws_count||']!', ws_usuario, 'REG_OFF', 'OFF', '01');
            commit;
        end if;

        -- Registro de eventos 
        if  prm_tipo='001' then
            ws_command := 'http://'||sch.ret_var('URL_UPDATE')||'/dwu.renew?prm_par=TIPO|001|CLIENTE|'||sch.ret_var('CLIENTE')||'|DATA|'||to_char(sysdate,'ddmmyyhh24mi')||'|EVENTO|'||prm_evento||'|STATUS|'||prm_status;
            begin
                ws_string  := utl_http.request(ws_command);
            exception
                when others then
                    insert into PENDING_REGS values (sysdate,ws_command,'P');
                    commit;
            end;
        end if;

        -- Registro de acessos 
        if prm_tipo='002' then
            ws_command := 'http://'||sch.ret_var('URL_UPDATE')||'/dwu.renew?prm_par=TIPO|002|CLIENTE|'||sch.ret_var('CLIENTE')||'|DATA|'||to_char(trunc(sysdate-1),'ddmmyyhh24mi')||'|USUARIO|'||prm_usuario||'|CLASSE|'||prm_evento||'|ACESSOS|'||prm_status;
            begin
                ws_string  := utl_http.request(ws_command);
            exception
                when others then
                    insert into PENDING_REGS values (sysdate,ws_command,'P');
                    commit;
            end;
        end if;

        -- Registro de Lock de sistema 
        if prm_tipo='003' then
            ws_command := 'http://'||sch.ret_var('URL_UPDATE')||'/dwu.renew?prm_par=TIPO|003|CLIENTE|'||sch.ret_var('CLIENTE')||'|DATA|'||to_char(sysdate,'ddmmyyhh24mi')||'|EVENTO|'||prm_evento||'|STATUS|'||prm_status;
            begin
                ws_string := utl_http.request(ws_command);
            exception
                when others then
                    insert into PENDING_REGS values (sysdate,ws_command,'P');
                    commit;
            end;

            if trim(ws_string)='LOCK_SYS' then
                update OBJECT_LOCATION set POSX='11px' 
                 where OWNER='DWU' 
                   and NAVEGADOR='DEFAULT' 
                   and OBJECT_ID='CONFIG';
                commit;
            end if;
            if trim(ws_string)='UNLOCK_SYS' then
                update OBJECT_LOCATION set POSX='12px' 
                 where OWNER='DWU' 
                   and NAVEGADOR='DEFAULT' 
                   and OBJECT_ID='CONFIG';
                    commit;
            end if;
        end if;

        -- Registro de Processos 
        if  prm_tipo='004' then
            ws_command := 'http://'||sch.ret_var('URL_UPDATE')||'/dwu.renew?prm_par=TIPO|004|CLIENTE|'||sch.ret_var('CLIENTE')||'|DATA|'||to_char(sysdate,'ddmmyyhh24mi')||'|DS_EVENTO|'||prm_evento||'|STATUS|'||prm_status;
            begin
                ws_string  := utl_http.request(ws_command);
            exception
                when others then
                    insert into PENDING_REGS values (sysdate,ws_command,'P');
                    commit;
            end;
        end if;

        -- Registro de Erros de JS 
        if  prm_tipo='005' then
            ws_command := 'http://'||sch.ret_var('URL_UPDATE')||'/dwu.renew?prm_par=TIPO|005|CLIENTE|'||sch.ret_var('CLIENTE')||'|DATA|'||to_char(trunc(sysdate-1),'ddmmyyhh24mi')||'|USUARIO|'||prm_usuario||'|ACESSOS|'||prm_status||'|QTDE|'||prm_qtde;
            begin
                ws_string  := utl_http.request(ws_command);
            exception
                when others then
                    insert into PENDING_REGS values (sysdate,ws_command,'P');
                    commit;
            end;
        end if;

        -- Registro de alteração de usuário     
        if prm_tipo='012' then

            ws_param := null;     -- Se não existir registro na tabela USUARIOS vai levar os campos nulos com situação/status = EXCLUIDO 
            select '|NM_COMPLETO|'||rawtohex(max(USU_COMPLETO))||'|DS_EMAIL|'||rawtohex(max(USU_EMAIL))||'|NR_TELEFONE|'||rawtohex(max(USU_NUMBER))||'|ID_SITUACAO|'||rawtohex(nvl(max(STATUS),'EXCLUIDO') )||'|DT_ULTIMA_VALIDACAO|'||rawtohex(TO_CHAR(max(DT_VALIDACAO_EMAIL),'DD/MM/YYYY HH24:MI:SS')) into ws_param          
              from usuarios
             where usu_nome = prm_usuario ; 

            if ws_param is not null then 
                ws_command := 'http://'||sch.ret_var('URL_UPDATE')||'/dwu.renew?prm_par=TIPO|012|CLIENTE|'||sch.ret_var('CLIENTE')||'|DATA|'||to_char(trunc(sysdate-1),'ddmmyyhh24mi')||'|USUARIO|'||prm_usuario||ws_param;
                begin
                    ws_string  := utl_http.request(ws_command);
                exception
                    when others then
                        insert into PENDING_REGS values (sysdate,ws_command,'P');
                        commit;
                end;         
            end if;
        end if;

        -- Registro de informações do sistema 
        if prm_tipo='013' then

            select banner into ws_banner_version from v$version where upper(banner) like '%ORACLE%' and rownum = 1; 
            ws_param := 'SISTEMA|BI|CD_VERSAO|'||gbl.getVersion||'|CD_VERSAO_ORACLE|'||sch.ret_var('ORACLE_VERSION')||'|DS_VERSAO_ORACLE|'||ws_banner_version; 
            SELECT rawtohex(ws_param) INTO ws_param from dual;  -- Converte para hexadecimal para evitar problema na URL 
            ws_command := 'http://'||sch.ret_var('URL_UPDATE')||'/dwu.renew?prm_par=TIPO|013|CLIENTE|'||sch.ret_var('CLIENTE')||'|PARAM_HEXADECIMAL|'||ws_param;
            begin
                ws_string  := utl_http.request(ws_command);
            exception
                when others then
                     insert into PENDING_REGS values (sysdate,ws_command,'P');
                     commit;
            end;         
        end if;

        -- Registro de Moitoramento do tamanho das tablespaces
        if prm_tipo='101' then
            ws_param := prm_qtde||'|DH_ENVIO|'||TO_CHAR(SYSDATE,'DDMMYYYYHH24MI');
            SELECT rawtohex(ws_param) INTO ws_param from dual;  -- Converte para hexadecimal para evitar problema na URL 
            ws_command := 'http://'||sch.ret_var('URL_UPDATE')||'/dwu.renew?prm_par=TIPO|'||prm_tipo||'|CLIENTE|'||sch.ret_var('CLIENTE')||'|PARAM_HEXADECIMAL|'||ws_param;
            begin
                ws_string  := utl_http.request(ws_command);
            exception when others then
                insert into PENDING_REGS values (sysdate,ws_command,'P');
                commit;
            end;         
        end if;

        -- Registro de Moitoramento de registros antigos na PENDING_REGS 
        if prm_tipo='104' then
            ws_command := 'http://'||sch.ret_var('URL_UPDATE')||'/dwu.renew?prm_par=TIPO|'||prm_tipo||'|CLIENTE|'||sch.ret_var('CLIENTE')||'|QT_DIAS|'||prm_qtde||'|DH_ENVIO|'||TO_CHAR(SYSDATE,'DDMMYYYYHH24MI'); 
            begin
                ws_string  := utl_http.request(ws_command);
            exception when others then
                insert into PENDING_REGS values (sysdate,ws_command,'P');
                commit;
            end;         
        end if;

        ws_string := TRIM(replace(ws_string,chr(10),''));

        if  ws_string not in ('OK REGISTRADO','UNLOCK_SYS','LOCK_SYS') then
            insert into log_eventos values(sysdate, '[RO]-FALHA REG.ONLINE SERVIDOR!', user, 'REG_OFF', 'OFF', '01');
            insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values(sysdate, 'RETORNO RENEW NAO PREVISTO:'||substr(ws_string,1,200), user, 'ERRO');
            commit;
        end if;

exception 
        when nao_enviar then
            null; 
        when others then
            insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - REG_ONLINE', ws_usuario, 'ERRO');
            update OBJECT_LOCATION set POSX='11px' where OWNER='DWU' and NAVEGADOR='DEFAULT' and OBJECT_ID='CONFIG';
            commit;
end NESTED_REG_ONLINE;


procedure autoupdate_atualiza (prm_tipo varchar2, prm_pkg varchar2 default null) is 
    ws_comando varchar2(500);
    ws_count   number := 0 ;
begin
    if prm_tipo = 'BI' then 
        ws_comando := 'upd.AutoUpdate_atualiza_bi';      --ws_comando := 'begin upd.AutoUpdate_atualiza_bi; end;'; 
    elsif prm_tipo = 'ETL' and prm_pkg is not null then 
        ws_comando := 'upd.AutoUpdate_atualiza_pkg('''||prm_pkg||''')';     --ws_comando := 'begin upd.AutoUpdate_atualiza_pkg('''||prm_pkg||'''); end;'; 
    end if;    
    -- Cria job que fica tentando executar o job de atualização da package (só cria se ainda não existe)
    if ws_comando is not null then 
        sch.execute_now(ws_comando, 'N'); 
        commit; 
    end if; 
exception when others then 
    insert into bi_log_sistema values(sysdate, 'Erro autoupdate_atualiza (Others):'||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 'DWU', 'ERRO');
    commit;
end autoupdate_atualiza;

---------------------------------------------------------------------------------------------------------------------------------------------------------
-------- Atualiza package UPD - é uma copia da procedure da UPD, criada porque a UPD não pode atualizar ela mesma
---------------------------------------------------------------------------------------------------------------------------------------------------------
procedure autoUpdate_atu_PACKAGE (prm_usuario        varchar2 default 'DWU',
                                  prm_tipo           varchar2, 
                                  prm_nome           varchar2, 
                                  prm_chamada        varchar2 default 'BANCO' ) as 
    ws_id_atu        number; 
    ws_comando_head  clob;    
    ws_comando_body  clob;    
    ws_sid           varchar2(20);
    ws_sid_lock      varchar2(20);    
    ws_msg_erro      varchar2(500);
    ws_try           integer; 
    ws_check         integer; 
    ws_dt_versao     date;
    ws_tipo          varchar2(20); 
    ws_raise_erro    exception ;
    ws_raise_timeout exception ;
begin

    if prm_tipo not like 'PACKAGE%' or prm_nome <> 'UPD'  then 
       ws_msg_erro := 'Procedure deve ser utilizada somente para Package UPD';
       raise ws_raise_erro; 
    end if;

    select nvl(max(id_auto_update),0)+1 into ws_id_atu from bi_auto_update_log;

    select sys_Context('USERENV', 'SID') into ws_sid from dual; 
    /* 
    select s.sid into ws_sid 
      from v$session s
     where s.audsid = sys_Context('USERENV', 'SESSIONID') 
       and s.sid    = sys_Context('USERENV', 'SID'); 
    **/    

    ws_comando_head := null;
    ws_comando_body := null;
    
    select conteudo_clob into ws_comando_head from bi_auto_update
     where tp_objeto = 'PACKAGE_SPEC' 
       and nm_objeto = prm_nome; 
    --
    select conteudo_clob into ws_comando_body from bi_auto_update
     where tp_objeto = 'PACKAGE_BODY' 
       and nm_objeto = prm_nome; 

    if ws_comando_head is null or ws_comando_body is null then 
       ws_msg_erro := 'Conteudo nulo';
       raise ws_raise_erro; 
    end if;     

    ws_tipo := 'PACKAGE_BODY'; -- Para colocar o log sempre como PACKAGE_BODY, pois é mais comum compilar somente o BODY 
    sch.AutoUpdate_log (ws_id_atu, 'ATUALIZA', ws_tipo, prm_nome, 'INICIO', null, prm_usuario); 

    if nvl(upper(sch.ret_var('USAR_DBA_DDL_LOCKS')),'S') = 'S' then
        -- aguarda processos em execução, faz 240 tentativas aguardando 5 segundos cada tentativa (+20 20 minutos) 
        ws_try   := 240;
        ws_check := 1;
        loop
            exit when ws_check=0;
            -- Verifica se tema alguma outra sessão utilizando o objeto 
            select count(*), max(l.session_id) into ws_check, ws_sid_lock  
            from dba_ddl_locks l
            where l.session_id <> ws_sid 
            and l.type       <> 'Table/Procedure/Type'
            and l.owner       = 'DWU' 
            and l.name        = prm_nome ;

            update bi_auto_update_log 
            set qt_tentativa   = nvl(qt_tentativa,0) + 1, 
                ds_atualizacao = 'ws_try='||ws_try||' ,ws_check='||ws_check||', sid='||ws_sid_lock
            where id_auto_update = ws_id_atu 
            and tp_atualizacao = 'ATUALIZA'
            and tp_objeto      = ws_tipo
            and nm_objeto      = prm_nome ;
            commit;    

            ws_try := ws_try - 1;
            if  ws_try=0 and ws_check<>0 then
                raise ws_raise_timeout;
            end if;
            if  ws_check<>0 then    -- se tem processo, aguarda mais 5 saegundos e tenta novamente 
                dbms_lock.sleep(5);
            end if;
        end loop;
    end if; 

    begin 
        execute immediate ws_comando_head;
        execute immediate ws_comando_body;
    exception when others then    
        ws_msg_erro := 'Erro: '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE; 
        raise ws_raise_erro; 
    end; 

    update bi_auto_update
       set dt_versao_sistema = dt_versao_baixa
     where tp_objeto in ('PACKAGE_SPEC', 'PACKAGE_BODY')
       and nm_objeto = prm_nome ; 
    
    COMMIT; 
    
    sch.AutoUpdate_log (ws_id_atu, 'ATUALIZA', ws_tipo, prm_nome, 'FIM', 'Ok', prm_usuario); 

    if prm_chamada = 'NAVEGADOR' then 
        select max(dt_versao_baixa) into ws_dt_versao from bi_auto_update 
          where tp_objeto = 'PACKAGE_BODY'
            and nm_objeto = prm_nome; 
        htp.p('OK|'||to_char(ws_dt_versao,'DD/MM/YYYY HH24:MI')||'|Atualizado|Objeto atualizado com sucesso' );
    end if; 

 exception 
    when ws_raise_erro then 
        sch.AutoUpdate_log (ws_id_atu, 'ATUALIZA', ws_tipo, prm_nome, 'ERRO', ws_msg_erro, prm_usuario); 
        if prm_chamada = 'NAVEGADOR' then 
            htp.p('ERRO||Erro na atualiza&ccedil;&atild;o|'||ws_msg_erro);
        end if;         
    when ws_raise_timeout then 
        ws_msg_erro := 'Timeout tentando atualizar package';
        sch.AutoUpdate_log (ws_id_atu, 'ATUALIZA', ws_tipo, prm_nome, 'ERRO', ws_msg_erro, prm_usuario);         
        if prm_chamada = 'NAVEGADOR' then 
            htp.p('ERRO||Erro na atualiza&ccedil;&atild;o|'||ws_msg_erro);
        end if;         
    when others then
        ws_msg_erro := 'Erro: '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE; 
        sch.AutoUpdate_log (ws_id_atu, 'ATUALIZA', ws_tipo, prm_nome, 'ERRO', ws_msg_erro, prm_usuario);
        if prm_chamada = 'NAVEGADOR' then 
            htp.p('ERRO||Erro na atualiza&ccedil;&atild;o|'||ws_msg_erro);
        end if;         
end autoUpdate_atu_PACKAGE;


procedure AutoUpdate_log  (prm_id        number, 
                           prm_tp_atu    varchar2, 
                           prm_tipo      varchar2,
                           prm_nome      varchar2, 
                           prm_situacao  varchar2, 
                           prm_msg       varchar2,
                           prm_usuario   varchar2 ) as
ws_id_situacao  varchar2(20); 
begin
    update bi_auto_update_log
       set ds_atualizacao = nvl(substr(prm_msg,1,199), ds_atualizacao),
           id_situacao    = prm_situacao,   
           dt_fim         = sysdate 
     where id_auto_update = prm_id 
       and tp_atualizacao = prm_tp_atu 
       and tp_objeto      = prm_tipo 
       and nm_objeto      = prm_nome
       and ( ( id_situacao = prm_situacao) or (prm_situacao in ('INICIO','ERRO','FIM') and id_situacao in ('INICIO','ERRO','FIM'))  ) ; 
    if sql%notfound then 
        insert into bi_auto_update_log (id_auto_update, tp_atualizacao, tp_objeto, nm_objeto, id_situacao, ds_atualizacao, dt_inicio, dt_fim, nm_usuario) 
                                values (prm_id, prm_tp_atu, prm_tipo, prm_nome, prm_situacao, substr(prm_msg,1,199), sysdate, null, prm_usuario); 
    end if; 
    -- 
    -- Atualiza a situação de atualização do objeto se for situação INICIO, ERRO, FIM 
    ws_id_situacao := null; 
    if    prm_situacao = 'INICIO' then    ws_id_situacao := 'ATUALIZANDO';
    elsif prm_situacao = 'FIM'    then    ws_id_situacao := 'ATUALIZADO';
    elsif prm_situacao = 'ERRO'   then    ws_id_situacao := 'ERRO';
    end if; 
    if ws_id_situacao is not null then 
        update bi_auto_update set id_situacao = ws_id_situacao
         where tp_objeto = prm_tipo 
           and nm_objeto = prm_nome ;    
    end if;                        
    commit;	
    --
end AutoUpdate_log;


function aguardar_atualizacao  (prm_tp_atualizacao   varchar2, 
                                prm_qt_tentativas    number, 
                                prm_qt_intervalo     number) return varchar2 as  
ws_tentativas_restantes    number;
ws_count                   number;
ws_sysdate                 date; 
begin
    ws_tentativas_restantes := prm_qt_tentativas;
    ws_count                := 1;
    ws_sysdate              := sysdate; 
    loop
        ws_count := 0;
        if prm_tp_atualizacao = 'JOB_QUARTER' then 
            select count(*) into ws_count from running_process where last_status='RUNNING';
        elsif prm_tp_atualizacao = 'AUTOUPDATE_ATUALIZA' then 
            select count(*) into ws_count from bi_auto_update_log
             where tp_atualizacao = 'ATUALIZA' 
               and id_situacao    IN ('ERRO', 'FIM')
               and tp_objeto      = 'TODOS' 
               and nm_objeto      = 'TODOS'
               and dt_inicio     >= ws_sysdate; 
            if ws_count = 0 then  ws_count := 1;
            else                  ws_count := 0;
            end if; 
        elsif prm_tp_atualizacao = 'AUTOUPDATE_UPD' then 
            select count(*) into ws_count from bi_auto_update_log
             where tp_atualizacao = 'ATUALIZA' 
               and id_situacao    IN ('ERRO', 'FIM')
               and tp_objeto      = 'PACKAGE_BODY' 
               and nm_objeto      = 'UPD'
               and dt_inicio     >= ws_sysdate; 
            if ws_count = 0 then  ws_count := 1;
            else                  ws_count := 0;
            end if; 
        end if;     

        if ws_count = 0 then 
            RETURN 'FIM';
        else 
            ws_tentativas_restantes := ws_tentativas_restantes - 1;
            if  ws_tentativas_restantes = 0 then
                RETURN 'TIMEOUT';
            end if;
            dbms_lock.sleep(prm_qt_intervalo);
        end if;
    end loop;
    RETURN 'FIM';
end aguardar_atualizacao; 

---------------------------------------------------------------------------------------------------------------------------------------------------------
-------- Registra log do udpdate de sistema, criada para atualização da UPD, a UPD não pode atualizar ela mesma
---------------------------------------------------------------------------------------------------------------------------------------------------------

procedure alert_online (p_id            in out number,
                        p_bloco		    varchar2 default null,
                        p_inicio        date     default null,
                        p_fim		    date     default null,
                        p_parametro	    varchar2 default null,
                        p_status 	    varchar2 default null,
                        p_obs	        varchar2 default null,
                        p_st_notify     varchar2 default 'REGISTRO',
                        p_mail_notify   varchar2 default 'N',
                        p_pipe_tabelas  varchar2 default null ) as  

-->> p_status     -- ATUALIZANDO
-->>              -- FINALIZADO 
-->>
-->> p_st_notify  -- "REGISTRO" Somente inserção na tabela VM_DETALHES
-->>              -- "ENVIO" Envia notificação parao CLOUD e VM_DETALHES
-->>
-->> p_mail_notify -- S - Envia email para suporte Upquery  
-->>               -- N - Não envia email    
 
cursor c_tabelas is
  select COLUMN_VALUE nm_tabela 
    from table ((sch.VPIPE(replace(p_pipe_tabelas,' ','')))); 

ws_id          number;
ws_command     varchar2(4000);
ws_string      varchar2(4000);
ws_temp        varchar2(4000);
ws_notify      varchar2(40);
ws_sid         varchar2(20);
ws_serial      varchar2(20); 
ws_obs         varchar2(1000); 
ws_status      varchar2(100); 
ws_count       number; 
nao_enviar     exception; 

begin

    ws_notify  := p_st_notify;
    ws_status  := substr(p_status,1,100);
    ws_obs     := substr(p_obs,1,999);

    if sch.tipo_ambiente in ('DESENV','HOMOLOGA') then  -- DESENV E HOMOLOGA, só registra não envia para a UPquery 
        ws_notify := 'REGISTRO';
    end if; 

	begin

        if nvl(p_id,0) <> 0 then 
            ws_id := p_id ; 
        else     
            select nvl(max(id),0) + 1 into ws_id from vm_detalhes;
        end if;

        select count(*) into ws_count from vm_detalhes
         where vm_detalhes.id    = ws_id
           and vm_detalhes.bloco = p_bloco;
        -- Se já existe atualiza senão cria novo registro 
        if ws_count <> 0 then   
            update vm_detalhes set dt_hr_fim = p_fim, 
                                   parametro = nvl(p_parametro, parametro),
                                   status    = p_status, 
                                   obs       = p_obs
             where vm_detalhes.id    = ws_id
               and vm_detalhes.bloco = p_bloco ;
        else      
            select max(sid), max(serial#) into ws_sid , ws_serial 
              from v$session 
             where audsid = sys_Context('USERENV', 'SESSIONID') 
               and sid    = sys_Context('USERENV', 'SID');
	        insert into vm_detalhes ( id, bloco, dt_hr_inicio, dt_hr_fim, parametro, status, obs, cd_sid, cd_serial ) 
                             values (ws_id, p_bloco, p_inicio, p_fim, substr(p_parametro,1,100), p_status, substr(p_obs,1,3999), ws_sid, ws_serial);
        end if; 
        -- Atualiza o tempo de atualização nas visões 
        if p_fim is not null and p_status <> 'ERRO' then 
            select count(*) into ws_count 
              from all_tab_columns 
             where table_name = 'MICRO_VISAO'
               and column_name = 'DT_ULTIMA_ATUALIZACAO';
            if ws_count > 0 then 
                ws_command := 'update micro_visao set dt_ultima_atualizacao = :1 where nm_tabela = :2 ';  
                for a in c_tabelas loop
                    EXECUTE IMMEDIATE ws_command USING p_fim,  upper(trim(a.nm_tabela)); 
                    commit; 
                    --update micro_visao set dt_ultima_atualizacao = p_fim 
                    -- where nm_tabela = a.nm_tabela;
                end loop ;
            end if;    
        end if;    

        commit;
	exception
	   when others then
	        ws_notify  := 'ENVIO';
            ws_status  := 'ERRO_ALERT';
            ws_obs     := substr('Erro: '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,999);
	end;

    p_id := ws_id; 

    if  ws_notify = 'ENVIO' THEN
        begin
	        ws_command := 'http://'||sch.ret_var('URL_UPDATE')||'/dwu.renew?prm_par=TIPO|010|CLIENTE|'||sch.ret_var('CLIENTE');
	        SELECT rawtohex(TO_CHAR(WS_ID)) INTO ws_temp FROM dual;
            ws_command := ws_command||'|ID|'||ws_temp;
            
            SELECT rawtohex(P_BLOCO) INTO ws_temp FROM dual;
            ws_command := ws_command||'|BLOCO|'||ws_temp;

            SELECT rawtohex(to_char(P_INICIO,'DD/MM/YYYY HH24:MI:SS')) INTO ws_temp FROM dual;
            ws_command := ws_command||'|INICIO|'||ws_temp;

            SELECT rawtohex(to_char(P_FIM,'DD/MM/YYYY HH24:MI:SS')) INTO ws_temp FROM dual;
            ws_command := ws_command||'|FIM|'||ws_temp;

            SELECT rawtohex(P_PARAMETRO) INTO ws_temp FROM dual;
            ws_command := ws_command||'|PARAMETRO|'||ws_temp;

            SELECT rawtohex(ws_status) INTO ws_temp FROM dual;
            ws_command := ws_command||'|STATUS|'||ws_temp;

            SELECT rawtohex(ws_obs) INTO ws_temp FROM dual;
            ws_command := ws_command||'|OBS|'||ws_temp;
            ws_command := ws_command||'|MAIL|'||p_mail_notify;

            commit;
          
            begin
                ws_string  := utl_http.request(ws_command);
            exception
                when others then
                    insert into PENDING_REGS values (sysdate,ws_command,'P');
                    commit;
            end;
        end;
    end if;
exception 
    when nao_enviar then 
        null;    
end alert_online; 

----------------------------------------------------------------------------------------------------
-- Registro online de todo o cadastro de usuarios - Usado somente para carga inicial, mas pode ser executado sempre que necessário 
----------------------------------------------------------------------------------------------------
procedure reg_online_usuario as 
    ws_command  varchar2(500);
    ws_string   varchar2(200);
begin
    for a in (select  usu_nome, '|NM_COMPLETO|'||rawtohex((USU_COMPLETO))||'|DS_EMAIL|'||rawtohex((USU_EMAIL))||'|NR_TELEFONE|'||rawtohex(USU_NUMBER)||'|ID_SITUACAO|'||rawtohex(nvl((STATUS),'EXCLUIDO') )||
                                '|DT_ULTIMA_VALIDACAO|'||rawtohex(TO_CHAR((DT_VALIDACAO_EMAIL),'DD/MM/YYYY HH24:MI:SS')) param 
                from usuarios ) loop 
        ws_command := 'http://'||sch.ret_var('URL_UPDATE')||'/dwu.renew?prm_par=TIPO|012|CLIENTE|'||sch.ret_var('CLIENTE')||'|DATA|'||to_char(trunc(sysdate-1),'ddmmyyhh24mi')||'|USUARIO|'||a.usu_nome||a.param;
        begin
            ws_string  := utl_http.request(ws_command);
        exception
            when others then
                insert into PENDING_REGS values (sysdate,ws_command,'P');
                commit;
        end;         
    end loop;     
end reg_online_usuario;


----------------------------------------------------------------------------------------------------
-- Limpa Logs do sistema 
----------------------------------------------------------------------------------------------------
procedure limpa_logs_sistema as 
    ws_tabela  varchar2(100);
begin

    -- Logs de erros e eventos do sistema 
    ws_tabela := 'bi_log_sistema'; 
    delete bi_log_sistema 
    where not ( nm_procedure = 'EVENTO' and upper(ds_log) LIKE '%BROWSER%')                -- Não limpa eventos de inclusão em Browser 
      and not ( nm_procedure = 'EVENTO' and upper(ds_log) LIKE '%EXCLUIDO%')               -- Logs de exclusão (Exclusão de linha do Browser, objetos, etc)
      and dt_log < add_months(trunc(sysdate,'month'),-2);                                 -- Mantem os últimos 2 meses + o mês atual 
    commit;  

    -- Log de atualização do sistema  
    ws_tabela := 'bi_auto_update_log'; 
    delete bi_auto_update_log 
    where dt_inicio < add_months(trunc(sysdate,'month'),-2);    -- Mantem os últimos 2 meses + o mês atual ; 
    commit;  

    -- Log de eventos - Não limpa log de acessos - utilizado para análises de acesso de usuários e telas  
    ws_tabela := 'log_eventos'; 
    delete log_eventos 
     where tipo        <> 'ACESSO' 
       and 1=1
       and data_evento < add_months(trunc(sysdate,'month'),-2);    -- Mantem os últimos 2 meses + o mês atual ; 
    commit;  

    -- Log da fila de ETL e eventos 
    ws_tabela := 'etl_fila'; 
    delete etl_fila 
     where dt_criacao < add_months(trunc(sysdate,'month'),-2);    -- Mantem os últimos 2 meses + o mês atual ; 
    commit;  

    -- Log das tarefas/ações de etl
    ws_tabela := 'etl_log'; 
    delete etl_log 
     where dh_inicio < add_months(trunc(sysdate,'month'),-2);    -- Mantem os últimos 2 meses + o mês atual ; 
    commit;  

    -- Documentos criados na geração de relatórios 
    ws_tabela := 'tab_documentos'; 
    delete tab_documentos 
     where ( name like 'REL%xls' or name like 'REL%html')
       and usuario = 'DWU' 
       and last_updated < add_months(trunc(sysdate,'month'),-2);    -- Mantem os últimos 2 meses + o mês atual ; 
    commit;  

    update var_conteudo set conteudo = to_char(sysdate, 'dd/mm/yyyy')
     where variavel = 'ULTIMA_LIMPEZA_LOG'; 
    commit;  

    insert into LOG_EVENTOS (data_evento, descricao, usuario, programa, tipo, onde )
                     values (sysdate, 'Executada limpeza de logs do sistema.', 'DWU', 'LIMPA_LOG', 'OK', '00'); 
    commit;  

exception when others then 
    insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values(sysdate, 'Erro LIMPA_LOGS_SISTEMA <'||ws_tabela||'>:'||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 'DWU', 'ERRO');
    commit; 
end limpa_logs_sistema;



--------------------------------------------------------------------------------------------------------------------
-- Retorna a classe da tela - Utilizada na envio dos dados de acesso 
--------------------------------------------------------------------------------------------------------------------
function ret_classe_tela ( prm_descricao  varchar2 default null, 
                           prm_programa   varchar2 default null) return varchar2 is 
    ws_classe varchar2(200);
    ws_screen varchar2(200);
    ws_posi   number;
    ws_posf   number; 
begin 
    ws_posi := instr(prm_descricao,'['); 
    ws_posf := instr(prm_descricao,']'); 
    --
    if nvl(prm_programa,'N/A') = 'BROWSER' then 
        ws_classe := 'BROWSER'; 
    elsif prm_descricao is null or ws_posi = 0 or ws_posf = 0 then 
        ws_classe := 'SEM_TELA';
    else 
        ws_screen := substr(prm_descricao, ws_posi+1, (ws_posf-ws_posi-1) );
        if ws_screen = 'DEFAULT' then 
            ws_classe := 'TELA_PRINCIPAL'; 
        else     
            select nvl(max(grfu.cd_classe),'SEM_CLASSE') into ws_classe 
              from grupos_funcao grfu, objetos obje
             where grfu.cd_grupo  = obje.cd_grupo 
               and obje.cd_objeto = ws_screen; 
        end if;     
    end if;     
    --
    return ws_classe;
    --
end ret_classe_tela; 

-- Executa do novo processo de integração 
procedure exec_integrador(prm_run_id            in varchar2,
                          prm_data_ini          in varchar2 default null,
                          prm_data_fim          in varchar2 default null,
                          prm_status_fila       in varchar2 default 'A',
                          prm_tempo_loop        in number   default 30,
                          prm_erro_step        out varchar2) as 

ws_dh_inicio  date;
ws_id_alert   number;
ws_tabelas    varchar2(100);
ws_error      varchar2(4000);
ws_status     varchar2(30);

ws_step_id        varchar2(50);   -- nome da ação
ws_tipo_comando   varchar2(50);   -- tipo ação
ws_comando        varchar2(4000); -- query inserir
ws_comando_limpar varchar2(4000); -- query deletar
ws_tab_destino    varchar2(50);   -- tabela destino
ws_unid_id        varchar2(50);   -- id da fila
ws_conexao        varchar2(200);  -- id da conexão 

ws_dh_ini_aguardar   date;
ws_status_integracao varchar2(10) := 'A';
ws_erro_integracao   varchar2(4000);
ws_st_notify         varchar2(20); 

begin

    ws_dh_inicio := sysdate;
    ws_id_alert  := null; 
    ws_tabelas   := '';   

    --Coletar informações necessárias da ELT_STEP
    select step_id, tipo_comando, comando, comando_limpar, tbl_destino, id_conexao
      into ws_step_id, ws_tipo_comando, ws_comando, ws_comando_limpar, ws_tab_destino, ws_conexao
      from etl_step
     where run_id = prm_run_id;

    sch.alert_online(ws_id_alert, 'EXEC_INTEGRADOR', ws_dh_inicio, null,prm_run_id||'-'||ws_step_id||' '||ws_tipo_comando||' '||prm_data_ini||' '||prm_data_fim ,'ATUALIZANDO','', 'REGISTRO', 'N', ws_tabelas);     

    ------------------------------------------------------------------------------------
    -- INSERIR AÇÃO NA FILA 
    ------------------------------------------------------------------------------------
    
    -- Fazer o replace do comando de insercao e delecao de acordo com as parametrizações
    if ws_tipo_comando = 'FULL' then
        null;
    elsif ws_tipo_comando = 'SCHEDULER' then
        ws_comando        := replace(replace(ws_comando,       '$[DATA_INI]',chr(39)||prm_data_ini||chr(39)),'$[DATA_FIM]',chr(39)||prm_data_fim||chr(39));
        ws_comando_limpar := replace(replace(ws_comando_limpar,'$[DATA_INI]',chr(39)||prm_data_ini||chr(39)),'$[DATA_FIM]',chr(39)||prm_data_fim||chr(39));
    end if;

    select SCH.gen_id into ws_unid_id from dual;
    
    -- Inserir ação na fila
    insert into etl_fila (id_uniq,    run_id,     tbl_destino,    comando,    comando_limpar,  dt_criacao, dt_inicio, dt_final, status,          erros,  id_conexao)
                  values (ws_unid_id, prm_run_id, ws_tab_destino, ws_comando, ws_comando_limpar, sysdate,  null,      null,     prm_status_fila, null, ws_conexao );
    commit;


    ------------------------------------------------------------------------------------
    -- AGUARDAR OPERAÇÃO DE POPULAR TABELA SER CONCLUÍDA 
    ------------------------------------------------------------------------------------
    -- Loop para aguardar finalizar carga dos dados.
    -- Se ficar mais que o tempo enviado por parametro nesse laço ele pula fora e indica o erro de "timeout"
    -- Se finalizar com erro ele tambem pula fora e registra o erro gravado na etl_fila
    -- Se finalizar ele pula fora com sucesso

    ws_dh_ini_aguardar := sysdate;

    while (sysdate - ws_dh_ini_aguardar) <= prm_tempo_loop/1440 and ws_status_integracao in ('A','R') 
    loop
        select status, erros 
          into ws_status_integracao, ws_erro_integracao
          from etl_fila
         where id_uniq = ws_unid_id 
           and run_id  = prm_run_id;
        --   
        dbms_lock.sleep(10);           
    end loop;

    if ws_status_integracao in ('A','R') then  --Se saiu do loop e o status ainda é A ou R, é pq estorou o timeout
        ws_error     := 'Aguardando integração a mais de '||prm_tempo_loop||' minutos. (SCH)';
        ws_status    := 'ERRO';
        ws_st_notify := 'ENVIO'; 
        update etl_fila set status = 'E', erros = ws_error
         where id_uniq = ws_unid_id 
           and run_id  = prm_run_id;
        commit;            
    elsif ws_status_integracao = 'E' THEN
        ws_error     := ws_erro_integracao;
        ws_status    := 'ERRO';
        ws_st_notify := 'ENVIO'; 
    else 
        ws_error     := null;
        ws_status    := 'FINALIZADO';
        ws_st_notify := 'REGISTRO'; 
    END IF;

    prm_erro_step := ws_status;  -- Retorna o Status

    sch.alert_online(ws_id_alert, 'EXEC_INTEGRADOR', ws_dh_inicio, sysdate, null, ws_status, ws_error, ws_st_notify, 'N', ws_tabelas); 

exception when others then
    ws_error      := substr(dbms_utility.format_error_stack||'-'||dbms_utility.format_error_backtrace,1,3999); 
    ws_status     := 'ERRO';
    ws_st_notify  := 'ENVIO'; 
    prm_erro_step := ws_status;    
    sch.alert_online(ws_id_alert, 'EXEC_INTEGRADOR', ws_dh_inicio, sysdate, null, ws_status, ws_error, ws_st_notify, 'N', ws_tabelas);     
end exec_integrador;



--=========================================================================================================================
--= FUNÇÕES cópias da package FUN -  Separadas da FUN para evitar lock da package FUN pelo processo de carga/job          = 
--=========================================================================================================================



--------------------------------------------------------------------------------------------------------------------
-- cópia da package FUN - Usado em Jobs para não utilizar/lockar a package FUN 
--------------------------------------------------------------------------------------------------------------------
procedure execute_now ( prm_comando  varchar2 default null,
                        prm_repeat  varchar2 default  's' ) as
    job_id          number;
    ws_owner        varchar2(90);
    ws_name         varchar2(90);
    ws_line         number;
    ws_caller       varchar2(90);
    ws_count        number := 0;

begin
    if prm_repeat = 'N' then
	    select count(*) into ws_count from all_jobs where what = trim(prm_comando)||';';
    end if;
    OWA_UTIL.WHO_CALLED_ME(ws_owner, ws_name, ws_line, ws_caller);

    if ws_count = 0 then
        dbms_job.submit(job => job_id, what => trim(prm_comando)||';', next_date => sysdate+((1/1440)/40), interval => null);
        commit;
    end if;
exception when others then
    insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - SCH.EXECUTE_NOW', 'DWU', 'ERRO');
    commit;
end execute_now;


----------------------------------------------------------------------------------------------------
-- cópia da package FUN - Usado em Jobs para não utilizar/lockar a package FUN 
----------------------------------------------------------------------------------------------------
function ret_var  ( prm_variavel   varchar2 default null, 
                    prm_usuario    varchar2 default 'DWU' ) return varchar2 as
        cursor crs_variaveis is
            select 	conteudo
            from	VAR_CONTEUDO
            where	USUARIO = prm_usuario and
                VARIAVEL = replace(replace(prm_variavel, '#[', ''), ']', '');
        ws_variaveis	crs_variaveis%rowtype;
begin
        Open  crs_variaveis;
        Fetch crs_variaveis into ws_variaveis;
        close crs_variaveis;

        return (ws_variaveis.conteudo);
exception when others then
        return '';
end ret_var;

----------------------------------------------------------------------------------------------------
-- cópia da package FUN - Usado em Jobs para não utilizar/lockar a package FUN 
----------------------------------------------------------------------------------------------------
function vpipe ( prm_entrada varchar2,
                 prm_divisao varchar2 default '|' ) return CHARRET pipelined as
   ws_bindn      number;
   ws_texto      varchar2(32000);
   ws_nm_var     varchar2(32000);
   ws_flag       char(1);
begin

   ws_flag  := 'N';
   ws_bindn := 0;
   ws_texto := prm_entrada;

   loop
        if  ws_flag = 'Y' then
            exit;
        end if;
        if  nvl(instr(ws_texto,prm_divisao),0) = 0 then
            ws_flag   := 'Y';
            ws_nm_var := ws_texto;
        else
            ws_nm_var := substr(ws_texto, 1 ,instr(ws_texto,prm_divisao)-1);
            ws_texto  := substr(ws_texto, length(ws_nm_var||prm_divisao)+1, length(ws_texto));
       end if;
       ws_bindn := ws_bindn + 1;
       pipe row (ws_nm_var);
   end loop;
exception
   when others then
      pipe row(sqlerrm||'=VPIPE');
end vpipe;

-- Gera e retorna ID único - essa função e uma cópia da FUN para evitar que a package SCH utilize a FUN e bloqueia a FUN enquando está rodando 
-----------------------------------------------------------------------------------------------------------
function gen_id return varchar2 is

	    ws_chave_final      varchar2(100);
        ws_ant_chave        varchar2(100);
        ws_tempo            varchar2(100);
        ws_chave            varchar2(100);
        p_id_cliente        varchar2(10);

begin
        begin
        p_id_cliente   := to_char(sysdate,'SSHH24SSDD');
        ws_chave_final := '';
        ws_ant_chave   := SCH.send_id;
        ws_chave       := ws_ant_chave||SCH.check_id(ws_ant_chave);
        ws_tempo       := to_char(sysdate,'DDMMYYYYHH24MISS');

        ws_chave_final := ws_chave_final||substr(ws_chave,1, 1)||substr(ws_tempo,14 ,1);
        ws_chave_final := ws_chave_final||substr(ws_chave,2, 1)||substr(ws_tempo,13 ,1);
        ws_chave_final := ws_chave_final||substr(ws_chave,3, 1)||substr(ws_tempo,12 ,1);
        ws_chave_final := ws_chave_final||substr(ws_chave,4, 1)||substr(ws_tempo,11 ,1);
        ws_chave_final := ws_chave_final||substr(ws_chave,5, 1)||substr(ws_tempo,10 ,1);
        ws_chave_final := ws_chave_final||substr(ws_chave,6, 1)||substr(ws_tempo,9 ,1);
        ws_chave_final := ws_chave_final||substr(ws_chave,7, 1)||substr(ws_tempo,8 ,1);
        ws_chave_final := ws_chave_final||substr(ws_chave,8, 1)||substr(ws_tempo,7 ,1);
        ws_chave_final := ws_chave_final||substr(ws_chave,9, 1)||substr(ws_tempo,6 ,1);
        ws_chave_final := ws_chave_final||substr(ws_chave,10,1)||substr(ws_tempo,5 ,1);
        ws_chave_final := ws_chave_final||substr(ws_chave,11,1)||substr(ws_tempo,4 ,1);
        ws_chave_final := ws_chave_final||substr(ws_chave,12,1)||substr(ws_tempo,3 ,1);
        ws_chave_final := ws_chave_final||substr(ws_chave,13,1)||substr(ws_tempo,2 ,1);
        ws_chave_final := ws_chave_final||substr(ws_chave,14,1)||substr(ws_tempo,1 ,1);

        ws_chave_final := substr(ws_chave_final,28,1)||substr(ws_chave_final,1,1)||substr(p_id_cliente,8,1)||substr(ws_chave_final,9,1)||
                          substr(ws_chave_final,25,1)||substr(ws_chave_final,2,1)||substr(p_id_cliente,7,1)||substr(ws_chave_final,10,1)||
                          substr(ws_chave_final,23,1)||substr(ws_chave_final,3,1)||substr(p_id_cliente,6,1)||substr(ws_chave_final,11,1)||
                          substr(ws_chave_final,26,1)||substr(ws_chave_final,4,1)||substr(p_id_cliente,5,1)||substr(ws_chave_final,12,1)||
                          substr(ws_chave_final,21,1)||substr(ws_chave_final,5,1)||substr(p_id_cliente,4,1)||substr(ws_chave_final,13,1)||
                          substr(ws_chave_final,24,1)||substr(ws_chave_final,6,1)||substr(p_id_cliente,3,1)||substr(ws_chave_final,14,1)||
                          substr(ws_chave_final,22,1)||substr(ws_chave_final,7,1)||substr(p_id_cliente,2,1)||substr(ws_chave_final,15,1)||
                          substr(ws_chave_final,27,1)||substr(ws_chave_final,8,1)||substr(p_id_cliente,1,1)||substr(ws_chave_final,16,1)||
                          substr(ws_chave_final,21,1)||substr(ws_chave_final,20,1)||substr(ws_chave_final,19,1)||substr(ws_chave_final,18,1)||
                          substr(ws_chave_final,17,1);
        end;
        return(ws_chave_final);
end gen_id;


-- Essa função e uma cópia da FUN para evitar que a package SCH utilize a FUN e bloqueia a FUN enquando está rodando 
-----------------------------------------------------------------------------------------------------------
function send_id ( prm_cliente varchar2 default null ) return varchar2 as

  type           tp_array is table of varchar2(2000) index by binary_integer;
  ws_array       tp_array;
  ws_counter     integer;
  ws_indice      varchar2(1);
  ws_session     varchar2(2);
  ws_indice_fake varchar2(1);
  ws_imei        varchar2(30);
  ws_origem      varchar2(30);

begin

  ws_imei         := '01275600346'||substr(prm_cliente, 7, 3)||'3877';
 
  ws_array(0)     := 'QPWOLASJIE';
  ws_array(1)     := 'ESLWPQMZNB';
  ws_array(2)     := 'YTRUIELQCB';
  ws_array(3)     := 'RADIOSULTE';
  ws_array(4)     := 'RITALQWCVM';
  ws_array(5)     := 'ZMAKQOCJDE';
  ws_array(6)     := 'YTHEDJKSPQ';
  ws_array(7)     := 'PIRALEZOUT';
  ws_array(8)     := 'HJWPAXOQTI';
  ws_array(9)     := 'DFRTEOAPQX';

  ws_indice       := substr(to_char(sysdate,'SS'),2,1);

  select  substr(ws_array(ws_indice),(to_number(substr(sid,1,1))+1),1)||substr(ws_array(ws_indice),(to_number(substr(serial#,1,1))+1),1)
          into ws_session
  from    v$session
  where   audsid  = sys_context('USERENV', 'SESSIONID');

  ws_indice_fake := abs((to_number(ws_indice)-to_number(substr(to_char(sysdate,'SS'),1,1))));

  ws_imei := substr(ws_array(ws_indice_fake),(to_number(substr(ws_imei,9, 1))+1),1)||
             substr(ws_array(ws_indice_fake),(to_number(substr(ws_imei,10,1))+1),1)||
             substr(ws_array(ws_indice_fake),(to_number(substr(ws_imei,11,1))+1),1);

  ws_indice_fake := substr(ws_array(2),(to_number(substr(ws_indice_fake, 1,1)+1)),1);
  ws_indice      := substr(ws_array(1),(to_number(substr(ws_indice,      1,1)+1)),1);

  return(ws_imei||ws_session||ws_indice||ws_indice_fake);

end send_id;


-- Essa função e uma cópia da FUN para evitar que a package SCH utilize a FUN e bloqueia a FUN enquando está rodando 
-----------------------------------------------------------------------------------------------------------
function check_id ( prm_chave varchar2 default null, prm_cliente varchar2 default null ) return varchar2 as

	type tp_array is table of varchar2(2000) index by binary_integer;
	ws_array       tp_array;
	ws_counter     integer;
	ws_indice      varchar2(1);
	ws_indice_fake varchar2(1);
	ws_session     varchar2(2);
	ws_check_imei  varchar2(3);
	ws_imei        varchar2(30);
	ws_retorno     varchar2(30);

begin

    ws_imei     := '01275600346'||substr(prm_cliente, 7, 3)||'3877';

	ws_array(0) := 'QPWOLASJIE';
	ws_array(1) := 'ESLWPQMZNB';
	ws_array(2) := 'YTRUIELQCB';
	ws_array(3) := 'RADIOSULTE';
	ws_array(4) := 'RITALQWCVM';
	ws_array(5) := 'ZMAKQOCJDE';
	ws_array(6) := 'YTHEDJKSPQ';
	ws_array(7) := 'PIRALEZOUT';
	ws_array(8) := 'HJWPAXOQTI';
	ws_array(9) := 'DFRTEOAPQX';

	ws_indice      := (instr(ws_array(1),substr(prm_chave,6,1)))-1;
	ws_indice_fake := (instr(ws_array(2),substr(prm_chave,7,1)))-1;
	ws_session     := (instr(ws_array(ws_indice), substr(prm_chave,4,1))-1) ||	
                      (instr(ws_array(ws_indice), substr(prm_chave,5,1))-1);
	ws_check_imei  := (instr(ws_array(ws_indice_fake),substr(prm_chave,1,1))-1) ||  
                      (instr(ws_array(ws_indice_fake),substr(prm_chave,2,1))-1) ||
	                  (instr(ws_array(ws_indice_fake),substr(prm_chave,3,1))-1);

	ws_indice      := substr(to_char(sysdate,'SS'),2,1);
	ws_indice_fake := abs((to_number(ws_indice)-to_number(substr(to_char(sysdate,'SS'),1,1))));
	ws_session     := substr(ws_array(abs(abs(ws_indice - ws_indice_fake))),(to_number(substr(ws_session,1,1))+1),1) ||
	                  substr(ws_array(abs(abs(ws_indice - ws_indice_fake))),(to_number(substr(ws_session,2,1))+1),1);
	ws_imei        := substr(ws_array(ws_indice_fake),(to_number(substr(ws_imei,12, 1))+1),1)||
	                  substr(ws_array(ws_indice_fake),(to_number(substr(ws_imei,13, 1))+1),1)||
	                  substr(ws_array(ws_indice_fake),(to_number(substr(ws_imei,14, 1))+1),1);

	ws_indice_fake := substr(ws_array(4),(to_number(substr(ws_indice_fake, 1,1)+1)),1);
	ws_indice      := substr(ws_array(5),(to_number(substr(ws_indice, 1,1)+1)),1);

	if ws_check_imei <> substr(ws_imei,9,3) then
	    ws_retorno := 'ERRO';
	else
	    ws_retorno := ws_imei||ws_session||ws_indice||ws_indice_fake;
	end if;

	return(ws_retorno);

end check_id;


function tipo_ambiente ( prm_cd_cliente varchar2  default null ) return varchar2 as
    ws_cd_cliente varchar2(50); 
begin 
    ws_cd_cliente := nvl(prm_cd_cliente, sch.ret_var('CLIENTE')); 
    if    ws_cd_cliente in ('999999911','999999906') then          return 'DESENV';
    elsif ws_cd_cliente = '999999907' then                         return 'HOMOLOGA';
    else                                                           return 'PRODUCAO';
    end if; 
end tipo_ambiente;  



end SCH;
