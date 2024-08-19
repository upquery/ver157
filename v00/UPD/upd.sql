create or replace package body UPD  is


---------------------------------------------------------------------------------------------------------------------------------------------------------
-------- Verifica se o cliente tem pemissão de Auto Update cadastrado na base da Upquery 
---------------------------------------------------------------------------------------------------------------------------------------------------------
function AutoUpdate_permissao ( prm_usuario        varchar2 ) return varchar2 as
    ws_cliente varchar2(100); 
    ws_url     varchar2(200);  
    ws_res     varchar2(400);
    ws_req     varchar2(800);
    ws_retorno varchar2(300);
begin

    -- Tipo de permissão de update de sistema 
    --  0  Sem permissão
	--	1  Manual (bi)
	--	2  Automático (job)
	--	9  Todos
    --  N  Não tem permissão - opção descontinuada 
    --  S  Tem permissão     - opção descontinuada 

    ws_url     := UPD.RET_VAR('URL_AUTOUPDATE');
    ws_cliente := upd.ret_var('CLIENTE'); 

    ws_retorno := '-1'; 
    ws_req := 'http://'||ws_url||'/dwu.beup.get_update_sistema?prm_chave=&prm_sistema=BI&prm_versao=&prm_tipo=CHECK_PERMISSAO&prm_cliente='||ws_cliente; 
    ws_res  := trim(UTL_HTTP.REQUEST(ws_req));
    ws_res := utl_url.unescape(ws_res, 'ISO-8859-1');

    if    ws_res like '0|%' then   ws_retorno := '0';
    elsif ws_res like '1|%' then   ws_retorno := '1';
    elsif ws_res like '2|%' then   ws_retorno := '2';
    elsif ws_res like '9|%' then   ws_retorno := '9';
    else  
        insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values (sysdate, 'Erro AutoUpdate_permissao: '|| ws_res, prm_usuario, 'ERRO'); 
        commit;
        ws_retorno := '0';
    end if;        

    return ws_retorno; 
exception when others then
    insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values (sysdate, 'Erro AutoUpdate_permissao: '|| DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, prm_usuario, 'ERRO'); 
    commit;
    return '-1';
end AutoUpdate_permissao ;


---------------------------------------------------------------------------------------------------------------------------------------------------------
-------- Atualiza parametros retornados da UPQUERY  
---------------------------------------------------------------------------------------------------------------------------------------------------------
procedure AutoUpdate_atu_parametros ( prm_sistema     varchar2,
                                      prm_usuario     varchar2 )  as
    ws_cliente  varchar2(100); 
    ws_url      varchar2(200);  
    ws_res      varchar2(400);
    ws_req      varchar2(800);
    ws_retorno  varchar2(300);
    ws_hr_baixa varchar2(100); 
    ws_hr_atu   varchar2(100); 
begin

    ws_url     := UPD.RET_VAR('URL_AUTOUPDATE');
    ws_cliente := upd.ret_var('CLIENTE'); 

    ws_retorno := 'Erro verificando permiss&atilde;o de atualiza&ccedil;&atilde;o, entre contato com o administrador do sistema'; 
    ws_req := 'http://'||ws_url||'/dwu.beup.get_update_sistema?prm_chave=&prm_sistema='||prm_sistema||'&prm_versao=&prm_tipo=CHECK_PARAMETROS&prm_cliente='||ws_cliente;
    ws_res := UTL_HTTP.REQUEST(ws_req);
    ws_res := utl_url.unescape(ws_res, 'UTF-8');     
    ws_res := REPLACE(ws_res,CHR(10),'');    -- retira uma quebra de linha 

    if ws_res like 'ERRO|%' then 
        insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values (sysdate, 'Erro AutoUpdate_atu_parametros: '|| ws_res, prm_usuario, 'ERRO'); 
        commit;
    else 
        begin 
            ws_hr_baixa := null;
            ws_hr_baixa := trim(upd.ret_param_nome (ws_res, 'HR_AUTOUPDATE_BAIXA')); 
            if ws_hr_baixa is not null and NVL(UPD.ret_var('HR_AUTOUPDATE_BAIXA'),'-1') <> ws_hr_baixa then 
                update var_conteudo set conteudo = ws_hr_baixa 
                where variavel = 'HR_AUTOUPDATE_BAIXA' ;
                if sql%notfound then 
                    insert into VAR_CONTEUDO (usuario, variavel, data, conteudo, locked) values ('DWU', 'HR_AUTOUPDATE_BAIXA', sysdate, ws_hr_baixa, 'S'); 
                end if ;
                commit; 
            end if; 

            ws_hr_atu  := null; 
            ws_hr_atu  := trim(upd.ret_param_nome (ws_res, 'HR_AUTOUPDATE_ATU')); 
            if NVL(UPD.ret_var('HR_AUTOUPDATE_ATU'),'-1') <> nvl(ws_hr_atu,'-1') then 
                update var_conteudo set conteudo = ws_hr_atu 
                where variavel = 'HR_AUTOUPDATE_ATU' ;
                if sql%notfound then 
                    insert into VAR_CONTEUDO (usuario, variavel, data, conteudo, locked) values ('DWU', 'HR_AUTOUPDATE_ATU', sysdate, ws_hr_atu, 'S'); 
                end if ;
                commit; 
            end if; 
        exception when others then     
            insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values (sysdate, 'Erro AutoUpdate_atu_parametros: '|| DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, prm_usuario, 'ERRO'); 
        end; 
    end if;        

exception when others then
    insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values (sysdate, 'Erro AutoUpdate_atu_parametros(outros): '|| DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, prm_usuario, 'ERRO'); 
    commit;
end AutoUpdate_atu_parametros ;


---------------------------------------------------------------------------------------------------------------------------------------------------------
-------- Verifica se tem novas alterações na UPDATE da Upquery - necessário executar antes o     
---------------------------------------------------------------------------------------------------------------------------------------------------------
procedure AutoUpdate_check_atualizacoes (prm_sistema     varchar2 default null,
                                         prm_versao      varchar2 default null,
                                         prm_usuario     varchar2 default null,
                                         prm_tp_atualiza varchar2 default 'ATUALIZA' ) as
    ws_url         varchar2(100); 
    ws_req         varchar2(200);
    ws_res         UTL_HTTP.HTML_PIECES;    
	ws_output      clob;
    ws_tp_objeto   varchar2(200);
    ws_nm_objeto   varchar2(200);
    ws_ds_objeto   varchar2(200);
    ws_st_objeto   varchar2(10);
    ws_cd_versao   varchar2(20); 
    ws_cliente     varchar2(100);
    ws_tp_check    varchar2(40);  
    ws_dt_versao_upquery  date; 
    ws_tp_conteudo        varchar2(20);
    ws_mime_type          varchar2(100);
    ws_sq_atualizacao     integer; 
    ws_qt_registros       number; 
    ws_qt_atualizado      integer; 
    ws_msg                varchar2(300); 
    ws_id_atu             number; 
    ws_dt_versao_sistema  date;
    ws_id_situacao        varchar2(20);
    ws_param         exception;
begin

    select nvl(max(id_auto_update),0)+1 into ws_id_atu from bi_auto_update_log; 
    if prm_tp_atualiza <> 'MANUTENCAO' then -- Não gera log para manutenção 
        AutoUpdate_log (ws_id_atu, 'CHECK', 'TODOS', 'TODOS', 'INICIO', null, prm_usuario);  
    end if;     


    ws_cliente := upd.ret_var('CLIENTE'); 
    ws_url     := UPD.RET_VAR('URL_AUTOUPDATE');

    if prm_tp_atualiza = 'MANUTENCAO' then 
        ws_tp_check := 'CHECK_MANUTENCAO'; 
    else    
        ws_tp_check := 'CHECK_UPDATE';  
    end if; 

    ws_req := 'http://'||ws_url||'/dwu.beup.get_update_sistema?prm_chave=&prm_sistema='||prm_sistema||'&prm_versao='||prm_versao||'&prm_tipo='||ws_tp_check||'&prm_cliente='||ws_cliente;  
    ws_res := UTL_HTTP.REQUEST_PIECES(ws_req, 32767);
    for a in 1..ws_res.count LOOP
       ws_output := ws_output||ws_res(a);
    end loop;
    ws_output := utl_url.unescape(ws_output, 'ISO-8859-1');            

    -- Marca como sem registro para controle dtodos como inválidos 
    update bi_auto_update set id_situacao = 'INVALIDO' 
     where ( (prm_tp_atualiza = 'ATUALIZA') or (prm_tp_atualiza = 'MANUTENCAO' and tp_objeto = 'MANUTENCAO') ); 


    -- Atualiza a situação dos objetos em comparação ao base Upquery
    ws_qt_atualizado := 0;
    for i in(select column_value as conteudo_linha from table(upd.vpipe_clob(ws_output) )     ) loop
        begin 
            ws_tp_objeto         :=  upd.vpipe_n(i.conteudo_linha,1,';');
            ws_nm_objeto         :=  upd.vpipe_n(i.conteudo_linha,2,';');
            ws_ds_objeto         :=  upd.vpipe_n(i.conteudo_linha,3,';');
            ws_dt_versao_upquery :=  to_date(upd.vpipe_n(i.conteudo_linha,4,';'),'ddmmyyyyhh24miss');     -- mesmo formato usado no envio 
            ws_st_objeto         :=  upd.vpipe_n(i.conteudo_linha,5,';');
            ws_sq_atualizacao    :=  upd.vpipe_n(i.conteudo_linha,6,';');
            ws_mime_type         :=  upd.vpipe_n(i.conteudo_linha,7,';');
            ws_tp_conteudo       :=  upd.vpipe_n(i.conteudo_linha,8,';');
            ws_qt_registros      :=  upd.vpipe_n(i.conteudo_linha,9,';');
            ws_cd_versao         :=  upd.vpipe_n(i.conteudo_linha,10,';');
        exception when others then 
            raise ws_param;
        end; 

        if ws_tp_objeto is not null then 
            ws_dt_versao_sistema := null;
            ws_id_situacao       := null; 
            --   
            if ws_st_objeto = 'B' then 
               ws_id_situacao := 'BLOQUEADO';
            else
                select max(dt_versao_sistema), max(id_situacao) 
                  into ws_dt_versao_sistema, ws_id_situacao 
                  from bi_auto_update 
                 where tp_objeto  = ws_tp_objeto
                   and nm_objeto  = ws_nm_objeto ;   
                --
                if ws_id_situacao <> 'ERRO' then 
                    if ws_dt_versao_upquery = nvl(ws_dt_versao_sistema, ws_dt_versao_upquery-1) then   
                        ws_id_situacao := 'ATUALIZADO';
                    else
                        ws_id_situacao := 'PENDENTE'; 
                    end if;    
                end if; 
            end if;     
            --
            update bi_auto_update 
                set cd_versao          = ws_cd_versao, 
                    dt_versao_upquery  = ws_dt_versao_upquery,
                    ds_objeto          = ws_ds_objeto,
                    sq_atualizacao     = ws_sq_atualizacao,
                    tp_conteudo        = ws_tp_conteudo,
                    mime_type_arquivo  = ws_mime_type,
                    id_situacao        = ws_id_situacao,
                    qt_registros       = nvl(ws_qt_registros,0)
                where tp_objeto  = ws_tp_objeto
                  and nm_objeto  = ws_nm_objeto ;   
            if sql%notfound then  
                insert into bi_auto_update (tp_objeto,nm_objeto,ds_objeto,dt_versao_upquery, sq_atualizacao, tp_conteudo, mime_type_arquivo, id_situacao, qt_registros, cd_versao) 
                                    values (ws_tp_objeto,ws_nm_objeto,ws_ds_objeto,ws_dt_versao_upquery, ws_sq_atualizacao, ws_tp_conteudo, ws_mime_type, 'PENDENTE', nvl(ws_qt_registros,0), ws_cd_versao);   -- Pendente, Atualizado, Erro atualização, Bloqueada
            end if;    
            ws_qt_atualizado := ws_qt_atualizado + 1;
        end if;    
    end loop;

    -- Se atualizou mais que 3 objetos (não deu erro de conexão), exclui os objetos inválidos atualizados a mais de 3 dias  
    if ws_qt_atualizado > 3  then 
        delete bi_auto_update 
            where id_situacao       = 'INVALIDO'
              and dt_versao_upquery < trunc(sysdate-3)
              and ( (prm_tp_atualiza = 'ATUALIZA') or (prm_tp_atualiza = 'MANUTENCAO' and tp_objeto = 'MANUTENCAO') ); 
    end if;        
    --  
    if prm_tp_atualiza <> 'MANUTENCAO' then -- Não gera log para manutenção 
        AutoUpdate_log (ws_id_atu, 'CHECK', 'TODOS', 'TODOS', 'FIM', 'ok', prm_usuario);  
    end if;     
    --    
    COMMIT; 
exception 
    when ws_param then 
        ws_msg := 'Erro no conteudo recebido : '||ws_tp_objeto||'-'||ws_nm_objeto; 
        AutoUpdate_log (ws_id_atu, 'CHECK', 'TODOS', 'TODOS', 'ERRO', ws_msg, prm_usuario);      
        insert into bi_log_sistema (dt_log, ds_log,nm_usuario, nm_procedure) values(sysdate, 'Erro AutoUpdate_check_atualizacoes '||ws_msg, prm_usuario, 'ERRO'); 
        commit; 
    when others then 
        ws_msg := substr(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,299); 
        AutoUpdate_log (ws_id_atu, 'CHECK', 'TODOS', 'TODOS', 'ERRO', ws_msg, prm_usuario);      
        insert into bi_log_sistema (dt_log,ds_log,nm_usuario,nm_procedure) values(sysdate, 'Erro AutoUpdate_check_atualizacoes:'||ws_msg, prm_usuario, 'ERRO'); 
        commit; 
end AutoUpdate_check_atualizacoes; 


---------------------------------------------------------------------------------------------------------------------------------------------------------
-------- Busca o conteúdo dos objetos atualizados 
---------------------------------------------------------------------------------------------------------------------------------------------------------
procedure AutoUpdate_baixa_conteudo (prm_sistema     varchar2,
                                     prm_versao      varchar2,
                                     prm_usuario     varchar2,
                                     prm_tipo        varchar2,
                                     prm_nome        varchar2,
                                     prm_chamada     varchar2 default 'BANCO',
                                     prm_tp_atualiza varchar2 default 'ATUALIZA' ) as

cursor c_bi_auto_update is 
    select tp_objeto, nm_objeto, tp_conteudo, sq_atualizacao, cd_versao 
      from bi_auto_update
     where (dt_versao_baixa <> dt_versao_upquery or dt_versao_baixa is null)   
       and ( prm_tipo = 'TODOS' or tp_objeto = prm_tipo or (prm_tipo = 'PACKAGE' and tp_objeto like 'PACKAGE%') )   
       and ( prm_nome = 'TODOS' or nm_objeto = prm_nome)     
       and id_situacao not in ('BLOQUEADO','INVALIDO')  -- Se não estiver bloqueado ou Invalido      
       and tp_objeto not in ('ESTADOS', 'CIDADES')
       and ( (prm_tp_atualiza = 'ATUALIZA') or (prm_tp_atualiza = 'MANUTENCAO' and tp_objeto = 'MANUTENCAO') ) 
     order by 3;

ws_id_atu           number; 
ws_permissao        varchar2(100) := null; 
ws_url              varchar2(100); 
ws_msg              varchar2(200);
ws_qt_obj           number;
ws_qt_erro          number; 
ws_usuario          varchar2(200);
ws_dt_versao        date; 
ws_id_permissao     varchar2(100);
ws_clob             clob;
ws_blob             blob; 
ws_erro_permissao   exception;

begin 

    ws_msg := null; 
    select nvl(max(id_auto_update),0)+1 into ws_id_atu from bi_auto_update_log; 

    if prm_tipo = 'TODOS' and prm_tp_atualiza <> 'MANUTENCAO' then -- Não gera log para manutenção 
        AutoUpdate_log (ws_id_atu, 'BAIXA', 'TODOS', 'TODOS', 'INICIO', null, prm_usuario);  
    end if;     
    
    ws_id_permissao := nvl(upd.autoUpdate_permissao(prm_usuario),'0'); 
    
    if (ws_id_permissao = '9'                                 ) or    -- Permissao total 
       (prm_chamada  = 'NAVEGADOR' and ws_id_permissao = '1'  ) or    -- Permissao de atualização manual (via BI)
       (prm_chamada  = 'BANCO'     and ws_id_permissao = '2'  ) then  -- Permissao de atualização automatica (via job)
       null; -- Não faz nada porque tem permissão 
    elsif ws_id_permissao = '-1' then 
        ws_msg := 'Erro verificando permiss&atilde;o de atualiza&ccedil;&atilde;o, entre contato com o administrador do sistema'; 
        raise ws_erro_permissao;         
    else     
        ws_msg := 'Sem permissao de update de sistema';  
        raise ws_erro_permissao; 
    end if; 

    ws_qt_obj  := 0;
    ws_qt_erro := 0; 
    ws_url := UPD.RET_VAR('URL_AUTOUPDATE');

    for a in c_bi_auto_update loop 
        AutoUpdate_log (ws_id_atu, 'BAIXA', a.tp_objeto, a.nm_objeto, 'INICIO', null, prm_usuario);  
        ws_qt_obj := ws_qt_obj + 1;
        if a.tp_objeto = 'AVISO' then 
            autoUpdate_baixa_atu_avisos ( ws_url, prm_sistema, a.cd_versao, prm_usuario, a.tp_objeto, a.nm_objeto, ws_msg); 
            if ws_msg is null then 
                ws_msg := 'OK|';             
                update bi_auto_update 
                   set dt_versao_baixa   = dt_versao_upquery,
                       dt_versao_sistema = dt_versao_upquery
                 where tp_objeto = a.tp_objeto
                   and nm_objeto = a.nm_objeto ;
                commit;    
            end if;
        elsif a.tp_conteudo = 'CLOB' then 
            autoUpdate_baixa_CLOB ( ws_url, prm_sistema, a.cd_versao, prm_usuario, a.tp_objeto, a.nm_objeto, ws_msg, ws_clob); 
            if ws_msg is null then 
                update bi_auto_update 
                   set conteudo_clob = ws_clob,
                       dt_versao_baixa = dt_versao_upquery
                 where tp_objeto = a.tp_objeto
                   and nm_objeto = a.nm_objeto ;
                commit; 
            end if;        
        elsif a.tp_conteudo = 'BLOB' then 
            autoUpdate_baixa_BLOB ( ws_url, prm_sistema, a.cd_versao, prm_usuario, a.tp_objeto, a.nm_objeto, ws_msg, ws_blob); 
            if ws_msg is null then 
                update bi_auto_update 
                   set conteudo_blob = ws_blob,
                       dt_versao_baixa = dt_versao_upquery
                 where tp_objeto = a.tp_objeto
                   and nm_objeto = a.nm_objeto ;
                commit; 
            end if;        
        else 
            ws_msg := 'Tipo de conteudo invalido para atualizacao';    
        end if; 

        if ws_msg not like 'OK|%' then 
            ws_qt_erro := ws_qt_erro + 1; 
            AutoUpdate_log (ws_id_atu, 'BAIXA', a.tp_objeto, a.nm_objeto, 'ERRO', ws_msg, prm_usuario);
        else 
            AutoUpdate_log (ws_id_atu, 'BAIXA', a.tp_objeto, a.nm_objeto, 'FIM', 'Ok', prm_usuario);          
        end if;     
    end loop; 

    if prm_tipo = 'TODOS' and prm_tp_atualiza <> 'MANUTENCAO' then -- Não gera log para manutenção 
        if ws_qt_erro = 0 then 
            AutoUpdate_log (ws_id_atu, 'BAIXA', 'TODOS', 'TODOS', 'FIM', 'objetos:'||ws_qt_obj||', erros:'||ws_qt_erro, prm_usuario);  
        else 
            AutoUpdate_log (ws_id_atu, 'BAIXA', 'TODOS', 'TODOS', 'ERRO', 'objetos:'||ws_qt_obj||', erros:'||ws_qt_erro, prm_usuario);  
        end if;     
    end if; 

    if prm_chamada = 'NAVEGADOR' then 
        if ws_qt_erro > 0 then 
            insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values (sysdate, 'Erro AutoUpdate_baixa_conteudo: '||ws_msg, prm_usuario, 'ERRO');     
            commit; 
            htp.p('ERRO||Erro na baixa|'||ws_msg);
        else
            if ws_qt_obj = 0 then 
                htp.p('ERRO||Erro na baixa|Erro nenhum objeto baixado');
            else     
                ws_msg := ws_qt_obj||' objeto(s) baixado(s) com sucesso.'; 
                select max(dt_versao_baixa) into ws_dt_versao from bi_auto_update 
                 where ( prm_tipo = 'TODOS' or tp_objeto = prm_tipo or (prm_tipo = 'PACKAGE' and tp_objeto like 'PACKAGE%') )   
                   and ( prm_nome = 'TODOS' or nm_objeto = prm_nome)   ; 
                htp.p('OK|'||to_char(ws_dt_versao,'DD/MM/YYYY HH24:MI')||'|Atualizado|'||ws_msg );
            end if;     
        end if;
    end if; 
exception 
    when ws_erro_permissao  then 
        AutoUpdate_log (ws_id_atu, 'BAIXA', prm_tipo, prm_nome, 'ERRO', ws_msg, prm_usuario);  
        if prm_chamada = 'NAVEGADOR' then 
            htp.p('ERRO||Sem permissão|'||ws_msg);
        end if;    
    when others then 
        ws_msg := DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE; 
        AutoUpdate_log (ws_id_atu, 'BAIXA', prm_tipo, prm_tipo, 'ERRO', ws_msg, prm_usuario);  
        insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values (sysdate, 'Erro AutoUpdate_baixa_conteudo(OTHERS): '|| ws_msg, prm_usuario, 'ERRO'); 
        commit; 
        if prm_chamada = 'NAVEGADOR' then 
            htp.p('ERRO||Erro na baixa|'||ws_msg);
        end if;    

end AutoUpdate_baixa_conteudo; 


---------------------------------------------------------------------------------------------------------------------------------------------------------
-------- Busca conteudos CLOB 
---------------------------------------------------------------------------------------------------------------------------------------------------------
procedure autoUpdate_baixa_clob (prm_url            varchar2, 
                                 prm_sistema        varchar2, 
                                 prm_versao         varchar2, 
                                 prm_usuario        varchar2,
                                 prm_tipo           varchar2, 
                                 prm_nome           varchar2, 
                                 prm_msg     in out varchar2,
                                 prm_clob    in out clob ) as 
    ws_res          UTL_HTTP.HTML_PIECES;
    ws_req          varchar2(800);
    ws_clob          clob;
    ws_ds_erro       varchar2(500);
    ws_erro_atualizando exception ;
begin

    prm_msg      := null;  
    prm_clob     := null; 
    ws_ds_erro   := null; 
    ws_clob      := NULL;         

    ws_req       := 'http://'||prm_url||'/dwu.beup.get_update_sistema?prm_chave=&prm_sistema='||prm_sistema||'&prm_versao='||prm_versao||'&prm_tipo='||prm_tipo||'&prm_nm_conteudo='||prm_nome;
    ws_res       := UTL_HTTP.REQUEST_PIECES(ws_req, 32767);
    for a in 1..ws_res.count LOOP
        ws_clob := ws_clob||ws_res(a);
    end loop;

    if ws_clob is null then
        ws_ds_erro := 'Conteudo retornou nulo';
        raise ws_erro_atualizando;
    end if; 

    if trim(ws_clob) LIKE 'ERRO|%' then 
        ws_ds_erro := replace(ws_clob,'ERRO|','');
        raise ws_erro_atualizando;
    end if; 

    if prm_tipo like 'PACKAGE%' then 
       ws_clob := replace(replace(ws_clob,chr(10),''),chr(13),' ');  -- Retira final de linha e troca o ENTER por espaco 
    end if;   

    prm_clob := ws_clob; 

 exception 
    when ws_erro_atualizando then 
        prm_msg := ws_ds_erro; 
    when others then
        prm_msg := DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE; 

end autoUpdate_baixa_clob;


---------------------------------------------------------------------------------------------------------------------------------------------------------
-------- Busca conteudos BLOB - arquivos 
---------------------------------------------------------------------------------------------------------------------------------------------------------
procedure autoUpdate_baixa_blob ( prm_url            varchar2, 
                                  prm_sistema        varchar2, 
                                  prm_versao         varchar2, 
                                  prm_usuario        varchar2,
                                  prm_tipo           varchar2, 
                                  prm_nome           varchar2, 
                                  prm_msg     in out varchar2,
                                  prm_blob    in out blob ) as 
    ws_req           UTL_HTTP.req; 
    ws_res           UTL_HTTP.resp;    
    ws_url           varchar2(800);
    ws_nm_objeto_iso varchar2(100);    
    ws_ds_erro       varchar2(1000); 
    ws_blob          blob;
    ws_raw           RAW(32767);
    ws_res_txt       varchar2(1000); 
    ws_count         integer;
    ws_erro_atualizando exception ;
begin

    prm_msg          := null;  
    prm_blob         := null; 
    ws_ds_erro       := null; 
    ws_nm_objeto_iso := utl_url.escape(prm_nome, true, 'ISO-8859-1');  
            
    -- Busca conteúdo do objeto/arquivo 
    ws_url       := 'http://'||prm_url||'/dwu.beup.get_update_sistema?prm_chave=&prm_sistema='||prm_sistema||'&prm_versao='||prm_versao||'&prm_tipo='||prm_tipo||'&prm_nm_conteudo='||ws_nm_objeto_iso;
    ws_req  := UTL_HTTP.begin_request (ws_url); 
    ws_res  := UTL_HTTP.get_response(ws_req);

    -- Lê o conteudo retornado e transforma em BLOB para gravar na tabela  
    ws_count := 0;
    dbms_lob.createtemporary(ws_blob, false);
    begin
        loop
            ws_count := ws_count + 1; 
            utl_http.read_raw(ws_res, ws_raw, 32767);
            dbms_lob.writeappend (ws_blob, utl_raw.length(ws_raw), ws_raw);

            -- Verifica se retornou erro 
            if ws_count = 1 then 
                ws_res_txt := substr(UTL_RAW.CAST_TO_VARCHAR2(ws_raw),1,500);
                if trim(ws_res_txt) LIKE 'ERRO|%' then 
                    ws_ds_erro := replace(ws_res_txt,'ERRO|',''); 
                    raise ws_erro_atualizando; 
                end if; 
            end if;     
        end loop;
    exception
        when utl_http.end_of_body then
            utl_http.end_response(ws_res);
    end;

    prm_blob := ws_blob ; 

exception 
    when ws_erro_atualizando then 
        prm_msg := ws_ds_erro; 
    when others then
        prm_msg := DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE; 
end autoUpdate_baixa_blob;



---------------------------------------------------------------------------------------------------------------------------------------------------------
-------- Busca e atualiza os Avisos de sistema 
---------------------------------------------------------------------------------------------------------------------------------------------------------
procedure autoUpdate_baixa_atu_avisos (prm_url            varchar2, 
                                       prm_sistema        varchar2, 
                                       prm_versao         varchar2, 
                                       prm_usuario        varchar2,
                                       prm_tipo           varchar2, 
                                       prm_nome           varchar2, 
                                       prm_msg     in out varchar2 ) as 
    ws_res              UTL_HTTP.HTML_PIECES;
    ws_req              varchar2(800);
    ws_clob             clob;
    ws_blob             blob; 
    ws_mime_type        varchar2(100); 
    ws_ds_erro          varchar2(500);
    ws_count            integer; 
    ws_aviso            bi_avisos%rowtype; 
    ws_erro_atualizando exception ;
begin

    prm_msg      := null;  
    ws_ds_erro   := null; 
    ws_clob      := NULL;         

    ws_req := 'http://'||prm_url||'/dwu.beup.get_update_sistema?prm_chave=&prm_sistema='||prm_sistema||'&prm_versao='||prm_versao||'&prm_tipo='||prm_tipo||'&prm_nm_conteudo='||prm_nome;    
    ws_res := UTL_HTTP.REQUEST_PIECES(ws_req, 32767);
    for a in 1..ws_res.count LOOP
       ws_clob := ws_clob||ws_res(a);
    end loop;

    if ws_clob is null then 
        ws_ds_erro := 'Conteudo retornou nulo';
        raise ws_erro_atualizando;
    end if; 

    if trim(ws_clob) LIKE 'ERRO|%' then 
        ws_ds_erro := replace(ws_clob,'ERRO|','');
        raise ws_erro_atualizando;
    end if; 

    ws_clob := utl_url.unescape(ws_clob, 'ISO-8859-1');            

    -- Atualiza os avisos 
    for i in(select column_value as conteudo_linha from table(upd.vpipe_clob(ws_clob) )     ) loop
        begin 
            ws_aviso := null;
            ws_aviso.id_aviso     :=  upd.vpipe_n(i.conteudo_linha,1,';');
            ws_aviso.ds_aviso     :=  upd.vpipe_n(i.conteudo_linha,2,';');
            ws_aviso.dh_inicio    :=  to_date(upd.vpipe_n(i.conteudo_linha,3,';'),'ddmmyyyyhh24miss');     -- mesmo formato usado no envio 
            ws_aviso.dh_fim       :=  to_date(upd.vpipe_n(i.conteudo_linha,4,';'),'ddmmyyyyhh24miss');     -- mesmo formato usado no envio             
            ws_aviso.tp_usuario   :=  upd.vpipe_n(i.conteudo_linha,5,';');
            ws_aviso.tp_conteudo  :=  upd.vpipe_n(i.conteudo_linha,6,';');
            ws_aviso.nm_conteudo  :=  upd.vpipe_n(i.conteudo_linha,7,';');
            ws_aviso.url_aviso    :=  upd.vpipe_n(i.conteudo_linha,8,';');
            ws_aviso.dh_alteracao :=  to_date(upd.vpipe_n(i.conteudo_linha,9,';'),'ddmmyyyyhh24miss');     -- mesmo formato usado no envio
        exception when others then 
            ws_ds_erro := substr('Erro conteudo do aviso '||ws_aviso.id_aviso||' - '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,499);
            raise ws_erro_atualizando;
        end; 
        --

        select count(*) into ws_count from bi_avisos 
         where id_aviso     = ws_aviso.id_aviso 
           and dh_alteracao = ws_aviso.dh_alteracao;  

        -- Se não existe o aviso ou existe mas foi alterado 
        if ws_count = 0 and ws_aviso.id_aviso is not null then
            
            -- Atualiza ou cria o aviso 
            update bi_avisos 
               set ds_aviso      = ws_aviso.ds_aviso,     
                   dh_inicio     = ws_aviso.dh_inicio,    
                   dh_fim        = ws_aviso.dh_fim,         
                   tp_usuario    = ws_aviso.tp_usuario,   
                   tp_conteudo   = ws_aviso.tp_conteudo,  
                   nm_conteudo   = ws_aviso.nm_conteudo,  
                   url_aviso     = ws_aviso.url_aviso, 
                   dh_alteracao  = ws_aviso.dh_alteracao 
             where id_aviso      = ws_aviso.id_aviso; 
            if sql%notfound then 
                insert into bi_avisos (id_aviso, ds_aviso, dh_inicio, dh_fim, tp_usuario, tp_conteudo, nm_conteudo, url_aviso, dh_alteracao)
                               values (ws_aviso.id_aviso, ws_aviso.ds_aviso, ws_aviso.dh_inicio, ws_aviso.dh_fim, ws_aviso.tp_usuario, ws_aviso.tp_conteudo, ws_aviso.nm_conteudo, ws_aviso.url_aviso, ws_aviso.dh_alteracao ); 
            end if;         

            -- Se for uma imagem interna do BI, faz o download da imagem da Upquery e grava na tab_documentos  
            if ws_aviso.tp_conteudo = 'IMAGEM_INTERNA' then  
                autoUpdate_baixa_clob ( prm_url, prm_sistema, prm_versao, prm_usuario,  'AVISO_IMAGEM_MIME', ws_aviso.nm_conteudo, ws_ds_erro, ws_clob); 
                if ws_ds_erro is not null then 
                    raise ws_erro_atualizando;
                end if;     
                ws_mime_type := ws_clob; 

                autoUpdate_baixa_blob ( prm_url, prm_sistema, prm_versao, prm_usuario,  'AVISO_IMAGEM', ws_aviso.nm_conteudo, ws_ds_erro, ws_blob); 
                if ws_ds_erro is not null then 
                    raise ws_erro_atualizando;
                end if;     
                --
                delete tab_documentos 
                 where name = ws_aviso.nm_conteudo
                   and usuario = 'AVISO'; 
                begin 
                    insert into tab_documentos (name, mime_type, doc_size, dad_charset, last_updated, content_type, blob_content, usuario)  
                                        values (ws_aviso.nm_conteudo, ws_mime_type, dbms_lob.getlength(ws_blob), 'ascii', sysdate, 'BLOB', ws_blob, 'AVISO') ;
                exception when others then 
                    ws_ds_erro := 'Erro gravando na tab_documentos o arquivo do aviso'; 
                    raise ws_erro_atualizando;
                end;                                         
            end if; 
            COMMIT;                
        end if;   
    end loop; 
    
    -- 
 exception 
    when ws_erro_atualizando then 
        prm_msg := ws_ds_erro; 
    when others then
        prm_msg := DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE; 

end autoUpdate_baixa_atu_avisos;


---------------------------------------------------------------------------------------------------------------------------------------------------------
-------- Atualiza o conteúdo dos objetos atualizados 
---------------------------------------------------------------------------------------------------------------------------------------------------------
procedure AutoUpdate_atu_sistema  (prm_usuario      varchar2 default 'DWU',
                                   prm_tipo         varchar2 default 'TODOS',
                                   prm_nome         varchar2 default 'TODOS' ,
                                   prm_tp_atualiza  varchar2 default 'ATUALIZA',                                    
                                   prm_chamada      varchar2 default 'BANCO' ) as


-- Objetos pendentes de atualização (data da ultima atualização inferior a data do objeto), atualização de SISTEMA, ou de PLSQL de MANUTENÇÃO do sistema 
cursor c_bi_auto_update is 
    select tp_objeto, nm_objeto, tp_conteudo, sq_atualizacao 
      from bi_auto_update
     where dt_versao_baixa = dt_versao_upquery 
       and ( dt_versao_sistema < dt_versao_baixa or dt_versao_sistema is null) 
       and id_situacao not in ('BLOQUEADO','INVALIDO')  -- Se não estiver bloqueado ou Invalido      
       and tp_objeto not in ('ESTADOS', 'CIDADES')
       --
       and ( prm_tipo = 'TODOS' or tp_objeto = prm_tipo or (prm_tipo = 'PACKAGE' and tp_objeto like 'PACKAGE%') )   
       and ( prm_nome = 'TODOS' or nm_objeto = prm_nome)     
       -- 
       and not ( substr(tp_objeto,1,7) = 'PACKAGE' and nm_objeto = 'UPD')          -- A package não pode atualizar ela mesma, a atualização deve ser feita pela procedure da SCH 
       and ( (prm_tp_atualiza in ('ATUALIZA','ATUALIZA_BI','ATUALIZA_ETL') ) or    -- Se for ATUALIZA pode rodar a manutenção também     
             (prm_tp_atualiza = 'MANUTENCAO' and tp_objeto = 'MANUTENCAO')  
           )  
       and ( ( prm_tp_atualiza in ('ATUALIZA','MANUTENCAO')  ) or  
             ( prm_tp_atualiza = 'ATUALIZA_BI'  and nm_objeto not in ('ETF','SCH') ) or 
             ( prm_tp_atualiza = 'ATUALIZA_ETL' and nm_objeto in ('ETF','SCH') ) 
           )  
        -- 
     order by sq_atualizacao;

ws_id_atu           number(10);
ws_msg              varchar2(2000);
ws_qt_obj           number;
ws_qt_manut         number; 
ws_dt_versao        date; 
ws_id_permissao     varchar2(10);
ws_count            integer; 
ws_erro_permissao   exception ;

begin 

    ws_qt_obj   := 0;
    ws_qt_manut := 0;

    ws_id_permissao := nvl(upd.autoUpdate_permissao(prm_usuario),'0'); 
    if (ws_id_permissao = '9'                                 ) or    -- Permissao total 
       (prm_chamada  = 'NAVEGADOR' and ws_id_permissao = '1'  ) or    -- Permissao de atualização manual (via BI)
       (prm_chamada  = 'BANCO'     and ws_id_permissao = '2'  ) then  -- Permissao de atualização automatica (via job)
       null; -- Não faz nada porque tem permissão 
    elsif ws_id_permissao = '-1' then 
        ws_msg := 'Erro verificando permiss&atilde;o de atualiza&ccedil;&atilde;o, entre contato com o administrador do sistema'; 
        raise ws_erro_permissao;         
    else     
        ws_msg := 'Sem permissao de update de sistema';  
        raise ws_erro_permissao; 
    end if; 


    select nvl(max(id_auto_update),0)+1 into ws_id_atu from bi_auto_update_log;    
    
    if prm_tipo = 'TODOS' and prm_tp_atualiza <> 'MANUTENCAO'  then 
        AutoUpdate_log (ws_id_atu, 'ATUALIZA', 'TODOS', 'TODOS', 'INICIO', null, prm_usuario);  
    end if;     

    for a in c_bi_auto_update loop 
        ws_qt_obj   := ws_qt_obj + 1; 
        ws_msg := null;
        AutoUpdate_log (ws_id_atu, 'ATUALIZA', a.tp_objeto, a.nm_objeto, 'INICIO', null, prm_usuario); 

        if a.tp_objeto in ('PACKAGE_SPEC','PACKAGE_BODY')  then 
            upd.autoUpdate_atu_PACKAGE (ws_id_atu, a.tp_objeto, a.nm_objeto, ws_msg); 
        elsif a.tp_objeto like 'VISUAL%'     or 
              a.tp_objeto like 'PROGRAMA%'   or 
              a.tp_objeto like 'IMAGEM%'     or 
              a.tp_objeto like 'MARCADORES%'  then 
            upd.autoUpdate_atu_ARQUIVO (ws_id_atu, a.tp_objeto, a.nm_objeto, ws_msg); 
        elsif a.tp_objeto in ('PADROES','CONSTANTES','PLSQL','MANUTENCAO')  then 
            upd.autoUpdate_atu_PLSQL (ws_id_atu, a.tp_objeto, a.nm_objeto, ws_msg); 
        else 
            ws_msg := 'Tipo de objeto nao tratado';
        end if; 

        if a.tp_objeto = 'MANUTENCAO' then 
            ws_qt_manut := ws_qt_manut + 1; 
        end if; 

        if ws_msg is not null then 
            AutoUpdate_log (ws_id_atu, 'ATUALIZA', a.tp_objeto, a.nm_objeto, 'ERRO', ws_msg, prm_usuario); 
            insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values (sysdate, 'AutoUpdate_atu_sistema ['||a.tp_objeto||'-'||a.nm_objeto||']:'||ws_msg, prm_usuario, 'ERRO');     
        else
            update bi_auto_update
               set dt_versao_sistema = dt_versao_baixa
             where tp_objeto = a.tp_objeto 
               and nm_objeto = a.nm_objeto ;  
            AutoUpdate_log (ws_id_atu, 'ATUALIZA', a.tp_objeto, a.nm_objeto, 'FIM', 'Ok', prm_usuario);         
        end if;    
    end loop; 
    
    if prm_tipo = 'TODOS' and prm_tp_atualiza <> 'MANUTENCAO' then 
        AutoUpdate_log (ws_id_atu, 'ATUALIZA', 'TODOS', 'TODOS', 'FIM', 'objetos:'||ws_qt_obj, prm_usuario);         
    end if; 

    commit;    

    if prm_tipo = 'TODOS' then 
        UPD.recompila_inativos(prm_usuario);   -- Tenta recompilar objetos inativos (se houver)          
    end if;     

    if prm_chamada = 'NAVEGADOR' then 
        if ws_msg is not null then 
            insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values (sysdate, 'Erro AutoUpdate_atu_sistema: '||ws_msg , prm_usuario, 'ERRO'); 
            commit; 
            htp.p('ERRO||Erro na atualiza&ccedil;&atilde;o|'||ws_msg);
        else
            ws_msg := ws_qt_obj||' objeto(s) atualizado(s) com sucesso.'; 
            select max(dt_versao_baixa) into ws_dt_versao from bi_auto_update 
              where ( (tp_objeto = prm_tipo) or ( prm_tipo = 'PACKAGE' and tp_objeto like 'PACKAGE%' ) )
                and ( nm_objeto = prm_nome or prm_nome = 'TODOS') ; 
            htp.p('OK|'||to_char(ws_dt_versao,'DD/MM/YYYY HH24:MI')||'|Atualizado|'||ws_msg );
        end if;
    end if; 

    --if ws_qt_manut > 0 then -- Se teve manutenção de sistema já faz o envio dos logs 
    --    upd.AutoUpdate_envia_log (prm_usuario); 
    --end if; 
    if prm_chamada <> 'NAVEGADOR' and prm_tipo = 'TODOS' then  
        select count(*) into ws_count from bi_auto_update_log where nvl(id_enviado,'N') = 'N';
        if ws_count > 0 then 
            upd.execute_now('UPD.AutoUpdate_envia_log (''DWU'')', 'N');
        end if; 
    end if;       

exception 
    when ws_erro_permissao then 
        if prm_tp_atualiza <> 'MANUTENCAO' then 
            AutoUpdate_log (ws_id_atu, 'ATUALIZA', prm_tipo, prm_nome, 'ERRO', ws_msg, prm_usuario);   
            --if prm_tipo = 'TODOS' then 
            --    UPD.recompila_inativos(prm_usuario);   -- Tenta recompilar objetos inativos (se houver)          
            --END IF;     
        end if;    
        if prm_chamada = 'NAVEGADOR' then 
            htp.p('ERRO||Sem permiss&atilde;o|'||ws_msg);        
        end if;    
    when others then 
        ws_msg := DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE; 
        if prm_tp_atualiza <> 'MANUTENCAO' then 
            AutoUpdate_log (ws_id_atu, 'ATUALIZA', 'TODOS', 'TODOS', 'ERRO', ws_msg, prm_usuario);             
        end if;     
        insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values (sysdate, 'Erro AutoUpdate_atu_sistema(OTHERS): '||ws_msg , prm_usuario, 'ERRO'); 
        commit; 
        if prm_chamada = 'NAVEGADOR' then 
            htp.p('ERRO||Erro na atualiza&ccedil;&atilde;o|'||ws_msg);        
        end if;    
end AutoUpdate_atu_sistema; 



---------------------------------------------------------------------------------------------------------------------------------------------------------
-------- Atualiza package 
---------------------------------------------------------------------------------------------------------------------------------------------------------
procedure autoUpdate_atu_PACKAGE (prm_id_atu         number, 
                                  prm_tipo           varchar2, 
                                  prm_nome           varchar2, 
                                  prm_msg     in out varchar2 ) as 
    ws_comando       clob;    
    ws_sid           varchar2(20);
    ws_sid_lock      varchar2(20);    
    ws_msg_erro      varchar2(2000);
    ws_try           integer; 
    ws_check         integer; 
    ws_tp_sessao     varchar2(10); 
    ws_raise_erro    exception ;
    ws_raise_timeout exception ;
begin

    ws_sid := sys_Context('USERENV', 'SID');   

    prm_msg    := null;  
    ws_comando := null;
    select conteudo_clob into ws_comando from bi_auto_update
     where tp_objeto = prm_tipo 
       and nm_objeto = prm_nome; 
    --
    if ws_comando is null then 
       ws_msg_erro := 'Conteudo nulo';
       raise ws_raise_erro; 
    end if;     

    if prm_nome in ('ETF','SCH') then 
        ws_tp_sessao := 'HTTP';   -- Mata somente sessões abertas pelo BI (HTTP)
    else 
        ws_tp_sessao := 'TODOS';  -- Mata todas as sessões utilizando a package 
    end if;     

    if nvl(upper(upd.ret_var('USAR_DBA_DDL_LOCKS')),'S') = 'S' then
        
        -- aguarda processos em execução, faz 240 tentativas aguardando 5 segundos cada tentativa (20 aguarda por minutos)
        ws_try   := 240;
        ws_check := 1;
        loop
            exit when ws_check=0;

            -- Mata sessões utilizando a package 
            upd.AutoUpdate_mata_sessao(prm_tipo, prm_nome, 'DWU', ws_tp_sessao, ws_msg_erro);

            -- Verifica se ainda ficou alguma sessão utilizando o objeto 
            select count(*), max(l.session_id) into ws_check, ws_sid_lock 
            from dba_ddl_locks l
            where l.session_id <> ws_sid 
            and l.type       <> 'Table/Procedure/Type'
            and l.owner       = NVL(upd.ret_var('OWNER_BI'),'DWU') 
            and l.name        = prm_nome ;

            update bi_auto_update_log 
            set qt_tentativa   = nvl(qt_tentativa,0) + 1, 
                ds_atualizacao = 'ws_try='||ws_try||' ,ws_check='||ws_check||', sid='||ws_sid_lock
            where id_auto_update = prm_id_atu 
            and tp_atualizacao = 'ATUALIZA'
            and tp_objeto      = prm_tipo
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
        execute immediate ws_comando;
    exception when others then    
        ws_msg_erro := 'Erro: '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE; 
        raise ws_raise_erro; 
    end; 

 exception 
    when ws_raise_erro then 
        prm_msg := ws_msg_erro;
    when ws_raise_timeout then 
        prm_msg := 'Timeout tentando atualizar package';
    when others then
        prm_msg := 'Erro: '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE; 
end autoUpdate_atu_PACKAGE;


---------------------------------------------------------------------------------------------------------------------------------------------------------
-------- Atualiza package 
---------------------------------------------------------------------------------------------------------------------------------------------------------
procedure autoUpdate_atu_ARQUIVO (prm_id_atu         number, 
                                  prm_tipo           varchar2, 
                                  prm_nome           varchar2, 
                                  prm_msg     in out varchar2 ) as 
    ws_sid           varchar2(10);
    ws_msg_erro      varchar2(2000);
    ws_try           integer; 
    ws_check         integer; 
    ws_blob          blob;    
    ws_mime          varchar2(200); 

    ws_raise_erro    exception ;
    ws_raise_timeout exception ;
begin


    prm_msg := null;  
    ws_blob := null; 
    select conteudo_blob, mime_type_arquivo into ws_blob, ws_mime  
      from bi_auto_update
     where tp_objeto = prm_tipo 
       and nm_objeto = prm_nome; 
    --
    if length(ws_blob) <= 0 then 
       ws_msg_erro := 'Conteudo nulo';
       raise ws_raise_erro; 
    end if;     

    begin 
        delete tab_documentos 
         where name    = prm_nome 
           and usuario = 'SYS';    -- Exclui o arquivo existente no usuário SYS, se existir 
        --   
        update tab_documentos 
           set BLOB_CONTENT  = ws_blob,
               LAST_UPDATED  = sysdate  
         where name    = prm_nome 
           and usuario = 'DWU';
        if sql%notfound then 
            insert into tab_documentos (name, mime_type, doc_size, dad_charset, last_updated, content_type, blob_content, usuario) 
                                values (prm_nome, ws_mime, null, 'ascii', sysdate, 'BLOB', ws_blob, 'DWU' ); 
        end if;    
        commit;
    exception when others then    
        ws_msg_erro := 'Erro: '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE; 
        raise ws_raise_erro; 
    end; 

 exception 
    when ws_raise_erro then 
        prm_msg := ws_msg_erro;
    when others then
        prm_msg := 'Erro: '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE; 
end autoUpdate_atu_ARQUIVO;






---------------------------------------------------------------------------------------------------------------------------------------------------------
-------- Atualiza objetos com SQL de atualização (SQLs separados por ;) 
---------------------------------------------------------------------------------------------------------------------------------------------------------
procedure autoUpdate_atu_PLSQL (prm_id_atu         number, 
                                prm_tipo           varchar2, 
                                prm_nome           varchar2, 
                                prm_msg     in out varchar2 ) as 
    ws_clob          clob;    
    ws_msg_erro      varchar2(500);
    ws_try           integer; 
    ws_check         integer; 
    ws_raise_erro    exception ;
    ws_raise_timeout exception ;
begin

    prm_msg := null;  
    ws_clob := null; 
    select conteudo_clob into ws_clob 
      from bi_auto_update
     where tp_objeto = prm_tipo 
       and nm_objeto = prm_nome; 
    --
    if ws_clob is null then 
       ws_msg_erro := 'Erro: Conteudo nulo';
       raise ws_raise_erro; 
    end if;     

    begin 
        execute immediate ws_clob; 
        commit;
    exception when others then    
        rollback; 
        ws_msg_erro := substr('Erro: '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,499); 
        raise ws_raise_erro; 
    end; 

 exception 
    when ws_raise_erro then 
        prm_msg := ws_msg_erro;
    when others then
        prm_msg := 'Erro: '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE; 
end autoUpdate_atu_PLSQL;





---------------------------------------------------------------------------------------------------------------------------------------------------------
-------- Atualiza Estados  e Cidades 
---------------------------------------------------------------------------------------------------------------------------------------------------------
procedure autoUpdate_CIDADES_ESTADOS  (prm_sistema        varchar2 default 'BI',
                                       prm_versao         varchar2 default null, 
                                       prm_usuario        varchar2,
                                       prm_tipo           varchar2,
                                       prm_chamada        varchar2 default 'BANCO' ) as 
    ws_res           UTL_HTTP.HTML_PIECES;
    ws_resN          varchar2(4000);
    ws_req           varchar2(800);
    ws_url           varchar2(100);    
    ws_nome          varchar2(20);

    ws_output        clob;
    ws_linha         varchar2(400);
    ws_count         number := 0;
    ws_limit         number;
    ws_qt_insert     number; 
    ws_qt_obj        number; 
    ws_qt_res        number; 
    ws_msg           varchar2(500);
    ws_msg_log       varchar2(500);
    ws_tam_aux       number; 
    ws_id_atu        number;
    ws_erro_atualizando exception ;
begin

    ws_url := UPD.RET_VAR('URL_AUTOUPDATE');

    ws_nome      := 'TODOS'; 
    ws_msg       := null; 
    ws_msg_log   := null; 
    delete bi_auto_update_temp; 

    select nvl(max(id_auto_update),0)+1 into ws_id_atu from bi_auto_update_log; 

    AutoUpdate_log (ws_id_atu, 'ATUALIZA', prm_tipo, ws_nome, 'INICIO', null, prm_usuario);  
    
    -- Busca a lista de CIDADES ou ESTADOS e insere(merge) nas tabelas (sem o JSON) 
    -----------------------------------------------------------------------------------
    ws_req       := 'http://'||ws_url||'/dwu.beup.get_update_sistema?prm_chave=&prm_sistema='||prm_sistema||'&prm_tipo='||prm_tipo||'&prm_nm_conteudo='||ws_nome;
    ws_res       := UTL_HTTP.REQUEST_PIECES(ws_req, 32767);
    ws_output    := ' ';         
    for a in 1..ws_res.count LOOP
       ws_output := ws_output||ws_res(a);
    end loop;

    if trim(ws_output) LIKE 'ERRO|%' then 
       ws_msg_log := replace(ws_output,'ERRO|','');
       raise ws_erro_atualizando;
    end if; 

    ws_qt_insert := 0; 
    AutoUpdate_log (ws_id_atu, 'ATUALIZA', prm_tipo, ws_nome, 'REGISTRO', 'Registros Inseridos '||ws_qt_insert, prm_usuario);                  
    while instr(ws_output, ';') <> 0 loop
        ws_linha   := substr(ws_output, 0, instr(ws_output, ';'));
        begin
            execute immediate replace(ws_linha, ';', '');
            if upper(ws_linha) not like '%BI_AUTO_UPDATE_TEMP%' then 
                ws_qt_insert := ws_qt_insert + 1;
                AutoUpdate_log (ws_id_atu, 'ATUALIZA', prm_tipo, ws_nome, 'REGISTRO', 'Registros Inseridos '||ws_qt_insert, prm_usuario);                  
            end if;                       
            commit;                
        exception when others then 
            ws_msg_log := DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
            raise ws_erro_atualizando; 
        end;        
        ws_count := ws_count+1;
        exit when ( ws_count > ws_limit ); 
        ws_output := replace(ws_output, ws_linha, '');
    end loop;


    -- Busca e atualiza o JSON com as coordenadas dos estados ou cidades 
    -----------------------------------------------------------------------------------
    ws_qt_obj := 0;
    ws_qt_res := 0;
    AutoUpdate_log (ws_id_atu, 'ATUALIZA', prm_tipo, ws_nome, 'JSON', 'JSON atualizados '||ws_qt_obj, prm_usuario);  

    for a in (select tp_objeto, nm_objeto, sq_objeto, conteudo_tamanho from bi_auto_update_temp order by 1,2,3) loop 

        ws_qt_res := ws_qt_res + 1;
        if a.tp_objeto = 'ESTADOS' then 
            select max(length(json)) into ws_tam_aux from bi_estados 
             where cd_estado = a.nm_objeto 
               and sq_json   = a.sq_objeto; 
        elsif a.tp_objeto = 'ESTADOS_BRASIL' then 
            select max(length(json)) into ws_tam_aux from bi_estados_brasil 
             where cd_estado = a.nm_objeto 
               and sequencia = a.sq_objeto; 
        elsif a.tp_objeto = 'CIDADES' then 
            select max(length(json)) into ws_tam_aux from bi_cidades
             where cd_cidade = a.nm_objeto 
               and sq_json   = a.sq_objeto;        
        elsif a.tp_objeto = 'CIDADES_BRASIL' then 
            select max(length(json)) into ws_tam_aux from bi_cidades_brasil 
             where cd_cidade = a.nm_objeto 
               and sequencia = a.sq_objeto;        
        elsif a.tp_objeto = 'REGIOES' then 
            select max(length(json)) into ws_tam_aux from bi_regioes
             where cd_regiao = a.nm_objeto 
               and sq_json   = a.sq_objeto;        
        end if;        
        
        -- Busca Json para atualização - Somente se o tamanho do JSON não mudou 
        if  nvl(ws_tam_aux,0) <> a.conteudo_tamanho then 
            ws_req       := 'http://'||ws_url||'/dwu.beup.get_update_sistema?prm_chave=&prm_sistema='||prm_sistema||'&prm_tipo='||a.tp_objeto||'&prm_nm_conteudo='||a.nm_objeto||'|'||a.sq_objeto;
            ws_res       := UTL_HTTP.REQUEST_PIECES(ws_req, 32767);
            ws_output    := null;        
            for a in 1..ws_res.count LOOP
                ws_output := ws_output||ws_res(a);
            end loop;
            if trim(ws_output) LIKE 'ERRO|%' then 
                ws_msg_log := replace(ws_output,'ERRO|','');
                raise ws_erro_atualizando;
            end if; 

            if NVL(ws_output,'N/A') <> 'N/A' then 
                begin
                    if prm_tipo = 'ESTADOS' then 
                        update bi_estados set json = ws_output
                         where cd_estado = a.nm_objeto
                           and sq_json   = a.sq_objeto ;
                    elsif prm_tipo = 'ESTADOS_BRASIL' then 
                        update bi_estados_brasil set json = ws_output
                         where cd_estado = a.nm_objeto
                           and sequencia = a.sq_objeto ;
                    elsif prm_tipo = 'CIDADES' then   
                        update bi_cidades set json = ws_output
                        where cd_cidade = a.nm_objeto
                          and sq_json   = a.sq_objeto ;
                    elsif prm_tipo = 'CIDADES_BRASIL' then   
                        update bi_cidades_brasil set json = ws_output
                        where cd_cidade = a.nm_objeto
                        and sequencia = a.sq_objeto ;
                    elsif prm_tipo = 'REGIOES' then   
                        update bi_regioes set json = ws_output
                        where cd_regiao = a.nm_objeto
                          and sq_json   = a.sq_objeto ;
                    end if;       

                    ws_qt_obj := ws_qt_obj + 1;
                    AutoUpdate_log (ws_id_atu, 'ATUALIZA', prm_tipo, ws_nome, 'JSON', 'JSON atualizados '||ws_qt_obj, prm_usuario);  

                    commit; 
                exception when others then 
                    ws_msg_log := DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
                    raise ws_erro_atualizando; 
                end;        
            end if;    
            
            commit;                
        end if;     
        --
    end loop;   

    if ws_qt_obj = 0 then 
        ws_msg_log := 'Nenhum JSON a atualizar'; 
    else 
        ws_msg_log := 'JSON atualizados: '||ws_qt_obj; 
    end if;     

    update bi_auto_update
       set dt_versao_sistema = dt_versao_upquery, 
           dt_versao_baixa   = dt_versao_upquery
     where tp_objeto = prm_tipo
       and nm_objeto = ws_nome;  
    commit; 

    AutoUpdate_log (ws_id_atu, 'ATUALIZA', prm_tipo, ws_nome, 'FIM', ws_msg_log, prm_usuario);  

    if prm_chamada = 'NAVEGADOR' then 
        if ws_qt_obj = 0 then 
            ws_msg := 'Nenhum registro pendente de atualiza&ccedil;&atilde;o';
        else 
            ws_msg := ws_qt_obj||' registros atualizados';
        end if; 
        htp.p('OK|'||to_char(sysdate,'DD/MM/YYYY HH24:MI')||'|Atualizado|'||ws_msg );
    end if ;


 exception 
    when ws_erro_atualizando then 
        rollback; 
        AutoUpdate_log (ws_id_atu, 'ATUALIZA', prm_tipo, ws_nome, 'ERRO', ws_msg_log,  prm_usuario);  
        insert into bi_log_sistema (dt_log, ds_log,nm_usuario, nm_procedure) values(sysdate, 'autoUpdate_CIDADES_ESTADOS:'||ws_msg_log, prm_usuario, 'EVENTO');         
        commit; 
        
        if prm_chamada = 'NAVEGADOR' then 
            ws_msg := 'Erro atualizando <'||UPPER(prm_tipo)||'>, entre em contato com o administrador do sistema'; 
            htp.p('ERRO||Erro na atualiza&ccedil;&atilde;o|'||ws_msg );
        end if;

    when others then
        rollback;
        ws_msg_log := 'ERRO:'||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE; 
        AutoUpdate_log (ws_id_atu, 'ATUALIZA', prm_tipo, ws_nome, 'ERRO', ws_msg_log,  prm_usuario);          
        insert into bi_log_sistema (dt_log, ds_log,nm_usuario, nm_procedure) values(sysdate, 'autoUpdate_CIDADES_ESTADOS(outros):'||ws_msg_log, prm_usuario, 'EVENTO');         
        commit; 

        if prm_chamada = 'NAVEGADOR' then 
            ws_msg := 'Erro atualizando <'||UPPER(prm_tipo)||'>, JSON atualizados '||ws_qt_obj||', entre em contato com o administrador do sistema';
            htp.p('ERRO||Erro na atualiza&ccedil;&atilde;o|'||ws_msg );
        end if;

end autoUpdate_CIDADES_ESTADOS;



---------------------------------------------------------------------
-- Job que faz a baixa dos conteudo e atualização somente da package UPD 
---------------------------------------------------------------------
procedure AutoUpdate_job_baixa    (prm_sistema  varchar,
                                   prm_versao   varchar2,
                                   prm_usuario  varchar2 ) as
begin 
    UPD.AutoUpdate_atu_parametros (prm_sistema, prm_usuario);                                  -- Busca parametrização na Upquery e atualiza no cliente 
    upd.AutoUpdate_check_atualizacoes (prm_sistema, prm_versao, prm_usuario );                 -- Verifica se tem novas atualizações  
    upd.AutoUpdate_baixa_conteudo (prm_sistema, prm_versao, prm_usuario,'TODOS','TODOS');      -- Baixa conteúdos dos objetos desatualizados  
    if upd.autoUpdate_existe_pendencia ('ATUALIZA_UPD') = 'S' then 
        upd.execute_now('SCH.AutoUpdate_atu_PACKAGE  (''DWU'', ''PACKAGE'',''UPD'', ''BANCO'')', 'N');        -- Atualiza a package UPD (tem que ser via Job utilizando a SCH por que a packag UPD não pode atualizar ela mesma)     
    end if;     
exception 
    when others then 
        insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values (sysdate, 'Erro AutoUpdate_job_baixa(OTHERS): '|| DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, prm_usuario, 'ERRO'); 
        commit; 
end AutoUpdate_job_baixa;


---------------------------------------------------------------------
-- Job que faz a atualização dos objetos já baixado (tenta baixar novamente pra garantir) o sistema  - Executado na troca do dia 
---------------------------------------------------------------------
procedure AutoUpdate_job_atualiza (prm_sistema      varchar,
                                   prm_versao       varchar2,
                                   prm_usuario      varchar2,
                                   prm_tp_atualiza  varchar2 default 'ATUALIZA' ) as
begin 
    upd.AutoUpdate_check_atualizacoes (prm_sistema, prm_versao, prm_usuario );                      -- Verifica se tem novas atualizações  
    upd.AutoUpdate_baixa_conteudo (prm_sistema, prm_versao, prm_usuario,'TODOS','TODOS');           -- Baixa conteúdo dos objetos desatualizados  
    upd.AutoUpdate_atu_sistema(prm_usuario, 'TODOS','TODOS',prm_tp_atualiza,'BANCO' );                   -- Atualiza os objetos do sistema (se existe pendencia)
    if upd.autoUpdate_existe_pendencia ('MANUTENCAO') = 'S' then        
        upd.AutoUpdate_atu_sistema(prm_usuario, 'TODOS','TODOS','MANUTENCAO','BANCO' ); 
    end if;     
exception 
    when others then 
        insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values (sysdate, 'Erro AutoUpdate_job_atualiza(OTHERS): '|| DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, prm_usuario, 'ERRO'); 
        commit; 
end AutoUpdate_job_atualiza;


---------------------------------------------------------------------
-- Job que faz a execucao dos objetos de manutenção do sistema - criado periodicamente pelo SCH.MAIN  
---------------------------------------------------------------------
procedure AutoUpdate_job_manutencao (prm_sistema  varchar,
                                     prm_versao   varchar2,
                                     prm_usuario  varchar2 ) as
begin 
    upd.AutoUpdate_check_atualizacoes (prm_sistema, prm_versao, prm_usuario, 'MANUTENCAO' );                        -- Verifica se tem manutenções pendentes 
    upd.AutoUpdate_baixa_conteudo     (prm_sistema, prm_versao, prm_usuario,'TODOS','TODOS','BANCO','MANUTENCAO');  -- Baixa conteúdo/PLSQL de manutenção 
    upd.AutoUpdate_atu_sistema        (prm_usuario, 'TODOS','TODOS','MANUTENCAO','BANCO' );                         -- Executa manutenções pendentes/baixadas 
exception 
    when others then 
        insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values (sysdate, 'Erro AutoUpdate_job_manutencao(OTHERS): '|| DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, prm_usuario, 'ERRO'); 
        commit; 
end AutoUpdate_job_manutencao;

-------------------------------------------------------------------------------------------------------------------------
procedure AutoUpdate_atualiza_bi is 
    ws_count_pend  integer := 0;
    ws_qt_locks    integer; 
    ws_dh_atu      date;
begin 
    begin 
        ws_dh_atu := to_date(to_char(sysdate,'ddmmyyyy')||trim(upd.ret_var('HR_AUTOUPDATE_ATU')),'ddmmyyyyhh24:mi'); 
    exception when others then 
        ws_dh_atu := to_date(to_char(sysdate,'ddmmyyyy')||'20:00','ddmmyyyyhh24:mi'); 
    end;      

    -- Após o horário de atualização verificar por 120 minutos (2 horas) a pendência de atualização 
    if sysdate between ws_dh_atu and (ws_dh_atu + (1/1440*120)) then 
        select count(*) into ws_count_pend 
        from bi_auto_update
        where dt_versao_baixa = dt_versao_upquery 
        and ( dt_versao_sistema < dt_versao_baixa or dt_versao_sistema is null) 
        and id_situacao not in ('BLOQUEADO','INVALIDO')  
        and tp_objeto not in ('ESTADOS', 'CIDADES')
        and not ( substr(tp_objeto,1,7) = 'PACKAGE' and nm_objeto in ('UPD','ETF','SCH')) ;
        
        if ws_count_pend > 0 then -- tem atualização pendente
            begin
                upd.execute_now('upd.autoupdate_atu_sistema (''BI'', ''TODOS'',''TODOS'',''ATUALIZA_BI'',''BANCO'')', 'N');
                commit; 
            exception when others then
                insert into log_eventos values(sysdate , '[QH]-Erro no upd.autoupdate_atualiza_bi(ATUALIZA_BI)' , USER , 'CALCULO' , 'OK', '0');
                insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values (sysdate, 'Erro upd.autoupdate_atualiza_bi(OTHERS): '|| DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 'DWU', 'ERRO'); 
                commit;
            end; 
        end if;     
    end if; 
end AutoUpdate_atualiza_bi; 

procedure autoupdate_atualiza_pkg (prm_package varchar2)  is 
    ws_tp_atualiza varchar2(30); 
    ws_count_pend  integer := 0;
    ws_qt_locks    integer; 
    ws_dh_atu      date;
begin 
    begin 
        ws_dh_atu := to_date(to_char(sysdate,'ddmmyyyy')||trim(upd.ret_var('HR_AUTOUPDATE_ATU')),'ddmmyyyyhh24:mi'); 
    exception when others then 
        ws_dh_atu := to_date(to_char(sysdate,'ddmmyyyy')||'20:00','ddmmyyyyhh24:mi'); 
    end;      

    ws_tp_atualiza := 'ATUALIZA_ETL';

    -- Após o horário de atualização verificar por 180 minutos (3 horas) a pendência de atualização 
    if sysdate between ws_dh_atu and (ws_dh_atu + (1/1440*180)) then 

        select count(*) into ws_count_pend
        from bi_auto_update
        where dt_versao_baixa = dt_versao_upquery 
        and ( dt_versao_sistema < dt_versao_baixa or dt_versao_sistema is null) 
        and id_situacao not in ('BLOQUEADO','INVALIDO')  
        and tp_objeto not in ('ESTADOS', 'CIDADES')
        and (substr(tp_objeto,1,7) = 'PACKAGE' and nm_objeto = prm_package) ;
        
        if ws_count_pend > 0 then -- tem atualização pendente
            ws_qt_locks := 0;
            if nvl(upper(upd.ret_var('USAR_DBA_DDL_LOCKS')),'N') = 'S' then
                select count(*) into ws_qt_locks   -- Verifica se tem algum processo de banco utilizando a package 
                from dba_ddl_locks l
                where l.type       <> 'Table/Procedure/Type'
                and l.owner       = NVL(upd.ret_var('OWNER_BI'),'DWU') 
                and l.name        = prm_package ;
            end if; 

            if ws_qt_locks = 0 then  -- Cria Job de atualização do sistema 
                begin
                    upd.execute_now('upd.AutoUpdate_atu_sistema (''BI'', ''PACKAGE'','''||prm_package||''',''ATUALIZA_ETL'',''BANCO'')', 'N');
                exception when others then
                    insert into log_eventos values(sysdate , '[QH]-Erro no upd.autoupdate_atualiza_pkg(ATUALIZA_ETL)' , USER , 'CALCULO' , 'OK', '0');
                    insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values (sysdate, 'Erro upd.autoupdate_atualiza_pkg(OTHERS-'||prm_package||'): '|| DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 'DWU', 'ERRO'); 
                    commit;
                end; 
            end if;
        end if;
    end if; 
end autoupdate_atualiza_pkg; 

-------------------------------------------------------------------------------------------------------------------------
/*
procedure autoupdate_atualiza_pkg (prm_package varchar2)  is 
    ws_tp_atualiza varchar2(30); 
    ws_count_pend  integer := 0;
    ws_qt_locks    integer; 
    ws_dh_atu      date;
    ws_atualizou   varchar2(1); 
    ws_comando     varchar2(4000);
begin 
    begin 
        ws_dh_atu := to_date(to_char(sysdate,'ddmmyyyy')||trim(upd.ret_var('HR_AUTOUPDATE_ATU')),'ddmmyyyyhh24:mi'); 
    exception when others then 
        ws_dh_atu := to_date(to_char(sysdate,'ddmmyyyy')||'20:00','ddmmyyyyhh24:mi'); 
    end;      

    ws_tp_atualiza := 'ATUALIZA_ETL';

    -- Se estiver período de atualização (inicio + 180 minutos (3 horas)), fica tentando a cada 5 minutos gerar a atualização
    ws_atualizou := 'N';
    loop
        if sysdate < ws_dh_atu or sysdate > (ws_dh_atu + (1/1440*180)) then -- Encerra as tentativas, se não estiver no período deatualização 
            exit; 
        end if; 

        select count(*) into ws_count_pend
        from bi_auto_update
        where dt_versao_baixa = dt_versao_upquery 
        and ( dt_versao_sistema < dt_versao_baixa or dt_versao_sistema is null) 
        and id_situacao not in ('BLOQUEADO','INVALIDO')  
        and tp_objeto not in ('ESTADOS', 'CIDADES')
        and (substr(tp_objeto,1,7) = 'PACKAGE' and nm_objeto = prm_package) ;

        if ws_count_pend > 0 then -- tem atualização pendente
            ws_qt_locks := 0;
            if nvl(upper(upd.ret_var('USAR_DBA_DDL_LOCKS')),'N') = 'S' then
                select count(*) into ws_qt_locks   -- Verifica se tem algum processo de banco utilizando a package 
                from v$session s, dba_ddl_locks l
                where s.sid       = l.session_id 
                and l.type       <> 'Table/Procedure/Type'
                and l.owner       = NVL(upd.ret_var('OWNER_BI'),'DWU') 
                and l.name        = prm_package
                and s.event not in ('PGA memory operation','library cache: bucket mutex X') ;
            end if; 

            if ws_qt_locks = 0 then  -- Cria Job de atualização do sistema, se ainda não exisitir  
                ws_atualizou := 'S';
                begin
                    upd.execute_now('upd.AutoUpdate_atu_sistema (''BI'', ''PACKAGE'','''||prm_package||''',''ATUALIZA_ETL'',''BANCO'')', 'N');
                    commit; 
                exception when others then
                    insert into log_eventos values(sysdate , '[QH]-Erro no upd.autoupdate_atualiza_pkg(ATUALIZA_ETL)' , USER , 'CALCULO' , 'OK', '0');
                    insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values (sysdate, 'Erro upd.autoupdate_atualiza_pkg(OTHERS-'||prm_package||'): '|| DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 'DWU', 'ERRO'); 
                    commit;
                end; 
            end if;
        else 
            ws_atualizou := 'S';    
        end if;
        if ws_atualizou = 'S' then 
            exit;
        else     
            dbms_lock.sleep(5*60);  -- Aguarda 5 minutos 
        end if;     
    end loop; 

end autoupdate_atualiza_pkg; 
*/ 

---------------------------------------------------------------------
-- Job que atualiza os objetos do sistema com o conteúdo já captura na UPQUERY - Deve ser executado no horário parametrizado no sistema (var_conteudo)
---------------------------------------------------------------------
procedure AutoUpdate_envia_log (prm_usuario  varchar2) as

-- Lista todos os objetos se houver alguma pendencia de envio de log
cursor c_bi_auto_update is 

    -- Log de atualização do sistema 
    select * from ( select sq_atualizacao, tp_objeto, nm_objeto, dt_versao_baixa, dt_versao_upquery, dt_versao_sistema 
                      from bi_auto_update  
                     where id_situacao <> 'BLOQUEADO'  
                       and tp_objeto   <> 'MANUTENCAO'
                       and dt_versao_upquery >= (sysdate -30) -- somente objetos que tiveram alterações nos últimos 30 dias
                    union all 
                     select 9999999999, 'TODOS', 'TODOS',null,null,null from dual 
                  ) t1  
     where exists ( select 1 from bi_auto_update_log t2
                     where t2.id_enviado  = 'T'
                       and t2.tp_objeto  <> 'MANUTENCAO'  
                  ) 
    -- Log de manutecao do sistema (se houver)
    union all 
    --
    select distinct 0 sq_atualizacao, lg.tp_objeto, lg.nm_objeto, dt_versao_baixa, dt_versao_upquery, dt_versao_sistema 
      from bi_auto_update au, bi_auto_update_log lg      
       where au.tp_objeto(+)  = lg.tp_objeto  
         and au.nm_objeto(+)  = lg.nm_objeto
         and lg.id_enviado   = 'T'
         and lg.tp_objeto    = 'MANUTENCAO'      
    --
     order by 1;  

cursor c_log  (p_tp varchar2, p_nm varchar2, p_tp_atualizacao varchar2) is 
    select id_auto_update, id_situacao, ds_atualizacao, dt_inicio, dt_fim, qt_tentativa 
      from bi_auto_update_log
     where tp_objeto      = p_tp 
       and nm_objeto      = p_nm 
       and ( (p_tp_atualizacao = 'ATUALIZA_BAIXA' and tp_atualizacao in ('ATUALIZA', 'BAIXA'))  or tp_atualizacao = p_tp_atualizacao )  
  order by id_auto_update desc; 

ws_atualiza     c_log%rowtype;
ws_baixa        c_log%rowtype;
ws_check        c_log%rowtype;
ws_envia        c_log%rowtype;
ws_cliente      varchar2(20); 
ws_param        varchar2(32000);
ws_command      varchar2(32000);
ws_string       varchar2(100); 
ws_qt_obj           number; 
ws_qt_erro          number; 
ws_qt_pendente      number; 
ws_qt_erro_envio    number;
ws_tempo_check      number; 
ws_tempo_baixa      number; 
ws_tempo_atualiza   number; 
nao_enviar          exception; 

begin 
    ws_cliente          := upd.ret_var('CLIENTE'); 
    ws_qt_erro_envio    := 0;
    ws_qt_obj           := 0; 
    ws_qt_erro          := 0; 
    ws_qt_pendente      := 0;

    if upd.tipo_ambiente(ws_cliente) in ('DESENV','HOMOLOGA') then  -- DESENV E HOMOLOGA, não envia logs 
        raise nao_enviar; 
    end if; 

    -- Limpa logs travados 
    delete bi_auto_update_log 
     where id_enviado  = 'N'
       and dt_inicio   < sysdate - 2
       and id_situacao = 'INICIO';

    -- Marca como T os logs já concluídos e ainda não enviados 
    update bi_auto_update_log 
       set id_enviado = 'T'
     where nvl(id_enviado,'N') = 'N'
       and id_situacao        <> 'INICIO' ;
    
    for a in c_bi_auto_update loop 

        if a.tp_objeto = 'MANUTENCAO' then 
            ws_envia := null;
            open  c_log (a.tp_objeto, a.nm_objeto, 'ATUALIZA');
            fetch c_log into ws_envia;
            close c_log ;
            --
            if ws_envia.id_situacao = 'FIM' then 
               ws_envia.id_situacao := 'ATUALIZADO';
            end if;    
            ws_tempo_check    := 0;
            ws_tempo_atualiza := round((ws_atualiza.dt_fim - ws_atualiza.dt_inicio) * 24 * 60 ,0);
            ws_tempo_baixa    := 0;
            --
        else
            -- Envia somente se houver log pendente de envio para o objeto 
            ws_tempo_check    := null;  
            ws_tempo_baixa    := null; 
            ws_tempo_atualiza := null; 
            --
            ws_atualiza       := null;
            open  c_log (a.tp_objeto, a.nm_objeto, 'ATUALIZA');
            fetch c_log into ws_atualiza;
            close c_log ; 
            --
            ws_baixa := null;
            open  c_log (a.tp_objeto, a.nm_objeto, 'BAIXA');
            fetch c_log into ws_baixa;
            close c_log; 
            --
            ws_check := null;
            open  c_log (a.tp_objeto, a.nm_objeto, 'CHECK');
            fetch c_log into ws_check;
            close c_log; 
            --
            -- Situação da atualização 
            if a.tp_objeto = 'TODOS' then   -- Ultimo registro enviado com a situação de TODOS os objetos 
                if ws_qt_erro > 0 then 
                    ws_envia.id_situacao := 'ERRO';
                else
                    if ws_qt_pendente > 0 then 
                        ws_envia.id_situacao := 'PENDENTE';
                    else 
                        ws_envia.id_situacao := 'ATUALIZADO';
                    end if;
                end if;
                ws_envia.ds_atualizacao := 'Total de objetos:'||ws_qt_obj||' (Erros:'||ws_qt_erro||', Pendentes:'||ws_qt_pendente||')';
            else 
                ws_qt_obj := ws_qt_obj + 1; 
                if a.dt_versao_baixa = a.dt_versao_upquery and a.dt_versao_sistema = a.dt_versao_upquery then 
                    ws_envia.id_situacao    := 'ATUALIZADO';
                    ws_envia.ds_atualizacao := ws_atualiza.ds_atualizacao;
                else 
                    if ws_atualiza.id_situacao ='ERRO' then 
                        ws_envia.id_situacao := 'ERRO'; 
                        if a.nm_objeto <> 'SEND_REPORT' then 
                            ws_qt_erro := ws_qt_erro + 1;
                        end if;    
                        ws_envia.ds_atualizacao := ws_atualiza.ds_atualizacao;                        
                    elsif ws_baixa.id_situacao = 'ERRO' then 
                        ws_envia.id_situacao := 'ERRO'; 
                        if ws_baixa.ds_atualizacao not like 'Sem permissao%' then 
                            ws_qt_erro := ws_qt_erro + 1;
                        end if;    
                        ws_envia.ds_atualizacao := ws_baixa.ds_atualizacao;                        
                    else 
                        ws_envia.id_situacao    := 'PENDENTE'; 
                        ws_qt_pendente          := ws_qt_pendente + 1; 
                        ws_envia.ds_atualizacao := 'Pendente';
                    end if;     
                end if;     
            end if; 
            -- 
            -- Dados da ultima atualização ou Baixa 
            if nvl(ws_atualiza.id_auto_update,0) > nvl(ws_baixa.id_auto_update,0) then 
                ws_envia.dt_inicio      := ws_atualiza.dt_inicio;
                ws_envia.dt_fim         := ws_atualiza.dt_fim;
                ws_envia.qt_tentativa   := ws_atualiza.qt_tentativa;
            else
                ws_envia.dt_inicio      := ws_baixa.dt_inicio;
                ws_envia.dt_fim         := ws_baixa.dt_fim;
                ws_envia.qt_tentativa   := ws_baixa.qt_tentativa;
            end if; 

            ws_tempo_check    := round((ws_check.dt_fim    - ws_check.dt_inicio)    * 24 * 60 ,0);
            ws_tempo_atualiza := round((ws_atualiza.dt_fim - ws_atualiza.dt_inicio) * 24 * 60 ,0);
            ws_tempo_baixa    := round((ws_baixa.dt_fim    - ws_baixa.dt_inicio)    * 24 * 60 ,0);

        end if; 

        -- Evento 014 situação update e manutenção do sistema
        if a.tp_objeto <> 'TODOS' or (a.tp_objeto = 'TODOS' and ws_qt_obj > 0) then  
            ws_param := 'SISTEMA|'           ||'BI'||                                                 --1
                        '|TP_OBJETO|'        ||a.tp_objeto||                                          --2 
                        '|NM_OBJETO|'        ||a.nm_objeto||                                          --3
                        '|ID_SITUACAO|'      ||ws_envia.id_situacao||                                 --4  
                        '|DT_VERSAO_UPQUERY|'||to_char(a.dt_versao_baixa,'ddmmyyyyhh24miss')||        --5                        
                        '|DT_VERSAO_BAIXA|'  ||to_char(a.dt_versao_baixa,'ddmmyyyyhh24miss')||        --6
                        '|DT_VERSAO_SISTEMA|'||to_char(a.dt_versao_sistema,'ddmmyyyyhh24miss')||      --7
                        '|DT_INICIO_LOG|'    ||to_char(ws_envia.dt_inicio,'ddmmyyyyhh24miss')||       --8
                        '|DT_FIM_LOG|'       ||to_char(ws_envia.dt_fim,'ddmmyyyyhh24miss')||          --9
                        '|DS_ATUALIZACAO|'   ||REPLACE(ws_envia.ds_atualizacao,'|','-')||             --10
                        '|QT_TENTATIVA|'     ||ws_envia.qt_tentativa||                                --11
                        '|TEMPO_CHECK|'      ||ws_tempo_check||                                       --12
                        '|TEMPO_BAIXA|'      ||ws_tempo_baixa||                                       --13
                        '|TEMPO_ATUALIZA|'   ||ws_tempo_atualiza ;                                    --14

            SELECT rawtohex(ws_param) INTO ws_param from dual;

            ws_command := 'http://'||upd.ret_var('URL_UPDATE')||'/dwu.renew?prm_par=TIPO|014|CLIENTE|'||upd.ret_var('CLIENTE')||'|PARAM_HEXADECIMAL|'||ws_param;
            
            begin
                ws_string  := substr(utl_http.request(ws_command),1,100);
            exception
                when others then
                    ws_string := 'NOK';
            end;
            if ws_string not like 'OK%' then 
                ws_qt_erro_envio := ws_qt_erro_envio + 1; 
                insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values (sysdate, 'Erro AutoUpdate_envia_log (retorno do envia): '|| ws_string, 'DWU', 'ERRO');                    
            end if; 
        end if;
        --
    end loop;     

    if ws_qt_erro_envio = 0 then 
        update bi_auto_update_log 
           set id_enviado = 'S',
               dt_envio   = sysdate 
         where id_enviado = 'T';
    else 
        update bi_auto_update_log 
           set id_enviado = 'N'
         where id_enviado = 'T';
    end if; 
    --
    commit; 
    --
exception
    when nao_enviar then 
        null; 
    when others then 
        rollback; 
        insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values (sysdate, 'Erro AutoUpdate_envia_log(OTHERS): '|| DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 'DWU', 'ERRO'); 
        commit; 
end AutoUpdate_envia_log;




procedure AutoUpdate_log  (prm_id        number, 
                           prm_tp_atu    varchar2, 
                           prm_tipo      varchar2,
                           prm_nome      varchar2, 
                           prm_situacao  varchar2, 
                           prm_msg       varchar2,
                           prm_usuario   varchar2 ) as
ws_id_situacao  varchar2(20); 
ws_id_enviado   varchar2(1); 
ws_msg          varchar2(200); 
begin
    ws_msg        := substr(prm_msg,1,180); -- tem que ser menos que 200, pois o substr ignora os enters no meio do texto 
    ws_id_enviado := 'N';
    if prm_tipo = 'TODOS' and prm_tp_atu <> 'ATUALIZA' then 
        ws_id_enviado := 'S';
    end if; 

    if prm_tp_atu = 'RECOMPILA' then 
        insert into bi_auto_update_log (id_auto_update, tp_atualizacao, tp_objeto, nm_objeto, id_situacao, ds_atualizacao, dt_inicio, dt_fim, nm_usuario, id_enviado) 
                                values (prm_id, prm_tp_atu, prm_tipo, prm_nome, prm_situacao, ws_msg, sysdate, null, prm_usuario, ws_id_enviado); 
    else 
        update bi_auto_update_log
        set ds_atualizacao = (case when tp_objeto IN ('PLSQL','MANUTENCAO') and prm_situacao = 'FIM' and ds_atualizacao is not null then ds_atualizacao else nvl(ws_msg, ds_atualizacao) end),
            id_situacao    = prm_situacao,   
            id_enviado     = ws_id_enviado, 
            dt_fim         = sysdate 
        where id_auto_update = prm_id 
        and tp_atualizacao = prm_tp_atu 
        and tp_objeto      = prm_tipo 
        and nm_objeto      = prm_nome
        and ( ( id_situacao = prm_situacao) or (prm_situacao in ('INICIO','ERRO','FIM') and id_situacao in ('INICIO','ERRO','FIM'))  ) ; 
        if sql%notfound then 
            insert into bi_auto_update_log (id_auto_update, tp_atualizacao, tp_objeto, nm_objeto, id_situacao, ds_atualizacao, dt_inicio, dt_fim, nm_usuario, id_enviado) 
                                    values (prm_id, prm_tp_atu, prm_tipo, prm_nome, prm_situacao, ws_msg, sysdate, null, prm_usuario, ws_id_enviado); 
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
    end if; 
    --
    commit;	
    --
end AutoUpdate_log;



procedure AutoUpdate_mata_sessao ( prm_tipo           varchar2, 
                                   prm_nome           varchar2, 
                                   prm_usuario        varchar2,
                                   prm_tipo_sessao    varchar2, 
                                   prm_msg     in out varchar2) as 
    cursor c1 is 
        select 'alter system kill session '''||S.Sid||','||s.Serial#||''' IMMEDIATE' ds_kill_session,
               l.name||'-'||s.sid||'-'||s.serial#||'-'||s.status||'-'||s.state||'-'||s.osuser||'-'||s.program||'-'||
               to_char(s.logon_time,'dd/mm/yyyy hh24:mi:ss')||'-'||to_char(s.sql_exec_start,'dd/mm/yyyy hh24:mi:ss')||'-'||s.program  ds_log 
          from v$session s, sys.dba_ddl_locks l
         where s.sid    = l.session_id 
           and l.owner  = NVL(upd.ret_var('OWNER_BI'),'DWU') 
           and not (s.AUDSID = Sys_Context('USERENV', 'SESSIONID') AND s.SID = Sys_Context('USERENV', 'SID'))
           and l.type  <> 'Table/Procedure/Type'
           and l.name  = prm_nome
           and ( (prm_tipo_sessao = 'HTTP' and upper(s.program) like 'HTTPD%') or 
                 (prm_tipo_sessao = 'TODOS')  
               )  
         order by s.sql_exec_start ;
begin
    prm_msg := null;
    for a in c1 loop
        begin  
            execute immediate a.ds_kill_session; 
            insert into bi_log_sistema (dt_log, ds_log,nm_usuario, nm_procedure) values(sysdate, 'AutoUpdate_mata_sessao <sessao encerrada>:'||a.ds_log, prm_usuario, 'EVENTO'); 
        exception when others then 
            prm_msg := 'Erro mantando processo de objeto.'; 
            insert into bi_log_sistema (dt_log, ds_log,nm_usuario, nm_procedure) values(sysdate, 'AutoUpdate_mata_sessao:'||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, prm_usuario, 'ERRO');     
            exit;
        end;    
    end loop;
exception when others then 
    prm_msg := DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE; 
end AutoUpdate_mata_sessao; 


-------------------------------------------------------------------------------------------------------------------------------------
-- Retorna se existe pendencia em algum processo de atualização/manutenção do sistema 
-------------------------------------------------------------------------------------------------------------------------------------
function autoUpdate_existe_pendencia ( prm_tp_atu   varchar2, 
                                       prm_tipo     varchar2 default 'TODOS', 
                                       prm_nome     varchar2 default 'TODOS' ) return varchar2 is
ws_count  number; 
begin 
    if prm_tp_atu ='BAIXA' then 
        select count(*) into ws_count 
          from bi_auto_update
         where (dt_versao_baixa < dt_versao_upquery or dt_versao_baixa is null)   
           -- 
           and ( prm_tipo = 'TODOS' or tp_objeto = prm_tipo or (prm_tipo = 'PACKAGE' and tp_objeto like 'PACKAGE%') )   
           and ( prm_nome = 'TODOS' or nm_objeto = prm_nome)     
           and id_situacao not in ('BLOQUEADO','INVALIDO')  -- Se não estiver bloqueado ou Invalido      
           and tp_objeto not in ('ESTADOS', 'CIDADES'); 
    elsif prm_tp_atu in ('ATUALIZA','MANUTENCAO') then 
        select count(*) into ws_count 
          from bi_auto_update
         where dt_versao_baixa = dt_versao_upquery
           and ( dt_versao_sistema < dt_versao_baixa or dt_versao_sistema is null) 
           and ( prm_tipo = 'TODOS' or tp_objeto = prm_tipo or (prm_tipo = 'PACKAGE' and tp_objeto like 'PACKAGE%') )   
           and ( prm_nome = 'TODOS' or nm_objeto = prm_nome)     
           and id_situacao not in ('BLOQUEADO','INVALIDO')  -- Se não estiver bloqueado ou Invalido      
           and tp_objeto not in ('ESTADOS', 'CIDADES')
           --
           and not ( substr(tp_objeto,1,7) = 'PACKAGE' and nm_objeto = 'UPD')   -- A package não pode atualizar ela mesma, a atualização deve ser feita pela procedure da SCH 
           --
           AND ( ( prm_tp_atu = 'ATUALIZA'   and tp_objeto not like 'MANUTENCAO%') or 
                 ( prm_tp_atu = 'MANUTENCAO' and tp_objeto like 'MANUTENCAO%') 
               ) ;    
    elsif prm_tp_atu = 'ATUALIZA_UPD' then 
        select count(*) into ws_count 
          from bi_auto_update
         where dt_versao_baixa = dt_versao_upquery
           and ( dt_versao_sistema < dt_versao_baixa or dt_versao_sistema is null) 
           and tp_objeto like 'PACKAGE%' and nm_objeto = 'UPD' ;
    elsif prm_tp_atu = 'ENVIO_LOG' then 
        select count(*) into ws_count 
          from bi_auto_update_log 
         where nvl(id_enviado,'N') <> 'S' ;
    end if; 

    if ws_count > 0 then  
        return 'S'; 
    else   
        return 'N'; 
    end if; 
end autoUpdate_existe_pendencia; 

----------------------------------------------------------------------------------------------------
-- Recompila objetos inválidos do Sistema
----------------------------------------------------------------------------------------------------
procedure recompila_inativos  (prm_usuario      varchar2 default 'DWU') as
    cursor c1 is 
        select 'alter '||decode(object_type,'PACKAGE BODY','PACKAGE',object_type)||' '||owner||'.'||object_name||' compile '||decode(object_type,'PACKAGE BODY', 'body','') ds_comando, object_type, object_name
          from all_objects
         where owner       = NVL(upd.ret_var('OWNER_BI'),'DWU') 
           and object_type in ('PROCEDURE','FUNCTION','PACKAGE BODY','PACKAGE')
           and object_name in (select nm_objeto from bi_auto_update where tp_objeto in ('PACKAGE_SPEC','PACKAGE_BODY','PLSQL') )
           and status      <> 'VALID'
           and object_name not in ('SCH','UPD','SEND_REPORT') ;    -- Package não pode recompilar ela mesma, a SEND_REPORT dá erro em clientes sem Java instalado no Oracle   
ws_id_atu     number; 
ws_tipo       varchar2(100);        
begin
    ws_id_atu := 0;
    for a in c1 loop
        if    a.object_type = 'PACKAGE'      then ws_tipo := 'PACKAGE_SPEC'; 
        elsif a.object_type = 'PACKAGE BODY' then ws_tipo := 'PACKAGE_BODY'; 
        else                                      ws_tipo := 'PLSQL';    
        end if; 
        if ws_id_atu = 0 then 
            select nvl(max(id_auto_update),0)+1 into ws_id_atu from bi_auto_update_log; 
        end if;             
        begin 
            execute immediate a.ds_comando; 
            AutoUpdate_log (ws_id_atu, 'RECOMPILA', ws_tipo, a.object_name, 'FIM', null, prm_usuario); 
            commit;  
        exception when others then 
            AutoUpdate_log (ws_id_atu, 'RECOMPILA', ws_tipo, a.object_name, 'ERRO', DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, prm_usuario);  
            commit;        
            insert into bi_log_sistema (dt_log, ds_log,nm_usuario, nm_procedure) values (sysdate, 'UPD.recompila_inativos ('||a.object_name||') - Erro:'||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, prm_usuario, 'ERRO');
            commit; 
        end;     
    end loop; 
exception when others then     
    insert into bi_log_sistema (dt_log, ds_log,nm_usuario, nm_procedure) values (sysdate, 'UPD.recompila_inativos-OTHERS - Erro:'||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, prm_usuario, 'ERRO');
    commit; 
end recompila_inativos;



------------------------------------------------------------------------------------------------------------------------------
-- funções copiadas da FUN - Necessário para não lockar essas packages no momento da atualização 
------------------------------------------------------------------------------------------------------------------------------

function c2b ( p_clob IN CLOB ) return blob is
  temp_blob   BLOB;
  dest_offset NUMBER  := 1;
  src_offset  NUMBER  := 1;
  amount      INTEGER := dbms_lob.lobmaxsize;
  blob_csid   NUMBER  := dbms_lob.default_csid;
  lang_ctx    INTEGER := dbms_lob.default_lang_ctx;
  warning     INTEGER;
BEGIN
    DBMS_LOB.CREATETEMPORARY( lob_loc => temp_blob, cache => TRUE );
    DBMS_LOB.CONVERTTOBLOB(temp_blob, p_clob,amount,dest_offset,src_offset,blob_csid,lang_ctx,warning);
    Return Temp_Blob;
END c2b;

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

-- 
function vpipe_clob ( prm_entrada clob,
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
            ws_flag  := 'Y';
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
end vpipe_clob;

--
function vpipe_n (prm_param varchar2,
                  prm_idx   number,
                  prm_pipe  varchar2 default '|' ) return varchar2 as 
ws_idx1   number;
ws_idx2   number;
begin

    if prm_idx <= 0 then 
       return null;
    end if;

    if (prm_idx - 1) <= 0 then 
        ws_idx1 := 0;
    else         
        ws_idx1 := instr(prm_param, prm_pipe ,1, prm_idx-1);
    end if;    
    ws_idx2 := instr(prm_param, prm_pipe,1, prm_idx);

    if ws_idx1 = 0 and ws_idx2 = 0 then 
       return null;
    end if; 
    if ws_idx2 = 0 then 
        ws_idx2 := length(prm_param); 
    else     
        ws_idx2 := ws_idx2 - ws_idx1 - 1; 
    end if;

    return substr(prm_param, ws_idx1 + 1, ws_idx2); 
end vpipe_n; 

----------------------------------------------------------------------
-- Retorna parte da string buscando pelo nome do campo (separado por pipe)
----------------------------------------------------------------------
function ret_param_nome (prm_param varchar2, prm_nome varchar2, prm_pipe varchar2 default '|') return varchar2 is 
ws_return varchar2(4000); 
begin

    if instr(prm_param, prm_nome||prm_pipe) = 0 then 
        ws_return := ''; 
    else 
        ws_return := substr(prm_param, instr(prm_param, prm_nome||prm_pipe), 4000);
        ws_return := replace(ws_return,prm_nome||prm_pipe,'');
        if instr(ws_return,prm_pipe,1,1) > 0 then 
            ws_return := substr(ws_return, 1, instr(ws_return,prm_pipe,1,1)-1);
        end if;  
    end if;    
    return ws_return; 
end ret_param_nome; 

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
    insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - EXECUTE_NOW', 'DWU', 'ERRO');
    commit;
end execute_now;



function tipo_ambiente ( prm_cd_cliente varchar2  default null ) return varchar2 as
    ws_cd_cliente varchar2(50); 
begin 
    ws_cd_cliente := nvl(prm_cd_cliente, upd.ret_var('CLIENTE')); 
    if    ws_cd_cliente in ('999999911','999999906') then          return 'DESENV';
    elsif ws_cd_cliente = '999999907' then                         return 'HOMOLOGA';
    else                                                           return 'PRODUCAO';
    end if; 
end tipo_ambiente;  



end UPD;