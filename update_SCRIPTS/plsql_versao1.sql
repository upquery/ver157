--------------------------------------------------------------------------------------------
-- Alterações de tabelas, indexes (update,insert,etc)
--------------------------------------------------------------------------------------------
declare 
    ws_passo         varchar2(20); 
    ws_count         number; 
    ws_msg_erro      varchar2(300); 
    ws_raise_execute exception;
    --
    -- Faz o execute immediate tratando alguns exceptions 
    ----------------------------------------------------------------------
    procedure p_execute_immediate (p_sql varchar2) is 
    begin
        execute immediate p_sql; 
    exception when others then 
        if DBMS_UTILITY.FORMAT_ERROR_STACK like '%ORA-01430%' or       -- coluna já existe 
           DBMS_UTILITY.FORMAT_ERROR_STACK like '%ORA-00955%' or       -- nome já está sendo usado por um objeto existente
           DBMS_UTILITY.FORMAT_ERROR_STACK like '%ORA-02260%' or       -- a tabela só pode ter uma chave primária
           DBMS_UTILITY.FORMAT_ERROR_STACK like '%ORA-01408%' or       -- coluna já indexada (criação de index)
           DBMS_UTILITY.FORMAT_ERROR_STACK like '%ORA-02443%' or       -- Constraint não existe 
           DBMS_UTILITY.FORMAT_ERROR_STACK like '%ORA-01452%' or       -- há chaves duplicadas na criação de index
           DBMS_UTILITY.FORMAT_ERROR_STACK like '%restri%exclusiva%violada%' then          
            null;
        else 
            ws_msg_erro := substr('PLSQL_VERSAO1('||ws_Passo||'):'||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,299); 
            raise ws_raise_execute;
        end if;      
    end;
    -----------------------------------------------------------------------
begin 
    --
    ws_passo := '1';
    p_execute_immediate ('create table BI_AVISOS (
                            id_aviso            number,
                            ds_aviso            varchar2(80),
                            dh_inicio           date,
                            dh_fim              date,
                            tp_usuario          varchar2(20),
                            tp_conteudo         VARCHAR2(40),
                            nm_conteudo         varchar2(300), 
                            url_aviso           varchar2(200), 
                            dh_alteracao        date 
                            )' );
    p_execute_immediate ('alter table bi_avisos add constraint pk_bi_avisos primary key (id_aviso)'); 
    p_execute_immediate ('create index idx_bi_avisos_01 on bi_avisos (dh_inicio, dh_fim)');  
    p_execute_immediate ('create table BI_AVISO_USUARIO (
                            id_aviso            number,
                            usu_nome            varchar2(80),
                            qt_visualizacao     number,
                            dh_visualizacao     date, 
                            id_nao_mostrar      varchar2(1),
                            dh_nao_mostrar      date    
                            )');  
    p_execute_immediate ('alter table bi_aviso_usuario add constraint pk_bi_aviso_usuario primary key (id_aviso, usu_nome)'); 
    p_execute_immediate ('create index bi_aviso_usuario_idx01 on bi_aviso_usuario (usu_nome)'); 
    --
    ws_passo := '2';
    p_execute_immediate ('alter table usuarios add tp_ordem_coluna  varchar2(5) default ''M'' ');
    p_execute_immediate ('alter table usuarios add id_aviso_mostrar varchar2(1) default ''S'' '); 
    --
    ws_passo := '3';
    p_execute_immediate ('alter table user_netwall add tp_net_address varchar2(1) default ''I'' ');      
    p_execute_immediate ('create index user_netwall_idx01 on user_netwall (tp_net_address)');  
    --
    ws_passo := '4';   
    p_execute_immediate ('alter table micro_coluna add color_perc varchar2(40)');  -- Nova propriedade de cor para colunas de percentual  
    --
    ws_passo := '5';   -- Marcadores mapa geo localização 
    p_execute_immediate (' create table BI_MAPA_MARCADOR 
                            (cd_marcador         varchar2(10), 
                            ds_marcador         varchar2(50), 
                            label_fontfamily    varchar2(50), 
                            label_color         varchar2(10), 
                            label_fontsize      number, 
                            label_fontweight    varchar2(20), 
                            img_url             varchar2(200), 
                            img_height          number, 
                            img_width           number, 
                            svg_path            varchar2(4000), 
                            svg_fillcolor       varchar2(20), 
                            svg_fillopacity     number, 
                            svg_strokeopacity   number,
                            svg_scale           number,                             
                            svg_rotation        number )   
                        '); 
    p_execute_immediate ('alter table bi_mapa_marcador add nm_usuario varchar2(50)'); -- Cliente com a tabela já criada
    p_execute_immediate ('alter table bi_mapa_marcador add nr_ordem number');                 -- Cliente com a tabela já criada 
    p_execute_immediate ('alter table bi_mapa_marcador add constraint pk_bi_mapa_marcador primary key (cd_marcador)'); 
    --
    p_execute_immediate ('alter table data_coluna add st_input_browser varchar2(2) default ''N'' ');     
    p_execute_immediate ('alter table data_coluna add acao varchar2(4000) default null ');     
    --
    p_execute_immediate (' create table BI_TABELA_SISTEMA 
                            (NM_TABELA VARCHAR2(200),
                             TP_TABELA VARCHAR2(20)
                            )   
                        '); 
    p_execute_immediate ('alter table BI_TABELA_SISTEMA  ADD CONSTRAINT PK_BI_TABELA_SISTEMA  PRIMARY KEY (NM_TABELA)');    
    --
    COMMIT; 
    --    
    ws_passo := '6';   -- Nova processoMarcadores mapa geo localização 
    p_execute_immediate (' create table bi_report_fila (
                            iu_report_fila    varchar2(50),
                            id_report_fila    varchar2(50),
                            id_report         number, 
                            destinatario      varchar2(200), 
                            assunto           varchar2(200),
                            mensagem          varchar2(4000),
                            tp_conteudo       varchar2(30), 
                            nm_conteudo       varchar2(200), 
                            largura_folha     number,
                            altura_folha      number,
                            dt_criacao        date, 
                            dt_inicio         date,
                            dt_final          date,
                            status            varchar2(1),
                            erros             varchar2(4000))   
                        '); 
    p_execute_immediate ('alter table bi_report_fila add constraint pk_bi_report_fila primary key (iu_report_fila)');
    p_execute_immediate ('create index idx_bi_report_fila_001 on bi_report_fila (id_report)');
    p_execute_immediate ('create index idx_bi_report_fila_002 on bi_report_fila (id_report_fila)');
    p_execute_immediate ('create index idx_bi_report_fila_003 on bi_report_fila (dt_criacao)');
    --
    p_execute_immediate ('alter table bi_report_list add cd_objeto          varchar2(100)');
    p_execute_immediate ('alter table bi_report_list add largura_folha      number');
    p_execute_immediate ('alter table bi_report_list add altura_folha       number');
    p_execute_immediate ('alter table bi_report_list add id_situacao_envio  varchar2(20)');
    p_execute_immediate ('alter table bi_report_list add id_report_fila     varchar2(50)');
    p_execute_immediate ('alter table bi_report_list add qt_tentativa_envio number');
    --
    p_execute_immediate ('alter table bi_report_schedule add dia_mes varchar2(120)');
    --
    p_execute_immediate ('update bi_report_list set cd_objeto = tela where cd_objeto is null and tela is not null');

    p_execute_immediate ('ALTER TABLE active_sessions ADD cd_sid VARCHAR2(20) ADD cd_serial VARCHAR2(20)');
    --
    p_execute_immediate ('alter table objetos modify subtitulo varchar2(4000)');
    --
    p_execute_immediate ('alter table data_coluna add largura varchar2(6) default null ');
    --
    p_execute_immediate ('alter table bi_report_list modify email varchar2(4000) default null ');
    -- 630s
    p_execute_immediate ('alter table gusers add constraint pk_gusers primary key (cd_group)');
    p_execute_immediate ('alter table usuarios add constraint pk_usuarios primary key (usu_nome)');
    p_execute_immediate ('create index idx_FILTROS_03 on FILTROS (cd_usuario)');
    p_execute_immediate ('create index TRADUCAO_COLUNAS_01 on TRADUCAO_COLUNAS (cd_tabela, cd_coluna)');
    --
    p_execute_immediate ('create index idx_FLOAT_FILTER_ITEM_01  on FLOAT_FILTER_ITEM (screen, cd_usuario)');
    p_execute_immediate ('create index idx_MICRO_COLUNA_01       on MICRO_COLUNA (cd_micro_visao, cd_coluna)'); 
    p_execute_immediate ('create index idx_FILTROS_02            on FILTROS (micro_visao, cd_usuario)');
    p_execute_immediate ('create index idx_FILTROS_03            on FILTROS (cd_usuario)');
    p_execute_immediate ('create index idx_DEFF_LINE_FILTRO_01 on DEFF_LINE_FILTRO (cd_mapa, nr_item, cd_padrao)');
    --
    p_execute_immediate ('create table BI_OBJECT_ANOTACAO ( 
                            cd_object      VARCHAR2(80), 
                            nm_usuario     varchar2(100), 
                            cd_coluna      varchar2(100), 
                            cd_condicao    varchar2(4000), 
                            cd_filtro      varchar2(4000),   
                            ds_anotacao    varchar2(4000),
                            dh_anotacao    date,
                            usuario_permissao varchar2(4000)
                            )'); 
    p_execute_immediate ('create index BI_OBJECT_ANOTACAO_idx01 on BI_OBJECT_ANOTACAO (cd_object, cd_coluna, cd_filtro)'); 
    p_execute_immediate ('alter table micro_coluna add st_alinhamento_cab varchar2 (8)');
    p_execute_immediate ('update micro_coluna set st_alinhamento_cab = st_alinhamento where st_alinhamento_cab is null');
    --
    commit;
    --
    ws_passo := '7';   -- ETL
    p_execute_immediate ('create table etl_tipo_conexao ( 
                            tp_conexao     varchar2(50),  
                            tp_parametro   varchar2(20),                             
                            cd_parametro   varchar(50),
                            nm_parametro   varchar(100),
                            ds_parametro   varchar2(4000),
                            ordem_tela     number(3),
                            ordem_comando  number(3) ) ');
    --                             
    commit; 
    --
    p_execute_immediate ('create unique index etl_step_idx02 on etl_step (step_id)');
    p_execute_immediate ('alter table etl_step add ds_step        varchar2(100)'); 
    p_execute_immediate ('alter table etl_step drop constraint pk_etl_step'); 
    p_execute_immediate ('alter table etl_fila add run_step_id    varchar2(20)'); 
    p_execute_immediate ('alter table etl_run  modify last_status varchar2(20)'); 
    p_execute_immediate ('alter table etl_run  add    st_ativo    varchar2(20)'); 
    p_execute_immediate ('create table etl_run_step ( 
                           run_step_id    varchar2(20), 
                           ordem          number, 
                           run_id         varchar2(200),
                           step_id        varchar2(60),
                           dependence_id  varchar2(4000),
                           case_sucesso   varchar2(20),
                           case_erro      varchar2(20), 
                           last_status    varchar2(20), 
                           dh_inicio      date,
                           dh_fim         date, 
                           job_id         varchar2(20) )'); 
    p_execute_immediate ('alter table etl_run_step modify dependence_id  varchar2(4000)');                            
    p_execute_immediate ('alter table etl_run_step add constraint pk_etl_run_step primary key (run_step_id)'); 
    p_execute_immediate ('create index etl_run_step_idx001 on etl_run_step (run_id)'); 
    p_execute_immediate ('create index etl_run_step_idx002 on etl_run_step (step_id)'); 
    p_execute_immediate ('create table etl_log ( 
                            log_id        varchar2(200), 
                            sq_log        number, 
                            tp_log        varchar2(20), 
                            ds_log        varchar2(200), 
                            run_id        varchar2(20), 
                            ordem         number,
                            run_step_id   varchar2(20),
                            step_id       varchar2(60),
                            dh_inicio     date default sysdate not null,
                            dh_fim        date, 
                            status        varchar2(20) )'); 
    p_execute_immediate ('create index etl_log_idx01 on etl_log (log_id, run_id, run_step_id)');
    p_execute_immediate ('create index etl_log_idx02 on etl_log (run_id)');
    p_execute_immediate ('create index etl_log_idx03 on etl_log (run_step_id)');
    p_execute_immediate ('create index etl_log_idx04 on etl_log (step_id)');
    p_execute_immediate ('create index etl_log_idx05 on etl_log (dh_inicio)');
    p_execute_immediate ('create table etl_run_param (
                            run_id        varchar2(200), 
                            cd_parametro  varchar2(50), 
                            conteudo      varchar2(4000),
                            st_ativo       varchar2(1)) '); 
    p_execute_immediate ('alter table etl_run_param modify conteudo varchar2(4000)');
    p_execute_immediate ('alter table etl_run_param add constraint pk_etl_run_param primary key (run_id, cd_parametro)');                             
    p_execute_immediate ('create table etl_step_param (
                            step_id        varchar2(200), 
                            cd_parametro  varchar2(50), 
                            ds_parametro  varchar2(100),
                            id_entreaspas varchar2(1) ) '); 
    p_execute_immediate ('alter table etl_step_param add constraint pk_etl_step_param primary key (step_id, cd_parametro)');                             
    --
    p_execute_immediate ('create table user_permissao  (
                            cd_usuario       varchar2(100), 
                            cd_permissao     varchar2(50), 
                            dt_permissao     date ) '); 
    p_execute_immediate ('alter table user_permissao add constraint pk_user_permissao primary key (cd_usuario, cd_permissao)');
    --
    ws_passo := '8'; 
    p_execute_immediate ('alter table etl_tipo_conexao add vl_default  varchar2(1000)'); 
    p_execute_immediate ('alter table etl_run          add dh_envio    date'); 
    p_execute_immediate ('alter table etl_fila         add step_id     varchar2(60)'); 
    --
    p_execute_immediate ('create index etl_fila_idx02 on etl_fila (id_uniq)'); 
    p_execute_immediate ('alter table etl_fila add qt_tentativas varchar2(3)'); 
    p_execute_immediate ('alter table etl_fila add nr_tentativa  varchar2(3)'); 
    p_execute_immediate ('alter table etl_run_step add qt_tentativas number');
        begin 
        p_execute_immediate ('grant execute on etl to upmaster');
    exception when others then 
        insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values(sysdate, 'PLSQL_VERSAO1('||ws_Passo||')(grant):'||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 'DWU', 'ERRO'); 
    end; 
    p_execute_immediate ('alter table etl_log modify ds_log varchar2(500)');
    --
    ws_passo := '8.1'; 
    p_execute_immediate ('alter table etl_tipo_conexao add tp_comando varchar2(100)'); 
    p_execute_immediate ('alter table etl_tipo_conexao drop constraint pk_etl_tipo_conexao'); 
    --
    ws_passo := '8.2'; 
    p_execute_immediate ('alter table etl_step add tipo_execucao varchar2(30)');
    p_execute_immediate ('alter table etl_tipo_conexao add tp_execucao varchar2(30)');
    p_execute_immediate ('create index etl_tipo_conexao_idx001 on etl_tipo_conexao (tp_conexao, tp_execucao, cd_parametro)');     
    --
    ws_passo := '8.3'; 
    p_execute_immediate ('create or replace TYPE CHARRET2 AS TABLE OF VARCHAR2(4000)');
    --
    p_execute_immediate ('alter table goto_objeto add cd_goto_objeto   number default 0');
    p_execute_immediate ('alter table goto_objeto add ds_complemento   varchar2(200)'); 
    p_execute_immediate ('alter table goto_objeto add cs_coluna        varchar2(4000)');  
    p_execute_immediate ('alter table goto_objeto add cs_agrupador     varchar2(4000)');
    p_execute_immediate ('alter table goto_objeto add cs_colup         varchar2(4000)');    
    p_execute_immediate ('alter table goto_objeto add orderby          varchar2(4000)'); 
    p_execute_immediate ('create index goto_objeto_idx01 on goto_objeto (cd_objeto, cd_usuario)');
    p_execute_immediate ('create index goto_objeto_idx02 on goto_objeto (cd_goto_objeto)');
    --
    ws_passo := '8.4';
    begin 
        p_execute_immediate ('alter table etl_run_param drop column nm_mascara');
    exception when others then 
        insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values(sysdate, 'PLSQL_VERSAO1('||ws_Passo||') (advertência) :'||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 'DWU', 'ERRO'); 
        commit; 
    end;     

    ws_passo := '8.5';
    begin 
        p_execute_immediate ('alter table etl_run_param add id_entreaspas varchar2(3)'); 
    exception when others then 
        insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values(sysdate, 'PLSQL_VERSAO1('||ws_Passo||') (advertência) :'||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 'DWU', 'ERRO'); 
        commit; 
    end;     
    p_execute_immediate ('alter table etl_log modify ds_log varchar2(4000)');
    p_execute_immediate ('alter table etl_fila add log_id        varchar2(50)'); 
    p_execute_immediate ('alter table etl_fila add dados_retorno clob');  
    p_execute_immediate ('create index etl_fila_status_idx01 on etl_fila (status)'); 
    p_execute_immediate ('create index etl_fila_criacao_idx02 on etl_fila (dt_criacao)'); 
    p_execute_immediate ('create index etl_fila_log_idx01 on etl_fila (log_id)');
    p_execute_immediate ('create index etl_fila_run_idx01 on etl_fila (run_id)');
    --
    p_execute_immediate ('create table bi_log_exec (
                            id_exec    varchar2(50),
                            cd_objeto  varchar2(50), 
                            cd_usuario varchar2(100),
                            tp_exec    varchar2(50),
                            sq_exec    integer,
                            ds_exec    varchar2(200),
                            dh_exec    date,
                            query_exec clob)' ); 
    p_execute_immediate ('create index bi_log_exec_idx001 on bi_log_exec (id_exec)');
    --
    ws_passo := '9';
    p_execute_immediate ('create table bi_jet_conexao  (
                            cd_conexao varchar2(30),
                            host       varchar2(40),
                            porta      varchar2(50),  
                            charset    varchar2(20),
                            formato    varchar2(10),
                            chunk      varchar2(30),
                            token      varchar2(70) )'); 
    p_execute_immediate ('alter table bi_jet_conexao add constraint bi_jet_conexao_pk primary key (cd_conexao)') ;
    p_execute_immediate ('create table bi_jet_tabela  (
                            nm_tabela      varchar2(200),
                            nm_tabela_jet  varchar2(200),
                            cd_conexao     varchar2(30),
                            id_ativo       varchar2(1) default ''S'' )'); 
    p_execute_immediate ('alter table bi_jet_tabela add id_ativo  varchar2(1) default ''S''') ;                            
    p_execute_immediate ('alter table bi_jet_tabela add constraint bi_jet_tabela_pk primary key (nm_tabela)') ;
    --
    ws_passo := '10';
    p_execute_immediate('ALTER TABLE MICRO_COLUNA MODIFY CD_MICRO_VISAO VARCHAR2(80)');
    --
    p_execute_immediate ('create global temporary table BI_GRAFICO_TMP  (
                            ordem   number,
                            col1    varchar2(100),
                            col2    varchar2(500),
                            col3    varchar2(100),
                            col4    varchar2(500),
                            col5    varchar2(500),
                            col6    varchar2(500),
                            col7    varchar2(500),
                            col8    varchar2(500),
                            val1    number,
                            val2    number,
                            val3    number,
                            val4    number
                          ) on commit delete rows'); 
    --
    ws_passo := '10';
    p_execute_immediate ('alter table bi_report_schedule add dia_mes varchar2(120)'); 
    --                            
    p_execute_immediate ('alter table usuarios add id_usuario_externo  varchar2(100)'); 
    p_execute_immediate ('create unique index idx_usuarios_001 on usuarios (id_usuario_externo)'); 
    --
    p_execute_immediate ('create table etl_log_envio (
                            run_id      varchar2(20), 
                            step_id     varchar2(60), 
                            dh_log      date, 
                            tp_log      varchar2(10),
                            ds_log      varchar2(200),
                            id_enviado  varchar2(1) default ''N'',
                            dh_envio    date )' );
    p_execute_immediate ('create index etl_log_envio_idx001 on etl_log_envio (id_enviado)'); 
    --
    p_execute_immediate ('alter table micro_coluna add sinalizador varchar2(40)');  
    --
    p_execute_immediate ('alter table codigo_descricao add tipo varchar2(100) default ''TABELA'''); 
    p_execute_immediate ('alter table codigo_descricao modify nds_tfisica varchar2(4000)'); 
    --
    p_execute_immediate ('alter table usuarios add APP varchar2(1) default ''S'''); 
    --
    p_execute_immediate ('alter table etl_step add base_destino varchar2(20)');     
    p_execute_immediate ('alter table etl_fila add conexao_jet varchar2(300)');     
    --
    p_execute_immediate ('create index idx_COLUMN_RESTRICTION_001 on COLUMN_RESTRICTION (cd_micro_visao, cd_coluna, usuario)'); 
    p_execute_immediate ('create index idx_object_restriction_001 on object_restriction (cd_objeto, usuario)'); 
    p_execute_immediate ('create index idx_destaque_002 on destaque (cd_objeto, cd_coluna)'); 
    --
    p_execute_immediate ('alter table modelo_cabecalho add nm_rotina_plsql varchar2(30)');
    --
    commit; 
    --
    p_execute_immediate ('alter table data_coluna add st_recarregar varchar2(1) default ''N'''); 
    p_execute_immediate ('alter table etl_schedule add p_dia_mes varchar2(120)');
    --
    p_execute_immediate ('alter table bi_report_list add id_ativo varchar2(1)');
    --
    p_execute_immediate ('alter table micro_coluna add sinalizador varchar2(40)');     
    p_execute_immediate ('alter table micro_coluna add formula_jet varchar2(4000)'); 
    --
    p_execute_immediate ('alter table grupos_funcao add cd_grupo_superior varchar2(40)');   
    --
    p_execute_immediate ('create table bi_aviso_permissao (
                            nm_usuario      varchar2(40),
                            id_aviso        varchar2(100),
                            dh_liberacao    date )');
    p_execute_immediate ('alter table bi_avisos add tp_origem varchar2(20) default null');
    p_execute_immediate ('alter table bi_avisos add tela_aviso varchar2(50) default null');
    -- 
    ws_passo := '11';
    begin 
        p_execute_immediate ('grant execute on cfg to upmaster');
    exception when others then 
        insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values(sysdate, 'PLSQL_VERSAO1('||ws_Passo||')(grant):'||substr(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,3900), 'DWU', 'ERRO'); 
    end; 
    --
    p_execute_immediate ('create table bi_regioes (
                            cd_regiao varchar2(3),
                            nm_regiao varchar2(40),
                            sq_json   number(3),
                            json      clob
    )');
    --
    p_execute_immediate ('alter table bi_estados add cd_regiao varchar2(4)'); 
    p_execute_immediate ('alter table bi_cidades add cd_regiao varchar2(4)'); 
    --
    p_execute_immediate ('create table bi_regioes (
                            cd_regiao varchar2(3),
                            nm_regiao varchar2(40),
                            sq_json   number(3),
                            json      clob
    )');
    --
    p_execute_immediate ('alter table bi_estados add cd_regiao varchar2(4)'); 
    p_execute_immediate ('alter table bi_cidades add cd_regiao varchar2(4)'); 
    --
    p_execute_immediate ('alter table data_coluna add st_multi_input varchar2(1) default ''N''');
    commit; 
    --
    p_execute_immediate ('alter table micro_coluna add quebra_texto varchar2(1)'); 
    p_execute_immediate ('alter table codigo_descricao add nr_ordem_select varchar2(5)'); 
    --  
    p_execute_immediate ('alter table bi_jet_tabela add id_browser varchar2(1) default ''N'' ');   
    p_execute_immediate ('create index tab_documentos_idx002 on tab_documentos (name)');   
    p_execute_immediate ('create index tab_documentos_idx003 on tab_documentos (usuario)');   
    --
    commit;        
exception 
    when ws_raise_execute then 
        insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values(sysdate, ws_msg_erro, 'DWU', 'ERRO'); 
        commit; 
    when others then 
        insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values(sysdate, 'PLSQL_VERSAO1('||ws_Passo||'):'||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 'DWU', 'ERRO'); 
        commit; 
end; 