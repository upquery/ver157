create or replace package OBJ  is

    procedure menu ( prm_objeto  varchar2 default null,
                          prm_screen  varchar2 default null,
                          prm_posicao varchar2 default null,
                          prm_posy    varchar2 default null,
                          prm_posx    varchar2 default null );

    procedure float_par ( prm_objeto varchar2 default null );

    procedure image ( prm_objeto      varchar2 default null,
                  prm_propagation varchar2 default null,
				  prm_screen      varchar2 default null,
				  prm_drill       varchar2 default null,
				  prm_nome        varchar2 default 'N/A',
				  prm_posicao     varchar2 default null,
				  prm_posy        varchar2 default null,
				  prm_posx        varchar2 default null );

    procedure float_filter ( prm_objeto varchar2 default null );


	procedure valor ( prm_objeto      varchar2 default null,
                      prm_drill       varchar2 default null,
                      prm_desc        varchar2 default null,
                      prm_visao       varchar2 default null,
                      prm_parametros  varchar2 default null,
                      prm_propagation varchar2 default null,
                      prm_screen      varchar2 default null,
                      prm_posx        varchar2 default null,
                      prm_posy        varchar2 default null,
                      prm_posicao     varchar2 default null,
                      prm_usuario     varchar2 default null,
					  prm_track       varchar2 default null,
					  prm_cd_goto     varchar2 default null );


    procedure ponteiro ( prm_objeto      varchar2 default null,
                         prm_drill       varchar2 default null,
                         prm_desc        varchar2 default null,
                         prm_visao       varchar2 default null,
                         prm_parametros  varchar2 default null,
                         prm_propagation varchar2 default null,
                         prm_screen      varchar2 default null,
                         prm_posx        varchar2 default null,
                         prm_posy        varchar2 default null,
                         prm_posicao     varchar2 default null,
                         prm_usuario     varchar2 default null,
						 prm_track       varchar2 default null,
						 prm_cd_goto 	 varchar2 default null );


    procedure grafico ( prm_objeto      varchar2 default null,
                        prm_drill       varchar2 default null,
                        prm_desc        varchar2 default null,
                        prm_visao       varchar2 default null,
                        prm_parametros  varchar2 default null,
                        prm_propagation varchar2 default null,
                        prm_screen      varchar2 default null,
                        prm_posx        varchar2 default null,
                        prm_posy        varchar2 default null,
                        prm_borda       varchar2 default null,
                        prm_posicao     varchar2 default null,
                        prm_dashboard   varchar2 default null,
						prm_usuario     varchar2 default null,
						prm_track       varchar2 default null,
						prm_cd_goto     varchar2 default null );

    procedure mapageoloc (  prm_objeto      varchar2 default null,
							prm_drill       varchar2 default 'N',
							prm_desc        varchar2 default null,
							prm_visao       varchar2 default null,
							prm_parametros  varchar2 default null,
							prm_propagation varchar2 default null,
							prm_screen      varchar2 default null,
							prm_posx        varchar2 default null,
							prm_posy        varchar2 default null,
							prm_borda       varchar2 default null,
							prm_posicao     varchar2 default null,
							prm_dashboard   varchar2 default null,
							prm_usuario     varchar2 default null,
							prm_track       varchar2 default null,
							prm_cd_goto    varchar2 default null );

	procedure mapageoloc_markers (	prm_parametros       varchar2 default null,
									prm_micro_visao      varchar2 default null,
									prm_objeto           varchar2 default null,
									prm_screen           varchar2 default null,
									prm_usuario			 varchar2 default null ) ;

    procedure relatorio ( prm_objeto      varchar2 default null,
                          prm_propagation varchar2 default null,
                          prm_screen      varchar2 default null,
                          prm_drill       varchar2 default null,
                          prm_nome        varchar2 default null,
                          prm_posicao     varchar2 default null,
                          prm_posy        varchar2 default null,
                          prm_posx        varchar2 default null,
						  prm_dashboard   varchar2 default 'false' );


    procedure file ( prm_objeto      varchar2 default null,
                     prm_propagation varchar2 default null,
                     prm_screen      varchar2 default null,
                     prm_drill       varchar2 default null,
                     prm_nome        varchar2 default null,
                     prm_posicao     varchar2 default null,
                     prm_posy        varchar2 default null,
                     prm_posx        varchar2 default null );


    procedure consulta ( prm_parametros	 varchar2 default null,
					 prm_visao       varchar2,
					 prm_coluna	     varchar2 default null,
					 prm_agrupador	 varchar2 default null,
					 prm_rp		     varchar2 default 'ROLL',
					 prm_colup	     varchar2 default null,
					 prm_comando	 varchar2 default 'MOUNT',
					 prm_mode	     varchar2 default 'NO',
					 prm_objeto	     varchar2,
					 prm_screen	     varchar2 default 'DEFAULT',
					 prm_posx	     varchar2 default null,
					 prm_posy	     varchar2 default null,
					 prm_ccount	     varchar2 default '0',
					 prm_drill	     varchar2 default 'N',
					 prm_ordem	     varchar2 default '0',
					 prm_zindex	     varchar2 default 'auto',
					 prm_track       varchar2 default null,
					 prm_objeton     varchar2 default null,
					 prm_self        varchar2 default null,
					 prm_dashboard   varchar2 default 'false',
                     prm_propagation varchar2 default null,
					 prm_usuario     varchar2 default null,
					 prm_cd_goto    varchar2 default null );

    
procedure titulo  ( prm_objeto 		 varchar2 default null,
                    prm_drill  		 varchar2 default null,
					prm_desc   		 varchar2 default null,
					prm_screen 		 varchar2 default null,
					prm_valor  		 varchar2 default null,
					prm_param  		 varchar2 default null,
					prm_usuario 	 varchar2 default null,
					prm_param_filtro varchar2 default null,
					prm_track        varchar2 default null,
					prm_cd_goto     varchar2 default null,
					prm_titulo       in out clob ) ;


procedure opcoes ( prm_objeto  varchar2 default null,
						prm_tipo    varchar2 default null,
						prm_par     varchar2 default null,
						prm_visao   varchar2 default null,
						prm_screen  varchar2 default null,
						prm_drill   varchar2 default null,
						prm_agrup   varchar2 default null,
						prm_colup   varchar2 default null,
						prm_usuario varchar2 default null );

procedure consultaInvertida ( prm_parametros char default '1|1',
			prm_micro_visao   char default null,
			prm_coluna	 	  char default null,
			prm_agrupador	  char default null,
			prm_rp		 	  char default 'ROLL',
			prm_colup	 	  char default null,
			prm_comando       char default 'MOUNT',
			prm_mode	 	  char default 'NO',
			prm_objid	 	  char default null,
			prm_screen		  char default 'DEFAULT',
			prm_posx		  char default null,
			prm_posy		  char default null,
			prm_ccount		  char default '0',
			prm_drill		  char default 'N',
			prm_ordem		  char default '0',
			prm_zindex		  char default 'auto',
			prm_track         varchar2 default null,
            prm_objeton       varchar2 default null,
			prm_dashboard     varchar2 default 'false',
	   	    prm_usuario       varchar2 default null,
			prm_cd_goto      varchar2 default null );

procedure show_objeto ( prm_objeto      varchar2 default null,
						prm_posx	    varchar2 default null,
						prm_posy	    varchar2 default null,
						prm_parametros  clob     default null,
						prm_drill	    varchar2 default 'N',
						prm_out		    varchar2 default 'N',
						prm_zindex	    varchar2 default '2',
						prm_screen      varchar2 default null,
						prm_forcet      varchar2 default null,
						prm_track       varchar2 default null,
						prm_objeton     varchar2 default null,
						prm_alt_med     varchar2 default 'no_change',
						prm_cross       char     default 'T',
						prm_self        varchar2 default null,
						prm_dashboard   varchar2 default 'false',
						prm_usuario     varchar2 default null,
						prm_admin       varchar2 default null,
						prm_cd_goto     varchar2 default null,
						prm_dash_altura number   default null,
						prm_dash_largura number  default null,
						prm_montagem    varchar2 default 'COM DADOS',
            prm_popup_drill varchar2 default 'false'  );

procedure subquery ( prm_objid       varchar2 default null,
					 prm_parametros  varchar2 default '1|1',
					 prm_micro_visao varchar2 default null,
					 prm_coluna	 	 varchar2 default null,  
					 prm_agrupador	 varchar2 default null,
					 prm_rp		 	 varchar2 default 'GROUP',
				 	 prm_colup	 	 varchar2 default null,
				 	 prm_screen		 varchar2 default 'DEFAULT',
				 	 prm_ccount		 char default '0',
				 	 prm_drill		 char default 'N',
				 	 prm_ordem		 number default 1,       
				 	 prm_self        varchar2 default null,
					 prm_usuario     varchar2 default null,
					 prm_cd_goto    varchar2 default null,
           			 prm_popup_drill varchar2 default 'false' ); 

procedure section_submenu (prm_objeto       varchar2,
						   prm_screen       varchar2,
						   prm_zindex	    varchar2) ; 

procedure lista_cidades ( prm_estado varchar2 default null,
							  prm_regiao     varchar2 default null,
                              prm_coluna varchar2 default 'CD',
							  prm_obj    varchar2 default null,
						      prm_screen varchar2 default null,
						      prm_visao  varchar2 default null,
							  prm_parametros varchar2 default null );
	
procedure lista_estados ( prm_estado varchar2 default null,
							prm_regiao     varchar2 default null,
							prm_coluna varchar2 default 'CD',
							prm_obj    varchar2 default null,
							prm_screen varchar2 default null,
							prm_visao  varchar2 default null,
							prm_parametros varchar2 default null );

procedure lista_regioes (   prm_regiao     varchar2 default null,
							prm_coluna    varchar2 default 'CD',
							prm_obj        varchar2 default null,
							prm_screen     varchar2 default null,
							prm_visao      varchar2 default null,
							prm_parametros varchar2 default null );

end OBJ;
