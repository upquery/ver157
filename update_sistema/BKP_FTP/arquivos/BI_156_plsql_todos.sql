declare 
ws_passo   varchar2(20); 
begin 
    --
    -- Cria tabela BI_CONSTANTES_BKP (se não existir)
    ws_passo := '0';
    declare 
        ws_count number; 
    begin 
        select count(*) into ws_count 
          from all_tables 
         where owner ='DWU' and table_name = 'BI_CONSTANTES_BKP'; 
        if ws_count = 0 then 
            execute immediate 'create table bi_constantes_bkp as select * from bi_constantes where rownum = 0 '; 
        end if; 
    end; 
    --
    --
    -- Aumenta o tamanho do nome da micro visão e tabela 
    begin  execute immediate 'alter table micro_visao modify nm_micro_visao varchar2(80)'; exception when others then null; end;  
    begin  execute immediate 'alter table micro_visao modify nm_tabela      varchar2(80)'; exception when others then null; end;  
    --
    -- Cria novos campos utilizados para a consulta customizada (se der erro é porque as colunas já existem)
    begin  execute immediate 'alter table objetos add id_customizado varchar2(1)';  exception when others then null; end;  
    begin  execute immediate 'alter table objetos add id_liberado    varchar2(1)';  exception when others then null; end;  
    --
    -- Novos campos na tabela USUARIOS para controle de Expiração de senha 
    begin  execute immediate 'alter table usuarios add dt_validacao_senha date';      exception when others then null; end;  
    begin  execute immediate 'alter table usuarios add id_expira_senha varchar2(1)';  exception when others then null; end;  
    begin  execute immediate 'alter table usuarios add dt_validacao_email date';      exception when others then     null; end;         
    begin  execute immediate 'alter table usuarios add cd_tela_inicial varchar2(40)';   exception when others then null; end; 
    begin  execute immediate 'alter table usuarios drop column dt_ultima_validacao';  exception when others then     null; end;
    --
    ws_passo := '4';
    -- Novo campo usuario no log do auto_update  
    begin  execute immediate 'alter table BI_AUTO_UPDATE_LOG ADD NM_USUARIO varchar2(50)';  exception when others then null; end;  
    --
    ws_passo := '4';
    -- Novo campo para ordenar favoritos na tela 
    begin execute immediate 'alter table favoritos add ordem number(4)';   exception when others then null; end; 
    --
    merge into VAR_CONTEUDO t1 using (select 'DWU' usuario, 'TEMPO_EXPIRA_EMAIL' variavel, '1' conteudo, 'Informar o tempo em dias para expira&ccedil;&atilde;o da &uacute;ltima valida&ccedil;&atilde;o de identidade do usu&aacute;rio através do e-mail.'||chr(10)||'Informar 0 para n&atilde;o expirar a valida&ccedil;&atilde;o de identidade do usu&aacute;rio, com isso o sistema solicitar&aacute; a valida&ccedil;&atilde;o somente para novos usu&aacute;rios, ou quando houver altera&ccedil;&atilde;o do email do usu&aacute;rio.' descricao, 'TTN' permissao, 'Tempo Expira E-mail' nome, 6 ordem from dual ) t2  on (t1.variavel = t2.variavel )  when matched then update set t1.descricao = t2.descricao, t1.nome = t2.nome, t1.ordem = t2.ordem, t1.permissao = t2.permissao  when not matched then insert (usuario, variavel, data, conteudo, descricao, nome, ordem, permissao) values (t2.usuario, t2.variavel, sysdate, t2.conteudo, t2.descricao, t2.nome, t2.ordem, t2.permissao);
    --
    merge into classes_funcao t1 using (select 'OUTROS' cd_classe, 'Outros' ds_classe, 91 ordem from dual ) t2  on (t1.cd_classe = t2.cd_classe )  when matched then update set t1.ds_classe = t2.ds_classe, t1.ordem = t2.ordem  when not matched then insert (cd_classe, ds_classe, ordem) values (t2.cd_classe, t2.ds_classe, t2.ordem );
    --
    commit; 
    --
exception when others then 
    insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values(sysdate, 'PLSQL_TODOS('||ws_Passo||'):'||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 'DWU', 'ERRO'); 
    commit; 
end; 