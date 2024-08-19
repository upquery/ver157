create or replace package FUN is

	TP_VARCHAR2_TABLE DBMS_SQL.VARCHAR2_TABLE;

    FUNCTION RET_LIST (	prm_condicoes varchar2 default null,
					    prm_lista	out	DBMS_SQL.VARCHAR2_TABLE ) return varchar2;
					
	FUNCTION VPIPE ( prm_entrada varchar2,
                     prm_divisao varchar2 default '|' ) return CHARRET pipelined;

	FUNCTION VPIPE2 ( prm_entrada varchar2,
                      prm_divisao varchar2 default '|' ) return CHARRET2 pipelined;

	FUNCTION VPIPE_CLOB ( prm_entrada clob,
                          prm_divisao varchar2 default '|' ) return CHARRET pipelined ; 
  
	function ret_var ( prm_variavel varchar2 default null, prm_usuario varchar2 default 'DWU' ) return varchar2;
	
	function getSessao  ( prm_cod varchar2 default null ) return varchar2;

	procedure setSessao ( prm_cod   varchar2 default null,
                          prm_valor varchar2 default null,
                          prm_data  date     default null );
	
	procedure SET_VAR  ( PRM_VARIAVEL   VARCHAR2 DEFAULT NULL,
                     prm_conteudo   varchar2 default null,
                     PRM_USUARIO    VARCHAR2 DEFAULT 'DWU' );

    function GVALOR( prm_objeto 	  varchar2 default null, 
		             prm_screen 	  varchar2 default null, 
					 prm_usuario 	  varchar2 default null,
					 prm_formatar     varchar2 default 'N',
					 prm_param_filtro varchar2 default null ) return varchar2;
	
	FUNCTION CHECK_BLINK ( prm_objeto    varchar2 default null,
                       prm_coluna    varchar2 default null,
                       prm_conteudo  varchar2 default null,
                       prm_original  varchar2 default null,
                       prm_screen    varchar2 default null,
                       prm_usuario   varchar2 default null,
					   prm_pre_suf_alias varchar2 default null,
					   prm_ar_colref DBMS_SQL.VARCHAR2_TABLE default TP_VARCHAR2_TABLE,
					   prm_ar_colval DBMS_SQL.VARCHAR2_TABLE default TP_VARCHAR2_TABLE) return char;

	procedure blink_condition ( prm_condicao  in  varchar2,
								prm_valor     in  varchar2,
								prm_conteudo  in  varchar2,
								prm_cor_fundo in  varchar2,
								prm_cor_fonte in  varchar2,
								ws_saida      out varchar2,
								ws_cor_fundo  out varchar2,
								ws_cor_fonte  out varchar2,
								prm_original  in  varchar2);
	
	FUNCTION CHECK_BLINK_TOTAL ( prm_objeto   varchar2 default null,
                                 prm_coluna   varchar2 default null,
                                 prm_conteudo varchar2 default null,
                                 prm_original varchar2 default null,
                                 prm_screen   varchar2 default null,
								 prm_pre_suf_alias varchar2 default null,
								 prm_ar_colref DBMS_SQL.VARCHAR2_TABLE default TP_VARCHAR2_TABLE,
					   			 prm_ar_colval DBMS_SQL.VARCHAR2_TABLE default TP_VARCHAR2_TABLE ) return char;
	
	FUNCTION CHECK_BLINK_LINHA ( prm_objeto   varchar2 default null,
                                 prm_coluna   varchar2 default null,
                                 prm_linha    varchar2 default null,
                                 prm_conteudo varchar2 default null,
                                 prm_screen   varchar2 default null,
								 prm_pre_suf_alias varchar2 default null,
								 prm_ar_colref DBMS_SQL.VARCHAR2_TABLE default TP_VARCHAR2_TABLE,
					   			 prm_ar_colval DBMS_SQL.VARCHAR2_TABLE default TP_VARCHAR2_TABLE ) return varchar2;
	
    FUNCTION WACESSO ( prm_who varchar2 default 'ALL') return CHARRET pipelined;

    FUNCTION WHO return varchar;	
	
	FUNCTION GPARAMETRO ( prm_parametro varchar2 default null, 
                          prm_desc      varchar2 default 'N',
                          prm_screen    varchar2 default null,
	                      prm_usuario   varchar2 default null,
						  prm_valida    varchar2 default 'N' ) return varchar2;
	
	function gformula2 ( prm_micro_visao  varchar2 default null,
	                     prm_coluna       varchar2 default null,
	                     prm_screen       varchar2 default null,
	                     prm_inside       varchar2 default 'N',
	                     prm_objeto       varchar2 default null,
                         prm_inicio       varchar2 default null,
                         prm_final        varchar2 default null,
						 prm_formula      varchar2 default null,
						 prm_valida       varchar2 default 'N',
						 prm_conexao_jet  varchar2 default null ) return varchar2;

	function gformula_browser ( prm_micro_data  varchar2 default null,
    	                        prm_coluna      varchar2 default null,
        	                    prm_screen      varchar2 default null) return varchar2; 

	FUNCTION GFORMULA ( prm_texto        varchar2 default null,
						prm_micro_visao  varchar2 default null,
						prm_agrupador    varchar2 default null,
						prm_inicio       varchar2 default 'NO',
						prm_final        varchar2 default 'NO',
						prm_screen       varchar2 default null,
						prm_recurs       varchar2 default null,
						prm_flexcol      varchar2 default 'N',
						prm_flexend      varchar2 default 'N' ) return varchar2;

	
	FUNCTION URL_DEFAULT ( prm_parametros	in  long,
					       prm_micro_visao	in  long,
					       prm_agrupadores	in out long,
					       prm_coluna		in out long,
					       prm_rp		    in out long,
					       prm_colup		in out long,
					       prm_comando		in  long,
					       prm_mode		    in out long ) return varchar2;

    FUNCTION VALOR_PONTO (  prm_parametros   varchar2 default null,
						    prm_micro_visao	 varchar2 default null,
						    prm_objeto		 varchar2 default null, 
						    prm_screen       varchar2 default null,
							prm_usuario		 varchar2 default null ) return char;	

    
    FUNCTION CDESC ( prm_codigo char  default null,
	                 prm_tabela char default null,
	                 prm_reverse boolean default false ) return varchar2;		

    FUNCTION GETPROP ( prm_objeto  varchar2,
					   prm_prop    varchar2,
					   prm_screen  varchar2 default 'DEFAULT',
                       prm_usuario varchar2 default 'DWU',
                       prm_tipo    varchar2 default null ) return varchar2 RESULT_CACHE;

	function getProps (  prm_objeto  varchar2,
						 prm_tipo    varchar2,
						 prm_prop    varchar2,
						 prm_usuario varchar2 default 'DWU',
                         prm_screen  varchar2 default null  ) return arr RESULT_CACHE;	

    FUNCTION PUT_STYLE ( prm_objeto    varchar2,
					     prm_prop      varchar2,
					     prm_tp_objeto varchar2,
					     prm_value     varchar2 default null ) return varchar2 RESULT_CACHE;	

    FUNCTION RET_SINAL ( prm_objeto    varchar2,
					     prm_coluna    varchar2,
					     prm_conteudo  varchar2 ) return varchar2;	

    FUNCTION PUT_PAR ( prm_objeto     varchar2,
					   prm_prop       varchar2,
					   prm_tp_objeto  varchar2,
					   prm_owner      varchar2 default null ) return varchar2;

    FUNCTION COL_NAME (	prm_cd_coluna   varchar2 default null,
						prm_micro_visao varchar2,
						prm_condicao	varchar2 default '',
						prm_conteudo	varchar2,
						prm_color varchar2 default '#000000',
						prm_title varchar2 default 'Filtro do drill',
						prm_repeat boolean default false,
						prm_agrupado varchar2 default null ) return varchar;

    FUNCTION check_user ( prm_usuario varchar2 default user ) return boolean;

	FUNCTION check_app_permission (prm_usuario varchar2 default user) return boolean;		
	
	FUNCTION VCALC ( prm_cd_coluna   varchar2,
				     prm_micro_visao varchar2 ) return boolean;
	
	FUNCTION XCALC ( prm_cd_coluna    varchar2, 
                     prm_micro_visao  varchar2, 
                     prm_screen       varchar2 ) return varchar2;
	
	FUNCTION XEXEC (  ws_content  varchar2 default null, 
	                  prm_screen  varchar2 default null, 
					  prm_atual   varchar2 default null, 
					  prm_ant     varchar2 default null ) return varchar2;
	
	FUNCTION SETEM ( prm_str1 varchar2,
				     prm_str2 varchar2 ) return boolean;
	
    function isnumber ( prm_valor varchar2 default null ) return boolean;

	function isnumber_sem_decimal (prm_valor varchar2 default null ) return boolean;
		
	FUNCTION IFMASCARA ( str1 in varchar2,
						 cmascara varchar2,
						 prm_cd_micro_visao varchar2 default '$[no_mv]',
						 prm_cd_coluna varchar2 default '$[no_co]',
						 prm_objeto varchar2 default '$[no_ob]',
						 prm_tipo varchar2 default 'micro_coluna',
						 prm_formula varchar2 default null,
						 prm_screen  varchar2 default null,
						 prm_usuario varchar2 default null ) return varchar2;

	function mascaraJs ( prm_mascara varchar2, prm_tipo varchar2 default 'texto' ) return varchar2;
	
	FUNCTION UM ( prm_coluna  varchar2 default '$[no_co]',
                  prm_visao   varchar2 default '$[no_ob]',
                  prm_content varchar2 default null,
                  prm_um      varchar2 default null ) return varchar2;
		
	FUNCTION IFNOTNULL ( str1 in varchar2, str2 in varchar2 ) return varchar2;
	
	FUNCTION VERIFICA_DATA ( chk_data varchar default null ) return varchar2;
	
	FUNCTION R_GIF ( prm_gif_nome  varchar2 default null,
                     prm_type      varchar2 default 'GIF',
                     prm_location  varchar2 default 'LOCAL' ) return varchar2;
	
	FUNCTION SUBPAR ( prm_texto        varchar2 default null, 
		              prm_screen       varchar2 default null, 
		              prm_desc         varchar2 default 'Y',
					  prm_usuario  	   varchar2 default null,
					  prm_param_filtro varchar2 default null,
					  prm_valida       varchar2 default 'N') return varchar2;
	
	FUNCTION CALL_DRILL ( prm_drill varchar default 'N', 
						  prm_parametros long,
						  prm_screen long,
						  prm_objid char default null,
						  prm_micro_visao char default null,
						  prm_coluna char default null,
						  prm_selected number default 1,
						  prm_track varchar2 default null, 
						  prm_objeton varchar2 default null ) return clob;
	
	FUNCTION NOME_COL ( prm_cd_coluna   varchar2,
                        prm_micro_visao varchar2, 
                        prm_screen      varchar2 default null ) return varchar2;

	
	FUNCTION MAPOUT ( prm_parametros   varchar2 default null,
					  prm_micro_visao  char default null,
					  prm_coluna       char default null,
					  prm_agrupador    char default null,
					  prm_mode         char default 'NO',
					  prm_objeto       varchar2 default null,
					  prm_screen       varchar2 default null,
					  prm_colup        varchar2 default null ) return varchar2;
					  
	
	FUNCTION VPIPE_PAR ( prm_entrada varchar ) return TAB_PARAMETROS pipelined;
	
	FUNCTION SHOW_FILTROS ( prm_condicoes    varchar2 default null,
							prm_cursor       number   default 0,
							prm_tipo         varchar2 default 'ATIVO',
							prm_objeto       varchar2 default null,
							prm_micro_visao  varchar2 default null,
							prm_screen       varchar2 default null,
							prm_usuario varchar2 default null ) return varchar2;
							
	FUNCTION show_destaques ( prm_condicoes   varchar2 default null,
							  prm_cursor      number   default 0,
							  prm_tipo        varchar2 default 'ATIVO',
							  prm_objeto      varchar2 default null,
							  prm_micro_visao varchar2 default null,
							  prm_screen      varchar2 default null,
                          	  prm_usuario     varchar2 default null ) return varchar2;
	
	FUNCTION PUT_VAR ( prm_variavel varchar2 default null,
                       prm_conteudo varchar2 default null )  return varchar2;
	
	FUNCTION CHECK_SYS  return varchar2;
	
	FUNCTION RCONDICAO ( prm_variavel varchar) return char;
	
	function dcondicao ( prm_variavel varchar2 default null ) return varchar2;

	function vpcondicao ( prm_variavel varchar2 default null ) return varchar2;
	
	FUNCTION CONVERT_PAR  ( prm_variavel  varchar2,
                            prm_aspas     varchar2 default null,
						    prm_screen    varchar2 default null,
							prm_pre_suf_alias varchar2 default null,
	                        prm_ar_colref DBMS_SQL.VARCHAR2_TABLE default TP_VARCHAR2_TABLE,
    	                    prm_ar_colval DBMS_SQL.VARCHAR2_TABLE default TP_VARCHAR2_TABLE ) return varchar2;
	
	FUNCTION SUBVAR ( prm_texto varchar2 default null) return varchar2;
	
	FUNCTION CHECK_NETWALL ( prm_user  varchar2 default null,
							 prm_ip    varchar2 default null ) return boolean;
	
	FUNCTION APPLY_DRE_MASC ( prm_masc   varchar default null,
                              prm_string varchar default null ) return varchar2;
	
	PROCEDURE EXECUTE_NOW ( prm_comando  varchar2 default null,
                        	prm_repeat  varchar2 default  'S' );
	
	FUNCTION GL_CALCULADA ( prm_texto        varchar2 default null,
                            prm_cd_coluna    varchar2 default null,
                            prm_vl_agrupador varchar2 default null,
							prm_tabela       varchar2 default null ) return varchar2;
	
	FUNCTION LIST_POST ( Prm_Objeto     Varchar2 Default Null,
                         Prm_Parametros Varchar2 Default Null,
					     prm_group      varchar2 default null ) Return TAB_MENSAGENS pipelined;
	
	FUNCTION LIST_ALL_POST ( Prm_Parametros Varchar2 Default Null,
                             prm_group      varchar2 default null ) Return TAB_MENSAGENS pipelined;
	
	FUNCTION VERIFICA_POST ( Prm_Objeto     Varchar2 Default Null,
                             Prm_Parametros Varchar2 Default Null ) Return boolean;
	
	FUNCTION EXT_MASC ( prm_value varchar2 default null ) return varchar2;
	
	FUNCTION INIT_TEXT_POST return number;
	
	FUNCTION CHECK_PERMISSAO ( prm_OBJETO varchar2 DEFAULT NULL, PRM_USUARIO VARCHAR2 DEFAULT NULL) return CHAR;
	
	FUNCTION c2b( p_clob IN CLOB ) RETURN BLOB;
	
	FUNCTION NSLOOKUP ( PRM_ENDERECO varchar default null ) return varchar2;
	
	FUNCTION LANG ( prm_texto varchar2 default null ) return varchar2;
	
	FUNCTION GET_TRANSLATOR ( prm_texto        varchar2,
                              prm_origem_lang  varchar2,
                              prm_destino_lang varchar2 ) return varchar2;

	function ret_par ( prm_sessao varchar2 ) return varchar2;
	
	FUNCTION UTRANSLATE ( prm_cd_coluna varchar2,
						  prm_tabela    varchar2,
						  prm_default   varchar2,
                          prm_padrao    varchar2 default 'PORTUGUESE' ) return varchar2;
	
	FUNCTION LIST_VIEW ( prm_tipo char default null ) return varchar2;
	
	FUNCTION CONVERT_CALENDAR ( prm_valor varchar2 default null,
                                prm_tipo varchar2 default null ) return varchar2;
	
	FUNCTION XFORMULA ( prm_texto  varchar2 default null, 
                        prm_screen varchar2 default null,
                        prm_space  varchar2 default 'N' ) return varchar2;
	
	FUNCTION URLENCODE ( p_str in varchar2 ) return varchar2;

	
	FUNCTION CHECK_ROTULOC ( prm_coluna varchar2 default null,
                             prm_visao varchar2 default null,
						     prm_screen varchar2 default null,
                             prm_ordem  varchar2 default 'inversa' ) return varchar2;

	
	FUNCTION CONV_TEMPLATE ( prm_micro_visao varchar2 default null,
                             prm_agrupadores varchar2 default null ) return VARCHAR2;
	
	FUNCTION B2C ( p_blob blob ) return clob;
	
	FUNCTION CLEAR_PARAMETRO ( prm_parametros varchar2 default null ) return clob;
	
	FUNCTION CHECK_SESSION return varchar2;
	
	function send_id ( prm_cliente varchar2 default null ) return varchar2;
	
	function check_id ( prm_chave varchar2 default null, prm_cliente varchar2 default null ) return varchar2;
	
	function check_token ( prm_chave varchar2 default null, prm_cliente varchar2 default null ) return varchar2;

	function gen_id return varchar2 ;  -- Usado no novo integrador de carga de dados exec_integrador 
	
	function showtag ( prm_obj varchar2 default null,
                       prm_tag varchar2 default null,
				       prm_outro varchar2 default null ) return varchar2;
	
	function check_value ( prm_valor varchar2 default null ) return varchar2;
	
	function ptg_trans ( prm_texto in varchar2 ) return varchar2;
	
	function html_trans ( prm_texto in clob ) return clob;
	
	function excluir_dash ( prm_objeto varchar2 default null ) return varchar2;
	
	function check_admin ( prm_permissao varchar2 default null ) return boolean;

    function get_sequence ( prm_tabela varchar2 default null,
                            prm_coluna varchar2 default null ) return number;

    function get_sequence_max ( prm_tabela varchar2 default null,
                            prm_coluna varchar2 default null ) return number;
    
    function attrib_temporeal ( prm_atrib varchar2 default null, 
	                            prm_obj   varchar2 default null ) return varchar2;
								
	function error_response ( prm_error varchar2 default null ) return varchar2;
						
    /*create or replace TYPE "TAB_PIPE" As Table Of PIPE_ORDER

      create or replace TYPE "PIPE_ORDER"  AS OBJECT
            ( VALOR VARCHAR2(4000), ORDEM NUMBER )	*/	

	function check_screen_access ( prm_screen  varchar2 default null, 
                                   prm_usuario varchar2 default null, 
                                   prm_admin   varchar2 default null ) return number;

    function vpipe_order ( prm_entrada varchar2,
                           prm_divisao varchar2 default '|' ) return tab_pipe pipelined;	

    
	function av_columns ( prm_obj        varchar2 default null,
                          prm_screen     varchar2 default null,
					      prm_condicoes  varchar2 default null ) return varchar2;
						  
	function test_columns ( prm_valor  varchar2 default null,
                            prm_tabela varchar2 default null,
						    prm_visao  varchar2 default null ) return varchar2;
	
	function get_qdata ( prm_dimensoes   varchar2 default null,
                         prm_medidas     varchar2 default null,
                         prm_filtros     varchar2 default null,
                         prm_micro_visao varchar2 default null ) return varchar2;

	function create_user ( username         in varchar2, 
					       password         in varchar2,
					       prm_referencia   in varchar2 default null,
					       prm_email        in varchar2,
					       prm_completo     in varchar2  ) return varchar2;

	function remove_user ( prm_usuario varchar2 ) return varchar2;

	function converte( prm_texto varchar2 default null ) return varchar2;

	function nomeObjeto( prm_objeto varchar2 default null ) return varchar2;

	function usuario return varchar2;

	--function pwd_vrf(username in varchar2, password in varchar2 ) return char;

	function randomCode( prm_tamanho number default 10) return varchar2;

	function objCode ( prm_alias varchar2 default null ) return varchar2;

	function objCode2 ( prm_alias varchar2 default null ) return varchar2;

	function testDigestedPassword( prm_usuario varchar2, prm_password varchar2 ) return varchar2;

	function digestPassword( prm_usuario varchar2, prm_password varchar2 ) return varchar2;

	function validaPassword( prm_usuario varchar2, prm_password varchar2 ) return varchar2;

	function conv_data( prm_data varchar2) return date;

	function vpipe_n (prm_param varchar2,
                  prm_idx   number,
                  prm_pipe  varchar2 default '|' ) return varchar2; 

	function pagina_html_aviso (prm_texto varchar2,
								prm_tipo  varchar2 default null) return varchar2; 
								
	function converte_json( prm_texto varchar2 default null ) return varchar2; 

	function check_endereco_email ( prm_email varchar2 default null ) return varchar2 ;

	function replace_binds_clob ( prm_query clob     default null, 
    	                          prm_binds varchar2 default null ) return clob ; 

	function ret_svg ( prm_nome   varchar2  default null ) return varchar2; 

	function lista_padrao_ds ( prm_cd_lista varchar2, 
    	                       prm_cd_item  varchar2 ) return varchar2 ; 

	procedure valida_formula (prm_tipo            in varchar2 default 'COLUNA',
	                          prm_formula         in varchar2 default null,
							  prm_screen          in varchar2 default null,
							  prm_objeto          in varchar2 default null,
							  prm_visao           in varchar2 default null,
                              prm_coluna          in varchar2 default null,
       	                      prm_retorno        out varchar2 ) ; 

	function user_permissao (prm_usuario         in varchar2,
	                         prm_permissao       in varchar2 ) return varchar2 ;  

	function get_cd_obj (prm_objeto   in varchar2) return varchar2 ;

	procedure modal_txt_sup (prm_txt in varchar2) ; 
	procedure log_exec_atu (prm_acao            varchar2 default 'INSERT',
							prm_log_exec        varchar2 default 'D',
							prm_id_exec  in out varchar2, 
                        	prm_cd_obj          varchar2 default null,
                        	prm_usuario         varchar2 default null,
                        	prm_tp_exec         varchar2 default null,
                        	prm_sq_exec         integer  default null,
                        	prm_ds_exec         varchar2 default null,
                        	prm_query           clob     default null) ; 
	procedure atu_traducao_colunas (prm_tabela          varchar2,
    	                            prm_coluna          varchar2,
        	                        prm_tipo            varchar2,
            	                    prm_linguagem       varchar2,
                	                prm_texto           varchar2,
                    	            prm_lang_default    varchar2 ) ;
	function conv_jet_comando (prm_comando  clob) return clob ;

	function lista_objetos_tela (prm_screen varchar2) return varchar2;

end FUN;
