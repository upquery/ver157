create or replace PACKAGE ETF  is

--- Cópia da FUN ----------------------------------------------------------------

function randomCode( prm_tamanho number default 10) return varchar2;

function cdesc ( prm_codigo char  default null,
					prm_tabela char default null,
					prm_reverse boolean default false ) return varchar2;		

function ret_var ( prm_variavel varchar2 default null, prm_usuario varchar2 default 'DWU' ) return varchar2;

procedure execute_now ( prm_comando  varchar2 default null,
						prm_repeat  varchar2 default  'S' );

function vpipe ( prm_entrada varchar2,
					prm_divisao varchar2 default '|' ) return charret pipelined;

function vpipe_clob ( prm_entrada clob,
						prm_divisao varchar2 default '|' ) return charret pipelined ; 

function vpipe_par ( prm_entrada varchar ) return tab_parametros pipelined;

function lang ( prm_texto varchar2 default null ) return varchar2;

function xexec ( ws_content  varchar2 default null ) return varchar2;   -- Copia da FUN com simplificações para utilização somente pelo processo de ETL 

function gen_id return varchar2 ; 

function send_id ( prm_cliente varchar2 default null ) return varchar2;

function check_id ( prm_chave varchar2 default null, prm_cliente varchar2 default null ) return varchar2;

function getSessao  ( prm_cod varchar2 default null ) return varchar2;

--- Cópia da GBL ----------------------------------------------------------------

function getLang return varchar2;

function getUsuario return varchar2;

procedure alert_online (p_id            in out number,
                        p_bloco		    varchar2 default null,
                        p_inicio        date     default null,
                        p_fim		    date     default null,
                        p_parametro	    varchar2 default null,
                        p_status 	    varchar2 default null,
                        p_obs	        varchar2 default null,
                        p_st_notify     varchar2 default 'REGISTRO',
                        p_mail_notify   varchar2 default 'N',
                        p_pipe_tabelas  varchar2 default null ); 

--- Funções espefíficas da Extração  ----------------------------------------------------------------

procedure exec_integrador(prm_run_id            in varchar2,
							prm_data_ini          in varchar2 default null,
							prm_data_fim          in varchar2 default null,
							prm_status_fila       in varchar2 default 'A',
							prm_tempo_loop        in number   default 30,
							prm_erro_step        out varchar2) ; 

procedure exec_step_integrador(prm_run_step_id    in varchar2,
							   prm_log_id         in varchar2 default null,
                               prm_step_id        in varchar2 default null,
                               prm_comando        in varchar2 default null,
                               prm_comando_limpar in varchar2 default null,
   							   prm_retorno       out clob, 
							   prm_status        out varchar2 ) ; 

procedure exec_schdl;

procedure exec_run (prm_run_id      varchar2,
					prm_run_step_id varchar2 default null);

procedure exec_run_step ( prm_run_step_id varchar2,
						  prm_log_id      varchar2,
						  prm_unico       varchar2 default 'N');

procedure exec_step (prm_run_step_id   in  varchar2,
					 prm_log_id        in  varchar2,
                     prm_retorno       out clob,
					 prm_status        out varchar2) ; 

procedure exec_param_substitui (prm_run_id          in varchar2, 
								prm_run_step_id     in varchar2,
								prm_step_id         in varchar2,
                                prm_comando     in out varchar2,
                                prm_parametros  in out varchar2,
                                prm_erro        in out varchar2 ) ; 

procedure stop_run (prm_run_id          varchar2,
                    prm_retorno  in out varchar2);

procedure etl_atu_status ( prm_tipo   varchar2, 
	                       prm_id     varchar2,
                           prm_status in out varchar2 ) ; 

procedure etl_log_gera ( prm_tipo         varchar2,
						 prm_log_id       varchar2,
	                     prm_run_id       varchar2,
						 prm_run_step_id  varchar2 default 0, 
						 prm_step_id      varchar2 default null,  
						 prm_ordem        number,						 
						 prm_status       varchar2, 
						 prm_data         date,  
						 prm_ds           varchar2 default null ) ;  

procedure etl_run_param_atu(prm_run_id varchar2) ; 						 

procedure etl_envio_status; 

procedure usuarios_set_status ( prm_usu_nome            varchar2 default null,
						        prm_id_usuario_externo  varchar2 default null,
							    prm_status              varchar2 default null, 
								prm_erro_retorno  out varchar2 ) ;


procedure job_remove (prm_job_id   varchar2) ; 

procedure canc_step_tempo_limite; 

procedure envia_log ;

function etl_fila_processa(prm_servico      varchar2,
                           prm_comando      varchar2) return varchar2 ;

END ETF;