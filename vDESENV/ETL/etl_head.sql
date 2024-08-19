create or replace PACKAGE ETL  is

function ret_comando_param ( prm_comando  varchar2, 
                             prm_parte    number   ) return varchar2 ;  

function ret_conexao_param ( prm_id_conexao     varchar2, 
                             prm_step_id        varchar2, 
                             prm_cd_parametro   varchar2) return varchar2;

function prn_a_status  (prm_status varchar2) return varchar2 ; 

procedure etl_fix ( prm_cod  varchar2 default null,
					prm_tipo varchar2 default 'run' );

procedure menu_etl (prm_menu      varchar2,
					prm_tipo      varchar2 default null,
					prm_id_copia  varchar2 default null) ; 
-------------------------------------------------------------------------------------------------------
procedure etl_conexoes_list ;
procedure etl_conexoes_valida (prm_acao           varchar2, 
								prm_campo          varchar2, 
								prm_conteudo       varchar2,
								prm_retorno    out varchar2 ) ;  
procedure etl_conexoes_insert ( prm_parametros    	 varchar2, 
								prm_conteudos    	 varchar2 ) ;  
procedure etl_conexoes_update ( prm_id_conexao    varchar2, 
								prm_cd_parametro  varchar2,
								prm_conteudo      varchar2 ) ;
procedure etl_conexoes_delete ( prm_id_conexao    varchar2 ) ; 

procedure etl_conexoes_teste (prm_id_conexao   in varchar2 ); 

-------------------------------------------------------------------------------------------------------
procedure etl_step_list (prm_step_id  varchar2 default null,
						 prm_order    varchar2 default '1',
						 prm_dir      varchar2 default '1') ; 
procedure etl_step_insert (prm_step_id        varchar2,
						   prm_tipo_execucao  varchar2,
						   prm_tipo_comando   varchar2,
						   prm_id_conexao     varchar2,
						   prm_tbl_destino    varchar2,
						   prm_id_copia       varchar2 default null) ;  
procedure etl_step_update (prm_step_id       varchar2, 
						   prm_cd_parametro  varchar2,
						   prm_conteudo      varchar2 ) ;
procedure etl_step_comando_update ( prm_step_id     varchar2, 
                             	    prm_coluna      varchar2,
									prm_parametros  varchar2 ) ;
procedure etl_step_delete (prm_step_id       varchar2 ) ;
-------------------------------------------------------------------------------------------------------
procedure etl_fila_list (prm_tp       varchar2 default null,
						 prm_id       varchar2 default null,
						 prm_order    varchar2 default null, 
                         prm_dir      varchar2 default null,
						 prm_linhas	  varchar2 default '50'); 
-------------------------------------------------------------------------------------------------------
procedure etl_run_list (prm_order    varchar2 default '2', 
                        prm_dir      varchar2 default '1'); 
procedure etl_run_insert (prm_ds_run varchar2) ;  
procedure etl_run_update (prm_run_id        varchar2, 
                          prm_cd_parametro  varchar2,
						  prm_conteudo      varchar2 ) ;
procedure etl_run_delete (prm_run_id        varchar2 ) ;			
-------------------------------------------------------------------------------------------------------
procedure etl_schedule_list(prm_run_id     varchar2); 
procedure etl_schedule_insert (prm_run_id        varchar2,
							   prm_p_semana      varchar2,
						   	   prm_p_mes         varchar2,
							   prm_p_hora        varchar2, 
						   	   prm_p_quarter     varchar2,
                               prm_p_dia_mes     varchar2) ; 
procedure etl_schedule_update ( prm_schedule_id   varchar2, 
                           	    prm_cd_parametro  varchar2,
						   	    prm_conteudo      varchar2 ); 
procedure etl_schedule_delete (prm_schedule_id varchar2 ) ;		
-------------------------------------------------------------------------------------------------------
procedure etl_run_step_list(prm_run_id     varchar2);
procedure etl_run_step_insert (prm_run_id        varchar2,
                               prm_ordem         varchar2,
						       prm_step_id       varchar2);
procedure etl_run_step_update ( prm_run_step_id   varchar2, 
                           	    prm_cd_parametro  varchar2,
						   	    prm_conteudo      varchar2 ) ; 
procedure etl_run_step_delete ( prm_run_step_id   varchar2 ) ; 

-------------------------------------------------------------------------------------------------------								
procedure etl_step_param_list(prm_step_id     varchar2) ; 
procedure etl_step_param_update ( prm_step_id       varchar2, 
                            	  prm_cd_parametro  varchar2,
								  prm_campo         varchar2, 
						   	      prm_conteudo      varchar2 );  

-------------------------------------------------------------------------------------------------------								
procedure etl_run_param_list(prm_run_id     varchar2); 
procedure etl_step_param_insert (prm_step_id        varchar2,
                         	     prm_cd_parametro   varchar2,
								 prm_ds_parametro   varchar2 ); 
procedure etl_run_param_update ( prm_run_id        varchar2, 
                           	     prm_cd_parametro  varchar2,
								 prm_campo         varchar2, 
						   	     prm_conteudo      varchar2 ) ; 
procedure etl_step_param_delete (prm_step_id      varchar2,
                                 prm_cd_parametro varchar2) ; 

-------------------------------------------------------------------------------------------------------								
procedure etl_log_list(prm_tp       varchar2,
                       prm_id       varchar2,
					   prm_linhas   varchar2 default '50'); 

procedure etl_run_exec (prm_run_id      varchar2,
                        prm_run_step_id varchar2 default null); 

procedure etl_run_stop (prm_run_id  varchar2);

procedure etl_step_comando ( prm_step_id  varchar2, 
                             prm_coluna   varchar2) ; 


END ETL;