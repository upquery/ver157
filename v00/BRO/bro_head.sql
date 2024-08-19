create or replace package BRO  is

    /*procedure direct ( prm_objeto varchar2 default null,
                     prm_screen varchar2 default null );*/

	procedure browser ( prm_objeto varchar2 default null, prm_screen varchar2 default null );

	procedure check_taux_bro (prm_objeto varchar2 default null,
							  prm_tabela varchar2 default null,
							  prm_coluna varchar2 default null,
							  prm_valor  varchar2 default null);

	procedure browserButtons  ( prm_tipo varchar2 default null,
	                            prm_visao varchar2 default null,
	                            prm_chave varchar2 default null,
								prm_coluna varchar2 default null );

	procedure browserExclude ( prm_chave varchar2 default null,
                               prm_campo varchar2 default null,
	                           prm_visao varchar2 default null );

	procedure browserEdit ( prm_obj    varchar2 default null,
	                        prm_chave  varchar2 default null,
							prm_campo  varchar2 default null,
                            prm_tabela varchar2 default null );
	
	procedure browserEditCLOB ( prm_obj    varchar2 default null,
	                            prm_chave  varchar2 default null,
							    prm_campo  varchar2 default null,
                                prm_coluna varchar2 default null );							

	procedure browserEditLine ( prm_tabela        varchar2 default null,
								prm_chave         varchar2 default null,
								prm_campo         varchar2 default null,
								prm_nome          IN owa_util.vc_arr,
								prm_conteudo      IN owa_util.vc_arr,
								prm_ant           IN owa_util.vc_arr,
                                prm_tipo          in owa_util.vc_arr,
                                prm_obj           varchar2 default null );

	procedure browserNewLine (  prm_tabela        varchar2 default null,
								prm_chave         varchar2 default null,
								prm_coluna        varchar2 default null,
								prm_nome          IN owa_util.vc_arr,
								prm_conteudo      IN owa_util.vc_arr,
                                prm_tipo          in owa_util.vc_arr,
                                prm_ident         varchar2 default null,
                                prm_sequence      varchar2 default 'false',
                                prm_obj           varchar2 default null );

	procedure browserEditColumn ( prm_obj           varchar2 default null,
								  prm_screen        varchar2 default null,  
	                              prm_tabela        varchar2 default null,
								  prm_campo_chave   varchar2 default null,
							  	  prm_chave         varchar2 default null,
								  prm_tipo          varchar2 default null,
								  prm_campo         varchar2 default null,
								  prm_conteudo      varchar2 default null) ;

	procedure browserMask ( prm_valor varchar2 default null, 
							prm_coluna varchar2 default null, 
							prm_visao  varchar2 default null, 
							prm_tipo   varchar2 default null );
	
	procedure browser_permissao ( prm_micro_data varchar2 default null,
	                              prm_coluna     varchar2 default null,
	                              prm_valor      varchar2 default null );
								  
	procedure dt_pagination ( prm_micro_data varchar2 default null,
	                          prm_coluna     varchar2 default null,
	                          prm_objid      varchar2 default null,
							  prm_chave      varchar2 default null,
                              prm_ordem      varchar2 default null,
	                          prm_screen     varchar2 default null,
	                          prm_limite     number   default 10,
							  prm_origem     number   default 0,
							  prm_direcao    varchar2 default '>',
	                          prm_busca      varchar2 default null,
							  prm_condicao   varchar2 default null,
							  prm_acumulado  varchar2 default null );

	procedure browserConfig ( prm_microdata varchar2 default null );

	procedure browserConfig_alter ( prm_microdata     varchar2 default null,
									prm_coluna        varchar2 default null,
									prm_rotulo        varchar2 default null,
									prm_mascara       varchar2 default null,
									prm_ligacao       varchar2 default 'SEM',
                                    prm_chave         number default 0,
									prm_branco        varchar2 default null,
									prm_default       varchar2 default null,
									prm_alinhamento   varchar2 default 'left',
									prm_invisivel     varchar2 default 'N',
									prm_formula       varchar2 default null,
									prm_tipo          varchar2 default 'N',
									prm_alignds       varchar2 default 'left',
									prm_tipoinput     varchar2 default 'text',
									prm_tamanho       varchar2 default null,
									prm_validacao     varchar2 default null,
									prm_ordem         number   default 99,
									prm_input_browser varchar2 default 'N', 
									prm_acao_botao    varchar2 default null, 
									prm_permissao     varchar2 default 'R',
									prm_acao          varchar2 default 'update',
									prm_largura       varchar2 default null,
                                    prm_recarregar    varchar2 default 'N' ,
									prm_multi_input   varchar2 default 'N');

  

    procedure anexo ( prm_chave varchar2 default null );

    PROCEDURE PUT_LINHA  ( prm_tabela           varchar2 default null,
                                         prm_chave            varchar2 default null,
                                         prm_campo           varchar2 default null,
                                         prm_nome             owa_util.vc_arr,
                                         prm_conteudo         owa_util.vc_arr,
                                         prm_conteudo_ant     owa_util.vc_arr,
                                         prm_tipo             owa_util.vc_arr,
                                         prm_status           out varchar2,
                                         prm_obj              varchar2 default null
                                       );

    PROCEDURE GET_LINHA  ( prm_tabela    varchar2 default null,
                       prm_chave      varchar2 default null,
                       prm_coluna     varchar2 default null,
                       prm_conteudo   out DBMS_SQL.CLOB_TABLE,
                       prm_obj        varchar2 default null,
					   prm_col_select varchar2 default null );

    PROCEDURE NEW_LINHA  (  prm_tabela   varchar2 default null,
	                        prm_chave    varchar2 default null,
	                        prm_coluna   varchar2 default null,
	                        prm_conteudo owa_util.vc_arr,
	                        prm_tipo     owa_util.vc_arr,
	                        prm_status   out varchar2,
                            prm_obj      varchar2 default null);

    procedure get_total ( prm_microdata varchar2 default null,
	                      prm_objid     varchar2 default null,
	                      prm_screen    varchar2 default null,
	                      prm_condicao  varchar2 default null,
	                      prm_coluna    varchar2 default null,
	                      prm_chave     varchar2 default null,
	                      prm_ordem     varchar2 default '1',
	                      prm_busca     varchar2 default null  );

    procedure menu ( prm_objeto varchar2 default null );

	procedure main_data ( prm_objid        varchar2 default null,
						  prm_coluna       varchar2 default null,
						  prm_microdata    varchar2 default null,
						  prm_screen       varchar2 default 'DEFAULT',
						  prm_condicao     varchar2 default 'semelhante' );

	procedure properties ( prm_id varchar2 );

	procedure exec_button_column ( prm_objeto       varchar2 default null,
								   prm_tabela       varchar2 default null,
								   prm_campo_chave  varchar2 default null,
								   prm_chave        varchar2 default null, 
								   prm_campo        varchar2 default null, 		
						           prm_acao         varchar2 default null ) ;
	
	function permissao_edit ( prm_objeto      varchar2 default null, 
							  prm_permissao   varchar2 default null,
							  prm_usuario     varchar2 default null ) return varchar2; 

	procedure alter_attrib_geral(prm_cd_object varchar2,
								 prm_cd_prop   varchar2 );
	procedure monta_select_option (prm_objid                varchar2, 
    	                       	   prm_cd_coluna            varchar2, 
								   prm_valor                varchar2 default null,
							   	   prm_html_option   in out clob ) ; 


end BRO;