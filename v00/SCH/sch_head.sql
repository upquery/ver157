create or replace PACKAGE SCH  IS

    procedure main;

    procedure finaliza_rel (prm_tempo varchar2 default null);

    procedure job_quarter ( prm_check varchar2 default null );

    procedure reg_online_acessos;

    procedure reg_online_usuarios;

    procedure nested_reg_online ( prm_tipo     varchar2 default null,
                                  prm_evento   varchar2 default null,
                                  prm_status   varchar2 default null,
                                  prm_usuario  varchar2 default null,
                                  prm_qtde     varchar2 default null ); 

    procedure autoupdate_atualiza (prm_tipo varchar2, prm_pkg varchar2 default null);

    procedure autoUpdate_atu_PACKAGE (prm_usuario        varchar2 default 'DWU',
                                      prm_tipo           varchar2, 
                                      prm_nome           varchar2, 
                                      prm_chamada        varchar2 default 'BANCO' ) ; 

    function aguardar_atualizacao  (prm_tp_atualizacao   varchar2, 
                                    prm_qt_tentativas    number, 
                                    prm_qt_intervalo     number) return varchar2; 

    procedure AutoUpdate_log  (prm_id        number, 
                               prm_tp_atu    varchar2, 
                               prm_tipo      varchar2,
                               prm_nome      varchar2, 
                               prm_situacao  varchar2, 
                               prm_msg       varchar2,
                               prm_usuario   varchar2 ) ;

    procedure alert_online (p_id       in out number,
                            p_bloco			  varchar2 default null,
                            p_inicio 		  date     default null,
                            p_fim			  date     default null,
                            p_parametro		  varchar2 default null,
                            p_status 		  varchar2 default null,
                            p_obs	          varchar2 default null,
                            p_st_notify       varchar2 default 'REGISTRO',
                            p_mail_notify     varchar2 default 'N',
                            p_pipe_tabelas    varchar2 default null ) ; 

    procedure reg_online_usuario ;

    procedure limpa_logs_sistema ; 

    function ret_classe_tela ( prm_descricao  varchar2 default null,
                               prm_programa   varchar2 default null) return varchar2 ;
                               
    procedure exec_integrador(prm_run_id            in varchar2,
                              prm_data_ini          in varchar2 default null,
                              prm_data_fim          in varchar2 default null,
                              prm_status_fila       in varchar2 default 'A',
                              prm_tempo_loop        in number   default 30,
                              prm_erro_step        out varchar2) ;

    --=========================================================================================================================
    --= FUNÇÕES cópias da package FUN -  Separadas da FUN para evitar lock da package FUN pelo processo de carga/job          = 
    --=========================================================================================================================
 
    procedure execute_now ( prm_comando  varchar2 default null,
                            prm_repeat  varchar2 default  's' );

    function ret_var  ( prm_variavel   varchar2 default null, 
                        prm_usuario    varchar2 default 'DWU' ) return varchar2 ;
                        
    function vpipe ( prm_entrada varchar2,
                     prm_divisao varchar2 default '|' ) return CHARRET pipelined;

    function gen_id return varchar2;
    
    function send_id ( prm_cliente varchar2 default null ) return varchar2;

    function check_id ( prm_chave varchar2 default null, prm_cliente varchar2 default null ) return varchar2 ; 

    function tipo_ambiente ( prm_cd_cliente varchar2  default null ) return varchar2; 

END SCH;
