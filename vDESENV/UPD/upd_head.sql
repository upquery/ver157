create or replace package  UPD  is
    -- >>>>>>>------------------------------------------------------------------------
    -- >>>>>>> Aplicação:	AUTO UPDATE
    -- >>>>>>> Por:		Upquery
    -- >>>>>>> Data:	06/08/2020
    -- >>>>>>> Pacote:	UPD
    -- >>>>>>>------------------------------------------------------------------------

    function AutoUpdate_permissao ( prm_usuario        varchar2) return varchar2 ;

    procedure AutoUpdate_atu_parametros ( prm_sistema     varchar2,
                                          prm_usuario     varchar2 )  ;

    procedure AutoUpdate_check_atualizacoes (prm_sistema     varchar2 default null,
                                             prm_versao      varchar2 default null,
                                             prm_usuario     varchar2 default null,
                                             prm_tp_atualiza varchar2 default 'ATUALIZA');

    procedure AutoUpdate_baixa_conteudo (prm_sistema     varchar2,
                                         prm_versao      varchar2,
                                         prm_usuario     varchar2,
                                         prm_tipo        varchar2,
                                         prm_nome        varchar2,
                                         prm_chamada     varchar2 default 'BANCO',
                                         prm_tp_atualiza varchar2 default 'ATUALIZA' ) ;

    procedure autoUpdate_baixa_clob (prm_url            varchar2, 
                                     prm_sistema        varchar2, 
                                     prm_versao         varchar2, 
                                     prm_usuario        varchar2,
                                     prm_tipo           varchar2, 
                                     prm_nome           varchar2, 
                                     prm_msg     in out varchar2,
                                     prm_clob    in out clob ) ; 

    procedure autoUpdate_baixa_blob ( prm_url            varchar2, 
                                      prm_sistema        varchar2, 
                                      prm_versao         varchar2, 
                                      prm_usuario        varchar2,
                                      prm_tipo           varchar2, 
                                      prm_nome           varchar2, 
                                      prm_msg     in out varchar2,
                                      prm_blob    in out blob ) ;  

    procedure autoUpdate_baixa_atu_avisos (prm_url            varchar2, 
                                           prm_sistema        varchar2, 
                                           prm_versao         varchar2, 
                                           prm_usuario        varchar2,
                                           prm_tipo           varchar2, 
                                           prm_nome           varchar2, 
                                           prm_msg     in out varchar2 ) ;  

    procedure AutoUpdate_atu_sistema  (prm_usuario      varchar2 default 'DWU',
                                       prm_tipo         varchar2 default 'TODOS',
                                       prm_nome         varchar2 default 'TODOS' ,
                                       prm_tp_atualiza  varchar2 default 'ATUALIZA',                                    
                                       prm_chamada      varchar2 default 'BANCO' ) ;

    procedure autoUpdate_atu_PACKAGE (prm_id_atu         number, 
                                      prm_tipo           varchar2, 
                                      prm_nome           varchar2, 
                                      prm_msg     in out varchar2 ) ; 

    procedure autoUpdate_atu_ARQUIVO (prm_id_atu         number, 
                                      prm_tipo           varchar2, 
                                      prm_nome           varchar2, 
                                      prm_msg     in out varchar2 ) ;  

    procedure autoUpdate_atu_PLSQL (prm_id_atu         number, 
                                    prm_tipo           varchar2, 
                                    prm_nome           varchar2, 
                                    prm_msg     in out varchar2 ) ;  

    procedure autoUpdate_CIDADES_ESTADOS  (prm_sistema        varchar2 default 'BI',
                                           prm_versao         varchar2 default null, 
                                           prm_usuario        varchar2,
                                           prm_tipo           varchar2,
                                           prm_chamada        varchar2 default 'BANCO' ) ; 

    procedure AutoUpdate_job_baixa    (prm_sistema  varchar,
                                       prm_versao   varchar2,
                                       prm_usuario  varchar2 ) ;

    procedure AutoUpdate_job_atualiza (prm_sistema      varchar,
                                       prm_versao       varchar2,
                                       prm_usuario      varchar2,
                                       prm_tp_atualiza  varchar2 default 'ATUALIZA' ) ; 

    procedure AutoUpdate_job_manutencao (prm_sistema  varchar,
                                         prm_versao   varchar2,
                                         prm_usuario  varchar2 ) ; 

    procedure AutoUpdate_atualiza_bi;  

    procedure AutoUpdate_atualiza_pkg (prm_package varchar2) ;

    procedure AutoUpdate_envia_log (prm_usuario  varchar2) ;


    procedure AutoUpdate_log  (prm_id        number, 
                               prm_tp_atu    varchar2, 
                               prm_tipo      varchar2,
                               prm_nome      varchar2, 
                               prm_situacao  varchar2, 
                               prm_msg       varchar2,
                               prm_usuario   varchar2 );

    procedure AutoUpdate_mata_sessao ( prm_tipo           varchar2, 
                                       prm_nome           varchar2, 
                                       prm_usuario        varchar2,
                                       prm_tipo_sessao    varchar2, 
                                       prm_msg     in out varchar2) ;

    function autoUpdate_existe_pendencia ( prm_tp_atu   varchar2, 
                                           prm_tipo     varchar2 default 'TODOS', 
                                           prm_nome     varchar2 default 'TODOS' ) return varchar2 ; 

    procedure recompila_inativos  (prm_usuario      varchar2 default 'DWU') ;

    function c2b ( p_clob IN CLOB ) return blob;

    function ret_var  ( prm_variavel   varchar2 default null, 
                        prm_usuario    varchar2 default 'DWU' ) return varchar2;

    function vpipe_clob ( prm_entrada clob,
                          prm_divisao varchar2 default '|' ) return CHARRET pipelined ;

    function vpipe_n (prm_param varchar2,
                      prm_idx   number,
                      prm_pipe  varchar2 default '|' ) return varchar2 ; 

    function ret_param_nome (prm_param varchar2, prm_nome varchar2, prm_pipe varchar2 default '|') return varchar2 ; 

    procedure execute_now ( prm_comando  varchar2 default null,
                            prm_repeat  varchar2 default  's' ) ; 

    function tipo_ambiente ( prm_cd_cliente varchar2  default null ) return varchar2;                             

end UPD;
