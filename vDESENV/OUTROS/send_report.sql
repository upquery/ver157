------------------------------------------------------------------------------------------------------
-- Procedure para report de telas por email - Utiliza Java por isso foi separado das packages do BI 
------------------------------------------------------------------------------------------------------
create or replace procedure send_report( prm_to       varchar2 default null,
                                         prm_cc       varchar2 default null,
                                         prm_message  varchar2 default null, 
                                         prm_subject  varchar2 default null,
                                         prm_url_bi   varchar2 default null,
                                         prm_url_tela varchar2 default null, 
                                         prm_apikey   varchar2 default null,
                                         prm_filename varchar2 default 'relatorio.pdf',
                                         prm_retorno  out varchar2 ) as
    ws_send         varchar2(4000);
    ws_send_retorno varchar2(4000); 
begin

    prm_retorno     := null; 
    ws_send_retorno := null;

    ws_send := '{ ';
    ws_send := ws_send||'"to":[ "'||prm_to||'"], ';         --DESTINATÁRIO
    if nvl(prm_cc, 'N/A') <> 'N/A' then
        ws_send := ws_send||'"toCc":[ "'||prm_cc||'"], ';   --CÓPIA OCULTA
    end if;
    ws_send := ws_send||'"message": "'||replace(replace(replace(replace(replace(prm_message, CHR(10), ''), CHR(13), ''), CHR(13)||CHR(10), ''), '\n', ''), '"', '\"')||'", ';     --CORPO DO EMAIL
    ws_send := ws_send||'"subject": "'||prm_subject||'", ';       --ASSUNTO
    ws_send := ws_send||'"urls": [{"url": "http://'||prm_url_bi||prm_url_tela||'", "user": "", "password": "", "attachmentName": "'||prm_filename||'"}] ';
    ws_send := ws_send||' }';

    -- ENDEREÇO DA FERRAMENTA DE ENVIO, REPORT É O PRINT DA TELA
    select XT_HTTP.doApiPost('http://backend.upquery.com/api/v1/report', prm_apikey, null, null, ws_send) into ws_send_retorno from dual;

    if nvl(ws_send_retorno,'N/A') <> 'N/A' then 
        prm_retorno := substr('Erro envio email XT_HTTP.doApiPost, Erro= <'||ws_send_retorno||'>.',1,499); 
        insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values (sysdate, substr('SEND_REPORT erro na chamada:'||ws_send,1,3999), 'DWU', 'ERRO'); 
        commit; 
    end if;

    -- GRANT PARA ACESSO A FERRAMENTA   -- dbms_java.grant_permission( grantee => 'DWU', permission_type => 'SYS:java.net.SocketPermission', permission_name => 'backend.upquery.com:80', permission_action => 'connect,resolve' );

exception when others then
    prm_retorno := substr('Erro outros <'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||'>.',1,499); 
end send_report;