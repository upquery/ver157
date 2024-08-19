create or replace package body OBJ  is

procedure menu ( prm_objeto  varchar2 default null,
                 prm_screen  varchar2 default null,
                 prm_posicao varchar2 default null,
                 prm_posy    varchar2 default null,
                 prm_posx    varchar2 default null ) as

		cursor crs_itens ( prm_usuario varchar2,
		                   prm_admin   varchar2 ) is
		
		select	cll.cd_objeto, nm_objeto, tp_objeto, nm_item,obj.atributos
		from	CALL_LIST CLL
        left join objetos obj on obj.cd_objeto = cll.cd_objeto
        left join call_name on call_name.cd_objeto = cll.cd_objeto
		where	cll.cd_list = prm_objeto and (
		    cll.cd_objeto not in ( select cd_objeto from OBJECT_RESTRICTION where (USUARIO = prm_usuario and st_restricao = 'I') or (prm_admin = 'A' and st_restricao = 'X') ) 
		    or
			( 
			cll.cd_objeto not in ( select cd_objeto from OBJECT_RESTRICTION where USUARIO = prm_usuario and st_restricao = 'I' ) and
			cll.cd_objeto in ( select cd_objeto from OBJECT_RESTRICTION where (prm_admin = 'A' and st_restricao = 'X') or (USUARIO = prm_usuario and st_restricao = 'L') ) 
			)

		)
		order by ordem, nm_objeto;

	    ws_itens	crs_itens%rowtype;
		--
		ws_titulo	varchar2(400);
		ws_tipo     varchar2(40);
		ws_usuario  varchar2(80);
	    ws_admin    varchar2(80);
		ws_padrao   varchar2(80) := 'PORTUGUESE';
		WS_ATT      VARCHAR2(500);
		WS_URL      VARCHAR2(500);
		WS_ALT      VARCHAR2(80);
begin

    ws_usuario := gbl.getUsuario;
	ws_admin   := gbl.getNivel;

	begin
        select CONTEUDO into ws_padrao
        from   PARAMETRO_USUARIO
        where  cd_usuario = ws_usuario and
               cd_padrao='CD_LINGUAGEM';
    exception
        when others then
            ws_padrao := 'PORTUGUESE';
    end;

    htp.p('<div class="dragme pro6" id="'||prm_objeto||'" title="'||prm_objeto||'" data-top="'||prm_posy||'" data-left="'||prm_posx||'" class="dragme pro6">');
		
	select nm_objeto into ws_titulo
	from OBJETOS
	where cd_objeto = prm_objeto and tp_objeto = 'CALL_LIST';

	if ws_admin = 'A' then
		htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options closed" id="'||prm_objeto||'more">');
	   		htp.p('<span class="preferencias" title="'||fun.lang('Propriedades')||'"></span>');
			htp.p('<span class="lightbulb" title="'||fun.lang('Lista do Menu')||'"></span>');
			htp.p('<span>');
				fcl.button_lixo('dl_obj', prm_objeto => prm_objeto);
			htp.p('</span>');
		htp.p('</span>');
		
	    htp.p('<h2>'||fun.utranslate('NM_OBJETO', prm_objeto, ws_titulo, ws_padrao)||'</h2>');
	else
	    htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options closed" id="'||prm_objeto||'more" style="max-width: 26px;">');
			htp.p('<span class="lightbulb" title="'||fun.lang('Lista do Menu')||'"></span>');
		htp.p('</span>');
		htp.p('<h2>'||fun.utranslate('NM_OBJETO', prm_objeto, ws_titulo, ws_padrao)||'</h2>');
	end if;
		
		htp.p('<ul id="space-options">');
		    WS_URL:=''||nvl(fun.ret_var('OWNER_BI'),'DWU')||'.fcl.download_tab?prm_arquivo=';
			WS_ALT := '&prm_alternativo=';
		
			open crs_itens(ws_usuario, ws_admin);
				loop
				fetch crs_itens into ws_itens;
				exit when crs_itens%notfound;

				IF WS_ITENS.ATRIBUTOS <> 'N/A' AND WS_ITENS.TP_OBJETO <> 'RELATORIO' THEN
				    WS_ATT :=  'download="'||WS_ITENS.ATRIBUTOS||'" href="'||WS_URL||WS_ITENS.ATRIBUTOS||WS_ALT||'"';
				END IF;

					ws_tipo := ws_itens.tp_objeto;

					if ws_tipo = 'SCRIPT' then
						htp.p('<li class="SCRIPT" id="'||ws_itens.cd_objeto||'menu"><a onclick="appendar('''||nvl(fun.ret_var('OWNER_BI'),'DWU')||'.obj.show_objeto?prm_objeto='||ws_itens.cd_objeto||'&PRM_ZINDEX=2&prm_posx=100px&prm_posy=100px&prm_screen=''+tela, '''', false); setTimeout(function(){ remover(''script-load''); }, 10000);">'||nvl(ws_itens.nm_item, ws_itens.nm_objeto)||'</a></li>');
					
					ELSIF WS_TIPO ='FILE' THEN
					    HTP.P('<li class="'||WS_TIPO||'" id="'||WS_ITENS.CD_OBJETO||'menu"><a href="'||nvl(fun.ret_var('OWNER_BI'),'DWU')||'.fcl.download_tab?prm_arquivo='||WS_ITENS.ATRIBUTOS||'">'||WS_ITENS.NM_OBJETO||'</a>');
					ELSE

						if trim(ws_itens.nm_item) <> '''' then
							htp.p('<li class="'||ws_tipo||'" id="'||ws_itens.cd_objeto||'menu"><a>'||fun.subpar(ws_itens.nm_item, prm_screen)||'</a></li>');
						else
							htp.p('<li class="'||ws_tipo||'" id="'||ws_itens.cd_objeto||'menu"><a>'||fun.subpar(fun.utranslate('NM_OBJETO', ws_itens.cd_objeto, ws_itens.nm_objeto, ws_padrao), prm_screen)||'</a></li>');
						end if;
					end if;
				end loop;
			close crs_itens;

		htp.p('</ul>');

	htp.p('</div>');

end menu;

procedure float_par ( prm_objeto varchar2 default null ) as
begin

    htp.p('<div onmousedown="event.stopPropagation();" class="dragme" id="'||prm_objeto||'"></div>');

end float_par;

procedure float_filter ( prm_objeto varchar2 default null ) as
begin

    htp.p('<div onmousedown="event.stopPropagation();" class="dragme" id="'||prm_objeto||'"></div>');

end float_filter;

procedure image ( prm_objeto      varchar2 default null,
                  prm_propagation varchar2 default null,
				  prm_screen      varchar2 default null,
				  prm_drill       varchar2 default null,
				  prm_nome        varchar2 default 'N/A',
				  prm_posicao     varchar2 default null,
				  prm_posy        varchar2 default null,
				  prm_posx        varchar2 default null ) as
		
	ws_atributos 		varchar2(4000);
	ws_ds_objeto 		varchar2(4000);
	ws_nome				varchar2(4000);

	ws_bgcolor	  		varchar2(80);
	ws_largura    		varchar2(80);	
	ws_maxheight   		varchar2(80);	
	ws_props_borda 		varchar2(80);
    ws_borda            varchar2(80);
    ws_prop_borda       varchar2(80);

	ws_style           	varchar2(40);
	-- ws_ocultarTitle		varchar2(40);
	ws_classe			varchar2(200);
	ws_scr              varchar2(4000);
	ws_url_arq  	  varchar2(500);
	ws_nm_arq         varchar2(300); 
	ws_nm_arq_tabela  varchar2(300); 
	ws_style_cursor   varchar2(30); 

begin

	select atributos, ds_objeto,nm_objeto 
	  into ws_atributos, ws_ds_objeto, ws_nome
	  from OBJETOS
	 where cd_objeto = prm_objeto;

	ws_bgcolor    := 'background-color: '||fun.getprop(prm_objeto, 'BGCOLOR');
	ws_maxheight  := 'max-height:'||fun.getprop(prm_objeto, 'ALTURA')||'px';
	ws_prop_borda := 'border: 1px solid '||fun.getprop(prm_objeto, 'BORDA_COR');

	if instr(fun.getprop(prm_objeto, 'LARGURA'), '%') > 0 then
		ws_largura := fun.getprop(prm_objeto, 'LARGURA');
	else
		ws_largura := replace(fun.getprop(prm_objeto, 'LARGURA'), 'px', '')||'px';
	end if;

	ws_style_cursor := null; 
	if fun.getprop(prm_objeto,'CHAMADA') is not null or fun.getprop(prm_objeto,'COMANDO') is not null then 
		ws_style_cursor := 'cursor: pointer;'; 
	end if; 
		
	htp.p('<div onmousedown="'||prm_propagation||'" class="dragme icone" id="'||trim(prm_objeto)||'" title="'||trim(prm_objeto)||'" data-top="'||prm_posy||'" data-left="'||prm_posx||'" data-script="'||fun.getprop(prm_objeto,'COMANDO')||'" data-chamada="'||fun.getprop(prm_objeto,'CHAMADA')||'" data-parametros="'||fun.getprop(prm_objeto,'PARAMETROS')||'" style="'||prm_posicao||'; '||ws_props_borda||'; min-width: 52px;">');	
		htp.prn('<style> 
			div#'||trim(prm_objeto)||' { min-width: 52px; }
			img#'||trim(prm_objeto)||'_gr { 
				'||ws_prop_borda||';'||ws_bgcolor||';'||ws_maxheight||'; height: auto;
				display: block; margin: 0 auto; max-width: '||ws_largura||';
				'||ws_style_cursor||' 
				'||fun.put_style(prm_objeto, 'BGCOLOR', 'ICONE')||'
			 }
			span#'||trim(prm_objeto)||'_ds { 
			');
			if fun.getprop(prm_objeto,'DISPLAY_TITLE') = 'N' then   -- Mostra o Título 
				htp.prn('
					color: '||fun.getprop(prm_objeto, 'TIT_COLOR')||'; 
					font-style: '||fun.getprop(prm_objeto, 'TIT_IT')||'; 
					font-weight: '||fun.getprop(prm_objeto, 'TIT_BOLD')||';
					font-family: '||fun.getprop(prm_objeto, 'TIT_FONT')||';
					font-size: '||fun.getprop(prm_objeto, 'TIT_SIZE')||'; 
					background-color: '||fun.getprop(prm_objeto, 'TIT_BGCOLOR')||';
					text-align: '||fun.getprop(prm_objeto, 'ALIGN_TIT')||';  					
					position: relative; z-index: 1; margin: 4px 0px; display: block; text-decoration: none;
				');
			else
				
				if gbl.getnivel = 'A' THEN		
					htp.prn('position: relative; z-index: 1; margin-top: -8px; display: block; letter-spacing: -2px; font-size: 12px;');
				else 
					htp.prn('font-size:0px;');	
				end if;	
				-- htp.prn('font-size:0.1px;');	
			end if;

			-- htp.prn('position: relative; z-index: 1; margin: 4px 0px;'||ws_ocultarTitle||' text-decoration: none; ');
			if  gbl.getNivel = 'A' then
				htp.prn('cursor: move;');
				ws_classe := 'wd_move';
			end if;	
		htp.prn('} </style>');	

		if (fun.getprop(prm_objeto, 'DISPLAY_TITLE') = 'S') then -- Ocultar título 
			if  gbl.getNivel = 'A' then
				htp.p('<span class="'||ws_classe||'" id="'||prm_objeto||'_ds">===</span>');
			end if;	
		else
			htp.p('<span class="'||ws_classe||', drill_N degrade_S" id="'||prm_objeto||'_ds">'||PRM_NOME||'</span>');
		end if;

		/***** 
		if (nvl(prm_nome,'N/A')<>'N/A') then
			if (fun.getprop(prm_objeto, 'DISPLAY_TITLE') = 'S') then -- Ocultar título 
				ws_ocultarTitle := 'display: block;';
				htp.p('<span class="'||ws_classe||'" id="'||prm_objeto||'_ds" style="letter-spacing: -3px;">===</span>');
			else
				ws_ocultarTitle := 'display: block;';
				htp.p('<span class="'||ws_classe||'" id="'||prm_objeto||'_ds">'||PRM_NOME||'</span>');
			end if;
		else
			ws_ocultarTitle := 'display: block;';
			htp.p('<span class="'||ws_classe||'" id="'||prm_objeto||'_ds" style="letter-spacing: -3px;">===</span>');
		end if;
		****/ 

		ws_url_arq       := substr(ws_atributos,1,instr(ws_atributos,'=')); 
		ws_nm_arq        := substr(ws_atributos,instr(ws_atributos,'=')+1, 1000); 
		ws_nm_arq        := lower(fun.subpar(ws_nm_arq, prm_screen));

		ws_nm_arq_tabela := null; 

		select max(name) into ws_nm_arq_tabela 
		  from tab_documentos 
		 where lower(name) = lower(ws_nm_arq)
		   and usuario     = 'DWU'; 
		if ws_nm_arq_tabela is null then 
			ws_nm_arq_tabela := ws_nm_arq;
		end if;   
		ws_scr := ws_url_arq||ws_nm_arq_tabela; 

		htp.p('<div class="container" style="position: relative;">');
			obj.opcoes(prm_objeto, 'IMAGE', '', '', prm_screen, prm_drill);	

			if gbl.getNivel= 'A' then
				--htp.p('<img src = "'||ws_scr||'" id="'||prm_objeto||'_gr" class="wd_move" onclick="sos('''||prm_objeto||''');"/>');
				htp.p('<img src = "'||ws_scr||'" id="'||prm_objeto||'_gr" class="wd_move" onclick="sos('''||prm_objeto||''');"/>');
			else
				htp.p('<img src = "'||ws_scr||'" id="'||prm_objeto||'_gr" onclick="sos('''||prm_objeto||''');"/>');
			end if;	
		htp.p('</div>');	
	htp.p('</div>');


end image;

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
				  prm_cd_goto     varchar2 default null ) as

	ws_mascara         varchar2(100);
	ws_unidade         varchar2(100);
	ws_formula         varchar2(1000);
	ws_gradiente       varchar2(200);
	ws_complemento     varchar2(32000);
	ws_gradiente_t     varchar2(200);
	ws_subtitulo       varchar2(2000)  := ' ';
	ws_tip             varchar2(100);
	ws_alinhamento_tit varchar2(100);
	ws_goto            varchar2(200);
	ws_filtro          varchar2(32000);
	ws_class           varchar2(100);
	ws_usuario         varchar2(80);
	ws_admin           varchar2(20);
	ws_count           number;   
	ws_valor_ponto     varchar2(400);
	ws_valor_abrev     varchar2(400);
	ws_valor_um        varchar2(80);
	ws_valor_meta      varchar2(80);

	ws_prop_align_tit    varchar2(40);
	ws_prop_altura       varchar2(40);
	ws_prop_bg           varchar2(80);
	ws_prop_borda		 varchar2(40);
	ws_prop_degrade      varchar2(40);
	ws_prop_degrade_tipo varchar2(40);
	ws_prop_largura      varchar2(40);
	ws_prop_radius       varchar2(40);
	ws_radius_img        varchar2(40);
	ws_radius_content    varchar2(40);
	ws_prop_tit_bg       varchar2(40);
	ws_prop_size         varchar2(40);
	ws_prop_bold         varchar2(40);
	ws_prop_color        varchar2(40);
	ws_prop_imgopt       varchar2(40);
	ws_prop_font         varchar2(40);
	ws_prop_it           varchar2(40);
	ws_prop_abreviacao	 varchar2(40);
	ws_blink             varchar2(4000);
	ws_aplica_destaque   varchar2(40);
	ws_largura_valor	 varchar2(10);
	WS_MSG_DADOS		 VARCHAR2(100);
	ws_valor_masc		 varchar2(400);
	ws_titulo_html       clob;
    ws_obj_html          varchar2(200);	
	ws_objeto            varchar2(200);

	ws_arr arr;

	ws_error             exception;

begin

    ws_usuario := prm_usuario;
    if ws_usuario is null then    
        ws_usuario := gbl.getUsuario;
    end if;

	if nvl(ws_usuario, 'N/A') = 'N/A' then
        ws_usuario := gbl.getUsuario;
	end if;

	if  prm_drill = 'Y' then
		ws_objeto   := fun.get_cd_obj(prm_objeto);
		ws_obj_html := ws_objeto||'trl'||prm_cd_goto;
	else
		ws_obj_html := prm_objeto;
		ws_objeto   := prm_objeto;
	end if;

    ws_arr := fun.getProps(ws_objeto, 'VALOR', 'ALTURA|APLICA_DESTAQUE|BGCOLOR|BOLD|BORDA_COR|COLOR|DEGRADE|DEGRADE_TIPO|FONT|IMG_OPTION|IT|LARGURA|NO_RADIUS|SIZE|TIT_BGCOLOR', 'DWU', prm_screen);

    ws_prop_altura       := ws_arr(1);
	ws_aplica_destaque   := ws_arr(2);
	ws_prop_bg           := ws_arr(3);
	ws_prop_bold         := ws_arr(4);
	ws_prop_borda        := ws_arr(5);
	ws_prop_color        := ws_arr(6);
	ws_prop_degrade      := ws_arr(7);
	ws_prop_degrade_tipo := ws_arr(8);
	ws_prop_font         := ws_arr(9);
	ws_prop_imgopt       := ws_arr(10);
	ws_prop_it           := ws_arr(11);
	ws_prop_largura      := ws_arr(12);
	ws_prop_radius       := ws_arr(13);
	ws_prop_size         := ws_arr(14);
	ws_prop_tit_bg       := ws_arr(15);

    ws_complemento := '';

	begin

		select nm_mascara, nm_unidade, formula 
		  into ws_mascara, ws_unidade, ws_formula
		  from MICRO_COLUNA
		 where cd_micro_visao = prm_visao 
		   and cd_coluna = substr(prm_parametros, 1 ,instr(prm_parametros,'|')-1);

	exception when others then
		raise ws_error;
	end;

	select count(*) into ws_count 
	  from column_restriction 
	 where usuario = user 
	   and cd_micro_visao = prm_visao 
	   and cd_coluna 
	    in (select column_value 
	          from table(fun.vpipe(prm_parametros)));
	
	-- select count(*) into ws_count_meta from micro_coluna where cd_coluna = replace(replace(ws_valor_meta, '$[', ''), ']', '') and CD_MICRO_VISAO = prm_visao;

	ws_valor_ponto := fun.valor_ponto(prm_parametros, prm_visao, ws_objeto, prm_screen,prm_usuario => ws_usuario );
	ws_valor_meta  := fun.CONVERT_PAR(NVL(fun.getprop(trim(ws_objeto),'META'),'N/A'), prm_screen => prm_screen);
	
	if ws_count = 0 then

		/* removendo propriedades para teste */
		--name="'||prm_screen||'"

		ws_largura_valor := fun.getprop(ws_objeto,'LARGURA_VALOR');

		htp.p('<div data-borda="" onmousedown="'||prm_propagation||'" id="'||trim(ws_obj_html)||'" data-swipe="" data-top="'||prm_posy||'" data-left="'||prm_posx||'" data-visao="'||prm_visao||'" class="dragme dados">');

			if trim(ws_prop_degrade) = 'S' or ws_prop_imgopt = 'S' then
				if nvl(ws_prop_degrade_tipo, '%??%') = '%??%' then
					ws_gradiente_t := 'linear';
				else
					ws_gradiente_t := ws_prop_degrade_tipo;
				end if;
				ws_gradiente := 'background: '||ws_gradiente_t||'-gradient('||ws_prop_tit_bg||', '||ws_prop_bg||');';
			else
				ws_gradiente := 'background-color: '||ws_prop_bg||';';
			end if;

			IF NVL(WS_LARGURA_VALOR,'AUTO') <> 'AUTO' THEN
				WS_LARGURA_VALOR:='width:'||WS_LARGURA_VALOR||';';
			ELSE
				WS_LARGURA_VALOR:='';
			END IF;


			--ESTILO SEPARADO DA CAMADA DE HTML
			htp.prn('<style> 
			div#'||trim(ws_obj_html)||' { 
				white-space: nowrap; 
				border: 1px solid '||ws_prop_borda||'; 
				'||prm_posicao||';
				'||WS_LARGURA_VALOR||'
				'||ws_gradiente||'
			}
			div#dados_'||trim(ws_obj_html)||', ul#'||ws_obj_html||'-filterlist {
				display: none;
			}');
		
			if ws_prop_radius <> 'N' then
				htp.prn('
				div#'||ws_obj_html||', div#'||ws_obj_html||'_ds, div#'||ws_obj_html||'_fakeds { 
					border-radius: 0 !important; 
				} 
				div#'||ws_obj_html||' span#'||ws_obj_html||'more { 
					border-radius: 0 0 0 6px; 
				} 
				a#'||ws_obj_html||'fechar { 
					border-radius: 0 0 0 6px; 
				} 
				div#'||ws_obj_html||'_vl { 
					border-radius: 0; 
				}');
			
			end if;

			if ws_prop_imgopt = 'S' then
				htp.prn('
				div#'||ws_obj_html||' div.img_container img {
					max-width: 100%; 
					border-radius: '   ||fun.getprop(ws_objeto,'IMG_RADIUS')||'; 
					height: '          ||fun.getprop(ws_objeto,'IMG_ALTURA')||'; 
					width: '           ||fun.getprop(ws_objeto,'IMG_LARGURA')||'; 
					background-color: '||fun.getprop(ws_objeto,'IMG_BGCOLOR')||'; 
					border: 1px solid '||fun.getprop(ws_objeto,'IMG_BORDA')||'; 
					padding: '         ||fun.getprop(ws_objeto,'IMG_ESPACAMENTO')||';
				}');
			end if;


			htp.prn('
			span#'||ws_obj_html||'_ds { 
				position: relative;
				z-index: 1;
				margin-top: -8px; 
				letter-spacing: -2px; 
				font-size: 12px;
			}
			div#ctnr_'||ws_obj_html||' {
				max-width: inherit; 
				min-width: inherit; 
				width:  '||ws_prop_largura||'px; 
				height: '||ws_prop_altura||'px;
			}
		
			div#'||ws_obj_html||'_vl {
				cursor: pointer;
				font-size: '  ||ws_prop_size||';
				color: '      ||ws_prop_color||'; 
				font-style: ' ||ws_prop_it||'; 
				font-weight: '||ws_prop_bold||'; 
				font-family: '||ws_prop_font||';
				');
				if /*nvl(fun.getprop(prm_objeto,'META'), 'N/A')*/  ws_valor_meta <> 'N/A' then
					htp.prn('border-radius: 0 !important;');
				else
					if ws_prop_imgopt = 'S' then
						htp.prn('border-radius: 5px 0 5px 0;');
					end if;	
				end if;
				if substr(trim(fun.put_style(ws_objeto, 'DEGRADE', ws_tip)), 5, 1) <> 'S' and ws_prop_imgopt <> 'S' then
					htp.prn('background-color: '||ws_prop_bg||';');
				end if;
			htp.prn('}');

			-- ||fun.check_blink(prm_objeto, substr(prm_parametros, 1 ,instr(prm_parametros,'|')-1), NVL(ws_valor_ponto, 'N/A'), ws_prop_color)||
			 
			--estilo do meta
			if /* nvl(fun.getprop(prm_objeto,'META'), 'N/A')*/  ws_valor_meta <> 'N/A' then
				htp.prn('div#'||ws_obj_html||'_mt {
					border-radius: 0 0 5px 5px; 
					padding: 2px; 
					text-align: center;
					color: '||ws_prop_color||'; 
					font-style: '||ws_prop_it||'; 
					font-weight: '||ws_prop_bold||'; 
					font-family: '||ws_prop_font||'; 
					font-size: 10px;');
				begin
					-- Aplica o mesmo destaque do valor - 22/07/2022 
					htp.prn(fun.check_blink(ws_objeto, substr(prm_parametros, 1 ,instr(prm_parametros,'|')-1), NVL(ws_valor_ponto, 'N/A'), fun.put_style(prm_objeto, 'COLOR', 'VALOR')));
					/* if ws_count_meta <> 0 then
						htp.prn(fun.check_blink(prm_objeto, substr(prm_parametros, 1 ,instr(prm_parametros,'|')-1), NVL(ws_valor_ponto, 'N/A'), fun.put_style(prm_objeto, 'COLOR', 'VALOR')));
					else
						htp.prn(fun.check_blink(prm_objeto, substr(prm_parametros, 1 ,instr(prm_parametros,'|')-1), NVL(ws_valor_meta, 'N/A'), fun.put_style(prm_objeto, 'COLOR', 'VALOR')));
					end if;
					*/ 
				exception when others then
					htp.prn(fun.check_blink(ws_objeto, substr(prm_parametros, 1 ,instr(prm_parametros,'|')-1), NVL(ws_valor_meta, 'N/A'), fun.put_style(ws_objeto, 'COLOR', 'VALOR')));
				end;
			end if;
			htp.prn('</style>');


			select count(*) into ws_count from goto_objeto where cd_objeto = trim(ws_objeto);

			htp.p('<div id="dados_'||ws_obj_html||'" data-tipo="VALOR" data-swipe="" data-visao="'||prm_visao||'" data-width="'||ws_prop_largura||'" data-height="'||ws_prop_altura||'" data-top="'||prm_posy||'" data-left="'||prm_posx||'" data-drill="'||ws_count||'" data-cd_goto="'||prm_cd_goto||'"></div>');

			obj.opcoes(ws_obj_html, 'VALOR', prm_parametros, prm_visao, prm_screen, prm_drill, prm_usuario => ws_usuario);

			htp.prn('<ul id="'||ws_obj_html||'-filterlist">');
				htp.prn(fun.show_filtros(prm_parametros, '', '', ws_objeto, prm_visao, prm_screen, prm_usuario => ws_usuario));
			htp.prn('</ul>');

			htp.prn('<ul id="'||ws_obj_html||'-destaquelist" style="display: none;" >');
				htp.prn(fun.show_destaques(prm_parametros, '', '', ws_objeto, prm_visao, prm_screen, prm_usuario => ws_usuario));
			htp.prn('</ul>');

			if nvl(ws_aplica_destaque,' ') not in ('valor','ambos') then 
				ws_blink := ' ';
			else    
				ws_blink := fun.check_blink(ws_objeto, substr(prm_parametros, 1 ,instr(prm_parametros,'|')-1), NVL(ws_valor_ponto, 'N/A'), ws_prop_color, prm_screen, ws_usuario);
			end if; 

			if nvl(ws_blink, 'N/A') = 'N/A' then
				ws_blink := ' ';
			end if;

			if ws_prop_radius = 'N' then
				ws_radius_img := 'border-radius: 6px 0 0 6px; ';
				ws_radius_content := 'border-radius: 0 6px 6px 0; ';
			else
				ws_radius_img := null;
				ws_radius_content := null;
			end if;
		
			if fun.getprop(ws_objeto,'IMG_OPTION') = 'S' then

				if nvl(ws_aplica_destaque,' ') in ('valor','ambos') then 
					htp.p('<div class="img_container" style="'||ws_radius_img||ws_blink||' margin: auto;">');
						htp.p('<img src="'||fun.getprop(ws_objeto,'IMG')||'" />');
					htp.p('</div>');

					htp.p('<div class="data_container '||ws_class||'" style="'||ws_radius_content||ws_blink||'">');
				else
					htp.p('<div class="img_container">');
						htp.p('<img src="'||fun.getprop(ws_objeto,'IMG')||'" />');
					htp.p('</div>');

					htp.p('<div class="data_container '||ws_class||'">');

				end if;
			else 
				htp.p('<div class="data_container '||ws_class||'">');
			end if;

				obj.titulo(ws_objeto, prm_drill, prm_desc, prm_screen, ws_valor_ponto, prm_parametros, ws_usuario, null, prm_track => prm_track, prm_cd_goto => prm_cd_goto, prm_titulo => ws_titulo_html);
				htp.p(ws_titulo_html);

				ws_count       := 0;
				ws_complemento := '';

				
				-- ABREVIAÇÃO NUMÉRICA, RECEBE O VLR, TESTA ONDE SE ENCAIXA, NO FIM RETIRA O PONTO ,SUBSTITUI POR VIRGULA E ARREDONDA O RESULTADO PARA 2 CASAS ---

				
				ws_valor_abrev := ws_valor_ponto; 
				if fun.getprop(ws_objeto,'ABREVIACAO') = 'S' then

					if abs(ws_valor_abrev) >1000000000000 then
						ws_valor_abrev:=round(ws_valor_abrev/1000000000000,2)|| ' T';

					elsif  abs(ws_valor_abrev) >1000000000 then
						ws_valor_abrev:=round(ws_valor_abrev/1000000000,2)|| ' B';

					elsif abs(ws_valor_abrev) >1000000 then
						ws_valor_abrev:=round(ws_valor_abrev/1000000,2)|| ' M';

					elsif abs(ws_valor_abrev) >1000 then
						ws_valor_abrev:=round(ws_valor_abrev/1000,2)|| ' K';

					else
						ws_valor_abrev:=round(ws_valor_abrev,2);

					end if;

					ws_valor_abrev:=replace(ws_valor_abrev,'.',',');

				end if;				

				begin

					for i in(select rtrim(cd_coluna)||'|'||decode(rtrim(condicao),'IGUAL','$[IGUAL]','DIFERENTE','$[DIFERENTE]','MAIOR','$[MAIOR]','MENOR','$[MENOR]','MAIOROUIGUAL','$[MAIOROUIGUAL]','MENOROUIGUAL','$[MENOROUIGUAL]','LIKE','$[LIKE]','NOTLIKE','$[NOTLIKE]','$[IGUAL]')||trim(conteudo) as coluna from FILTROS where micro_visao = prm_visao and cd_objeto = ws_objeto and tp_filtro = 'objeto' and condicao not in ('NOFLOAT', 'NOFILTER')) loop
						ws_filtro := i.coluna||'|'||ws_filtro;
					end loop;

					ws_complemento := ' data-filtro="'||ws_filtro||'" onclick="get(''drill_go'').value = ''''; drillfix(event, '''||ws_obj_html||''', this.getAttribute(''data-filtro''));"';
				
				exception when others then
					
					if gbl.getNivel = 'A' then 
						insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - ESTRUTURA - objeto|visao|coluna:'||prm_objeto||'|'||prm_visao||'|'||substr(prm_parametros, 1 ,instr(prm_parametros,'|')-1) , ws_usuario, 'ERRO');
						commit;
						htp.p('Erro montando filtros para abertura da Drill, verifique o log de erros do sistema');
					end if;
				end;

				if /*nvl(fun.getprop(prm_objeto,'META'), 'N/A')*/ ws_valor_meta <> 'N/A' then
					htp.p('<div id="ctnr_'||ws_obj_html||'" class="block-fusion"></div>');
				end if;

				ws_msg_dados := nvl(fun.getProp(ws_objeto,'ERR_SD'),'N/A');

				--atribuido para não fazer mais de uma chamada da função, valor com mascara/abreviação numérica
				ws_valor_masc:= NVL(fun.ifmascara(ws_valor_abrev, rtrim(ws_mascara), prm_visao, substr(prm_parametros, 1 ,instr(prm_parametros,'|')-1), ws_objeto, '', ws_formula, prm_screen, ws_usuario), ws_msg_dados);
				ws_valor_um := fun.getprop(trim(ws_objeto),'UM');
				
				if ws_valor_um is null then
					ws_valor_masc := fun.UM(substr(prm_parametros, 1 ,instr(prm_parametros,'|')-1),prm_visao, ws_valor_masc);
				else
					ws_valor_masc:= fun.um(null,null,ws_valor_masc,ws_valor_um);

				end if;

				htp.p('<div class="valor" id="'||ws_obj_html||'_vl" '||ws_complemento||' title="'||ws_valor_masc||'">');   --ws_valor_ponto 

					htp.prn(ws_valor_masc);
					
				htp.p('</div>');


                if nvl(ws_aplica_destaque,' ') in ('valor','ambos') then 
					htp.prn('<style> div#'||ws_obj_html||'_vl { '||ws_blink||'; } </style>');
				end if;

				--if ws_count_meta <> 0 then  - 22/07/2022 
				--	ws_valor_meta := ws_valor_ponto;
				--end if;

				ws_complemento := null;

				if ws_valor_meta <> 'N/A' then
					ws_complemento := fun.ifmascara(ws_valor_meta, rtrim(ws_mascara), prm_visao, substr(prm_parametros, 1 ,instr(prm_parametros,'|')-1), ws_objeto, '', ws_formula, prm_screen, ws_usuario);
					htp.p('<div id="'||ws_obj_html||'_mt">'||fun.getprop(trim(ws_objeto),'META_HINT')||' '||ws_complemento||'</div>');
				end if;

				/* 
				if ws_count_meta <> 0 then
					ws_complemento := ws_valor_ponto;
				else
					ws_complemento := fun.getprop(trim(prm_objeto),'META'); 
				end if;
				*/ 

				if ws_valor_meta = 'N/A' then 
					ws_valor_meta := null;
				end if;	
				htp.p('<span id="valores_'||ws_obj_html||'" data-tipo="VALOR" data-valor="'||ws_valor_ponto||'" data-color="'||fun.getprop(ws_objeto,'COLOR')||'" data-meta="'||ws_valor_meta /*fun.CONVERT_PAR(ws_complemento, prm_screen => prm_screen)*/ ||'" data-colunareal="'||prm_parametros||'" data-coluna="'||replace(fun.CHECK_ROTULOC(substr(prm_parametros, 1 ,instr(prm_parametros,'|')-1), prm_visao, prm_screen), '<BR>', ' ')||'"></span>');

			htp.p('</div>');	
			
		htp.p('</div>');

	end if;
exception 

	when ws_error then
		insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - ESTRUTURA - objeto|visao|coluna:'||prm_objeto||'|'||prm_visao||'|'||substr(prm_parametros, 1 ,instr(prm_parametros,'|')-1) , ws_usuario, 'ERRO');
		commit;
	when others then
		insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - ERROR', ws_usuario, 'ERRO');
		commit;

end valor;

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
					 prm_usuario	 varchar2 default null,
					 prm_track       varchar2 default null,
					 prm_cd_goto 	 varchar2 default null ) as

    ws_mascara         varchar2(100);
    ws_unidade         varchar2(100);
    ws_formula         varchar2(3000);
    ws_filtro          varchar2(2000);
    ws_class           varchar2(60);
    ws_gradiente       varchar2(2000);
    ws_gradiente_t     varchar2(40);
    ws_complemento     varchar2(1400) := '';
    ws_goto            varchar2(2000);
    ws_count           number;
	ws_valor_ponto     varchar2(80);
	ws_usuario         varchar2(40);
	ws_arr             arr;

	ws_prop_altura    varchar2(80);
	ws_prop_bgcolor   varchar2(80);
	ws_prop_bold      varchar2(80);
	ws_prop_color     varchar2(80);
	ws_prop_degrade   varchar2(80);
	ws_prop_degradetp varchar2(80);
	ws_prop_font      varchar2(80);
	ws_prop_it     	  varchar2(80);
	ws_prop_largura   varchar2(80);
	ws_prop_noradius  varchar2(80);
	ws_prop_size      varchar2(80);
	ws_prop_titbg     varchar2(80);
	ws_prop_um        varchar2(80);
	ws_posicao		  varchar2(40);
	ws_prop_borda	  varchar2(80);
	ws_titulo_html    clob;
    ws_obj_html        varchar2(100);
    ws_objeto          varchar2(100);

begin

    ws_usuario := prm_usuario;
    if ws_usuario is null then    
        ws_usuario := gbl.getUsuario;
    end if;

	if  prm_drill = 'Y' then
		ws_objeto   := fun.get_cd_obj(prm_objeto);
		ws_obj_html := ws_objeto||'trl'||prm_cd_goto;
	else
		ws_objeto   := prm_objeto;
		ws_obj_html := prm_objeto;
	end if;

	ws_arr := fun.getProps(ws_objeto, 'PONTEIRO', 'ALTURA|BGCOLOR|BOLD|BORDA_COR|COLOR|DEGRADE|DEGRADE_TIPO|FONT|IT|LARGURA|NO_RADIUS|SIZE|TIT_BGCOLOR|UM', 'DWU', prm_screen);

	ws_prop_altura    := ws_arr(1);
	ws_prop_bgcolor   := ws_arr(2);
	ws_prop_bold      := ws_arr(3);
	ws_prop_borda     := ws_arr(4);
	ws_prop_color     := ws_arr(5);

	ws_prop_degrade   := ws_arr(6);
	ws_prop_degradetp := ws_arr(7);
	ws_prop_font      := ws_arr(8);
	ws_prop_it     	  := ws_arr(9);

	ws_prop_largura   := ws_arr(10);
	ws_prop_noradius  := ws_arr(11);
	ws_prop_size      := ws_arr(12);

	ws_prop_titbg     := ws_arr(13);
	ws_prop_um        := ws_arr(14);

    select nm_mascara, nm_unidade, formula into ws_mascara, ws_unidade, ws_formula
	from MICRO_COLUNA
	where cd_micro_visao = prm_visao and
	cd_coluna = substr(prm_parametros, 1 ,instr(prm_parametros,'|')-1);

	select count(*) into ws_count from column_restriction where usuario = user and cd_micro_visao = prm_visao and cd_coluna in (select column_value from table(fun.vpipe(prm_parametros)));

    if ws_count = 0 then

		ws_gradiente := 'background-color: '||ws_prop_bgcolor;

		if ws_prop_degrade = 'S' then

            if nvl(ws_prop_degradetp, '%??%') = '%??%' then
				ws_gradiente_t := 'linear';
			else
				ws_gradiente_t := ws_prop_degradetp;
			end if;

            ws_gradiente := ' background: '||ws_gradiente_t||'-gradient('||ws_prop_titbg||', '||ws_prop_bgcolor||'); ';
		end if;

		htp.p('<div id="'||ws_obj_html||'" class="dragme medidor'||ws_class||'" onmousedown="'||prm_propagation||'">');

		    htp.p('<style>div#'||ws_obj_html||' { '||prm_posicao||' '||ws_gradiente||'; border: 1px solid '||ws_prop_borda||'; }</style>');

			select count(cd_objeto_go) into ws_count from goto_objeto where cd_objeto = ws_objeto;

			htp.p('<div id="dados_'||ws_obj_html||'" style="display: none;" data-visao="'||prm_visao||'" data-tipo="PONTEIRO" data-swipe="" data-width="'||ws_prop_largura||'" data-height="'||ws_prop_altura||'" data-top="'||prm_posy||'" data-left="'||prm_posx||'" data-drill="'||ws_count||'" data-cd_goto="'||prm_cd_goto||'"></div>');

			if fun.getprop(ws_objeto,'NO_RADIUS') <> 'N' then
				htp.p('<style>div#'||ws_obj_html||', div#'||ws_obj_html||'_ds { border-radius: 0; } div#'||ws_obj_html||' /*span#'||ws_obj_html||'more { border-radius: 0 0 6px 0; }*/ a#'||ws_obj_html||'fechar { border-radius: 0 0 0 6px; }</style>');
			end if;

			obj.opcoes(ws_obj_html, 'PONTEIRO', prm_parametros, prm_visao, prm_screen, prm_drill, prm_usuario => ws_usuario);

			obj.titulo(ws_objeto, prm_drill, prm_desc, prm_screen, ws_usuario, null, prm_track => prm_track, prm_cd_goto => prm_cd_goto, prm_titulo => ws_titulo_html);
			htp.p(ws_titulo_html);

			htp.prn('<ul id="'||ws_obj_html||'-filterlist" style="display: none;">');
				htp.prn(fun.show_filtros(prm_parametros, '', '', ws_objeto, prm_visao, prm_screen));
			htp.prn('</ul>');

			htp.prn('<style>div#ctnr_'||ws_obj_html||' {');
				htp.prn('position: relative !important;');
				htp.prn('max-width: inherit;'); 
				htp.prn('min-width: inherit;'); 
				htp.prn('width: ' ||ws_prop_largura||'px;'); 
				htp.prn('height: '||ws_prop_altura||'px;');
			htp.prn('}</style>');

			htp.p('<div id="ctnr_'||ws_obj_html||'" class="block-fusion">'||fun.lang('Carregando Informa&ccedil;&otilde;es...Aguarde!')||'</div>');

				ws_valor_ponto := fun.valor_ponto(prm_parametros, prm_visao, ws_objeto, prm_screen,prm_usuario => ws_usuario );

				htp.p('<div id="valor_'||ws_obj_html||'" title="'||ws_valor_ponto||'" onclick="get(''drill_go'').value = ''''; drillfix(event, '''||ws_obj_html||''', '''');" style="cursor: pointer;">');

				if(instr(ws_prop_um, '>') = 1) then
					htp.prn(fun.UM(substr(prm_parametros, 1 ,instr(prm_parametros,'|')-1), prm_visao,NVL(fun.ifmascara(ws_valor_ponto,rtrim(ws_mascara), prm_visao, substr(prm_parametros, 1 ,instr(prm_parametros,'|')-1), ws_objeto, '', ws_formula, prm_screen, ws_usuario), 'N/A'))||' '||replace(ws_prop_um, '>', ''));
				elsif(instr(ws_prop_um, '<') = 1) then
					htp.prn(replace(ws_prop_um, '<', '')||' '||fun.UM(substr(prm_parametros, 1 ,instr(prm_parametros,'|')-1),prm_visao,NVL(fun.ifmascara(ws_valor_ponto,rtrim(ws_mascara), prm_visao, substr(prm_parametros, 1 ,instr(prm_parametros,'|')-1), ws_objeto, '', ws_formula, prm_screen, ws_usuario), 'N/A')));
				else
					htp.prn(fun.UM(substr(prm_parametros, 1 ,instr(prm_parametros,'|')-1), prm_visao,NVL(fun.ifmascara(ws_valor_ponto,rtrim(ws_mascara), prm_visao, substr(prm_parametros, 1 ,instr(prm_parametros,'|')-1), ws_objeto, '', ws_formula, prm_screen, ws_usuario), 'N/A')));
				end if;

			htp.p('</div>');

			htp.p('<style>div#valor_'||ws_obj_html||' { overflow: hidden; height: 32px; line-height: 32px; border-top: 1px solid #000; text-align: center; font-style: '||ws_prop_it||'; font-weight: '||ws_prop_bold||'; font-family: '||ws_prop_font||'; font-size: '||ws_prop_size||'; color: '||ws_prop_color||'; }</style>');

			fcl.data_attrib(ws_obj_html, 'PONTEIRO', prm_screen);

        htp.p('</div>');

    end if;

end ponteiro;

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
					prm_usuario		varchar2 default null,
					prm_track       varchar2 default null,
					prm_cd_goto    varchar2 default null ) as

    ws_tipo            		varchar2(80);
	ws_gradiente       		varchar2(2000);
	ws_gradiente_tipo  		varchar2(40);
	ws_posicao         		varchar2(80);
	ws_class           		varchar2(60);
	ws_alinhamento_tit 		varchar2(80);
	ws_filtro          		varchar2(2000);
	ws_coluna          		varchar2(400) := '';
	ws_agrupador       		varchar2(400) := '';
	ws_colup           		varchar2(400) := '';
		
	ws_parametrosr     		clob;
	ws_parametros      		clob;
	ws_count           		number;

	ws_prop_degrade       	varchar2(40);
    ws_prop_degrade_tipo  	varchar2(40);
	ws_prop_tit_bg        	varchar2(40);
	ws_prop_bg            	varchar2(40);
	ws_prop_radius        	varchar2(40);
	ws_prop_largura       	varchar2(40);
	ws_prop_altura        	varchar2(40);
	ws_prop_align_tit     	varchar2(40);
	ws_prop_sec           	varchar2(120);
	ws_prop_borda         	varchar2(40);
	ws_prop_visivel         varchar2(1000); 
	ws_usuario            	varchar2(40);
	ws_padrao			  	varchar2(80);  
	ws_ordem              	varchar2(500);    
	w_ds_prop             	varchar2(100);
	ws_agrupadores        	varchar2(1000);
	ws_objeto               varchar2(200);
	ws_titulo_html          clob;
	ws_obj_html        		varchar2(400);
	ws_goto            		varchar2(2000);	
	ws_arr arr;

	--cursor c_object_attrib_col is 
	--   select 0 as mim, 600 as max

begin

    ws_usuario := prm_usuario;
    if ws_usuario is null then    
        ws_usuario := gbl.getUsuario;
    end if;
	ws_padrao   := gbl.getLang;

	if  prm_drill = 'Y' then
		ws_objeto   := fun.get_cd_obj(prm_objeto);
		ws_obj_html := ws_objeto||'trl'||prm_cd_goto;
	else
		ws_objeto   := prm_objeto;
		ws_obj_html := prm_objeto;
	end if;


	--get values
    select decode(tp_objeto, 'OBJETO', 'BARRAS', tp_objeto) into ws_tipo from OBJETOS where cd_objeto = ws_objeto/* and cd_usuario='DWU'*/;
	select cs_coluna, cs_agrupador, nvl(cs_colup, '') into ws_coluna, ws_agrupador, ws_colup from ponto_avaliacao where cd_ponto = ws_objeto;
	select count(*) into ws_count from goto_objeto where cd_objeto = ws_objeto;

	if  prm_cd_goto is not null then 
		select nvl(max(cs_coluna), ws_coluna), nvl(max(cs_agrupador),ws_agrupador), nvl(max(cs_colup), ws_colup)  
		  into ws_coluna, ws_agrupador, ws_colup
		  from GOTO_OBJETO
		 where cd_goto_objeto = prm_cd_goto ; 
	end if; 

	ws_arr := fun.getProps(ws_objeto, ws_tipo, 'ALIGN_TIT|ALTURA|BGCOLOR|BORDA_COR|DEGRADE|DEGRADE_TIPO|LARGURA|NO_RADIUS|TIT_BGCOLOR', ws_usuario, prm_screen);

    ws_prop_align_tit    := ws_arr(1);
	ws_prop_altura       := ws_arr(2);
	ws_prop_bg           := ws_arr(3);
	ws_prop_borda        := ws_arr(4);
	ws_prop_degrade      := ws_arr(5);
	ws_prop_degrade_tipo := ws_arr(6);
	ws_prop_largura      := ws_arr(7);
	ws_prop_radius       := ws_arr(8);
	ws_prop_tit_bg       := ws_arr(9);

	ws_prop_sec          := fun.getprop(ws_objeto, 'SEC');
	ws_prop_visivel      := fun.getprop(ws_objeto, 'VISIVEL', prm_screen, ws_usuario);

	if prm_drill = 'Y' then
		ws_class := ' drill';

	end if;

	if ws_tipo = 'MAPA' then
		ws_class := ws_class||' mapa';

	end if;

	if trim(ws_prop_degrade) = 'S' then
	
		if nvl(ws_prop_degrade_tipo, '%??%') = '%??%' then
			ws_gradiente_tipo := 'linear';
		else
			ws_gradiente_tipo := ws_prop_degrade_tipo;
		end if;
		
		ws_gradiente := 'background: '||ws_gradiente_tipo||'-gradient('||ws_prop_tit_bg||', '||ws_prop_bg||');';

	else
		ws_gradiente := 'background: '||ws_prop_bg||';';

	end if;

	ws_parametrosr := replace(prm_parametros, '  |  ', '');

	if fun.setem(ws_parametros,'|') and nvl(trim(ws_parametrosr),'%$%')<>'%$%' then
		ws_parametros := ws_parametros||ws_parametrosr;
	else
		ws_parametros := ws_parametrosr;
	end if;

	for i in(select rtrim(cd_coluna)||'|'||decode(rtrim(condicao),'IGUAL','$[IGUAL]','DIFERENTE','$[DIFERENTE]','MAIOR','$[MAIOR]','MENOR','$[MENOR]','MAIOROUIGUAL','$[MAIOROUIGUAL]','MENOROUIGUAL','$[MENOROUIGUAL]','LIKE','$[LIKE]','NOTLIKE','$[NOTLIKE]','$[IGUAL]')||rtrim(conteudo) as coluna from FILTROS where micro_visao = trim(prm_visao) and tp_filtro = 'objeto' and cd_objeto = ws_objeto and cd_usuario  = 'DWU' and condicao not in ('NOFLOAT', 'NOFILTER')) loop
		ws_filtro := i.coluna||'|'||ws_filtro;
	end loop;

	--ws_filtro := replace(ws_filtro, '+','%2B');
	--ws_filtro := replace(ws_filtro, '-','%2D');
	ws_filtro := substr(ws_filtro, 0, length(ws_filtro)-1);
	
	ws_filtro := ws_filtro||'|'||prm_parametros;

	htp.p('<div class="dragme grafico'||ws_class||'" onclick="if(objatual != this.id){ objatual = this.id;}" id="'||ws_obj_html||'" onmousedown="'||prm_propagation||'">');

	htp.p('<style>div#'||ws_obj_html||' { '||ws_gradiente||' '||prm_borda||' '||prm_posicao||'; border: 1px solid '||ws_prop_borda||'; }</style>');

	if ws_prop_radius <> 'N' then
		htp.p('<style>div#'||ws_obj_html||', div#'||ws_obj_html||'_ds { border-radius: 0; } div#'||ws_obj_html||' /*span#'||ws_obj_html||'more { border-radius: 0 0 6px 0; }*/ a#'||ws_obj_html||'fechar { border-radius: 0 0 0 6px; }</style>');
	end if;

	obj.opcoes(ws_obj_html, ws_tipo, ws_parametros, prm_visao, prm_screen, prm_drill, ws_agrupador, ws_colup, prm_usuario => ws_usuario);

	if prm_drill = 'Y' then

		if lower(ws_prop_largura) = 'auto' then
			ws_posicao := 'width: 400px; height: '||ws_prop_altura||'px;';
		else
			ws_posicao := 'width: '||ws_prop_largura||'px; height: '||ws_prop_altura||'px;';
		end if;
	else
		ws_posicao := 'width: '||ws_prop_largura||'px; height: '||ws_prop_altura||'px;';
	end if;

	select count(*) into ws_count from goto_objeto where cd_objeto = ws_objeto;

    -- 	alterado para passar parametro 'normal' na func fun.check_rotuloc - 12/01/2022
	htp.p('<div data-tipoobj="'||ws_tipo||'" id="dados_'||ws_obj_html||'" data-visao="'||prm_visao||'" data-visivel="'||ws_prop_visivel||'" data-heatmap="'||fun.getprop(ws_objeto, 'HEATMAP')||'" data-funil-sort="'||fun.getprop(ws_objeto, 'FUNIL_SORT')||'" data-funil="'||fun.getprop(ws_objeto, 'FUNIL')||'"  data-ccoluna-hex="'||fun.getprop(ws_objeto, 'COR-COLUNA-HEX')||'" data-maximo="'||fun.XFORMULA(fun.getprop(ws_objeto, 'MAXIMO'), prm_screen)||'"  data-filtro="'||ws_filtro||'" data-drill="'||ws_count||'" data-sec="'||fun.check_rotuloc(ws_prop_sec, prm_visao,null,'normal')/*fun.utranslate('NM_ROTULO', prm_visao, fun.check_rotuloc(ws_prop_sec, prm_visao), ws_padrao)*/||'" data-coluna="'||fun.utranslate('NM_ROTULO', prm_visao, fun.check_rotuloc(ws_coluna, prm_visao,null,'normal'), ws_padrao)||'" data-colunareal="'||ws_coluna||'" data-agrupadoresreal="'||ws_agrupador||'" data-agrupadores="'||fun.utranslate('NM_ROTULO', prm_visao, fun.check_rotuloc(ws_agrupador, prm_visao,null,'normal'), ws_padrao)||'" data-tipo="'||ws_tipo||'" data-top="'||prm_posy||'" data-left="'||prm_posx||'" data-swipe="" data-cd_goto="'||prm_cd_goto||'" style="display: none;"></div>');

	if instr(ws_tipo, 'MAPA') > 0 then

		if fun.getprop(ws_objeto, 'TYPE') = 'C' then
			htp.p('<ul class="lista_cidades" style="display: none; white-space: nowrap; word-break: keep-all;">');
				obj.lista_cidades(fun.getprop(ws_objeto, 'ESTADOS'), fun.getprop(ws_objeto, 'REGIOES'), 'CD', ws_objeto, prm_screen, prm_visao, prm_parametros);
			htp.p('</ul>');
		elsif fun.getprop(ws_objeto, 'TYPE') = 'R' then
			htp.p('<ul class="lista_regioes" style="display: none; white-space: nowrap; word-break: keep-all;">');
				obj.lista_regioes(fun.getprop(ws_objeto, 'REGIOES'), 'CD', ws_objeto, prm_screen, prm_visao, prm_parametros);
			htp.p('</ul>');
		else
			htp.p('<ul class="lista_estados" style="display: none; white-space: nowrap; word-break: keep-all;">');
				obj.lista_estados(fun.getprop(ws_objeto, 'ESTADOS'), fun.getprop(ws_objeto, 'REGIOES'), 'CD', ws_objeto, prm_screen, prm_visao, prm_parametros);
			htp.p('</ul>');
		end if;

	end if;

	obj.titulo(ws_obj_html, prm_drill, prm_desc, prm_screen, ws_usuario, null, prm_track => prm_track, prm_cd_goto => prm_cd_goto, prm_titulo => ws_titulo_html);
	htp.p(ws_titulo_html);

	
	if ws_tipo not in('MAPA','CALENDARIO')  then

		ws_ordem := upper(fun.getprop(ws_objeto, 'ORDEM', prm_usuario => ws_usuario));

		htp.p('<select class="ordem" title="'||fun.lang('Ordem dos valores do gr&aacute;fico')||'">');

				htp.p('<option selected  value="N/A">'||fun.lang('Ordem Default')||'</option>');
				
		        ws_count := 0;
				for i in
				(
					select column_value as coluna, cd_ligacao as ligacao 
					  from table(fun.vpipe(ws_coluna||'|'||ws_agrupador||'|'||ws_colup||'|'||fun.getprop(ws_objeto, 'SEC'))) t1
					  left join micro_coluna t2 on t2.cd_coluna = t1.column_value and t2.cd_micro_visao = prm_visao
					 where column_value is not null
					 order by ligacao desc
				) loop

					ws_count := ws_count+1;
					
					if ws_ordem = 'R_'||i.coluna||' ASC' then
					    htp.p('<option value="r_'||i.coluna||' ASC" selected>'||fun.CHECK_ROTULOC(i.coluna, prm_visao, prm_screen)||' crescente</option>');
					else
						htp.p('<option value="r_'||i.coluna||' ASC">'||fun.CHECK_ROTULOC(i.coluna, prm_visao, prm_screen)||' crescente</option>');
					end if;

					if ws_ordem = 'R_'||i.coluna||' DESC' then
						htp.p('<option value="r_'||i.coluna||' DESC" selected>'||fun.CHECK_ROTULOC(i.coluna, prm_visao, prm_screen)||' decrescente</option>');
					else
						htp.p('<option value="r_'||i.coluna||' DESC">'||fun.CHECK_ROTULOC(i.coluna, prm_visao, prm_screen)||' decrescente</option>');
					end if;

					if ws_count = 1 and i.ligacao <> 'SEM' then
						ws_count := ws_count+1;
						
						if ws_ordem = 'R_NM_'||i.coluna||'_D ASC' then
						    htp.p('<option value="r_nm_'||i.coluna||'_d ASC" selected>'||fun.CHECK_ROTULOC(i.coluna, prm_visao, prm_screen)||'(desc) crescente</option>');
						else
							htp.p('<option value="r_nm_'||i.coluna||'_d ASC">'||fun.CHECK_ROTULOC(i.coluna, prm_visao, prm_screen)||'(desc) crescente</option>');
						end if;

						if ws_ordem = 'R_NM_'||i.coluna||'_D DESC' then
							htp.p('<option value="r_nm_'||i.coluna||'_d DESC" selected>'||fun.CHECK_ROTULOC(i.coluna, prm_visao, prm_screen)||'(desc) decrescente</option>');
						else
							htp.p('<option value="r_nm_'||i.coluna||'_d DESC">'||fun.CHECK_ROTULOC(i.coluna, prm_visao, prm_screen)||'(desc) decrescente</option>');
						end if;
					end if;
				end loop;

		htp.p('</select>');

		-------------------------------------------------------------------------------------------------
		-- Agrupadores para troca- Colunas que podem substituir a coluna atual do gráfico - 28/01/2021 -- 
		-------------------------------------------------------------------------------------------------

		select count(*) into ws_count 
		  from bi_object_padrao 
		 where tp_objeto = ws_tipo 
		   and cd_prop  = 'AGRUPADORES' ;

        if ws_count = 0 then 
		   ws_agrupadores := 'N/A'; 

		else   
			ws_agrupadores := upper(fun.getprop(ws_objeto, 'AGRUPADORES', prm_usuario => 'DWU'));  -- ws_usuario;

		end if;	
		
		if nvl(ws_agrupadores,'N/A') <> 'N/A' then 
			htp.p('<select class="agrupador_troca" title="'||fun.lang('Colunas para troca no gr&aacute;fico')||'">');
				
				htp.p('<option selected disabled value="N/A">'||fun.lang('Colunas para troca')||'</option>');
				ws_count := 0;
				for i in
				(
					select column_value as coluna, cd_ligacao as ligacao 
					from table(fun.vpipe(ws_agrupadores) ) t1
					left join micro_coluna t2 on t2.cd_coluna = t1.column_value and t2.cd_micro_visao = prm_visao
					where column_value is not null
					order by ligacao desc
				) loop

					ws_count := ws_count+1;
					htp.p('<option value="'||i.coluna||'">'||fun.CHECK_ROTULOC(i.coluna, prm_visao, prm_screen)||'</option>');

				end loop;

			htp.p('</select>');

		end if;


	end if;

	htp.prn('<ul id="'||ws_obj_html||'-filterlist" style="display: none;">');
		htp.prn(fun.show_filtros(ws_parametros, '', '', ws_objeto, prm_visao, prm_screen));
	htp.prn('</ul>');

	htp.prn('<ul id="'||ws_obj_html||'-destaquelist" style="display: none;" >');
		htp.prn(fun.show_destaques(ws_parametros, '', '', ws_objeto, prm_visao, prm_screen));
	htp.prn('</ul>');

	htp.p('<div style="display: none;" id="gxml_'||ws_obj_html||'" data-parametros="'||ws_parametros||'" data-cs_coluna="'||ws_colup||'" data-cs_agrupador="'||ws_agrupador||'" data-tip="'||ws_tipo||'" data-cs_colup="'||ws_colup||'" data-sec="'||ws_prop_sec||'">');
        fcl.charout(ws_parametros, prm_visao, ws_objeto, prm_screen,prm_usuario => ws_usuario, prm_cd_goto => prm_cd_goto);
	htp.p('</div>');

		if ws_tipo in ('LINHAS', 'BARRAS') then
			htp.p('<div class="espaco" style="-webkit-overflow-scrolling: touch; overflow-x: auto; height: calc('||ws_prop_altura||'px + 20px);"><div id="ctnr_'||ws_obj_html||'" class="block-fusion" style="position: relative !important; min-width: inherit; '||ws_posicao||'">'||fun.lang('Carregando Informa&ccedil;&otilde;es...Aguarde!')||'</div></div>');
		else
			htp.p('<div id="ctnr_'||ws_obj_html||'" class="block-fusion espaco" style="position: relative !important; min-width: inherit; /*max-width: inherit;*/ '||ws_posicao||'">'||fun.lang('Carregando Informa&ccedil;&otilde;es...Aguarde!')||'</div>');
		end if;
	                        
		fcl.data_attrib(ws_obj_html, ws_tipo, prm_screen);

	htp.p('</div>');

exception 
	when others then
		htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);

end grafico;



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
						prm_usuario		varchar2 default null,
						prm_track       varchar2 default null,
						prm_cd_goto    varchar2 default null ) as

    ws_tipo            		varchar2(80);
	ws_posicao         		varchar2(80);
	ws_class           		varchar2(60);
	ws_alinhamento_tit 		varchar2(80);
	ws_obj_html        		varchar2(400);
	ws_goto            		varchar2(2000);
	ws_filtro          		varchar2(2000);
	ws_coluna          		varchar2(400) := '';
	ws_agrupador       		varchar2(400) := '';
	ws_colup           		varchar2(400) := '';
		
	ws_parametrosr     		clob;
	ws_parametros      		clob;
	ws_count           		number;

	ws_prop_tit_bg        	varchar2(40);
	ws_prop_bg            	varchar2(40);
	ws_prop_radius        	varchar2(40);
	ws_prop_largura       	varchar2(40);
	ws_prop_altura        	varchar2(40);
	ws_prop_align_tit     	varchar2(40);
	ws_prop_sec           	varchar2(120);
	ws_prop_borda         	varchar2(40);
	ws_usuario            	varchar2(40);
	ws_padrao			  	varchar2(80);  
	ws_ordem              	varchar2(500);    
	w_ds_prop             	varchar2(100);
	ws_agrupadores        	varchar2(1000);
	ws_titulo_html          clob;
	ws_arr arr;
	

	--cursor c_object_attrib_col is 
	--   select 0 as mim, 600 as max

begin

    ws_usuario := prm_usuario;
    if ws_usuario is null then    
        ws_usuario := gbl.getUsuario;
    end if;
	ws_padrao  := gbl.getLang;

	--get values
    select tp_objeto into ws_tipo from OBJETOS where cd_objeto = prm_objeto/* and cd_usuario='DWU'*/;
	select max(cs_coluna), max(cs_agrupador), max(nvl(cs_colup, '')) into ws_coluna, ws_agrupador, ws_colup 
	  from ponto_avaliacao where cd_ponto = prm_objeto;
	select count(*) into ws_count from goto_objeto where cd_objeto = prm_objeto;

	ws_arr := fun.getProps(prm_objeto, ws_tipo, 'ALIGN_TIT|ALTURA|BORDA_COR|LARGURA|NO_RADIUS|TIT_BGCOLOR', 'DWU', prm_screen);

    ws_prop_align_tit    := ws_arr(1);
	ws_prop_altura       := ws_arr(2);
	ws_prop_borda        := ws_arr(3);
	ws_prop_largura      := ws_arr(4);
	ws_prop_radius       := ws_arr(5);
	ws_prop_tit_bg       := ws_arr(6);
	ws_prop_sec          := fun.getprop(prm_objeto, 'SEC');
	ws_prop_bg           := 'background: #ffffff; ';

	ws_class := 'dragme mapageoloc';
	if prm_drill = 'Y' then
		ws_class := ws_class||' drill';
	end if;

	ws_parametrosr := replace(prm_parametros, '  |  ', '');
	if fun.setem(ws_parametros,'|') and nvl(trim(ws_parametrosr),'%$%')<>'%$%' then
		ws_parametros := ws_parametros||ws_parametrosr;
	else
		ws_parametros := ws_parametrosr;
	end if;
						
	if prm_drill = 'Y' then
		ws_obj_html := prm_objeto||'trl'||prm_cd_goto;
	else
		ws_obj_html := prm_objeto;
	end if;
						
	for i in(select rtrim(cd_coluna)||'|'||decode(rtrim(condicao),'IGUAL','$[IGUAL]','DIFERENTE','$[DIFERENTE]','MAIOR','$[MAIOR]','MENOR','$[MENOR]','MAIOROUIGUAL','$[MAIOROUIGUAL]','MENOROUIGUAL','$[MENOROUIGUAL]','LIKE','$[LIKE]','NOTLIKE','$[NOTLIKE]','$[IGUAL]')||rtrim(conteudo) as coluna 
	           from FILTROS 
			  where micro_visao = trim(prm_visao) 
			    and tp_filtro   = 'objeto' 
			    and cd_objeto   = prm_objeto 
				and cd_usuario  = 'DWU'
                and condicao not in ('NOFLOAT', 'NOFILTER')) loop
		ws_filtro := i.coluna||'|'||ws_filtro;
	end loop;

	ws_filtro := substr(ws_filtro, 0, length(ws_filtro)-1);
	ws_filtro := ws_filtro||'|'||prm_parametros;

	---------------------------------------------
	-- Abre a div do objeto 
	----------------------------------------------
	htp.p('<div id="'||ws_obj_html||'" class="'||ws_class||'" onclick="if(objatual != this.id){ objatual = this.id;}" onmousedown="'||prm_propagation||'">');
	
	htp.p('<style>div#'||ws_obj_html||' { '||ws_prop_bg||prm_borda||' '||prm_posicao||'; border: 1px solid '||ws_prop_borda||'; }</style>');

	if ws_prop_radius <> 'N' then
		htp.p('<style>div#'||ws_obj_html||', div#'||ws_obj_html||'_ds { border-radius: 0; } div#'||ws_obj_html||' a#'||ws_obj_html||'fechar { border-radius: 0 0 0 6px; }</style>');
	end if;

	obj.opcoes(ws_obj_html, ws_tipo, ws_parametros, prm_visao, prm_screen, prm_drill, ws_agrupador, ws_colup, prm_usuario => ws_usuario);

	if lower(ws_prop_largura) = 'auto' then
		ws_posicao := 'width: 400px; height: '||ws_prop_altura||'px;';
	else
		ws_posicao := 'width: '||ws_prop_largura||'px; height: '||ws_prop_altura||'px;';
	end if;

	select count(*) into ws_count from goto_objeto where cd_objeto = prm_objeto;
	
	htp.p('<div id="dados_'||ws_obj_html||'" data-tipoobj="'||ws_tipo||'"  data-visao="'||prm_visao||'"  data-filtro="'||ws_filtro||'" data-drill="'||ws_count||'" data-sec="'||fun.check_rotuloc(ws_prop_sec, prm_visao,null,'normal')/*fun.utranslate('NM_ROTULO', prm_visao, fun.check_rotuloc(ws_prop_sec, prm_visao), ws_padrao)*/||'" data-coluna="'||fun.utranslate('NM_ROTULO', prm_visao, fun.check_rotuloc(ws_coluna, prm_visao,null,'normal'), ws_padrao)||'" data-colunareal="'||ws_coluna||'" data-agrupadoresreal="'||ws_agrupador||'" data-agrupadores="'||fun.utranslate('NM_ROTULO', prm_visao, fun.check_rotuloc(ws_agrupador, prm_visao,null,'normal'), ws_padrao)||'" data-tipo="'||ws_tipo||'" data-top="'||prm_posy||'" data-left="'||prm_posx||'" data-swipe="" data-cd_goto="'||prm_cd_goto||'" style="display: none;"></div>');
	
	obj.titulo(prm_objeto, prm_drill, prm_desc, prm_screen, ws_usuario, null, prm_track => prm_track, prm_cd_goto => prm_cd_goto, prm_titulo => ws_titulo_html);
	htp.p(ws_titulo_html);

	htp.prn('<ul id="'||ws_obj_html||'-filterlist" style="display: none;">');
		htp.prn(fun.show_filtros(ws_parametros, '', '', prm_objeto, prm_visao, prm_screen));
	htp.prn('</ul>');

	htp.p('<div id="ctnr_'||ws_obj_html||'" class="block-fusion-mapa-gl espaco" style="position: relative !important; min-width: inherit; max-width: inherit; '||ws_posicao||';">'||fun.lang('Carregando Informa&ccedil;&otilde;es...Aguarde!')||'</div>');
	
	-- Div com os atributos do objeto (attributos_)
	fcl.data_attrib(ws_obj_html, ws_tipo, prm_screen);

	htp.p('<div style="display: none;" id="gxml_'||ws_obj_html||'">');
		obj.mapageoloc_markers(ws_parametros, prm_visao, ws_obj_html, prm_screen, prm_usuario => ws_usuario);  -- Monta marcadores  
	htp.p('</div>');
	------------------------------------------------------
	-- Fecha a div do objeto 
	--------------------------------------------------------
    htp.p('</div>');

exception 
	when others then
		htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);

end mapageoloc;


procedure mapageoloc_markers (prm_parametros       varchar2 default null,
							  prm_micro_visao      varchar2 default null,
							  prm_objeto           varchar2 default null,
							  prm_screen           varchar2 default null,
							  prm_usuario		   varchar2 default null ) as

	cursor c_marcador (p_cd_marcador varchar2) is  
		select 'S' tem_marcador, a.* 
		  from bi_mapa_marcador a 
		 where cd_marcador = p_cd_marcador;  

	ws_m_padrao     c_marcador%rowtype; 
	ws_m_valor      c_marcador%rowtype; 

	type tp_micro_coluna is table of micro_coluna%rowtype index by pls_integer;
	ws_micro_coluna    tp_micro_coluna; 


	ws_objeto        varchar2(200); 
	ret_coluna       varchar2(400);
	ws_ncolumns      DBMS_SQL.VARCHAR2_TABLE;
	ws_pvcolumns     DBMS_SQL.VARCHAR2_TABLE;
	ws_mfiltro       DBMS_SQL.VARCHAR2_TABLE;
	ws_lquery        number;
	ws_colup         long;
	ws_coluna        long;
	ws_agrupador     long;
	ws_rp            long;
	ws_parametros    long;
	ws_cursor        integer;
	ws_linhas        integer;
	ws_query_montada dbms_sql.varchar2a;
	ws_query_pivot   long;
	ws_sql           long;
	ws_vazio         boolean := True;


	ws_counter       number := 0;	
	ws_count         number;
	ws_cab_cross     clob;
	ws_queryoc	     clob;
	ws_id_json       number := 0;
	
	ws_json           varchar2(32000); 

	ws_cod            varchar2(500); 
	ws_nome  		  varchar2(500); 
	ws_descricao 	  varchar2(500); 
	ws_marcador       varchar2(100); 
	ws_imagem         varchar2(100); 
	ws_lat            varchar2(30); 
	ws_lng 			  varchar2(30); 	
	ws_rotacao        varchar2(30); 
	ws_label  		  varchar2(32000); 
	ws_icon           varchar2(32000);
	ws_qt_taux        number; 

	ws_usuario        varchar2(80);
	ws_padrao         varchar2(80) := 'PORTUGUESE';
	ws_admin          varchar2(80);

	ws_ds_erro        varchar2(32000); 
	
	ws_nodata        exception;
	ws_raise_mapa    exception ; 

begin

    ws_usuario := prm_usuario;
    if ws_usuario is null then    
        ws_usuario := gbl.getUsuario;
    end if;

	ws_padrao  := gbl.getLang;
	ws_admin   := nvl(gbl.getNivel, 'N');
	ws_objeto  := fun.get_cd_obj(prm_objeto); 

	select cs_coluna, cs_agrupador into ws_coluna, ws_agrupador from ponto_avaliacao where cd_ponto = ws_objeto;

	-- Valida quantidade de colunas selecionadas 
	--------------------------------------------------------------------
	select count(*) into ws_count from TABLE(FUN.VPIPE(ws_coluna)); 	
	if ws_count <> 4 then 
		ws_ds_erro := 'Devem ser selecionadas 4 colunas agrupadoras, foram selecionadas <'||ws_count||'>.' ;  
		raise ws_raise_mapa; 
	end if; 
	select count(*) into ws_count from TABLE(FUN.VPIPE(ws_agrupador)); 	
	if ws_count <> 3 then 
		ws_ds_erro := 'Devem ser selecionadas 3 colunas de valores, foram selecionadas <'||ws_count||'>.' ;  
		raise ws_raise_mapa; 
	end if; 


    ws_rp           := 'GROUP';
    ws_colup        := '';
    ws_parametros   := prm_parametros;

	open  c_marcador ( fun.getprop(ws_objeto, 'MARKER_STYLE') );
	fetch c_marcador into ws_m_padrao; 
	close c_marcador;

    begin 
		ws_sql := core.MONTA_QUERY_DIRECT(prm_micro_visao, ws_coluna, ws_parametros, ws_rp, ws_colup, ws_query_pivot, ws_query_montada, ws_lquery, ws_ncolumns, ws_pvcolumns, ws_agrupador, ws_mfiltro, ws_objeto, prm_screen => prm_screen, prm_cross => 'N', prm_cab_cross => ws_cab_cross,prm_usuario => ws_usuario);
    end;
	
	-- Monta texto do SQL para retornar caso de erro.   
	------------------------------------------------------------------
	ws_queryoc := '';
	ws_counter := 0;
	loop
		ws_counter := ws_counter + 1;
		exit when (ws_counter > ws_query_montada.COUNT); 
		ws_queryoc := ws_queryoc||ws_query_montada(ws_counter);
	end loop;

	-- Grava a ultima query executada para o objeto
	------------------------------------------------------------------	
	if ws_admin = 'A' then  
		begin  
			delete bi_object_query where cd_object = ws_objeto and nm_usuario = ws_usuario;
			insert into bi_object_query (cd_object, nm_usuario, dt_ultima_execucao, query) values (ws_objeto, ws_usuario, sysdate, ws_queryoc ); 
		exception when others then 
			insert into bi_log_sistema values (sysdate,'Erro gravando em bi_object_query ['||ws_objeto||']:'|| DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, ws_usuario,'ERRO');
		end; 
		commit;	
	end if;

	if ws_sql like 'Excesso de filtros%' then 
		ws_ds_erro := 'Excesso de filtros no objeto.' ;  
		raise ws_raise_mapa; 
	end if; 


    begin 
	   ws_cursor := dbms_sql.open_cursor;
	   dbms_sql.parse( c => ws_cursor, statement => ws_query_montada, lb => 1, ub => ws_lquery, lfflg => true, language_flag => dbms_sql.native );
	   ws_sql := core.bind_direct(ws_parametros, ws_cursor, '', ws_objeto, prm_micro_visao, prm_screen,prm_usuario => ws_usuario );
	exception when others then 
    	ws_ds_erro := 'Erro buscando dados do objeto, verifique as propriedades e atributos do objeto.' ;  
		raise ws_raise_mapa; 
    end; 

	-- Carrega parametros das colunas  e define o tamanho do retorno de cada coluna
	----------------------------------------------------------------------------------
	ws_counter        := 0;
	loop
		ws_counter := ws_counter + 1;
		exit when (ws_counter > ws_ncolumns.COUNT ); 
		dbms_sql.define_column(ws_cursor, ws_counter, ret_coluna, 200);
		--
		begin 
			select a.* into ws_micro_coluna(ws_counter) from micro_coluna a where cd_micro_visao = prm_micro_visao and cd_coluna = ws_ncolumns(ws_counter); 
		exception when others then 	
			ws_micro_coluna(ws_counter) := null;
		end; 
	end loop;


	-- início do JSON 
	------------------------------------------------------
	ws_linhas := dbms_sql.execute(ws_cursor);	
	htp.prn('<span class="json">');
    loop
		ws_linhas := dbms_sql.fetch_rows(ws_cursor);
        if ws_linhas = 1 then
            ws_vazio := False;
        else
            if ws_vazio = True then
                dbms_sql.close_cursor(ws_cursor);
                raise ws_nodata;
            end if;
            exit;
        end if;

		begin

			if ws_micro_coluna(1).cd_ligacao <> 'SEM'  then 
				ws_qt_taux := 1;
			else 
				ws_qt_taux := 0;
			end if; 	
			dbms_sql.column_value(ws_cursor, 1,              ws_cod);
			dbms_sql.column_value(ws_cursor, 1 + ws_qt_taux, ws_nome);
			dbms_sql.column_value(ws_cursor, 2 + ws_qt_taux, ws_descricao);
			dbms_sql.column_value(ws_cursor, 3 + ws_qt_taux, ws_marcador);
			dbms_sql.column_value(ws_cursor, 4 + ws_qt_taux, ws_imagem);
			dbms_sql.column_value(ws_cursor, 5 + ws_qt_taux, ws_lat);
			dbms_sql.column_value(ws_cursor, 6 + ws_qt_taux, ws_lng);
			dbms_sql.column_value(ws_cursor, 7 + ws_qt_taux, ws_rotacao);

			if ws_imagem is not null and upper(ws_imagem) not like '%HTTP%' then 
				ws_imagem := nvl(fun.ret_var('OWNER_BI'),'DWU')||'.fcl.download?arquivo='||ws_imagem; 
			end if; 				

			ws_m_valor := null;
			open  c_marcador (ws_marcador);
			fetch c_marcador into ws_m_valor; 
			close c_marcador; 
			
			-- Se não tem marcador no registro pega o parametrizado como padrão no objeto 
			if nvl(ws_m_valor.tem_marcador,'N') <> 'S' then 
				ws_m_valor := ws_m_padrao; 
			end if; 

			-- Utiliza a rotação cadastrada no registro do marcador, se existir 
			if ws_rotacao is not null then 
				begin 
					ws_m_valor.svg_rotation := ws_rotacao; 
				exception when others then 
					null;
				end; 		
			end if; 

			-- Define parametros do Label 
			-----------------------------------------------------			
			ws_label := '"label_text":"'      ||ws_nome                           ||'", 
			             "label_fontFamily":"'||ws_m_valor.label_fontfamily       ||'",
						 "label_fontWeight":"'||ws_m_valor.label_fontWeight       ||'",						 
					  	 "label_color":"'     ||ws_m_valor.label_color            ||'",
						 "label_fontSize":"'  ||nvl(ws_m_valor.label_fontSize ,14)||'px' ||'" ' ;

			-- Define parametros do Icone 
			-----------------------------------------------------
			if ws_imagem is not null then 			-- Se tem imagem no registro, prevalece a imagem do registro ao do destaque
				ws_m_valor.img_url := ws_imagem; 
			end if; 	

			if ws_m_valor.img_url is not null and upper(ws_m_valor.img_url) not like '%HTTP%' then 
				ws_m_valor.img_url := nvl(fun.ret_var('OWNER_BI'),'DWU')||'.fcl.download?arquivo='||ws_m_valor.img_url; 
			end if; 				

			if ws_m_valor.img_url is not null then 
				ws_icon := '"icon_url":"'       ||ws_m_valor.img_url               ||'",
							"icon_height":"'    ||ws_m_valor.img_height            ||'",      
							"icon_width":"'     ||ws_m_valor.img_width             ||'" ' ;			
			else 
				ws_icon := '"icon_path":"'         ||ws_m_valor.svg_path                  ||'",
						    "icon_fillColor":"'    ||ws_m_valor.svg_fillcolor             ||'",
							"icon_fillOpacity":"'  ||nvl(ws_m_valor.svg_fillopacity   ,1) ||'",
							"icon_strokeOpacity":"'||nvl(ws_m_valor.svg_strokeopacity ,1) ||'",
							"icon_rotation":"'     ||nvl(ws_m_valor.svg_rotation      ,0) ||'",
							"icon_scale":"'        ||nvl(ws_m_valor.svg_scale         ,1) ||'" ' ;									
			end if; 				 	
        exception when others then
			ws_ds_erro := 'Erro buscando dados das colunas de dados.';
            raise ws_raise_mapa;
        end;

	    ws_id_json := ws_id_json + 1;
		ws_json := '"'||ws_id_json||'": {"cod":"'||ws_cod||'", "title":"'||ws_descricao||'","lat":"'||ws_lat ||'","lng":"'||ws_lng ||'",'||ws_label||','||ws_icon||'}'; 
		if ws_id_json > 1 then 
			ws_json := ','||ws_json;
		end if; 	
	    htp.prn(ws_json);
	end loop; 
    dbms_sql.close_cursor(ws_cursor);


	htp.prn('</span>');
	------------------------------------------------------
	-- fim div JSON 


exception 
	when ws_nodata then  -- query sem dados 
        htp.p('</span><span id="'||prm_objeto||'_ERR">'||fun.subpar(fun.getprop(ws_objeto,'ERR_SD'), prm_screen)||'</span>');
	when ws_raise_mapa then
		insert into bi_log_sistema values (sysdate, 'MAPAGELOC_MARKERS:'||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, ws_usuario, 'ERRO');
        commit;
		if ws_admin = 'A' then     
			ws_ds_erro := ws_ds_erro || '<br>ERRO:'||DBMS_UTILITY.FORMAT_ERROR_STACK||'.<br><br>SQL:'||ws_queryoc;  
		end if; 	
		htp.p('<span id="'||prm_objeto||'_ERR">'||'<br>'||ws_ds_erro||'</span>');
	when others then
		ws_ds_erro := 'Erro montando marcadores do mapa.'; 
		insert into bi_log_sistema values (sysdate, 'MAPAGELOC_MARKERS:'||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, ws_usuario, 'ERRO');
        commit;
		if ws_admin = 'A' then   
			ws_ds_erro := ws_ds_erro || '<br>ERRO:'||DBMS_UTILITY.FORMAT_ERROR_STACK||'.<br><br>SQL:'||ws_queryoc; 
		end if; 	
		htp.p('<span id="'||prm_objeto||'_ERR">'||'<br>'||ws_ds_erro||'</span>');
end mapageoloc_markers;


procedure relatorio ( prm_objeto      varchar2 default null,
					  prm_propagation varchar2 default null,
					  prm_screen      varchar2 default null,
					  prm_drill       varchar2 default null,
					  prm_nome        varchar2 default null,
					  prm_posicao     varchar2 default null,
					  prm_posy        varchar2 default null,
					  prm_posx        varchar2 default null,
					  prm_dashboard   varchar2 default 'false'  ) as 

    ws_usuario varchar2(40);
	ws_objeto  varchar2(80);
	ws_style varchar2(80);
	ws_props_borda varchar2(80);
	ws_count number;
	ws_titulo_html     clob;
	ws_obj_html        varchar2(200);
	ws_width           varchar2(20);
	ws_drill_relatorio varchar(20);

begin

    ws_usuario := gbl.getUsuario;

	ws_obj_html := prm_objeto;
	if  prm_drill='Y' then
		ws_objeto := fun.get_cd_obj(prm_objeto); 
		ws_drill_relatorio := 'Y';
	else
		ws_objeto := prm_objeto;
		ws_drill_relatorio := 'N';
	end if;

	ws_props_borda := fun.getprop(ws_objeto, 'BORDA_COR');
	if prm_dashboard = 'true' then 
		ws_width := ' max-width: 280px; '; 
	else 
		ws_width := ' width: 280px; '; 
	end if;	

	htp.p('<div onmousedown="'||prm_propagation||'" id="'||ws_objeto||'trl" data-drill-relatorio="'||ws_drill_relatorio||'" data-top="'||prm_posy||'" data-left="'||prm_posx||'" style="'||prm_posicao||'; border: 1px solid '||ws_props_borda||';'||ws_width||' background-color: #FFF; border: 1px solid #999; text-align: center;" class="dragme relatorio">');

		obj.opcoes(ws_objeto, 'RELATORIO', '', '', prm_screen, prm_drill, prm_usuario => ws_usuario);

		if instr(fun.getprop(ws_objeto, 'LARGURA'), '%') > 0 then
			ws_style := fun.getprop(ws_objeto, 'LARGURA');
		else
			ws_style := replace(fun.getprop(ws_objeto, 'LARGURA'), 'px', '')||'px';
		end if;
		
		obj.titulo(prm_objeto, prm_drill, prm_nome, prm_screen, ws_usuario, null, null, null, prm_titulo => ws_titulo_html);
		htp.p(ws_titulo_html);

		select count(*) into ws_count from tab_documentos where trim(name) like 'REL_'||ws_objeto||'_'||gbl.getUsuario||'_%' and content_type = 'LOCKED';
		
		htp.p('<ul id="'||trim(ws_obj_html)||'_lista">');
			if ws_count <> 0 then
				up_rel.baixar_rel(ws_objeto, 'LOCKED');
			else
				up_rel.baixar_rel(ws_objeto);
			end if;
		htp.p('</ul>');

		if ws_count <> 0 then
			htp.p('<a class="rel_button loading" id="'||ws_obj_html||'_button" onclick="gerar_relatorio('''||ws_objeto||''', '''||prm_screen||''', '''||to_char(sysdate, 'YYMMDDHH24MI')||''');">');
				htp.p('<span>'||fun.lang('EXECUTANDO')||'</span>');
			htp.p('</a>');
		else
			htp.p('<a class="rel_button" id="'||ws_obj_html||'_button" onclick="gerar_relatorio('''||ws_objeto||''', '''||prm_screen||''', '''||to_char(sysdate, 'YYMMDDHH24MI')||''');">');
				htp.p('<span>'||fun.lang('GERAR RELAT&Oacute;RIO')||'</span>');
			htp.p('</a>');
		end if;
	htp.p('</div>');

end relatorio;

procedure file ( prm_objeto      varchar2 default null,
                 prm_propagation varchar2 default null,
				 prm_screen      varchar2 default null,
				 prm_drill       varchar2 default null,
				 prm_nome        varchar2 default null,
				 prm_posicao     varchar2 default null,
				 prm_posy        varchar2 default null,
				 prm_posx        varchar2 default null ) as 

    ws_borda     varchar2(80);
    ws_width     varchar2(80);
	ws_height    varchar2(80);
    ws_bg        varchar2(80);
	ws_align_tit varchar2(80);
	ws_color_tit varchar2(80);
	ws_bg_tit    varchar2(80);
	ws_it_tit    varchar2(80);
	ws_bold_tit	 varchar2(80);
	ws_font_tit	 varchar2(80);
	ws_size_tit	 varchar2(80);

	ws_sandbox     varchar2(20);
	ws_usuario     varchar2(80);
	ws_atributos   varchar2(120);
	ws_titulo_html clob;
	ws_count     number := 0;

begin

    ws_usuario := gbl.getUsuario;

    select atributos into ws_atributos
	from   OBJETOS
	where  cd_objeto=prm_objeto;
    
	--ATRIBUTOS DE ESTILO
	ws_borda     := 'border-color: '||fun.getprop(prm_objeto, 'BORDA_COR');
    ws_width     := 'width: '||fun.getprop(prm_objeto, 'LARGURA');
	ws_height    := 'height: '||fun.getprop(prm_objeto, 'ALTURA');
    ws_bg        := 'background: '||nvl(fun.getprop(prm_objeto, 'BGCOLOR'), '#FFF');
	ws_align_tit := 'text-align: '||fun.getprop(prm_objeto,'ALIGN_TIT');
	ws_color_tit := 'color: '||fun.getprop(prm_objeto, 'TIT_COLOR');
	ws_bg_tit    := 'background: '||fun.getprop(prm_objeto, 'TIT_BGCOLOR');
	ws_it_tit    := 'text-decotarion: '||fun.getprop(prm_objeto, 'TIT_IT');
	ws_bold_tit	 := 'font-weight: '||fun.getprop(prm_objeto, 'TIT_BOLD');
	ws_font_tit	 := 'font-family: '||fun.getprop(prm_objeto, 'TIT_FONT');
	ws_size_tit	 := 'font-size: '||fun.getprop(prm_objeto, 'TIT_SIZE');

	htp.p('<div onmousedown="'||prm_propagation||'" id="'||prm_objeto||'" data-top="'||prm_posy||'" data-left="'||prm_posx||'" class="dragme file drill_'||prm_drill||' radius_'||fun.getprop(prm_objeto,'NO_RADIUS')||'">');
    
	--ESTILO SEPARADO DA CAMADA DE HTML
	htp.prn('<style> div#'||prm_objeto||' {
	'||ws_borda||';
	'||ws_width||';
	'||ws_height||';
	'||ws_bg||';
	'||prm_posicao||';
    } 

	div#'||prm_objeto||'.radius_S, div#'||prm_objeto||'.radius_S div#'||prm_objeto||'_ds { 
		border-radius: 0; 
	} 

	/*div#'||prm_objeto||'.radius_S span#'||prm_objeto||'more { 
		border-radius: 0 0 6px 0; 
	} */

	div#'||prm_objeto||'.radius_S a#'||prm_objeto||'fechar { 
		border-radius: 0 0 0 6px; 
	}

	div#'||prm_objeto||'_ds {
        cursor: move; 
		text-align: center; 
		margin: 0 -3px; 
		padding: 3px; 
		'||ws_color_tit||';
		'||ws_bg_tit||';
		'||ws_it_tit||';
		'||ws_bold_tit||';
		'||ws_font_tit||';
		'||ws_size_tit||';
	}

	div#'||prm_objeto||'_sub {
        '||ws_align_tit||';
		'||ws_color_tit||';
	} 
	div#'||prm_objeto||'_vl {
        width: inherit; 
		height: inherit; 
		border: 0px; 
		padding: 0px; 
		overflow: auto; 
		top: 0;
		position: absolute; 
		background-color: #FFF; 
		z-index: -1;
	}
	div#'||prm_objeto||'_sub a {
        right: 2px; 
		bottom: 2px; 
		position: absolute; 
		z-index: 2;
	}
	div#'||prm_objeto||'_sub a img {
        height: 14px;
	}
	</style>');


	obj.opcoes(prm_objeto, 'FILE', '', '', prm_screen, prm_drill, prm_usuario => ws_usuario);
	
	obj.titulo(prm_objeto, prm_drill, prm_nome, prm_screen, ws_usuario, null, null, null, prm_titulo => ws_titulo_html);
	htp.p(ws_titulo_html);

		if fun.getprop(prm_objeto, 'SANDBOX') <> 'N' then
			ws_sandbox := 'sandbox';
		else
			ws_sandbox := '';
		end if;
			
		select count(*) into ws_count from tab_documentos where name = replace(ws_atributos, ' ', '_');
		if ws_count <> 0 then
			htp.p('<a href="'||nvl(fun.ret_var('OWNER_BI'),'DWU')||'.fcl.download?arquivo='||lower(replace(ws_atributos, ' ', '_'))||'" download target="_blank">');
			    htp.p('<img src="'||nvl(fun.ret_var('OWNER_BI'),'DWU')||'.fcl.download?arquivo=download.png">');
			htp.p('</a>');
			htp.p( '<iframe '||ws_sandbox||' id="'||prm_objeto||'_vl" onload="" name="'||prm_objeto||'_file" onmousedown="event.stopPropagation();" src="'||nvl(fun.ret_var('OWNER_BI'),'DWU')||'.fcl.download?arquivo='||replace(ws_atributos, ' ', '_')||'">');
		else
			htp.p( '<iframe '||ws_sandbox||' id="'||prm_objeto||'_vl" data-estilo="'||fun.getprop(prm_objeto,'CUSTOM_CSS')||'" onload="var estilo = document.createElement(''style''); estilo.innerHTML = this.getAttribute(''data-estilo''); document.getElementById('''||prm_objeto||'_vl'').document.head.appendChild(estilo);" name="'||prm_objeto||'_file" onmousedown="event.stopPropagation();" src="'||nvl(fun.ret_var('OWNER_BI'),'DWU')||'.fcl.download?arquivo='||replace(ws_atributos, ' ', '_')||'">');
		end if;
		
		htp.p('</iframe>');
		
	htp.p('</div>');

end file;

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
					 prm_cd_goto    varchar2 default null ) as

	TYPE rec_cols_total IS RECORD (
      cd_coluna   varchar2(200), 
      class       varchar2(200) );
	type tp_cols_total is table of rec_cols_total index by pls_integer;

	ws_cols_total   tp_cols_total ; 
	ws_anot_cond        	 varchar2(32000);

    ws_objeto      varchar2(200);
    ws_propagation 				varchar2(400) := '';
	ws_subquery    				varchar2(600);
	ws_isolado     				varchar2(60);
	ws_posix	   				varchar2(80);
	ws_posiy	   				varchar2(80);
	ws_cod         				varchar2(80);
	ws_order       				varchar2(90);
	ws_obj_html   				varchar2(200);
	ws_colup	   				varchar2(400);
	ws_coluna	   				varchar2(4000);
	ws_mode		   				varchar2(30);
	ws_rp          				varchar2(80);
	ws_texto       				varchar2(32000);
	ws_parametros  				varchar2(32000);
	ws_sem		   				varchar2(40);
	ws_ordem	   				varchar2(400);
	ws_ordem_query 				varchar2(400);
	ws_tmp_jump	   				varchar2(300);
	ws_show_only   				varchar2(10);
	ws_full        				varchar2(10);
	ws_borda       				varchar2(60);
	ws_html        				varchar2(4000);
	ws_titulo	   				varchar2(400);
	ws_binds       				varchar2(8000);
	ws_ctemp	   				varchar2(40);
	ws_fix         				varchar2(80);
	ws_usuario     				varchar2(80);
	ws_admin       				varchar2(20);
	ws_tpt         				varchar2(600);
	ws_query_hint  				varchar2(80);
	ws_cab_cross   				varchar2(4000);
	ws_drill	   				varchar2(40);
	ws_subtitulo   				varchar2(400);
	ws_nome        				varchar2(400);
	ws_jump		   				varchar2(600);
	ret_coluna	   				varchar2(4000);
	ws_ordem_arrow 				varchar2(100);
	ws_hint        				varchar2(5000);
	ws_col_sup_ant 				varchar2(4000);
	ws_col_sup     				varchar2(4000);
	ws_classe      				varchar2(400);
	ws_calculada_n 				varchar2(200);
	ws_zebrado	   				varchar2(20);
	ws_zebrado_d   				varchar2(40);
	ws_cod_coluna  				varchar2(2000);
	ret_colgrp     				varchar2(2000);
	ws_drill_a	   				varchar2(4000);
	ws_linha_calc  				varchar2(20);
	ws_check       				varchar2(300);
	ret_coltot     				varchar2(2000);
	ws_tmp_check   				varchar2(300);
	ws_idcol	   				varchar2(120);
	ws_alinhamento 				varchar2(80);
	ws_nm_var_al   				varchar2(400);
	ws_texto_al    				varchar2(10000);
	ws_pivot_c     				varchar2(4000);
	ws_class_td_pivot 			varchar2(400);
	ws_class_td_pivot_acum		CLOB;
	ws_valores_sem_repeticao	varchar2(1000);
	ws_valor_atual				varchar2(400);
	ws_background_d				varchar2(400);
	ws_background				varchar2(400);
	ws_cd_coluna   				varchar2(400);
	ws_pivot       				varchar2(300);
	ws_calculada   				varchar2(800);
    ws_calculada_m 				varchar2(200);
	ws_conteudo_a   			varchar2(4000);
	ws_content	    			varchar2(5000);
	ws_content_anot 			varchar2(5000);
	ws_agrupador    			varchar2(4000);
	ws_blink_linha  			varchar2(4000)  := 'N/A';
	ws_blink_aux    			varchar2(4000)  := 'N/A';	
	ws_repeat       			varchar2(60)    := 'show';
	ws_largura      			varchar2(60)    := '0';
	ws_null         			varchar2(1)     := null;
	ws_saida        			varchar2(10)    := 'S';
	ws_posicao	    			varchar2(2000)  := ' ';
	ws_obs          			varchar2(2000);
	ws_show_destaque   			varchar2(32000);
	ws_show_filtros    			varchar2(32000);
	ws_formato_excel   	  		varchar2(20);
	WS_ULTIMA_ATUALIZACAO 		varchar2(20);
	ws_nm_tabela          		varchar2(200); 
	ws_nm_tabela_fis      		varchar2(200); 
	ws_span_tempo         		varchar2(4000); 
	ws_th_atributos       		varchar2(2000);
	ws_html_arq           		varchar2(100);
	ws_param_titulo       		varchar2(10000); 

	ws_anot_param       	 	varchar2(32000);	
	ws_anot_texto       	 	varchar2(32000);
	ws_prop_usuario_anotacao 	varchar2(4000);
	ws_prop_ocultar_subtotal 	varchar2(1000);	
	ws_col_subt              	varchar2(1000);
	ws_st_oculta             	varchar2(1); 
	ws_estilo_pivot    		 	varchar2(400);
	ws_padrao 					varchar2(80) := 'PORTUGUESE';
	ws_amostra_top				varchar2(20);
	--
	ws_queryoc	   				clob;
	ws_sql         				clob;
	ws_sql_pivot   				clob;
	ws_query_pivot 				clob;
	ws_excel       				clob;
	ws_title 	   				clob;
	ws_content_ant 				clob;
	ws_rotulo_ant  				clob; 
	ret_colup	   				clob;
	ws_xatalho	   				clob;
	ws_atalho	   				clob;
	ws_textot	   				clob;
	ws_titulo_html 				clob;
	ws_html_t             		clob;
	ws_html_1             		clob;
	ws_html_2             		clob;
	ws_html_3             		clob;
	ws_estilo_linha    			clob;   --varchar2(32000);
	ws_estilo_linha1   			clob;
--
    ws_count       				number;
	ws_countor     				number;
	ws_fixed       				number;
	ws_row         				number;
	ws_lquery	   				number;
	ws_step        				number;
	ws_count_v     				number;
	ws_col_valor   				number;
	ws_agrup_max   				number;
	ws_content_sum 				number;
	ws_temp_valor  				number := 0;
	ws_temp_valor2 				number := 0;
	ws_total_linha 				number := 0;
	ws_ac_linha    				number := 0;
	ws_linha_col   				number := 0;
	ws_linha       				number := 0;
	ws_amostra     				number := 0;
	ws_chcor	   				number := 0;
	ws_ctnull	   				number := 0;
	ws_ctcol	   				number := 0;
	ws_ct_top      				number := 0;
	ws_xcoluna	   				number := 0;
	ws_stepper     				number := 0;
	ws_distinctmed 				number := 0;
	ws_qt_colagr      			number := 0;
	ws_qt_colinv      			number := 0; 
	ws_qt_colinv_cod  			number := 0;     
	ws_qt_colinv_val  			number := 0; 	
	ws_cspan	   				number := 0;
	ws_tempo_avg   				number := 0;
	ws_tempo_query 				number := 0;
	ws_counter	   				number := 1;
	ws_scol		   				number := 0;
	ws_top         				number := 0;
	ws_ccoluna	   				number := 1;
	ws_counterid   				number := 0;
	ws_bindn	   				number := 0;
	ws_xcount	   				number := 0;
	ws_child       				number := 0;
	ws_qt_cab_agru 				number := 0;
	ws_col_arr_count 			number := 1;
	--
	ws_admin_drill_ex  			boolean;
	ws_admin_drill_ad  			boolean;
	ws_admin_filtro_ex 			boolean;
	ws_admin_filtro_ad 			boolean;
	ws_firstid	    			char(1);
	ws_pipe		    			char(1);
	 --   
	dat_coluna      			date;
	ws_tempo        			date;
	--
	ws_query_montada			DBMS_SQL.VARCHAR2A;
	ws_ncolumns					DBMS_SQL.VARCHAR2_TABLE;
	ws_pvcolumns				DBMS_SQL.VARCHAR2_TABLE;
	ws_mfiltro					DBMS_SQL.VARCHAR2_TABLE;
	ws_vcol						DBMS_SQL.VARCHAR2_TABLE;
	ws_vcon						DBMS_SQL.VARCHAR2_TABLE;
	ws_coluna_ant				DBMS_SQL.VARCHAR2_TABLE;
	ws_array_anterior   		DBMS_SQL.VARCHAR2_TABLE;
	ws_array_atual      		DBMS_SQL.VARCHAR2_TABLE;
	ws_class_atual      		DBMS_SQL.VARCHAR2_TABLE;
	arr_destaq_col              DBMS_SQL.VARCHAR2_TABLE;
	arr_destaq_val              DBMS_SQL.VARCHAR2_TABLE;
	rec_tab             		DBMS_SQL.DESC_TAB;
	--
	ws_arr         				arr;
	ws_col_arr       			arr;
	ws_arr_anot    				fcl.arr_anotacao;

	--initcab
	ws_colspan     number;
	ws_negrito     varchar2(40);
	
	ws_cursor	     integer;
	ws_linhas	     integer;
	ws_pcursor	     number;
	ws_col_arr       arr;
	ws_col_arr_count number := 1;
	
	ws_vazio	   boolean := True;
	ws_prop_ocultar_selecao  varchar2(10); 
	ws_ordem_drill           varchar2(400); 
	ws_log_exec              varchar2(10);
	ws_log_exec_id           varchar2(200);
	ws_agrupador_aux		 varchar2(4000);
	ws_invisivel_aux		 varchar2(4000);
	ws_owner_bi              varchar2(30); 
	ws_coluna_destaque	 	 varchar2(4000); 
	ws_pre_suf_alias         varchar2(100); 
	ws_nodata_passo          varchar2(20); 
	
	ws_nodata      		exception;
	ws_semquery    		exception;
	ws_excesso_filtro   exception;
	ws_err_amostra		exception;

	cursor nc_colunas is 
	  select a.*, 'N' invisivel, 0 qt_destaque_celula, 0 qt_destaque_linha, 0 qt_destaque_total , 0 qt_destaque_refcol
	    from MICRO_COLUNA a 
	   where cd_micro_visao = prm_visao;

	type ws_tmcolunas is table of nc_colunas%ROWTYPE
	    index by pls_integer;

	ret_mcol			ws_tmcolunas;

	-- Procedure que executa o htp.p ou grava em variáveil para enviar para arquivos 
	procedure htp_p ( prm_html    clob     default null, 
	                  prm_gera_H  varchar2 default 'S',
					  prm_prn     varchar2 default 'P') as 
	begin
		
		if ws_saida = 'H' then 
			
			if prm_gera_H = 'S' then
				ws_html_t := ws_html_t||prm_html;
			end if;	

		else
			
			if prm_prn = 'PRN' then	
				htp.prn(prm_html);
			else
				htp.p(prm_html);
			end if;

		end if; 

	end htp_p;


    -- procedure copiada para a subquery, se alterar aqui altere lá também
	procedure ret_column_value (prm_counter     number,
	                            prm_dat_coluna   out date,
								prm_ret_coluna   out varchar2,
								prm_content      out varchar2,
								prm_content_anot out varchar2) as
	begin
		begin
			prm_content := null;
			prm_dat_coluna := null;
			prm_ret_coluna := null;

			if rec_tab(prm_counter).col_type = 12 then
				dbms_sql.column_value(ws_cursor, prm_counter, prm_dat_coluna);
				if ret_mcol(ws_ccoluna).nm_mascara = 'SEM' then
					prm_content := to_char(prm_dat_coluna, 'DD/MM/RRRR HH24:MI');
				else
					prm_content := fun.ifmascara(to_char(prm_dat_coluna,'DD/MM/RRRR HH24:MI:SS'), fun.cdesc(ret_mcol(ws_ccoluna).nm_mascara, 'MASCARAS'));
				end if;
				prm_content_anot := prm_content;
				prm_ret_coluna   := prm_dat_coluna;
			else
				begin
					dbms_sql.column_value(ws_cursor, prm_counter, prm_ret_coluna);
				exception when others then
					dbms_sql.column_value(ws_cursor, prm_counter, prm_ret_coluna);
				end;
				ws_content_anot := prm_ret_coluna; 

				prm_content := replace(prm_ret_coluna,'"',     '&#34;');
				prm_content := replace(prm_content,chr(39), '&#39;');
				prm_content := replace(prm_content,'/',     '&#47;');
				prm_content := replace(prm_content,'<',	  '&#60;');
				prm_content := replace(prm_content,'>',	  '&#62;');
			
			end if;
		exception when others then
			dbms_sql.column_value(ws_cursor, prm_counter, prm_ret_coluna);
			prm_content := prm_ret_coluna;
		end;	

		if instr(prm_content, '[LC]') > 0 then 
			prm_content := replace(prm_content, '[LC]', '');
		end if;		
	end ret_column_value; 

    -- procedure copiada para a subquery, se alterar aqui altere lá também
	procedure monta_arr_destaque as 
		ws_dat_aux        date;
		ws_ret_aux        varchar2(4000);
		ws_destaq_content varchar2(5000);
		ws_anot_aux       varchar2(5000);
	begin
		arr_destaq_col.delete;
		arr_destaq_val.delete;
		for a in 1..ws_ncolumns.count  loop
			ret_column_value (a, ws_dat_aux, ws_ret_aux, ws_destaq_content, ws_anot_aux);
			arr_destaq_val(a) := ws_destaq_content; 
			arr_destaq_col(a) := rec_tab(a).col_name; 
		end loop;
	exception when others then 
		insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values(sysdate, 'NESTED_TD ['||prm_objeto||']:'||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, ws_usuario, 'ERRO');
		commit;
	end monta_arr_destaque; 	


	procedure nested_fix ( prm_alinhamento in  varchar2,
	                       prm_negrito     in  varchar2,
						   prm_coluna      in  number,
						   prm_estilo      in out varchar2 ) as
		
		ws_style 		varchar2(200);	
		ws_child 		number;		
		ws_linha_th  	number; 
		ws_qt_th     	number; 

	begin

	    ws_child := prm_coluna+1;

		-- Se exitir PIVOT, monta a formatação das colunas do PIVOT 
		ws_qt_th := 0;
		if prm_colup is not null then 
			if prm_estilo is null then 
				for a in (select t1.* from micro_coluna t1, TABLE(FUN.VPIPE(prm_colup)) t2
						where t1.cd_micro_visao = PRM_VISAO
							and t1.cd_coluna      = t2.column_value
						) loop 

					ws_qt_th := ws_qt_th + 1 ; 
					ws_style := null;
					
					if lower(trim(a.st_alinhamento)) in ('right','left','center') then  
						ws_style := ws_style||' text-align: '||lower(trim(a.st_alinhamento))||' ;';
					end if;
					if trim(a.st_negrito) = 'S' then
						ws_style := ws_style||' font-weight: bold;';
					end if;
					if ws_style is not null then  
						if ws_qt_th = 1 then 
							prm_estilo := prm_estilo||' table#'||ws_obj_html||'c tr:nth-child('||ws_qt_th||') th:nth-child(+n+'||(ws_qt_cab_agru+1)||')' ;  -- 1ª linha começa com as colunas de valores
						else 
							prm_estilo := prm_estilo||' table#'||ws_obj_html||'c tr:nth-child('||ws_qt_th||') th ' ;                                      -- 2º linha aplica em todas as colunas
						end if; 	
						prm_estilo := prm_estilo||' { '||trim(ws_style)||' }';
					end if; 	
				end loop ; 			
			else 
				select count(*) into ws_qt_th from TABLE(FUN.VPIPE(prm_colup)); 
			end if; 
		end if; 

		-- Formatação das colunas de TD e TH referente a coluna TD 
		ws_style := null;
	    if lower(trim(prm_alinhamento)) in ('right','left','center') then
			ws_style := ws_style||' text-align: '||lower(trim(prm_alinhamento))||';';
		end if; 
		if trim(prm_negrito) = 'S' then
			ws_style := ws_style||' font-weight: bold;';
		end if;

		ws_linha_th := ws_qt_th + 1; 

		prm_estilo := prm_estilo||' table#'||ws_obj_html||'c tr td:nth-child('||ws_child||')'; 
		
		if prm_colup is null then -- Não tem PIVOT 
			prm_estilo := prm_estilo||', table#'||ws_obj_html||'c tr th:nth-child('||(ws_child - ws_qt_cab_agru)||')' ; 
		else 	
			if ws_child <= ws_qt_cab_agru then 
				prm_estilo := prm_estilo||', table#'||ws_obj_html||'c tr:nth-child(1) th:nth-child('||(ws_child)||')' ;	 -- colunas sem pivot (primeiras colunas)  	
			else 
				prm_estilo := prm_estilo||', table#'||ws_obj_html||'c tr:nth-child('||ws_linha_th||') th:nth-child('||(ws_child - ws_qt_cab_agru)||')' ;   -- colunas com pivot (colunas de valores)
			end if; 	
		end if; 	
		prm_estilo := prm_estilo||' { '||trim(ws_style)||' }';

	end nested_fix;

	procedure nested_calculada( prm_calculada   in varchar2, 
								prm_coluna      in varchar2 default null, 
								prm_dir         in varchar2 default null, 
								prm_count       in out number, 
								prm_objeto      varchar2 default null, 
								prm_formula     varchar2 default null, 
								prm_screen      varchar2 default null, 
								prm_jump        varchar2 default null,
								prm_mascara     varchar2 default null,
								prm_content     varchar2 default null,
								prm_content_a   varchar2 default null,
								prm_calculada_m varchar2 default null ) as

        ws_calculada   varchar2(800);
        ws_calculada_m varchar2(200);

	begin

	    if nvl(prm_coluna, 'N/A') <> 'N/A' then
			
			if length(prm_calculada) > 0 then
				for i in(select column_value as valor from table(fun.vpipe((prm_calculada)))) loop
					if instr(i.valor, prm_dir) > 0 then
						if substr(i.valor, 0, instr(i.valor, prm_dir)-1) = prm_coluna then
							htp_p('<td></td>');
						end if;
					end if;
				end loop;
			end if;

        elsif nvl(prm_jump, 'N/A') <> 'N/A' then

			begin
				if length(prm_calculada) > 0 then
					for i in(select column_value as valor, rownum as linha from table(fun.vpipe((prm_calculada)))) loop
						if instr(i.valor, prm_dir) > 0 then
							if substr(i.valor, 0, instr(i.valor, prm_dir)-1) = prm_coluna then
								ws_calculada := fun.xexec('EXEC='||substr(i.valor, instr(i.valor, prm_dir)+1), prm_screen, prm_content, prm_content_a);
								select nvl(mascara, trim(prm_mascara)) into ws_calculada_m from(select column_value as mascara, rownum as linha from table(fun.vpipe((prm_calculada_m)))) where linha = i.linha;
								htp_p('<td '||prm_jump||'>'||fun.ifmascara(ws_calculada, ws_calculada_m, prm_visao, prm_coluna, prm_objeto, '', prm_formula, prm_screen, ws_usuario)||'</td>');
							end if;
						end if;
					end loop;
				end if;
			exception when others then
				htp_p('<td '||prm_jump||' data-err="'||sqlerrm||'">err</td>');
			end;
			
		else

		    if length(prm_calculada) > 0 then
				for i in(select column_value as valor, rownum as linha from table(fun.vpipe((prm_calculada)))) loop
					if instr(i.valor, '>') > 0 then
						prm_count := prm_count+1;
					end if;
					if instr(i.valor, '<') > 0 then
						prm_count := prm_count+1;
					end if;
				end loop;
			end if;

		end if;

	end nested_calculada;

	procedure nested_td ( prm_hint    	   varchar2 default null,
	                      prm_fix     	   varchar2 default null,
						  prm_counter 	   varchar2 default null,
						  prm_idcol   	   varchar2 default null,
						  prm_objeto  	   varchar2 default null,
						  prm_coluna  	   varchar2 default null,
						  prm_content 	   in out varchar2,
						  prm_screen  	   varchar2 default null,
						  prm_formula 	   varchar2 default null,
						  prm_visao   	   varchar2 default null,
						  prm_mascara 	   varchar2 default null,
						  prm_jump    	   varchar2 default null,
						  prm_agrupador    varchar2 default null,
						  prm_um           varchar2 default null,
						  prm_ccoluna      number   default 0 ) as

	    ws_conteudo      varchar2(5000);
		ws_id            varchar2(80) := '';
		ws_atributo      varchar2(4000);
		ws_anot_svg      varchar2(1000);
		ws_anot_class    varchar2(20);		
		ws_anot_title    varchar2(4000);
		ws_condicao      varchar2(4000);
		ws_usua_perm     varchar2(32000); 

	begin
	    
		ws_anot_texto := null;
		-- Cria a anotação de célula (TD), caso exista  -- Se foi carregado anotações para o objetos 
		if ws_arr_anot.count > 0 then  
			ws_condicao  := replace(ws_anot_cond||'|'||prm_parametros,'||','|'); 
			ws_usua_perm := ws_usuario; 
			fcl.anotacao_busca_anot ('HTML_USUARIO', prm_objeto, prm_screen, null, prm_coluna, ws_condicao, ws_arr_anot, ws_usua_perm, ws_anot_texto);
			if ws_anot_texto is not null then 
				ws_anot_svg   := '<span>'||fun.ret_svg('anotacao_marcacao')||'</span>';  -- Atenção, quando alterar esse SVG tem que alterar no JS, pois ele também é colocado na TD quando uma anotação é criada/gravada 
				ws_anot_class := ' anotacao '; 
			end if; 	
		end if; 	

        ws_conteudo := trim(prm_content);
		ws_id := prm_idcol;

		if nvl(prm_mascara, 'N/A') <> 'N/A' then
			ws_conteudo := fun.ifmascara(ws_conteudo, trim(prm_mascara), prm_visao, prm_coluna, prm_objeto, '', prm_formula, prm_screen, ws_usuario);
		end if;

		if nvl(prm_um, 'N/A') <> 'N/A' then
			ws_conteudo := fun.um(prm_coluna, prm_visao, ws_conteudo, prm_um);
		end if;
		
		-- Retirado a regra que inibia o 0/null da ret_sinal 01/10/21
		if prm_agrupador <> 'SEM'/* and nvl(prm_content, '0') <> '0'*/ then
			ws_conteudo := ws_conteudo||fun.ret_sinal(prm_objeto, prm_coluna, prm_content);
		end if;

		-- Aplica destaque de celula de linha e celula de total  
		ws_blink_aux := null;
		if ret_mcol(prm_ccoluna).qt_destaque_celula > 0 or ret_mcol(prm_ccoluna).qt_destaque_total > 0 then 
			arr_destaq_col.delete;
			arr_destaq_val.delete;
			ws_pre_suf_alias := null;
			if ret_mcol(prm_ccoluna).qt_destaque_refcol > 0 then 		-- Se tem colunas &[] dentro do conteúdo do destaque, monta array com os conteúdos para passar para o destaque  
				monta_arr_destaque;
				ws_pre_suf_alias := substr(rec_tab(prm_counter).col_name,1,instr(rec_tab(prm_counter).col_name,ws_ncolumns(prm_counter))-1)||'|'||   -- prefixo 
				                    substr(rec_tab(prm_counter).col_name,instr(rec_tab(prm_counter).col_name,ws_ncolumns(prm_counter))+length(ws_ncolumns(prm_counter)),1000);  -- sufixo 
			end if;
			if ret_colgrp = 0 then      -- linha normal 
				ws_blink_aux := fun.check_blink(prm_objeto, prm_coluna, prm_content, '', prm_screen, ws_usuario, prm_pre_suf_alias => ws_pre_suf_alias, prm_ar_colref => arr_destaq_col, prm_ar_colval => arr_destaq_val);
			else                        -- linha de total 
            	ws_blink_aux := fun.check_blink_total(prm_objeto, prm_coluna, NVL(prm_content,'0'), '', prm_screen, prm_pre_suf_alias => ws_pre_suf_alias, prm_ar_colref => arr_destaq_col, prm_ar_colval => arr_destaq_val);				
			end if; 	
		end if;

        ws_atributo := trim(prm_hint||prm_fix||ws_id||ws_blink_aux||' '||prm_jump);
		ws_atributo := replace(ws_atributo,'class="', 'class="'||ws_anot_class); 

		ws_html_1 := '<td '; 
		if nvl(ws_atributo, 'N/A') <> 'N/A' then
			ws_html_1 := ws_html_1 ||ws_atributo;
		end if;
		ws_html_1 := ws_html_1||'>'||ws_anot_svg||ws_conteudo||'</td>'; 

		htp_p(ws_html_1,prm_prn => 'PRN');  --PRN

	exception when others then
	    htp_p('<td>'||sqlerrm||'</td>',prm_prn => 'PRN'); --PRN 
	end nested_td;

begin
	ws_usuario := prm_usuario;
    if ws_usuario is null then    
        ws_usuario := gbl.getUsuario;
    end if;
	
	ws_tempo    := SYSDATE;
	ws_admin    := nvl(gbl.getNivel(ws_usuario),'N');
	ws_owner_bi := nvl(fun.ret_var('OWNER_BI'),'DWU');

	if nvl(fun.ret_var('LOG_EXEC'),'N') in ('S','D') then 
		ws_log_exec     := fun.ret_var('LOG_EXEC');
		ws_log_exec_id  := null;
	end if; 	


	if prm_drill = 'Y' then 
		ws_objeto   := fun.get_cd_obj(prm_objeto);   -- Retorna o código do objeto retirado os sufixos se for uma Drill 
	    ws_obj_html := ws_objeto||'trl'||prm_cd_goto;
	else 
		ws_objeto := prm_objeto; 
		ws_obj_html := ws_objeto;
	end if; 	

	ws_estilo_linha  := ''; 
	ws_estilo_linha1 := ''; 

	ws_prop_usuario_anotacao := nvl(fun.getprop (ws_objeto, 'USUARIO_ANOTACAO'),'NENHUM'); 
	ws_prop_ocultar_selecao  := nvl(fun.getprop (ws_objeto, 'OCULTAR_SELECAO'),'S'); 
	ws_prop_ocultar_subtotal := nvl(fun.getprop (ws_objeto, 'OCULTAR_SUBTOTAL'),'S'); 

	--gravar a última att da visão na variável ws_ultima_atualizacao pra reusar em mais tipos de objetos
	ws_nm_tabela          := null;
	ws_ultima_atualizacao := null; 
	SELECT MAX(nm_tabela),  to_char(max(mi1.dt_ultima_atualizacao),'dd/mm/yyyy hh24:mi') INTO ws_nm_tabela, ws_ultima_atualizacao
	  FROM micro_visao       mi1,
		   ponto_avaliacao   po1
	 WHERE mi1.nm_micro_visao = po1.cd_micro_visao
	   AND po1.cd_ponto       = ws_objeto
	   AND ROWNUM = 1;
	ws_nm_tabela_fis := fun.GETPROP (ws_objeto, 'TABELA_FISICA_OBJETO');	   
	if ws_nm_tabela_fis is not null then 
	   ws_nm_tabela := ws_nm_tabela_fis; 
	end if; 
	select count(*) into ws_count from all_tables where owner = nvl(fun.ret_var('OWNER_TABLE_DATA'),'DWU') and table_name = ws_nm_tabela; 
	if ws_count > 0 then 
		if ws_ultima_atualizacao is not null then 
			ws_span_tempo := '<span class="tempo" data-obs="<h4>&Uacute;ltima Atualiza&ccedil;&atilde;o</h4><span>'||WS_ULTIMA_ATUALIZACAO||'</span>" onclick="objObs(this.getAttribute(''data-obs''));"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" style="margin-top: 0px;><title>Stopwatch</title><g id=" _11_-_20"="" data-name="11 - 20"><g id="Stopwatch"><path d="M38.1,14.312l1.455-1.454.793.793a1,1,0,0,0,1.414-1.414l-3-3a1,1,0,1,0-1.414,1.414l.792.793L36.688,12.9A18.892,18.892,0,0,0,25,8.051V7h2a2,2,0,0,0,2-2V4a2,2,0,0,0-2-2H21a2,2,0,0,0-2,2V5a2,2,0,0,0,2,2h2V8.051A18.892,18.892,0,0,0,11.312,12.9L9.858,11.444l.792-.793A1,1,0,1,0,9.236,9.237l-3,3A1,1,0,1,0,7.65,13.651l.793-.793L9.9,14.312a19,19,0,1,0,28.2,0ZM21,4h6V5H21Zm3,40A17,17,0,1,1,41,27,17.019,17.019,0,0,1,24,44Z"></path><path d="M24,12A15,15,0,1,0,39,27,15.017,15.017,0,0,0,24,12ZM35,28h1.949a12.919,12.919,0,0,1-3.088,7.447l-1.376-1.376a1,1,0,1,0-1.414,1.414l1.376,1.376A12.926,12.926,0,0,1,25,39.949V38a1,1,0,0,0-2,0v1.949a12.926,12.926,0,0,1-7.447-3.088l1.376-1.376a1,1,0,1,0-1.414-1.414l-1.376,1.376A12.919,12.919,0,0,1,11.051,28H13a1,1,0,0,0,0-2H11.051a12.919,12.919,0,0,1,3.088-7.447l1.376,1.376a1,1,0,1,0,1.414-1.414l-1.376-1.376A12.926,12.926,0,0,1,23,14.051V16a1,1,0,0,0,2,0V14.051a12.926,12.926,0,0,1,7.447,3.088l-1.376,1.376a1,1,0,1,0,1.414,1.414l1.376-1.376A12.919,12.919,0,0,1,36.949,26H35a1,1,0,0,0,0,2Z"></path><path d="M27.827,17.761a1,1,0,0,0-1.306.541l-2.367,5.714c-.052,0-.1-.016-.154-.016a3.03,3.03,0,1,0,2,.781l2.367-5.713A1,1,0,0,0,27.827,17.761ZM24,28a1,1,0,1,1,1-1A1,1,0,0,1,24,28Z"></path></g></svg></span>'; 
		else 
			ws_span_tempo := '<span class="tempo" onclick="alerta(''feed-fixo'', ''Consulta n&atilde;o possui informa&ccedil;&atilde;o de data da &uacute;ltima atualiza&ccedil;&atilde;o dos dados'') ;"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" style="margin-top: 0px;><title>Stopwatch</title><g id=" _11_-_20"="" data-name="11 - 20"><g id="Stopwatch"><path d="M38.1,14.312l1.455-1.454.793.793a1,1,0,0,0,1.414-1.414l-3-3a1,1,0,1,0-1.414,1.414l.792.793L36.688,12.9A18.892,18.892,0,0,0,25,8.051V7h2a2,2,0,0,0,2-2V4a2,2,0,0,0-2-2H21a2,2,0,0,0-2,2V5a2,2,0,0,0,2,2h2V8.051A18.892,18.892,0,0,0,11.312,12.9L9.858,11.444l.792-.793A1,1,0,1,0,9.236,9.237l-3,3A1,1,0,1,0,7.65,13.651l.793-.793L9.9,14.312a19,19,0,1,0,28.2,0ZM21,4h6V5H21Zm3,40A17,17,0,1,1,41,27,17.019,17.019,0,0,1,24,44Z"></path><path d="M24,12A15,15,0,1,0,39,27,15.017,15.017,0,0,0,24,12ZM35,28h1.949a12.919,12.919,0,0,1-3.088,7.447l-1.376-1.376a1,1,0,1,0-1.414,1.414l1.376,1.376A12.926,12.926,0,0,1,25,39.949V38a1,1,0,0,0-2,0v1.949a12.926,12.926,0,0,1-7.447-3.088l1.376-1.376a1,1,0,1,0-1.414-1.414l-1.376,1.376A12.919,12.919,0,0,1,11.051,28H13a1,1,0,0,0,0-2H11.051a12.919,12.919,0,0,1,3.088-7.447l1.376,1.376a1,1,0,1,0,1.414-1.414l-1.376-1.376A12.926,12.926,0,0,1,23,14.051V16a1,1,0,0,0,2,0V14.051a12.926,12.926,0,0,1,7.447,3.088l-1.376,1.376a1,1,0,1,0,1.414,1.414l1.376-1.376A12.919,12.919,0,0,1,36.949,26H35a1,1,0,0,0,0,2Z"></path><path d="M27.827,17.761a1,1,0,0,0-1.306.541l-2.367,5.714c-.052,0-.1-.016-.154-.016a3.03,3.03,0,1,0,2,.781l2.367-5.713A1,1,0,0,0,27.827,17.761ZM24,28a1,1,0,1,1,1-1A1,1,0,0,1,24,28Z"></path></g></svg></span>'; 		
		end if; 			
	else 
		ws_span_tempo := null; 
	end if; 

    --DEFININDO PROPS
	ws_arr := fun.getProps(ws_objeto, 'CONSULTA', 'AGRUPADORES|ALTURA|AMOSTRA|BORDA_COR|CALCULADA|CALCULADA_M|CALCULADA_N|COLUNA_FINAL|COLUNA_INICIAL|DASH_MARGIN_BOT|DASH_MARGIN_LEFT|DASH_MARGIN_RIGHT|DASH_MARGIN_TOP|DEGRADE|DRILLT|FILTRO|FIXAR_TOT|FIXED-N|FONTE_CABECALHO|FONTE_CLARO|FONTE_ESCURO|FONTE_TOTAL|FONT_FAMILY|FONT_SIZE|FULL|FUNDO_CABECALHO|FUNDO_CLARO|FUNDO_ESCURO|FUNDO_TOTAL|FUNDO_VALOR|GRID_COLOR|HEAD_BOLD|LARGURA|LINHA_ACUMULADA|NAO_REPETIR|NOME_COLUNA|NOME_PIVOT|NO_OPTION|NO_RADIUS|NO_TUP|OMITIR_TOT|QUBE|QUERY_STAT|SO_TOT|SUBQUERY|TOP|TOTAL_ACUMULADO|TOTAL_GERAL_TEXTO|TOTAL_SEPARADO|TOTAL_SEPARADO_TEXTO|TOT_BOLD|TP_GRUPO|VISIVEL|XML', 'DWU', prm_screen);


    ws_admin_drill_ex  := fun.check_admin('DRILLS_EX');
	ws_admin_drill_ad  := fun.check_admin('DRILLS_ADD'); 
	ws_admin_filtro_ex := fun.check_admin('FILTERS_EX');
	ws_admin_filtro_ad := fun.check_admin('FILTERS_ADD');

	ws_padrao := gbl.getLang;
    ws_saida := ws_arr(54);

	ws_formato_excel := fun.ret_var('FORMATO_EXCEL', ws_usuario); 
	if nvl(ws_formato_excel,'N/A') = 'N/A' then 
 		ws_formato_excel := fun.ret_var('FORMATO_EXCEL', 'DWU'); 
	end if; 

    ws_drill := prm_drill; 
	if prm_drill = 'C' then   -- adicionado 02/03/2022 (consulta customizada)
	    ws_saida := 'S';       
	end if;
	
	ws_html_t := ''; 
	if prm_drill = 'R' then  
	    ws_saida := 'H';       
	end if;

    if ws_saida = 'S' or ws_saida = 'O' then  -- adicionado C - 02/03/2022 (consulta customizada)
		fcl.gera_conteudo(ws_excel, ws_saida, '<?xml version="1.0" encoding="UTF-8"?><?mso-application progid="Excel.Sheet"?>');
		fcl.gera_conteudo(ws_excel, ws_saida, '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" xmlns:html="http://www.w3.org/TR/REC-html40" xmlns:x2="http://schemas.microsoft.com/office/excel/2003/xml">');
		fcl.gera_conteudo(ws_excel, ws_saida, '<Worksheet ss:Name="Plan1"><Table>', '', '');
    end if; 

	if prm_dashboard <> 'false' then
	    ws_propagation := prm_propagation;
	end if;

	select column_value into ws_subquery from table(fun.vpipe((ws_arr(45)))) where rownum = 1;

    ws_isolado := ws_arr(16);

	if(instr(prm_posx, '-') = 1) then
		ws_posix := '5px';
	else
		ws_posix := prm_posx;
	end if;

	if(instr(prm_posy, '-') = 1) then
		ws_posiy := '65px';
	else
		ws_posiy := nvl(prm_posy, 0);
	end if;

    select cod into ws_cod from objetos where cd_objeto = ws_objeto;

	if prm_dashboard <> 'false' then
	    ws_order := 'order: '||ws_posix||';';
	else
		ws_order := 'left: '||ws_posix||';';
	end if;

	ws_posicao := '';
	if nvl(trim(prm_posx),'NOLOC') <> 'NOLOC' and prm_drill <> 'C'  then
	    ws_posicao := 'position: absolute; top:'||ws_posiy||'; left: 5px; '||ws_order||' ';
	else
	    if(prm_drill = 'O') then
		    ws_posicao := ' position: absolute; top: 8px; left: 8px; ';
		end if;
	end if;

	if prm_dashboard <> 'N' and prm_drill <> 'C' then
	    ws_posicao := ws_posicao||' margin-top: '||ws_arr(13)||';';
		ws_posicao := ws_posicao||' margin-right: '||ws_arr(12)||';';
		ws_posicao := ws_posicao||' margin-bottom: '||ws_arr(10)||';';
		ws_posicao := ws_posicao||' margin-left: '||ws_arr(11)||';';
	end if;

	ws_colup     := prm_colup;
	ws_coluna    := prm_coluna;

	if prm_drill = 'C' then
        ws_agrupador := prm_agrupador;
	else
	    ws_agrupador := fun.conv_template(prm_visao, prm_agrupador);
	end if;

	-- DRILL - pega atributos da drill, se houver 
	----------------------------------------------------------------------------------------------------------
	ws_ordem_drill := null;
	if prm_drill = 'Y' then -- mudanca para usar ordernacao nos "reabrir"
		-- Procura ordenação da drill,  1-prm_screm+ws_usuario, 2-DEFAULT+ws_usuario, 3-DEFAULT+DWU
	    for a in 1..3 loop
			if ws_ordem_drill is null then 
				select max(upper(propriedade)) into ws_ordem_drill from object_attrib 
				 where cd_object = ws_obj_html
				   and cd_prop   = 'ORDEM' 
				   and screen    = decode(a,1,prm_screen,'DEFAULT') 
				   and owner     = decode(a,3,'DWU',ws_usuario);
			end if; 
		end loop; 
		--
        if nvl(prm_cd_goto,0) <> 0 then
            select nvl(max(cs_coluna), ws_coluna), nvl(max(cs_agrupador),ws_agrupador), nvl(max(cs_colup), ws_colup), nvl(ws_ordem_drill, max(orderby))
            into ws_coluna, ws_agrupador, ws_colup, ws_ordem_drill 
            from GOTO_OBJETO
            where cd_goto_objeto = prm_cd_goto ; 
        end if;
		--
	end if; 	 	
	-- dando erro quando a coluna invisivel é selecionada no meio 06/12/23
	/* ws_agrupador_aux	:= null;
	ws_invisivel_aux	:= null;

	if length(ws_arr(53)) > 0 then
		for a in (select column_value as cd_coluna from table( fun.vpipe(ws_agrupador)) where column_value is not null) loop
			select count(*) into ws_count from table( fun.vpipe(ws_arr(53))) where column_value = a.cd_coluna;

			if ws_count = 0 then
				if ws_agrupador_aux is null then
					ws_agrupador_aux := a.cd_coluna;
				else
					ws_agrupador_aux := ws_agrupador_aux||'|'||a.cd_coluna;
				end if;
			else
				if ws_invisivel_aux is null then
					ws_invisivel_aux := a.cd_coluna;
				else
					ws_invisivel_aux := ws_invisivel_aux||'|'||a.cd_coluna;
				end if;
			end if;
		end loop;
		ws_agrupador := ws_agrupador_aux||'|'||ws_invisivel_aux;
	end if;
 */
	ws_rp	      := prm_rp;
	ws_mode       := 'ED';
	ws_texto      := prm_parametros;
    ws_parametros := fun.converte(prm_parametros);

	open nc_colunas;
		loop
			fetch nc_colunas bulk collect into ret_mcol limit 2000;
			exit when nc_colunas%NOTFOUND;
		end loop;
	close nc_colunas;

	ws_counter := 0;
	loop

	    ws_counter := ws_counter + 1;
	    if  ws_counter > ret_mcol.COUNT then
	    	exit;
	    end if;
		if trim(upper(ret_mcol(ws_counter).st_alinhamento_cab)) = 'DEFAULT' then
			ret_mcol(ws_counter).st_alinhamento_cab := ret_mcol(ws_counter).st_alinhamento;
		end if;
	    if trim(ret_mcol(ws_counter).st_agrupador) <> 'SEM' and fun.setem(ws_agrupador, trim(ret_mcol(ws_counter).cd_coluna)) and (trim(ret_mcol(ws_counter).st_invisivel) <> 'S') then
		    ws_scol := ws_scol + 1;
	    end if;
		-- Verifica se a coluna está no attributo de invisivel 
		select count(*) into ws_count from table(fun.vpipe((ws_arr(53)))) where column_value = ret_mcol(ws_counter).cd_coluna; -- v001
		if ws_count > 0 then 
			ret_mcol(ws_counter).invisivel := 'S';
		end if;
		-- Verifica se tem destaque para a coluna -- v001
		select sum(DECODE(lower(tipo_destaque),'normal',1,'celula barra',1,0)), 
			   sum(DECODE(lower(tipo_destaque),'linha' ,1,'estrela',     1,0)), 
			   sum(DECODE(lower(tipo_destaque),'total' ,1,'total barra', 1,0)),
			   sum(DECODE(instr(conteudo,'!['),0,0,1))
		  into ret_mcol(ws_counter).qt_destaque_celula,
			   ret_mcol(ws_counter).qt_destaque_linha, 
			   ret_mcol(ws_counter).qt_destaque_total,
			   ret_mcol(ws_counter).qt_destaque_refcol
		  from destaque
	 	 where ( cd_usuario in (ws_usuario, 'DWU') OR cd_usuario in (select cd_group from gusers_itens where cd_usuario = ws_usuario) ) 
           and cd_objeto      = ws_objeto 
           and cd_coluna      = ret_mcol(ws_counter).cd_coluna; 

	end loop;

	if nvl(ws_objeto,'%$%') <> '%$%' and ws_objeto <> 'newquery' then
	   ws_rp := ws_arr(52);
	end if;

	ws_sem := 1;

	if  substr(ws_parametros,length(ws_parametros),1)='|' then
        ws_parametros := substr(ws_parametros,1,length(ws_parametros)-1);
    end if;

	ws_ordem := '';
	ws_countor := 0;

	begin
	    select upper(propriedade) into ws_ordem_query from object_attrib where cd_object = ws_objeto and screen = prm_screen and CD_PROP = 'ORDEM' and owner = ws_usuario and rownum = 1;
	exception when others then 
		begin 
			select upper(propriedade) into ws_ordem_query from object_attrib where cd_object = ws_objeto and screen = 'DEFAULT' and CD_PROP = 'ORDEM' and owner = ws_usuario and rownum = 1;
		exception when others then 
			begin 
				select upper(propriedade) into ws_ordem_query from object_attrib where cd_object = ws_objeto and screen = 'DEFAULT' and CD_PROP = 'ORDEM' and owner = 'DWU' and rownum = 1;
			exception when others then 
				ws_ordem_query := '1'; 
			end ; 
		end;
	end;
	if prm_drill = 'Y' and ws_ordem_drill is not null then 
		ws_ordem_query := ws_ordem_drill; 
    elsif prm_drill = 'Y' and ws_ordem_drill is null and nvl(prm_cd_goto,0) = 0 then
        ws_ordem_query := '1'; 
	end if; 	


    ws_ordem := ws_ordem_query;

	if length(ws_subquery) > 0 then
	    ws_tmp_jump := 'seta '||ws_subquery;
	else
	    ws_tmp_jump := 'setadown';
	end if;

	if length(ws_subquery) > 0 then
        ws_subquery := 'data-subquery="'||ws_subquery||'"';
	end if;

	select nvl(show_only, 'N') into ws_show_only from usuarios where usu_nome = ws_usuario;

	if ws_arr(25) <> '0' and ws_show_only = 'S' then
	    ws_full := ' full';
	end if;

	if prm_drill = 'Y' then
	    ws_full := ' drill'||ws_full;
	end if;

	if length(ws_arr(4)) > 0 and ws_saida <> 'H' then
		ws_borda := 'border: 1px solid '||trim(ws_arr(4))||';';
	end if;

	if prm_drill <> 'Y' then
	    ws_html := 'data-swipe=""';
	end if;

	if nvl(fun.getprop (ws_objeto, 'REORDER'),'S') = 'S' then 
		ws_html := ws_html ||' data-reorder-msg="Reordena&ccedil;&atilde;o bloqueada para este objeto"';
	else
		ws_html := ws_html ||' data-reorder-msg=""';
	end if;	
    
	-- começo do objeto - abre a DIV do objeto 
	if  prm_drill = 'C' then
		htp.p('<div id="'||ws_obj_html||'" class="dragme front custom'||ws_full||'" '||ws_html||'>');
	else 
	    htp_p('<div id="'||ws_obj_html||'" onmousedown="'||ws_propagation||'" class="dragme front'||ws_full||'" '||ws_html||'>');
	end if;    

	    select subtitulo, nm_objeto, fun.subpar(ds_objeto, prm_screen) into ws_subtitulo, ws_nome, ws_obs from objetos where cd_objeto = ws_objeto;
		ws_obs := replace(ws_obs,'"', '&quot;'); 


		if  nvl(ws_objeto,'%?%')<>'%?%' then
			ws_titulo := ws_nome;
		else
			ws_titulo := '';
		end if;

		if ws_arr(46) <> 'X' then
			ws_top := ws_arr(46);
		end if;
		
		ws_param_titulo := null;
		if prm_drill = 'R' then  -- chamada por report/email 
			ws_param_titulo := ws_parametros; 
		end if; 

		obj.titulo(ws_objeto, prm_drill, ws_titulo, prm_screen, prm_usuario => ws_usuario, prm_param_filtro => ws_param_titulo, prm_track => prm_track, prm_cd_goto => prm_cd_goto, prm_titulo => ws_titulo_html);
		htp_p(ws_titulo_html); 

		if ws_saida <> 'H' then 
			obj.opcoes(prm_objeto=>ws_obj_html, prm_tipo=>'CONSULTA', prm_par=>'', prm_visao=>prm_visao, prm_screen=>prm_screen, prm_drill=>prm_drill, prm_usuario => ws_usuario);  -- Monta menu OPCOES
		end if; 

		if ws_saida <> 'H' then 
			htp_p('<form name="busca" style="display: none;">');
					htp_p('<input type="hidden" name="show_'||ws_obj_html||'" id="show_'||ws_obj_html||'" value="prm_drill='||prm_drill||'&prm_objeto='||ws_objeto||'&PRM_POSX='||ws_posix||'&PRM_ZINDEX='||prm_zindex||'&PRM_POSY='||ws_posiy||'&prm_parametros='||ws_parametros||'&prm_screen='||prm_screen||'&prm_track=&prm_objeton=" />');
					htp_p('<input type="hidden" name="npar_'||ws_obj_html||'" id="par_'||ws_obj_html||'" value="'||ws_parametros||'" />');
					htp_p('<input type="hidden" name="nord_'||ws_obj_html||'" id="ord_'||ws_obj_html||'" value="'||ws_ordem||'" />');
					htp_p('<input type="hidden" name="nmvs_'||ws_obj_html||'" id="mvs_'||ws_obj_html||'" value="'||prm_visao||'" />');
					htp_p('<input type="hidden" name="ncol_'||ws_obj_html||'" id="col_'||ws_obj_html||'" value="'||ws_coluna||'" />');
					htp_p('<input type="hidden" name="nagp_'||ws_obj_html||'" id="agp_'||ws_obj_html||'" value="'||ws_agrupador||'" />');
					htp_p('<input type="hidden" name="nrps_'||ws_obj_html||'" id="rps_'||ws_obj_html||'" value="'||ws_rp||'" />');
					htp_p('<input type="hidden" name="ndri_'||ws_obj_html||'" id="dri_'||ws_obj_html||'" value="'||ws_drill||'" />');
					htp_p('<input type="hidden" name="ncup_'||ws_obj_html||'" id="cup_'||ws_obj_html||'" value="'||ws_colup||'" />');
					htp_p('<input type="hidden" name="nsco_'||ws_obj_html||'" id="sco_'||ws_obj_html||'" value="" />' );
					htp_p('<input type="hidden" id="excel_mask_'||ws_obj_html||'" value="'||fun.getprop(ws_objeto, 'EXCEL_MASK')||'" />' );
			htp_p('</form>');
		end if; 

	    -- Style da div principal 	
		if ws_arr(39) <> 'N' then
        	ws_html := 'div#'||ws_obj_html||', span#'||ws_obj_html||'_ds { border-radius: 0; } div#'||ws_obj_html||' ';
		end if;
		ws_html_1 := '<style>div#'||ws_obj_html||' { background-color: '||ws_arr(30)||'; '||ws_posicao||' max-width: calc(100% - '||ws_arr(11)||' - '||ws_arr(12)||'); '||ws_borda||' }</style>'; 
		ws_html_2 := '<style>div#'||ws_obj_html||' table tr td, div#'||ws_obj_html||' table tr th { font-size: '||ws_arr(24)||'; font-family: '||ws_arr(23)||'; } '||ws_html||'</style>'; 

		-- Monta style para ocultar linhas de subtotal(todas) - ws_arr(44)(SO_TOT)
		if ws_arr(44) = 'S' or nvl(ws_prop_ocultar_subtotal,'NENHUM') = 'TODOS' then 
			ws_html_3 := ws_html_3||'div#'||ws_obj_html||' tr.total.normal { display: none; }';
		end if;
		-- MOnta style para ocultar o total geral - ws_arr(41)(OMITIR_TOT)  
		if ws_arr(41) = 'S' then
			ws_html_3 := ws_html_3||'div#'||ws_obj_html||' tr.total.geral { display: none; }';
		end if;
		if ws_html_3 is not null then 
			ws_html_3 := '<style>'||ws_html_3||'</style>';
		end if;

		-- Monta style para ocultar linhas de subtotal individualmente 
		if nvl(ws_prop_ocultar_subtotal,'NENHUM') not in ('NENHUM','TODOS') then 
			ws_html_3 := ws_html_3||'<style>';
			for a in (select column_value from table( fun.vpipe(ws_prop_ocultar_subtotal)) where column_value is not null) loop
				ws_html_3 := ws_html_3||'div#'||ws_obj_html||' tr.total.normal.'||a.column_value||' { display: none; }';
			end loop;
			ws_html_3 := ws_html_3||'</style>';				
		end if; 		

		htp_p(ws_html_1||ws_html_2||ws_html_3); 

		ws_show_filtros  := fun.show_filtros(trim(ws_parametros), ws_cursor, ws_isolado, ws_objeto, prm_visao, prm_screen);
		ws_show_destaque := fun.show_destaques(trim(ws_parametros), ws_cursor, ws_isolado, ws_objeto, prm_visao, prm_screen);

		if ws_saida <> 'H' then 
			htp_p('<span class="turn">');
					htp_p(ws_span_tempo);

					if nvl(ws_obs, 'N/A') <> 'N/A' then
						htp_p('<span class="obs" data-obs="<h4>'||fun.lang('Observa&ccedil;&otilde;es do objeto')||'</h4><span>'||ws_obs||'</span>" onclick="objObs(this.getAttribute(''data-obs''));">');
							htp_p('<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" id="Camada_1" x="0px" y="0px" viewBox="0 0 1280 1280" style="fill: gray;" xml:space="preserve"><g><g><path  d="M590,249.13h100v446.71H590V249.13z M590,807.52h100v223.36H590V807.52z"/></g><path  d="M640,1256c-83.14,0-163.81-16.29-239.79-48.43c-73.36-31.03-139.23-75.44-195.79-131.99   c-56.56-56.56-100.97-122.43-131.99-195.79C40.29,803.82,24,723.14,24,640s16.29-163.81,48.43-239.79   c31.03-73.36,75.44-139.23,131.99-195.79S326.85,103.46,400.21,72.43C476.19,40.29,556.86,24,640,24s163.81,16.29,239.79,48.43   c73.36,31.03,139.23,75.44,195.79,131.99c56.56,56.55,100.97,122.43,131.99,195.79C1239.71,476.19,1256,556.86,1256,640   s-16.29,163.82-48.43,239.79c-31.03,73.36-75.44,139.23-131.99,195.79c-56.56,56.56-122.43,100.97-195.79,131.99   C803.81,1239.71,723.14,1256,640,1256z M640,123.47c-69.75,0-137.39,13.65-201.04,40.57c-61.5,26.01-116.75,63.26-164.2,110.72   c-47.45,47.45-84.7,102.7-110.72,164.2c-26.92,63.65-40.57,131.29-40.57,201.04s13.65,137.39,40.57,201.04   c26.01,61.5,63.26,116.75,110.72,164.2c47.45,47.45,102.7,84.7,164.2,110.72c63.65,26.92,131.29,40.57,201.04,40.57   s137.39-13.65,201.04-40.57c61.5-26.01,116.75-63.26,164.2-110.72c47.45-47.45,84.7-102.7,110.72-164.2   c26.92-63.65,40.57-131.29,40.57-201.04s-13.65-137.39-40.57-201.04c-26.01-61.5-63.26-116.75-110.72-164.2   c-47.45-47.45-102.7-84.7-164.2-110.72C777.39,137.12,709.75,123.47,640,123.47z"/></g></svg>');
						htp_p('</span>');
					end if;

					if length(trim(ws_show_filtros)) > 3 then
						htp_p('<span class="filtros" style="color: gray;">F</span>');
					end if;

					if length(trim(ws_show_destaque)) > 3 then
						htp_p('<span class="destaques">');
						htp_p('</span>');
					end if;
			htp_p('</span>');

			htp_p('<ul id="'||ws_obj_html||'-filterlist" style="display: none;" >',prm_prn => 'PRN'); --PRN
				htp_p(ws_show_filtros,prm_prn => 'PRN'); --PRN
			htp_p('</ul>',prm_prn => 'PRN'); --PRN

			htp_p('<ul id="'||ws_obj_html||'-destaquelist" style="display: none;" >',prm_prn => 'PRN'); --PRN
				htp_p(ws_show_destaque,prm_prn => 'PRN'); --PRN
			htp_p('</ul>',prm_prn => 'PRN'); --PRN

			htp_p('<div id="dados_'||ws_obj_html||'" data-formato_excel="'||ws_formato_excel||'" 
												data-left="'||ws_posix||'" 
												data-top="'||ws_posiy||'" 
												data-drill="'||prm_drill||'" 
												data-grupo="'||ws_arr(52)||'" 
												data-full="'||ws_arr(25)||'" 
												data-visao="'||prm_visao||'" 
												data-track="'||prm_track||'"
												data-cd_goto="'||prm_cd_goto||'"></div>');
		end if; 

		begin
			ws_sql := core.MONTA_QUERY_DIRECT(prm_visao, ws_coluna, ws_parametros, ws_rp, ws_colup, ws_query_pivot, ws_query_montada, ws_lquery, ws_ncolumns, ws_pvcolumns, ws_agrupador, ws_mfiltro, ws_objeto, ws_ordem_query, prm_screen => prm_screen, prm_cross => 'N', prm_cab_cross => ws_cab_cross, prm_self => prm_self,prm_usuario => ws_usuario);

			--select nvl(show_only, 'N') into ws_show_active from usuarios where trim(usu_nome) = ws_usuario;
			if ws_show_only <> 'S' then
				INSERT INTO LOG_EVENTOS VALUES (SYSDATE, substr(prm_visao||'/'||ws_coluna||'/'||trim(ws_parametros)||'/'||ws_rp||'/'||ws_colup||'/'||WS_AGRUPADOR,1,2000), ws_usuario, 'ALL', 'no_user', '01');
				commit;
			end if;

		exception when others then 
			raise ws_semquery;
		end;
		

		if ws_sql like 'Excesso de filtros%' then
		    raise ws_excesso_filtro;
		end if;

		-- Monta texto com o SQL 
		ws_queryoc := null;
		ws_counter := 0;
		loop
			ws_counter := ws_counter + 1;
			exit when (ws_counter > ws_query_montada.COUNT); 
			ws_queryoc := ws_queryoc||ws_query_montada(ws_counter);
		end loop;
		if ws_queryoc is null then  -- Caso não exista query_montada pega a query do PIVOT (se houver pivot)
			ws_queryoc := ws_query_pivot; 
		end if; 	

		if ws_admin = 'A' or ws_log_exec in ('S','D') then  -- Grava a ultima query executada para o objeto 
			begin  
				ws_cursor := dbms_sql.open_cursor;
				dbms_sql.parse( c => ws_cursor, statement => ws_query_montada, lb => 1, ub => ws_lquery, lfflg => true, language_flag => dbms_sql.native );
				ws_binds := core.bind_direct(ws_parametros, ws_cursor, '', ws_objeto, prm_visao, prm_screen,prm_usuario => ws_usuario);
				ws_binds := replace(ws_binds, 'Binds Carregadas=|', '');
				dbms_sql.close_cursor(ws_cursor);				
				ws_queryoc := nvl(substr(fun.replace_binds_clob (ws_queryoc, ws_binds),1,32000),'ERRO');
			exception when others then 
				insert into bi_log_sistema values (sysdate,'Erro realizando replace dos BINDS ['||ws_objeto||']:'|| DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, ws_usuario,'ERRO');
			end; 
		end if; 		

		if ws_admin = 'A' then  -- Grava a ultima query executada para o objeto 
			begin  
				delete bi_object_query where cd_object = ws_objeto and nm_usuario = ws_usuario;
				insert into bi_object_query (cd_object, nm_usuario, dt_ultima_execucao, query) values (ws_objeto, ws_usuario, sysdate, ws_queryoc ); 
			exception when others then 
				insert into bi_log_sistema values (sysdate,'Erro gravando em bi_object_query ['||ws_objeto||']:'|| DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, ws_usuario,'ERRO');
			end; 
			commit; 
		end if;

		if ws_log_exec in ('S','D') then
			fun.log_exec_atu ('INSERT', ws_log_exec, ws_log_exec_id, ws_objeto, ws_usuario, 'CONSULTA', 10, 'INICIO', ws_queryoc); 
			commit;
		end if; 

		if instr(ws_obj_html, 'trl') = 0 and ws_saida <> 'H' then  --Se não for Drill 
			htp_p('<span id="'||ws_obj_html||'sync" class="sync" title="'||ws_query_hint||'"><img src="'||ws_owner_bi||'.fcl.download?arquivo=sinchronize.png" /></span>');
		end if;

		ws_title := 'Query: '||chr(13)||ws_queryoc;

		if ws_sql = 'Sem Query' then
		    raise ws_semquery;
		end if;

		if ws_sql = 'Sem Dados' then
			ws_nodata_passo := '1';
		    raise ws_nodata;
		end if;


		ws_sql_pivot := ws_query_pivot;
		ws_html      := ''; 

		if ws_saida <> 'H' then 
			loop
				ws_counter := ws_counter + 1;
				if  ws_counter > ws_query_montada.COUNT then
					exit;
				end if;
				if ws_arr(42) = 'S' THEN
					if instr(ws_obj_html, 'trl') = 0 then
						if instr(ws_query_montada(ws_counter), 'SEG') > 0 and ws_admin = 'A' then
							htp_p('<span style="z-index: 2; height: 15px; width: 16px; position: absolute; top: 7px; right: 7px; opacity: 0.3;">');
								htp_p('<svg height="512pt" viewBox="-34 0 512 512" width="512pt" xmlns="http://www.w3.org/2000/svg" style="width: inherit;height: inherit;"><path d="m221.703125 0-221.703125 128v256l221.703125 128 221.703125-128v-256zm176.515625 136.652344-176.515625 101.914062-176.515625-101.914062 176.515625-101.910156zm-368.132812 26.027344 176.574218 101.941406v203.953125l-176.574218-101.945313zm206.660156 305.894531v-203.953125l176.574218-101.941406v203.949218zm0 0"></path></svg>');
							htp_p('</span>');
						end if;
					end if;
				end if;
			end loop;
		end if; 

	ws_counter := 0;
	ws_amostra_top:= nvl(fun.getprop(prm_objeto,'TOP'),'X');
	ws_amostra := to_number(ws_arr(3));
	
	-- CONFERE SE O OBJETO POSSUI ALGUM TIPO DE AMOSTRA OU AMOSTRAGEM COM O GROUP BY ROLLUP 14/07/2023
	-- COMENTADO A PEDIDO DO SUPORTE DEVIDO A RECLAMAÇÕES DOS CLIENTES .
	--if (ws_amostra > 0 or (ws_amostra_top <> 'X' and to_number(ws_amostra_top) > 0) ) and ws_arr(52) = 'ROLL' then
	--	raise ws_err_amostra;
	--end if;

	-- Define propriedades das colunas do cursor/query 
	begin

		ws_cursor := dbms_sql.open_cursor;
		dbms_sql.parse( c => ws_cursor, statement => ws_query_montada, lb => 1, ub => ws_lquery, lfflg => true, language_flag => dbms_sql.native );
		ws_binds := core.bind_direct(ws_parametros, ws_cursor, '', ws_objeto, prm_visao, prm_screen,prm_usuario => ws_usuario);
		ws_binds := replace(ws_binds, 'Binds Carregadas=|', '');

		ws_counter := 0;

		loop
			ws_counter := ws_counter + 1;
			if  ws_counter > ws_ncolumns.COUNT-1 then
				exit;
			end if;
			
			begin
				dbms_sql.describe_columns(ws_cursor, ws_counter, rec_tab);

				if rec_tab(ws_counter).col_type = 12 and ret_mcol(ws_ccoluna).nm_mascara = 'SEM' then
					dbms_sql.define_column(ws_cursor, ws_counter, dat_coluna);
				else
					dbms_sql.define_column(ws_cursor, ws_counter, ret_coluna, 3000);
				end if;
			exception 
			    when others then
				    dbms_sql.define_column(ws_cursor, ws_counter, ret_coluna, 3000);
			end;

		end loop;

		/***************************************************************************************************************************
		* - desabilitado em 06/03/2024 - evitar realizar um .execute desnecessário, e que deixa o objeto mais lento 
		ws_linhas := dbms_sql.execute(ws_cursor);
		ws_linhas := dbms_sql.fetch_rows(ws_cursor);

		if  ws_linhas = 1 then
		    ws_vazio := False;
		else
			dbms_sql.close_cursor(ws_cursor);
	        ws_vazio := True;
      		raise ws_nodata;
        end if;
		*************************************************************************************/

		dbms_sql.close_cursor(ws_cursor);
    
	end;
	
	-- Tempo de query (banco)
	-- 0.0000580   				---> 5seg
	-- 0.000115741 				---> 10seg
	-- 0.00023148148148148146	---> 20seg

	if ws_arr(43) = 'S' or (sysdate > (ws_tempo + (0.0000580))) then

		--((sysdate-ws_tempo)*1440)*60*1000)
		insert into query_stat
					(id_stat,dt_stat,cd_objeto,nm_micro_visao,nm_tabela,cs_coluna,cs_colup,cs_agrupador,cs_utilizados,nm_fast_cube,tempo)
			 values			   
			 		(ws_usuario, sysdate, ws_objeto, /*ws_arr(43)*/prm_visao, '', substr(ws_parametros, 1 ,instr(ws_parametros,'|')-1), '', '', '', '', round(( sysdate-ws_tempo)*1440*60)); --removido *1000 para exibir em segundos

	end if;

	if ws_admin = 'A' then
		if prm_drill <> 'O' and ws_saida <> 'H' then
			htp_p('<textarea readonly class="faketitle" id="'||ws_obj_html||'faketitle" ontouch="document.getElementById('''||ws_obj_html||'faketitle'').select(); document.execCommand(''Copy'');">');
				begin
					-- fcl.replace_binds(ws_title, ws_binds);
					ws_html_1 := fun.replace_binds_clob (ws_title, ws_binds); 
					htp_p(ws_html_1);
				exception when others then
					htp_p('Query excedeu o limite de 24 Kb');
				end;
			htp_p('</textarea>');
		end if;
	end if;

	begin
		ws_largura := ws_arr(33);
		if ws_largura = '0' then
		    ws_largura := '4000';
		end if;
	exception when others then
	    ws_largura := '4000';
	end;

	begin
	    ws_ctemp := ws_arr(2);
		if ws_ctemp = '0' then
		    ws_ctemp := '6000';
		end if;
	exception when others then
	    ws_ctemp := '6000';
	end;

	ws_fixed := nvl(ws_arr(18), '9999')+1;
	if length(ws_arr(48)) > 0 and ws_fixed > 0 then
		ws_fixed := 999;
	end if;

	if prm_drill = 'C' then 
		ws_ctemp := '0'; 
	end if; 

	if ws_saida <> 'O' then

		-- Style - inicio 
	    ws_html_1 := '<style>'; 
		if ws_saida = 'H' then 
			ws_html_1 := ws_html_1||'div#'||ws_obj_html||'dv2 { max-width: '||ws_largura||'px; cursor: default;';
		else 	
			ws_html_1 := ws_html_1||'div#'||ws_obj_html||'dv2 { max-width: '||ws_largura||'px; '||fcl.fpdata(ws_ctemp,'0','',' max-height: '||ws_ctemp||'px;')||' cursor: default;';
		end if; 			
		if ws_arr(14) = 'S' THEN
			ws_html_1 := ws_html_1 || ' background: -webkit-linear-gradient('||ws_arr(27)||', '||ws_arr(28)||'); background: linear-gradient('||ws_arr(27)||', '||ws_arr(28)||');';
		end if;
		ws_html_1 := ws_html_1 || '}';

		ws_html_1 := ws_html_1 ||' table#'||ws_obj_html||'c tr.total td, div#'||ws_obj_html||'fixed li.total { background-color: '||ws_arr(29)||' !important; color: '||ws_arr(22)||'; }';
		if  ws_arr(14) <> 'S' THEN
			ws_html_1 := ws_html_1 ||'table#'||ws_obj_html||'c tr.cl { background: '||ws_arr(27)||'; color: '||ws_arr(20)||'; }';
			ws_html_1 := ws_html_1 ||'table#'||ws_obj_html||'c tr.es { background: '||ws_arr(28)||'; color: '||ws_arr(21)||'; }';
		else
			ws_html_1 := ws_html_1 ||'table#'||ws_obj_html||'c tr.cl { color: '||ws_arr(20)||'; }';
			ws_html_1 := ws_html_1 ||'table#'||ws_obj_html||'c tr.es { color: '||ws_arr(21)||'; }';
		end if;
		ws_html_1 := ws_html_1 ||' div#'||ws_obj_html||' table tr td, div#'||ws_obj_html||' table tr th { outline: 1px solid '||ws_arr(31)||'; outline-offset: 0; }';
		ws_html_1 := ws_html_1 ||' td.flag, li.seta, td.seta, td.setadown { padding-left: 13px; }';

		if ws_arr(17) = 'S' then 
			ws_html_1 := ws_html_1 ||' table#'||ws_obj_html||' tbody tr.total.geral td, table#'||ws_obj_html||'c tbody tr.total.geral td { bottom: 1px; position: sticky; position: -webkit-sticky; }';
		end if;
		ws_html_1 := ws_html_1 ||' div#'||ws_obj_html||'dv2 thead tr { background: '||ws_arr(26)||'; color: '||ws_arr(19)||'; }';
		ws_html_1 := ws_html_1 ||'</style>'; 

		htp_p(ws_html_1,prm_prn => 'PRN'); --PRN
		-- Style - fim  

		if ws_saida = 'H' then --Style para fixar a largura da tabela
			ws_html_1 := '<style> div#'||ws_obj_html||' { width: '||ws_largura||'px; }, table#'||ws_obj_html||'c { width: 100%; } </style>'; 
			htp_p(ws_html_1); 
		end if; 

		if ws_saida = 'H' then
			ws_html_1 := '<div class="fonte" id="'||ws_obj_html||'dv2">';
		else 	
			ws_html_1 := '<div class="fonte" data-resize="" data-maxheight="'||ws_ctemp||'" data-maxwidth="'||ws_largura||'" id="'||ws_obj_html||'dv2">';
		end if; 	
		ws_html_1 := ws_html_1 ||'<div id="'||ws_obj_html||'m">';
		ws_html_1 := ws_html_1 ||'<table id="'||ws_obj_html||'c">'; -- Abertura da Tabela 

		htp_p(ws_html_1,prm_prn => 'PRN'); --PRN

	end if;

	ws_counter     := 0;
	ws_counterid   := 1;
	ws_ccoluna     := 0;
    ws_step        := 0;
	ws_qt_cab_agru := 0; 

	if ws_saida <> 'O' then
	    if ws_arr(32) = 'bold' then
            ws_jump := 'bld';
		end if;
		htp_p('<thead class="'||ws_jump||'">');
	end if;

    if ws_saida = 'S' or ws_saida = 'O' then
	    fcl.gera_conteudo(ws_excel, ws_saida, '<Row>', '', '');
    end if;

	-- Carrega todas as anotações do objeto num array, para agilizar a consulta 
	-- Atenção: Criado var_conteudo ANOT_HABILITA, para uso durante validação da funcionalidade, excluir var_conteudo depois de implantada nos clientes
	--------------------------------------------------------------------------------------
	if nvl(fun.ret_var('ANOT_HABILITA'),'N') = 'S' then 
		if ws_prop_usuario_anotacao <> 'NENHUM' then  -- Permite anotação no objeto 
			fcl.anotacao_monta_anot ( ws_objeto, prm_screen, ws_arr_anot);
		end if; 	
	end if; 	
	
	---------------------------------------------------------------------------------------
    -- Monta 1a linha do cabeçalho - somente Colunas agrupadores (sem SUM, NVL, MIN, MAX, etc...)
	---------------------------------------------------------------------------------------
	if ws_saida <> 'O' then
		htp_p('<tr>');
	end if;

	ws_row := ws_pvcolumns.COUNT+1;

	if ws_saida <> 'O' then  -- Coluna da seta no cabeçalho 
	    htp_p('<th rowspan="'||ws_row||'" colspan="1" class=" colagr fix" style="cursor: auto" ></th>');		

        ws_qt_cab_agru := ws_qt_cab_agru + 1; 
		ws_fixed := ws_fixed - 1; 
	end if;

	begin
    	loop
			ws_counter := ws_counter+1;
			ws_counterid := ws_counterid+1;

			if  ws_counter > ws_ncolumns.COUNT-2 then
				exit;
			end if;

			ws_ccoluna := 1;

			loop
				if ws_ccoluna = ret_mcol.COUNT or ret_mcol(ws_ccoluna).cd_coluna = ws_ncolumns(ws_counter) then
					exit;
				end if;

				ws_ccoluna := ws_ccoluna + 1;
			end loop;

			if  ret_mcol(ws_ccoluna).st_agrupador = 'SEM' then

			    ws_count     := ws_pvcolumns.COUNT+1;
				ws_qt_colagr := ws_qt_colagr + 1; 

				ws_hint := '';
				select hint into ws_hint from micro_coluna where cd_micro_visao = prm_visao and cd_coluna = ret_mcol(ws_ccoluna).cd_coluna;

				ws_content := replace(ret_coluna,'/',     '&#47;');

				if nvl(ws_hint, 'N/A') <> 'N/A' then
					ws_hint := 'title="'||ws_hint||'"';
				end if;

				-- select count(*) into ws_count_v from table(fun.vpipe((ws_arr(53)))) where column_value = ret_mcol(ws_ccoluna).cd_coluna;
				ws_count_v := 0;    -- v001
				if ret_mcol(ws_ccoluna).invisivel = 'S' then 
					ws_count_v := 1;
				end if; 			

				-- Define as colunas fixas e invisíveis 
				ws_fix := '';  
				if ws_fixed > 1 then --   and ws_counter < ws_fixed then (destivado em 21/09/2022 para corrigir erro em colunas fixas no cabeçalho) 
					ws_fix   := ' fix';
					ws_fixed := ws_fixed-1;					
				end if; 
				if ws_count_v <> 0 then
					ws_fix   := ws_fix||' inv';
					ws_qt_colinv := ws_qt_colinv + 1;   -- Soma quantidade de colunas invisíveis 
				end if; 	
				ws_fix := ' colagr'||ws_fix ;  -- Adiciona a classe de coluna agrupadora 

				-- Se não imprime código, mas tem ligação (tem código) e é a coluna do código (ws_repeat = 'show')
				if  ret_mcol(ws_ccoluna).st_com_codigo = 'N' and ret_mcol(ws_ccoluna).cd_ligacao <> 'SEM' and ws_repeat = 'show' then 
					ws_qt_colinv_cod := ws_qt_colinv_cod + 1;   -- Soma quantidade de colunas invisíveis (escondidas) 					
					if ws_count_v <> 0 then 
						ws_qt_colinv := ws_qt_colinv - 1 ;
					end if; 	
					ws_estilo_linha := ws_estilo_linha||' div#main table#'||ws_obj_html||'c tr:nth-child(1):not(.sub) th:nth-child('||ws_counterid||'), div#main table#'||ws_obj_html||' tr:nth-child(1):not(.sub) th:nth-child('||ws_counterid||'), div#main table#'||ws_obj_html||'c tr:not(.duplicado):not(.sub) td:nth-child('||ws_counterid||'), table#'||ws_obj_html||' tr:not(.duplicado):not(.sub) td:nth-child('||ws_counterid||'), div#custom-conteudo table#'||ws_obj_html||'c tr:not(.duplicado):not(.sub) td:nth-child('||(ws_counterid-1)||'), div#custom-conteudo table#'||ws_obj_html||'c tr:not(.duplicado):not(.sub) th:nth-child('||(ws_counterid-1)||') { display: none; }';
					ws_fix := ws_fix||' print';
					ws_repeat := 'hidden';
				end if;


				/**** Comentado porque a variável ws_ordem já é preechida no inicio dessa procedure  
				-- adicionado "and screen = prm_screen" para que a seta da ordem funcione
				begin
					select upper(propriedade) into ws_ordem from object_attrib where cd_object = ws_objeto and screen = prm_screen and CD_PROP = 'ORDEM' and owner = ws_usuario and rownum = 1;
				exception when no_data_found then 
					begin
						select upper(propriedade) into ws_ordem from object_attrib where cd_object = ws_objeto and CD_PROP = 'ORDEM' and owner = 'DWU' and rownum = 1;
					exception when no_data_found then   
						ws_ordem := '1'; 
					end;
				end;
				******/ 

				begin
					select upper(replace(column_value, ret_mcol(ws_ccoluna).cd_coluna, '')) into ws_ordem_arrow from table((fun.vpipe(ws_ordem, ','))) where trim(column_value) like (ws_counter||' %');
				exception when others then
					ws_ordem_arrow := '';
				end;
				ws_th_atributos := 'data-agrupador="'||ret_mcol(ws_ccoluna).cd_coluna||'"'; 
				
				if trim(ret_mcol(ws_ccoluna).st_negrito) = 'S' then
						ws_negrito := 'bold';
				end if;

				ws_html_1 := ''; 
				if rtrim(ret_mcol(ws_ccoluna).st_invisivel) = 'S' then
					if ws_saida <> 'O' then
						htp_p('<th rowspan="'||ws_count||'" class="'||ws_ordem_arrow||' '||ws_fix||'" colspan="'||ws_cspan||'" '||ws_jump||' class="no_font" '||ws_hint||' '||ws_th_atributos||' style="text-align: '||ret_mcol(ws_ccoluna).st_alinhamento_cab||'; font-weight: '||ws_negrito||';" >',prm_prn => 'PRN'); --PRN
					end if;
				else
					if ws_saida <> 'O' then
						htp_p('<th rowspan="'||ws_count||'" class="'||ws_ordem_arrow||ws_fix||'" colspan="1" '||ws_jump||' '||ws_hint||' '||ws_th_atributos||' style="text-align: '||ret_mcol(ws_ccoluna).st_alinhamento_cab||'; font-weight: '||ws_negrito||';"  >',prm_prn => 'PRN'); --PRN
					end if;
				end if; 

				if ws_saida <> 'O' then
					if (ws_content_ant = ret_mcol(ws_ccoluna).nm_rotulo) or (ret_mcol(ws_ccoluna).cd_ligacao = 'SEM') then
						--htp.prn(fun.utranslate('NM_ROTULO', prm_visao, fun.check_rotuloc(ret_mcol(ws_ccoluna).cd_coluna, prm_visao, prm_screen), ws_padrao));
						
						--replace colocado na fun.check_rotuloc para remover as aspas quando concatenado um filtro/objeto junto
						ws_html_1 := ws_html_1 || fun.utranslate('NM_ROTULO', prm_visao, replace(fun.check_rotuloc(ret_mcol(ws_ccoluna).cd_coluna, prm_visao, prm_screen),chr(39),''), ws_padrao); 
					else
						--htp.prn('#');
						ws_html_1 := ws_html_1 ||'#'; 
					end if;
				end if;

				if ws_saida <> 'O' then
					--htp.prn('</th>');
					ws_html_1 := ws_html_1 || '</th>'; 
				end if;
				htp_p(ws_html_1,prm_prn => 'PRN'); --PRN


				if ws_saida = 'S' or ws_saida = 'O' then 
					fcl.gera_conteudo(ws_excel, ws_saida ,'<Cell><Data ss:Type="String">'||replace(fun.ptg_trans(fun.utranslate('NM_ROTULO', prm_visao, fun.check_rotuloc(ret_mcol(ws_ccoluna).cd_coluna, prm_visao, prm_screen), ws_padrao)), '<BR>', ' ')||'</Data></Cell>', '', '');
				end if;

				if nvl(trim(ret_mcol(ws_ccoluna).color),'N/A')<>'N/A' then -- criado a regra para não estourar a variavel ws_estilo_linha 30-05-22
					ws_estilo_linha := ws_estilo_linha||' div#main table#'||ws_obj_html||'c tr:not(.total):not(.geral):not(.destaqueLinha) td:nth-child('||(ws_counter+1)||'),div#main table#'||ws_obj_html||'trlc tr:not(.total):not(.geral):not(.destaqueLinha) td:nth-child('||(ws_counter+1)||') { background-color: '||ret_mcol(ws_ccoluna).color||'; }';							
				end if;

				-- Mostra a URL depois do nome ou depois do código se não tem nome (ligação)
				if ws_saida not in ('O','H') then
					if (ws_content_ant = ret_mcol(ws_ccoluna).nm_rotulo) or (ret_mcol(ws_ccoluna).cd_ligacao = 'SEM') then
						if nvl(ret_mcol(ws_ccoluna).url, 'N/A') <> 'N/A' then
							htp_p('<th rowspan="'||ws_count||'"></th>','N',prm_prn => 'PRN'); --prn
							ws_cspan := ws_cspan+1;
						end if; 
					end if; 		
				end if;

				if ws_content_ant = ret_mcol(ws_ccoluna).nm_rotulo then
					ws_repeat := 'show';
				end if;

			end if;

	    	ws_content_ant := ret_mcol(ws_ccoluna).nm_rotulo;

		end loop;

    exception when others then
        insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - ERROCOUNT', ws_usuario, 'ERRO');
        commit;
    end;

	------------------------------------------------------------------------------------------
    -- Monta linha do cabeçalho - das colunas de valores - Colunas de valores da pivotada - (somente quanto existe PIVOT)
	------------------------------------------------------------------------------------------
	ws_count := 0;
	ws_bindn  := 0;

	loop

		ws_bindn := ws_bindn + 1;
	    if  ws_bindn > ws_pvcolumns.COUNT then
		    exit;
	    end if;

		ws_html_1 := ''; 
		if ws_bindn > 1 then
		    htp_p('<tr title="2">');
        end if;

	    ws_pcursor   := dbms_sql.open_cursor;

		begin
			dbms_sql.parse(ws_pcursor, ws_sql_pivot, dbms_sql.native);
		exception
			when others then
				raise ws_semquery;
		end;

	    ws_counter := 0;
	    loop
	    	ws_counter := ws_counter + 1;
	    	if  ws_counter > ws_pvcolumns.COUNT then
	    	    exit;
	    	end if;

			dbms_sql.define_column(ws_pcursor, ws_counter, ret_colup, 3000);

		end loop;

		ws_ccoluna := 1;

	    loop
			if  ws_ccoluna = ret_mcol.COUNT or ret_mcol(ws_ccoluna).cd_coluna = ws_pvcolumns(ws_bindn) then
				exit;
			end if;
			ws_ccoluna := ws_ccoluna + 1;
	    end loop;

	    ws_binds := core.bind_direct(ws_parametros, ws_pcursor, '', ws_objeto, prm_visao, prm_screen,prm_usuario => ws_usuario);
		
		ws_binds := replace(ws_binds, 'Binds Carregadas=|', '');
		
	    ws_linhas := dbms_sql.execute(ws_pcursor);
        
		ws_count_v := 0;
		select count(*) into ws_count_v from table(fun.vpipe((ws_arr(53)))) where column_value in (select column_value from table(fun.vpipe((select cs_agrupador from ponto_avaliacao where cd_ponto = ws_objeto))));

		ws_content_ant    := '%First%';
		ws_col_sup_ant := '%First%';
	    ws_xcount         := 0;

		loop

		    ws_linhas := dbms_sql.fetch_rows(ws_pcursor);

		    if  ws_linhas <> 1 then
		        if ws_saida <> 'O' then
				    --fecha a linha, ignora o ultimo pivot que pega o próprio valor
					if ws_bindn <> ws_pvcolumns.COUNT then
			            --initcab puxado
						ws_count := 0;

						nested_calculada(ws_arr(5), '', '', ws_count);
						
						ws_colspan := ((ws_xcount*ws_scol)+ws_count)-(ws_count_v*ws_xcount);

                        -- Cabeçalho do pivot
						------------------------------------------------

						--htp.prn('<th style="text-align:center !important;" colspan="'||ws_colspan||'">');
						ws_html_1 := '<th style="text-align:center !important;" colspan="'||ws_colspan||'">'; 
						
						if  ret_mcol(ws_ccoluna).cd_ligacao <> 'SEM' then
							if  ret_mcol(ws_ccoluna).st_com_codigo = 'S' then
								ws_content_ant := ws_content_ant||'-'||fun.cdesc(ws_content_ant,ret_mcol(ws_ccoluna).cd_ligacao);
							else
								ws_content_ant := fun.cdesc(ws_content_ant,ret_mcol(ws_ccoluna).cd_ligacao);
							end if;
						end if;

						begin 
							--htp.p(trim(fun.utranslate('NM_ROTULO', prm_visao, fun.ifmascara(ws_content_ant, ret_mcol(ws_ccoluna).nm_mascara, prm_visao, prm_coluna, '', '', '', ''), ws_padrao)));
							ws_html_1 := ws_html_1 || trim(fun.utranslate('NM_ROTULO', prm_visao, fun.ifmascara(ws_content_ant, ret_mcol(ws_ccoluna).nm_mascara, prm_visao, prm_coluna, '', '', '', ''), ws_padrao)); 
						exception when others then
							--htp.p(trim(fun.utranslate('NM_ROTULO', prm_visao, ws_content_ant, ws_padrao)));
							ws_html_1 := ws_html_1 || trim(fun.utranslate('NM_ROTULO', prm_visao, ws_content_ant, ws_padrao)); 
						end;

						--htp.p('</th>');
						ws_html_1 := ws_html_1 ||'</th>'; 
						htp_p(ws_html_1); 

						--fim do initcab
					
					end if;
				end if;

			    exit;
		    end if;

		    dbms_sql.column_value(ws_pcursor, ws_bindn, ret_coluna);
			
			if ws_bindn > 1 then
			    --segundo nivel eu comparo com o pai, que é sempre único, niveis posteriores ainda correm risco
			    dbms_sql.column_value(ws_pcursor, ws_bindn-1, ws_col_sup);
			end if;

			
		    --verificando primeiro anterior ou ultimo nivel
			if  ws_content_ant = '%First%' or (ws_bindn = ws_pvcolumns.COUNT) then
		        ws_content_ant := ret_coluna;
		    end if;

            --verificando primeiro pai
			if  ws_col_sup_ant = '%First%' then
		        ws_col_sup_ant := ws_col_sup;
		    end if;

            --se é ultimo nivel se baseia nos filhos os tamanhos, que já tem a quantidade pré-definida
			if  ws_bindn = ws_pvcolumns.COUNT then
				ws_xcount := 1;
			end if;
			
		    if (ws_content_ant <> ret_coluna or ws_col_sup_ant <> ws_col_sup) or ws_bindn = ws_pvcolumns.COUNT then
		        if ws_saida <> 'O' then
				    	ws_count := 0;
						
						nested_calculada(ws_arr(5), '', '', ws_count);

						ws_colspan := ((ws_xcount*ws_scol)+ws_count)-(ws_count_v*ws_xcount);

                        -- Celula do cabeçalho do valor pivotado
						------------------------------------------------------------

						--htp.prn('<th style="text-align:center !important;" colspan="'||ws_colspan||'">');
						ws_html_1 := '<th style="text-align:center !important;" colspan="'||ws_colspan||'">'; 
						
						if ret_mcol(ws_ccoluna).cd_ligacao <> 'SEM' then
							if  ret_mcol(ws_ccoluna).st_com_codigo = 'S' then
								ws_content_ant := ws_content_ant||'-'||fun.cdesc(ws_content_ant,ret_mcol(ws_ccoluna).cd_ligacao);
							else
								ws_content_ant := fun.cdesc(ws_content_ant,ret_mcol(ws_ccoluna).cd_ligacao);
							end if;
						end if;

						begin
							-- htp.prn(trim(fun.utranslate('NM_ROTULO', prm_visao, fun.ifmascara(ws_content_ant,ret_mcol(ws_ccoluna).nm_mascara, prm_visao, prm_coluna, '', '', '', '', ws_usuario), ws_padrao)));
							ws_html_1 := ws_html_1 || trim(fun.utranslate('NM_ROTULO', prm_visao, fun.ifmascara(ws_content_ant,ret_mcol(ws_ccoluna).nm_mascara, prm_visao, prm_coluna, '', '', '', '', ws_usuario), ws_padrao)); 
						exception when others then
							--htp.prn(trim(fun.utranslate('NM_ROTULO', prm_visao, ws_content_ant, ws_padrao)));
							ws_html_1 := ws_html_1 || trim(fun.utranslate('NM_ROTULO', prm_visao, ws_content_ant, ws_padrao)); 
						end;
						--htp.p('</th>');
						ws_html_1 := ws_html_1 || '</th>'; 
						htp_p(ws_html_1); 

						--fim do initcab

				end if;
				ws_xcount := 0;
		    end if;

            ws_xcount      := ws_xcount + 1;
  
            -- colunas e pais viraram passado 
		    ws_content_ant := ret_coluna;
			ws_col_sup_ant := ws_col_sup;
	    end loop;

		ws_xcount      := 1;

        nested_calculada(ws_arr(5), '', '', ws_xcount);

		-- pivot final do total
		------------------------------------------------------------
		if (ws_saida <> 'O' and ws_arr(40) <> 'S') then  

			ws_counter := ws_xcount*ws_scol-ws_count_v;
			--htp.prn('<th style="text-align:center !important;" colspan="'||ws_counter||'">'||ws_arr(37)||'</th>');
			ws_html_1 := '<th style="text-align:center !important;" colspan="'||ws_counter||'">'||ws_arr(37)||'</th>'; 
			if ws_row > 1 then
			    --htp.p('</tr>');
				ws_html_1 := ws_html_1 || '</tr>'; 
			end if;
			htp_p(ws_html_1);
		end if;

		dbms_sql.close_cursor(ws_pcursor);

	end loop;

	--------------------------------------------------------------------------------- 	
    -- Monta linha do cabeçalho - Colunas de valores (última linha de cabeçalho) 	
	--------------------------------------------------------------------------------- 
	if ws_saida <> 'O' and ws_row > 1 then
	    htp_p('<tr title="3">');
	else 
	    ws_qt_cab_agru := 0;   -- Se tem somente uma linha de cabeçalho, não deve reduzir a quantidade de colunas não agrupadoras   
	end if;
	

	ws_counter := 0;
	ws_ccoluna := 0;

	select count(*) into ws_distinctmed from table(fun.vpipe((select cs_agrupador from ponto_avaliacao where cd_ponto = ws_objeto)));

	if ws_distinctmed = 1 then
	    select count(column_value) into ws_distinctmed from table(fun.vpipe((select formula from micro_coluna where st_agrupador = 'TPT' and cd_micro_visao = ws_objeto and cd_coluna = (select cs_agrupador from ponto_avaliacao where cd_ponto = ws_objeto)))) where column_value in (select nvl(column_value, 'N/A') from table(fun.vpipe((select propriedade from object_attrib where cd_prop = 'TPT' and owner = ws_usuario and cd_object = prm_agrupador))));
	end if;

	ws_col_valor     := 0;
	ws_qt_colinv_val := 0;

	loop
	    ws_counter   := ws_counter + 1;
	    if ws_arr(40) <> 'S' or ws_pvcolumns.COUNT = 0 then
			if ws_counter > ws_ncolumns.COUNT-2 then
				exit;
			end if;
		else
		    if ws_counter > ws_ncolumns.COUNT-2 then
				exit;
			end if;
		end if;

		if length(ws_estilo_linha) > 30000 and ws_estilo_linha1 is null then 
			ws_estilo_linha1 := ws_estilo_linha;
			ws_estilo_linha  := '';
		end if; 

	    ws_ccoluna := 1;
		
	    loop
			if  ws_ccoluna = ret_mcol.COUNT or ret_mcol(ws_ccoluna).cd_coluna = ws_ncolumns(ws_counter) then
				exit;
			end if;
			ws_ccoluna := ws_ccoluna + 1;
	    end loop;
       
	   	ws_hint := '';
       
	    if nvl(ret_mcol(ws_ccoluna).hint, 'N/A') <> 'N/A' then
			ws_hint := 'title="'||ret_mcol(ws_ccoluna).hint||'" ';
		end if;
		
		ws_html := '';
		
	    if  ret_mcol(ws_ccoluna).st_agrupador <> 'SEM' then -- Colunas dos valores 
	        
			-- select count(*) into ws_count_v from table(fun.vpipe((ws_arr(53)))) where column_value = ret_mcol(ws_ccoluna).cd_coluna;
			ws_count_v := 0;    -- v001
			if ret_mcol(ws_ccoluna).invisivel = 'S' then 
				ws_count_v := 1;
			end if; 

			if length(ws_arr(5)) > 0 then
				for i in (select column_value as valor, rownum as linha from table(fun.vpipe((ws_arr(5))))) loop
					if instr(i.valor, '<') > 0 then
						if substr(i.valor, 0, instr(i.valor, '<')-1) = ret_mcol(ws_ccoluna).cd_coluna then
							select nome into ws_calculada_n from(select column_value as nome, rownum as linha from table(fun.vpipe((ws_arr(7))))) where linha = i.linha;
							ws_counterid := ws_counterid+1;
							htp_p('<th style="text-align: center;">'||ws_calculada_n||'</th>',prm_prn => 'PRN'); --prn
						end if;
					end if;
				end loop;
			end if;

			ws_counterid := ws_counterid + 1;
			
			begin
				select replace(column_value, ret_mcol(ws_ccoluna).cd_coluna, '') into ws_ordem_arrow from table((fun.vpipe(ws_ordem, ','))) where trim(column_value) like (ws_counter||' %');
			exception when others then
			    ws_ordem_arrow := '';
			end;
			--replace colocado na fun.check_rotuloc para remover as aspas quando concatenado um filtro/objeto junto
			ws_html := ws_html||nvl(ws_arr(36), fun.utranslate('NM_ROTULO', prm_visao, replace(replace(fun.check_rotuloc(ret_mcol(ws_ccoluna).cd_coluna, prm_visao, prm_screen), '(BR)', ' &#013;&#010; '),chr(39),''), ws_padrao));

			ws_col_valor := ws_col_valor+1;

			-- Coluna de valor e invisível, não gera no html 
			if ws_count_v <> 0 then
				ws_qt_colinv_val := ws_qt_colinv_val + 1; 
			else 
				if ws_saida <> 'O' then 

				    if(trim(ret_mcol(ws_ccoluna).st_invisivel) = 'S') then
						ws_classe := 'no_font';
					else
						ws_classe := ws_ordem_arrow;
					end if;

                    begin
						
						--if ret_colgrp <> 1 then
						if ws_arr(40) <> 'S' then
							if ws_counter+ws_scol < ws_ncolumns.COUNT-1 then
								begin
									ws_pivot := 'data-pivot="'||trim(ws_mfiltro(ws_counter+1))||'"';
								exception when others then
									ws_pivot := '';
								end;
							else
								ws_pivot := '';
							end if;
						else
							if ws_counter < ws_ncolumns.COUNT-1 then
								begin
									ws_pivot := 'data-pivot="'||trim(ws_mfiltro(ws_counter+1))||'"';
								exception when others then
									ws_pivot := '';
								end;
							else
								ws_pivot := '';
							end if;
						end if;
					exception when others then
						ws_pivot := '';
					end;

					if length(ws_arr(1)) > 0 then
						ws_classe := ws_classe||' callmed';
					end if;
					
					if trim(ret_mcol(ws_ccoluna).st_negrito) = 'S' then
						ws_negrito := 'bold';
					end if;

				  htp_p('<th '||ws_subquery||' '||ws_pivot||' data-ordem="1" data-valor="'||ret_mcol(ws_ccoluna).cd_coluna||'" data-inv-antes="'||ws_qt_colinv_val||'" class="'||trim(ws_classe)||'" '||ws_hint||' style="text-align: '||ret_mcol(ws_ccoluna).st_alinhamento_cab||'; font-weight: '||ws_negrito||';" >'||ws_html||'</th>',prm_prn => 'PRN'); --prn

					ws_estilo_linha := ws_estilo_linha||' div#main table#'||ws_obj_html||'c tr:not(.total):not(.geral):not(.destaqueLinha) td:nth-child('||(ws_counter+1-ws_qt_colinv_val)||'),div#main table#'||ws_obj_html||' tr:not(.total):not(.geral):not(.destaqueLinha) td:nth-child('||(ws_counter+1-ws_qt_colinv_val)||') { background-color: '||ret_mcol(ws_ccoluna).color||'; }';				
				end if;
				ws_html := '';

			end if;

			if length(ws_arr(5)) > 0 then
				for i in(select column_value as valor, rownum as linha from table(fun.vpipe((ws_arr(5))))) loop
					if instr(i.valor, '>') > 0 then
						if substr(i.valor, 0, instr(i.valor, '>')-1) = ret_mcol(ws_ccoluna).cd_coluna then
							select nome into ws_calculada_n from(select column_value as nome, rownum as linha from table(fun.vpipe((ws_arr(7))))) where linha = i.linha;
							ws_counterid := ws_counterid+1;
							htp_p('<th class="cen">'||ws_calculada_n||'</th>');
						end if;
					end if;
				end loop;
			end if;

			if ws_saida = 'S' or ws_saida = 'O' then    
				fcl.gera_conteudo(ws_excel, ws_saida ,'<Cell><Data ss:Type="String">'||replace(fun.ptg_trans(fun.utranslate('NM_ROTULO', prm_visao, fun.check_rotuloc(ret_mcol(ws_ccoluna).cd_coluna, prm_visao, prm_screen), ws_padrao)), '<BR>', '')||'</Data></Cell>', '', '');
			end if;

		end if;

	end loop;

	

	ws_step := ws_counter;
	if ws_arr(40) <> 'S' then 
	    ws_stepper := ws_scol;
	end if;

    if ws_saida = 'S' or ws_saida = 'O' then  
	    fcl.gera_conteudo(ws_excel, ws_saida, '</Row>', '', '');
	end if;

	if ws_saida <> 'O' then
		htp_p('</tr>');
		htp_p('</thead>');
	end if;

	ws_repeat := 'show';
	ws_firstid := 'Y';    -- Primeira linha = Y

    ws_agrup_max  :=0;

	ws_cursor := dbms_sql.open_cursor;
	dbms_sql.parse( c => ws_cursor, statement => ws_query_montada, lb => 1, ub => ws_lquery, lfflg => true, language_flag => dbms_sql.native );

	ws_binds := core.bind_direct(ws_parametros, ws_cursor, '', ws_objeto, prm_visao, prm_screen,prm_usuario => ws_usuario);
    ws_binds := replace(ws_binds, 'Binds Carregadas=|', '');

	ws_counter := 0;

	loop
	    ws_counter := ws_counter + 1;
	    if  ws_counter > ws_ncolumns.COUNT then
	    	exit;
	    end if;

		begin
			if rec_tab(ws_counter).col_type = 12 then
				dbms_sql.define_column(ws_cursor, ws_counter, dat_coluna);
			else
				dbms_sql.define_column(ws_cursor, ws_counter, ret_coluna, 2000);
			end if;
		exception when others then
			dbms_sql.define_column(ws_cursor, ws_counter, ret_coluna, 2000);
		end;
	end loop;

	ws_linhas := dbms_sql.execute(ws_cursor);
	ws_counter := 0;

	loop

		ws_counter := ws_counter + 1;
		if  ws_counter > ws_ncolumns.COUNT-2 then
			exit;
		end if;

		ws_ccoluna := 1;

		loop
			if  ws_ccoluna = ret_mcol.COUNT or ret_mcol(ws_ccoluna).cd_coluna = ws_ncolumns(ws_counter) then
				exit;
			end if;
			ws_ccoluna := ws_ccoluna + 1;
		end loop;

		if  ret_mcol(ws_ccoluna).st_agrupador = 'SEM' then
			ws_vcol(ws_counter) := ret_mcol(ws_ccoluna).cd_coluna;
			ws_vcon(ws_counter) := 'First';
		end if;

		ws_coluna_ant(ws_counter) := 'First';

	end loop;

    ws_zebrado   := 'First';
	ws_zebrado_d := 'First';

	ws_hint := '';

	htp_p('<style>',prm_prn => 'PRN');          --PRN
	htp_p(ws_estilo_linha1,prm_prn => 'PRN' );  --PRN
	htp_p(ws_estilo_linha,prm_prn => 'PRN' );--PRN	 
	htp_p('</style>',prm_prn => 'PRN');--PRN

	ws_estilo_linha := '';
	ws_estilo_linha1 := '';

    --começo do corpo de conteúdo
	htp_p('<tbody>');
	
    ----------------------------------------------------------------------
	-- Monta as linhas com dados da consulta 
	-----------------------------------------------------------------------
	loop
	    
		ws_count         := 0;
	
		ws_linhas := dbms_sql.fetch_rows(ws_cursor);
	    if  ws_linhas = 1 then
		    ws_vazio := False;
	    else
            if  ws_vazio = True then
	            dbms_sql.close_cursor(ws_cursor);
				ws_nodata_passo := '2';
      		    raise ws_nodata;
        	end if;
        	exit;
	    end if;
		
		ws_fixed := nvl(ws_arr(18), '9999')+1;
		if length(ws_arr(48)) > 0 and ws_fixed > 0 then
		    ws_fixed := 999;
		end if;

		ws_ct_top := ws_ct_top + 1;
        if  ws_top <> 0 and ws_ct_top > ws_top then
            exit;
        end if;
		if nvl(fun.getprop(prm_objeto,'DESTACAR_PIVOT'),'N') <> 'N' and (prm_colup is not null or prm_drill = 'Y') then
		--if nvl(fun.getprop(prm_objeto,'DESTACAR_PIVOT'),'N') <> 'N' and prm_colup is not null then --comentado para funcionar 480a.
			ws_zebrado   := 'Claro';
			ws_zebrado_d := 'Distinto_claro';
		else
			if  ws_zebrado in ('First','Escuro') then
				ws_zebrado   := 'Claro';
				ws_zebrado_d := 'Distinto_claro';
			else
				ws_zebrado   := 'Escuro';
				ws_zebrado_d := 'Distinto_escuro';
			end if;
		end if;

	
	    ws_counter := 0;
	    ws_ccoluna := 0;
	    ws_chcor   := 0;
	    ws_ctnull  := 0;
	    ws_ctcol   := 0;

	    loop

			ws_counter := ws_counter + 1;
			if  ws_counter > ws_ncolumns.COUNT then
				exit;
			end if;

			ws_xcoluna := 1;
			loop
				if  ws_xcoluna = ret_mcol.COUNT or ret_mcol(ws_xcoluna).cd_coluna = ws_ncolumns(ws_counter) then
					exit;
				end if;
				ws_xcoluna := ws_xcoluna + 1;
			end loop;

			ws_ccoluna := ws_ccoluna + 1;
			
			begin
				if rec_tab(ws_counter).col_type = 12 then
					dbms_sql.column_value(ws_cursor, ws_ccoluna, dat_coluna);
					ret_coluna := dat_coluna; 
				else
					dbms_sql.column_value(ws_cursor, ws_ccoluna, ret_coluna);
				end if;
			exception when others then
				dbms_sql.column_value(ws_cursor, ws_ccoluna, ret_coluna);
			end;


			if  ret_mcol(ws_xcoluna).st_agrupador = 'SEM' then
				ws_ctcol  := ws_ctcol + 1;
			end if;
			if  nvl(ret_coluna,'%*') = '%*' and ret_mcol(ws_xcoluna).st_agrupador = 'SEM' then
				ws_ctnull := ws_ctnull + 1;
				ws_chcor := 1;
			end if;

	    end loop;

	    ws_col_subt := ''; 
		ws_xatalho  := '';
	    ws_pipe     := '';
	    ws_bindn    := ws_vcol.FIRST;
	    
		while ws_bindn is not null loop
			if  ws_bindn = 1 or ws_ncolumns(ws_bindn) <> ws_ncolumns(ws_bindn-1) then
				
				
				begin
					if rec_tab(ws_bindn).col_type = 12 then
						dbms_sql.column_value(ws_cursor, ws_bindn, dat_coluna);
						ws_vcon(ws_bindn) := to_char(dat_coluna,'dd/mm/rrrr hh24:mi:ss');     -- Card: 536a - 22/05/2024 
						ws_cod_coluna := dat_coluna;
						ret_coluna    := dat_coluna;
					else
						dbms_sql.column_value(ws_cursor, ws_bindn, ret_coluna);
						ws_vcon(ws_bindn) := ret_coluna;
						ws_cod_coluna := ret_coluna;
					end if;
				exception when others then
					dbms_sql.column_value(ws_cursor, ws_bindn, ret_coluna);
					ws_vcon(ws_bindn) := ret_coluna;
					ws_cod_coluna := ret_coluna;
				end;
				
				
				if  nvl(ws_vcon(ws_bindn),'%*') <> '%*' then
					ws_xatalho := ws_xatalho||ws_pipe;
					--ws_xatalho := trim(ws_xatalho)||ws_vcol(ws_bindn)||'|'||ws_vcon(ws_bindn);
					ws_xatalho := trim(ws_xatalho)||ws_vcol(ws_bindn)||'|'|| replace(ws_vcon(ws_bindn),'|','@PIPE@');   -- Subsitui |, se houver no texto (para resolver erro nos parametros da DRILL)  
					ws_pipe    := '|';
					ws_col_subt:= ws_vcol(ws_bindn);  -- coluna do subtotal 
				end if;
			end if;
			ws_bindn := ws_vcol.NEXT(ws_bindn);
	    end loop;
		
		
		dbms_sql.column_value(ws_cursor, ws_ncolumns.COUNT-1, ret_colgrp);
		dbms_sql.column_value(ws_cursor, ws_ncolumns.COUNT, ret_coltot);    -- Se for a linha do total geral retorna 1 

		ws_linha := ws_linha+1;
		ws_linha_col := ws_linha_col+1;

		
			
		if (ws_linha > ws_amostra and ws_amostra <> 0) then
			exit;
		end if;
		
		if instr(ret_coluna, '[LC]') > 0 then
			WS_LINHA_CALC := ' lc';  
			ret_coluna := replace(ret_coluna, '[LC]', '');
			ws_xatalho := replace(ws_xatalho, '[LC]', '');
		else
			WS_LINHA_CALC := ''; 
		end if;
		

		-- Linhas normais 
		if ret_colgrp = 0 then
			
			ws_html_1 := ''; 
			if ws_saida <> 'O' then
				if ws_zebrado = 'Escuro'  then
					ws_html_1 := '<tr class="es'||WS_LINHA_CALC||'">';
				else
					ws_html_1 := '<tr class="cl'||WS_LINHA_CALC||'">'; 
				end if;
			end if;
			htp_p(ws_html_1);

			if ws_saida = 'S' or ws_saida = 'O' then   
				fcl.gera_conteudo(ws_excel, ws_saida, '<Row>', '', '');
			end if;

		-- Linhas de subtotal e total geral 
		else
			if ws_saida <> 'O' then
				
				if ws_arr(51) = 'bold' then
                    ws_jump := ' bld';
				end if;
				
				ws_html_1 := ''; 
				if ret_coltot = 1 then -- Total Geral 
					ws_html_1 := '<tr class="total geral st-'||ws_arr(41)||ws_jump||'" data-drill="'||ws_arr(15)||'">'; 
				else
					if ws_arr(44) <> 'S' then -- Subtotal 
						ws_st_oculta := ws_arr(44);     -- st-S é usado na exportação para o Excel, se tiver st-S não exporta a linha para o Excel
						if ws_prop_ocultar_subtotal = 'TODOS' or instr('|'||ws_prop_ocultar_subtotal||'|', '|'||ws_col_subt||'|') > 0 then
							ws_st_oculta := 'S';
						end if; 	
						ws_html_1 := '<tr class="total normal st-'||ws_st_oculta||ws_jump||' '||ws_col_subt||'">'; 
					end if;
				end if;
				htp_p(ws_html_1);
			end if;
			
			if ws_saida = 'S' or ws_saida = 'O' then    
				fcl.gera_conteudo(ws_excel, ws_saida, '<Row>', '', '');
			end if;

			if  ws_zebrado in ('First','Escuro') then
				ws_zebrado   := 'Claro';
				ws_zebrado_d := 'Distinto_claro';
			else
				ws_zebrado   := 'Escuro';
				ws_zebrado_d := 'Distinto_escuro';
			end if;
			
			ws_linha_col := 0;

		end if;

		if length(ws_tmp_jump) > 5 then
			ws_check := ws_tmp_check;
		end if;

		ws_xatalho := trim(ws_xatalho);
		ws_drill_a := replace('|'||ws_xatalho,'||','|');

		if(instr(ws_drill_a, '|', 1, 1) = 1) then
			ws_drill_a := substr(ws_drill_a,2,length(ws_drill_a));
		end if;

		ws_jump := ws_tmp_jump;

		ws_cod_coluna := ret_coluna;

		ws_fix   := '';
		if ws_fixed > 1 then
			ws_fix   := 'fix';
			ws_fixed := ws_fixed-1;
		end if;
		ws_fix := ws_fix||' colagr';  -- define a primeira coluna (da seta) também como agrupadora

		ws_drill_a := replace(ws_drill_a,'"',     '&#34;'); -- Problema, gera simbolos no html 
		ws_drill_a := replace(ws_drill_a,chr(39), '&#39;');
		ws_drill_a := replace(ws_drill_a,'/',     '&#47;');
		ws_drill_a := replace(ws_drill_a,'<',	  '&#60;');
		ws_drill_a := replace(ws_drill_a,'>',	  '&#62;');

		ws_hint := replace(ret_coluna,'"',     '&#34;');
		ws_hint := replace(ws_hint,   chr(39), '&#39;');
		ws_hint := replace(ws_hint,   '/',     '&#47;');
		ws_hint := replace(ws_hint,'<',	  '&#60;');
		ws_hint := replace(ws_hint,'>',	  '&#62;');

		-- Linha Normal - monta a coluna da SETA 
		if ret_colgrp = 0 then 
			if ws_saida <> 'O' then 
				htp_p('<td '||ws_check||' title="'||ws_hint||'" class="'||ws_jump||' '||ws_fix||'" '||ws_subquery||' data-ordem="1" data-valor="'||ws_drill_a||'"></td>');
				ws_anot_cond := ws_drill_a; 
			end if;
		else


			-- Linha do total geral  - Monta as colunas agrupadores com ou sem Texto de total 
			if ret_coltot = 1 then   

				if ws_saida <> 'O' then
					htp_p('<td data-valor="'||ws_drill_a||'" data-drill="'||ws_saida||'" class="dir '||ws_fix||'"></td>');

					-- Se tem descrição no total 
					if length(ws_arr(48)) > 0 then
						htp_p('<td colspan="'||(ws_qt_colagr - ws_qt_colinv - ws_qt_colinv_cod)||'" data-valor="'||ws_drill_a||'" class="dir '||ws_fix||'" style="display: table-cell !important;">'||ws_arr(48)||'</td>');


						for z IN 1..(ws_qt_colagr - 1) LOOP -- Total de colunas menos 1 do colspan 
							htp_p('<td data-valor="'||ws_drill_a||'" class="inv"></td>');
						end loop;
					else

						-- Monta as colunas de total referente aos agrupadores (com as mesmas classes dos agrupadores) 
						for c in 1..ws_cols_total.count loop 
							htp_p('<td data-valor="'||ws_drill_a||'" '||ws_cols_total(c).class||'></td>');
						end loop; 

					end if; 

				else

				    if ws_saida = 'S' or ws_saida = 'O' then 
						fcl.gera_conteudo(ws_excel, ws_saida ,'<Cell> <Data ss:Type="String">'||ws_arr(48)||'</Data></Cell>', '', '');
					end if;

					for l in 1..(ws_qt_colagr - ws_qt_colinv) loop  -- trocado dimensao_soma 
                        fcl.gera_conteudo(ws_excel, ws_saida ,'<Cell> <Data ss:Type="String"></Data></Cell>', '', '');
					end loop;

				end if;

			-- Linha do subtotal - mesma coluna da seta, porém em branco 
			else
				if ws_saida <> 'O' then
				    if ws_arr(44) <> 'S' then
					    htp_p('<td data-valor="'||ws_drill_a||'" class="'||ws_fix||'"></td>');
					end if;
				end if;
			end if;

		end if;

		ws_counter       := 0;  
		ws_qt_colinv_val := 0;   -- Utilizada para acumular a quantidade de colunas de valores parametrizadas como invisível 

		-- Monta as colunas de dados da consulta 
		------------------------------------------------------------------
		loop
			-- necessário a entrada antes do contador
			if 	ws_class_td_pivot is not null  then
				ws_class_td_pivot_acum := ws_class_td_pivot_acum||ws_class_td_pivot||'|';
			end if;


			ws_counter := ws_counter + 1;

			if length(ws_estilo_linha) > 30000 and ws_estilo_linha1 is null then 
				ws_estilo_linha1 := ws_estilo_linha;
				ws_estilo_linha  := '';
			end if; 

			if ws_arr(40) <> 'S' or ws_pvcolumns.COUNT = 0 then
				if ws_counter > ws_ncolumns.COUNT-2 then
					exit;
				end if;
			else
			    if ws_counter > ws_ncolumns.COUNT-2 then
					exit;
				end if;
			end if;
			
			begin
				if(ws_counter) < ws_step-ws_stepper then
					ws_atalho := ws_mfiltro(ws_counter+1);
				else
					ws_atalho := '';
					ws_class_td_pivot:='pvt-tot ';
				end if;
			exception
				when others then
				ws_atalho := '';
			end;
			
			ws_ccoluna := 1;

			loop

				if ws_ccoluna > ret_mcol.COUNT then
					ws_ccoluna := ws_ccoluna - 1;
					exit;
				end if;

				if ret_mcol(ws_ccoluna).cd_coluna = ws_ncolumns(ws_counter)  then
					exit;
				end if;

				ws_ccoluna := ws_ccoluna + 1;

			end loop;

			ret_column_value (ws_counter, dat_coluna, ret_coluna, ws_content, ws_content_anot);
			--
			-- Transformado em procedure para ser usado também na montagem do destaque 
			/**************
			begin
				if rec_tab(ws_counter).col_type = 12 then
					dbms_sql.column_value(ws_cursor, ws_counter, dat_coluna);
					if ret_mcol(ws_ccoluna).nm_mascara = 'SEM' then
						ws_content := to_char(dat_coluna, 'DD/MM/YYYY HH24:MI');
					else
						ws_content := dat_coluna;
					end if;
					ws_content_anot := ws_content; 
					ret_coluna      := dat_coluna;
				else
					begin
						dbms_sql.column_value(ws_cursor, ws_counter, ret_coluna);
					exception when others then
						dbms_sql.column_value(ws_cursor, ws_counter, ret_coluna);
					end;
					ws_content_anot := ret_coluna; 

					ws_content := replace(ret_coluna,'"',     '&#34;');
					ws_content := replace(ws_content,chr(39), '&#39;');
					ws_content := replace(ws_content,'/',     '&#47;');
					ws_content := replace(ws_content,'<',	  '&#60;');
					ws_content := replace(ws_content,'>',	  '&#62;');
				
				end if;
			exception when others then
				dbms_sql.column_value(ws_cursor, ws_counter, ret_coluna);
				ws_content := ret_coluna;
			end;	
			if instr(ws_content, '[LC]') > 0 then 
			    ws_content := replace(ws_content, '[LC]', '');
		    end if;		
			*********************************/ 

			-- Não repetir valores iguais a coluna anterior - ws_arr(35) prop NAO_REPETIR
			begin
				if ws_linha > 1 then
				    if trim(ret_coluna) = trim(ws_array_anterior(ws_counter)) and ws_arr(35) = 'S' and ret_mcol(ws_ccoluna).st_agrupador = 'SEM' then
						ws_content := '';
					end if;
				end if;
			exception when others then
				htp_p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,'N');
			end;

			if ws_firstid = 'Y' then
				ws_idcol := 'id="'||ws_obj_html||ws_counter||'l" ';
			else
				ws_idcol := '';
			end if;

			--ws_drill_a := replace(trim(ws_atalho)||'|'||trim(ws_xatalho),'||','|');  -- v001
			ws_drill_a := replace(ws_atalho||'|'||ws_xatalho,'||','|');
			
			if(instr(ws_drill_a, '|', 1, 1) = 1) then
				ws_drill_a := substr(ws_drill_a,2,length(ws_drill_a));
			end if;
			ws_anot_cond := ws_drill_a;

			ws_jump := '';

			if(length(ws_jump) > 1) then
			  ws_jump := 'style="'||ws_jump||'"';
			end if;

			if rtrim(ret_mcol(ws_ccoluna).st_invisivel) <> 'S' then

				if rtrim(substr(ret_mcol(ws_ccoluna).formula,1,8))='FLEXCOL=' then
					begin
						ws_texto_al     := replace(ret_mcol(ws_ccoluna).formula,'FLEXCOL=','');
						ws_nm_var_al    := substr(ws_texto_al, 1 ,instr(ws_texto_al,'|')-1);
						ws_cd_coluna := fun.gparametro(trim(ws_nm_var_al), prm_screen => prm_screen);
						select nvl(st_alinhamento, 'LEFT') into ws_alinhamento
						from MICRO_COLUNA
						where cd_micro_visao = prm_visao and
						cd_coluna = ws_cd_coluna;
					exception when others then
						ws_alinhamento := ret_mcol(ws_ccoluna).st_alinhamento;
					end;
				else
					ws_alinhamento := ret_mcol(ws_ccoluna).st_alinhamento;
				end if;

			else
				ws_jump := ws_jump||' class="no_font"';
			end if;

			if ws_content = '"' then
				ws_jump := ws_jump||' class="cen"';
			end if;

			ws_jump := trim(ws_jump);

			
			if ws_arr(34) = 'S' and ret_mcol(ws_ccoluna).st_agrupador <> 'SEM' and ws_counter < ws_ncolumns.COUNT and ret_colgrp = 0  THEN
				if ws_counter > ws_arr(9) and ws_counter < (ws_ncolumns.COUNT-ws_arr(8)) and ws_scol = 1 then
					begin
						ws_temp_valor := to_number(nvl(ret_coluna, '0'));
					exception when others then
						ws_temp_valor := 0;
					end;

					ws_ac_linha := ws_ac_linha + ws_temp_valor;
					ws_content     := ws_ac_linha;
				end if;
			end if;

			ws_pivot_c := '';
			
			if ws_atalho is not null then -- v001
				for i in (select cd_conteudo from table(fun.vpipe_par(ws_atalho))) loop
					ws_pivot_c        := ws_pivot_c||'-'||replace(i.cd_conteudo, '|', '-');
					ws_class_td_pivot := 'pvt-'||replace(ws_pivot_c,'-','');
				end loop;
			end if; 

			select ret_mcol(ws_ccoluna).cd_coluna||'-'||ws_pivot_c into ws_pivot_c from dual;

			if length(ws_pivot_c) = length(ret_mcol(ws_ccoluna).cd_coluna||'-') then
				ws_pivot_c := ret_mcol(ws_ccoluna).cd_coluna;
			end if;

			ws_pivot_c := replace(ws_pivot_c, '--', '-');
						
			ws_hint := '';
			

			if nvl(ret_mcol(ws_ccoluna).limite, 0) > 0 and length(ws_content) > nvl(ret_mcol(ws_ccoluna).limite, 0) then
				ws_hint := ws_content;
				ws_content := substr(ws_content, 0, ret_mcol(ws_ccoluna).limite);
			end if;
			
			if nvl(ws_hint, 'N/A') <> 'N/A' then
				ws_hint := 'title="'||ws_hint||'" ';
			end if;

			-- Define algumas classes da coluna - fix(fixa), inv(invisivel) e colagr(agrupadora)
			ws_fix   := null;
			if ws_fixed > 1 then
				ws_fix   := 'fix';
				ws_fixed := ws_fixed-1;				
			end if; 

			-- select count(*) into ws_count_v from table(fun.vpipe((ws_arr(53)))) where column_value = ret_mcol(ws_ccoluna).cd_coluna;
			ws_count_v := 0;    -- v001
			if ret_mcol(ws_ccoluna).invisivel = 'S' then 
				ws_count_v := 1;
			end if; 

			if ws_count_v <> 0 then
				ws_fix   := ws_fix||' inv ';
			end if;
			if ret_mcol(ws_ccoluna).st_agrupador = 'SEM' then
				ws_fix := ws_fix||' colagr';  -- Coluna agrupadora 
			end if; 	
			if ws_fix is not null then 
				if ret_mcol(ws_ccoluna).quebra_texto = 'S' then 
					ws_fix := 'style="white-space: normal;" class="'||ws_fix||'"';
				else
					ws_fix := 'class="'||ws_fix||'"';
				end if;
			end if; 	

			-- Colunas agrupadoras com o mesmo conteúdo da coluna anterior  
			if ret_mcol(ws_ccoluna).st_agrupador = 'SEM' and ws_content = ws_coluna_ant(ws_counter) then

					if length(ws_repeat) = 4 then

						if ws_saida <> 'O' then
							
							-- coluna da linha de Subtotal 
							if ret_colgrp <> 0 then  
								if ws_arr(44) <> 'S' then 
									nested_td(ws_hint, ws_fix, ws_counter, ws_idcol, ws_objeto, ret_mcol(ws_ccoluna).cd_coluna, ws_content, prm_screen, ret_mcol(ws_ccoluna).formula, prm_visao,ret_mcol(ws_ccoluna).nm_mascara, ws_jump, ret_mcol(ws_ccoluna).st_agrupador, ret_mcol(ws_ccoluna).nm_unidade, ws_ccoluna);
								end if;
							else
								nested_td(ws_hint, ws_fix, ws_counter, ws_idcol, ws_objeto, ret_mcol(ws_ccoluna).cd_coluna, ws_content, prm_screen, ret_mcol(ws_ccoluna).formula, prm_visao,ret_mcol(ws_ccoluna).nm_mascara, ws_jump, ret_mcol(ws_ccoluna).st_agrupador, ret_mcol(ws_ccoluna).nm_unidade, ws_ccoluna);
							end if;

							if ws_firstid = 'Y' then
								-- Guarda num array a classe da coluna para aplicardo as mesmas classes no total 
								ws_cols_total(ws_counter).cd_coluna := ret_mcol(ws_ccoluna).cd_coluna; 
								ws_cols_total(ws_counter).class     := ws_fix; 
							end if; 

							-- Se for mesma coluna anterior ou não tem TAUX
							if (nvl(ws_rotulo_ant,' ') = ret_mcol(ws_ccoluna).nm_rotulo) or (ret_mcol(ws_ccoluna).cd_ligacao = 'SEM') then
								if nvl(ret_mcol(ws_ccoluna).url, 'N/A') <> 'N/A' then
									if ws_fix is null then 
										ws_fix := 'class="imgurl"'; 
									else 
										ws_fix := replace(ws_fix,'class="', 'class="imgurl '); 
									end if; 
									htp_p('<td onmouseleave="out_evento();" '||ws_fix||'" data-url="'||replace(replace(ret_mcol(ws_ccoluna).url,'"',''), '$[DOWNLOAD]', ''||ws_owner_bi||'.fcl.download?arquivo=')||'" data-i="'||ws_counter||'" '||ws_idcol||fun.check_blink(ws_objeto, ret_mcol(ws_ccoluna).cd_coluna, ws_content, '', prm_screen, ws_usuario)||' '||ws_jump||'>');
									htp_p('<svg style="border-radius: 2px; padding: 0px 1px; background: #DEDEDE; width: 14px;" version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" 	 viewBox="0 0 58 58" style="enable-background:new 0 0 58 58;" xml:space="preserve"> <g> 	<path d="M57,6H1C0.448,6,0,6.447,0,7v44c0,0.553,0.448,1,1,1h56c0.552,0,1-0.447,1-1V7C58,6.447,57.552,6,57,6z M56,50H2V8h54V50z" 		/> 	<path d="M16,28.138c3.071,0,5.569-2.498,5.569-5.568C21.569,19.498,19.071,17,16,17s-5.569,2.498-5.569,5.569 		C10.431,25.64,12.929,28.138,16,28.138z M16,19c1.968,0,3.569,1.602,3.569,3.569S17.968,26.138,16,26.138s-3.569-1.601-3.569-3.568 		S14.032,19,16,19z"/> 	<path d="M7,46c0.234,0,0.47-0.082,0.66-0.249l16.313-14.362l10.302,10.301c0.391,0.391,1.023,0.391,1.414,0s0.391-1.023,0-1.414 		l-4.807-4.807l9.181-10.054l11.261,10.323c0.407,0.373,1.04,0.345,1.413-0.062c0.373-0.407,0.346-1.04-0.062-1.413l-12-11 		c-0.196-0.179-0.457-0.268-0.72-0.262c-0.265,0.012-0.515,0.129-0.694,0.325l-9.794,10.727l-4.743-4.743 		c-0.374-0.373-0.972-0.392-1.368-0.044L6.339,44.249c-0.415,0.365-0.455,0.997-0.09,1.412C6.447,45.886,6.723,46,7,46z"/> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
								end if;
							end if; 
						end if;

						if ws_saida = 'S' or ws_saida = 'O' then    
							fcl.gera_conteudo(ws_excel, ws_saida ,'<Cell><Data ss:Type="String">'||fun.ptg_trans(fun.ifmascara(ws_content,rtrim(ret_mcol(ws_ccoluna).nm_mascara),prm_visao, ret_mcol(ws_ccoluna).cd_coluna, ws_objeto, '', ret_mcol(ws_ccoluna).formula, prm_screen, ws_usuario))||'</Data></Cell>', '', '');
						end if;

					end if;
			else
					-- Colunas agrupadoras 
					if ret_mcol(ws_ccoluna).st_agrupador = 'SEM' then
						if length(ws_repeat) = 4 then

							-- Linha de total (não gera nada)
							if ret_coltot = 1 and length(ws_arr(48)) > 0  then
								null; 
							else
								if ws_saida <> 'O' then
									
									-- não é linha de total 
									if ret_coltot <> 1 then

									    if ws_firstid = 'Y' then
											nested_fix(ret_mcol(ws_ccoluna).st_alinhamento, ret_mcol(ws_ccoluna).st_negrito, ws_counter, ws_estilo_linha);
										end if;

									    -- Não é linha de subtotal 
										if ret_colgrp = 0 or (ws_arr(44) <> 'S' ) then 
										    nested_td(ws_hint, ws_fix, ws_counter, ws_idcol, ws_objeto, ret_mcol(ws_ccoluna).cd_coluna, ws_content, prm_screen, ret_mcol(ws_ccoluna).formula, prm_visao,ret_mcol(ws_ccoluna).nm_mascara, ws_jump, ret_mcol(ws_ccoluna).st_agrupador, ret_mcol(ws_ccoluna).nm_unidade, ws_ccoluna);
										end if;

									    if ws_firstid = 'Y' then
											-- Guarda num array a classe da coluna para aplicardo as mesmas classes no total 
											ws_cols_total(ws_counter).cd_coluna := ret_mcol(ws_ccoluna).cd_coluna; 
											ws_cols_total(ws_counter).class     := ws_fix; 
										end if;

										-- Cria outra coluna adicional - Se a coluna tem uma URL (imagem)
										if (nvl(ws_rotulo_ant,' ') = ret_mcol(ws_ccoluna).nm_rotulo) or (ret_mcol(ws_ccoluna).cd_ligacao = 'SEM') then
											if nvl(ret_mcol(ws_ccoluna).url, 'N/A') <> 'N/A' then											
												if ws_fix is null then 
													ws_fix := 'class="imgurl"'; 
												else 
													ws_fix := replace(ws_fix,'class="', 'class="imgurl '); 
												end if; 
												htp_p('<td onmouseleave="out_evento();" '||ws_fix||'" data-url="'||replace(replace(replace(replace(replace(ret_mcol(ws_ccoluna).url,'"',''), '$[DOWNLOAD]', ''||ws_owner_bi||'.fcl.download?arquivo='), '$[SELF]', ws_cod_coluna), chr(39), ''), '|', '')||'" data-i="'||ws_counter||'" '||ws_idcol||fun.check_blink(ws_objeto, ret_mcol(ws_ccoluna).cd_coluna, ws_content, '', prm_screen, ws_usuario)||' '||ws_jump||'>');
												htp_p('<svg style="border-radius: 2px; padding: 0px 1px; background: #DEDEDE; width: 14px;" version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" 	 viewBox="0 0 58 58" style="enable-background:new 0 0 58 58;" xml:space="preserve"> <g> 	<path d="M57,6H1C0.448,6,0,6.447,0,7v44c0,0.553,0.448,1,1,1h56c0.552,0,1-0.447,1-1V7C58,6.447,57.552,6,57,6z M56,50H2V8h54V50z" 		/> 	<path d="M16,28.138c3.071,0,5.569-2.498,5.569-5.568C21.569,19.498,19.071,17,16,17s-5.569,2.498-5.569,5.569 		C10.431,25.64,12.929,28.138,16,28.138z M16,19c1.968,0,3.569,1.602,3.569,3.569S17.968,26.138,16,26.138s-3.569-1.601-3.569-3.568 		S14.032,19,16,19z"/> 	<path d="M7,46c0.234,0,0.47-0.082,0.66-0.249l16.313-14.362l10.302,10.301c0.391,0.391,1.023,0.391,1.414,0s0.391-1.023,0-1.414 		l-4.807-4.807l9.181-10.054l11.261,10.323c0.407,0.373,1.04,0.345,1.413-0.062c0.373-0.407,0.346-1.04-0.062-1.413l-12-11 		c-0.196-0.179-0.457-0.268-0.72-0.262c-0.265,0.012-0.515,0.129-0.694,0.325l-9.794,10.727l-4.743-4.743 		c-0.374-0.373-0.972-0.392-1.368-0.044L6.339,44.249c-0.415,0.365-0.455,0.997-0.09,1.412C6.447,45.886,6.723,46,7,46z"/> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
											end if;
										end if; 
									end if;
								end if;
								if ws_saida = 'S' or ws_saida = 'O' then   
									fcl.gera_conteudo(ws_excel, ws_saida ,'<Cell><Data ss:Type="String">'||fun.ptg_trans(ws_content)||'</Data></Cell>', '', '');
								end if;
							end if;
						end if;
					
					-- Colunas de valores 
					else 

						-- Foi commentado o código abaixo por causa do card : 504a.

						-- if(ret_mcol(ws_ccoluna).st_agrupador in ('PSM','PCT') and ret_colgrp <> 0) or (ret_mcol(ws_ccoluna).st_gera_rel = 'N' and ret_colgrp <> 0) then
						-- 	ws_content := ' ';
						-- end if;

						if(ret_mcol(ws_ccoluna).st_gera_rel = 'N' and ret_colgrp <> 0) then
							ws_content := ' ';
						end if;

						-- Não é subtotal 
						if ret_colgrp <> 0 then
							-- Primeira coluna de valor, Total acumulado = S, total separado = N
							if ws_arr(47) = 'S' and ws_scol = 1 and ws_arr(49) = 'N' then
								if ws_counter+ws_ctnull > ws_arr(9)+ws_ctcol and ws_counter < ((ws_ncolumns.COUNT)-ws_arr(8)) then
									begin
										if trim(nvl(ws_content, 'N/A')) = 'N/A' then
											ws_content := '';
										else
											ws_content := to_number(ws_content);
										end if;
										ws_temp_valor2 := to_number(ws_content);
									exception when others then
										ws_temp_valor2 := 0;
									end;
									ws_total_linha := ws_total_linha + ws_temp_valor2;
									ws_content     := ws_total_linha;
								end if;
							end if;
						end if;	
							
						if ws_saida <> 'O' then
							nested_calculada(ws_arr(5), ret_mcol(ws_ccoluna).cd_coluna, '<', ws_count_v);
							
							-- Primeira linha de dados (gera com ID para cada célula ) 
							if ws_firstid = 'Y' then
								if ws_count_v <> 0 then
									ws_qt_colinv_val := ws_qt_colinv_val + 1 ;   -- acumula colunas invisíveis de valores 
								else
									nested_fix(ret_mcol(ws_ccoluna).st_alinhamento, ret_mcol(ws_ccoluna).st_negrito, (ws_counter - ws_qt_colinv_val), ws_estilo_linha);
								end if; 	
							end if;

							ws_fix   := '';
							if ws_count_v <> 0 then
								ws_fix   := 'inv';
							end if;
							
							ws_content := nvl(ws_content, 0);

							-- Coluna de valor ( normal, total geral, e subtotal (se somente total geral = N) )
							if (ws_arr(44) = 'S' and ret_colgrp = 0) or ws_arr(44) = 'N' or ret_coltot = 1 then 
								if ws_count_v = 0 then  -- ATENÇÃO: Coluna de valor invisível não é carregada para o HTML (regra diferente das colunas agrupadoras)
									nested_td(ws_hint, 'class="'||ws_fix||ws_class_td_pivot||'"', ws_counter, ws_idcol, prm_objeto, ret_mcol(ws_ccoluna).cd_coluna, ws_content, prm_screen, ret_mcol(ws_ccoluna).formula, prm_visao,ret_mcol(ws_ccoluna).nm_mascara, ws_jump, ret_mcol(ws_ccoluna).st_agrupador, ret_mcol(ws_ccoluna).nm_unidade, ws_ccoluna);
								end if; 	
							end if;

							nested_calculada(ws_arr(5), ret_mcol(ws_ccoluna).cd_coluna, '>', ws_count_v);
						end if;

						if ws_saida = 'S' or ws_saida = 'O' then   
							fcl.gera_conteudo(ws_excel, ws_saida ,'<Cell> <Data ss:Type="String">'||fun.ptg_trans(ws_content)||'</Data></Cell>', '', '');
						end if;
					end if;
					
			end if;
			
			

			ws_blink_aux   := '';			

			-- Destaque de linha 
			if ret_colgrp = 0 and ret_mcol(ws_ccoluna).qt_destaque_linha > 0 then -- v001

				arr_destaq_col.delete;
				arr_destaq_val.delete;
				ws_pre_suf_alias := null;
				if ret_mcol(ws_ccoluna).qt_destaque_refcol > 0 then 
					monta_arr_destaque;
					ws_pre_suf_alias := substr(rec_tab(ws_counter).col_name,1,instr(rec_tab(ws_counter).col_name,ws_ncolumns(ws_counter))-1)||'|'||   -- prefixo 
					                    substr(rec_tab(ws_counter).col_name,instr(rec_tab(ws_counter).col_name,ws_ncolumns(ws_counter))+length(ws_ncolumns(ws_counter)),1000);  -- sufixo 
				end if; 	
				if ret_mcol(ws_ccoluna).st_agrupador <> 'SEM' then
					ws_blink_aux := fun.check_blink_linha(ws_objeto, ret_mcol(ws_ccoluna).cd_coluna, ws_linha, nvl(ret_coluna,'0'), prm_screen, prm_pre_suf_alias => ws_pre_suf_alias, prm_ar_colref => arr_destaq_col, prm_ar_colval => arr_destaq_val) ; 
				else
					if ret_coluna <> fun.cdesc(ret_mcol(ws_ccoluna).cd_coluna,ret_mcol(ws_ccoluna).cd_ligacao) then
						ws_blink_aux := fun.check_blink_linha(ws_objeto, ret_mcol(ws_ccoluna).cd_coluna, ws_linha, nvl(ret_coluna,'0'), prm_screen, prm_pre_suf_alias => ws_pre_suf_alias, prm_ar_colref => arr_destaq_col, prm_ar_colval => arr_destaq_val);
					end if;
				end if;
				if length(ws_blink_aux) > 7 then
					ws_blink_linha := ws_blink_aux;
				end if;
			end if;	



			-- Soma para utilizar no total SEPARADO (se houver) 
            if ret_coltot = 1 and ret_mcol(ws_ccoluna).st_agrupador <> 'SEM' then
				if length(ws_repeat) = 4 then
                    
					ws_count_v := 0;
					
					begin
						-- select count(*) into ws_count_v from table(fun.vpipe((ws_arr(53)))) where column_value = ret_mcol(ws_ccoluna).cd_coluna;
						if ret_mcol(ws_ccoluna).invisivel = 'S' then 
							ws_count_v := 1;
						end if; 
						if ws_count_v = 0 then
							ws_count := ws_count+1;
							
							begin
								ws_content_sum := to_number(ws_content_sum)+to_number(ret_coluna);
							exception when others then
								ws_content_sum := ret_coluna;
							end;

							ws_array_atual(ws_count) := fun.ifmascara(ws_content_sum,rtrim(ret_mcol(ws_ccoluna).nm_mascara), prm_visao, ret_mcol(ws_ccoluna).cd_coluna, ws_objeto, '', ret_mcol(ws_ccoluna).formula, prm_screen, ws_usuario);
							ws_class_atual(ws_count) := ws_jump;
						end if;
					exception when others then
						ws_count_v := 0;
					end;
					
				end if;

			end if;
			
			ws_jump := '';
			ws_check := '';

			ws_coluna_ant(ws_counter)     := ret_coluna;
			ws_array_anterior(ws_counter) := ret_coluna;

			ws_conteudo_a := ws_content;
			ws_rotulo_ant := ret_mcol(ws_ccoluna).nm_rotulo; 	


		end loop;
		
		ws_count := 0;
		ws_content_sum := 0;

		if ws_saida <> 'O' then
			if ws_blink_linha <> 'N/A' then 
			    htp_p(ws_blink_linha); 
			end if;
		end if;

		ws_blink_linha := 'N/A';

		ws_firstid := 'N';
		if ws_saida = 'S' or ws_saida = 'O' then  
			fcl.gera_conteudo(ws_excel, ws_saida, '</Row>', '', '');
		end if;
		htp_p('</tr>');
		
		ws_ac_linha := 0;
		ws_total_linha := 0;

	end loop;

	ws_total_linha := 0;
	ws_ac_linha := 0;
	ws_fixed := 0;

	if ws_log_exec in ('S','D') then 
		fun.log_exec_ATU ('FIM', ws_log_exec, ws_log_exec_id, ws_objeto, ws_usuario, 'CONSULTA', 20, 'FINALIZADO', null); 
	end if; 

	
	-----------------------------------------------------------------------------------------------
	-- Gera linha de total SAPARADO
	-----------------------------------------------------------------------------------------------
	if ws_saida <> 'O' and ws_arr(52) = 'ROLL' then
		if ws_arr(49) = 'S' then
			ws_blink_linha := 'N/A';
			htp_p('<tr class="total duplicado" data-i="0">');

				htp_p('<td class="fix"></td>');

			    ws_fixed := nvl(ws_arr(18), '9999')+1;
				if length(ws_arr(48)) > 0 and ws_fixed > 0 then
					ws_fixed := 999;
				end if;

			    if ws_fixed > 1 then
					ws_fix   := 'fix';
					ws_fixed := ws_fixed-1;
				else
					ws_fix   := '';
				end if;
				ws_fix := ws_fix||' colagr';  

				ws_counter := 1;
				ws_count   := 0;
				
				loop

					if ws_counter > ws_array_atual.count then
						exit;
					end if;

					if length(ws_array_atual(ws_counter)) > 0 then
						ws_count := ws_count+1;
						ws_array_atual(ws_count) := ws_array_atual(ws_counter);
						ws_class_atual(ws_count) := ws_class_atual(ws_counter);
					end if;
					
					ws_counter := ws_counter+1;

				end loop;
				
				htp_p('<td colspan="'||(ws_qt_colagr - (ws_qt_colinv + ws_qt_colinv_cod) )||'" style="text-align: right;" class="'||ws_fix||'">'||ws_arr(50)||'</td>');

				for t in 1..(ws_qt_colagr - 1) loop -- Colunas agrupadoras menos 1 do colspan 
					htp_p('<td class="inv"></td>');
				end loop;

                ws_counter := 0;
				ws_content := 0;

				loop	
				
					ws_counter := ws_counter+1;
					
					if ws_counter > ws_col_valor or ws_counter > ws_count then
					    exit;
					end if;
					
					begin
						ws_content := ws_array_atual(ws_counter);
					exception when others then
						ws_content := 0;
					end;
					
					begin
						htp_p('<td '||ws_class_atual(ws_counter)||'>'||ws_content||'</td>');
					exception when others then
						htp_p('<td>'||sqlerrm||'</td>');
					end;

				end loop;

			htp_p('</tr>');
		end if;
	end if;
	
	dbms_sql.close_cursor(ws_cursor);

	
	
	if nvl(fun.getprop(prm_objeto,'DESTACAR_PIVOT'),'N') <> 'N' and (prm_colup is not null or prm_drill = 'Y') then
	--if nvl(fun.getprop(prm_objeto,'DESTACAR_PIVOT'),'N') <> 'N' and prm_colup is not null then -- comentado para funcinar 480a.

		for i in 1..length(ws_class_td_pivot_acum) - length(replace(ws_class_td_pivot_acum, '|')) + 1 loop
			ws_valor_atual := regexp_substr(ws_class_td_pivot_acum, '[^|]+', 1, i);

			-- testa o valor atual e atribui na variável ws_valores_sem_repetição uma única vez, sem repetir o valor
			if instr('|' || ws_valores_sem_repeticao || '|', '|' || ws_valor_atual || '|') = 0 then
				ws_valores_sem_repeticao := ws_valores_sem_repeticao || '|' || ws_valor_atual;

			end if;
		end loop;

		--percorre  os valores únicos e aplica o background intercalanto fundo claro e escuro.
		for i in (select column_value from table(fun.vpipe(ws_valores_sem_repeticao)))
		loop
			if  ws_background in ('Escuro') then
				ws_background_d := fun.getprop(prm_objeto,'FUNDO_ESCURO');
				ws_background	:= 'Claro';
			else
				ws_background_d := fun.getprop(prm_objeto,'FUNDO_CLARO');
				ws_background	:= 'Escuro';
			end if;
					
			--total é montado separado , então precisa inverter a cor novamente para não repetir a última do pivot
			if i.column_value = 'pvt-tot' then
				if ws_background = 'Claro' then
					ws_background_d := fun.getprop(prm_objeto,'FUNDO_ESCURO');
				else
					ws_background_d := fun.getprop(prm_objeto,'FUNDO_CLARO');
				end if;
			end if;

			if ws_estilo_linha not like '%div#'||ws_obj_html||' table tr td.'||i.column_value||' { background-color:'||ws_background_d||' }%' then
				--aplica o css com base na nova classe criada com referencia do pivot.
				ws_estilo_linha := ws_estilo_linha||' div#'||ws_obj_html||' table tr td.'||i.column_value||' { background-color:'||ws_background_d||' }';
			end if;
		
		end loop;

	end if;
	

	if ws_saida <> 'O' then
	    htp_p('</tbody>');
	    htp_p('</table>');

		if nvl(ws_estilo_linha, 'N/A') <> 'N/A' or nvl(ws_estilo_linha1, 'N/A') <> 'N/A' then
			htp_p('<style>'); 
			htp_p(ws_estilo_linha1 );
			htp_p(ws_estilo_linha );
			htp_p('</style>');
		end if; 	
		ws_estilo_linha  := '';
		ws_estilo_linha1 := '';

		-- Oculta a primeira coluna de marcador 
		if nvl(ws_prop_ocultar_selecao,'N') = 'S' then  
			htp_p('<style>'); 
			htp_p(' table#'||ws_obj_html||'c tr td:nth-child(1), table#'||ws_obj_html||'c tr:nth-child(1) th:nth-child(1) {display:none;}');	
			htp_p('</style>');
		end if; 	
		
	    htp_p('</div>');
	end if;
	
	ws_textot := '';
	ws_pipe   := '';
	ws_counter := 0;

	loop
	    ws_counter := ws_counter + 1;
	    if  ws_counter > ws_ncolumns.COUNT then
		    exit;
	    end if;

	    ws_ccoluna := 1;
	    loop
			if ws_ccoluna = ret_mcol.COUNT or ret_mcol(ws_ccoluna).cd_coluna = ws_ncolumns(ws_counter) then
				exit;
			end if;
			ws_ccoluna := ws_ccoluna + 1;
	    end loop;

	    if ret_mcol(ws_ccoluna).cd_ligacao <> 'SEM' and ret_mcol(ws_ccoluna).st_com_codigo = 'S' then
		    ws_textot := ws_textot||ws_pipe||'2';
		    ws_pipe   := '|';
		    ws_counter := ws_counter + 1;
	    else
		    ws_textot := ws_textot||ws_pipe||'1';
		    ws_pipe   := '|';
	    end if;
		
	end loop;

	-- Adiciona classe para consulta gerada em arquivo HTML 
	if ws_saida = 'H' then 
		htp_p('<style> .dir {text-align: right !important;} .inv {display:none;} </style>');  
	end if; 

	if ws_saida = 'O' then
        select count(*) into ws_count from usuarios where usu_nome = ws_usuario and nvl(excel_out, 'S') = 'S';
		if ws_count = 1 then
			htp_p('<a style="display: flex; flex-flow: column; align-items: center; margin-top: 20px;" href="'||ws_owner_bi||'.fcl.download_tab?prm_arquivo=spools_'||ws_usuario||'.xls&prm_alternativo="><span class="excel" title="'||fun.lang('Baixar xml')||'"></span></a>');
		else
			htp_p('<a style="display: flex; flex-flow: column; align-items: center; margin-top: 20px;"><span class="noexcel" title="'||fun.lang('Xml bloqueado')||'"></span></a>');
		end if;
	end if;

	htp_p('</div>');
	if  prm_drill!='Y' then
		htp_p('</div>');
	end if;


    if ws_saida = 'S' or ws_saida = 'O' then 
		fcl.gera_conteudo(ws_excel, ws_saida, '<Row><Cell><Data ss:Type="String"></Data></Cell></Row>');
		fcl.gera_conteudo(ws_excel, ws_saida, '<Row><Cell><Data ss:Type="String">'||fun.lang('FILTROS')||': '||fun.ptg_trans(fun.show_filtros(trim(ws_parametros), ws_cursor, ws_isolado, ws_objeto, prm_visao, prm_screen))||'</Data></Cell></Row>');
		fcl.gera_conteudo(ws_excel, ws_saida, '</Table></Worksheet></Workbook>', '', '');
	end if;

	-- Gera arquivo excel se a saida for S ou O
	select count(*) into ws_count from usuarios where usu_nome = ws_usuario and nvl(excel_out, 'S') = 'S';
	if ws_count = 1 then
		delete from tab_documentos where name = 'spools_'||ws_usuario||'.xls' and usuario = ws_usuario;
		if ws_saida in ('S','O') then  
			begin
				insert into tab_documentos values('spools_'||ws_usuario||'.xls', 'application/octet', '', 'ascii', sysdate, 'BLOB', fun.c2b(replace(replace(replace(ws_excel, '&', 'E'), '´', ''), '¿', '')), ws_usuario);
			exception when others then
				htp_p(sqlerrm);
			end;
		end if;
	end if;

	-- Gerar saida HTML se a saida for H 
	if ws_saida = 'H' and prm_objeton is not null then
		ws_html_t := '<head><meta http-equiv="Content-type" content="text/html; charset=utf-8" /></head>'||ws_html_t; 
		update tab_documentos set content_type ='BLOB', blob_content = fun.c2b(ws_html_t) 
		  where name = prm_objeton;
		commit; 
	end if; 

	if prm_drill = 'C' and nvl(ws_titulo, 'N/A') = 'N/A' then
		htp_p('<a class="addpurple" onclick="var desc = get(''custom-conteudo-desc'').value; if(desc.length > 3){ call(''save_consulta'', ''prm_visao=''+get(''prm_visao'').title+''&prm_nome='||ws_objeto||'&prm_desc=''+desc+''&prm_coluna=''+get(''prm_coluna_agrup'').title+''&prm_colup=''+get(''prm_coluna_pivot'').title+''&prm_agrupador=''+get(''prm_coluna_valor'').title+''&prm_grupo=&prm_rp=''+get(''prm_coluna_tipo'').title+''&prm_filtros=''+get(''filtropipe'').title).then(function(res){ if(res.indexOf(''#alert'') == -1){ alerta(''feed-fixo'', TR_CR); } }); } else { alerta(''feed-fixo'', TR_DS_LE); }" data-event="false" id="custom-conteudo-submit" style="float: right; margin: 12px 8px 0 0;">'||fun.lang('MATERIALIZAR CONSULTA')||'</a>');
	end if;

exception 
	when ws_excesso_filtro then
		if ws_log_exec in ('S','D') then 
			fun.log_exec_atu ('FIM', ws_log_exec, ws_log_exec_id, ws_objeto, ws_usuario, 'CONSULTA', 20, 'FINALIZADO - EXCESSO FILTROS', null); 
		end if; 

	    htp_p('<span class="err">'||ws_sql||'</span>','N');
		htp_p('</div>','N');
        insert into bi_log_sistema values(sysdate, 'CONSULTA: '||ws_sql, ws_usuario, 'ERRO');
		if ws_saida = 'H' and prm_objeton is not null then
			update tab_documentos set content_type ='ERRO', blob_content = fun.c2b('Excesso de filtros na consulta.') 
		  	 where name = prm_objeton;
		end if; 	 
		commit; 
	when ws_err_amostra then
		if ws_log_exec in ('S','D') then 
			fun.log_exec_atu ('FIM', ws_log_exec, ws_log_exec_id, ws_objeto, ws_usuario, 'CONSULTA', 20, 'FINALIZADO - ERRO AMOSTRA', null); 
		end if; 

		ws_html_1 := 'N&atilde;o foi poss&iacute;vel montar os dados da consulta, verifique as propriedades e atributos da consulta.'; 
		ws_html_2 := ws_html_1;
		if ws_admin = 'A' then 
		    ws_html_1 := ws_html_1 || '<br><br>'||fun.lang('ERRO:  Atributo AMOSTRAGEM ou AMOSTRA n&atilde;o pode estar junto com o atributo AGRUPAMENTO ROLLUP')||' <br><br>'||ws_queryoc||'</span>'; 
		else 
			ws_html_1 := ws_html_1 || '</span>';
		end if;  	
		htp_p(ws_html_1,'N'); 
        insert into bi_log_sistema values(sysdate, 'ERRO:  Atributo AMOSTRAGEM ou AMOSTRA no objeto '||prm_objeto||' n&atilde;o pode estar junto com o atributo AGRUPAMENTO ROLLUP - CONSULTA', ws_usuario, 'ERRO');
		commit;
	when ws_semquery then
		if ws_log_exec in ('S','D') then 
			fun.log_exec_atu ('FIM', ws_log_exec, ws_log_exec_id, ws_objeto, ws_usuario, 'CONSULTA', 20, 'FINALIZADO - SEM QUERY', null); 
		end if; 

	    htp_p('<span class="err">'||fun.lang('Relat&oacute;rio Sem Query')||'</span>','N');
		htp_p('</div>','N');
        insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - SEMQUERY', ws_usuario, 'ERRO');
		if ws_saida = 'H' and prm_objeton is not null then
			update tab_documentos set content_type ='ERRO', blob_content = fun.c2b('Consulta/Objeto sem query.')
		  	where name = prm_objeton;
		end if; 	
        commit;

	when ws_nodata then
		if ws_log_exec in ('S','D') then 
			fun.log_exec_atu ('FIM', ws_log_exec, ws_log_exec_id, ws_objeto, ws_usuario, 'CONSULTA', 20, 'FINALIZADO - SEM DADOS', null); 
		end if; 
		if ws_nodata_passo = '2' then 
			htp_p('</tbody></table></div></div>','N');  -- tbody >> table >> div m >> dv2 
		end if;
        if ws_admin = 'A' then
			htp_p('<span class="errquery">','N');
				ws_html_1 := fun.replace_binds_clob (ws_title, ws_binds);   --fcl.replace_binds(ws_title, ws_binds);
				IF WS_HTML_1 = 'Erro substituindo BINDs' THEN	
					htp_p(ws_title);
				ELSE		
					htp_p(ws_html_1,'N');
				END IF;
			htp_p('</span>','N');
		end if;
		htp_p('<span class="err">'||nvl(fun.getprop(ws_objeto, 'ERR_SD'), fun.lang('Sem Dados'))||'</span>','N');
		htp_p('</div>','N');
		if ws_saida = 'H' and prm_objeton is not null then
			ws_html_1 := '<div style="text-align: center;height: 83px;padding-top: 50px;font-size: 20px;border: 1px solid #000;">'||fun.lang('CONSULTA SEM DADOS.')||'</div>';
			update tab_documentos set content_type ='BLOB', blob_content = fun.c2b(ws_html_1) 
		  	where name = prm_objeton;
		end if;
		commit;	
	when others	then
		if ws_log_exec in ('S','D') then 
			fun.log_exec_atu ('FIM', ws_log_exec, ws_log_exec_id, ws_objeto, ws_usuario, 'CONSULTA', 20, 'FINALIZADO - ERRO OUTROS', null); 
		end if; 

		ws_html_1 := 'N&atilde;o foi poss&iacute;vel montar os dados da consulta, verifique as propriedades e atributos da consulta.'; 
		ws_html_2 := ws_html_1;
		if ws_admin = 'A' then 
		    ws_html_1 := ws_html_1 || '<br><br>ERRO: '||sqlerrm||' <br><br>'||ws_queryoc||'</span>'; 
		else 
			ws_html_1 := ws_html_1 || '</span>';
		end if;  	
		htp_p(ws_html_1,'N'); 
		htp_p('</div>','N');
        insert into log_eventos values(sysdate, substr(prm_visao||'/'||ws_coluna||'/'||trim(ws_parametros)||'/'||ws_rp||'/'||ws_colup||'/'||WS_AGRUPADOR,1,2000) , ws_usuario, 'OTHER', 'ERRORLINE', '01');
        insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - CONSULTA', ws_usuario, 'ERRO');
		if ws_saida = 'H' and prm_objeton is not null then
			update tab_documentos set content_type ='ERRO', blob_content = fun.c2b(ws_html_2)
		  	where name = prm_objeton;
		end if; 	
        commit;

end consulta;

procedure titulo  ( prm_objeto       varchar2 default null,
                    prm_drill        varchar2 default null,
					prm_desc         varchar2 default null,
					prm_screen       varchar2 default null,
					prm_valor        varchar2 default null,
					prm_param        varchar2 default null,
					prm_usuario      varchar2 default null,
					prm_param_filtro varchar2 default null,
					prm_track        varchar2 default null,
					prm_cd_goto     varchar2 default null, 
					prm_titulo    in out clob ) as 

	ws_prop_tit_color   varchar2(40);
	ws_prop_align_tit   varchar2(40);
	ws_prop_tit_size    varchar2(40);
	ws_prop_tit_it      varchar2(40);
	ws_prop_tit_bold    varchar2(40);
	ws_prop_tit_font    varchar2(40);
	ws_prop_tit_bgcolor varchar2(40);
	ws_prop_display     varchar2(40);
	ws_prop_color       varchar2(40);
	ws_prop_degrade     varchar2(40);
	ws_prop_fundo_tit   varchar2(40);
	ws_oculta_titulo    varchar2(10); 
	ws_aplica_destaque  varchar2(40);
	ws_tipo             varchar2(80);
	ws_sub              varchar2(4000);
	ws_objeto           varchar2(200);
	ws_blink            varchar2(800);
	ws_padrao           varchar2(80) := 'PORTUGUESE';
	ws_prop_sub_color	varchar2(80);
	ws_titulo           varchar2(500) := null; 
	ws_style_min_height varchar2(50);
	ws_style_sub_email  varchar2(300); 
	ws_objeto_aux       varchar2(100); 
	ws_objeto_ant       varchar2(100); 
	ws_ds_compl         varchar2(200); 
	ws_obj_html         varchar2(200);	
	ws_arr              arr;
    ws_usuario          varchar2(100);

begin
	
	prm_titulo := null; 

	if prm_drill = 'Y' then
		ws_objeto   := fun.get_cd_obj(prm_objeto);
        ws_obj_html := ws_objeto||'trl'||prm_cd_goto;
	else 	
		ws_objeto   := prm_objeto;
		ws_obj_html := prm_objeto;
	end if;

	select subtitulo, tp_objeto into ws_sub, ws_tipo from objetos where cd_objeto = ws_objeto;

	ws_padrao          := gbl.getLang;
	ws_aplica_destaque := 'titulo';
	
	if ws_tipo = 'CONSULTA' then
	    
		ws_arr := fun.getProps(ws_objeto, ws_tipo, 'ALIGN_TIT|DEGRADE|FUNDO_TIT|TIT_BOLD|TIT_COLOR|TIT_FONT|TIT_SIZE', ws_usuario,prm_screen);

	    ws_prop_align_tit    := ws_arr(1);
		ws_prop_degrade      := ws_arr(2);
		ws_prop_fundo_tit    := ws_arr(3);
		ws_prop_tit_bold     := ws_arr(4);
		ws_prop_tit_color    := ws_arr(5);		
		ws_prop_tit_font     := ws_arr(6);
		ws_prop_tit_size	 := ws_arr(7);

		
		ws_prop_sub_color 	:= fun.getprop(prm_objeto,'SUB_COLOR');
		ws_prop_tit_color    := 'color: '||ws_prop_tit_color;
		ws_prop_tit_bold    := 'font-weight: '||ws_prop_tit_bold;
	    ws_prop_tit_bgcolor := 'background-color: '||ws_prop_fundo_tit;
		ws_prop_align_tit   := 'text-align: '||ws_prop_align_tit;
		ws_prop_tit_size    := 'font-size: '||ws_prop_tit_size;
	    ws_prop_tit_font    := 'font-family: '||ws_prop_tit_font;

	elsif ws_tipo in ('PIZZA', 'LINHAS', 'BARRAS', 'COLUNAS', 'MAPA') then

	    ws_arr := fun.getProps(ws_objeto, ws_tipo, 'ALIGN_TIT|DEGRADE|TIT_BGCOLOR|TIT_BOLD|TIT_COLOR|TIT_FONT|TIT_IT|TIT_SIZE', ws_usuario, prm_screen);

	    ws_prop_align_tit   := ws_arr(1);
		ws_prop_degrade     := ws_arr(2);
		ws_prop_tit_bgcolor := ws_arr(3);
		ws_prop_tit_bold    := ws_arr(4);
		ws_prop_tit_color   := ws_arr(5);
		ws_prop_tit_font    := ws_arr(6);
		ws_prop_tit_it      := ws_arr(7);
		ws_prop_tit_size    := ws_arr(8);
		
		ws_prop_sub_color 	:=  fun.getprop(prm_objeto,'SUB_COLOR');
		ws_prop_tit_color   := 'color: '||ws_prop_tit_color;
		ws_prop_tit_size    := 'font-size: '||ws_prop_tit_size;
		ws_prop_tit_it      := 'font-style: '||ws_prop_tit_it;
        ws_prop_tit_bold    := 'font-weight: '||ws_prop_tit_bold;
	    ws_prop_tit_font    := 'font-family: '||ws_prop_tit_font;
	    ws_prop_tit_bgcolor := 'background-color: '||ws_prop_tit_bgcolor;
		ws_prop_align_tit   := 'text-align: '||ws_prop_align_tit;

	elsif ws_tipo = 'VALOR' then

		ws_arr := fun.getProps(ws_objeto, ws_tipo, 'ALIGN_TIT|APLICA_DESTAQUE|COLOR|DEGRADE|DISPLAY_TITLE|TIT_BGCOLOR|TIT_BOLD|TIT_COLOR|TIT_FONT|TIT_IT|TIT_SIZE', ws_usuario, prm_screen);

	    ws_prop_align_tit   := ws_arr(1);
		ws_aplica_destaque  := ws_arr(2);
		ws_prop_color       := ws_arr(3);
		ws_prop_degrade     := ws_arr(4);
		ws_prop_display     := ws_arr(5);
		ws_prop_tit_bgcolor := ws_arr(6);
		ws_prop_tit_bold    := ws_arr(7);
		ws_prop_tit_color   := ws_arr(8);
		ws_prop_tit_font    := ws_arr(9);
		ws_prop_tit_it      := ws_arr(10);
		ws_prop_tit_size    := ws_arr(11);
		
		ws_prop_sub_color 	:= fun.getprop(prm_objeto,'SUB_COLOR');
		ws_prop_tit_color   := 'color: '||ws_prop_tit_color;
		ws_prop_tit_size    := 'font-size: '||ws_prop_tit_size;
		ws_prop_tit_it      := 'font-style: '||ws_prop_tit_it;
        ws_prop_tit_bold    := 'font-weight: '||ws_prop_tit_bold;
	    ws_prop_tit_font    := 'font-family: '||ws_prop_tit_font;
	    ws_prop_tit_bgcolor := 'background-color: '||ws_prop_tit_bgcolor;
		ws_prop_display     := 'display: '||ws_prop_display;
		ws_prop_color       := 'color: '||ws_prop_color;
		ws_prop_align_tit   := 'text-align: '||ws_prop_align_tit;

	elsif ws_tipo = 'RELATORIO' then

		prm_titulo := null ;

	else

		ws_arr := fun.getProps(ws_objeto, ws_tipo, 'ALIGN_TIT|COLOR|DEGRADE|TIT_BGCOLOR|TIT_BOLD|TIT_COLOR|TIT_FONT|TIT_IT|TIT_SIZE', ws_usuario,prm_screen);

	    ws_prop_align_tit   := ws_arr(1);
		ws_prop_color       := ws_arr(2);
		ws_prop_degrade     := ws_arr(3);
		ws_prop_tit_bgcolor := ws_arr(4);
		ws_prop_tit_bold    := ws_arr(5);
		ws_prop_tit_color   := ws_arr(6);
		ws_prop_tit_font    := ws_arr(7);
		ws_prop_tit_it      := ws_arr(8);
		ws_prop_tit_size    := ws_arr(9);
		
		ws_prop_sub_color 	:= fun.getprop(ws_objeto,'SUB_COLOR');
		ws_prop_tit_color   := 'color: '||ws_prop_tit_color;
		ws_prop_tit_size    := 'font-size: '||ws_prop_tit_size;
		ws_prop_tit_it      := 'font-style: '||ws_prop_tit_it;
        ws_prop_tit_bold    := 'font-weight: '||ws_prop_tit_bold;
	    ws_prop_tit_font    := 'font-family: '||ws_prop_tit_font;
	    ws_prop_tit_bgcolor := 'background-color: '||ws_prop_tit_bgcolor;
		ws_prop_color       := 'color: '||ws_prop_color;
		ws_prop_align_tit   := 'text-align: '||ws_prop_align_tit;

	end if;

	ws_oculta_titulo     := nvl(fun.getprop(prm_objeto, 'OCULTA_TITULO'),'N'); 

	if ws_aplica_destaque not in ('titulo','ambos') then 
	   ws_blink := 'N/A';
	else    
  	   ws_blink  := fun.check_blink(prm_objeto, substr(prm_param, 1 ,instr(prm_param,'|')-1), NVL(prm_valor, 'N/A'), ws_prop_color, prm_screen, prm_usuario);
	end if;

	if nvl(ws_blink, 'N/A') <> 'N/A' then
        ws_blink := ws_blink||';';
	end if;

	-- Pega o objeto anterior e o complemento da descriç~çao da DRILL - caso tenha sido aberto em forma de DRILL 
	ws_objeto_ant := null;
	ws_objeto_aux := null;
	ws_ds_compl   := null;
	if nvl(prm_cd_goto,0) > 0 then 
		select max(ds_complemento) into ws_ds_compl 
		  from goto_objeto
		 where cd_goto_objeto = prm_cd_goto; 
	end if; 	


	if ws_oculta_titulo = 'N' then 
		ws_titulo := fun.subpar(fun.utranslate('NM_OBJETO', prm_objeto, prm_desc, ws_padrao), prm_screen, prm_usuario => prm_usuario, prm_param_filtro => prm_param_filtro); 
		if ws_ds_compl is not null then 
			ws_titulo := ws_ds_compl;
		end if;
	end if;

	prm_titulo := prm_titulo || '<div data-touch="0" class="wd_move drill_'||prm_drill||' degrade_'||ws_prop_degrade||'" id="'||ws_obj_html||'_ds">';
	if (fun.getprop(prm_objeto,'DISPLAY_TITLE') = 'N') OR (ws_tipo <> 'CONSULTA') then
		prm_titulo := prm_titulo ||ws_titulo; 
	end if;
	prm_titulo := prm_titulo ||'</div>';

    -- Escoder o título se não foi preenchido 
	ws_style_min_height := ''; 
	if nvl(length(ws_titulo),0) = 0 then 
		ws_style_min_height := 'min-height: 0px; ';
	end if; 

    --ESTILO SEPARADO DA CAMADA DE HTML
    --htp.prn('<style> div#'||trim(ws_objeto)||'_ds { '||ws_prop_align_tit||'; '||ws_prop_tit_color||'; '||ws_prop_tit_size||'; '||ws_prop_tit_it||'; '||ws_prop_tit_bold||'; '||ws_prop_tit_font||'; '||ws_blink||' '||ws_prop_display||'; /* verificar necessidade  text-indent: 14px; */ padding: 5px; '||ws_style_min_height||' } div#'||trim(ws_objeto)||'_ds:not(.degrade_S) { '||ws_prop_tit_bgcolor||'; } </style>');
	prm_titulo := prm_titulo || '<style> div#'||trim(ws_obj_html)||'_ds { '||ws_prop_align_tit||'; '||ws_prop_tit_color||'; '||ws_prop_tit_size||'; '||ws_prop_tit_it||'; '||ws_prop_tit_bold||'; '||ws_prop_tit_font||'; '||ws_blink||' '||ws_prop_display||'; /* verificar necessidade  text-indent: 14px; */ padding: 5px; '||ws_style_min_height||' } div#'||trim(ws_obj_html)||'_ds:not(.degrade_S) { '||ws_prop_tit_bgcolor||'; } </style>' ;  

	-- Subitulo 
	if nvl(ws_sub, 'N/A') <> 'N/A' then
		ws_style_sub_email := null;
		if prm_drill = 'R' then -- Formatação do subtitulo para report enviado por email 
			ws_style_sub_email := 'font-size: 10px;white-space: pre-line;';
		end if; 	
        --htp.p('<style>div#'||trim(ws_objeto)||'_sub { '||ws_prop_display||'; '||ws_prop_align_tit||'; '||ws_prop_tit_color||'; '||ws_blink||'; color: '||ws_prop_sub_color||'; }</style>');
	    --htp.p('<div class="sub" id="'||ws_objeto||'_sub">'||fun.subpar(fun.utranslate('NM_OBJETO', prm_objeto, ws_sub, ws_padrao), prm_screen)||'</div>');
		prm_titulo := prm_titulo || '<style>div#'||trim(ws_obj_html)||'_sub { '||ws_prop_display||'; '||ws_prop_align_tit||'; '||ws_prop_tit_color||'; '||ws_blink||'; color: '||ws_prop_sub_color||';'||ws_style_sub_email||' }</style>'; 
		prm_titulo := prm_titulo || '<div class="sub" id="'||ws_obj_html||'_sub">'||fun.subpar(fun.utranslate('NM_OBJETO', prm_objeto, ws_sub, ws_padrao), prm_screen, prm_usuario => prm_usuario, prm_param_filtro => prm_param_filtro)||'</div>'; 		
	end if;

exception when others then
	if nvl(gbl.getNivel,'.') = 'A' then 
		prm_titulo := 'Erro montando titulo: '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE; 
	else 
		prm_titulo := 'Erro no titulo';
	end if; 
end titulo;

procedure opcoes ( prm_objeto  varchar2 default null,
                       prm_tipo    varchar2 default null,
                       prm_par     varchar2 default null,
					   prm_visao   varchar2 default null,
					   prm_screen  varchar2 default null,
					   prm_drill   varchar2 default null,
					   prm_agrup   varchar2 default null,
					   prm_colup   varchar2 default null,
					   prm_usuario varchar2 default null ) as

    ws_count        		number;
	ws_drill        		boolean := false;
	ws_filter       		boolean := false;
	ws_itens        		number  := 0;
	ws_tpt          		varchar2(400);
	ws_admin        		varchar2(80);
	ws_usuario      		varchar2(80);
	ws_tempo_query  		number  := 0;
	ws_tempo_avg    		number  := 0;
	ws_query_hint   		varchar2(80);
	ws_nome         		varchar2(200);
	ws_obs					varchar2(4000);
	ws_largura      		varchar2(60)    := '0';
	ws_null         		varchar2(1)     := null;
	ws_count_filtro    		number;
	ws_count_destaque  		number;
	ws_qt_opcoes       		integer; 
	ws_prn_opcoes      		varchar2(10000); 
	ws_excel_out       		varchar2(10); 
	WS_ULTIMA_ATUALIZACAO	varchar2(20);
	ws_span_tempo           varchar2(4000); 
	ws_nm_tabela            varchar2(200);
	ws_nm_tabela_fis        varchar2(200);
	ws_objeto               varchar2(200);
	ws_obj_html             varchar2(200);

    ws_admin_drill_ex  		boolean;
	ws_admin_drill_ad  		boolean; 
	ws_admin_filtro_ex 		boolean; 
	ws_admin_filtro_ad 		boolean; 
	ws_admin_attrib    		boolean;
	    
begin


	if nvl(prm_usuario, 'N/A') = 'N/A' then
        ws_usuario := gbl.getUsuario;
	else
		ws_usuario := prm_usuario;
	end if;

	ws_admin           := gbl.getNivel;
    ws_admin_drill_ex  := fun.check_admin('DRILLS_EX');
	ws_admin_drill_ad  := fun.check_admin('DRILLS_ADD'); 
	ws_admin_filtro_ex := fun.check_admin('FILTERS_EX');
	ws_admin_filtro_ad := fun.check_admin('FILTERS_ADD');
	ws_admin_attrib    := fun.check_admin('ATTRIB_ALT');

	ws_objeto   := fun.get_cd_obj(prm_objeto);
	ws_obj_html := prm_objeto; 

	select nvl(max(excel_out),'S') into ws_excel_out from usuarios where usu_nome = ws_usuario and rownum = 1;

	select nm_objeto, fun.subpar(ds_objeto, prm_screen) into ws_nome, ws_obs from objetos where cd_objeto = ws_objeto ;
	ws_obs := replace(ws_obs,'"', '&quot;');

	if nvl(ws_admin, 'N') <> 'A' then
		if ws_admin_drill_ad and ws_admin_drill_ex then
            ws_drill := true;
		else
            ws_drill := false;
		end if;
	    
		if fun.check_admin('FILTERS_ADD') and fun.check_admin('FILTERS_EX') then
            ws_filter := true;
		else
            ws_filter := false;
		end if;
	end if;

	--gravar a última att da visão na variável ws_ultima_atualizacao pra reusar em mais tipos de objetos
	ws_nm_tabela     := null;
	ws_ultima_atualizacao := null; 
	SELECT MAX(nm_tabela),  to_char(max(mi1.dt_ultima_atualizacao),'dd/mm/yyyy hh24:mi') INTO ws_nm_tabela, ws_ultima_atualizacao
	  FROM micro_visao       mi1,
		   ponto_avaliacao   po1
	 WHERE mi1.nm_micro_visao = po1.cd_micro_visao
	   AND po1.cd_ponto = ws_objeto
	   AND ROWNUM = 1;
	ws_nm_tabela_fis := fun.GETPROP (ws_objeto, 'TABELA_FISICA_OBJETO');	   
	if ws_nm_tabela_fis is not null then 
	   ws_nm_tabela := ws_nm_tabela_fis; 
	end if; 
	select count(*) into ws_count from all_tables where owner = nvl(fun.ret_var('OWNER_TABLE_DATA'),'DWU') and table_name = ws_nm_tabela; 
	if ws_count > 0 then 
		if ws_ultima_atualizacao is not null then 
			ws_span_tempo := '<span class="tempo" data-obs="<h4>&Uacute;ltima Atualiza&ccedil;&atilde;o</h4><span>'||WS_ULTIMA_ATUALIZACAO||'</span>" onclick="objObs(this.getAttribute(''data-obs''));"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" style="margin-top: 0px;><title>Stopwatch</title><g id=" _11_-_20"="" data-name="11 - 20"><g id="Stopwatch"><path d="M38.1,14.312l1.455-1.454.793.793a1,1,0,0,0,1.414-1.414l-3-3a1,1,0,1,0-1.414,1.414l.792.793L36.688,12.9A18.892,18.892,0,0,0,25,8.051V7h2a2,2,0,0,0,2-2V4a2,2,0,0,0-2-2H21a2,2,0,0,0-2,2V5a2,2,0,0,0,2,2h2V8.051A18.892,18.892,0,0,0,11.312,12.9L9.858,11.444l.792-.793A1,1,0,1,0,9.236,9.237l-3,3A1,1,0,1,0,7.65,13.651l.793-.793L9.9,14.312a19,19,0,1,0,28.2,0ZM21,4h6V5H21Zm3,40A17,17,0,1,1,41,27,17.019,17.019,0,0,1,24,44Z"></path><path d="M24,12A15,15,0,1,0,39,27,15.017,15.017,0,0,0,24,12ZM35,28h1.949a12.919,12.919,0,0,1-3.088,7.447l-1.376-1.376a1,1,0,1,0-1.414,1.414l1.376,1.376A12.926,12.926,0,0,1,25,39.949V38a1,1,0,0,0-2,0v1.949a12.926,12.926,0,0,1-7.447-3.088l1.376-1.376a1,1,0,1,0-1.414-1.414l-1.376,1.376A12.919,12.919,0,0,1,11.051,28H13a1,1,0,0,0,0-2H11.051a12.919,12.919,0,0,1,3.088-7.447l1.376,1.376a1,1,0,1,0,1.414-1.414l-1.376-1.376A12.926,12.926,0,0,1,23,14.051V16a1,1,0,0,0,2,0V14.051a12.926,12.926,0,0,1,7.447,3.088l-1.376,1.376a1,1,0,1,0,1.414,1.414l1.376-1.376A12.919,12.919,0,0,1,36.949,26H35a1,1,0,0,0,0,2Z"></path><path d="M27.827,17.761a1,1,0,0,0-1.306.541l-2.367,5.714c-.052,0-.1-.016-.154-.016a3.03,3.03,0,1,0,2,.781l2.367-5.713A1,1,0,0,0,27.827,17.761ZM24,28a1,1,0,1,1,1-1A1,1,0,0,1,24,28Z"></path></g></svg></span>'; 
		else 
			ws_span_tempo := '<span class="tempo" onclick="alerta(''feed-fixo'', ''Objeto n&atilde;o possui informa&ccedil;&atilde;o de data da &uacute;ltima atualiza&ccedil;&atilde;o dos dados'') ;"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" style="margin-top: 0px;><title>Stopwatch</title><g id=" _11_-_20"="" data-name="11 - 20"><g id="Stopwatch"><path d="M38.1,14.312l1.455-1.454.793.793a1,1,0,0,0,1.414-1.414l-3-3a1,1,0,1,0-1.414,1.414l.792.793L36.688,12.9A18.892,18.892,0,0,0,25,8.051V7h2a2,2,0,0,0,2-2V4a2,2,0,0,0-2-2H21a2,2,0,0,0-2,2V5a2,2,0,0,0,2,2h2V8.051A18.892,18.892,0,0,0,11.312,12.9L9.858,11.444l.792-.793A1,1,0,1,0,9.236,9.237l-3,3A1,1,0,1,0,7.65,13.651l.793-.793L9.9,14.312a19,19,0,1,0,28.2,0ZM21,4h6V5H21Zm3,40A17,17,0,1,1,41,27,17.019,17.019,0,0,1,24,44Z"></path><path d="M24,12A15,15,0,1,0,39,27,15.017,15.017,0,0,0,24,12ZM35,28h1.949a12.919,12.919,0,0,1-3.088,7.447l-1.376-1.376a1,1,0,1,0-1.414,1.414l1.376,1.376A12.926,12.926,0,0,1,25,39.949V38a1,1,0,0,0-2,0v1.949a12.926,12.926,0,0,1-7.447-3.088l1.376-1.376a1,1,0,1,0-1.414-1.414l-1.376,1.376A12.919,12.919,0,0,1,11.051,28H13a1,1,0,0,0,0-2H11.051a12.919,12.919,0,0,1,3.088-7.447l1.376,1.376a1,1,0,1,0,1.414-1.414l-1.376-1.376A12.926,12.926,0,0,1,23,14.051V16a1,1,0,0,0,2,0V14.051a12.926,12.926,0,0,1,7.447,3.088l-1.376,1.376a1,1,0,1,0,1.414,1.414l1.376-1.376A12.919,12.919,0,0,1,36.949,26H35a1,1,0,0,0,0,2Z"></path><path d="M27.827,17.761a1,1,0,0,0-1.306.541l-2.367,5.714c-.052,0-.1-.016-.154-.016a3.03,3.03,0,1,0,2,.781l2.367-5.713A1,1,0,0,0,27.827,17.761ZM24,28a1,1,0,1,1,1-1A1,1,0,0,1,24,28Z"></path></g></svg></span>'; 				
			--ws_span_tempo := '<span class="tempo" onclick="alerta(''feed-fixo'', ''Objeto n&atilde;o possui informa&ccedil;&otilde;es sobre atualiza&ccedil;&atilde;o dos dados'') ;"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" style="margin-top: 0px;><title>Stopwatch</title><g id=" _11_-_20"="" data-name="11 - 20"><g id="Stopwatch"><path d="M38.1,14.312l1.455-1.454.793.793a1,1,0,0,0,1.414-1.414l-3-3a1,1,0,1,0-1.414,1.414l.792.793L36.688,12.9A18.892,18.892,0,0,0,25,8.051V7h2a2,2,0,0,0,2-2V4a2,2,0,0,0-2-2H21a2,2,0,0,0-2,2V5a2,2,0,0,0,2,2h2V8.051A18.892,18.892,0,0,0,11.312,12.9L9.858,11.444l.792-.793A1,1,0,1,0,9.236,9.237l-3,3A1,1,0,1,0,7.65,13.651l.793-.793L9.9,14.312a19,19,0,1,0,28.2,0ZM21,4h6V5H21Zm3,40A17,17,0,1,1,41,27,17.019,17.019,0,0,1,24,44Z"></path><path d="M24,12A15,15,0,1,0,39,27,15.017,15.017,0,0,0,24,12ZM35,28h1.949a12.919,12.919,0,0,1-3.088,7.447l-1.376-1.376a1,1,0,1,0-1.414,1.414l1.376,1.376A12.926,12.926,0,0,1,25,39.949V38a1,1,0,0,0-2,0v1.949a12.926,12.926,0,0,1-7.447-3.088l1.376-1.376a1,1,0,1,0-1.414-1.414l-1.376,1.376A12.919,12.919,0,0,1,11.051,28H13a1,1,0,0,0,0-2H11.051a12.919,12.919,0,0,1,3.088-7.447l1.376,1.376a1,1,0,1,0,1.414-1.414l-1.376-1.376A12.926,12.926,0,0,1,23,14.051V16a1,1,0,0,0,2,0V14.051a12.926,12.926,0,0,1,7.447,3.088l-1.376,1.376a1,1,0,1,0,1.414,1.414l1.376-1.376A12.919,12.919,0,0,1,36.949,26H35a1,1,0,0,0,0,2Z"></path><path d="M27.827,17.761a1,1,0,0,0-1.306.541l-2.367,5.714c-.052,0-.1-.016-.154-.016a3.03,3.03,0,1,0,2,.781l2.367-5.713A1,1,0,0,0,27.827,17.761ZM24,28a1,1,0,1,1,1-1A1,1,0,0,1,24,28Z"></path></g></svg></span>'; 		
		end if; 
	else
		ws_span_tempo := null;
	end if; 

	case

	    when prm_tipo = 'CONSULTA' then

			/* já é adicionado na procedure CONSULTA  
			IF NVL(WS_OBS, 'N/A') <> 'N/A' THEN
				HTP.P('<span class="obs" data-obs="<h4>'||FUN.LANG('Observa&ccedil;&otilde;es do objeto')||'</h4><span>'||WS_OBS||'</span>" onclick="objObs(this.getAttribute(''data-obs''));">&#63;</span>');
			END IF;
			**/ 
			
			if prm_drill = 'C' then
					htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options closed" id="'||ws_obj_html||'more">');
						htp.p(fun.showtag(ws_obj_html, 'atrib', prm_screen));
						htp.p('<span class="preferencias" data-visao="'||prm_visao||'" data-drill="'||prm_drill||'" title="'||fun.lang('Propriedades')||'"></span>');
						htp.p(fun.showtag(ws_obj_html, 'filter', prm_visao));
						htp.p(fun.showtag(ws_obj_html||'c', 'excel'));
					htp.p('</span>');
			elsif prm_drill = 'O' then 
				htp.p(ws_null);
			else 
				if ws_admin = 'A' then

					if prm_drill = 'Y' then
						htp.p('<a class="fechar" id="'||ws_obj_html||'fechar" title="'||fun.lang('Fechar')||'"></a>');
						htp.p('<a class="fechar_app" id="'||ws_obj_html||'fechar_app"></a>');   -- Somente efeito visual, a acão continua no elemento 'fechar' 
					end if; 

					htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options closed" id="'||ws_obj_html||'more">');
						htp.p(fun.showtag(ws_obj_html, 'atrib', prm_screen));
						htp.p('<span class="preferencias" data-visao="'||prm_visao||'" data-drill="'||prm_drill||'" title="'||fun.lang('Propriedades')||'"></span>');
						htp.p(fun.showtag(ws_obj_html, 'filter', prm_visao));
						htp.p('<span class="sigma" title="'||fun.lang('Linha calculada')||'"></span>');
						htp.p('<span class="lightbulb" title="'||fun.lang('Drill')||'"></span>');
						htp.p(fun.showtag(ws_obj_html||'c', 'excel'));
						htp.p('<span class="data_table" title="'||fun.lang('Alterar Consulta')||'"></span>');
						htp.p(fun.showtag('', 'star'));
						if prm_drill = 'Y' then
							htp.p('<span title="'||FUN.LANG('Marcar objeto')||'" style="position: relative; height: 26px; width: 20px; float: left; text-align: center; line-height: 32px;" onclick="loading(); ajax(''fly'', ''favoritar'', ''prm_objeto='||ws_OBJETO||'&prm_nome=''+document.getElementById('''||ws_obj_html||'_ds'').innerHTML+''&prm_url=&prm_screen=''+document.getElementById(''current_screen'').value+''&prm_parametros=''+encodeURIComponent(document.getElementById(''par_'||ws_obj_html||''').value)+''&prm_dimensao=''+encodeURIComponent(document.getElementById(''col_'||ws_obj_html||''').value)+''&prm_medida=''+encodeURIComponent(document.getElementById(''agp_'||ws_obj_html||''').value)+''&prm_pivot=''+encodeURIComponent(document.getElementById(''cup_'||ws_obj_html||''').value)+''&prm_acao=incluir'', false); loading(); call(''obj_screen_count'', ''prm_screen=''+tela+''&prm_tipo=FAVORITOS'').then(function(resposta){ if(parseInt(resposta) > 0){ document.getElementById(''favoritos'').classList.remove(''inv''); } else { document.getElementById(''favoritos'').classList.add(''inv''); } });">');
								htp.p('<svg style="height: 16px; width: 16px;" version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" 	 width="613.408px" height="613.408px" viewBox="0 0 613.408 613.408" style="enable-background:new 0 0 613.408 613.408;" 	 xml:space="preserve"> <g> 	<path d="M605.254,168.94L443.792,7.457c-6.924-6.882-17.102-9.239-26.319-6.069c-9.177,3.128-15.809,11.241-17.019,20.855 		l-9.093,70.512L267.585,216.428h-142.65c-10.344,0-19.625,6.215-23.629,15.746c-3.92,9.573-1.71,20.522,5.589,27.779 		l105.424,105.403L0.699,613.408l246.635-212.869l105.423,105.402c4.881,4.881,11.45,7.467,17.999,7.467 		c3.295,0,6.632-0.709,9.78-2.002c9.573-3.922,15.726-13.244,15.726-23.504V345.168l123.839-123.714l70.429-9.176 		c9.614-1.251,17.727-7.862,20.813-17.039C614.472,186.021,612.136,175.801,605.254,168.94z M504.856,171.985 		c-5.568,0.751-10.762,3.232-14.745,7.237L352.758,316.596c-4.796,4.775-7.466,11.242-7.466,18.041v91.742L186.437,267.481h91.68 		c6.757,0,13.243-2.669,18.04-7.466L433.51,122.766c3.983-3.983,6.569-9.176,7.258-14.786l3.629-27.696l88.155,88.114 		L504.856,171.985z"/> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');              
							htp.p('</span>');
						else 
							fcl.button_lixo('dl_obj', prm_objeto=> ws_obj_html, prm_tag => 'span');
						end if;
						htp.p(fun.showtag(prm_objeto, 'clone'));
					htp.p('</span>');
				else

					if prm_drill = 'Y' then
						htp.p('<a class="fechar" id="'||ws_obj_html||'fechar" title="'||fun.lang('Fechar')||'"></a>');
						htp.p('<a class="fechar_app" id="'||ws_obj_html||'fechar_app"></a>');   -- Somente efeito visual, a acão continua no elemento 'fechar' 
					end if; 

					if nvl(fun.getprop(ws_objeto,'NO_OPTION'),'N') <> 'S' then

						select count(*) into ws_count from ponto_avaliacao where cs_agrupador in (select nvl(cd_coluna, 'N/A') from micro_coluna where st_agrupador = 'TPT' and cd_micro_visao = prm_visao) and cd_ponto = ws_objeto;
						if ws_count > 0 then
							select nvl(cs_agrupador, 'N/A') into ws_tpt from ponto_avaliacao where cs_agrupador in (select nvl(cd_coluna, 'N/A') from micro_coluna where st_agrupador = 'TPT' and cd_micro_visao = prm_visao) and cd_ponto = ws_objeto;
						else
							ws_tpt := 'N/A';
						end if;


						ws_prn_opcoes := ''; 
						ws_qt_opcoes  := 0; 

						if fun.check_admin('ATTRIB_ALT') THEN
							ws_qt_opcoes := ws_qt_opcoes + 1; 
							ws_prn_opcoes:= ws_prn_opcoes ||fun.showtag(ws_obj_html, 'atrib', prm_screen);
						end if;

						if ws_admin_drill_ex or ws_admin_drill_ad then
							ws_qt_opcoes  := ws_qt_opcoes + 1; 
							ws_prn_opcoes := ws_prn_opcoes || '<span class="lightbulb" title="'||fun.lang('Drill')||'"></span>';
						end if;

						if ws_admin_filtro_ex or ws_admin_filtro_ad then
							ws_qt_opcoes := ws_qt_opcoes + 1; 
							ws_prn_opcoes := ws_prn_opcoes || fun.showtag(ws_obj_html, 'filter', prm_visao);
						end if;

						if ws_excel_out = 'S' then 
							ws_qt_opcoes := ws_qt_opcoes + 1; 
							ws_prn_opcoes := ws_prn_opcoes || fun.showtag(ws_obj_html||'c', 'excel');
						end if; 	

						if ws_tpt <> 'N/A'then
							ws_qt_opcoes := ws_qt_opcoes + 1; 
							ws_prn_opcoes := ws_prn_opcoes || '<span class="data_table" title="'||fun.lang('Alterar Template')||'" onclick=" fakeOption('''||ws_tpt||''', ''Op&ccedil;&otilde;es do template'', ''template'', '''||prm_visao||''');"></span>';
						end if;

						if prm_drill = 'Y' then
							ws_qt_opcoes := ws_qt_opcoes + 1; 							
							ws_prn_opcoes := ws_prn_opcoes 	|| '<span title="'||FUN.LANG('Marcar objeto')||'" style="position: relative; height: 26px; width: 20px; float: left; text-align: center; line-height: 32px;" onclick="loading(); ajax(''fly'', ''favoritar'', ''prm_objeto='||ws_OBJETO||'&prm_nome=''+document.getElementById('''||ws_obj_html||'_ds'').innerHTML+''&prm_url=&prm_screen=''+document.getElementById(''current_screen'').value+''&prm_parametros=''+encodeURIComponent(document.getElementById(''par_'||ws_obj_html||''').value)+''&prm_dimensao=''+encodeURIComponent(document.getElementById(''col_'||ws_obj_html||''').value)+''&prm_medida=''+encodeURIComponent(document.getElementById(''agp_'||ws_obj_html||''').value)+''&prm_pivot=''+encodeURIComponent(document.getElementById(''cup_'||ws_obj_html||''').value)+''&prm_acao=incluir'', false); loading(); call(''obj_screen_count'', ''prm_screen=''+tela+''&prm_tipo=FAVORITOS'').then(function(resposta){ if(parseInt(resposta) > 0){ document.getElementById(''favoritos'').classList.remove(''inv''); } else { document.getElementById(''favoritos'').classList.add(''inv''); } });">'
															||   '<svg style="height: 16px; width: 16px;" version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" 	 width="613.408px" height="613.408px" viewBox="0 0 613.408 613.408" style="enable-background:new 0 0 613.408 613.408;" 	 xml:space="preserve"> <g> 	<path d="M605.254,168.94L443.792,7.457c-6.924-6.882-17.102-9.239-26.319-6.069c-9.177,3.128-15.809,11.241-17.019,20.855 		l-9.093,70.512L267.585,216.428h-142.65c-10.344,0-19.625,6.215-23.629,15.746c-3.92,9.573-1.71,20.522,5.589,27.779 		l105.424,105.403L0.699,613.408l246.635-212.869l105.423,105.402c4.881,4.881,11.45,7.467,17.999,7.467 		c3.295,0,6.632-0.709,9.78-2.002c9.573-3.922,15.726-13.244,15.726-23.504V345.168l123.839-123.714l70.429-9.176 		c9.614-1.251,17.727-7.862,20.813-17.039C614.472,186.021,612.136,175.801,605.254,168.94z M504.856,171.985 		c-5.568,0.751-10.762,3.232-14.745,7.237L352.758,316.596c-4.796,4.775-7.466,11.242-7.466,18.041v91.742L186.437,267.481h91.68 		c6.757,0,13.243-2.669,18.04-7.466L433.51,122.766c3.983-3.983,6.569-9.176,7.258-14.786l3.629-27.696l88.155,88.114 		L504.856,171.985z"/> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>'              
															|| '</span>';
						end if; 

						if ws_qt_opcoes > 0 then 
							if    ws_qt_opcoes = 1 			then   	  		ws_largura := 'max-width: 34px; max-height: 32px;';
							elsif ws_qt_opcoes = 2 			then     		ws_largura := 'max-width: 68px; max-height: 32px;';
							elsif ws_qt_opcoes = 3 		    then     		ws_largura := 'max-width: 102px; max-height: 32px;';
							elsif ws_qt_opcoes in (4,5,6)   then     		ws_largura := 'max-width: 102px; max-height: 64px;';
							elsif ws_qt_opcoes in (7,8,9) 	then     		ws_largura := 'max-width: 102px; max-height: 96px;';
							elsif ws_qt_opcoes >= 10 		then    		ws_largura := 'max-width: 102px; max-height: 128px;';
							end if; 
							htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options closed" id="'||ws_obj_html||'more" style="'||ws_largura||'">');
								htp.p(ws_prn_opcoes); 
							htp.p('</span>');
						end if; 
					end if;

				end if; 
			end if;

		when prm_tipo = 'VALOR' then

		    if instr(prm_objeto, 'trl') = 0 and instr(prm_objeto, 'temp') = 0 then
			    htp.p('<span id="'||ws_obj_html||'sync" class="sync" title="'||ws_query_hint||'"><img src="'||nvl(fun.ret_var('OWNER_BI'),'DWU')||'.fcl.download?arquivo=sinchronize.png" /></span>');
			else
                htp.p('<a class="fechar" id="'||ws_obj_html||'fechar" title="'||fun.lang('Fechar')||'">');
					htp.p('<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="612px" height="612px" viewBox="0 0 612 612" style="enable-background:new 0 0 612 612;" xml:space="preserve"> <g> 	<g id="cross"> 		<g> 			<polygon points="612,36.004 576.521,0.603 306,270.608 35.478,0.603 0,36.004 270.522,306.011 0,575.997 35.478,611.397 				306,341.411 576.521,611.397 612,575.997 341.459,306.011 			"></polygon> 		</g> 	</g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
				htp.p('</a>');
				htp.p('<a class="fechar_app" id="'||ws_obj_html||'fechar_app"></a>');   -- Somente efeito visual, a acão continua no elemento 'fechar' 
			end if;
			
			if ws_admin = 'A' then
				htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options closed" id="'||ws_obj_html||'more" >');
					htp.p(fun.showtag(ws_obj_html, 'atrib', prm_screen));
					--htp.p(fun.showtag(prm_objeto, 'post'));
					htp.p('<span class="preferencias" alt="P" title="'||fun.lang('Propriedades')||'"></span>');
					htp.p(fun.showtag(ws_obj_html, 'filter', prm_visao));
					htp.p('<span class="lightbulb" title="'||fun.lang('Drills')||'"></span>');
					htp.p('<span class="star" title="'||fun.lang('Alterar Destaque')||'" ></span>');
                    --htp.p('<span class="removeobj" title="'||fun.lang('Excluir')||'" ></span>');
					fcl.button_lixo('dl_obj', prm_objeto=> ws_obj_html, prm_tag => 'span');
					htp.p(fun.showtag(prm_objeto, 'clone'));
				htp.p('</span>');
			else
				if nvl(fun.getprop(ws_objeto,'NO_OPTION'),'N') <> 'S' then
				    htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options closed" id="'||ws_obj_html||'more">');
					--if prm_drill = 'Y' or instr(prm_objeto, 'temp') > 0 then
					--    htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options closed" id="'||prm_objeto||'more">');
					--else
					--    htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options closed" id="'||prm_objeto||'more">');
					--end if;	
						if fun.check_admin('ATTRIB_ALT') THEN
							htp.p(fun.showtag(ws_obj_html, 'atrib', prm_screen));
							ws_itens := ws_itens+1; 
						end if;

						if ws_filter then
						    htp.p(fun.showtag(ws_obj_html, 'filter', prm_visao));
							ws_itens := ws_itens+1;
						end if;
						
						if ws_drill then
						    htp.p('<span class="lightbulb" title="'||fun.lang('Drills')||'"></span>');
							ws_itens := ws_itens+1;
						end if;

						--htp.p('<span class="star" title="'||fun.lang('Alterar Destaque')||'" ></span>');
						--ws_itens := ws_itens+1;
					htp.p('</span>');
					ws_itens := 34*ws_itens;
				    if ws_itens = 0 then
					    htp.p('<style>div#'||ws_obj_html||' span.options { display: none; } div#'||ws_obj_html||' span.turn { right: 3px; }</style>');
					else
					    htp.p('<style>div#'||ws_obj_html||' span.options { max-width: '||ws_itens||'px; max-height: 33px; }</style>');
					end if;
				end if;

				if prm_drill = 'Y' or instr(prm_objeto, 'temp') <> 0 then
					htp.p('<a class="fechar" id="'||ws_obj_html||'fechar" title="'||fun.lang('Fechar')||'"></a>');
					htp.p('<a class="fechar_app" id="'||ws_obj_html||'fechar_app"></a>');   -- Somente efeito visual, a acão continua no elemento 'fechar' 					
				end if;

			end if;

			ws_count_filtro   := length(trim(fun.show_filtros(prm_par, '', '', ws_objeto, prm_visao, prm_screen)));
			ws_count_destaque := length(trim(fun.show_destaques(prm_par, '', '', ws_objeto, prm_visao, prm_screen)));
			
			if ws_count_filtro > 3 or ws_count_destaque > 3 or nvl(ws_obs, 'N/A') <> 'N/A' or ws_span_tempo is not null then
				htp.p('<span class="turn">');
				
				htp.p(ws_span_tempo);
				-- htp.p('<span class="tempo" data-obs="<h4>&Uacute;ltima Atualiza&ccedil;&atilde;o</h4><span>'||WS_ULTIMA_ATUALIZACAO||'</span>" onclick="objObs(this.getAttribute(''data-obs''));"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" style="margin-top: 0px;><title>Stopwatch</title><g id=" _11_-_20"="" data-name="11 - 20"><g id="Stopwatch"><path d="M38.1,14.312l1.455-1.454.793.793a1,1,0,0,0,1.414-1.414l-3-3a1,1,0,1,0-1.414,1.414l.792.793L36.688,12.9A18.892,18.892,0,0,0,25,8.051V7h2a2,2,0,0,0,2-2V4a2,2,0,0,0-2-2H21a2,2,0,0,0-2,2V5a2,2,0,0,0,2,2h2V8.051A18.892,18.892,0,0,0,11.312,12.9L9.858,11.444l.792-.793A1,1,0,1,0,9.236,9.237l-3,3A1,1,0,1,0,7.65,13.651l.793-.793L9.9,14.312a19,19,0,1,0,28.2,0ZM21,4h6V5H21Zm3,40A17,17,0,1,1,41,27,17.019,17.019,0,0,1,24,44Z"></path><path d="M24,12A15,15,0,1,0,39,27,15.017,15.017,0,0,0,24,12ZM35,28h1.949a12.919,12.919,0,0,1-3.088,7.447l-1.376-1.376a1,1,0,1,0-1.414,1.414l1.376,1.376A12.926,12.926,0,0,1,25,39.949V38a1,1,0,0,0-2,0v1.949a12.926,12.926,0,0,1-7.447-3.088l1.376-1.376a1,1,0,1,0-1.414-1.414l-1.376,1.376A12.919,12.919,0,0,1,11.051,28H13a1,1,0,0,0,0-2H11.051a12.919,12.919,0,0,1,3.088-7.447l1.376,1.376a1,1,0,1,0,1.414-1.414l-1.376-1.376A12.926,12.926,0,0,1,23,14.051V16a1,1,0,0,0,2,0V14.051a12.926,12.926,0,0,1,7.447,3.088l-1.376,1.376a1,1,0,1,0,1.414,1.414l1.376-1.376A12.919,12.919,0,0,1,36.949,26H35a1,1,0,0,0,0,2Z"></path><path d="M27.827,17.761a1,1,0,0,0-1.306.541l-2.367,5.714c-.052,0-.1-.016-.154-.016a3.03,3.03,0,1,0,2,.781l2.367-5.713A1,1,0,0,0,27.827,17.761ZM24,28a1,1,0,1,1,1-1A1,1,0,0,1,24,28Z"></path></g></svg></span>');
	
				--htp.p('<span class="tempo" onclick="ajax(''list'',''atu_view'',''prm_screen=&prm_objeto='||prm_objeto||''', false,''attriblist'');if(!document.getElementById(''attriblist'').classList.contains(''open'')){document.getElementById(''attriblist'').classList.add(''open'');}else{document.getElementById(''attriblist'').classList.remove(''open'');}"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" style="margin-top: 0px;><title>Stopwatch</title><g id=" _11_-_20"="" data-name="11 - 20"><g id="Stopwatch"><path d="M38.1,14.312l1.455-1.454.793.793a1,1,0,0,0,1.414-1.414l-3-3a1,1,0,1,0-1.414,1.414l.792.793L36.688,12.9A18.892,18.892,0,0,0,25,8.051V7h2a2,2,0,0,0,2-2V4a2,2,0,0,0-2-2H21a2,2,0,0,0-2,2V5a2,2,0,0,0,2,2h2V8.051A18.892,18.892,0,0,0,11.312,12.9L9.858,11.444l.792-.793A1,1,0,1,0,9.236,9.237l-3,3A1,1,0,1,0,7.65,13.651l.793-.793L9.9,14.312a19,19,0,1,0,28.2,0ZM21,4h6V5H21Zm3,40A17,17,0,1,1,41,27,17.019,17.019,0,0,1,24,44Z"></path><path d="M24,12A15,15,0,1,0,39,27,15.017,15.017,0,0,0,24,12ZM35,28h1.949a12.919,12.919,0,0,1-3.088,7.447l-1.376-1.376a1,1,0,1,0-1.414,1.414l1.376,1.376A12.926,12.926,0,0,1,25,39.949V38a1,1,0,0,0-2,0v1.949a12.926,12.926,0,0,1-7.447-3.088l1.376-1.376a1,1,0,1,0-1.414-1.414l-1.376,1.376A12.919,12.919,0,0,1,11.051,28H13a1,1,0,0,0,0-2H11.051a12.919,12.919,0,0,1,3.088-7.447l1.376,1.376a1,1,0,1,0,1.414-1.414l-1.376-1.376A12.926,12.926,0,0,1,23,14.051V16a1,1,0,0,0,2,0V14.051a12.926,12.926,0,0,1,7.447,3.088l-1.376,1.376a1,1,0,1,0,1.414,1.414l1.376-1.376A12.919,12.919,0,0,1,36.949,26H35a1,1,0,0,0,0,2Z"></path><path d="M27.827,17.761a1,1,0,0,0-1.306.541l-2.367,5.714c-.052,0-.1-.016-.154-.016a3.03,3.03,0,1,0,2,.781l2.367-5.713A1,1,0,0,0,27.827,17.761ZM24,28a1,1,0,1,1,1-1A1,1,0,0,1,24,28Z"></path></g></svg></span>');
					
					if nvl(ws_obs, 'N/A') <> 'N/A' then
						htp.p('<span class="obs" data-obs="<h4>'||fun.lang('Observa&ccedil;&otilde;es do objeto')||'</h4><span>'||ws_obs||'</span>" onclick="objObs(this.getAttribute(''data-obs''));">');
							htp.p('<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" id="Camada_1" x="0px" y="0px" viewBox="0 0 1280 1280" style="fill: gray;" xml:space="preserve"><g><g><path  d="M590,249.13h100v446.71H590V249.13z M590,807.52h100v223.36H590V807.52z"/></g><path  d="M640,1256c-83.14,0-163.81-16.29-239.79-48.43c-73.36-31.03-139.23-75.44-195.79-131.99   c-56.56-56.56-100.97-122.43-131.99-195.79C40.29,803.82,24,723.14,24,640s16.29-163.81,48.43-239.79   c31.03-73.36,75.44-139.23,131.99-195.79S326.85,103.46,400.21,72.43C476.19,40.29,556.86,24,640,24s163.81,16.29,239.79,48.43   c73.36,31.03,139.23,75.44,195.79,131.99c56.56,56.55,100.97,122.43,131.99,195.79C1239.71,476.19,1256,556.86,1256,640   s-16.29,163.82-48.43,239.79c-31.03,73.36-75.44,139.23-131.99,195.79c-56.56,56.56-122.43,100.97-195.79,131.99   C803.81,1239.71,723.14,1256,640,1256z M640,123.47c-69.75,0-137.39,13.65-201.04,40.57c-61.5,26.01-116.75,63.26-164.2,110.72   c-47.45,47.45-84.7,102.7-110.72,164.2c-26.92,63.65-40.57,131.29-40.57,201.04s13.65,137.39,40.57,201.04   c26.01,61.5,63.26,116.75,110.72,164.2c47.45,47.45,102.7,84.7,164.2,110.72c63.65,26.92,131.29,40.57,201.04,40.57   s137.39-13.65,201.04-40.57c61.5-26.01,116.75-63.26,164.2-110.72c47.45-47.45,84.7-102.7,110.72-164.2   c26.92-63.65,40.57-131.29,40.57-201.04s-13.65-137.39-40.57-201.04c-26.01-61.5-63.26-116.75-110.72-164.2   c-47.45-47.45-102.7-84.7-164.2-110.72C777.39,137.12,709.75,123.47,640,123.47z"/></g></svg>');
						htp.p('</span>');
					end if;
					
					if ws_count_filtro > 3 then
						htp.p('<span class="filtros" style="color: gray;">F</span>');
					end if;

					if ws_count_destaque > 3 then
						htp.p('<span class="destaques">');
						htp.p('</span>');
					end if;
				htp.p('</span>'); 
			end if;

		when prm_tipo = 'PONTEIRO' then

		    if instr(prm_objeto, 'trl') = 0 and instr(prm_objeto, 'temp') = 0 then
			    htp.p('<span id="'||ws_obj_html||'sync" class="sync" title="'||ws_query_hint||'"><img src="'||nvl(fun.ret_var('OWNER_BI'),'DWU')||'.fcl.download?arquivo=sinchronize.png" /></span>');
			else
                htp.p('<a class="fechar" id="'||ws_obj_html||'fechar" title="'||fun.lang('Fechar')||'">');
					htp.p('<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="612px" height="612px" viewBox="0 0 612 612" style="enable-background:new 0 0 612 612;" xml:space="preserve"> <g> 	<g id="cross"> 		<g> 			<polygon points="612,36.004 576.521,0.603 306,270.608 35.478,0.603 0,36.004 270.522,306.011 0,575.997 35.478,611.397 				306,341.411 576.521,611.397 612,575.997 341.459,306.011 			"></polygon> 		</g> 	</g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
				htp.p('</a>');
				htp.p('<a class="fechar_app" id="'||ws_obj_html||'fechar_app"></a>');   -- Somente efeito visual, a acão continua no elemento 'fechar' 				
			end if;

			ws_itens := 0;

			if ws_admin = 'A' then
				htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options closed" id="'||ws_obj_html||'more" >');
					htp.p(fun.showtag(ws_obj_html, 'atrib', prm_screen));
					htp.p('<span class="preferencias" title="'||fun.lang('Propriedades')||'"></span>');
					htp.p(fun.showtag(ws_obj_html, 'filter', prm_visao));
					htp.p('<span class="lightbulb" title="'||fun.lang('Drills')||'"></span>');
					fcl.button_lixo('dl_obj', prm_objeto=> ws_objeto, prm_tag => 'span');
					htp.p(fun.showtag(prm_objeto, 'clone'));
				htp.p('</span>');
			else
				if nvl(fun.getprop(ws_objeto,'NO_OPTION'),'N') <> 'S' then
				   
				    if prm_drill = 'Y' or instr(prm_objeto, 'temp') > 0 then
					    htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options closed" id="'||ws_obj_html||'more">');
					else
					    htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options closed" id="'||ws_obj_html||'more">');
					end if;	
						
						if fun.check_admin('ATTRIB_ALT') THEN	
							htp.p(fun.showtag(ws_obj_html, 'atrib', prm_screen));
							ws_itens := ws_itens+1; 
						end if;

							
						if ws_filter then
							htp.p(fun.showtag(ws_obj_html, 'filter', prm_visao));
							ws_itens := ws_itens+1;
						end if;

						if ws_drill then
							htp.p('<span class="lightbulb" title="'||fun.lang('Drills')||'"></span>');
							ws_itens := ws_itens+1;
						end if;

						htp.p(fun.showtag(prm_objeto, 'export', 'png'));
						ws_itens := ws_itens+1;

					htp.p('</span>');
				end if;

				ws_itens := 34*ws_itens;
				htp.p('<style>div#'||ws_obj_html||' span.options { max-width: '||ws_itens||'px; max-height: 33px; }</style>');

				if prm_drill = 'Y' or instr(prm_objeto, 'temp') <> 0 then
					htp.p('<a class="fechar" id="'||ws_obj_html||'fechar" title="'||fun.lang('Fechar')||'"></a>');
					htp.p('<a class="fechar_app" id="'||ws_obj_html||'fechar_app"></a>');   -- Somente efeito visual, a acão continua no elemento 'fechar'
				end if;
			end if;

			if length(trim(fun.show_filtros(prm_par, '', '', ws_objeto, prm_visao, prm_screen))) > 3 or length(trim(fun.show_destaques(prm_par, '', '', ws_objeto, prm_visao, prm_screen))) > 3 or 
			   nvl(ws_obs, 'N/A') <> 'N/A' or ws_span_tempo is not null then
				htp.p('<span class="turn">');

				htp.p(ws_span_tempo);

					if nvl(ws_obs, 'N/A') <> 'N/A' then
						htp.p('<span class="obs" data-obs="<h4>'||fun.lang('Observa&ccedil;&otilde;es do objeto')||'</h4><span>'||ws_obs||'</span>" onclick="objObs(this.getAttribute(''data-obs''));">');
							htp.p('<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" id="Camada_1" x="0px" y="0px" viewBox="0 0 1280 1280" style="fill: gray;" xml:space="preserve"><g><g><path  d="M590,249.13h100v446.71H590V249.13z M590,807.52h100v223.36H590V807.52z"/></g><path  d="M640,1256c-83.14,0-163.81-16.29-239.79-48.43c-73.36-31.03-139.23-75.44-195.79-131.99   c-56.56-56.56-100.97-122.43-131.99-195.79C40.29,803.82,24,723.14,24,640s16.29-163.81,48.43-239.79   c31.03-73.36,75.44-139.23,131.99-195.79S326.85,103.46,400.21,72.43C476.19,40.29,556.86,24,640,24s163.81,16.29,239.79,48.43   c73.36,31.03,139.23,75.44,195.79,131.99c56.56,56.55,100.97,122.43,131.99,195.79C1239.71,476.19,1256,556.86,1256,640   s-16.29,163.82-48.43,239.79c-31.03,73.36-75.44,139.23-131.99,195.79c-56.56,56.56-122.43,100.97-195.79,131.99   C803.81,1239.71,723.14,1256,640,1256z M640,123.47c-69.75,0-137.39,13.65-201.04,40.57c-61.5,26.01-116.75,63.26-164.2,110.72   c-47.45,47.45-84.7,102.7-110.72,164.2c-26.92,63.65-40.57,131.29-40.57,201.04s13.65,137.39,40.57,201.04   c26.01,61.5,63.26,116.75,110.72,164.2c47.45,47.45,102.7,84.7,164.2,110.72c63.65,26.92,131.29,40.57,201.04,40.57   s137.39-13.65,201.04-40.57c61.5-26.01,116.75-63.26,164.2-110.72c47.45-47.45,84.7-102.7,110.72-164.2   c26.92-63.65,40.57-131.29,40.57-201.04s-13.65-137.39-40.57-201.04c-26.01-61.5-63.26-116.75-110.72-164.2   c-47.45-47.45-102.7-84.7-164.2-110.72C777.39,137.12,709.75,123.47,640,123.47z"/></g></svg>');
						htp.p('</span>');
					end if;
					
					if length(trim(fun.show_filtros(prm_par, '', '', ws_objeto, prm_visao, prm_screen))) > 3 then
						htp.p('<span class="filtros" style="color: gray;">F</span>');
					end if;

					if length(trim(fun.show_destaques(prm_par, '', '', ws_objeto, prm_visao, prm_screen))) > 3 then
						htp.p('<span class="destaques">');
							--htp.p('<svg style="height: calc(100% - 10px); width: calc(100% - 10px); margin: 5px; fill: #333; pointer-events: none;" enable-background="new -1.23 -8.789 141.732 141.732" height="141.732px" id="Livello_1" version="1.1" viewBox="-1.23 -8.789 141.732 141.732" width="141.732px" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><g id="Livello_100"><path d="M139.273,49.088c0-3.284-2.75-5.949-6.146-5.949c-0.219,0-0.434,0.012-0.646,0.031l-42.445-1.001l-14.5-37.854   C74.805,1.824,72.443,0,69.637,0c-2.809,0-5.168,1.824-5.902,4.315L49.232,42.169L6.789,43.17c-0.213-0.021-0.43-0.031-0.646-0.031   C2.75,43.136,0,45.802,0,49.088c0,2.1,1.121,3.938,2.812,4.997l33.807,23.9l-12.063,37.494c-0.438,0.813-0.688,1.741-0.688,2.723   c0,3.287,2.75,5.952,6.146,5.952c1.438,0,2.766-0.484,3.812-1.29l35.814-22.737l35.812,22.737c1.049,0.806,2.371,1.29,3.812,1.29   c3.393,0,6.143-2.665,6.143-5.952c0-0.979-0.25-1.906-0.688-2.723l-12.062-37.494l33.806-23.9   C138.15,53.024,139.273,51.185,139.273,49.088"/></g><g id="Livello_1_1_"/></svg>');
						htp.p('</span>');
					end if;

				htp.p('</span>');

			end if;


		when prm_tipo in ('LINHAS','BARRAS','PIZZA', 'COLUNAS', 'SANKEY', 'SCATTER','RADAR', 'CALENDARIO') then

		    if instr(prm_objeto, 'trl') = 0 and instr(prm_objeto, 'temp') = 0 then
			    htp.p('<span id="'||ws_obj_html||'sync" class="sync" title="'||ws_query_hint||'"><img src="'||nvl(fun.ret_var('OWNER_BI'),'DWU')||'.fcl.download?arquivo=sinchronize.png" /></span>');
			else
                htp.p('<a class="fechar" id="'||ws_obj_html||'fechar" title="'||fun.lang('Fechar')||'">');
					htp.p('<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="612px" height="612px" viewBox="0 0 612 612" style="enable-background:new 0 0 612 612;" xml:space="preserve"> <g> 	<g id="cross"> 		<g> 			<polygon points="612,36.004 576.521,0.603 306,270.608 35.478,0.603 0,36.004 270.522,306.011 0,575.997 35.478,611.397 				306,341.411 576.521,611.397 612,575.997 341.459,306.011 			"></polygon> 		</g> 	</g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
				htp.p('</a>');
				htp.p('<a class="fechar_app" id="'||ws_obj_html||'fechar_app"></a>');   -- Somente efeito visual, a acão continua no elemento 'fechar'
			end if;

			ws_itens := 0;
			
			if ws_admin = 'A' then

				htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options closed" id="'||ws_obj_html||'more">');
					htp.p(fun.showtag(ws_obj_html, 'atrib', prm_screen));
					htp.p('<span class="preferencias" title="'||fun.lang('Propriedades')||'"></span>');
					htp.p(fun.showtag(ws_obj_html, 'filter', prm_visao));
					htp.p('<span class="lightbulb" title="'||fun.lang('Drills')||'"></span>');
					if prm_tipo not in ('SANKEY', 'SCATTER','RADAR' ) then 
						htp.p(fun.showtag(ws_obj_html, 'star', 'png'));  -- Destaque 
					end if; 	
					htp.p(fun.showtag(ws_obj_html, 'export', 'png'));
					
					if instr(prm_objeto, 'trl') = 0 then
					    fcl.button_lixo('dl_obj', prm_objeto=> ws_objeto, prm_tag => 'span');
					end if;
					htp.p(fun.showtag(prm_objeto, 'clone'));
				htp.p('</span>');

			else

				if nvl(fun.getprop(ws_objeto,'NO_OPTION'),'N') <> 'S' then
				    
					if prm_drill = 'Y' or instr(prm_objeto, 'temp') > 0 then
					    htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options closed" id="'||ws_obj_html||'more">');
					else
					    htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options closed" id="'||ws_obj_html||'more">');
					end if;	
						
						if fun.check_admin('ATTRIB_ALT') THEN
							
							htp.p(fun.showtag(ws_obj_html, 'atrib', prm_screen));
							ws_itens := ws_itens+1; 
						end if;

						
						if ws_filter then
						    htp.p(fun.showtag(ws_obj_html, 'filter', prm_visao));
							ws_itens := ws_itens+1;
						end if;

						if ws_drill then
						    htp.p('<span class="lightbulb" title="'||fun.lang('Drills')||'"></span>');
							ws_itens := ws_itens+1;
						end if;

						htp.p(fun.showtag(ws_obj_html, 'export', 'png'));
						ws_itens := ws_itens+1;
					htp.p('</span>');

				end if;

				ws_itens := 34*ws_itens;
				htp.p('<style>div#'||ws_obj_html||' span.options { max-width: '||ws_itens||'px; max-height: 33px; }</style>');

				if prm_drill = 'Y' or instr(prm_objeto, 'temp') <> 0 then
					htp.p('<a class="fechar" id="'||ws_obj_html||'fechar" title="'||fun.lang('Fechar')||'"></a>');
					htp.p('<a class="fechar_app" id="'||ws_obj_html||'fechar_app"></a>');   -- Somente efeito visual, a acão continua no elemento 'fechar'
				end if;
			end if;

			if length(trim(fun.show_filtros(prm_par, '', '', ws_objeto, prm_visao, prm_screen))) > 3 or length(trim(fun.show_destaques(prm_par, '', '', ws_objeto, prm_visao, prm_screen))) > 3 or 
			   nvl(ws_obs, 'N/A') <> 'N/A' or ws_span_tempo is not null then
				htp.p('<span class="turn">');

				htp.p(ws_span_tempo);
				--htp.p('<span class="tempo" data-obs="<h4>&Uacute;ltima Atualiza&ccedil;&atilde;o</h4><span>'||WS_ULTIMA_ATUALIZACAO||'</span>" onclick="objObs(this.getAttribute(''data-obs''));"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" style="margin-top: 0px;><title>Stopwatch</title><g id=" _11_-_20"="" data-name="11 - 20"><g id="Stopwatch"><path d="M38.1,14.312l1.455-1.454.793.793a1,1,0,0,0,1.414-1.414l-3-3a1,1,0,1,0-1.414,1.414l.792.793L36.688,12.9A18.892,18.892,0,0,0,25,8.051V7h2a2,2,0,0,0,2-2V4a2,2,0,0,0-2-2H21a2,2,0,0,0-2,2V5a2,2,0,0,0,2,2h2V8.051A18.892,18.892,0,0,0,11.312,12.9L9.858,11.444l.792-.793A1,1,0,1,0,9.236,9.237l-3,3A1,1,0,1,0,7.65,13.651l.793-.793L9.9,14.312a19,19,0,1,0,28.2,0ZM21,4h6V5H21Zm3,40A17,17,0,1,1,41,27,17.019,17.019,0,0,1,24,44Z"></path><path d="M24,12A15,15,0,1,0,39,27,15.017,15.017,0,0,0,24,12ZM35,28h1.949a12.919,12.919,0,0,1-3.088,7.447l-1.376-1.376a1,1,0,1,0-1.414,1.414l1.376,1.376A12.926,12.926,0,0,1,25,39.949V38a1,1,0,0,0-2,0v1.949a12.926,12.926,0,0,1-7.447-3.088l1.376-1.376a1,1,0,1,0-1.414-1.414l-1.376,1.376A12.919,12.919,0,0,1,11.051,28H13a1,1,0,0,0,0-2H11.051a12.919,12.919,0,0,1,3.088-7.447l1.376,1.376a1,1,0,1,0,1.414-1.414l-1.376-1.376A12.926,12.926,0,0,1,23,14.051V16a1,1,0,0,0,2,0V14.051a12.926,12.926,0,0,1,7.447,3.088l-1.376,1.376a1,1,0,1,0,1.414,1.414l1.376-1.376A12.919,12.919,0,0,1,36.949,26H35a1,1,0,0,0,0,2Z"></path><path d="M27.827,17.761a1,1,0,0,0-1.306.541l-2.367,5.714c-.052,0-.1-.016-.154-.016a3.03,3.03,0,1,0,2,.781l2.367-5.713A1,1,0,0,0,27.827,17.761ZM24,28a1,1,0,1,1,1-1A1,1,0,0,1,24,28Z"></path></g></svg></span>');
				--htp.p('<span class="tempo" onclick="ajax(''list'',''atu_view'',''prm_screen=&prm_objeto='||prm_objeto||''', false,''attriblist'');if(!document.getElementById(''attriblist'').classList.contains(''open'')){document.getElementById(''attriblist'').classList.add(''open'');}else{document.getElementById(''attriblist'').classList.remove(''open'');}"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" style="margin-top: 0px;><title>Stopwatch</title><g id=" _11_-_20"="" data-name="11 - 20"><g id="Stopwatch"><path d="M38.1,14.312l1.455-1.454.793.793a1,1,0,0,0,1.414-1.414l-3-3a1,1,0,1,0-1.414,1.414l.792.793L36.688,12.9A18.892,18.892,0,0,0,25,8.051V7h2a2,2,0,0,0,2-2V4a2,2,0,0,0-2-2H21a2,2,0,0,0-2,2V5a2,2,0,0,0,2,2h2V8.051A18.892,18.892,0,0,0,11.312,12.9L9.858,11.444l.792-.793A1,1,0,1,0,9.236,9.237l-3,3A1,1,0,1,0,7.65,13.651l.793-.793L9.9,14.312a19,19,0,1,0,28.2,0ZM21,4h6V5H21Zm3,40A17,17,0,1,1,41,27,17.019,17.019,0,0,1,24,44Z"></path><path d="M24,12A15,15,0,1,0,39,27,15.017,15.017,0,0,0,24,12ZM35,28h1.949a12.919,12.919,0,0,1-3.088,7.447l-1.376-1.376a1,1,0,1,0-1.414,1.414l1.376,1.376A12.926,12.926,0,0,1,25,39.949V38a1,1,0,0,0-2,0v1.949a12.926,12.926,0,0,1-7.447-3.088l1.376-1.376a1,1,0,1,0-1.414-1.414l-1.376,1.376A12.919,12.919,0,0,1,11.051,28H13a1,1,0,0,0,0-2H11.051a12.919,12.919,0,0,1,3.088-7.447l1.376,1.376a1,1,0,1,0,1.414-1.414l-1.376-1.376A12.926,12.926,0,0,1,23,14.051V16a1,1,0,0,0,2,0V14.051a12.926,12.926,0,0,1,7.447,3.088l-1.376,1.376a1,1,0,1,0,1.414,1.414l1.376-1.376A12.919,12.919,0,0,1,36.949,26H35a1,1,0,0,0,0,2Z"></path><path d="M27.827,17.761a1,1,0,0,0-1.306.541l-2.367,5.714c-.052,0-.1-.016-.154-.016a3.03,3.03,0,1,0,2,.781l2.367-5.713A1,1,0,0,0,27.827,17.761ZM24,28a1,1,0,1,1,1-1A1,1,0,0,1,24,28Z"></path></g></svg></span>');


					if nvl(ws_obs, 'N/A') <> 'N/A' then
						htp.p('<span class="obs" data-obs="<h4>'||fun.lang('Observa&ccedil;&otilde;es do objeto')||'</h4><span>'||ws_obs||'</span>" onclick="objObs(this.getAttribute(''data-obs''));">');
							htp.p('<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" id="Camada_1" x="0px" y="0px" viewBox="0 0 1280 1280" style="fill: gray;" xml:space="preserve"><g><g><path  d="M590,249.13h100v446.71H590V249.13z M590,807.52h100v223.36H590V807.52z"/></g><path  d="M640,1256c-83.14,0-163.81-16.29-239.79-48.43c-73.36-31.03-139.23-75.44-195.79-131.99   c-56.56-56.56-100.97-122.43-131.99-195.79C40.29,803.82,24,723.14,24,640s16.29-163.81,48.43-239.79   c31.03-73.36,75.44-139.23,131.99-195.79S326.85,103.46,400.21,72.43C476.19,40.29,556.86,24,640,24s163.81,16.29,239.79,48.43   c73.36,31.03,139.23,75.44,195.79,131.99c56.56,56.55,100.97,122.43,131.99,195.79C1239.71,476.19,1256,556.86,1256,640   s-16.29,163.82-48.43,239.79c-31.03,73.36-75.44,139.23-131.99,195.79c-56.56,56.56-122.43,100.97-195.79,131.99   C803.81,1239.71,723.14,1256,640,1256z M640,123.47c-69.75,0-137.39,13.65-201.04,40.57c-61.5,26.01-116.75,63.26-164.2,110.72   c-47.45,47.45-84.7,102.7-110.72,164.2c-26.92,63.65-40.57,131.29-40.57,201.04s13.65,137.39,40.57,201.04   c26.01,61.5,63.26,116.75,110.72,164.2c47.45,47.45,102.7,84.7,164.2,110.72c63.65,26.92,131.29,40.57,201.04,40.57   s137.39-13.65,201.04-40.57c61.5-26.01,116.75-63.26,164.2-110.72c47.45-47.45,84.7-102.7,110.72-164.2   c26.92-63.65,40.57-131.29,40.57-201.04s-13.65-137.39-40.57-201.04c-26.01-61.5-63.26-116.75-110.72-164.2   c-47.45-47.45-102.7-84.7-164.2-110.72C777.39,137.12,709.75,123.47,640,123.47z"/></g></svg>');
						htp.p('</span>');
					end if;
					
					if length(trim(fun.show_filtros(prm_par, '', '', ws_objeto, prm_visao, prm_screen))) > 3 then
						htp.p('<span class="filtros" style="color: gray;">F</span>');
					end if;

					if length(trim(fun.show_destaques(prm_par, '', '', ws_objeto, prm_visao, prm_screen))) > 3 then
						htp.p('<span class="destaques">');
							--htp.p('<svg style="height: calc(100% - 10px); width: calc(100% - 10px); margin: 5px; fill: #333; pointer-events: none;" enable-background="new -1.23 -8.789 141.732 141.732" height="141.732px" id="Livello_1" version="1.1" viewBox="-1.23 -8.789 141.732 141.732" width="141.732px" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><g id="Livello_100"><path d="M139.273,49.088c0-3.284-2.75-5.949-6.146-5.949c-0.219,0-0.434,0.012-0.646,0.031l-42.445-1.001l-14.5-37.854   C74.805,1.824,72.443,0,69.637,0c-2.809,0-5.168,1.824-5.902,4.315L49.232,42.169L6.789,43.17c-0.213-0.021-0.43-0.031-0.646-0.031   C2.75,43.136,0,45.802,0,49.088c0,2.1,1.121,3.938,2.812,4.997l33.807,23.9l-12.063,37.494c-0.438,0.813-0.688,1.741-0.688,2.723   c0,3.287,2.75,5.952,6.146,5.952c1.438,0,2.766-0.484,3.812-1.29l35.814-22.737l35.812,22.737c1.049,0.806,2.371,1.29,3.812,1.29   c3.393,0,6.143-2.665,6.143-5.952c0-0.979-0.25-1.906-0.688-2.723l-12.062-37.494l33.806-23.9   C138.15,53.024,139.273,51.185,139.273,49.088"/></g><g id="Livello_1_1_"/></svg>');
						htp.p('</span>');
					end if;

				htp.p('</span>');
			end if;

		when prm_tipo = 'ICONE' then

		    
			if ws_admin = 'A' then
				htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options closed" id="'||trim(ws_obj_html)||'more">');
					htp.p(fun.showtag(ws_obj_html, 'atrib', prm_screen));
					htp.p('<span class="preferencias" title="'||fun.lang('Propriedades')||'"></span>');
					--htp.p('<span class="removeobj" title="'||fun.lang('Excluir')||'" ></span>');
					fcl.button_lixo('dl_obj', prm_objeto=> ws_objeto, prm_tag => 'span');
					htp.p(fun.showtag(prm_objeto, 'clone'));
				htp.p('</span>');
			end if;

		when prm_tipo = 'IMAGE' then

			htp.p('<span class="turn">');

				if nvl(ws_obs, 'N/A') <> 'N/A' then
						htp.p('<span class="obs" data-obs="<h4>'||fun.lang('Observa&ccedil;&otilde;es do objeto')||'</h4><span>'||ws_obs||'</span>" onclick="objObs(this.getAttribute(''data-obs''));">');
							htp.p('<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" id="Camada_1" x="0px" y="0px" viewBox="0 0 1280 1280" style="fill: gray;" xml:space="preserve"><g><g><path  d="M590,249.13h100v446.71H590V249.13z M590,807.52h100v223.36H590V807.52z"/></g><path  d="M640,1256c-83.14,0-163.81-16.29-239.79-48.43c-73.36-31.03-139.23-75.44-195.79-131.99   c-56.56-56.56-100.97-122.43-131.99-195.79C40.29,803.82,24,723.14,24,640s16.29-163.81,48.43-239.79   c31.03-73.36,75.44-139.23,131.99-195.79S326.85,103.46,400.21,72.43C476.19,40.29,556.86,24,640,24s163.81,16.29,239.79,48.43   c73.36,31.03,139.23,75.44,195.79,131.99c56.56,56.55,100.97,122.43,131.99,195.79C1239.71,476.19,1256,556.86,1256,640   s-16.29,163.82-48.43,239.79c-31.03,73.36-75.44,139.23-131.99,195.79c-56.56,56.56-122.43,100.97-195.79,131.99   C803.81,1239.71,723.14,1256,640,1256z M640,123.47c-69.75,0-137.39,13.65-201.04,40.57c-61.5,26.01-116.75,63.26-164.2,110.72   c-47.45,47.45-84.7,102.7-110.72,164.2c-26.92,63.65-40.57,131.29-40.57,201.04s13.65,137.39,40.57,201.04   c26.01,61.5,63.26,116.75,110.72,164.2c47.45,47.45,102.7,84.7,164.2,110.72c63.65,26.92,131.29,40.57,201.04,40.57   s137.39-13.65,201.04-40.57c61.5-26.01,116.75-63.26,164.2-110.72c47.45-47.45,84.7-102.7,110.72-164.2   c26.92-63.65,40.57-131.29,40.57-201.04s-13.65-137.39-40.57-201.04c-26.01-61.5-63.26-116.75-110.72-164.2   c-47.45-47.45-102.7-84.7-164.2-110.72C777.39,137.12,709.75,123.47,640,123.47z"/></g></svg>');
						htp.p('</span>');
				end if;
			htp.p('</span>');

				if ws_admin = 'A' then
					htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options bolota closed" id="'||ws_obj_html||'more">');
						htp.p(fun.showtag(ws_obj_html, 'atrib', prm_screen));
						htp.p('<span class="preferencias" title="'||fun.lang('Propriedades')||'"></span>');
						fcl.button_lixo('dl_obj', prm_objeto=> ws_objeto, prm_tag => 'span');
						htp.p(fun.showtag(prm_objeto, 'clone'));
					htp.p('</span>');
				end if;
			htp.p('</span>');

		when prm_tipo = 'RELATORIO' then
		
			htp.p('<span class="turn">');

				if nvl(ws_obs, 'N/A') <> 'N/A' then
					htp.p('<span class="obs" data-obs="<h4>'||fun.lang('Observa&ccedil;&otilde;es do objeto')||'</h4><span>'||ws_obs||'</span>" onclick="objObs(this.getAttribute(''data-obs''));">');
						htp.p('<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" id="Camada_1" x="0px" y="0px" viewBox="0 0 1280 1280" style="fill: gray;" xml:space="preserve"><g><g><path  d="M590,249.13h100v446.71H590V249.13z M590,807.52h100v223.36H590V807.52z"/></g><path  d="M640,1256c-83.14,0-163.81-16.29-239.79-48.43c-73.36-31.03-139.23-75.44-195.79-131.99   c-56.56-56.56-100.97-122.43-131.99-195.79C40.29,803.82,24,723.14,24,640s16.29-163.81,48.43-239.79   c31.03-73.36,75.44-139.23,131.99-195.79S326.85,103.46,400.21,72.43C476.19,40.29,556.86,24,640,24s163.81,16.29,239.79,48.43   c73.36,31.03,139.23,75.44,195.79,131.99c56.56,56.55,100.97,122.43,131.99,195.79C1239.71,476.19,1256,556.86,1256,640   s-16.29,163.82-48.43,239.79c-31.03,73.36-75.44,139.23-131.99,195.79c-56.56,56.56-122.43,100.97-195.79,131.99   C803.81,1239.71,723.14,1256,640,1256z M640,123.47c-69.75,0-137.39,13.65-201.04,40.57c-61.5,26.01-116.75,63.26-164.2,110.72   c-47.45,47.45-84.7,102.7-110.72,164.2c-26.92,63.65-40.57,131.29-40.57,201.04s13.65,137.39,40.57,201.04   c26.01,61.5,63.26,116.75,110.72,164.2c47.45,47.45,102.7,84.7,164.2,110.72c63.65,26.92,131.29,40.57,201.04,40.57   s137.39-13.65,201.04-40.57c61.5-26.01,116.75-63.26,164.2-110.72c47.45-47.45,84.7-102.7,110.72-164.2   c26.92-63.65,40.57-131.29,40.57-201.04s-13.65-137.39-40.57-201.04c-26.01-61.5-63.26-116.75-110.72-164.2   c-47.45-47.45-102.7-84.7-164.2-110.72C777.39,137.12,709.75,123.47,640,123.47z"/></g></svg>');
					htp.p('</span>');
				end if;
			htp.p('</span>');
				
				if ws_admin = 'A' then
					htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options bolota closed" id="'||ws_obj_html||'more">');
						htp.p('<span class="preferencias" title="'||fun.lang('Propriedades')||'"></span>');
						fcl.button_lixo('dl_obj', prm_objeto=> ws_objeto, prm_tag => 'span');
						htp.p(fun.showtag(prm_objeto, 'clone'));
					htp.p('</span>');
				end if;
			htp.p('</span>');

				if prm_drill = 'Y' or instr(ws_nome, 'temp') > 0 then
					htp.p('<a class="fechar" id="'||ws_obj_html||'fechar" title="'||fun.lang('Fechar')||'"></a>');
					htp.p('<a class="fechar_app" id="'||ws_obj_html||'fechar_app"></a>');   -- Somente efeito visual, a acão continua no elemento 'fechar'				
				end if;
				
		when prm_tipo = 'FILE' then
		    if ws_admin = 'A' then
				htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options closed" id="'||ws_obj_html||'more">');
					htp.p(fun.showtag(ws_obj_html, 'atrib', prm_screen));
					htp.p('<span class="preferencias" title="'||fun.lang('Propriedades')||'"></span>');
					fcl.button_lixo('dl_obj', prm_objeto=> ws_objeto, prm_tag => 'span');
					htp.p(fun.showtag(prm_objeto, 'clone'));
				htp.p('</span>');
			end if;
			
		when prm_tipo = 'TEXTO' then
		    if  ws_admin = 'A' then
				
				htp.p('<span id="'||ws_obj_html||'more" class="options closed">');
					htp.p(fun.showtag(ws_obj_html, 'atrib', prm_screen));
					htp.p('<span class="preferencias" title="'||fun.lang('Propriedades')||'"></span>');
					fcl.button_lixo('dl_obj', prm_objeto=> ws_objeto, prm_tag => 'span');
					htp.p(fun.showtag(prm_objeto, 'clone'));
				htp.p('</span>');

			 	htp.p('<span id="'||ws_obj_html||'sync" class="sync" style="top: -14px;"><img src="'||nvl(fun.ret_var('OWNER_BI'),'DWU')||'.fcl.download?arquivo=sinchronize.png" /></span>');

				htp.p('<span id="'||ws_obj_html||'_ds" class="wd_move" style="text-align: left; position: relative; margin: -12px 20px 0 0; letter-spacing: -2px; font-size: 12px;">');
					htp.p('<p title="'||fun.lang('Dois cliques para mover o objeto.')||'" style="position: relative; left: 30px;">===</p>');
				htp.p('</span>');

			end if;

		when prm_tipo = 'GENERICO' then

		    htp.p('<span id="'||ws_obj_html||'sync" class="sync"><img src="'||nvl(fun.ret_var('OWNER_BI'),'DWU')||'.fcl.download?arquivo=sinchronize.png" /></span>');

			if prm_screen = 'SCR_CUSTOMIZACAO' then 
				htp.p('<span id="'||ws_obj_html||'more" class="options closed" style="max-width: 70px;">');
					htp.p('<span class="preferencias" title="'||fun.lang('Propriedades')||'"></span>');
				htp.p('</span>');
			elsif  ws_admin = 'A' then
				htp.p('<span id="'||ws_obj_html||'more" class="options closed" style="max-width: 70px;">');
					htp.p('<span class="preferencias" title="'||fun.lang('Propriedades')||'"></span>');
					fcl.button_lixo('dl_obj', prm_objeto=> ws_objeto, prm_tag => 'span');
				htp.p('</span>');
			end if;
		
		when prm_tipo = 'MAPA' then

			if instr(prm_objeto, 'trl') = 0 and instr(ws_nome, 'temp') = 0 then
			    htp.p('<span id="'||ws_obj_html||'sync" class="sync" title="'||ws_query_hint||'"><img src="'||nvl(fun.ret_var('OWNER_BI'),'DWU')||'.fcl.download?arquivo=sinchronize.png" /></span>');
            else
                htp.p('<a class="fechar" id="'||ws_obj_html||'fechar" title="'||fun.lang('Fechar')||'">');
					htp.p('<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="612px" height="612px" viewBox="0 0 612 612" style="enable-background:new 0 0 612 612;" xml:space="preserve"> <g> 	<g id="cross"> 		<g> 			<polygon points="612,36.004 576.521,0.603 306,270.608 35.478,0.603 0,36.004 270.522,306.011 0,575.997 35.478,611.397 				306,341.411 576.521,611.397 612,575.997 341.459,306.011 			"></polygon> 		</g> 	</g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
				htp.p('</a>');
				htp.p('<a class="fechar_app" id="'||ws_obj_html||'fechar_app"></a>');   -- Somente efeito visual, a acão continua no elemento 'fechar'
			end if;

			ws_count_filtro   := length(trim(fun.show_filtros(prm_par, '', '', ws_objeto, prm_visao, prm_screen)));
			if ws_count_filtro > 3 or ws_span_tempo is not null or nvl(ws_obs, 'N/A') <> 'N/A' then
				htp.p('<span class="turn">');
					htp.p(ws_span_tempo);
					if nvl(ws_obs, 'N/A') <> 'N/A' then
						htp.p('<span class="obs" data-obs="<h4>'||fun.lang('Observa&ccedil;&otilde;es do objeto')||'</h4><span>'||ws_obs||'</span>" onclick="objObs(this.getAttribute(''data-obs''));">');
							htp.p('<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" id="Camada_1" x="0px" y="0px" viewBox="0 0 1280 1280" style="fill: gray;" xml:space="preserve"><g><g><path  d="M590,249.13h100v446.71H590V249.13z M590,807.52h100v223.36H590V807.52z"/></g><path  d="M640,1256c-83.14,0-163.81-16.29-239.79-48.43c-73.36-31.03-139.23-75.44-195.79-131.99   c-56.56-56.56-100.97-122.43-131.99-195.79C40.29,803.82,24,723.14,24,640s16.29-163.81,48.43-239.79   c31.03-73.36,75.44-139.23,131.99-195.79S326.85,103.46,400.21,72.43C476.19,40.29,556.86,24,640,24s163.81,16.29,239.79,48.43   c73.36,31.03,139.23,75.44,195.79,131.99c56.56,56.55,100.97,122.43,131.99,195.79C1239.71,476.19,1256,556.86,1256,640   s-16.29,163.82-48.43,239.79c-31.03,73.36-75.44,139.23-131.99,195.79c-56.56,56.56-122.43,100.97-195.79,131.99   C803.81,1239.71,723.14,1256,640,1256z M640,123.47c-69.75,0-137.39,13.65-201.04,40.57c-61.5,26.01-116.75,63.26-164.2,110.72   c-47.45,47.45-84.7,102.7-110.72,164.2c-26.92,63.65-40.57,131.29-40.57,201.04s13.65,137.39,40.57,201.04   c26.01,61.5,63.26,116.75,110.72,164.2c47.45,47.45,102.7,84.7,164.2,110.72c63.65,26.92,131.29,40.57,201.04,40.57   s137.39-13.65,201.04-40.57c61.5-26.01,116.75-63.26,164.2-110.72c47.45-47.45,84.7-102.7,110.72-164.2   c26.92-63.65,40.57-131.29,40.57-201.04s-13.65-137.39-40.57-201.04c-26.01-61.5-63.26-116.75-110.72-164.2   c-47.45-47.45-102.7-84.7-164.2-110.72C777.39,137.12,709.75,123.47,640,123.47z"/></g></svg>');
						htp.p('</span>');
					end if;
					if ws_count_filtro > 3 then 
						htp.p('<span class="filtros" style="color: gray;">F</span>');
					end if;	
				htp.p('</span>');
			end if;
			
		    if ws_admin = 'A' then
				
				htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options closed" style="max-width: 142px;" id="'||ws_obj_html||'more">');
					htp.p(fun.showtag(ws_obj_html, 'atrib', prm_screen));
					htp.p('<span class="preferencias" title="'||fun.lang('Propriedades')||'"></span>');
					htp.p(fun.showtag(ws_obj_html, 'filter', prm_visao));
					htp.p('<span class="lightbulb" title="'||fun.lang('Drills')||'"></span>');
					htp.p(fun.showtag(ws_obj_html, 'export', 'png'));
					if instr(prm_objeto, 'trl') = 0 then
					    fcl.button_lixo('dl_obj', prm_objeto=> ws_objeto, prm_tag => 'span');
					end if;
					htp.p(fun.showtag(prm_objeto, 'clone'));
				htp.p('</span>');
			else

				if nvl(fun.getprop(ws_objeto,'NO_OPTION'),'N') <> 'S' then
					htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options closed" style="max-height: 33px;" id="'||ws_obj_html||'more">');
						
						if fun.check_admin('ATTRIB_ALT') THEN
							htp.p(fun.showtag(ws_obj_html, 'atrib', prm_screen));
						end if;

						if ws_filter then
						    htp.p(fun.showtag(ws_obj_html, 'filter', prm_visao));
						end if;

						if ws_drill then
						    htp.p('<span class="lightbulb" title="'||fun.lang('Drills')||'"></span>');
						end if;

						htp.p(fun.showtag(ws_obj_html, 'export', 'png'));

					htp.p('</span>');
				end if;

				if prm_drill = 'Y' or instr(ws_nome, 'temp') > 0 then
					htp.p('<a class="fechar" id="'||ws_obj_html||'fechar" title="'||fun.lang('Fechar')||'"></a>');
					htp.p('<a class="fechar_app" id="'||ws_obj_html||'fechar_app"></a>');   -- Somente efeito visual, a acão continua no elemento 'fechar'
				end if;

			end if;
			
		when prm_tipo = 'HEATMAP' then

		    if ws_admin = 'A' then
				
				htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="closed" style="max-width: 104px;" id="'||ws_obj_html||'more">');	
				htp.p(fun.showtag(ws_obj_html, 'atrib', prm_screen));
				htp.p(fun.showtag(ws_obj_html, 'filter', prm_visao));
				htp.p(fun.showtag(ws_obj_html, 'clone'));

			else
			    
				htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="closed" style="max-width: 50px;" id="'||ws_obj_html||'more">');

			end if;
			
			htp.p('<span id="'||ws_obj_html||'_center" title="'||fun.lang('Centralizar')||'" class="center" onclick="var centro = document.getElementById('''||ws_obj_html||''').getAttribute(''data-center''); call(''alter_attrib'', ''prm_objeto='||ws_objeto||'&prm_prop=CENTER&prm_value=''+centro+''&prm_usuario='||ws_usuario||''').then(function(resposta){ if(resposta.indexOf(''error'') != -1 || resposta.indexOf(''FAIL'') != -1){ alerta(''feed-fixo'', TR_ER); } else { alerta(''feed-fixo'', '''||fun.lang('Centralizado no ponto atual')||'''); } });"><svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" 	 width="79.536px" height="79.536px" viewBox="0 0 79.536 79.536" style="enable-background:new 0 0 79.536 79.536;" 	 xml:space="preserve"> <g> 	<path style="fill:#010002;" d="M48.416,39.763c0,4.784-3.863,8.647-8.627,8.647c-4.782,0-8.647-3.863-8.647-8.647 		c0-4.771,3.865-8.627,8.647-8.627C44.553,31.136,48.416,34.992,48.416,39.763z M43.496,79.531V66.088l3.998-0.01l-7.716-13.35 		l-7.72,13.359h3.992v13.442H43.496z M0,43.481h13.463v4.008l13.362-7.715l-13.367-7.726l0.005,3.998H0.005L0,43.481z 		 M79.536,36.045H66.089v-3.987l-13.365,7.715l13.365,7.706v-3.988l13.447-0.01V36.045z M36.056,0.005v13.442l-3.998,0.011 		l7.72,13.362l7.716-13.362h-3.998V0.005H36.056z"/> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg></span>');
			htp.p('<span style="border-radius: 10px;" id="'||ws_obj_html||'_zoom" title="'||fun.lang('Zoom')||'" class="zoom" onclick="var zoom = document.getElementById('''||ws_obj_html||''').getAttribute(''data-zoom''); call(''alter_attrib'', ''prm_objeto='||ws_objeto||'&prm_prop=ZOOM&prm_value=''+zoom+''&prm_usuario='||ws_usuario||''').then(function(resposta){ if(resposta.indexOf(''error'') != -1 || resposta.indexOf(''FAIL'') != -1){ alerta(''feed-fixo'', TR_ER); } else { alerta(''feed-fixo'', '''||fun.lang('Zoom fixado para o valor atual')||'''); } });"><svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" 	 viewBox="0 0 206.166 206.166" style="enable-background:new 0 0 206.166 206.166;" xml:space="preserve"> <g> 	<g> 		<g> 			<path d="M176.009,30.157c-40.209-40.209-105.643-40.209-145.852,0c-40.209,40.211-40.209,105.639,0,145.852 				c20.105,20.105,46.516,30.157,72.926,30.157s52.822-10.052,72.926-30.157C216.218,135.797,216.218,70.368,176.009,30.157z 				 M35.766,35.766C54.324,17.207,78.706,7.93,103.083,7.93c23.145,0,46.291,8.363,64.454,25.09L33.019,167.537 				C-1.325,130.238-0.411,71.944,35.766,35.766z M170.4,170.4c-36.18,36.176-94.48,37.091-131.771,2.747L173.146,38.629 				C207.49,75.927,206.576,134.22,170.4,170.4z"/> 			<path d="M91.384,59.732H75.316V43.583c0-2.19-1.774-3.967-3.967-3.967s-3.967,1.776-3.967,3.967v16.149H51.718 				c-2.192,0-3.967,1.776-3.967,3.967c0,2.191,1.774,3.967,3.966,3.967h15.665V83.25c0,2.19,1.774,3.967,3.967,3.967 				s3.967-1.776,3.967-3.967V67.666h16.068c2.192,0,3.967-1.776,3.967-3.967C95.351,61.509,93.577,59.732,91.384,59.732z"/> 			<path d="M154.649,134.816h-39.667c-2.192,0-3.967,1.774-3.967,3.967s1.774,3.967,3.967,3.967h39.667 				c2.192,0,3.967-1.774,3.967-3.967S156.842,134.816,154.649,134.816z"/> 		</g> 	</g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg></span>');
				
			htp.p('</span>');
			htp.p('<a class="fechar" id="'||ws_obj_html||'fechar" title="'||fun.lang('Fechar')||'">X</a>');
			
			htp.p('<span class="turn">');

				htp.p(ws_span_tempo);
				--htp.p('<span class="tempo" data-obs="<h4>&Uacute;ltima Atualiza&ccedil;&atilde;o</h4><span>'||WS_ULTIMA_ATUALIZACAO||'</span>" onclick="objObs(this.getAttribute(''data-obs''));"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" style="margin-top: 0px;><title>Stopwatch</title><g id=" _11_-_20"="" data-name="11 - 20"><g id="Stopwatch"><path d="M38.1,14.312l1.455-1.454.793.793a1,1,0,0,0,1.414-1.414l-3-3a1,1,0,1,0-1.414,1.414l.792.793L36.688,12.9A18.892,18.892,0,0,0,25,8.051V7h2a2,2,0,0,0,2-2V4a2,2,0,0,0-2-2H21a2,2,0,0,0-2,2V5a2,2,0,0,0,2,2h2V8.051A18.892,18.892,0,0,0,11.312,12.9L9.858,11.444l.792-.793A1,1,0,1,0,9.236,9.237l-3,3A1,1,0,1,0,7.65,13.651l.793-.793L9.9,14.312a19,19,0,1,0,28.2,0ZM21,4h6V5H21Zm3,40A17,17,0,1,1,41,27,17.019,17.019,0,0,1,24,44Z"></path><path d="M24,12A15,15,0,1,0,39,27,15.017,15.017,0,0,0,24,12ZM35,28h1.949a12.919,12.919,0,0,1-3.088,7.447l-1.376-1.376a1,1,0,1,0-1.414,1.414l1.376,1.376A12.926,12.926,0,0,1,25,39.949V38a1,1,0,0,0-2,0v1.949a12.926,12.926,0,0,1-7.447-3.088l1.376-1.376a1,1,0,1,0-1.414-1.414l-1.376,1.376A12.919,12.919,0,0,1,11.051,28H13a1,1,0,0,0,0-2H11.051a12.919,12.919,0,0,1,3.088-7.447l1.376,1.376a1,1,0,1,0,1.414-1.414l-1.376-1.376A12.926,12.926,0,0,1,23,14.051V16a1,1,0,0,0,2,0V14.051a12.926,12.926,0,0,1,7.447,3.088l-1.376,1.376a1,1,0,1,0,1.414,1.414l1.376-1.376A12.919,12.919,0,0,1,36.949,26H35a1,1,0,0,0,0,2Z"></path><path d="M27.827,17.761a1,1,0,0,0-1.306.541l-2.367,5.714c-.052,0-.1-.016-.154-.016a3.03,3.03,0,1,0,2,.781l2.367-5.713A1,1,0,0,0,27.827,17.761ZM24,28a1,1,0,1,1,1-1A1,1,0,0,1,24,28Z"></path></g></svg></span>');

				--htp.p('<span class="tempo" onclick="ajax(''list'',''atu_view'',''prm_screen=&prm_objeto='||prm_objeto||''', false,''attriblist'');if(!document.getElementById(''attriblist'').classList.contains(''open'')){document.getElementById(''attriblist'').classList.add(''open'');}else{document.getElementById(''attriblist'').classList.remove(''open'');}"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" style="margin-top: 0px;><title>Stopwatch</title><g id=" _11_-_20"="" data-name="11 - 20"><g id="Stopwatch"><path d="M38.1,14.312l1.455-1.454.793.793a1,1,0,0,0,1.414-1.414l-3-3a1,1,0,1,0-1.414,1.414l.792.793L36.688,12.9A18.892,18.892,0,0,0,25,8.051V7h2a2,2,0,0,0,2-2V4a2,2,0,0,0-2-2H21a2,2,0,0,0-2,2V5a2,2,0,0,0,2,2h2V8.051A18.892,18.892,0,0,0,11.312,12.9L9.858,11.444l.792-.793A1,1,0,1,0,9.236,9.237l-3,3A1,1,0,1,0,7.65,13.651l.793-.793L9.9,14.312a19,19,0,1,0,28.2,0ZM21,4h6V5H21Zm3,40A17,17,0,1,1,41,27,17.019,17.019,0,0,1,24,44Z"></path><path d="M24,12A15,15,0,1,0,39,27,15.017,15.017,0,0,0,24,12ZM35,28h1.949a12.919,12.919,0,0,1-3.088,7.447l-1.376-1.376a1,1,0,1,0-1.414,1.414l1.376,1.376A12.926,12.926,0,0,1,25,39.949V38a1,1,0,0,0-2,0v1.949a12.926,12.926,0,0,1-7.447-3.088l1.376-1.376a1,1,0,1,0-1.414-1.414l-1.376,1.376A12.919,12.919,0,0,1,11.051,28H13a1,1,0,0,0,0-2H11.051a12.919,12.919,0,0,1,3.088-7.447l1.376,1.376a1,1,0,1,0,1.414-1.414l-1.376-1.376A12.926,12.926,0,0,1,23,14.051V16a1,1,0,0,0,2,0V14.051a12.926,12.926,0,0,1,7.447,3.088l-1.376,1.376a1,1,0,1,0,1.414,1.414l1.376-1.376A12.919,12.919,0,0,1,36.949,26H35a1,1,0,0,0,0,2Z"></path><path d="M27.827,17.761a1,1,0,0,0-1.306.541l-2.367,5.714c-.052,0-.1-.016-.154-.016a3.03,3.03,0,1,0,2,.781l2.367-5.713A1,1,0,0,0,27.827,17.761ZM24,28a1,1,0,1,1,1-1A1,1,0,0,1,24,28Z"></path></g></svg></span>');


				if length(trim(fun.show_filtros(prm_par, '', '', ws_objeto, prm_visao, prm_screen))) > 3 then
					htp.p('<span class="filtros" style="color: gray;">F</span>');
				end if;

			htp.p('</span>');

		when prm_tipo = 'MAPAGEOLOC' then

			if prm_drill = 'Y' then
                htp.p('<a class="fechar" id="'||ws_obj_html||'fechar" title="'||fun.lang('Fechar')||'"></a>');
				htp.p('<a class="fechar_app" id="'||ws_obj_html||'fechar_app"></a>');   -- Somente efeito visual, a acão continua no elemento 'fechar'
            else
				htp.p('<span id="'||ws_obj_html||'sync" class="sync" title="'||ws_query_hint||'"><img src="'||nvl(fun.ret_var('OWNER_BI'),'DWU')||'.fcl.download?arquivo=sinchronize.png" /></span>');
			end if;
			
			ws_count_filtro   := length(trim(fun.show_filtros(prm_par, '', '', ws_objeto, prm_visao, prm_screen)));

			htp.p('<span class="turn">');
				htp.p(ws_span_tempo);
				if nvl(ws_obs, 'N/A') <> 'N/A' then
					htp.p('<span class="obs" data-obs="<h4>'||fun.lang('Observa&ccedil;&otilde;es do objeto')||'</h4><span>'||ws_obs||'</span>" onclick="objObs(this.getAttribute(''data-obs''));">');
						htp.p('<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" id="Camada_1" x="0px" y="0px" viewBox="0 0 1280 1280" style="fill: gray;" xml:space="preserve"><g><g><path  d="M590,249.13h100v446.71H590V249.13z M590,807.52h100v223.36H590V807.52z"/></g><path  d="M640,1256c-83.14,0-163.81-16.29-239.79-48.43c-73.36-31.03-139.23-75.44-195.79-131.99   c-56.56-56.56-100.97-122.43-131.99-195.79C40.29,803.82,24,723.14,24,640s16.29-163.81,48.43-239.79   c31.03-73.36,75.44-139.23,131.99-195.79S326.85,103.46,400.21,72.43C476.19,40.29,556.86,24,640,24s163.81,16.29,239.79,48.43   c73.36,31.03,139.23,75.44,195.79,131.99c56.56,56.55,100.97,122.43,131.99,195.79C1239.71,476.19,1256,556.86,1256,640   s-16.29,163.82-48.43,239.79c-31.03,73.36-75.44,139.23-131.99,195.79c-56.56,56.56-122.43,100.97-195.79,131.99   C803.81,1239.71,723.14,1256,640,1256z M640,123.47c-69.75,0-137.39,13.65-201.04,40.57c-61.5,26.01-116.75,63.26-164.2,110.72   c-47.45,47.45-84.7,102.7-110.72,164.2c-26.92,63.65-40.57,131.29-40.57,201.04s13.65,137.39,40.57,201.04   c26.01,61.5,63.26,116.75,110.72,164.2c47.45,47.45,102.7,84.7,164.2,110.72c63.65,26.92,131.29,40.57,201.04,40.57   s137.39-13.65,201.04-40.57c61.5-26.01,116.75-63.26,164.2-110.72c47.45-47.45,84.7-102.7,110.72-164.2   c26.92-63.65,40.57-131.29,40.57-201.04s-13.65-137.39-40.57-201.04c-26.01-61.5-63.26-116.75-110.72-164.2   c-47.45-47.45-102.7-84.7-164.2-110.72C777.39,137.12,709.75,123.47,640,123.47z"/></g></svg>');
					htp.p('</span>');
				end if;
				if ws_count_filtro > 3 then 
					htp.p('<span class="filtros" style="color: gray;">F</span>');
				end if; 	
			htp.p('</span>');
			
		    if ws_admin = 'A' then
				
				htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options closed" style="max-width: 142px;" id="'||ws_obj_html||'more">');
					htp.p(fun.showtag(ws_obj_html, 'atrib', prm_screen));
					htp.p('<span class="preferencias" title="'||fun.lang('Propriedades')||'"></span>');
					htp.p(fun.showtag(ws_obj_html, 'filter', prm_visao));
					htp.p('<span class="lightbulb" title="'||fun.lang('Drills')||'"></span>');
					-- htp.p(fun.showtag(prm_objeto, 'export', 'png'));
					if prm_drill <> 'Y' then
					    fcl.button_lixo('dl_obj', prm_objeto=> ws_objeto, prm_tag => 'span');
					end if;
					htp.p(fun.showtag(prm_objeto, 'clone'));
				htp.p('</span>');
			else
				if nvl(fun.getprop(ws_objeto,'NO_OPTION'),'N') <> 'S' then
					
					htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options closed" style="max-height: 33px;" id="'||ws_obj_html||'more">');
						if fun.check_admin('ATTRIB_ALT') THEN
							htp.p(fun.showtag(ws_obj_html, 'atrib', prm_screen));
						end if;
						
						if ws_drill then
						    htp.p('<span class="lightbulb" title="'||fun.lang('Drills')||'"></span>');
						end if;

						if ws_filter then
						    htp.p(fun.showtag(ws_obj_html, 'filter', prm_visao));
						end if;

					htp.p('</span>');

				end if;

				if prm_drill = 'Y' then
					htp.p('<a class="fechar" id="'||ws_obj_html||'fechar" title="'||fun.lang('Fechar')||'"></a>');
					htp.p('<a class="fechar_app" id="'||ws_obj_html||'fechar_app"></a>');   -- Somente efeito visual, a acão continua no elemento 'fechar'
				end if;

			end if;
		else
		    htp.p('<a class="fechar" id="'||ws_obj_html||'fechar" title="'||fun.lang('Fechar')||'">X</a>');
	end case;

end opcoes;

procedure consultaInvertida (
			prm_parametros	 char default '1|1',
			prm_micro_visao  char default null,
			prm_coluna	     char default null,
			prm_agrupador	 char default null,
			prm_rp		     char default 'ROLL',
			prm_colup	     char default null,
			prm_comando	     char default 'MOUNT',
			prm_mode	     char default 'NO',
			prm_objid	     char default null,
			prm_screen	     char default 'DEFAULT',
			prm_posx	     char default null,
			prm_posy	     char default null,
			prm_ccount	     char default '0',
			prm_drill	     char default 'N',
			prm_ordem	     char default '0',
			prm_zindex	     char default 'auto',
            prm_track        varchar2 default null,
            prm_objeton      varchar2 default null,
			prm_dashboard    varchar2 default 'false',
			prm_usuario      varchar2 default null,
			prm_cd_goto     varchar2 default null ) as

	ws_objeto           varchar2(200);
	ws_obj_html         varchar2(200);

	cursor crs_micro_visao is
			select	rtrim(cd_grupo_funcao) as cd_grupo_funcao
			from 	MICRO_VISAO where nm_micro_visao = prm_micro_visao;

	ws_micro_visao crs_micro_visao%rowtype;

	cursor crs_xgoto(prm_usuario varchar2) is
			select	rtrim(cd_objeto_go) as cd_objeto_go
			from 	GOTO_OBJETO where cd_objeto = ws_objeto and
			        cd_objeto_go not in ( select cd_objeto from OBJECT_RESTRICTION where USUARIO = prm_usuario )
			order by cd_objeto_go;

	ws_xgoto crs_xgoto%rowtype;

	type ws_tmcolunas is table of MICRO_COLUNA%ROWTYPE
			    		index by pls_integer;

	type generic_cursor is ref cursor;

	crs_saida generic_cursor;

	cursor nc_colunas is select * from MICRO_COLUNA where cd_micro_visao = prm_micro_visao;

	ret_coluna			varchar2(2000);
	ret_mcol			ws_tmcolunas;

	ws_ncolumns			DBMS_SQL.VARCHAR2_TABLE;
	ws_coluna_ant		DBMS_SQL.VARCHAR2_TABLE;
	ws_pvcolumns		DBMS_SQL.VARCHAR2_TABLE;
	ws_mfiltro			DBMS_SQL.VARCHAR2_TABLE;
	ws_vcol				DBMS_SQL.VARCHAR2_TABLE;
	ws_vcon				DBMS_SQL.VARCHAR2_TABLE;

	ws_drill			varchar2(40);
	ws_zebrado			varchar2(20);
	ws_zebrado_d		varchar2(40);
	ws_queryoc			clob;
	ws_pipe				char(1);

	ws_posx				varchar(5);
	ws_posy				varchar(5);

	ret_colup			long;
	ws_lquery			number;
	ws_counterid		number := 0;
	ws_counter			number := 1;
	ws_ccoluna			number := 1;
	ws_xcoluna			number := 0;
	ws_chcor			number := 0;
	ws_bindn			number := 0;
	ws_scol				number := 0;
	ws_cspan			number := 0;
	ws_xcount			number := 0;
	ws_ctnull			number := 0;
	ws_ctcol			number := 0;

	ws_texto			long;
	ws_textot			long;
	ws_nm_var			long;
	ws_content_ant		long;
	ws_content			long;
	ws_colup			long;
	ws_coluna			long;
	ws_agrupador		long;
	ws_rp				long;
	ws_xatalho			long;
	ws_atalho			long;
	ws_parametros		long;
	ws_ordem			varchar2(400);
	ws_ordem_query		varchar2(400);
	ws_countor          number;

	ws_acesso			exception;
	ws_semquery			exception;
	ws_sempermissao		exception;
	ws_pcursor			integer;
	ws_cursor			integer;
	ws_linhas			integer;
	ws_query_montada	dbms_sql.varchar2a;
	ws_query_count      dbms_sql.varchar2a;
	ws_query_pivot		long;
	ws_sql				long;
	ws_sql_pivot		long;
	--ws_script			long;
	--ws_locais			long;
	ws_titulo			varchar2(150);
	--ws_temptxt			varchar2(3000);
	ws_mode				varchar2(30);
	ws_idcol			varchar2(120);
	ws_cleardrill		varchar2(120);
	ws_firstid			char(1);

	ws_vazio			boolean := True;
	ws_nodata       	exception;
	ws_invalido			exception;
	--ws_ponto_avalicao	exception;
	ws_close_html		exception;
	ws_mount			exception;
	ws_parseerr			exception;
	ws_agrupador_max number;

	ws_posicao			varchar2(2000) := ' ';
	ws_drill_atalho		varchar2(3000);
	ws_ctemp			varchar2(40);
	ws_tmp_jump			varchar2(300);
	ws_jump				varchar2(600);
	ws_posix			varchar2(80);
	ws_posiy			varchar2(80);
	ws_sem				varchar2(40);
	ws_title 			clob;
	ws_gotocounter		number;
	--ws_timer            number;
	ws_step             number;
	ws_stepper          number := 0;
	ws_largura          varchar2(60);
	--ws_larguran         number;
	--ws_talk             varchar2(40) := 'talk';
	ws_linha            number := 0;
	ws_fixed            varchar2(40);
	ws_ct_top           number := 0;
	ws_top              number := 0;
	ws_tmp_check        varchar2(300);
	ws_check            varchar2(300);
	ws_row              number;
	ws_pivot            varchar2(300);
	ws_distinctmed      number := 0;
	ws_cab_cross        varchar2(4000);
	ws_refcol           varchar2(4000);
	ws_limite_col       number;
	ws_linha_calc       number;
	ws_temp_valor number := 0;
    ws_total_linha number := 0;
	ws_acumulada_linha number := 0;
	ret_colgrp          varchar2(2000);
	ws_linha_acumulada varchar2(10);
	ws_total_acumulado varchar2(10);
	ws_limite_i varchar2(10);
	ws_limite_f varchar2(10);
	--ws_omitir char(1);
	ws_propagation varchar2(30);
	ws_order         varchar2(60);
	ws_blink_linha      varchar2(4000) := 'N/A';
    ws_tpt              varchar2(400);
	ws_count            number;
	ws_borda            varchar2(60);
    ws_null             varchar2(1) := null;
    ws_nome             varchar2(400);
	ws_html             varchar2(4000);
	ws_classe           varchar2(400);
	ws_ligacao          varchar2(200);
	ws_usuario          varchar2(80);
	ws_admin            varchar2(4);
	ws_excesso_filtro   exception;
begin

    ws_usuario := prm_usuario;
    if ws_usuario is null then    
        ws_usuario := gbl.getUsuario;
    end if;

	if  prm_drill = 'Y' then
		ws_objeto   := fun.get_cd_obj(prm_objid);
		ws_obj_html := ws_objeto||'trl'||prm_cd_goto;
	else
		ws_objeto   := prm_objid;
		ws_obj_html := prm_objid;
	end if;

	ws_admin   := nvl(gbl.getNivel,'N');

    if prm_dashboard <> 'false' then
	    ws_propagation := 'event.stopPropagation();';
	else
	    ws_propagation := '';
	end if;

	if(instr(prm_posx, '-') = 1) then
		ws_posix := '5px';
	else
		ws_posix := prm_posx;
	end if;

	if(instr(prm_posy, '-') = 1) then
		ws_posiy := '65px';
	else
		ws_posiy := prm_posy;
	end if;

	

	if prm_dashboard <> 'false' then
	    ws_order := 'order: '||ws_posix||';';
	else
		ws_order := 'left: '||ws_posix||';';
	end if;

	if  nvl(prm_posx,'NOLOC') <> 'NOLOC' then
	    ws_posicao := ' position: absolute; top:'||ws_posiy||'; '||ws_order||' ';
	else
	    if(prm_drill = 'O') then
		    ws_posicao := ' position: absolute; top: 8px; left: 8px; ';
		else
	        ws_posicao := ' position: absolute; top: 110px; left: 7px; ';
		end if;
	end if;

	ws_colup     := prm_colup;
	ws_coluna    := prm_coluna;
	ws_agrupador := fun.conv_template(prm_micro_visao, prm_agrupador);
	ws_mode      := prm_mode;
	ws_rp	     := prm_rp;
	ws_mode	     := 'ED';

	open crs_micro_visao;
	fetch crs_micro_visao into ws_micro_visao;
	close crs_micro_visao;

	ws_texto := prm_parametros;

    ws_parametros := prm_parametros;

	open nc_colunas;
	loop
	    fetch nc_colunas bulk collect into ret_mcol limit 2000;
	    exit when nc_colunas%NOTFOUND;
	end loop;
	close nc_colunas;

	ws_counter := 0;
	loop
	    ws_counter := ws_counter + 1;
	    if  ws_counter > ret_mcol.COUNT then
	    	exit;
	    end if;
	    if rtrim(ret_mcol(ws_counter).st_agrupador) <> 'SEM' and fun.setem(ws_agrupador,rtrim(ret_mcol(ws_counter).cd_coluna)) then
		ws_scol := ws_scol + 1;
	    end if;
	end loop;

	if nvl(prm_objid,'%$%') <> '%$%' and prm_objid <> 'newquery' then
	   ws_rp := fun.getprop(ws_objeto,'TP_GRUPO');
	end if;

	ws_sem := 1;

	if substr(ws_parametros,length(ws_parametros),1)='|' then
       ws_parametros := substr(ws_parametros,1,length(ws_parametros)-1);
    end if;

	ws_ordem := '';
	ws_ordem_query := '';
	ws_countor := 0;
	select count(*) into ws_countor from object_attrib where cd_object = ws_objeto and CD_PROP = 'ORDEM' and owner = ws_usuario;
	if ws_countor = 1 then
	    select upper(propriedade) into ws_ordem_query from object_attrib where cd_object = ws_objeto and CD_PROP = 'ORDEM' and owner = ws_usuario;
	    ws_ordem := ws_ordem_query;
	else
	    select count(*) into ws_countor from object_attrib where cd_object = ws_objeto and CD_PROP = 'ORDEM' and owner = 'DWU';
	    if ws_countor = 1 then
	        select upper(propriedade) into ws_ordem_query from object_attrib where cd_object = ws_objeto and CD_PROP = 'ORDEM' and owner = 'DWU';
	    end if;
	end if;

	ws_sql := core.MONTA_QUERY_DIRECT(prm_micro_visao, ws_coluna, ws_parametros, ws_rp, ws_colup, ws_query_pivot, ws_query_montada, ws_lquery, ws_ncolumns, ws_pvcolumns, ws_agrupador, ws_mfiltro, ws_objeto, ws_ordem_query, prm_screen => prm_screen, prm_cross => 'S', prm_cab_cross => ws_cab_cross,prm_usuario => ws_usuario);

    insert into log_eventos values(sysdate, prm_micro_visao||'/'||ws_coluna||'/'||trim(ws_parametros)||'/'||ws_rp||'/'||ws_colup||'/'||WS_AGRUPADOR, ws_usuario, 'ACESSO', 'ACESSO', '01');

	if ws_sql like 'Excesso de filtros%' then 
		raise ws_excesso_filtro; 
	end if; 

	ws_queryoc := '';
	ws_counter := 0;
	ws_gotocounter := 0;
	loop
	    ws_counter := ws_counter + 1;
	    if  ws_counter > ws_query_montada.COUNT then
	    	exit;
	    end if;
	    ws_queryoc := ws_queryoc||ws_query_montada(ws_counter);
	end loop;
	
	if ws_admin = 'A' then  -- Grava a ultima query executada para o objeto
		begin  
			delete bi_object_query where cd_object = ws_objeto and nm_usuario = ws_usuario;
			insert into bi_object_query (cd_object, nm_usuario, dt_ultima_execucao, query) values (ws_objeto, ws_usuario, sysdate, ws_queryoc ); 
		exception when others then 
			insert into bi_log_sistema values (sysdate,'Erro gravando em bi_object_query ['||ws_objeto||']:'|| DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, ws_usuario,'ERRO');
		end; 
		commit;	
	end if;


	if ws_sql = 'Sem Query' then
	   raise ws_semquery;
	end if;

	ws_sql_pivot := ws_query_pivot;

	open crs_xgoto(ws_usuario);
	loop
	    fetch crs_xgoto into ws_xgoto;
	    exit when crs_xgoto%notfound;
		ws_gotocounter := ws_gotocounter+1;
	end loop;
	close crs_xgoto;

	if(ws_gotocounter > 0) then
	        ws_tmp_jump := '';
	end if;

	if length(fun.getprop(ws_objeto, 'BORDA_COR')) > 0 then
		if prm_drill <> 'Y' then
		    ws_borda := 'border: 1px solid '||trim(fun.getprop(ws_objeto, 'BORDA_COR'))||';';
		else
		    ws_borda := 'height: auto; border: 1px solid '||trim(fun.getprop(ws_objeto, 'BORDA_COR'))||';';
		end if;
	end if;
	
	if prm_drill = 'Y' then
	    ws_classe := 'dragme front drill cross';
	else
	    ws_classe := 'dragme front cross';
	end if;

	if prm_drill <> 'Y' then
	    ws_html := 'data-refresh="12000" data-swipe="" ontouchstart="swipeStart('''||ws_objeto||''', event); selectmouse(event);" ontouchmove="swipe('''||ws_objeto||''', event);" ontouchend="swipe('''||ws_objeto||''', event);"';
	end if;
	
	htp.p('<div id="'||ws_obj_html||'" data-drillt="'||fun.getprop(ws_objeto,'DRILLT')||'" data-full="'||fun.getprop(ws_objeto,'FULL')||'" data-cell="'||ws_ordem||'" data-track="" data-left="'||ws_posix||'" data-top="'||ws_posiy||'" data-visao="'||prm_micro_visao||'" data-drill="'||prm_drill||'" onmousedown="'||ws_propagation||'" class="'||ws_classe||'" style="background-color: '||fun.getprop(ws_objeto, 'FUNDO_VALOR')||'; '||ws_posicao||' max-width: calc(100% - '||fun.getprop(ws_objeto,'DASH_MARGIN_LEFT', prm_screen)||' - '||fun.getprop(ws_objeto,'DASH_MARGIN_RIGHT', prm_screen)||'); '||ws_borda||'" '||ws_html||'>');
    ws_html   := '';
	ws_classe := '';
	

	if fun.getprop(ws_objeto,'NO_RADIUS') <> 'N' then
        htp.p('<style>div#'||ws_obj_html||' table tr td, div#'||ws_obj_html||' table tr th, div#'||ws_obj_html||'fixed, div#'||ws_obj_html||'fixed { font-size: '||fun.getprop(ws_objeto,'FONT_SIZE')||'; } div#'||ws_obj_html||', span#'||ws_obj_html||'_ds { border-radius: 0; } div#'||ws_obj_html||' span#'||ws_obj_html||'more { border-radius: 0 0 6px 0; } /*a#'||ws_obj_html||'fechar { border-radius: 0 0 0 6px; }*/</style>');
	else
	    htp.p('<style>div#'||ws_obj_html||' table tr td, div#'||ws_obj_html||' table tr th, div#'||ws_obj_html||'fixed, div#'||ws_obj_html||'fixed { font-size: '||fun.getprop(ws_objeto,'FONT_SIZE')||'; }</style>');
	end if;


	htp.p('<style>div#'||ws_obj_html||'fixed span, div.dragme.cross div.header table tbody tr:first-child, div.dragme.cross div.header table tbody tr:first-child td { background: '||fun.getprop(ws_objeto, 'FUNDO_CABECALHO')||'; color: '||fun.getprop(ws_objeto, 'FONTE_CABECALHO')||'; }');
	    htp.p('table#'||ws_obj_html||'c tr.total, div#'||ws_obj_html||'fixed li.total { background: '||fun.getprop(ws_objeto, 'FUNDO_TOTAL')||'; color: '||fun.getprop(ws_objeto, 'FONTE_TOTAL')||'; }');
	
		if  fun.getprop(ws_objeto, 'DEGRADE') <> 'S' THEN
		    htp.p('table#'||ws_obj_html||'c tr.cl, div#'||ws_obj_html||'fixed li.cl, div#'||ws_obj_html||'fixed li.seta.cl { background: '||fun.getprop(ws_objeto, 'FUNDO_CLARO')||'; color: '||fun.getprop(ws_objeto, 'FONTE_CLARO')||'; }');
		    htp.p('table#'||ws_obj_html||'c tr.es, div#'||ws_obj_html||'fixed li.es, div#'||ws_obj_html||'fixed li.seta.es { background: '||fun.getprop(ws_objeto, 'FUNDO_ESCURO')||'; color: '||fun.getprop(ws_objeto, 'FONTE_ESCURO')||'; }');
		else
		    htp.p('table#'||ws_obj_html||'c tr.cl, div#'||ws_obj_html||'fixed li.cl, div#'||ws_obj_html||'fixed li.seta.cl { color: '||fun.getprop(ws_objeto, 'FONTE_CLARO')||'; }');
		    htp.p('table#'||ws_obj_html||'c tr.es, div#'||ws_obj_html||'fixed li.es, div#'||ws_obj_html||'fixed li.seta.es { color: '||fun.getprop(ws_objeto, 'FONTE_ESCURO')||'; }');
		end if;
	htp.p('</style>');


	htp.p('<span class="turn">');
	--htp.p('<span class="tempo" onclick="ajax(''list'',''atu_view'',''prm_screen='||prm_screen||'&prm_objeto='||prm_objeto||''', false,''attriblist'');"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" style="margin-top: 0px;><title>Stopwatch</title><g id=" _11_-_20"="" data-name="11 - 20"><g id="Stopwatch"><path d="M38.1,14.312l1.455-1.454.793.793a1,1,0,0,0,1.414-1.414l-3-3a1,1,0,1,0-1.414,1.414l.792.793L36.688,12.9A18.892,18.892,0,0,0,25,8.051V7h2a2,2,0,0,0,2-2V4a2,2,0,0,0-2-2H21a2,2,0,0,0-2,2V5a2,2,0,0,0,2,2h2V8.051A18.892,18.892,0,0,0,11.312,12.9L9.858,11.444l.792-.793A1,1,0,1,0,9.236,9.237l-3,3A1,1,0,1,0,7.65,13.651l.793-.793L9.9,14.312a19,19,0,1,0,28.2,0ZM21,4h6V5H21Zm3,40A17,17,0,1,1,41,27,17.019,17.019,0,0,1,24,44Z"></path><path d="M24,12A15,15,0,1,0,39,27,15.017,15.017,0,0,0,24,12ZM35,28h1.949a12.919,12.919,0,0,1-3.088,7.447l-1.376-1.376a1,1,0,1,0-1.414,1.414l1.376,1.376A12.926,12.926,0,0,1,25,39.949V38a1,1,0,0,0-2,0v1.949a12.926,12.926,0,0,1-7.447-3.088l1.376-1.376a1,1,0,1,0-1.414-1.414l-1.376,1.376A12.919,12.919,0,0,1,11.051,28H13a1,1,0,0,0,0-2H11.051a12.919,12.919,0,0,1,3.088-7.447l1.376,1.376a1,1,0,1,0,1.414-1.414l-1.376-1.376A12.926,12.926,0,0,1,23,14.051V16a1,1,0,0,0,2,0V14.051a12.926,12.926,0,0,1,7.447,3.088l-1.376,1.376a1,1,0,1,0,1.414,1.414l1.376-1.376A12.919,12.919,0,0,1,36.949,26H35a1,1,0,0,0,0,2Z"></path><path d="M27.827,17.761a1,1,0,0,0-1.306.541l-2.367,5.714c-.052,0-.1-.016-.154-.016a3.03,3.03,0,1,0,2,.781l2.367-5.713A1,1,0,0,0,27.827,17.761ZM24,28a1,1,0,1,1,1-1A1,1,0,0,1,24,28Z"></path></g></svg></span>');


		/*****************  Desabilitado a opção de inversão da tabela - 29/07/2022 - Definido em reunião até fazer algumas correções da tabela invertida  
		select count(*) into ws_counter from table(fun.vpipe_par(prm_coluna));
		if ws_counter = 0 and nvl(trim(prm_colup), 'null') = 'null' then
			htp.p('<span class="arrowturn">&#x21B2;</span>');
		end if;
		***************/ 

		/*if to_number(fun.ret_var('ORACLE_VERSION')) > 10 then
			select count(*) into ws_counter from table(fun.vpipe(prm_coluna));
			if ws_counter = 0 and nvl(trim(prm_colup), 'null') = 'null' then
				htp.p('<span class="arrowturn">&#x21B2;</span>');
				if length(trim(fun.show_filtros(trim(ws_parametros), ws_cursor, '', prm_objid, prm_micro_visao, prm_screen))) > 3 then
					htp.p('<span class="filtros">F</span>');
				end if;
			end if;
		end if;*/

		

		if length(trim(fun.show_filtros(trim(ws_parametros), ws_cursor, '', ws_objeto, prm_micro_visao, prm_screen))) > 3 then
			htp.p('<span class="filtros" style="color: gray;">F</span>');

		end if;
		
		if length(trim(fun.show_destaques(trim(ws_parametros), ws_cursor, '', ws_objeto, prm_micro_visao, prm_screen))) > 3 then
			htp.p('<span class="destaques">');
				htp.p('<svg style="height: calc(100% - 10px); width: calc(100% - 10px); margin: 5px; fill: #333; pointer-events: none;" enable-background="new -1.23 -8.789 141.732 141.732" height="141.732px" id="Livello_1" version="1.1" viewBox="-1.23 -8.789 141.732 141.732" width="141.732px" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><g id="Livello_100"><path d="M139.273,49.088c0-3.284-2.75-5.949-6.146-5.949c-0.219,0-0.434,0.012-0.646,0.031l-42.445-1.001l-14.5-37.854   C74.805,1.824,72.443,0,69.637,0c-2.809,0-5.168,1.824-5.902,4.315L49.232,42.169L6.789,43.17c-0.213-0.021-0.43-0.031-0.646-0.031   C2.75,43.136,0,45.802,0,49.088c0,2.1,1.121,3.938,2.812,4.997l33.807,23.9l-12.063,37.494c-0.438,0.813-0.688,1.741-0.688,2.723   c0,3.287,2.75,5.952,6.146,5.952c1.438,0,2.766-0.484,3.812-1.29l35.814-22.737l35.812,22.737c1.049,0.806,2.371,1.29,3.812,1.29   c3.393,0,6.143-2.665,6.143-5.952c0-0.979-0.25-1.906-0.688-2.723l-12.062-37.494l33.806-23.9   C138.15,53.024,139.273,51.185,139.273,49.088"/></g><g id="Livello_1_1_"/></svg>');
			htp.p('</span>');
		end if;
	
	htp.p('</span>');
	htp.p('<span id="'||ws_obj_html||'sync" class="sync" title=""><img src="'||nvl(fun.ret_var('OWNER_BI'),'DWU')||'.fcl.download?arquivo=sinchronize.png" /></span>');

	ws_counter := 0;

	if prm_drill = 'Y' then
	    htp.p('<a class="fechar" id="'||ws_obj_html||'fechar" title="'||fun.lang('Fechar')||'"></a>');
		htp.p('<a class="fechar_app" id="'||ws_obj_html||'fechar_app"></a>');   -- Somente efeito visual, a acão continua no elemento 'fechar'
		if ws_admin = 'A' then
	        htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options closed" id="'||ws_obj_html||'more">');
				htp.p(fun.showtag(ws_obj_html, 'atrib', prm_screen));
				--htp.p(fun.showtag(prm_objid, 'post'));
			    htp.p('<span class="preferencias" data-visao="'||prm_micro_visao||'" data-drill="'||prm_drill||'" title="'||fun.lang('Propriedades')||'"></span>');
			    htp.p(fun.showtag(ws_obj_html, 'filter', prm_micro_visao));
				htp.p('<span class="sigma" title="'||fun.lang('Linha calculada')||'"></span>');
			    htp.p('<span class="lightbulb" title="'||fun.lang('Drill')||'"></span>');
			    htp.p(fun.showtag(ws_obj_html||'c', 'excel'));
			    htp.p('<span class="data_table" title="'||fun.lang('Alterar Consulta')||'"></span>');
				htp.p(fun.showtag('', 'star'));
			htp.p('</span>');
	    else
		    if nvl(fun.getprop(ws_objeto,'NO_OPTION'),'N') <> 'S' then

				if ws_count > 0 then
				    select nvl(cs_agrupador, 'N/A') into ws_tpt from ponto_avaliacao where cs_agrupador in (select nvl(cd_coluna, 'N/A') from micro_coluna where st_agrupador = 'TPT' and cd_micro_visao = prm_micro_visao) and cd_ponto = ws_objeto;
				else
				    ws_tpt := 'N/A';
				end if;

				if ws_tpt <> 'N/A' then
				    htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options closed" id="'||ws_obj_html||'more" style="right: 0; max-width: 132px; max-height: 26px;">');
				else
				    htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options closed" id="'||ws_obj_html||'more" style="right: 0; max-width: 106px; max-height: 26px;">');
				end if;
				
				htp.p('<span class="lightbulb" title="'||fun.lang('Drill')||'"></span>');
				--htp.p(fun.showtag(ws_objid, 'post'));
				htp.p(fun.showtag(ws_obj_html||'c', 'excel'));
				htp.p(fun.showtag('', 'star'));
				htp.p('</span>');
				
			end if;
	    end if;
	elsif prm_drill = 'O' then
	    htp.p(ws_null);
	else
	    if ws_admin = 'A' then
	    	htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options closed" id="'||ws_obj_html||'more">');
				htp.p(fun.showtag(ws_obj_html, 'atrib', prm_screen));
				--htp.p(fun.showtag(ws_objid, 'post'));
				htp.p('<span class="preferencias" data-visao="'||prm_micro_visao||'" data-drill="'||prm_drill||'" title="'||fun.lang('Propriedades')||'"></span>');
				htp.p(fun.showtag(ws_obj_html, 'filter', prm_micro_visao));
				htp.p('<span class="sigma" title="'||fun.lang('Linha calculada')||'"></span>');
				htp.p('<span class="lightbulb" title="'||fun.lang('Drill')||'"></span>');
	   			htp.p(fun.showtag(ws_obj_html||'c', 'excel'));
				htp.p('<span class="data_table" title="'||fun.lang('Alterar Consulta')||'"></span>');
				htp.p(fun.showtag('', 'star'));
				fcl.button_lixo('dl_obj', prm_objeto => ws_objeto, prm_tag => 'span');
			htp.p('</span>');
	   		--htp.p('<a class="fechar" id="'||ws_objid||'fechar" title="'||fun.lang('Fechar')||'"></a>');
	    else
	   		if nvl(fun.getprop(ws_objeto,'NO_OPTION'),'N') <> 'S' then

				if ws_count > 0 then
				    select nvl(cs_agrupador, 'N/A') into ws_tpt from ponto_avaliacao where cs_agrupador in (select nvl(cd_coluna, 'N/A') from micro_coluna where st_agrupador = 'TPT' and cd_micro_visao = prm_micro_visao) and cd_ponto = ws_objeto;
				else
				    ws_tpt := 'N/A';
				end if;

				if ws_tpt <> 'N/A' then
				    htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options closed" id="'||ws_obj_html||'more" style="right: 0; max-width: 106px; max-height: 30px;">');
				else
				    htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options closed" id="'||ws_obj_html||'more" style="right: 0; max-width: 106px; max-height: 30px;">');
				end if;
				    htp.p('<span class="lightbulb" title="'||fun.lang('Drill')||'"></span>');
					--htp.p(fun.showtag(ws_objid, 'post'));
					htp.p(fun.showtag(ws_obj_html||'c', 'excel'));
                    htp.p(fun.showtag('', 'star'));
				htp.p('</span>');
			end if;
	    end if;
	end if;

	begin
		ws_cursor := dbms_sql.open_cursor;
		dbms_sql.parse( c => ws_cursor, statement => ws_query_montada, lb => 1, ub => ws_lquery, lfflg => true, language_flag => dbms_sql.native );
		ws_sql := core.bind_direct(ws_parametros, ws_cursor, '', ws_objeto, prm_micro_visao, prm_screen,prm_usuario => ws_usuario);
		
		select count(*) into ws_limite_col
        from table(fun.vpipe(ws_cab_cross));

	select count(*) into ws_linha_calc
	from linha_calculada
	where cd_micro_visao = prm_micro_visao 
	  and cd_objeto      = ws_objeto;

		ws_counter := 0;
		loop
		    ws_counter := ws_counter + 1;
		    if  ws_counter > (ws_limite_col + ws_linha_calc) then
		    	exit;
		    end if;
		    dbms_sql.define_column(ws_cursor, ws_counter, ret_coluna, 2000);
		end loop;

		ws_linhas := dbms_sql.execute(ws_cursor);
		ws_linhas := dbms_sql.fetch_rows(ws_cursor);
		if  ws_linhas = 1 then
		    ws_vazio := False;
	    else
	        dbms_sql.close_cursor(ws_cursor);
	        ws_vazio := True;
      		raise ws_nodata;
        end if;
		dbms_sql.close_cursor(ws_cursor);
	exception
	    when others then
	    	raise ws_parseerr;
	end;

	htp.formOpen( cattributes => 'name="busca" style="display: none;"', curl =>'A', cmethod => 'post');
		if  prm_drill <> 'Y' then
		    htp.p( '<input type="hidden" name="show_'||ws_obj_html||'" id="show_'||ws_obj_html||'" value="prm_drill=N&prm_objeto='||ws_objeto||'&PRM_POSX='||ws_posix||'&PRM_ZINDEX='||prm_zindex||'&PRM_POSY='||ws_posiy||'&prm_parametros='||ws_parametros||'&prm_screen='||prm_screen||'&prm_track=&prm_objeton=" />');
		end if;
		htp.p( '<input type="hidden" name="npar_'||ws_obj_html||'" id="par_'||ws_obj_html||'" value="'||ws_parametros||'" />');
		htp.p( '<input type="hidden" name="nord_'||ws_obj_html||'" id="ord_'||ws_obj_html||'" value="'||ws_ordem||'" />');
		htp.p( '<input type="hidden" name="nmvs_'||ws_obj_html||'" id="mvs_'||ws_obj_html||'" value="'||prm_micro_visao||'" />');
		htp.p( '<input type="hidden" name="ncol_'||ws_obj_html||'" id="col_'||ws_obj_html||'" value="'||ws_coluna||'" />');
		htp.p( '<input type="hidden" name="nagp_'||ws_obj_html||'" id="agp_'||ws_obj_html||'" value="'||ws_agrupador||'" />');
		htp.p( '<input type="hidden" name="nrps_'||ws_obj_html||'" id="rps_'||ws_obj_html||'" value="'||ws_rp||'" />');
		htp.p( '<input type="hidden" name="ndri_'||ws_obj_html||'" id="dri_'||ws_obj_html||'" value="'||ws_drill||'" />');
		htp.p( '<input type="hidden" name="ncup_'||ws_obj_html||'" id="cup_'||ws_obj_html||'" value="'||ws_colup||'" />');
		htp.p( '<input type="hidden" name="nsco_'||ws_obj_html||'" id="sco_'||ws_obj_html||'" value="" />' );
    	htp.p( '<input type="hidden" name="ndrl_'||ws_obj_html||'" id="drill_'||ws_obj_html||'" value='||chr(39)||fun.call_drill(prm_drill, ws_parametros, prm_screen, prm_objid, prm_micro_visao, prm_coluna, 1, prm_track, prm_objeton)||chr(39)||' />' );
    	htp.p( '<input type="hidden" name="ndrl_'||ws_obj_html||'" id="drill2_'||ws_obj_html||'" value='||chr(39)||fun.call_drill(prm_drill, ws_parametros, prm_screen, prm_objid, prm_micro_visao, prm_coluna, 2, prm_track, prm_objeton)||chr(39)||' />' );
	htp.formclose;
	
	select nm_objeto into ws_nome from objetos where cd_objeto = ws_objeto;

	if  nvl(prm_objid,'%?%')<>'%?%' then
		    ws_titulo := ws_nome;
		else
		    ws_titulo := '';
	end if;

	if  fun.getprop(ws_objeto, 'TOP') <> 'X' then
        ws_top := fun.getprop(ws_objeto, 'TOP');
    end if;

	ws_title := ws_queryoc;

	if  prm_drill='Y' then
		if ws_admin = 'A' then
			htp.p('<span style="text-align: '||fun.getprop(ws_objeto,'ALIGN_TIT')||'; background-color: '||fun.getprop(ws_objeto,'FUNDO_TIT')||'; color: '||fun.getprop(ws_objeto,'TIT_COLOR')||';" id="'||ws_obj_html||'_ds" ondblclick="curtain(''''); scale('''||ws_obj_html||''');" data-touch="0" ontouchstart="document.getElementById('''||ws_obj_html||''').style.opacity=0.7;" ontouchend="document.getElementById('''||ws_obj_html||''').style.opacity=1; dblTouch('''||ws_obj_html||''');" title="'||ws_objeto||'" class="wd_move" onmouseup="document.getElementById('''||ws_obj_html||''').style.opacity=1;" onmousedown="document.getElementById('''||ws_obj_html||''').style.opacity=0.7;">'||fun.subpar(fun.utranslate('NM_OBJETO', ws_objeto, ws_titulo), prm_screen)||'</span>');
		else
		    htp.p('<span style="text-align: '||fun.getprop(ws_objeto,'ALIGN_TIT')||'; background-color: '||fun.getprop(ws_objeto,'FUNDO_TIT')||'; color: '||fun.getprop(ws_objeto,'TIT_COLOR')||';" id="'||ws_obj_html||'_ds" ondblclick="curtain(''''); scale('''||ws_obj_html||''');" data-touch="0" ontouchstart="document.getElementById('''||ws_obj_html||''').style.opacity=0.7;" ontouchend="document.getElementById('''||ws_obj_html||''').style.opacity=1; dblTouch('''||ws_obj_html||''');" title="'||fun.lang('clique e arraste para mover')||'" onmouseup="document.getElementById('''||ws_obj_html||''').style.opacity=1;" onmousedown="document.getElementById('''||ws_obj_html||''').style.opacity=0.7;" class="wd_move">'||fun.subpar(fun.utranslate('NM_OBJETO', ws_objeto, ws_titulo), prm_screen)||'</span>');
		end if;
	else
		if ws_admin = 'A' then
		    htp.p('<span style="text-align: '||fun.getprop(ws_objeto,'ALIGN_TIT')||'; background-color: '||fun.getprop(ws_objeto,'FUNDO_TIT')||'; color: '||fun.getprop(ws_objeto,'TIT_COLOR')||';" id="'||ws_obj_html||'_ds" ondblclick="curtain(''''); scale('''||ws_obj_html||''');" data-touch="0" ontouchend="dblTouch('''||ws_obj_html||'''); invisible_touch('''||ws_obj_html||''', ''stop'');" data-touch="0" title="'||ws_obj_html||'" class="wd_move" ontouchstart="invisible_touch('''||ws_obj_html||''', ''start'');" onmousedown="invisible_touch('''||ws_obj_html||''', ''start''); " onmouseup="invisible_touch('''||ws_obj_html||''', ''stop'');">'||fun.subpar(fun.utranslate('NM_OBJETO', ws_objeto, ws_titulo), prm_screen)||'</span>');
		else
		    htp.p('<span style="text-align: '||fun.getprop(ws_objeto,'ALIGN_TIT')||'; background-color: '||fun.getprop(ws_objeto,'FUNDO_TIT')||'; color: '||fun.getprop(ws_objeto,'TIT_COLOR')||';" id="'||ws_obj_html||'_ds" ondblclick="curtain(''''); scale('''||ws_obj_html||''');" data-touch="0" ontouchend="dblTouch('''||ws_obj_html||''');" data-touch="0" class="no_move">'||fun.subpar(fun.utranslate('NM_OBJETO', ws_objeto, ws_titulo), prm_screen)||'</span>');
		end if;
	end if;


	htp.p('<ul id="'||ws_obj_html||'-filterlist" style="display: none;">');
	    htp.p(fun.show_filtros(trim(ws_parametros), ws_cursor, '', ws_objeto, prm_micro_visao, prm_screen));
	htp.p('</ul>');
	
	htp.p('<ul id="'||ws_obj_html||'-destaquelist" style="display: none;" >');
	    htp.p(fun.show_destaques(trim(ws_parametros), ws_cursor, '', ws_objeto, prm_micro_visao, prm_screen));
	htp.p('</ul>');

	begin
		if fun.getprop(ws_objeto, 'LARGURA') <> 0 then
			ws_largura := to_number(fun.getprop(ws_objeto, 'LARGURA'));
		else
			ws_largura := to_number('4000');
		end if;
    exception when others then
	    ws_largura := to_number('4000');
	end;
	
	begin
		if fun.getprop(ws_objeto, 'ALTURA') <> 0 then
			ws_ctemp := to_number(fun.getprop(ws_objeto, 'ALTURA'))+14;
		else
			ws_ctemp := to_number('6000');
		end if;
	exception when others then
	    ws_ctemp := to_number('6000');
	end;

	htp.p('<div class="header" id="'||ws_obj_html||'header" style="background-color: '||fun.getprop(ws_objeto, 'FUNDO_VALOR')||'; max-width: '||ws_largura||'px;"></div>');

	if fun.getprop(ws_objeto, 'DEGRADE') = 'S' THEN
	    htp.p('<div class="fonte" data-resize="" data-maxheight="'||ws_ctemp||'" data-maxwidth="'||ws_largura||'" style="max-width: '||ws_largura||'px; '||fcl.fpdata(ws_ctemp,'0','',' max-height: '||ws_ctemp||'px; cursor: default; ')||' background: -webkit-linear-gradient('||fun.getprop(ws_objeto, 'FUNDO_CLARO')||', '||fun.getprop(ws_objeto, 'FUNDO_ESCURO')||'); background: linear-gradient('||fun.getprop(ws_objeto, 'FUNDO_CLARO')||', '||fun.getprop(ws_objeto, 'FUNDO_ESCURO')||'); " id="'||ws_obj_html||'dv2">');
	else
		htp.p('<div class="fonte" data-resize="" data-maxheight="'||ws_ctemp||'" data-maxwidth="'||ws_largura||'" style="max-width: '||ws_largura||'px; '||fcl.fpdata(ws_ctemp,'0','',' max-height: '||ws_ctemp||'px; cursor: default; ')||'" id="'||ws_obj_html||'dv2">');
	end if;

	htp.p('<div id="'||ws_obj_html||'m">');
	
	
	htp.tableOpen( cattributes => ' id="'||ws_obj_html||'c" ');

	ws_counter   := 0;
	ws_counterid := 1;
	ws_ccoluna   := 0;
    ws_step := 0;

	ws_firstid := 'Y';

	ws_cursor := dbms_sql.open_cursor;

	dbms_sql.parse( c => ws_cursor, statement => ws_query_montada, lb => 1, ub => ws_lquery, lfflg => true, language_flag => dbms_sql.native );

	ws_sql := core.bind_direct(ws_parametros, ws_cursor, '', ws_objeto, prm_micro_visao, prm_screen,prm_usuario => ws_usuario);

	ws_counter := 0;
	loop
	    ws_counter := ws_counter + 1;
	    if  ws_counter > (ws_limite_col + ws_linha_calc) then
	    	exit;
	    end if;
	    dbms_sql.define_column(ws_cursor, ws_counter, ret_coluna, 2000);
	end loop;
	ws_linhas := dbms_sql.execute(ws_cursor);

	ws_counter := 0;
	loop
	    ws_counter := ws_counter + 1;
	    if  ws_counter > (ws_limite_col + ws_linha_calc) then
		exit;
	    end if;

	    ws_ccoluna := 1;
	    loop
		if  ws_ccoluna = ret_mcol.COUNT or ret_mcol(ws_ccoluna).cd_coluna = ws_ncolumns(ws_counter) then
		    exit;
		end if;
		ws_ccoluna := ws_ccoluna + 1;
	    end loop;

	    if  ret_mcol(ws_ccoluna).st_agrupador = 'SEM' then
	        ws_vcol(ws_counter) := ret_mcol(ws_ccoluna).cd_coluna;
	        ws_vcon(ws_counter) := 'First';
	    end if;

	    ws_coluna_ant(ws_counter) := 'First';
	end loop;

	htp.p('<tbody></tbody>');
	
	htp.p('<thead>');

        select cd_ligacao into ws_ligacao from micro_coluna where cd_coluna = ws_coluna and cd_micro_visao = prm_micro_visao;
	
	    htp.p('<tr class="escuro" style="background: '||fun.getprop(ws_objeto, 'FUNDO_CABECALHO')||'; color: '||fun.getprop(ws_objeto, 'FONTE_CABECALHO')||';">');
			for i in (SELECT COLUMN_VALUE FROM TABLE(fun.VPIPE((ws_cab_cross)))) loop
				if i.column_value = ws_coluna then
					if nvl(ws_ligacao, 'SEM') <> 'SEM' then
					    htp.prn('<th>#</th>');
					else
					    htp.prn('<th>'||fun.nome_col(i.column_value, prm_micro_visao)||'</th>');
					end if;
				else
					htp.prn('<th>'||i.column_value||'</th>');
				end if;
			end loop;
	    htp.p('</tr>');

		
		if nvl(ws_ligacao, 'SEM') <> 'SEM' then
             htp.p('<tr class="escuro" style="background: '||fun.getprop(ws_objeto, 'FUNDO_CABECALHO')||'; color: '||fun.getprop(ws_objeto, 'FONTE_CABECALHO')||';">');
				for i in (SELECT COLUMN_VALUE FROM TABLE(fun.VPIPE((ws_cab_cross)))) loop
					if i.column_value = ws_coluna then
						htp.prn('<th>'||fun.nome_col(i.column_value, prm_micro_visao)||'</th>');
					else
						htp.prn('<th>'||fun.cdesc(i.column_value, ws_ligacao)||'</th>');
					end if;
				end loop;
	    	htp.p('</tr>');
		end if;
	
	htp.p('</thead>');

	ws_zebrado   := 'First';
	ws_zebrado_d := 'First';
    
    

	htp.p('<tbody>');

	loop
	    ws_linhas := dbms_sql.fetch_rows(ws_cursor);
	    if  ws_linhas = 1 then
		    ws_vazio := False;
	    else
            if  ws_vazio = True then
	            dbms_sql.close_cursor(ws_cursor);
      		    raise ws_nodata;
        	end if;
        	exit;
	    end if;

		ws_ct_top := ws_ct_top + 1;
        if  ws_top <> 0 and ws_ct_top > ws_top then
            exit;
        end if;

		if  ws_zebrado in ('First','Escuro') then
			ws_zebrado   := 'Claro';
			ws_zebrado_d := 'Distinto_claro';
		else
			ws_zebrado   := 'Escuro';
			ws_zebrado_d := 'Distinto_escuro';
		end if;

	    ws_counter := 0;
	    ws_ccoluna := 0;
	    ws_chcor   := 0;
	    ws_ctnull  := 0;
	    ws_ctcol   := 0;

	    loop

		ws_counter := ws_counter + 1;
		if  ws_counter > (ws_limite_col + ws_linha_calc) then
		    exit;
		end if;

		ws_xcoluna := 1;
		loop
		    if  ws_xcoluna = ret_mcol.COUNT or ret_mcol(ws_xcoluna).cd_coluna = ws_ncolumns(ws_counter) then
				exit;

		    end if;
		    ws_xcoluna := ws_xcoluna + 1;
		end loop;

		ws_ccoluna := ws_ccoluna + 1;
		dbms_sql.column_value(ws_cursor, ws_ccoluna, ret_coluna);

		if  ws_ccoluna = 1 then
		    ret_coluna := substr(ret_coluna,6,length(ret_coluna));
			ws_refcol := ret_coluna;
		end if;

		if  ret_mcol(ws_xcoluna).st_agrupador = 'SEM' then
		    ws_ctcol  := ws_ctcol + 1;
		end if;

	    end loop;

	    ws_xatalho := '';
	    ws_pipe    := '';
	    ws_bindn := ws_vcol.FIRST;
	    while ws_bindn is not null loop
		if  ws_bindn = 1 or ws_ncolumns(ws_bindn) <> ws_ncolumns(ws_bindn-1) then
		    dbms_sql.column_value(ws_cursor, ws_bindn, ret_coluna);
		    ws_vcon(ws_bindn) := ret_coluna;
		    dbms_sql.column_value(ws_cursor, ws_bindn, ret_coluna);
		    if  nvl(ret_coluna,'%*') <> '%*' then
		        ws_xatalho := ws_xatalho||ws_pipe;
			ws_xatalho := trim(ws_xatalho)||ws_vcol(ws_bindn);
			ws_pipe    := '|';
		    end if;
		end if;
		ws_bindn := ws_vcol.NEXT(ws_bindn);
	    end loop;
	    
	    

		ws_linha := ws_linha+1;
		if  ret_colgrp <> 0 then
			htp.tableRowOpen( cattributes => 'class="total"');
		else
			if(ws_zebrado = 'Escuro') then
			  htp.tableRowOpen( cattributes => 'class="es"');
			else
			  htp.tableRowOpen( cattributes => 'class="cl"');
			end if;
		end if;

		if(length(ws_tmp_jump) > 5) then
		    ws_check := ws_tmp_check;
		end if;

		ws_drill_atalho := replace('|'||trim(ws_xatalho),'||','|');
		if(instr(ws_drill_atalho, '|', 1, 1) = 1) then
		  ws_drill_atalho := substr(ws_drill_atalho,2,length(ws_drill_atalho));
		end if;

		ws_jump := ws_tmp_jump;

		/*if fun.verifica_post(prm_objid, ws_drill_atalho) then
			ws_jump := '';
		end if;*/

		if ret_colgrp = 0 then
		    htp.p('<td '||ws_check||' style="'||ws_jump||'" data-valor="'||ws_vcol(1)||'"></td>');
		end if;

	    ws_counter := 0;

		ws_limite_i := fun.getprop(ws_objeto,'COLUNA_INICIAL');
        ws_limite_f := fun.getprop(ws_objeto,'COLUNA_FINAL');
        ws_linha_acumulada := fun.getprop(ws_objeto,'LINHA_ACUMULADA');
		ws_total_acumulado := fun.getprop(ws_objeto,'TOTAL_ACUMULADO');

	    loop
		ws_counter := ws_counter + 1;
		if  ws_counter > (ws_limite_col + ws_linha_calc) then
		    exit;
		end if;


		begin
		    if(ws_counter) < ws_step-(ws_stepper) then
		        
		        ws_atalho := ws_mfiltro(ws_counter+1);
			else
			    ws_atalho := '';
			end if;
		exception
		    when others then
			ws_atalho := '';
		end;

		 ws_ccoluna := 1;
		  loop
			  if ret_mcol(ws_ccoluna).cd_coluna = ws_refcol then
				  exit;
			  end if;
			  ws_ccoluna := ws_ccoluna + 1;
		  end loop;

		dbms_sql.column_value(ws_cursor, ws_counter, ret_coluna);

		ret_coluna := replace(ret_coluna,'"','*');
		ret_coluna := replace(ret_coluna,'/',' ');

		if  ws_firstid = 'Y' then
		    ws_idcol := ' id="'||ws_objeto||ws_counter||'l" ';
		else
		    ws_idcol := '';
		end if;

		ws_drill_atalho := replace(trim(ws_atalho)||'|'||trim(ws_xatalho),'||','|');
		if(instr(ws_drill_atalho, '|', 1, 1) = 1) then
		  ws_drill_atalho := substr(ws_drill_atalho,2,length(ws_drill_atalho));
		end if;

		/*if fun.verifica_post(prm_objid, ws_drill_atalho) then
			if(length(ws_jump) > 5) then
			     ws_jump := ' ';
		    end if;
		end if;*/

		if(length(ws_jump) > 1) then
		  ws_jump := 'style="'||ws_jump||'"';
		end if;

		if(rtrim(ret_mcol(ws_ccoluna).st_invisivel) <> 'S') then
			if(rtrim(ret_mcol(ws_ccoluna).st_alinhamento) = 'RIGHT') then
				if(rtrim(ret_mcol(ws_ccoluna).st_negrito) = 'S') then
				    ws_jump := ws_jump||' class="dir bld"';
				else
				    ws_jump := ws_jump||' class="dir"';
				end if;
			elsif(rtrim(ret_mcol(ws_ccoluna).st_alinhamento) = 'CENTER') then
				if(rtrim(ret_mcol(ws_ccoluna).st_negrito) = 'S') then
				    ws_jump := ws_jump||' class="cen bld"';
				else
				    ws_jump := ws_jump||' class="cen"';
				end if;
			else
			    if(rtrim(ret_mcol(ws_ccoluna).st_negrito) = 'S') then
				    ws_jump := ws_jump||' class="bld"';
				end if;
			end if;

		else
			ws_jump := ws_jump||' class="no_font"';
		end if;

		ws_jump := trim(ws_jump);

		if  ret_mcol(ws_ccoluna).cd_coluna = ws_refcol then
		    ws_content := fun.nome_col(ret_coluna, prm_micro_visao);
		else
		    ws_content := ret_coluna;
		end if;

		if  ws_linha_acumulada = 'S' and ret_mcol(ws_ccoluna).st_agrupador <> 'SEM' and ws_counter < ws_ncolumns.COUNT and ret_colgrp = 0  THEN

			if  ws_counter > ws_limite_i and ws_counter < (ws_ncolumns.COUNT)-ws_limite_f and ws_scol = 1 then
				begin
					ws_temp_valor := to_number(nvl(ret_coluna, '0'));
				exception when others then
				    ws_temp_valor := 0;
				end;

				ws_acumulada_linha := ws_acumulada_linha + ws_temp_valor;
				ws_content     := ws_acumulada_linha;

			else
			    ws_content := ret_coluna;
			end if;
		else
		    ws_content := ret_coluna;
		end if;


		if length(trim(ws_atalho)) > 0 then
		    ws_pivot := 'data-p="'||trim(ws_atalho)||'"';
		end if;
		if  ret_mcol(ws_ccoluna).st_agrupador = 'SEM' and ret_coluna = ws_coluna_ant(ws_counter) then
		htp.tableData(fcl.fpdata((ws_ctnull - ws_ctcol),0,'','')||fun.ifmascara(ws_content,rtrim(ret_mcol(ws_ccoluna).nm_mascara), prm_micro_visao, ret_mcol(ws_ccoluna).cd_coluna, ws_objeto, '', ret_mcol(ws_ccoluna).formula, prm_screen), calign => '', cattributes => ' ');

		else
		    if ret_mcol(ws_ccoluna).st_agrupador = 'SEM' then

			htp.tableData(fcl.fpdata((ws_ctnull - ws_ctcol),0,'','')||fun.ifmascara(ws_content,rtrim(ret_mcol(ws_ccoluna).nm_mascara),prm_micro_visao, ret_mcol(ws_ccoluna).cd_coluna, ws_objeto, '', ret_mcol(ws_ccoluna).formula, prm_screen), calign => '', cattributes => ' ');

			else
		        ws_content := ws_content;
		        if(ret_mcol(ws_ccoluna).st_agrupador in ('PSM','PCT') and ret_colgrp = 0) or (ret_mcol(ws_ccoluna).st_gera_rel = 'N' and ret_colgrp = 0) then
		            ws_content := ' ';
		        end if;
				if ret_colgrp <> 0 and ws_scol = 1 then
					if ws_total_acumulado = 'S' THEN
						if ws_ccoluna > ws_limite_i and ws_ccoluna < ((ws_ncolumns.COUNT-1)-ws_limite_f) then
							begin
								ws_temp_valor := to_number(ws_content);
							exception
								when others then
									 ws_temp_valor := 0;
							end;
							ws_total_linha := ws_total_linha + ws_temp_valor;
							ws_content     := ws_total_linha;
						end if;
					end if;

					htp.tableData(fun.um(ret_mcol(ws_ccoluna).cd_coluna, prm_micro_visao, fun.ifmascara(ws_content,rtrim(ret_mcol(ws_ccoluna).nm_mascara), prm_micro_visao, ret_mcol(ws_ccoluna).cd_coluna, ws_objeto, '', ret_mcol(ws_ccoluna).formula, prm_screen)), calign => '', cattributes => fun.check_blink_total(ws_objeto, ret_mcol(ws_ccoluna).cd_coluna, ws_content, '', prm_screen)||
					' '||ws_jump||' '||ws_pivot||' ');
				else

					if  ws_counter = 1 then
					    htp.tableData(fun.nome_col(substr(ws_content,6,length(ws_content)), prm_micro_visao), calign => '', cattributes => 
			            ' '||ws_jump||' '||ws_pivot||' ' );
					else
					    htp.tableData(fun.um(ret_mcol(ws_ccoluna).cd_coluna, prm_micro_visao, fun.ifmascara(fun.nome_col(ws_content, prm_micro_visao),rtrim(ret_mcol(ws_ccoluna).nm_mascara), prm_micro_visao, ret_mcol(ws_ccoluna).cd_coluna, ws_objeto, '', ret_mcol(ws_ccoluna).formula, prm_screen)), calign => '', cattributes => 
			            ' '||ws_jump||' '||ws_pivot||' ' );
					end if;

				end if;
			end if;
		end if;

		if length(fun.check_blink_linha(ws_objeto, ret_mcol(ws_ccoluna).cd_coluna, ws_linha, ret_coluna, prm_screen)) > 7 and ret_colgrp = 0 then
		    ws_blink_linha := fun.check_blink_linha(ws_objeto, ret_mcol(ws_ccoluna).cd_coluna, ws_linha, ret_coluna, prm_screen);
		end if;

		ws_jump := '';
		ws_check := '';

		ws_coluna_ant(ws_counter) := ret_coluna;
	    end loop;

		if ws_blink_linha <> 'N/A' then htp.p(ws_blink_linha); end if;
	    ws_blink_linha := 'N/A';

	    ws_firstid := 'N';
	    htp.tableRowClose;
		ws_acumulada_linha := 0;
		ws_total_linha := 0;
	end loop;
	ws_acumulada_linha := 0;
	ws_total_linha := 0;
	dbms_sql.close_cursor(ws_cursor);
	htp.p('</tbody>');
	htp.tableClose;
	htp.p('</div>');
	ws_textot := '';
	ws_pipe   := '';
	ws_counter := 0;

	loop
	    ws_counter := ws_counter + 1;
	    if  ws_counter > (ws_limite_col + ws_linha_calc) then
		    exit;
	    end if;

	    ws_ccoluna := 1;
	    loop
		if  ws_ccoluna = ret_mcol.COUNT or ret_mcol(ws_ccoluna).cd_coluna = ws_ncolumns(ws_counter) then
		    exit;
		end if;
		ws_ccoluna := ws_ccoluna + 1;
	    end loop;

	    if  ret_mcol(ws_ccoluna).cd_ligacao <> 'SEM' and ret_mcol(ws_ccoluna).st_com_codigo = 'S' then
		ws_textot := ws_textot||ws_pipe||'2';
		ws_pipe   := '|';
		ws_counter := ws_counter + 1;
	    else
		ws_textot := ws_textot||ws_pipe||'1';
		ws_pipe   := '|';
	    end if;
	end loop;

	htp.p( '<input type="hidden" name="seqw_'||ws_obj_html||'" id="seqx_'||ws_obj_html||'" value="'||trim(ws_textot)||'" >');
	htp.p( '<input type="hidden" name="csxq_'||ws_obj_html||prm_ccount||'" id="cseq_'||ws_obj_html||prm_ccount||'" value="'||trim(ws_textot)||'" >');
	htp.p('</div>');
	if  prm_drill!='Y' then
		htp.p('</div>');
	end if;
	htp.p('</div>');

exception
		when ws_excesso_filtro then
        	insert into bi_log_sistema values(sysdate, 'CONSULTA: '||ws_sql, ws_usuario, 'ERRO');
        	commit;
	    	htp.p('<span class="err">'||ws_sql||'</span>');
			htp.p('</div>');
        when ws_mount then
	     fcl.iniciar;
        when ws_close_html then
	     fcl.POSICIONA_OBJETO('newquery','DWU','DEFAULT','DEFAULT');
	    when ws_parseerr   then
	    if ws_vazio then
            insert into log_eventos values(sysdate, prm_micro_visao||'/'||ws_coluna||'/'||trim(ws_parametros)||'/'||ws_rp||'/'||ws_colup||'/'||WS_AGRUPADOR, ws_usuario, 'VAZIO', 'ERRORLINE', '01');
            insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - VAZIO', ws_usuario, 'ERRO');
            commit;
        else
            insert into log_eventos values(sysdate, prm_micro_visao||'/'||ws_coluna||'/'||trim(ws_parametros)||'/'||ws_rp||'/'||ws_colup||'/'||WS_AGRUPADOR, ws_usuario, 'NOVAZIO', 'PARSE', '01');
		    insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - PARSEERR', ws_usuario, 'ERRO');
            commit;
		end if;
	    commit;
		htp.p('<p style="display: none;">'||ws_cab_cross||'  -   '||ws_ncolumns.COUNT||'</p>');
		htp.p('<span class="wd_move" style="text-align: '||fun.getprop(ws_objeto,'ALIGN_TIT')||'; background-color: '||fun.getprop(ws_objeto,'FUNDO_TIT')||'; color: '||fun.getprop(ws_objeto,'TIT_COLOR')||'; text-align: center; text-transform: uppercase; font-weight: bold; cursor: move; display: block;">'||fun.lang('Sem Dados')||'</span>');
		if ws_admin = 'A' then
		htp.tableOpen( cattributes => ' id="'||ws_obj_html||'c" style="max-width: 760px; overflow: auto; display: inline-block;"');
		    htp.tableRowOpen( cattributes => 'style="background: '||fun.getprop(ws_objeto, 'FUNDO_CABECALHO')||'; color: '||fun.getprop(ws_objeto, 'FONTE_CABECALHO')||';" border="0" id="'||ws_obj_html||'_tool" ');
			fcl.TableDataOpen( ccolspan => ws_limite_col, calign => 'LEFT');
			fcl.TableDataClose;
		    htp.tableRowClose;
		    htp.p('<ul>');
			htp.p(fun.show_filtros(trim(ws_parametros), ws_cursor, '', ws_objeto, prm_micro_visao, prm_screen) );
			htp.p('</ul>');
    		htp.tableRowOpen( cattributes => ' style="background: '||fun.getprop(ws_objeto, 'FUNDO_CABECALHO')||'; color: '||fun.getprop(ws_objeto, 'FONTE_CABECALHO')||';" border="0" id="'||ws_obj_html||'_tool" ');
			fcl.TableDataOpen( ccolspan => ws_limite_col, calign => 'LEFT');
			htp.p('<div style="white-space: pre-line; font-size: 15px; text-align: center; cursor: pointer;" onclick="paste = encodeURIComponent(this.innerHTML.trim()); alerta(''feed-fixo'', ''query copiada!'');">');
			ws_counter := 0;
			loop
				ws_counter := ws_counter + 1;
				if  ws_counter > ws_query_montada.COUNT then
				    exit;
				end if;
				htp.p(ws_query_montada(ws_counter));
			end loop;
			htp.p('</div>');
			fcl.TableDataClose;
		    htp.tableRowClose;
		    htp.tableClose;
		end if;
		htp.p('<div align="center"><img alt="'||fun.lang('alerta')||'" src="'||fun.r_gif('warning','PNG')||'"></div>');
		htp.p('</div>');
    when ws_invalido   then
        insert into log_eventos values(sysdate, prm_micro_visao||'/'||ws_coluna||'/'||trim(ws_parametros)||'/'||ws_rp||'/'||ws_colup||'/'||WS_AGRUPADOR, ws_usuario, 'INVALIDO', 'E-ACC', '01');
        insert into bi_log_sistema values(sysdate, 'ERRORLINE: '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - INVALIDO', ws_usuario, 'ERRO');
        commit;
	    fcl.negado(fun.lang('Parametros Invalidos'));
	when ws_acesso	     then
	   fcl.negado(prm_micro_visao||'visao');
	when ws_semquery     then
        insert into log_eventos values(sysdate, prm_micro_visao||'/'||ws_coluna||'/'||trim(ws_parametros)||'/'||ws_rp||'/'||ws_colup||'/'||WS_AGRUPADOR, ws_usuario, 'SEMQUERY', 'SEMQUERY', '01');
        insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - SEMQUERY', ws_usuario, 'ERRO');
        commit;
	    fcl.negado('['||prm_micro_visao||']-['||ws_objeto||']-'||fun.lang('Relat&oacute;rio Sem Query'));
	when ws_nodata	     then
		insert into log_eventos values(sysdate, prm_micro_visao||'/'||ws_coluna||'/'||trim(ws_parametros)||'/'||ws_rp||'/'||ws_colup||'/'||WS_AGRUPADOR, ws_usuario, 'NODATA', 'NODATA', '01');
        insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - NODATA', ws_usuario, 'ERRO');
        commit;
        htp.p('</div>');
		fcl.negado(prm_micro_visao||' - '||fun.lang('Sem Dados no relat&oacute;rio')||'.');
		htp.p('</div>');
	when ws_sempermissao then
	   fcl.negado(prm_micro_visao||' - '||fun.lang('Sem Permiss&atilde;o Para Este Filtro')||'.');
    when others	     then
        insert into log_eventos values(sysdate, prm_micro_visao||'/'||ws_coluna||'/'||trim(ws_parametros)||'/'||ws_rp||'/'||ws_colup||'/'||WS_AGRUPADOR, ws_usuario, 'OTHER', 'ERRORLINE', '01');
        insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - consultaInvertida', ws_usuario, 'ERRO');
        commit;
		if ws_admin = 'A' then 
		    htp.p('<span class="errorquery">'||fun.lang('N&atilde;o foi poss&iacute;vel montar os dados da consulta, verifique as propriedades e atributos da consulta.')||' <br><br>ERRO: '||sqlerrm||' <br><br>'||ws_queryoc||'</span>');
		else 
		    htp.p('<span class="errorquery">'||fun.lang('N&atilde;o foi poss&iacute;vel montar os dados da consulta, verifique as propriedades e atributos da consulta.')||'</span>');
		end if;  	
end consultaInvertida;

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
                        prm_popup_drill varchar2 default 'false'   ) as

	ws_mascara		    varchar2(30);
	ws_unidade		    varchar2(30);
	ws_goto             varchar2(2000);

	ws_cd_ponto		    varchar2(40);
	ws_nm_ponto		    varchar2(80);
	ws_ds_ponto		    varchar2(2000);
	ws_tp_renovacao		varchar2(1);
	ws_cd_micro_visao	varchar2(40);
	ws_parametros		varchar2(32000);
	ws_vl_salvo		    long;
	ws_cs_parametros	varchar2(32000);
	ws_cs_coluna		varchar2(2000);
	ws_cs_agrupador		varchar2(2000);
	ws_cs_rp		    varchar2(2000);
	ws_cs_colup		    varchar2(2000);
  
	ws_cd_objeto		varchar2(40);
	ws_nm_objeto		varchar2(80);
	ws_tp_objeto		varchar2(40);
	ws_cd_usuario		varchar2(40);
	ws_atributos		varchar2(4000);
	ws_ds_objeto		varchar2(2000);

	ws_obj			varchar2(60);
	ws_tip			varchar2(60);
	ws_referencia	varchar2(60);
	ws_posicao		varchar2(2000)	:=' ';
	ws_tamanho		varchar2(2000)  :=' ';
	ws_gout			varchar2(2000);

	ws_gvalores		varchar2(2000)  := ' ';
	ws_grotulo		varchar2(2000)  := ' ';
	ws_gdescricao	varchar2(2000)  := ' ';
	ws_subtitulo    varchar2(2000)  := ' ';
	ws_vmax			varchar2(2000);
	ws_vmin			varchar2(2000);

	ws_posx			varchar2(20);
	ws_posy			varchar2(20);
	ws_zindex		varchar2(20);
	ws_count		number;
	ws_situacao     number;
	ws_rcount       number;
	ws_parametrosr  clob;
	ws_parametro    clob := '';
	ws_param_ant    clob;
	ws_param_aux    clob;	
	ws_param_atu    clob;
	ws_param_dup    clob;

	ws_class        varchar2(60);
	ws_talk         varchar2(5) := 'talk';
	ws_style        varchar2(200);
	ws_filtro       varchar2(2000);
	ws_tipo         varchar2(80);
	ws_gradiente    varchar2(2000);
	ws_propagation  varchar2(400);
	ws_order        varchar2(50);
	ws_formula      varchar2(3000);
	ws_gradiente_tipo varchar2(40);
	ws_data_coluna  varchar2(500);
	ws_borda        varchar2(60)   := '';
	ws_complemento  varchar2(1400) := '';
	ws_coluna       varchar2(4000)  := '';
    ws_agrupador    varchar2(400)  := '';
	ws_colup        varchar2(400)  := '';
	ws_objid        varchar2(400);
	ws_tempo        date;
	ws_sec          varchar2(400)  := '';
	
	ws_cursor	    integer;
	ws_sql		    varchar2(2000);
	ws_valor        varchar2(400);
	ws_valores      clob;
	ws_linhas       integer;
	ws_alinhamento_tit varchar2(80);
	ws_ligacao      varchar2(80);
	ws_valor_ponto  varchar2(200);
	ws_valor_meta   varchar2(200);
	ws_valor_um     varchar2(40);
	ws_pos_i        number; 	
	ws_pos_f        number; 	

	ws_usuario      varchar2(80);
	ws_admin        varchar2(80);
	ws_padrao       varchar2(80) := 'PORTUGUESE';
	ws_bgColor_article	varchar2(80):='TRANSPARENT';
	ws_bgColor_section  varchar2(80):='TRANSPARENT';
	ws_italico		varchar2(80);
	ws_negrito		varchar2(80);
	ws_font			varchar2(80);
	ws_size			varchar2(80);
	ws_align        varchar2(80);
	ws_bordaCor		varchar2(200);
	ws_nouser       exception;
	ws_tempo_marquee varchar2(500);
	ws_class_new_consulta   varchar2(20);
	ws_class_new_valor      varchar2(20);
	ws_class_new_grafico    varchar2(20);
	ws_class_sel_barras     varchar2(20) := ' ';
	ws_class_sel_colunas    varchar2(20) := ' ';
	ws_class_sel_linhas     varchar2(20) := ' ';
	ws_class_sel_pizza      varchar2(20) := ' ';
	ws_class_sel_ponteiro   varchar2(20) := ' ';
	ws_class_sel_mapa       varchar2(20) := ' ';
	ws_class_sel_mapageoloc varchar2(20) := ' ';
	ws_class_sel_sankey     varchar2(20) := ' ';
	ws_class_sel_scatter    varchar2(20) := ' ';
	ws_class_sel_radar      varchar2(20) := ' ';
	ws_class_sel_calendario varchar2(20) := ' ';
	section_style			varchar2(4000);
	ws_posicao_section		varchar2(100);
	ws_altura_section		varchar2(100);
	ws_altura_article 		varchar2(100);
	ws_padding_section		varchar2(100);
	ws_width_calc_section	varchar2(100);
	
begin
	--pega o primeiro momento do tempo para o calculo da query_stat
	ws_tempo := SYSDATE;

	ws_usuario := prm_usuario;
	ws_admin   := prm_admin;

    if nvl(ws_usuario, 'N/A') = 'N/A' then
		ws_usuario := gbl.getUsuario;
	end if;

	if nvl(ws_admin, 'N/A') = 'N/A' then
		ws_admin   := nvl(gbl.getNivel, 'N');
	end if;

	if nvl(ws_usuario, 'NOUSER') = 'NOUSER' then
		raise ws_nouser;
	end if;

    if prm_dashboard <> 'false' then
	    ws_propagation := 'movingArticle(event);';
	else
	    ws_propagation := '';
	end if;

	if prm_drill = 'O' then
		htp.p('<script>setTimeout(function(){ ajustar('''||prm_objeto||''');}, 500);</script>');
	end if;

	if fun.getprop(prm_objeto, 'FILTRO') = 'COM CORTE' then
		ws_parametro := substr(prm_parametros, instr(prm_parametros, '##')+2, 999);
	end if;

	if fun.getprop(prm_objeto, 'FILTRO') = 'PASSIVO' or prm_drill = 'C' then

		if instr(nvl(prm_parametros,'N/A'), '##') = 0 then -- Não tem parametros de objetos anteriores 
			ws_parametro := prm_parametros;
		else 
			-- Retira dos parametros dos objetos anteriores se o campo estiver no parametro do objeto atual que chamou a Drill
			ws_param_ant := trim(substr(prm_parametros, 1, instr(prm_parametros, '##')-1));
			ws_param_atu := trim(substr(prm_parametros, instr(prm_parametros, '##')+2, 99999));
			ws_param_aux := '|'||ws_param_ant||'|';  -- Adiona PIPE para facilitar a extração das colunas duplicadas

			for a in (select cd_coluna, cd_conteudo from table(fun.vpipe_par(ws_param_ant)) ) loop 
				select count(*) into ws_count 
				  from table(fun.vpipe_par(ws_param_atu)) t2
				 where t2.cd_coluna = a.cd_coluna;  

				if ws_count > 0 then 
					ws_pos_i := instr(ws_param_aux,'|'||a.cd_coluna||'|');
					ws_pos_f := instr(ws_param_aux,'|',ws_pos_i+1,2);
					if ws_pos_i > 0 then 
						ws_param_dup := substr(ws_param_aux, ws_pos_i, (ws_pos_f - ws_pos_i + 1) ); 
						ws_param_aux := replace(ws_param_aux, ws_param_dup,'|'); 
					end if; 

				end if; 	


			end loop; 	

			-- Retira os PIPE adicionados no inicio e no fim dos parametros anteriores 
			ws_param_aux := trim(ws_param_aux);
			if substr(ws_param_aux,1,1) = '|'                    then  ws_pos_i := 2;                        else  ws_pos_i := 1;  end if; 
			if substr(ws_param_aux,length(ws_param_aux),1) = '|' then  ws_pos_f := length(ws_param_aux)-1;   else  ws_pos_f := length(ws_param_aux);  end if; 	
			ws_param_aux := trim(substr(ws_param_aux, ws_pos_i, (ws_pos_f-ws_pos_i+1) ) ); 

			if ws_param_aux is null then 
				ws_parametro := ws_param_atu;
			else 	
				ws_parametro := ws_param_aux||'|'||ws_param_atu;
			end if; 	

		end if; 	

	end if;


	if instr(nvl(prm_objeto,' '),'SECTION') = 0 then

		if nvl(fun.CHECK_PERMISSAO(prm_objeto),'S') = 'S' or prm_drill = 'C' then

			if prm_drill = 'C' and instr(prm_objeto,'nova_custom=') > 0  then -- Se é customizada e ainda não tem objeto criado 
                ws_cd_objeto := fun.objCode('COBJ_');
				ws_nm_objeto := 'CUSTOM';
				ws_tp_objeto := 'CONSULTA';
				ws_cd_usuario := ws_usuario;
				
				ws_obj            := trim(ws_cd_objeto);
			    ws_tip            := trim(ws_tp_objeto);
				ws_cd_micro_visao := replace(prm_objeto,'nova_custom=',''); 

		    else
				select cd_objeto, 	 nm_objeto,    tp_objeto,    cd_usuario,    atributos,    ds_objeto  
				  into ws_cd_objeto, ws_nm_objeto, ws_tp_objeto, ws_cd_usuario, ws_atributos, ws_ds_objeto
				  from OBJETOS
				 where cd_objeto=prm_objeto;

				ws_obj := trim(prm_objeto);
			    ws_tip := trim(ws_tp_objeto);
				select max(cd_micro_visao) into ws_cd_micro_visao from PONTO_AVALIACAO where cd_ponto = prm_objeto;
			end if;

            if prm_drill = 'C' then
				htp.p('<script>setTimeout(function(){ topDistance('''||ws_obj||'''); }, 5000);</script>');
			end if;

			ws_posx   := prm_posx;
			ws_posy   := prm_posy;
			ws_zindex := prm_zindex;
			if  length(trim(ws_zindex)) = 0 then
				ws_zindex := '2';
			end if;

			if nvl(prm_posx,'NOLOC') = 'NOLOC' then
				if prm_drill = 'O' then
					ws_posx := '0';
				else
					ws_posx := '200px';
				end if;
			end if;

			begin
				if prm_dashboard <> 'false' then
					ws_order := 'order: '||ws_posx||';';
				else
					ws_order := 'left: '||(to_number(replace(lower(ws_posx), 'px', ''))+28)||'px';
				end if;
			exception when others then
				ws_order := '';
			end;

			if ws_tp_objeto = 'TEXTO' and ws_admin <> 'A' then
				ws_posy := (to_number(replace(lower(ws_posy), 'px', ''))+28)||'px';
			end if;

			if nvl(prm_posy,'NOLOC') = 'NOLOC' then
				if prm_drill = 'O' then
					ws_posy := '0';
				else
					ws_posy := '200px';
				end if;
			end if;

			select nm_objeto, subtitulo into ws_gdescricao, ws_subtitulo
			  from OBJETOS
			 where cd_objeto=ws_obj;

			if prm_drill = 'Y' then
			    ws_class := ' drill';
			end if;
			
			if ws_tp_objeto = 'MAPA' then
			    ws_class := ' mapa';
			end if;

			if prm_track = 'INSIDE' then

				select cd_ponto, nm_ponto, ds_ponto, tp_renovacao, cd_micro_visao, parametros, vl_salvo, cs_parametros, cs_coluna, cs_agrupador, cs_rp, cs_colup into
					   ws_cd_ponto, ws_nm_ponto, ws_ds_ponto, ws_tp_renovacao, ws_cd_micro_visao, ws_parametros, ws_vl_salvo, ws_cs_parametros, ws_cs_coluna, ws_cs_agrupador, ws_cs_rp, ws_cs_colup
				from   PONTO_AVALIACAO
				where  cd_ponto = prm_objeto;

				select count(*) into ws_count from table((fun.vpipe(ws_cs_coluna)));

				if ws_count > 1 then
					ws_count := 0;
					for i in (select column_value into ws_count from table((fun.vpipe(ws_cs_coluna)))) loop
						if ws_count = 0 then
							ws_cs_coluna := prm_drill||'|';
						else
							ws_cs_coluna := ws_cs_coluna||i.column_value||'|';
						end if;
						ws_count := ws_count+1;
					end loop;
				else
					ws_cs_coluna := prm_drill;
				end if;

				ws_parametrosr := ws_parametro;

				if fun.setem(ws_cs_parametros,'|') and nvl(trim(ws_parametrosr),'%$%')<>'%$%' then
					ws_cs_parametros := ws_cs_parametros||ws_parametrosr;
				else
					ws_cs_parametros := ws_parametrosr;
				end if;

				-- upquery.subquery (prm_objeto, ws_cs_parametros, rtrim(ws_cd_micro_visao), ws_cs_coluna, ws_cs_agrupador, ws_cs_rp, ws_cs_colup, prm_screen, '', '', prm_objeton, prm_self);
                obj.subquery (prm_objeto, ws_cs_parametros, rtrim(ws_cd_micro_visao), ws_cs_coluna, ws_cs_agrupador, ws_cs_rp, ws_cs_colup, prm_screen, '', '', prm_objeton, prm_self,prm_usuario => ws_usuario, prm_cd_goto => prm_cd_goto, prm_popup_drill => prm_popup_drill);

			else

				if prm_drill <> 'C' then 
					ws_posicao := ' position: absolute; top:'||ws_posy||'; '||ws_order||'';
				end if;	

				if nvl(fun.getprop(ws_obj,'DEGRADE_TIPO'), '%??%') = '%??%' then
			    	ws_gradiente_tipo := 'linear';
				else
			    	ws_gradiente_tipo := fun.getprop(ws_obj,'DEGRADE_TIPO');
				end if;
 
				if prm_dashboard <> 'false' and prm_drill <> 'C' then
	            	ws_posicao := ws_posicao||' margin-top: '||fun.getprop(prm_objeto,'DASH_MARGIN_TOP',   prm_screen)||';'; 
					ws_posicao := ws_posicao||' margin-right: '||fun.getprop(prm_objeto,'DASH_MARGIN_RIGHT', prm_screen)||';';
					ws_posicao := ws_posicao||' margin-bottom: '||fun.getprop(prm_objeto,'DASH_MARGIN_BOT',   prm_screen)||';';
					ws_posicao := ws_posicao||' margin-left: '||fun.getprop(prm_objeto,'DASH_MARGIN_LEFT',  prm_screen)||';';
					ws_posicao := ws_posicao||' max-width: calc(100% - '||fun.getprop(prm_objeto,'DASH_MARGIN_LEFT', prm_screen)||' - '||fun.getprop(prm_objeto,'DASH_MARGIN_RIGHT', prm_screen)||');';
				end if;

            	/*1 ok, 2 criado generico, 0 não tem ponto avaliação*/
				begin
					if ws_tp_objeto not in ('IMAGE', 'ICONE', 'TEXTO', 'CALL_LIST', 'FLOAT_FILTER', 'FLOAT_PAR', 'MAPAGEOLOC', 'FILE', 'BROWSER', 'SPV', 'MARQUEE', 'SCRIPT', 'OBJETO', 'RELATORIO') then
					
							select count(*) into ws_situacao from PONTO_AVALIACAO where cd_ponto = prm_objeto;
							select cd_ponto, nm_ponto, ds_ponto, tp_renovacao, cd_micro_visao, parametros, vl_salvo, cs_parametros, cs_coluna, cs_agrupador, cs_rp, cs_colup 
							  into ws_cd_ponto, ws_nm_ponto, ws_ds_ponto, ws_tp_renovacao, ws_cd_micro_visao, ws_parametros, ws_vl_salvo, ws_cs_parametros, ws_cs_coluna, ws_cs_agrupador, ws_cs_rp, ws_cs_colup
							  from PONTO_AVALIACAO
							 where cd_ponto = prm_objeto;
							

							if ws_tp_objeto = 'VALOR' then
								if nvl(trim(ws_parametros),'N/A') = 'N/A' then
									ws_situacao :=2;
								end if;
							else
								if nvl(trim(ws_cs_coluna), 'N/A') = 'N/A' then
									ws_situacao := 2;
								end if;

								if nvl(trim(ws_cd_micro_visao), 'N/A') = 'N/A' then
									ws_situacao := 2;
								end if;

								if nvl(trim(ws_cs_agrupador), 'N/A') = 'N/A' then
									ws_situacao := 2;
								end if;
							end if;

							ws_parametros := ws_parametro||ws_parametros;
					else
						if ws_tp_objeto = 'OBJETO' then
							ws_situacao := 2;
						else
							ws_situacao := 1;
						end if;
					end if;
	
				exception when others then
	            	ws_situacao := 2;
				end;

				if ws_situacao = 0 then
					if ws_admin = 'A' then
						htp.p('<div title="'||fun.lang('clique para remover')||'" style="cursor: pointer; position: absolute; background: #CC0000; color: #FFF; font-weight: bold; text-align: center; padding: 5px; border-radius: 5px; border: 1px solid #000;" onclick="if(document.getElementById('''||prm_objeto||''')){ document.getElementById('''||prm_objeto||''').style.display=''none''; } else { this.style.display = ''none''; } ajax(''fly'', ''remove_location'', ''prm_obj='||prm_objeto||'&prm_screen=''+document.getElementById(''current_screen'').value, false); noerror('''', '''||fun.lang('Objeto removido com sucesso!')||''', ''feed-fixo'');">'||fun.lang('Erro ao carregar o PA do objeto')||' '||prm_objeto||'</div>');
					else
						htp.p('<div title="'||fun.lang('clique para remover')||'" style="cursor: pointer; position: absolute; background: #CC0000; color: #FFF; font-weight: bold; text-align: center; padding: 5px; border-radius: 5px; border: 1px solid #000;">'||fun.lang('Erro ao carregar o PA do objeto')||' '||prm_objeto||'</div>');
					end if;
				else
					case
				    when ws_tp_objeto = 'CONSULTA' and ws_situacao <> 2 and nvl(ws_nm_objeto, 'N/A') <> 'N/A' then

						ws_parametrosr := ws_parametro;

						if fun.setem(ws_cs_parametros,'|') and nvl(trim(ws_parametrosr),'%$%')<>'%$%' then
							ws_cs_parametros := ws_cs_parametros||ws_parametrosr;
						else
							ws_cs_parametros := ws_parametrosr;
						end if;

						if prm_alt_med <> 'no_change' then
							ws_cs_agrupador := prm_alt_med;
						end if;

						select count(*) into ws_count from table(fun.vpipe_par(ws_cs_coluna));

						if fun.put_par(prm_objeto, 'CROSS', 'CONSULTA') = 'S' and ws_count = 0 and nvl(trim(ws_cs_colup), 'null') = 'null' then
							if prm_cross = 'N' then
							   obj.consulta(ws_cs_parametros, trim(ws_cd_micro_visao), ws_cs_coluna, ws_cs_agrupador, ws_cs_rp, ws_cs_colup, '', '', RTRIM(ws_cd_objeto), prm_screen => prm_screen, prm_posx => prm_posx, prm_posy => prm_posy, prm_drill=> prm_drill, prm_zindex => prm_zindex, prm_track => prm_track, prm_objeton => prm_objeton, prm_self => prm_self, prm_dashboard => prm_dashboard, prm_propagation => ws_propagation, prm_usuario => ws_usuario, prm_cd_goto => prm_cd_goto);
							else
							   obj.consultaInvertida(ws_cs_parametros, trim(ws_cd_micro_visao), ws_cs_coluna, ws_cs_agrupador, ws_cs_rp, ws_cs_colup, '', '', RTRIM(ws_cd_objeto), prm_screen => prm_screen, prm_posx => prm_posx, prm_posy => prm_posy, prm_drill=> prm_drill, prm_zindex => prm_zindex, prm_track => prm_track, prm_objeton => prm_objeton, prm_dashboard => prm_dashboard,prm_usuario => ws_usuario, prm_cd_goto => prm_cd_goto );
							end if;
						else
							if prm_cross = 'S' then
								obj.consultaInvertida(ws_cs_parametros, trim(ws_cd_micro_visao), ws_cs_coluna, ws_cs_agrupador, ws_cs_rp, ws_cs_colup, '', '', RTRIM(ws_cd_objeto), prm_screen => prm_screen, prm_posx => prm_posx, prm_posy => prm_posy, prm_drill=> prm_drill, prm_zindex => prm_zindex, prm_track => prm_track, prm_objeton => prm_objeton, prm_dashboard => prm_dashboard,prm_usuario => ws_usuario, prm_cd_goto => prm_cd_goto );
							else
							    obj.consulta(ws_cs_parametros, trim(ws_cd_micro_visao), ws_cs_coluna, ws_cs_agrupador, ws_cs_rp, ws_cs_colup, '', '', RTRIM(ws_cd_objeto), prm_screen => prm_screen, prm_posx => prm_posx, prm_posy => prm_posy, prm_drill=> prm_drill, prm_zindex => prm_zindex, prm_track => prm_track, prm_objeton => prm_objeton, prm_self => prm_self, prm_dashboard => prm_dashboard, prm_propagation => ws_propagation,prm_usuario => ws_usuario, prm_cd_goto => prm_cd_goto);
							end if;
						end if;

				    when ws_tp_objeto = 'CALL_LIST' then
				        
						obj.menu(ws_obj, prm_screen, ws_posicao, ws_posy, ws_posx);

				    when ws_tp_objeto = 'FLOAT_PAR' then
					    
				        obj.float_par(ws_obj);

				    when ws_tp_objeto = 'FLOAT_FILTER' then
					    
						obj.float_filter(ws_obj);


					-- Tempo de query (banco)
					-- 0.0000580   				---> 5seg
					-- 0.000115741 				---> 10seg
					-- 0.00023148148148148146	---> 20seg
				    when ws_tp_objeto = 'VALOR' and ws_situacao <> 2 /*and nvl(ws_nm_objeto, 'N/A') <> 'N/A'*/ then


						obj.valor(ws_obj, prm_drill, ws_gdescricao, ws_cd_micro_visao, ws_parametros, ws_propagation, prm_screen, ws_posx, ws_posy, ws_posicao, ws_usuario, prm_track => prm_track, prm_cd_goto => prm_cd_goto);
									
						if fun.getprop(prm_objeto, 'QUERY_STAT') = 'S' or (sysdate > ws_tempo+(0.0000580)) then
							insert into QUERY_STAT values(ws_usuario, sysdate, prm_objeto, ws_cd_micro_visao, '', substr(ws_parametros, 1 ,instr(ws_parametros,'|')-1), '', '', '', '', round(((sysdate-ws_tempo)*1440)*60));
						end if;

					when ws_tp_objeto = 'PONTEIRO' then

					    begin
							obj.ponteiro(prm_objeto, prm_drill, ws_gdescricao, ws_cd_micro_visao, nvl(ws_parametros, ws_cs_agrupador||'|'), ws_propagation, prm_screen, ws_posx, ws_posy, ws_posicao,prm_usuario => ws_usuario, prm_track => prm_track, prm_cd_goto => prm_cd_goto);
						end;

						if fun.getprop(prm_objeto, 'QUERY_STAT') = 'S' or (sysdate > ws_tempo+(0.0000580)) then
							insert into QUERY_STAT values(ws_usuario, sysdate, prm_objeto, ws_cd_micro_visao, '', substr(ws_parametros, 1 ,instr(ws_parametros,'|')-1), '', '', '', '', round(((sysdate-ws_tempo)*1440)*60));
						end if;

				    when ws_tp_objeto in ('LINHAS','BARRAS', 'COLUNAS', 'PIZZA', 'ROSCA', 'MAPA','SANKEY', 'SCATTER', 'RADAR', 'CALENDARIO') and ws_situacao <> 2 and nvl(ws_nm_objeto, 'N/A') <> 'N/A' then
						
						obj.grafico(prm_objeto, prm_drill, ws_gdescricao, ws_cd_micro_visao, ws_parametros, ws_propagation, prm_screen, ws_posx, ws_posy, ws_posicao, prm_dashboard,prm_usuario => ws_usuario, prm_cd_goto => prm_cd_goto);
						
						if fun.getprop(prm_objeto, 'QUERY_STAT') = 'S' or (sysdate > ws_tempo+(0.0000580)) then
							insert into QUERY_STAT values(ws_usuario, sysdate, prm_objeto, ws_cd_micro_visao, '', substr(ws_parametros, 1 ,instr(ws_parametros,'|')-1), '', '', '', '', round(((sysdate-ws_tempo)*1440)*60));
						end if;

				    when ws_tp_objeto = 'OBJETO' or ws_situacao = 2 or nvl(ws_nm_objeto, 'N/A') = 'N/A' and ws_tp_objeto not in ('IMAGE','MAPAGEOLOC') then

						if ws_admin = 'A' or prm_screen = 'SCR_CUSTOMIZACAO'then
							select decode(tp_objeto, 'OBJETO', 'BARRAS', tp_objeto) into ws_tipo from OBJETOS where cd_objeto = prm_objeto/* and cd_usuario='DWU'*/;

							if substr(trim(fun.put_style(ws_obj, 'DEGRADE', ws_tip)), 5, 1) = 'S' then
								if nvl(fun.getprop(ws_obj,'DEGRADE_TIPO'), '%??%') = '%??%' then
									ws_gradiente_tipo := 'linear';
								else
									ws_gradiente_tipo := fun.getprop(ws_obj,'DEGRADE_TIPO');
								end if;
								ws_gradiente := 'background: '||ws_gradiente_tipo||'-gradient('||substr(fun.put_style(ws_obj, 'TIT_BGCOLOR', ws_tip), 18, 7)||', '||substr(fun.put_style(ws_obj, 'BGCOLOR', ws_tip), 18, 7)||');';
							else
								ws_gradiente := fun.put_style(ws_obj, 'BGCOLOR', ws_tip);
							end if;

							ws_objid := prm_objeto;

							select count(*) into ws_count from goto_objeto where cd_objeto = prm_objeto;

							ws_goto := '';

							htp.p('<div class="dragme generico'||ws_class||'" onclick="if(objatual != this.id){ objatual = this.id; }" id="'||ws_objid||'" onmousedown="'||ws_propagation||'" ontouchstart="swipeStart('''||ws_obj||''', event);" ontouchmove="swipe('''||ws_obj||''', event);" ontouchend="swipe('''||ws_obj||''', event);" style="'||ws_gradiente||' border-color: 1px solid #999; '||ws_posicao||';">');

							if fun.getprop(prm_objeto,'NO_RADIUS') <> 'N' then
								htp.p('<style>div#'||prm_objeto||', div#'||prm_objeto||'_ds { border-radius: 0; } div#'||prm_objeto||' span#'||prm_objeto||'more { border-radius: 0 0 6px 0; } a#'||prm_objeto||'fechar { border-radius: 0 0 0 6px; }</style>');
							end if;

							obj.opcoes(ws_objid, 'GENERICO', '', '', prm_screen, '', '', '', prm_usuario => ws_usuario);
							
							ws_posicao := 'width: 400px;';
							
							if ws_situacao <> 2 then -- Objeto ainda generico não gerar dados_
								htp.p('<div data-tipoobj="'||ws_tp_objeto||'" id="dados_'||trim(ws_objid)||'" data-heatmap="'||fun.getprop(prm_objeto, 'HEATMAP')||'" data-funil-sort="'||fun.getprop(prm_objeto, 'FUNIL_SORT')||'" data-funil="'||fun.getprop(prm_objeto, 'FUNIL')||'"  data-ccoluna-hex="'||fun.getprop(prm_objeto, 'COR-COLUNA-HEX')||'" data-maximo="'||fun.XFORMULA(fun.getprop(prm_objeto, 'MAXIMO'), prm_screen)||'" data-dashboard="'||prm_dashboard||'" data-filtro="'||ws_filtro||'" data-drill="'||ws_goto||'" data-sec="'||fun.check_rotuloc(fun.getprop(prm_objeto, 'SEC'), ws_cd_micro_visao)||'" data-coluna="'||fun.check_rotuloc(ws_coluna, ws_cd_micro_visao)||'" data-colunareal="'||ws_coluna||'" data-agrupadoresreal="'||ws_agrupador||'" data-agrupadores="'||fun.check_rotuloc(ws_agrupador, ws_cd_micro_visao)||'"  data-refresh="8000" data-tipo="'||ws_tipo||'" data-top="'||ws_posy||'" data-left="'||ws_posx||'" data-swipe="" data-cd_goto="'||prm_cd_goto||'" style="display: none;"></div>');
							end if; 

							if substr(trim(fun.put_style(ws_obj, 'DEGRADE', ws_tipo)), 5, 1) = 'S' then
								ws_gradiente := '';
							else
								ws_gradiente := fun.put_style(ws_obj, 'TIT_BGCOLOR', ws_tipo);
							end if;

							ws_alinhamento_tit := fun.getprop(prm_objeto,'ALIGN_TIT');
							if ws_alinhamento_tit = 'left' then
								ws_alinhamento_tit := ws_alinhamento_tit||'; text-indent: 14px';
							end if;
							
							begin
								select CONTEUDO into ws_padrao
								from   PARAMETRO_USUARIO
								where  cd_usuario = ws_usuario and
									cd_padrao='CD_LINGUAGEM';
							exception
								when others then
									ws_padrao := 'PORTUGUESE';
							end;
							
							if ws_admin = 'A' and prm_screen <> 'SCR_CUSTOMIZACAO' then
								htp.p('<div data-touch="0" class="wd_move" title="'||fun.lang('Clique e arraste para mover, duplo clique para ampliar')||'" style="text-align: '||ws_alinhamento_tit||'; '||fun.put_style(ws_obj, 'TIT_COLOR', ws_tipo)||ws_gradiente||fun.put_style(ws_obj, 'TIT_IT', ws_tipo)||fun.put_style(ws_obj, 'TIT_BOLD', ws_tipo)||fun.put_style(ws_obj, 'TIT_FONT', ws_tipo)||fun.put_style(ws_obj, 'TIT_SIZE', ws_tipo)||'" id="'||prm_objeto||'_ds">'||nvl(fun.subpar(fun.utranslate('NM_OBJETO', prm_objeto, ws_gdescricao, ws_padrao), prm_screen), 'OBJETO')||'</div>');
							else
								htp.p('<div data-touch="0" style="padding: 5px; border-radius: 7px 7px 0 0; cursor: default; text-align: '||ws_alinhamento_tit||'; '||fun.put_style(ws_obj, 'TIT_COLOR', ws_tipo)||ws_gradiente||fun.put_style(ws_obj, 'TIT_IT', ws_tipo)||fun.put_style(ws_obj, 'TIT_BOLD', ws_tipo)||fun.put_style(ws_obj, 'TIT_FONT', ws_tipo)||fun.put_style(ws_obj, 'TIT_SIZE', ws_tipo)||'" id="'||prm_objeto||'_ds">'||nvl(fun.subpar(fun.utranslate('NM_OBJETO', prm_objeto, ws_gdescricao, ws_padrao), prm_screen), 'OBJETO')||'</div>');
							end if;

							htp.p('<div class="sub" id="'||prm_objeto||'_sub" style="text-align: '||ws_alinhamento_tit||'; '||fun.put_style(ws_obj, 'TIT_COLOR', ws_tipo)||';">'||fun.subpar(fun.utranslate('NM_OBJETO', ws_obj, ws_subtitulo, ws_padrao), prm_screen)||'</div>');

							if ws_tp_objeto = 'OBJETO' then

								if prm_screen = 'SCR_CUSTOMIZACAO' then 
									htp.p('<ul class="queryadd" title="'||ws_tp_objeto||'" style="display: block;">');   
										htp.p('<li title="'||fun.lang('CONSULTA')||'" onclick="snackObject(this, '''||prm_objeto||''', ''consulta'', '''', '''');">');
											htp.p('<svg style="margin-top: 8px;" version="1.1"  xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"viewBox="0 0 502 502" style="enable-background:new 0 0 502 502;" xml:space="preserve"> <g> <g> <g> <path d="M492,56.375H10c-5.522,0-10,4.477-10,10v369.25c0,5.523,4.478,10,10,10h482c5.522,0,10-4.477,10-10V66.375 C502,60.852,497.522,56.375,492,56.375z M120.5,425.625H20v-53.896h100.5V425.625z M120.5,351.728H20v-53.896h100.5V351.728z M120.5,277.832H20v-53.896h100.5V277.832z M120.5,203.935H20v-53.664h100.5V203.935z M241,425.625H140.5v-53.896H241V425.625z M241,351.728H140.5v-53.896H241V351.728z M241,277.832H140.5v-53.896H241V277.832z M241,203.935H140.5v-53.664H241V203.935z M361.5,425.625H261v-53.896h100.5V425.625z M361.5,351.728H261v-53.896h100.5V351.728z M361.5,277.832H261v-53.896h100.5 V277.832z M361.5,203.935H261v-53.664h100.5V203.935z M482,425.625H381.5v-53.896H482V425.625z M482,351.728H381.5v-53.896H482 V351.728z M482,277.832H381.5v-53.896H482V277.832z M482,203.936H381.5v-53.664H482V203.936z M482,130.039H20V76.375h462V130.039 z"/> <path d="M209,107.625h192c5.522,0,10-4.477,10-10s-4.478-10-10-10H209c-5.522,0-10,4.477-10,10S203.478,107.625,209,107.625z"/> <path d="M436,107.625h22c5.522,0,10-4.477,10-10s-4.478-10-10-10h-22c-5.522,0-10,4.477-10,10S430.478,107.625,436,107.625z"/> </g> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
											htp.p('<span style="margin-top: -3px;">'||fun.lang('CONSULTA')||'</span>');
										htp.p('</li>');
									htp.p('</ul>');

								else 
								    htp.p('<ul class="queryadd" title="'||ws_tp_objeto||'">');   
										htp.p('<li title="'||fun.lang('GR&Aacute;FICO')||'" onclick="snackObject(this, '''||prm_objeto||''', ''grafico'', '''');">');
											htp.p('<svg style="" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"viewBox="0 0 480 480" style="enable-background:new 0 0 480 480;" xml:space="preserve"> <g> <g> <path d="M316.211,123.858l-69.281-120c-2.544-3.827-7.708-4.868-11.536-2.324c-0.921,0.612-1.711,1.402-2.324,2.324l-69.281,120 c-2.209,3.826-0.898,8.719,2.928,10.928c1.217,0.702,2.597,1.072,4.001,1.072h138.563c4.418,0.001,8.001-3.58,8.001-7.999 C317.283,126.455,316.913,125.074,316.211,123.858z M184.574,119.858l55.426-96l55.426,96H184.574z"/> </g> </g> <g> <g> <path d="M472.004,335.858c-0.001,0-0.003,0-0.004,0H344c-4.417-0.001-7.999,3.579-8,7.996c0,0.001,0,0.003,0,0.004v128 c-0.001,4.417,3.579,7.999,7.996,8c0.001,0,0.003,0,0.004,0h128c4.417,0.001,7.999-3.579,8-7.996c0-0.001,0-0.003,0-0.004v-128 C480.001,339.441,476.421,335.859,472.004,335.858z M464,463.858H352v-112h112V463.858z"/> </g> </g> <g> <g> <path d="M72,335.858c-39.765,0-72,32.235-72,72c0,39.764,32.235,72,72,72s72-32.236,72-72 C143.955,368.112,111.746,335.903,72,335.858z M72,463.858c-30.928,0-56-25.072-56-56c0-30.928,25.072-56,56-56 c30.928,0,56,25.072,56,56C127.964,438.771,102.913,463.822,72,463.858z"/> </g> </g> <g> <g> <path d="M163.336,88.538l-6.672-14.547C62.627,117.189,16.991,224.92,51.383,322.522l15.086-5.328 C34.834,227.396,76.822,128.284,163.336,88.538z"/> </g> </g> <g> <g> <path d="M309,426.491c-21.921,8.869-45.353,13.409-69,13.367c-25.347,0.054-50.427-5.166-73.648-15.328l-6.406,14.656 c49.31,21.464,105.173,22.233,155.055,2.133L309,426.491z"/> </g> </g> <g> <g> <path d="M336.908,80.869l0.002-0.003c-1.734-0.961-3.488-1.906-5.254-2.813l-7.312,14.234c1.609,0.828,3.204,1.682,4.785,2.562 l3.891-6.992l-3.883,6.992c58.511,32.463,94.824,94.095,94.863,161.008c0.015,18.185-2.664,36.272-7.949,53.672l15.305,4.656 C458.787,223.874,419.438,126.668,336.908,80.869z"/> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
											htp.p('<span>'||fun.lang('GR&Aacute;FICO')||'</span>');
										htp.p('</li>');
										htp.p('<li title="'||fun.lang('CONSULTA')||'" onclick="snackObject(this, '''||prm_objeto||''', ''consulta'', '''');">');
											htp.p('<svg style="margin-top: 8px;" version="1.1"  xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"viewBox="0 0 502 502" style="enable-background:new 0 0 502 502;" xml:space="preserve"> <g> <g> <g> <path d="M492,56.375H10c-5.522,0-10,4.477-10,10v369.25c0,5.523,4.478,10,10,10h482c5.522,0,10-4.477,10-10V66.375 C502,60.852,497.522,56.375,492,56.375z M120.5,425.625H20v-53.896h100.5V425.625z M120.5,351.728H20v-53.896h100.5V351.728z M120.5,277.832H20v-53.896h100.5V277.832z M120.5,203.935H20v-53.664h100.5V203.935z M241,425.625H140.5v-53.896H241V425.625z M241,351.728H140.5v-53.896H241V351.728z M241,277.832H140.5v-53.896H241V277.832z M241,203.935H140.5v-53.664H241V203.935z M361.5,425.625H261v-53.896h100.5V425.625z M361.5,351.728H261v-53.896h100.5V351.728z M361.5,277.832H261v-53.896h100.5 V277.832z M361.5,203.935H261v-53.664h100.5V203.935z M482,425.625H381.5v-53.896H482V425.625z M482,351.728H381.5v-53.896H482 V351.728z M482,277.832H381.5v-53.896H482V277.832z M482,203.936H381.5v-53.664H482V203.936z M482,130.039H20V76.375h462V130.039 z"/> <path d="M209,107.625h192c5.522,0,10-4.477,10-10s-4.478-10-10-10H209c-5.522,0-10,4.477-10,10S203.478,107.625,209,107.625z"/> <path d="M436,107.625h22c5.522,0,10-4.477,10-10s-4.478-10-10-10h-22c-5.522,0-10,4.477-10,10S430.478,107.625,436,107.625z"/> </g> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
											htp.p('<span style="margin-top: -3px;">'||fun.lang('CONSULTA')||'</span>');
										htp.p('</li>');
										htp.p('<li title="'||fun.lang('VALOR')||'"  onclick="snackObject(this, '''||prm_objeto||''', ''valor'', '''');">');
											htp.p('<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 512 512" style="enable-background:new 0 0 512 512;" xml:space="preserve"> <g> <g> <path d="M400.388,175.787c-1.707-3.413-4.267-5.12-7.68-5.12H292.015L391.855,12.8c1.707-2.56,1.707-5.973,0-8.533 S387.588,0,384.175,0H247.642c-3.413,0-5.973,1.707-7.68,4.267l-128,256c-1.707,2.56-1.707,5.973,0,8.533 c1.707,2.56,5.12,4.267,7.68,4.267h87.893l-95.573,227.84c-1.707,3.413,0,7.68,3.413,10.24c0.853,0.853,2.56,0.853,4.267,0.853 c2.56,0,5.12-0.853,6.827-2.56l273.067-324.267C401.242,182.613,402.095,179.2,400.388,175.787z M149.508,454.827l78.507-187.733 c0.853-2.56,0.853-5.12-0.853-7.68c-1.707-1.707-4.267-3.413-6.827-3.413h-87.04L252.762,17.067h116.053L268.122,174.933 c-1.707,2.56-1.707,5.973,0,8.533s4.267,4.267,7.68,4.267h98.987L149.508,454.827z"></path> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');										--htp.p('<svg viewBox="0 0 19 20" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M7.71183 11.8399V19.4743H0.0644531V11.8399H7.71183ZM8.66775 0.770142L13.8297 9.35879H3.3146L8.66775 0.770142ZM13.8297 11.2674C14.9768 11.2674 16.1239 11.6491 16.8887 12.6034C17.6534 13.5577 18.0358 14.512 18.0358 15.6571C18.0358 16.8023 17.6534 17.9474 16.8887 18.7109C16.1239 19.4743 14.9768 19.856 13.8297 19.856C12.6826 19.856 11.5355 19.4743 10.7708 18.7109C10.006 17.9474 9.62367 16.8023 9.62367 15.6571C9.62367 14.512 10.006 13.3668 10.7708 12.6034C11.5355 11.8399 12.6826 11.2674 13.8297 11.2674Z" fill="#191147"/></svg>');
											htp.p('<span>'||fun.lang('VALOR')||'</span>');
										htp.p('</li>');
									htp.p('</ul>');
								end if;	

							else 	

								ws_class_new_grafico  := 'removed';
								ws_class_new_consulta := 'removed';
								ws_class_new_valor    := 'removed';

								if ws_tp_objeto = 'CONSULTA' then
									ws_class_new_consulta := 'single';
								elsif ws_tp_objeto = 'VALOR' then
									ws_class_new_valor := 'single';
								else 
									ws_class_new_grafico := 'TIPO GRAFICO';
								end if;

								if ws_class_new_grafico <> 'TIPO GRAFICO' then 

									htp.p('<ul class="queryadd" title="'||ws_tp_objeto||'">'); 
										htp.p('<li class="'||ws_class_new_grafico||'" title="'||fun.lang('GR&Aacute;FICO')||'" onclick="loadAttrib(''ed_gadg'', ''ws_par_sumary='||prm_objeto||'&prm_tipo=grafico&prm_tipo_graf=''); this.classList.add(''single''); this.nextElementSibling.classList.add(''removed'');">');
											htp.p('<svg style="" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"viewBox="0 0 480 480" style="enable-background:new 0 0 480 480;" xml:space="preserve"> <g> <g> <path d="M316.211,123.858l-69.281-120c-2.544-3.827-7.708-4.868-11.536-2.324c-0.921,0.612-1.711,1.402-2.324,2.324l-69.281,120 c-2.209,3.826-0.898,8.719,2.928,10.928c1.217,0.702,2.597,1.072,4.001,1.072h138.563c4.418,0.001,8.001-3.58,8.001-7.999 C317.283,126.455,316.913,125.074,316.211,123.858z M184.574,119.858l55.426-96l55.426,96H184.574z"/> </g> </g> <g> <g> <path d="M472.004,335.858c-0.001,0-0.003,0-0.004,0H344c-4.417-0.001-7.999,3.579-8,7.996c0,0.001,0,0.003,0,0.004v128 c-0.001,4.417,3.579,7.999,7.996,8c0.001,0,0.003,0,0.004,0h128c4.417,0.001,7.999-3.579,8-7.996c0-0.001,0-0.003,0-0.004v-128 C480.001,339.441,476.421,335.859,472.004,335.858z M464,463.858H352v-112h112V463.858z"/> </g> </g> <g> <g> <path d="M72,335.858c-39.765,0-72,32.235-72,72c0,39.764,32.235,72,72,72s72-32.236,72-72 C143.955,368.112,111.746,335.903,72,335.858z M72,463.858c-30.928,0-56-25.072-56-56c0-30.928,25.072-56,56-56 c30.928,0,56,25.072,56,56C127.964,438.771,102.913,463.822,72,463.858z"/> </g> </g> <g> <g> <path d="M163.336,88.538l-6.672-14.547C62.627,117.189,16.991,224.92,51.383,322.522l15.086-5.328 C34.834,227.396,76.822,128.284,163.336,88.538z"/> </g> </g> <g> <g> <path d="M309,426.491c-21.921,8.869-45.353,13.409-69,13.367c-25.347,0.054-50.427-5.166-73.648-15.328l-6.406,14.656 c49.31,21.464,105.173,22.233,155.055,2.133L309,426.491z"/> </g> </g> <g> <g> <path d="M336.908,80.869l0.002-0.003c-1.734-0.961-3.488-1.906-5.254-2.813l-7.312,14.234c1.609,0.828,3.204,1.682,4.785,2.562 l3.891-6.992l-3.883,6.992c58.511,32.463,94.824,94.095,94.863,161.008c0.015,18.185-2.664,36.272-7.949,53.672l15.305,4.656 C458.787,223.874,419.438,126.668,336.908,80.869z"/> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
											htp.p('<span>'||fun.lang('GR&Aacute;FICO')||'</span>');
										htp.p('</li>');

										htp.p('<li class="'||ws_class_new_consulta||'" title="'||fun.lang('CONSULTA')||'" onclick="loadAttrib(''ed_gadg'', ''ws_par_sumary='||prm_objeto||'&prm_tipo=consulta&prm_tipo_graf=''); this.classList.add(''single''); this.previousElementSibling.classList.add(''removed'');">');
											htp.p('<svg style="margin-top: 8px;" version="1.1"  xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"viewBox="0 0 502 502" style="enable-background:new 0 0 502 502;" xml:space="preserve"> <g> <g> <g> <path d="M492,56.375H10c-5.522,0-10,4.477-10,10v369.25c0,5.523,4.478,10,10,10h482c5.522,0,10-4.477,10-10V66.375 C502,60.852,497.522,56.375,492,56.375z M120.5,425.625H20v-53.896h100.5V425.625z M120.5,351.728H20v-53.896h100.5V351.728z M120.5,277.832H20v-53.896h100.5V277.832z M120.5,203.935H20v-53.664h100.5V203.935z M241,425.625H140.5v-53.896H241V425.625z M241,351.728H140.5v-53.896H241V351.728z M241,277.832H140.5v-53.896H241V277.832z M241,203.935H140.5v-53.664H241V203.935z M361.5,425.625H261v-53.896h100.5V425.625z M361.5,351.728H261v-53.896h100.5V351.728z M361.5,277.832H261v-53.896h100.5 V277.832z M361.5,203.935H261v-53.664h100.5V203.935z M482,425.625H381.5v-53.896H482V425.625z M482,351.728H381.5v-53.896H482 V351.728z M482,277.832H381.5v-53.896H482V277.832z M482,203.936H381.5v-53.664H482V203.936z M482,130.039H20V76.375h462V130.039 z"/> <path d="M209,107.625h192c5.522,0,10-4.477,10-10s-4.478-10-10-10H209c-5.522,0-10,4.477-10,10S203.478,107.625,209,107.625z"/> <path d="M436,107.625h22c5.522,0,10-4.477,10-10s-4.478-10-10-10h-22c-5.522,0-10,4.477-10,10S430.478,107.625,436,107.625z"/> </g> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
											htp.p('<span style="margin-top: -3px;">'||fun.lang('CONSULTA')||'</span>');
										htp.p('</li>');

										htp.p('<li class="'||ws_class_new_valor||'" title="'||fun.lang('VALOR')||'" onclick="loadAttrib(''ed_gadg'', ''ws_par_sumary='||prm_objeto||'&prm_tipo=valor&prm_tipo_graf=''); this.classList.add(''single''); this.nextElementSibling.classList.add(''removed'');">');
											htp.p('<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 512 512" style="enable-background:new 0 0 512 512;" xml:space="preserve"> <g> <g> <path d="M400.388,175.787c-1.707-3.413-4.267-5.12-7.68-5.12H292.015L391.855,12.8c1.707-2.56,1.707-5.973,0-8.533 S387.588,0,384.175,0H247.642c-3.413,0-5.973,1.707-7.68,4.267l-128,256c-1.707,2.56-1.707,5.973,0,8.533 c1.707,2.56,5.12,4.267,7.68,4.267h87.893l-95.573,227.84c-1.707,3.413,0,7.68,3.413,10.24c0.853,0.853,2.56,0.853,4.267,0.853 c2.56,0,5.12-0.853,6.827-2.56l273.067-324.267C401.242,182.613,402.095,179.2,400.388,175.787z M149.508,454.827l78.507-187.733 c0.853-2.56,0.853-5.12-0.853-7.68c-1.707-1.707-4.267-3.413-6.827-3.413h-87.04L252.762,17.067h116.053L268.122,174.933 c-1.707,2.56-1.707,5.973,0,8.533s4.267,4.267,7.68,4.267h98.987L149.508,454.827z"></path> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');										--htp.p('<svg viewBox="0 0 19 20" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M7.71183 11.8399V19.4743H0.0644531V11.8399H7.71183ZM8.66775 0.770142L13.8297 9.35879H3.3146L8.66775 0.770142ZM13.8297 11.2674C14.9768 11.2674 16.1239 11.6491 16.8887 12.6034C17.6534 13.5577 18.0358 14.512 18.0358 15.6571C18.0358 16.8023 17.6534 17.9474 16.8887 18.7109C16.1239 19.4743 14.9768 19.856 13.8297 19.856C12.6826 19.856 11.5355 19.4743 10.7708 18.7109C10.006 17.9474 9.62367 16.8023 9.62367 15.6571C9.62367 14.512 10.006 13.3668 10.7708 12.6034C11.5355 11.8399 12.6826 11.2674 13.8297 11.2674Z" fill="#191147"/></svg>');
											htp.p('<span>'||fun.lang('VALOR')||'</span>');
										htp.p('</li>');
									htp.p('</ul>');

								else 
									if ws_tp_objeto = 'BARRAS'      then    ws_class_sel_barras     := ' selecionado ';     end if;
									if ws_tp_objeto = 'COLUNAS'     then    ws_class_sel_colunas    := ' selecionado ';     end if;
									if ws_tp_objeto = 'LINHAS'      then    ws_class_sel_linhas     := ' selecionado ';     end if;
									if ws_tp_objeto = 'PIZZA'       then    ws_class_sel_pizza      := ' selecionado ';     end if;
									if ws_tp_objeto = 'PONTEIRO'    then    ws_class_sel_ponteiro   := ' selecionado ';     end if;
									if ws_tp_objeto = 'MAPA'        then    ws_class_sel_mapa       := ' selecionado ';     end if;
									if ws_tp_objeto = 'MAPAGEOLOC'  then    ws_class_sel_mapageoloc := ' selecionado ';     end if;
									if ws_tp_objeto = 'SANKEY'      then    ws_class_sel_sankey     := ' selecionado ';     end if;
									if ws_tp_objeto = 'SCATTER'     then    ws_class_sel_scatter    := ' selecionado ';     end if;
									if ws_tp_objeto = 'RADAR'       then    ws_class_sel_radar      := ' selecionado ';     end if;
									if ws_tp_objeto = 'CALENDARIO'  then    ws_class_sel_calendario := ' selecionado ';     end if;
									htp.p('<ul class="queryadd-graph-group">'); 
										htp.p('<li>'); 
											htp.p('<ul class="queryadd-graph">'); 
												htp.p('<li class="amostragem-graficos" title="'||fun.lang('BARRAS')||'" onclick="loadAttrib(''ed_gadg'', ''ws_par_sumary='||prm_objeto||'&prm_tipo=grafico&prm_tipo_graf=BARRAS''); ClickIconGrap(this);">');
													htp.p('<svg class="icones-graficos '||ws_class_sel_barras||'" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 480 480" style="enable-background:new 0 0 480 480;" xml:space="preserve"> <g> <g> <path d="M448,352H40v-56h272c4.8,0,8-3.2,8-8v-96c0-4.8-3.2-8-8-8H40v-56h144c4.8,0,8-3.2,8-8V24c0-4.8-3.2-8-8-8H40V8 c0-4.8-3.2-8-8-8s-8,3.2-8,8v464c0,4.8,3.2,8,8,8s8-3.2,8-8v-8h408c4.8,0,8-3.2,8-8v-96C456,355.2,452.8,352,448,352z M40,32h136 v80H40V32z M40,200h264v80H40V200z M440,448H40v-80h400V448z"/> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
													htp.p('<span id="icon-label">'||fun.lang('BARRAS')||'</span>');
												htp.p('</li>');											
													
												htp.p('<li class="amostragem-graficos" title="'||fun.lang('COLUNA')||'" onclick="loadAttrib(''ed_gadg'', ''ws_par_sumary='||prm_objeto||'&prm_tipo=grafico&prm_tipo_graf=COLUNAS''); ClickIconGrap(this);">');
													htp.p('<svg class="icones-graficos '||ws_class_sel_colunas||'" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 480 480" style="enable-background:new 0 0 480 480;" xml:space="preserve"> <g> <g> <g> <rect y="464" width="480" height="16"/> <path d="M32,448h80c4.418,0,8-3.582,8-8V296c0-4.418-3.582-8-8-8H32c-4.418,0-8,3.582-8,8v144C24,444.418,27.582,448,32,448z M40,304h64v128H40V304z"/> <path d="M256,448h80c4.418,0,8-3.582,8-8V200c0-4.418-3.582-8-8-8h-80c-4.418,0-8,3.582-8,8v240C248,444.418,251.582,448,256,448 z M264,208h64v224h-64V208z"/> <path d="M144,448h80c4.418,0,8-3.582,8-8V104c0-4.418-3.582-8-8-8h-80c-4.418,0-8,3.582-8,8v336C136,444.418,139.582,448,144,448 z M152,112h64v320h-64V112z"/> <path d="M368,448h80c4.418,0,8-3.582,8-8V8c0-4.418-3.582-8-8-8h-80c-4.418,0-8,3.582-8,8v432C360,444.418,363.582,448,368,448z M376,16h64v416h-64V16z"/> </g> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
													htp.p('<span id="icon-label">'||fun.lang('COLUNA')||'</span>');
												htp.p('</li>');	

												htp.p('<li class="amostragem-graficos" title="'||fun.lang('LINHAS')||'" onclick="loadAttrib(''ed_gadg'', ''ws_par_sumary='||prm_objeto||'&prm_tipo=grafico&prm_tipo_graf=LINHAS''); ClickIconGrap(this);">');
													htp.p('<svg class="icones-graficos '||ws_class_sel_linhas||'" height="512" viewBox="0 0 74 74" width="512" xmlns="http://www.w3.org/2000/svg"><path d="m47.24 67h-2.97a1 1 0 0 1 0-2h2.97a1 1 0 1 1 0 2z"/><path d="m27.37 67h-24.37a1 1 0 0 1 0-2h24.37a1 1 0 1 1 0 2z"/><path d="m37.27 67h-2.9a1 1 0 0 1 0-2h2.9a1 1 0 1 1 0 2z"/><path d="m71 67h-16.76a1 1 0 0 1 0-2h15.76v-26a1 1 0 0 1 2 0v27a1 1 0 0 1 -1 1z"/><path d="m8 42a1 1 0 0 1 -.707-1.707l19.5-19.5a1 1 0 0 1 1.415 0l18.242 18.242 12.8-14.692a.959.959 0 0 1 .776-.343 1 1 0 0 1 .761.382l11 14a1 1 0 0 1 -1.573 1.236l-10.253-13.05-12.707 14.589a1 1 0 0 1 -.719.343 1.011 1.011 0 0 1 -.742-.293l-18.293-18.293-18.792 18.793a1 1 0 0 1 -.708.293z"/><path d="m8 59.75a1 1 0 0 1 -.707-1.707l19.5-19.5a1 1 0 0 1 1.415 0l18.242 18.242 12.8-14.692a.989.989 0 0 1 .779-.343 1 1 0 0 1 .761.382l11 14a1 1 0 0 1 -1.573 1.236l-10.256-13.05-12.707 14.589a1 1 0 0 1 -1.461.05l-18.293-18.293-18.792 18.793a1 1 0 0 1 -.708.293z"/><path d="m8 72a1 1 0 0 1 -1-1v-68a1 1 0 0 1 2 0v68a1 1 0 0 1 -1 1z"/></svg>');
													htp.p('<span id="icon-label">'||fun.lang('LINHAS')||'</span>');
												htp.p('</li>');
												
												htp.p('<li class="amostragem-graficos" title="'||fun.lang('PIZZA')||'" onclick="loadAttrib(''ed_gadg'', ''ws_par_sumary='||prm_objeto||'&prm_tipo=grafico&prm_tipo_graf=PIZZA''); ClickIconGrap(this);">');
													htp.p('<svg class="icones-graficos '||ws_class_sel_pizza||'" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 512 512" style="enable-background:new 0 0 512 512;" xml:space="preserve"> <g> <g> <g> <path d="M234.667,263.019V32c0-5.888-4.779-10.667-10.667-10.667c-123.52,0-224,110.059-224,245.333S110.059,512,245.333,512 c60.523,0,93.269-10.965,134.784-45.099c4.459-3.669,5.184-10.219,1.643-14.784L234.667,263.019z M245.333,490.667 c-123.52,0-224-100.48-224-224c0-119.552,85.184-217.536,192-223.701v223.701c0,2.368,0.789,4.672,2.261,6.549l142.848,183.659 C324.757,482.603,296.661,490.667,245.333,490.667z"/> <path d="M266.667,256h234.667c5.888,0,10.667-4.779,10.667-10.667C512,110.059,401.941,0,266.667,0 C260.779,0,256,4.779,256,10.667v234.667C256,251.221,260.779,256,266.667,256z M277.333,21.589 c115.051,5.419,207.659,98.027,213.077,213.077H277.333V21.589z"/> <path d="M501.333,277.333H288c-4.096,0-7.872,2.368-9.643,6.08c-1.771,3.712-1.237,8.107,1.344,11.285l138.667,171.669 c1.856,2.325,4.587,3.733,7.552,3.947c0.256,0.021,0.491,0.021,0.747,0.021c2.688,0,5.291-1.024,7.275-2.859 C483.541,421.205,512,355.797,512,288C512,282.112,507.221,277.333,501.333,277.333z M427.584,443.819L310.336,298.667h180.075 C487.787,352.896,465.344,404.757,427.584,443.819z"/> </g> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
													htp.p('<span id="icon-label">'||fun.lang('PIZZA')||'</span>');
												htp.p('</li>');

												htp.p('<li class="amostragem-graficos" title="'||fun.lang('PONTEIRO')||'" onclick="loadAttrib(''ed_gadg'', ''ws_par_sumary='||prm_objeto||'&prm_tipo=grafico&prm_tipo_graf=PONTEIRO''); ClickIconGrap(this);">');
													htp.p('<svg class="icones-graficos '||ws_class_sel_ponteiro||'" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 512 512" style="enable-background:new 0 0 512 512;" xml:space="preserve"> <g> <g> <g> <path d="M366.292,215.99L241.417,325.781c-0.167,0.146-0.333,0.292-0.479,0.448c-4.042,4.021-6.271,9.385-6.271,15.104 c0,11.76,9.563,21.333,21.333,21.333c5.667,0,11.021-2.208,15.563-6.75l109.792-124.875c3.708-4.219,3.5-10.604-0.479-14.583 C376.896,212.49,370.542,212.281,366.292,215.99z"/> <path d="M256,85.333c-141.167,0-256,114.844-256,256c0,26.479,4.104,52.688,12.167,77.917c1.417,4.417,5.521,7.417,10.167,7.417 h467.333c4.646,0,8.75-3,10.167-7.417C507.896,394.021,512,367.813,512,341.333C512,200.177,397.167,85.333,256,85.333z M458.667,352h31.26c-0.824,18.04-3.237,35.947-8.177,53.333H30.25c-4.94-17.387-7.353-35.293-8.177-53.333h31.26 C59.229,352,64,347.229,64,341.333c0-5.896-4.771-10.667-10.667-10.667h-31.46c1.581-34.919,10.68-67.865,25.948-97.208 l27.324,15.781c1.688,0.969,3.521,1.427,5.333,1.427c3.667,0,7.271-1.906,9.229-5.333c2.958-5.104,1.208-11.625-3.896-14.573 l-27.263-15.746c18.323-28.539,42.602-52.816,71.142-71.138l15.746,27.28c1.958,3.417,5.563,5.333,9.229,5.333 c1.813,0,3.646-0.458,5.333-1.427c5.104-2.948,6.854-9.469,3.896-14.573l-15.777-27.332c29.345-15.27,62.293-24.37,97.215-25.951 v31.46c0,5.896,4.771,10.667,10.667,10.667s10.667-4.771,10.667-10.667v-31.46c34.922,1.581,67.87,10.681,97.215,25.951 l-15.777,27.332c-2.958,5.104-1.208,11.625,3.896,14.573c1.688,0.969,3.521,1.427,5.333,1.427c3.667,0,7.271-1.917,9.229-5.333 l15.746-27.28c28.54,18.322,52.819,42.599,71.142,71.138l-27.263,15.746c-5.104,2.948-6.854,9.469-3.896,14.573 c1.958,3.427,5.563,5.333,9.229,5.333c1.812,0,3.646-0.458,5.333-1.427l27.324-15.781c15.268,29.344,24.367,62.289,25.948,97.208 h-31.46c-5.896,0-10.667,4.771-10.667,10.667C448,347.229,452.771,352,458.667,352z"/> </g> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
													htp.p('<span id="icon-label">'||fun.lang('PONTEIRO')||'</span>');
												htp.p('</li>');
											htp.p('</ul>'); 
										htp.p('</li>'); 
										htp.p('<li>'); 
											htp.p('<ul class="queryadd-graph">'); 
												htp.p('<li class="amostragem-graficos" title="'||fun.lang('MAPA GEOGRAFICO')||'" onclick="loadAttrib(''ed_gadg'', ''ws_par_sumary='||prm_objeto||'&prm_tipo=grafico&prm_tipo_graf=MAPA'');  ClickIconGrap(this);">');
													htp.p('<svg class="icones-graficos '||ws_class_sel_mapa||'" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 560.12 454.23" style="enable-background:new 0 0 560.12 454.23;" xml:space="preserve"> <path d="M237.74,49.87c4.59,2.1,6.93,5.85,8.33,10.58c2.06,6.95,4.59,13.76,6.73,20.68c0.64,2.08,1.66,2.69,3.75,2.64 c5.51-0.14,11.04,0.07,16.54-0.13c1.45-0.05,3.18-0.76,4.22-1.76c5.68-5.44,11.16-11.08,16.74-16.62 c6.32-6.27,13.32-5.56,18.28,1.85c6.2,9.26,12.31,18.57,18.59,27.77c0.99,1.45,2.54,2.78,4.13,3.51 c35.12,16.06,70.31,31.96,105.42,48.03c18.94,8.67,25.73,30.37,14.75,47.03c-2.11,3.2-4.92,5.96-7.62,8.72 c-6.15,6.3-12.36,12.54-18.7,18.64c-1.87,1.8-2.5,3.64-2.47,6.16c0.11,11.85-0.02,23.71,0.09,35.57c0.04,4.15-1.37,7.45-4.29,10.35 c-14.4,14.32-28.76,28.67-43.07,43.08c-2.73,2.75-5.9,4.05-9.69,4.3c-19.98,1.35-33.2,15.16-33.54,35.33 c-0.29,17.39,1.41,13.27-11.26,26.11c-8.17,8.27-16.41,16.46-24.64,24.65c-5.83,5.8-11.6,5.79-17.45-0.04 c-10.64-10.6-21.27-21.23-31.87-31.87c-5.36-5.38-5.37-11.32-0.07-16.69c4.54-4.59,9.15-9.11,13.68-13.71 c6.53-6.61,6.05-14.26-1.28-19.85c-7-5.33-13.97-10.71-21.15-15.79c-4.52-3.2-6.75-7.07-6.5-12.74c0.32-7.26-0.03-14.55,0.14-21.83 c0.06-2.38-0.78-3.57-2.88-4.53c-4.47-2.05-8.8-4.41-13.22-6.56c-4.33-2.11-6.58-5.51-6.65-10.31c-0.05-3.99-0.12-7.98,0.01-11.97 c0.06-1.99-0.66-2.87-2.56-3.48c-7.58-2.4-15.1-5.01-22.65-7.51c-6.11-2.02-8.77-5.55-8.85-11.95c-0.06-4.69-0.06-9.39-0.11-14.08 c0-0.18-0.21-0.37-0.53-0.87c-6.01,2.99-12.05,5.99-18.08,8.99c-3.67,1.82-7.32,3.68-11.01,5.45c-4.54,2.19-8.8,1.48-12.31-1.99 c-11.37-11.21-22.63-22.52-33.86-33.86c-1.27-1.29-2.11-3-3.15-4.52c0-2.11,0-4.23,0-6.34c2.57-2.96,5-6.06,7.74-8.86 c7.96-8.12,16.11-16.05,24.03-24.21c1.14-1.17,1.95-3.17,1.99-4.82c0.21-7.73,0.04-15.47,0.11-23.21 c0.1-11.22,7.35-20.82,18.05-24.19c7.13-2.25,13.98-1.46,20.29,2.29c8.66,5.14,19.02-1.34,18.15-10.99 c-0.09-1.05-0.03-2.11-0.01-3.16c0.12-6.46,2.68-9.97,8.76-12c4.99-1.66,10-3.25,14.96-4.98c5.9-2.05,11.76-4.22,17.64-6.33 C233.51,49.87,235.63,49.87,237.74,49.87z M125.14,173.61c6.55,6.51,12.86,12.62,18.96,18.94c1.75,1.81,3.03,1.76,5.12,0.7 c11.25-5.76,22.57-11.38,33.89-17.02c9.35-4.66,17.05,0.14,17.11,10.65c0.04,6.93,0.12,13.86-0.05,20.78 c-0.06,2.61,0.55,3.94,3.27,4.75c7.28,2.18,14.45,4.72,21.65,7.17c6.69,2.27,9.03,5.54,9.06,12.47c0.01,3.76,0.14,7.52-0.05,11.27 c-0.11,2.18,0.56,3.39,2.58,4.31c4.57,2.1,9.04,4.44,13.54,6.71c4.39,2.22,6.56,5.78,6.53,10.75c-0.05,8.33-0.12,16.67,0.08,25 c0.04,1.46,0.98,3.35,2.12,4.26c5.49,4.4,11.21,8.51,16.82,12.76c17.64,13.33,19.32,35.99,3.81,51.76 c-2.29,2.32-4.79,4.43-6.85,6.32c6.69,6.67,12.88,12.84,19.18,19.12c7-7,14.34-14.26,21.54-21.65c0.76-0.78,0.98-2.27,1.08-3.46 c0.33-4.2,0.29-8.44,0.74-12.63c2.5-23.45,24.24-44.92,47.65-47.35c1.69-0.17,3.64-1.02,4.84-2.19 c11.88-11.69,23.68-23.47,35.35-35.37c1.21-1.23,2-3.42,2.03-5.17c0.18-11.5,0.25-23.01,0.02-34.51c-0.1-5.17,1.42-9.18,5.22-12.79 c8.16-7.77,16-15.87,23.96-23.85c7.62-7.64,6.17-15.54-3.65-20.01c-35.6-16.18-71.17-32.42-106.81-48.52 c-4.02-1.82-7.05-4.29-9.4-8.02c-4.3-6.82-8.92-13.44-13.62-20.46c-4.46,4.55-8.42,9.08-12.94,12.97c-2.14,1.84-5.29,3.39-8.04,3.48 c-11.25,0.39-22.53,0.24-33.8,0.13c-5.16-0.05-8.5-2.66-10.28-7.57c-0.6-1.65-1.07-3.34-1.63-5.01c-2.04-6.05-4.09-12.11-6.2-18.36 c-5.25,1.72-10.17,3.21-14.97,5c-0.89,0.33-1.72,1.84-1.9,2.92c-3.79,23.17-27.44,35.31-48.28,24.7c-5.27-2.68-8-1.03-8.03,4.94 c-0.04,7.4-0.43,14.82,0.11,22.18c0.54,7.45-1.91,12.96-7.43,17.94C139.81,158.55,132.74,166.08,125.14,173.61z"/></svg>');
													htp.p('<span id="icon-label">'||fun.lang('MAPA')||'</span>');
												htp.p('</li>');

												htp.p('<li class="amostragem-graficos" title="'||fun.lang('MAPA GEOLOCALIZA&Ccedil;&Atilde;O')||'" onclick="loadAttrib(''ed_gadg'', ''ws_par_sumary='||prm_objeto||'&prm_tipo=grafico&prm_tipo_graf=MAPAGEOLOC''); ClickIconGrap(this);">');
													htp.p('<svg class="icones-graficos '||ws_class_sel_mapageoloc||'" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 560.12 454.23" style="enable-background:new 0 0 560.12 454.23;" xml:space="preserve"> <g> <path d="M92.06,396.78c5.65-12.94,11.35-25.85,16.93-38.81c16.48-38.31,32.97-76.62,49.32-114.99c2.63-6.18,6.77-9.05,13.54-8.94 c12.96,0.21,25.93,0.06,39.66,0.06c-0.94-1.76-1.63-3.1-2.36-4.41c-11.01-19.79-21-40.1-25.6-62.39 c-7.13-34.61-2.32-67.39,19.92-95.69c21.58-27.45,51.11-38.84,85.56-35.5c47.68,4.62,81.44,38.12,88.9,85.38 c4.46,28.29-1.47,54.56-12.93,80.05c-4.3,9.55-9.33,18.78-14.03,28.15c-0.64,1.28-1.31,2.53-2.28,4.41c2.18,0,3.82,0,5.47,0 c11.26,0,22.52,0.2,33.77-0.07c7.08-0.17,11.3,2.83,14.06,9.29c21.63,50.69,43.43,101.32,65.19,151.96c0.23,0.53,0.6,1,0.9,1.5 c0,1.95,0,3.91,0,5.86c-2.69,2.69-5.39,5.37-8.08,8.06c-119.94,0-239.89,0-359.83,0c-2.69-2.69-5.39-5.37-8.08-8.06 C92.06,400.68,92.06,398.73,92.06,396.78z M280.04,294.01c2.32-2.91,4.39-5.43,6.38-8.01c21.87-28.26,42.07-57.57,57.08-90.15 c9.83-21.34,16.18-43.27,13.08-67.28c-5.51-42.58-35.15-68.54-71.39-70.74c-25.86-1.57-47.97,6.96-64.45,27.46 c-13.98,17.39-18.31,37.97-17.94,59.75c0.31,18.07,6.44,34.67,13.85,50.82c14.37,31.37,33.73,59.65,54.6,86.97 C274.03,286.49,276.93,290.07,280.04,294.01z M415.88,332.55c-0.18-0.7-0.22-1.05-0.36-1.37c-10.38-24.2-20.81-48.38-31.1-72.61 c-0.92-2.16-2.21-2.45-4.2-2.44c-13.82,0.06-27.64,0.12-41.46-0.04c-2.82-0.03-4.28,0.99-5.9,3.18 c-14.12,19.15-28.26,38.3-42.72,57.2c-6.35,8.29-13.39,8.12-20.07,0.2c-4.41-5.22-8.7-10.53-13.2-16 c-13.23,6.76-26.39,13.49-39.83,20.35c1.22,1.28,2.04,2.16,2.89,3.02c16.95,16.92,33.89,33.85,50.86,50.75 c4.67,4.65,8.69,10.99,14.34,13.3c5.67,2.31,13,0.66,19.6,0.52c1.86-0.04,3.89-0.51,5.54-1.35c14.79-7.54,29.52-15.2,44.26-22.85 C374.92,353.83,395.28,343.25,415.88,332.55z M119.99,388.46c44.44,0,88.39,0,131.88,0c-18.66-18.64-37.46-37.41-56.47-56.4 c-20.99,10.72-42.52,21.71-64.04,32.73c-0.72,0.37-1.53,0.95-1.84,1.64C126.33,373.65,123.24,380.91,119.99,388.46z M243.26,282.81 c-5.96-8.71-11.6-17.1-17.46-25.34c-0.63-0.89-2.51-1.26-3.81-1.27c-13.94-0.09-27.87,0.03-41.81-0.13 c-2.65-0.03-3.8,0.92-4.79,3.23c-10.03,23.54-20.16,47.03-30.25,70.54c-0.4,0.94-0.66,1.94-1.24,3.71 C177.41,316.44,210.18,299.71,243.26,282.81z M424.61,352.91c-22.62,11.73-45.05,23.36-67.49,35c0.08,0.19,0.17,0.37,0.25,0.56 c27.43,0,54.86,0,82.75,0c-4.83-11.28-9.52-22.23-14.23-33.17C425.58,354.55,425.13,353.85,424.61,352.91z"/> <path d="M313.17,134.83c0,18.24-14.9,33.14-33.12,33.13c-18.22-0.01-33.11-14.92-33.1-33.15c0.01-18.27,14.87-33.1,33.12-33.09 C298.36,101.73,313.17,116.55,313.17,134.83z M280.11,145.87c5.94-0.03,10.95-5.06,10.98-11.01c0.02-6.16-5.06-11.13-11.26-11.01 c-6.03,0.11-10.86,5.08-10.79,11.1C269.1,140.89,274.19,145.9,280.11,145.87z"/> </g> </svg>');
													htp.p('<span id="icon-label">'||fun.lang('MAPA GEO')||'</span>');
												htp.p('</li>');

												htp.p('<li class="amostragem-graficos" title="'||fun.lang('SANKEY')||'" onclick="loadAttrib(''ed_gadg'', ''ws_par_sumary='||prm_objeto||'&prm_tipo=grafico&prm_tipo_graf=SANKEY'');  ClickIconGrap(this);">');
													htp.p('<svg class="icones-graficos '||ws_class_sel_sankey||'" version="1.1" id="Camada_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 560.1 454.2" style="enable-background:new 0 0 560.1 454.2;" xml:space="preserve"> <g><rect x="11.7" y="26.8" width="25.7" height="86"/><rect x="11.7" y="196.4" width="25.7" height="79.5"/><rect x="11.7" y="374.6" width="25.7" height="59.9"/><rect x="519.4" y="26.8" width="25.7" height="86"/><rect x="519.4" y="138.8" width="25.7" height="79.5"/><rect x="519.4" y="287.6" width="25.7" height="76.5"/><path d="M496,337.8l-0.6-30c-0.2,0-0.4,0-0.6,0c-14.1,0-26-13.4-39.9-29c-1.6-1.8-3.2-3.5-4.7-5.3c10.2-23.6,17.8-47.2,23.2-66.1c3.3-11.4,20.4-10.7,20.5-10.7l-0.9-29.9c-13.7-1-36.3,4.4-43.9,31.1c-4.6,16.2-11,36-19.2,56c-4.5-3.4-9.1-6.4-14.2-8.7c-18.5-8.2-37.2-4.7-57.3,10.7c-15.2,10.5-29.6,32.5-46.1,57.9c-4.3,6.7-8.8,13.5-13.3,20.2c-7.8-7.4-14.4-17.7-20.3-31.4c-6.3-14.7-11.9-33.3-17.1-54.8c19.8-22.6,34.3-51.7,47.2-77.7c8.4-16.8,16.3-32.7,24.7-45.3c32.7-49.1,92.7-47.2,125.5-41.8c17.5,2.9,33.3,1.6,34,1.5V54.6c-0.2,0-15.7,1.2-30.4-1.3c-38.3-6.4-108.7-7.9-149.3,53c-9.4,14.2-17.8,30.9-26.6,48.6c-10.2,20.4-20.5,41.1-32.8,58.4c-3.1-14.9-6.2-30.7-9.2-47c-8.4-44.4-30.7-76.6-66.4-95.7c-29.3-15.7-61.7-19-83.8-19l0,0c-16.8,0-29.1,0.1-29.2,0.1l0.3,30c0.1,0,12.2-0.1,28.9-0.1l0,0c19.5,0,48.1,2.8,73.2,16.3c28,15,45.5,40.2,52.1,75c4.3,22.8,8.5,44.5,13,64.5c-15,13-33.1,20.7-56.1,19.2c-33-2-45.4-3.6-87.7-22.4c-12.2-5.5-23.5-5.6-24.7-5.6l-0.1,30c0.1,0,7.8,0.1,15.8,3.7c44.2,19.7,59.6,22.1,95.4,24.3c2.3,0.1,4.7,0.2,6.9,0.2c23,0,41.8-7.3,57.8-18.9c4.9,18.3,10,34.6,15.9,48.3c7.6,17.4,16.2,30.8,26.8,40.9c-18.8,24.5-39.4,44.5-63,47.7c-50.3,6.8-103.6-2.1-131-8.1C75.6,393.8,64.5,394,64,394l0.5,30c0.1,0,9.1-0.1,19.8,2.2c21.3,4.6,57.8,11,97.1,11c13.6,0,27.6-0.8,41.4-2.6c33.1-4.5,59.9-31.6,82.6-62.2c5.7,2.6,11.9,4.6,18.5,6c5.5,1.2,10.9,1.8,16.3,1.8c14.6,0,28.7-4.3,42.1-12.9c15.2-9.7,29.6-25.1,42.8-45.6c4.4-6.8,8.5-13.9,12.3-21.2c15.6,17.5,33.1,37.2,57.4,37.2C495.3,337.8,495.6,337.8,496,337.8zM404.7,303.7c-11.1,17.1-22.8,29.7-34.8,37.4c-13.3,8.5-26.9,11.2-41.5,8c-2-0.4-3.8-0.9-5.7-1.5c3.5-5.2,6.8-10.4,10.1-15.4c14.4-22.1,27.9-43,38.8-50.4l0.7-0.5c19-14.7,31.6-12.6,45.6-0.7C413.9,288.6,409.5,296.4,404.7,303.7z"/></g></svg>');
													htp.p('<span id="icon-label">'||fun.lang('SANKEY')||'</span>');
												htp.p('</li>');

												htp.p('<li class="amostragem-graficos" title="'||fun.lang('BOLHAS')||'" onclick="loadAttrib(''ed_gadg'', ''ws_par_sumary='||prm_objeto||'&prm_tipo=grafico&prm_tipo_graf=SCATTER'');  ClickIconGrap(this);">');
													htp.p('<svg class="icones-graficos '||ws_class_sel_scatter||'" version="1.1" id="Camada_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 560.1 454.2" style="enable-background:new 0 0 560.1 454.2;" xml:space="preserve"><circle cx="396.5" cy="157.3" r="58.5"/><circle cx="282.5" cy="275.3" r="37.5"/><circle cx="240" cy="155.8" r="67"/><circle cx="387" cy="272.3" r="21.5"/><circle cx="188.5" cy="312.3" r="19.5"/><polygon points="103.5,396.4 103.5,9.8 79.5,9.8 79.5,89.8 52,89.8 52,108.8 79.5,108.8 79.5,223.8 52,223.8 52,242.8 79.5,242.8 79.5,357.8 52,357.8 52,376.8 79.5,376.8 79.5,396.4 79,396.4 79,420.5 152.5,420.5 152.5,446.3 171.5,446.3 171.5,420.5 286.5,420.5 286.5,446.3 305.5,446.3 305.5,420.5 420.5,420.5 420.5,446.3 439.5,446.3 439.5,420.5 488,420.5 488,396.4 "/></svg>');
													htp.p('<span id="icon-label">'||fun.lang('BOLHAS')||'</span>');
												htp.p('</li>');

												htp.p('<li class="amostragem-graficos" title="'||fun.lang('RADAR')||'" onclick="loadAttrib(''ed_gadg'', ''ws_par_sumary='||prm_objeto||'&prm_tipo=grafico&prm_tipo_graf=RADAR'');  ClickIconGrap(this);">');
													htp.p('<svg class="icones-graficos '||ws_class_sel_radar||'" version="1.1" id="Camada_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 560.1 454.2" style="enable-background:new 0 0 560.1 454.2;" xml:space="preserve"><path d="M285.9,14C166.7,14,70,110.6,70,229.8c0,45.8,14.3,88.3,38.7,123.3c-4.5,7-7.1,15.3-7.1,24.2c0,24.9,20.2,45.1,45.1,45.1c9.9,0,19-3.2,26.4-8.5c32.8,20.1,71.4,31.8,112.7,31.8c119.2,0,215.8-96.6,215.8-215.8S405.1,14,285.9,14z M474.7,216.8h-26.2c-3.2-15.1-14.6-27.2-29.3-31.5c-6.4-19.1-16.7-36.4-30.1-50.8l32-37.1C451.7,128.6,471.5,170.4,474.7,216.8z M146.7,332.3c-6.3,0-12.2,1.3-17.7,3.6c-18.2-26.9-29.7-58.7-32.1-93h48.9c6.2,67.2,59.7,120.7,126.9,126.9v48.9c-30.4-2.1-58.9-11.3-83.7-26.1c1.7-4.8,2.6-9.9,2.6-15.2C191.8,352.5,171.6,332.3,146.7,332.3z M228,135.3c0,14.4-11.7,26.1-26.1,26.1c-14.4,0-26.1-11.7-26.1-26.1c0-14.4,11.7-26.1,26.1-26.1C216.3,109.2,228,120.9,228,135.3z M187.5,174.4c4.5,1.6,9.3,2.5,14.3,2.5c23,0,41.7-18.7,41.7-41.7c0-3.3-0.4-6.6-1.1-9.7c9.6-4,19.8-6.7,30.5-7.9v45.7c-26.1,5.3-46.4,26.7-49.9,53.5h-49.2C175.5,201.6,180.3,187.2,187.5,174.4z M366.3,216.8H348c-1.2-8.9-4.2-17.3-8.8-24.7l31.6-36.6c8.2,9.3,14.8,20,19.6,31.6C378.2,192.6,369.1,203.5,366.3,216.8z M321.9,173.7c-6.8-4.8-14.6-8.3-23-10.1v-45.9c19.8,2.3,38,9.7,53.4,20.8L321.9,173.7z M298.9,180.6c4.4,1.3,8.4,3.2,12.2,5.7l-12.2,14.1V180.6z M272.9,216.8h-33.2c3.2-17.6,16.2-31.7,33.2-36.5V216.8z M272.9,242.8v27.2c-13.9-3.9-25.1-14.1-30.5-27.2H272.9z M298.9,242.8h29.8c-5.3,12.9-16.2,23-29.8,27V242.8z M317.9,216.8l9.8-11.3c1.7,3.6,2.9,7.3,3.6,11.3H317.9z M370.3,117.6c-20.3-15.3-44.8-25.2-71.5-27.6V41c38.9,2.6,74.5,17,103.4,39.6L370.3,117.6z M224.9,242.8c6.5,22.3,24.9,39.6,48,44.2V342c-52-6-93.2-47.2-99.1-99.1H224.9z M298.9,286.9c22.7-4.9,40.8-22,47.2-44.1H369c4.6,10.4,13.3,18.5,24.1,22.4c-13.5,41.1-50,71.7-94.2,76.8V286.9z M407.4,252c-14.6,0-26.4-11.8-26.4-26.4c0-14.6,11.8-26.4,26.4-26.4c14.6,0,26.4,11.8,26.4,26.4C433.7,240.2,421.9,252,407.4,252z M272.9,41v48.9c-16.2,1.5-31.6,5.7-45.8,12.3c-7-5.4-15.8-8.6-25.3-8.6c-23,0-41.7,18.7-41.7,41.7c0,7.8,2.1,15,5.8,21.3c-10.9,17.9-18,38.3-20,60.3H97C103.4,122.7,178.7,47.4,272.9,41z M146.7,405.6c-15.6,0-28.3-12.7-28.3-28.3c0-15.6,12.7-28.3,28.3-28.3c15.6,0,28.3,12.7,28.3,28.3C175,393,162.3,405.6,146.7,405.6z M298.9,418.7v-48.9c59.6-5.5,108.4-48.2,123-104.6c11.3-4.2,20.3-13,24.6-24.2c-0.2,0.6-0.4,1.3-0.6,1.9h28.8C468.3,337,393,412.3,298.9,418.7z"/></svg>');
													htp.p('<span id="icon-label">'||fun.lang('RADAR')||'</span>');
												htp.p('</li>');
												
												htp.p('<li class="amostragem-graficos" title="CALENDARIO" onclick="loadAttrib(''ed_gadg'', ''ws_par_sumary='||prm_objeto||'&prm_tipo=grafico&prm_tipo_graf=CALENDARIO'');  ClickIconGrap(this);">');
													htp.p('<svg class="icones-graficos '|| ws_class_sel_calendario ||'" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" id="Camada_1" x="0px" y="0px" viewBox="0 0 560.1 454.2" style="enable-background:new 0 0 560.1 454.2;" xml:space="preserve"> <path d="M382.8,23.9c10.6,0,21.3,0,31.9,0c0,10.6,0,21.2,0,31.9c6.3,0,12,0,17.7,0c28.5,0.1,49.3,20.8,49.4,49.4  c0,92.7,0,185.5,0,278.2c0,4-0.3,8-1.2,11.9c-5.3,22.7-24.2,37.4-48.2,37.4c-103.2,0-206.5,0-309.7,0c-1.1,0-2.1,0-3.2,0  c-15.1-0.8-27.3-7.1-36.6-19c-5.4-6.9-7.9-14.9-9.7-23.3c0-97.4,0-194.8,0-292.2c0.2-0.5,0.5-1,0.6-1.5  c5.7-26.4,23.5-40.9,50.5-40.9c5.3,0,10.5,0,16,0c0-11,0-21.5,0-31.9c10.6,0,21.3,0,31.9,0c0,10.6,0,21.2,0,31.7  c70.5,0,140.5,0,210.8,0C382.8,44.8,382.8,34.4,382.8,23.9z M104.9,174.2c0,1.8,0,3.1,0,4.4c0,67.7,0,135.5,0,203.2  c0,13,6.1,19,19.1,19c102.3,0,204.6,0,307,0c12.8,0,18.9-6.1,18.9-18.7c0-67.9,0-135.7,0-203.6c0-1.4,0-2.8,0-4.3  C334.7,174.2,220,174.2,104.9,174.2z M382.9,88c-70.6,0-140.6,0-211,0c0,10.6,0,20.9,0,31.4c-10.7,0-21.1,0-32,0  c0-10.7,0-21.1,0-31.7c-6.4,0-12.4-0.1-18.4,0c-9.9,0.2-16.5,6.7-16.6,16.6c-0.1,9.4,0,18.9,0,28.3c0,3,0,6,0,9  c115.2,0,230,0,344.9,0c0-13.2,0.2-26.1-0.1-39c-0.2-7.5-5.8-14-13.3-14.7c-7.1-0.6-14.3-0.1-21.8-0.1c0,10.7,0,21.1,0,31.5  c-10.8,0-21.1,0-31.7,0C382.9,109,382.9,98.7,382.9,88z"/><path d="M165.4,207.8c0,10.5,0,20.8,0,31.4c-10.4,0-20.8,0-31.5,0c0-10.3,0-20.8,0-31.4C144.4,207.8,154.8,207.8,165.4,207.8z"/><path d="M229.3,239.3c-10.5,0-20.8,0-31.4,0c0-10.4,0-20.8,0-31.5c10.3,0,20.8,0,31.4,0C229.3,218.3,229.3,228.7,229.3,239.3z"/><path d="M261.6,239.2c0-10.6,0-20.9,0-31.4c10.5,0,20.8,0,31.4,0c0,10.3,0,20.7,0,31.4C282.8,239.2,272.3,239.2,261.6,239.2z"/><path d="M325.5,239.2c0-10.5,0-20.8,0-31.4c10.6,0,21,0,31.6,0c0,10.4,0,20.7,0,31.4C346.7,239.2,336.3,239.2,325.5,239.2z"/><path d="M389.3,239.3c0-10.6,0-20.9,0-31.5c10.5,0,20.9,0,31.6,0c0,10.5,0,20.9,0,31.5C410.4,239.3,400.1,239.3,389.3,239.3z"/><path d="M165.3,303.2c-10.6,0-20.9,0-31.4,0c0-10.5,0-20.8,0-31.4c10.3,0,20.7,0,31.4,0C165.3,282,165.3,292.4,165.3,303.2z"/><path d="M229.3,271.7c0,10.6,0,20.9,0,31.4c-10.5,0-20.8,0-31.4,0c0-10.3,0-20.7,0-31.4C208.2,271.7,218.6,271.7,229.3,271.7z"/><path d="M261.7,271.6c10.6,0,20.9,0,31.4,0c0,10.5,0,20.8,0,31.4c-10.3,0-20.7,0-31.4,0C261.7,292.7,261.7,282.3,261.7,271.6z"/><path d="M325.6,271.6c10.5,0,20.9,0,31.4,0c0,10.6,0,21,0,31.6c-10.5,0-20.8,0-31.4,0C325.6,292.8,325.6,282.3,325.6,271.6z"/><path d="M389.4,271.6c10.7,0,21,0,31.5,0c0,10.5,0,20.8,0,31.4c-10.4,0-20.8,0-31.5,0C389.4,292.7,389.4,282.3,389.4,271.6z"/><path d="M133.8,366.9c0-10.6,0-20.9,0-31.4c10.5,0,20.8,0,31.4,0c0,10.3,0,20.7,0,31.4C155,366.9,144.6,366.9,133.8,366.9z"/><path d="M197.8,335.5c10.6,0,20.9,0,31.4,0c0,10.5,0,20.8,0,31.4c-10.3,0-20.7,0-31.4,0C197.8,356.6,197.8,346.2,197.8,335.5z"/><path d="M293.1,367c-10.6,0-20.9,0-31.4,0c0-10.5,0-20.8,0-31.4c10.3,0,20.7,0,31.4,0C293.1,345.9,293.1,356.3,293.1,367z"/><path d="M325.6,335.4c10.6,0,20.8,0,31.3,0c0,10.5,0,20.9,0,31.6c-10.3,0-20.8,0-31.3,0C325.6,356.4,325.6,345.9,325.6,335.4z"/></svg>');
													htp.p('<span id="icon-label">CALENDARIO</span>');
												htp.p('</li>');
											htp.p('</ul>'); 
										htp.p('</li>'); 
									htp.p('</ul>');
								end if;	
							end if; 
								
							htp.p('<div id="ctnr_'||ws_objid||'" class="block-fusion espaco" style="position: relative !important; min-width: inherit; max-width: inherit; '||ws_posicao||';"></div>');

							fcl.data_attrib(ws_objid, ws_tipo);

							htp.p('</div>');
						end if;

				    when ws_tp_objeto = 'IMAGE' then

					    obj.image(prm_objeto, ws_propagation, prm_screen, prm_drill, ws_nm_objeto, ws_posicao, ws_posy, ws_posx);


				    when ws_tp_objeto = 'FILE' then

                        obj.file(prm_objeto, ws_propagation, prm_screen, prm_drill, ws_nm_objeto, ws_posicao, ws_posy, ws_posx);

				    when ws_tp_objeto in ('UPGETPAR','CH_PASS') then
						htp.p('<div src="'||nvl(fun.ret_var('OWNER_BI'),'DWU')||'.fcl.ch_pwd"><script>alert('||nvl(fun.ret_var('OWNER_BI'),'DWU')||'.fcl.ch_pwd);</script></div>');
						if  ws_tp_objeto = 'UPGETPAR' then
							htp.p( '<iframe width="100%" height="100%" name="'||ws_obj||'_file"  src="'||nvl(fun.ret_var('OWNER_BI'),'DWU')||'.fcl.get_par?ws_type=SUBMIT" style=" background:#CDCDC1; border:0px; padding:0px; '||fun.put_style(ws_obj, 'TIT_COLOR', ws_tip)||fun.put_style(ws_obj, 'TIT_BGCOLOR', ws_tip)||'; "></iframe>');
						else
							htp.p( '<iframe width="100%" height="100%" name="'||ws_obj||'_file"  src="'||nvl(fun.ret_var('OWNER_BI'),'DWU')||'.fcl.ch_pwd" style=" background:#CDCDC1; border:0px; padding:0px; '||fun.put_style(ws_obj, 'TIT_COLOR', ws_tip)||fun.put_style(ws_obj, 'TIT_BGCOLOR', ws_tip)||'; "></iframe>');
						end if;
						
				    when ws_tp_objeto= 'RELATORIO' then

					    obj.relatorio(prm_objeto, ws_propagation, prm_screen, prm_drill, ws_nm_objeto, ws_posicao, ws_posy, ws_posx, prm_dashboard => prm_dashboard);
				    
				    when ws_tp_objeto = 'MAPAGEOLOC' then
						
						obj.mapageoloc(prm_objeto, prm_drill, ws_gdescricao, ws_cd_micro_visao, ws_parametro, ws_propagation, prm_screen, ws_posx, ws_posy, ws_posicao, prm_dashboard,prm_usuario => ws_usuario, prm_track => prm_track, prm_cd_goto => prm_cd_goto);

				    when ws_tp_objeto = 'TEXTO' then
						
						ws_italico	:= fun.getprop(prm_objeto,'IT');
						ws_negrito	:= fun.getprop(prm_objeto,'BOLD');
						ws_font		:= fun.getprop(prm_objeto,'FONT');
						ws_size		:= fun.getprop(prm_objeto,'SIZE');
						ws_align    := fun.getprop(prm_objeto,'ALIGN');
						ws_bordaCor := 'border: 1px solid '||fun.getprop(prm_objeto, 'BORDA_COR');
						
                        
						begin
							select CONTEUDO into ws_padrao
							from   PARAMETRO_USUARIO
							where  cd_usuario = ws_usuario and
								cd_padrao='CD_LINGUAGEM';
						exception
							when others then
								ws_padrao := 'PORTUGUESE';
						end;

						if fun.getprop(prm_objeto,'MARQUEE') = 'S' then

							ws_tempo_marquee := 'animation: marquee '||fun.getprop(prm_objeto,'VEL_MARQ')||'s linear infinite';
							
						    htp.p('<div onmousedown="'||ws_propagation||'" class="dragme marquee" id="'||trim(prm_objeto)||'" data-top="'||ws_posy||'" data-left="'||ws_posx||'" style="width: calc('||fun.getprop(prm_objeto,'LARGURA')||' - 2px); white-space: nowrap; '||ws_posicao||'; '||fun.put_style(ws_obj, 'COLOR', ws_tip)||fun.put_style(ws_obj, 'BGCOLOR', ws_tip)||'" ondbclick=" call_save(''enabled''); carrega(''av_prop?ws_par_sumary='||prm_objeto||'&prm_screen='||prm_screen||'''); showedobj(''hide'');">');
						else
                            htp.p('<div onmousedown="'||ws_propagation||'" class="dragme texto" id="'||trim(prm_objeto)||'" data-top="'||ws_posy||'" data-left="'||ws_posx||'" style="white-space: nowrap; '||ws_posicao||'; '||ws_borda||fun.put_style(ws_obj, 'COLOR', ws_tip)||fun.put_style(ws_obj, 'BGCOLOR', ws_tip)||'" ondbclick=" call_save(''enabled''); carrega(''av_prop?ws_par_sumary='||prm_objeto||'&prm_screen='||prm_screen||'''); showedobj(''hide'');">');
                        end if;
						
	                    obj.opcoes(prm_objeto, ws_tp_objeto, '', '', prm_screen, prm_drill, prm_usuario => ws_usuario);

                        ws_atributos := fun.subpar(fun.utranslate('ATRIBUTOS', prm_objeto, fun.subpar(ws_atributos, prm_screen), ws_padrao), prm_screen);          
                        ws_atributos := replace(replace(ws_atributos, '<', '&lt;'), '>', '&gt;');
                        --htp.p('<span id="valor_'||prm_objeto||'" class="texto" style="'||fun.put_style(prm_objeto, 'IT', ws_tip)||fun.put_style(prm_objeto, 'BOLD', ws_tip)||fun.put_style(prm_objeto, 'FONT', ws_tip)||fun.put_style(prm_objeto, 'SIZE', ws_tip)||' text-align: center; display: block; min-width: 70px; white-space: pre;" ><p>'||fun.subpar(fun.utranslate('ATRIBUTOS', prm_objeto, fun.subpar(ws_atributos, prm_screen), ws_padrao), prm_screen)||'</p></span>');
                        htp.p('<span id="valor_'||prm_objeto||'" class="texto" style="font-Family:'||WS_FONT||'; '||ws_bordaCor||'; font-Weight:'||WS_NEGRITO||'; font-Size:'||WS_SIZE||'; font-Style:'||WS_ITALICO||'; text-Align: '||WS_ALIGN||'; display: block; min-width: 70px; white-space: pre;" ><p style="'||ws_tempo_marquee||';">'||ws_atributos||'</p></span>');

						htp.p('</div>');


					when ws_tp_objeto = 'MAPAFUSION' then
						
						begin
							select CONTEUDO into ws_padrao
							from   PARAMETRO_USUARIO
							where  cd_usuario = ws_usuario and
								cd_padrao='CD_LINGUAGEM';
						exception
							when others then
								ws_padrao := 'PORTUGUESE';
						end;
						
						if substr(trim(fun.put_style(ws_obj, 'DEGRADE', ws_tip)), 5, 1) = 'S' then
							ws_gradiente := 'background: '||ws_gradiente_tipo||'-gradient('||substr(fun.put_style(ws_obj, 'TIT_BGCOLOR', ws_tip), 18, 7)||', '||substr(fun.put_style(ws_obj, 'BGCOLOR', ws_tip), 18, 7)||'); ';
						else
							ws_gradiente := fun.put_style(ws_obj, 'BGCOLOR', ws_tip);
						end if;

						if fun.getprop(prm_objeto,'NO_RADIUS') <> 'N' then
							htp.p('<style>div#'||prm_objeto||' { border-radius: 0; } div#'||prm_objeto||' span#'||prm_objeto||'more { border-radius: 0 0 6px 0; } a#'||prm_objeto||'fechar { border-radius: 0 0 0 6px; }</style>');
						end if;

						htp.p('<div onmousedown="event.stopPropagation();" class="dragme grafico" id="'||rtrim(prm_objeto)||'" data-top="'||ws_posy||'" data-left="'||ws_posx||'" style="'||ws_posicao||'; '||ws_gradiente||'">');

						obj.opcoes(ws_objid, ws_tp_objeto, '', '', prm_screen, prm_drill, prm_usuario => ws_usuario);

						ws_alinhamento_tit := fun.getprop(prm_objeto,'ALIGN_TIT');
						if ws_alinhamento_tit = 'left' then
							ws_alinhamento_tit := ws_alinhamento_tit||'; text-indent: 14px';
						end if; 

						if ws_admin = 'A' then
							if substr(trim(fun.put_style(ws_obj, 'DEGRADE', ws_tip)), 5, 1) = 'S' then
								htp.p('<div class="wd_move" title="'||fun.lang('Clique e arraste para mover, duplo clique para ampliar.')||'" style="text-align: '||ws_alinhamento_tit||'; padding: 4px 23px; border-radius: 7px 7px 0 0; '||fun.put_style(ws_obj, 'TIT_COLOR', ws_tip)||fun.put_style(ws_obj, 'TIT_IT', ws_tip)||fun.put_style(ws_obj, 'TIT_BOLD', ws_tip)||fun.put_style(ws_obj, 'TIT_FONT', ws_tip)||fun.put_style(ws_obj, 'TIT_SIZE', ws_tip)||'" id="'||prm_objeto||'_ds">'||fun.subpar(fun.utranslate('NM_OBJETO', ws_obj, ws_nm_objeto, ws_padrao), prm_screen)||'</div>');
							else
								htp.p('<div class="wd_move" title="'||fun.lang('Clique e arraste para mover, duplo clique para ampliar.')||'" style="text-align: '||ws_alinhamento_tit||'; padding: 4px 23px; border-radius: 7px 7px 0 0; '||fun.put_style(ws_obj, 'TIT_COLOR', ws_tip)||fun.put_style(ws_obj, 'TIT_BGCOLOR', ws_tip)||fun.put_style(ws_obj, 'TIT_IT', ws_tip)||fun.put_style(ws_obj, 'TIT_BOLD', ws_tip)||fun.put_style(ws_obj, 'TIT_FONT', ws_tip)||fun.put_style(ws_obj, 'TIT_SIZE', ws_tip)||'" id="'||prm_objeto||'_ds">'||fun.subpar(fun.utranslate('NM_OBJETO', ws_obj, ws_nm_objeto, ws_padrao), prm_screen)||'</div>');
							end if;
						else
							if substr(trim(fun.put_style(ws_obj, 'DEGRADE', ws_tip)), 5, 1) = 'S' then
								htp.p('<div style="padding: 4px 23px; border-radius: 7px 7px 0 0; cursor: default; text-align: center; '||fun.put_style(ws_obj, 'TIT_COLOR', ws_tip)||fun.put_style(ws_obj, 'TIT_IT', ws_tip)||fun.put_style(ws_obj, 'TIT_BOLD', ws_tip)||fun.put_style(ws_obj, 'TIT_FONT', ws_tip)||fun.put_style(ws_obj, 'TIT_SIZE', ws_tip)||'" id="'||prm_objeto||'_ds">'||fun.subpar(fun.utranslate('NM_OBJETO', ws_obj, ws_nm_objeto, ws_padrao), prm_screen)||'</div>');
							else
								htp.p('<div style="padding: 4px 23px; border-radius: 7px 7px 0 0; cursor: default; text-align: center; '||fun.put_style(ws_obj, 'TIT_COLOR', ws_tip)||fun.put_style(ws_obj, 'TIT_BGCOLOR', ws_tip)||fun.put_style(ws_obj, 'TIT_IT', ws_tip)||fun.put_style(ws_obj, 'TIT_BOLD', ws_tip)||fun.put_style(ws_obj, 'TIT_FONT', ws_tip)||fun.put_style(ws_obj, 'TIT_SIZE', ws_tip)||'" id="'||prm_objeto||'_ds">'||fun.subpar(fun.utranslate('NM_OBJETO', ws_obj, ws_nm_objeto, ws_padrao), prm_screen)||'</div>');
							end if;
						end if;

						htp.p('<div class="sub" id="'||prm_objeto||'_sub" style="text-align: '||ws_alinhamento_tit||'; '||fun.put_style(ws_obj, 'TIT_COLOR', ws_tip)||';">'||fun.subpar(fun.utranslate('NM_OBJETO', ws_obj, ws_subtitulo, ws_padrao), prm_screen)||'</div>');


							htp.prn('<ul id="'||prm_objeto||'-filterlist" style="display: none;">');
								htp.prn(fun.show_filtros(ws_parametros, '', '', prm_objeto, ws_cd_micro_visao, prm_screen));
							htp.prn('</ul>');

							htp.p('<div style="display: none;" id="gxml_'||prm_objeto||'">');
								fcl.charout(ws_parametros, ws_cd_micro_visao, ws_obj, prm_screen,prm_usuario => ws_usuario, prm_cd_goto => prm_cd_goto);
							htp.p('</div>');


							htp.p('<div id="ctmr_'||ws_obj||'" class="block-fusion"></div> ');

					    htp.p('</div>');

					when ws_tp_objeto = 'SCRIPT' then
						htp.p('<div class="dragme" style="border: 1px solid #555; background: #E7E7E7; border-radius: 4px; border: 2px solid #333; '||fun.put_style(ws_obj, 'BGCOLOR', ws_tip)||' '||fun.put_style(ws_obj, 'COLOR', ws_tip)||' '||fun.put_style(ws_obj, 'BOLD', ws_tip)||' '||fun.put_style(ws_obj, 'IT', ws_tip)||' '||fun.put_style(ws_obj, 'FONT', ws_tip)||' position: fixed; top: 40%; left: 40%; z-index: 1; text-align: center;" id="script-load">');
							htp.p('<script type="text/javascript"></script>');
							htp.p('<span style="font-size: 20px; font-family: tahoma; padding: 10px;" class="up" onclick="ajax(''return'', ''Programa_Execucao'', ''prm_objeto='||prm_objeto||'&prm_parametros='||fun.getprop(prm_objeto,'parametros')||'&prm_screen=''+tela, '''', false); alerta(''feed-fixo'', respostaAjax.trim());">'||fun.lang('EXECUTAR')||'</span>');
							htp.p('<a class="fechar">X</a>');
						htp.p('</div>');

					when ws_tp_objeto = 'ORGANOGRAMA' then
						
						begin
							select CONTEUDO into ws_padrao
							from   PARAMETRO_USUARIO
							where  cd_usuario = ws_usuario and
								cd_padrao='CD_LINGUAGEM';
						exception
							when others then
								ws_padrao := 'PORTUGUESE';
						end;
											
						if ws_admin = 'A' then
							if substr(trim(fun.put_style(ws_obj, 'DEGRADE', ws_tip)), 5, 1) = 'S' then
								htp.p('<div onmousedown="event.stopPropagation();" class="dragme grafico" id="'||rtrim(prm_objeto)||'" data-top="'||ws_posx||'" data-left="'||ws_posx||'" data-swipe="" style="'||ws_posicao||'; '||(fun.put_style(ws_obj, 'SIZE', ws_tip))||' background: '||ws_gradiente_tipo||'-gradient('||substr(fun.put_style(ws_obj, 'TIT_BGCOLOR', ws_tip), 18, 7)||', '||substr(fun.put_style(ws_obj, 'BGCOLOR', ws_tip), 18, 7)||'); width: '||fun.getprop(ws_obj, 'LARGURA')||'px; height: '||fun.getprop(ws_obj, 'ALTURA')||'px;" ontouchstart="swipeStart('''||ws_obj||''', event);" ontouchmove="swipe('''||ws_obj||''', event);" ontouchend="swipe('''||ws_obj||''', event);">');
							else
								htp.p('<div onmousedown="event.stopPropagation();" class="dragme grafico" id="'||rtrim(prm_objeto)||'" data-top="'||ws_posy||'" data-left="'||ws_posx||'" data-swipe="" style="'||ws_posicao||'; '||(fun.put_style(ws_obj, 'BGCOLOR', ws_tip))||' '||(fun.put_style(ws_obj, 'SIZE', ws_tip))||' width: '||fun.getprop(ws_obj, 'LARGURA')||'px; height: '||fun.getprop(ws_obj, 'ALTURA')||'px;" ontouchstart="swipeStart('''||ws_obj||''', event);" ontouchmove="swipe('''||ws_obj||''', event);" ontouchend="swipe('''||ws_obj||''', event);">');
							end if;

							if fun.getprop(prm_objeto,'NO_RADIUS') <> 'N' then
								htp.p('<style>div#'||prm_objeto||' { border-radius: 0; } div#'||prm_objeto||' span#'||prm_objeto||'more { border-radius: 0 0 6px 0; } a#'||prm_objeto||'fechar { border-radius: 0 0 0 6px; }</style>');
							end if;

							htp.p('<style>');
								htp.p('div.orgChart tr.lines td.left { border-right: 2px solid '||fun.getprop(prm_objeto, 'LINHA_COLOR')||'; }');
								htp.p('div.orgChart tr.lines td.right { border-left: 2px solid '||fun.getprop(prm_objeto, 'LINHA_COLOR')||'; }');
								htp.p('div.orgChart tr.lines td.top { border-top: 3px solid '||fun.getprop(prm_objeto, 'LINHA_COLOR', 'ORGANOGRAMA')||'; }');
								htp.p('div.orgChart div.node { height: '||fun.getprop(prm_objeto, 'ALTURA_BLOCO')||'px; width: '||fun.getprop(prm_objeto, 'LARGURA_BLOCO')||'px; background-color: '||fun.getprop(prm_objeto, 'NODE_BGCOLOR')||'; font-size: '||fun.getprop(prm_objeto, 'SIZE')||'; font-weight: '||fun.getprop(prm_objeto, 'BOLD')||'; font-style: '||fun.getprop(prm_objeto, 'IT')||'; font-family: '||fun.getprop(prm_objeto, 'FONT')||'; color: '||fun.getprop(prm_objeto, 'COLOR')||'; } ');
							htp.p('</style>');
							htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options closed" id="'||ws_obj||'more" style="max-width: 94px;">');
								htp.p(fun.showtag(prm_objeto, 'post'));
								htp.p('<span class="preferencias" title="'||fun.lang('Propriedades')||'"></span>');
								htp.p('<span class="lightbulb" title="'||fun.lang('Drills')||'"></span>');
							htp.p('</span>');
						else
							if substr(trim(fun.put_style(ws_obj, 'DEGRADE', ws_tip)), 5, 1) = 'S' then
								if nvl(fun.getprop(ws_obj,'DEGRADE_TIPO'), '%??%') = '%??%' then
									ws_gradiente_tipo := 'linear';
								else
									ws_gradiente_tipo := fun.getprop(ws_obj,'DEGRADE_TIPO');
								end if;
								ws_gradiente := 'background: '||ws_gradiente_tipo||'-gradient('||substr(fun.put_style(ws_obj, 'TIT_BGCOLOR', ws_tip), 18, 7)||', '||substr(fun.put_style(ws_obj, 'BGCOLOR', ws_tip), 18, 7)||'); ';
							else
								ws_gradiente := fun.put_style(ws_obj, 'BGCOLOR', ws_tip);
							end if;

							htp.p('<div onmousedown="event.stopPropagation();" class="dragme grafico" id="'||rtrim(prm_objeto)||'" data-top="'||ws_posy||'" data-left="'||ws_posx||'" data-swipe="" ontouchstart="swipeStart('''||ws_obj||''', event);" ontouchmove="swipe('''||ws_obj||''', event);" ontouchend="swipe('''||ws_obj||''', event);" style="'||ws_posicao||'; '||ws_gradiente||' width: '||fun.getprop(ws_obj, 'LARGURA')||'px; height: '||fun.getprop(ws_obj, 'ALTURA')||'px;">');

							if fun.getprop(prm_objeto,'NO_RADIUS') <> 'N' then
								htp.p('<style>div#'||prm_objeto||' { border-radius: 0; } div#'||prm_objeto||' span#'||prm_objeto||'more { border-radius: 0 0 6px 0; } a#'||prm_objeto||'fechar { border-radius: 0 0 0 6px; }</style>');
							end if;

							htp.p('<style>');
								htp.p('div.orgChart tr.lines td.left { border-right: 2px solid '||fun.getprop(prm_objeto, 'LINHA_COLOR')||'; }');
								htp.p('div.orgChart tr.lines td.right { border-left: 2px solid '||fun.getprop(prm_objeto, 'LINHA_COLOR')||'; }');
								htp.p('div.orgChart tr.lines td.top { border-top: 3px solid '||fun.getprop(prm_objeto, 'LINHA_COLOR')||'; }');
								htp.p('div.orgChart div.node { height: '||fun.getprop(prm_objeto, 'ALTURA_BLOCO')||'px; width: '||fun.getprop(prm_objeto, 'LARGURA_BLOCO')||'px; background-color: '||fun.getprop(prm_objeto, 'NODE_BGCOLOR')||'; font-size: '||fun.getprop(prm_objeto, 'SIZE')||'; font-weight: '||fun.getprop(prm_objeto, 'BOLD')||'; font-style: '||fun.getprop(prm_objeto, 'IT')||'; font-family: '||fun.getprop(prm_objeto, 'FONT')||'; color: '||fun.getprop(prm_objeto, 'COLOR')||'; } ');
							htp.p('</style>');
							if nvl(fun.getprop(prm_objeto,'NO_OPTION'),'N') <> 'S' then
								htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options closed" id="'||ws_obj||'more" style="max-width: 40px;">');
									htp.p(fun.showtag(prm_objeto, 'post'));
								htp.p('</span>');
							end if;
						end if;

						if ws_admin = 'A' then
							if substr(trim(fun.put_style(ws_obj, 'DEGRADE', ws_tip)), 5, 1) = 'S' then
								htp.p('<div data-touch="0" class="wd_move" title="'||fun.lang('Clique e arraste para mover, duplo clique para ampliar.')||'" style="padding: 4px 23px; border-radius: 7px 7px 0 0; '||fun.put_style(ws_obj, 'TIT_COLOR', ws_tip)||fun.put_style(ws_obj, 'TIT_IT', ws_tip)||fun.put_style(ws_obj, 'TIT_BOLD', ws_tip)||fun.put_style(ws_obj, 'TIT_FONT', ws_tip)||fun.put_style(ws_obj, 'TIT_SIZE', ws_tip)||'" id="'||prm_objeto||'_ds">'||fun.subpar(fun.utranslate('NM_OBJETO', prm_objeto, ws_nm_ponto, ws_padrao), prm_screen)||'</div>');
							else
								htp.p('<div data-touch="0" class="wd_move" title="'||fun.lang('Clique e arraste para mover, duplo clique para ampliar.')||'" style="padding: 4px 23px; border-radius: 7px 7px 0 0; '||fun.put_style(ws_obj, 'TIT_COLOR', ws_tip)||fun.put_style(ws_obj, 'TIT_BGCOLOR', ws_tip)||fun.put_style(ws_obj, 'TIT_IT', ws_tip)||fun.put_style(ws_obj, 'TIT_BOLD', ws_tip)||fun.put_style(ws_obj, 'TIT_FONT', ws_tip)||fun.put_style(ws_obj, 'TIT_SIZE', ws_tip)||'" id="'||prm_objeto||'_ds">'||fun.subpar(fun.utranslate('NM_OBJETO', prm_objeto, ws_nm_ponto, ws_padrao), prm_screen)||'</div>');
							end if;
						else
							if substr(trim(fun.put_style(ws_obj, 'DEGRADE', ws_tip)), 5, 1) = 'S' then
								htp.p('<div data-touch="0" class="wd_move" style="cursor: move; padding: 4px 23px; border-radius: 7px 7px 0 0; cursor: default; text-align: center; '||fun.put_style(ws_obj, 'TIT_COLOR', ws_tip)||fun.put_style(ws_obj, 'TIT_IT', ws_tip)||fun.put_style(ws_obj, 'TIT_BOLD', ws_tip)||fun.put_style(ws_obj, 'TIT_FONT', ws_tip)||fun.put_style(ws_obj, 'TIT_SIZE', ws_tip)||'" id="'||prm_objeto||'_ds">'||fun.subpar(fun.utranslate('NM_OBJETO', prm_objeto, ws_nm_ponto, ws_padrao), prm_screen)||'</div>');
							else
								htp.p('<div data-touch="0" class="wd_move" style="cursor: move; padding: 4px 23px; border-radius: 7px 7px 0 0; cursor: default; text-align: center; '||fun.put_style(ws_obj, 'TIT_COLOR', ws_tip)||fun.put_style(ws_obj, 'TIT_BGCOLOR', ws_tip)||fun.put_style(ws_obj, 'TIT_IT', ws_tip)||fun.put_style(ws_obj, 'TIT_BOLD', ws_tip)||fun.put_style(ws_obj, 'TIT_FONT', ws_tip)||fun.put_style(ws_obj, 'TIT_SIZE', ws_tip)||'" id="'||prm_objeto||'_ds">'||fun.subpar(fun.utranslate('NM_OBJETO', prm_objeto, ws_nm_ponto, ws_padrao), prm_screen)||'</div>');
							end if;
						end if;

						ws_count := 0;
						htp.p('<div id="chart-container" class="block-fusion" style="'||(fun.put_style(ws_obj, 'COLOR', ws_tip))||' '||(fun.put_style(ws_obj, 'BOLD', ws_tip))||' '||(fun.put_style(ws_obj, 'IT', ws_tip))||' '||(fun.put_style(ws_obj, 'FONT', ws_tip))||' position: relative; overflow: auto; margin: 0 auto; height: calc(100% - 32px);"></div>');
						htp.p('<div style="display: none;" name="ngxml'||prm_objeto||'" id="gxml_'||prm_objeto||'">');
					    htp.p('</div>');
					    htp.p('</div>');

					when ws_tp_objeto = 'BROWSER' then
                        begin
				            BRO.browser(ws_obj, prm_screen);
				        exception when others then
                            htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
				        end;			
					else
                        htp.p('');
				    end case;
			    end if;
		    end if;
		end if;

	else
			/*posx é a ordem, posy vai ser a linha*/
			
			ws_posicao_section    := nvl(fun.getprop(prm_objeto,'POSICAO_SECTION',NULL,'DWU','SECTION'),null);
			ws_count              := 0;
			ws_bgColor_section    := nvl(fun.getprop(prm_objeto,'BGCOLOR_SECTION',NULL,'DWU','SECTION'),'TRANSPARENT');
			ws_altura_section     := nvl(fun.getprop(prm_objeto,'ALTURA_SECTION',NULL,'DWU','SECTION'),'60px');
			ws_padding_section    := nvl(fun.getprop(prm_objeto,'PADDING_SECTION',NULL,'DWU','SECTION'),'10px');
			ws_width_calc_section := 'width: calc(100% - '||to_char(2 * (to_number(replace(ws_padding_section,'px',''))) + 4) || 'px)';
			
			section_style := 'background: ' || NVL(ws_bgColor_section, 'TRANSPARENT') || '; flex-wrap: wrap; flex-direction: ' || prm_zindex ||'; padding: ' || ws_padding_section  ;
			if ws_posicao_section = 'SUPERIOR' then
				section_style := section_style || '; position: sticky; top: 34px; z-index: 8; order: -999; margin-top: 0px; min-height: ' || ws_altura_section || '; ' || ws_width_calc_section; 
			elsif ws_posicao_section = 'INFERIOR' then
				section_style := section_style || '; position: sticky; bottom: 0px; z-index: 8; order: 999; margin-bottom: 0px; min-height: ' || ws_altura_section || '; ' || ws_width_calc_section;
			else 
				section_style := section_style || '; order: '||prm_posx;
			end if;

			htp.p('<section id="' || prm_objeto || '" style="' || section_style || '">');

			if ws_admin = 'A' then

				obj.section_submenu (prm_objeto, prm_screen, prm_zindex);
				/******
				htp.p('<div class="submenu" onmousedown="event.stopPropagation();">');
					-- Botão adicionar Bloco 
					htp.p('<a class="adddash" title="'||fun.lang('adicionar bloco')||'" onclick="dashboard('''', ''insert'', '''||prm_objeto||''');">+</a>');
					-- Lista orientação 
					ws_style_aux := '';
					if ws_posicao_section in('SUPERIOR','INFERIOR') then 
						ws_style_aux := 'style="left:72px;"';
					end if;
					htp.p('<select '||ws_style_aux||' onchange="dashboard(document.getElementById(''current_screen'').value, ''rowcolumn'', '''||prm_objeto||''',  this.value);">');
						htp.p('<optgroup label="'||fun.lang('Formato')||'"></optgroup>');
						if prm_zindex = 'row' then
							htp.p('<option value="row" selected>'||fun.lang('Horizontal')||'</option>');
						else
							htp.p('<option value="row">'||fun.lang('Horizontal')||'</option>');
						end if;
						if prm_zindex = 'column' then
							htp.p('<option value="column" selected>'||fun.lang('Vertical')||'</option>');
						else
							htp.p('<option value="column">'||fun.lang('Vertical')||'</option>');
						end if;
					htp.p('</select>');

					-- Lista posição do bloco 
					ws_style_aux := 'style="left:122px;"';
					if ws_posicao_section in('SUPERIOR','INFERIOR') then 
						ws_style_aux := 'style="left:160px;"';
					end if;
					htp.p('<select '||ws_style_aux||' onchange="dashboard(document.getElementById(''current_screen'').value, ''posicao_section'', '''||prm_objeto||''',  this.value);">');
						htp.p('<optgroup label="'||fun.lang('Posi&ccedil;&atilde;o')||'"></optgroup>');
						if ws_posicao_section = 'SUPERIOR'  then
							htp.p('<option value="SUPERIOR" selected>'||fun.lang('Superior')||'</option>');
						else
							htp.p('<option value="SUPERIOR">'||fun.lang('Superior')||'</option>');
						end if;
						if ws_posicao_section = 'INFERIOR' then
							htp.p('<option value="INFERIOR" selected>'||fun.lang('Inferior')||'</option>');
						else
							htp.p('<option value="INFERIOR">'||fun.lang('Inferior')||'</option>');
						end if;
						if ws_posicao_section is null then
							htp.p('<option value="" selected>'||fun.lang('Normal')||'</option>');
						else
							htp.p('<option value="">'||fun.lang('Normal')||'</option>');
						end if;
					htp.p('</select>');
					
					-- Margem interna 
					if ws_posicao_section in('SUPERIOR','INFERIOR') then 
						htp.p('<input style="left:249px; top: auto; bottom: 4px; width:60px;"  title="Margem interna" onkeypress="if(event.which == ''13''){ this.blur(); }" onblur="dashboard('''||prm_screen||''', ''padding_section'', '''||prm_objeto||''', this.value);" value="'||ws_padding_section||'" >');	
					else 
						htp.p('<input style="left:208px; top: auto; bottom: 4px; width:60px;"  title="Margem interna" onkeypress="if(event.which == ''13''){ this.blur(); }" onblur="dashboard('''||prm_screen||''', ''padding_section'', '''||prm_objeto||''', this.value);" value="'||ws_padding_section||'" >');	
					end if;
					-- Altura do bloco 
					if ws_posicao_section in('SUPERIOR','INFERIOR') then 
						htp.p('<input style="left:318px; top: auto; bottom: 4px; width:60px;"  title="Altura m&iacute;nima" onkeypress="if(event.which == ''13''){ this.blur(); }" onblur="dashboard('''||prm_screen||''', ''altura_section'', '''||prm_objeto||''', this.value);" value="'||ws_altura_section||'" >');	
					end if;
					
					htp.p('<input style="left:4px; width:60px;"  title="'||fun.lang('Cor do Fundo')||'" onkeypress="if(event.which == ''13''){ this.blur(); }" onblur="dashboard('''||prm_screen||''', ''background_section'', '''||prm_objeto||''', this.value);" value="'||ws_bgColor_section||'" >');	
                   
                    htp.p(fun.excluir_dash(prm_objeto));
				htp.p('</div>');
                ************************************/ 
			end if;
			for i in (select object_id, posy, posx, zindex, decode(porcentagem, '0', '', porcentagem) as porcentagem 
			            from object_location where screen = prm_objeto order by posx) loop

				if prm_zindex = 'row' then
				    select count(*) into ws_count from object_location where screen = prm_objeto;
				    ws_posicao := 100/ws_count;
					ws_posicao := '0 1 '||ws_posicao||'%';
				else
				    ws_posicao := '0 0 auto';
				end if;
				ws_bgColor_article:=nvl(fun.getprop(i.object_id,'BGCOLOR_ARTICLE',NULL,'DWU','ARTICLE'),'TRANSPARENT');
				
				if ws_posicao_section is not null then 
					ws_altura_article := 'min-height: ' || ws_altura_section;
				end if;

				htp.p('<article id="'||i.object_id||'" style="justify-content: '||i.posy||'; background:'||nvl(ws_bgColor_article,'TRANSPARENT')||'; align-items: '||i.posy||'; flex-direction: '||i.zindex||'; order: '||nvl(i.posx, 1)||'; flex-basis: '||nvl('calc('||i.porcentagem||' - 6.4px)', 'auto')||';' ||ws_altura_article|| '">');
					if ws_admin = 'A' then
						htp.p('<div class="articlemenu" onmousedown="event.stopPropagation();">');
							htp.p(fun.excluir_dash(i.object_id));
							htp.p('<select onchange="dashboard('''||prm_objeto||''', ''align'', '''||i.object_id||''', this.value);">');
								htp.p('<optgroup label="'||fun.lang('Alinhamento')||'"></optgroup>');
								if i.posy = 'flex-start' then
								    htp.p('<option value="flex-start" selected>'||fun.lang('Esquerda')||'</option>');
								else
								    htp.p('<option value="flex-start">'||fun.lang('Esquerda')||'</option>');
								end if;
								if i.posy = 'flex-end' then
								    htp.p('<option value="flex-end" selected>'||fun.lang('Direita')||'</option>');
								else
								    htp.p('<option value="flex-end">'||fun.lang('Direita')||'</option>');
								end if;
								if i.posy = 'center' then
								    htp.p('<option value="center" selected>'||fun.lang('Centro')||'</option>');
								else
								    htp.p('<option value="center">'||fun.lang('Centro')||'</option>');
								end if;
								if i.posy = 'inherit' then
								    htp.p('<option value="inherit" selected>'||fun.lang('Todo')||'</option>');
								else
								    htp.p('<option value="inherit">'||fun.lang('Todo')||'</option>');
								end if;
							htp.p('</select>');
							htp.p('<select onchange="dashboard('''||prm_objeto||''', ''rowcolumn'', '''||i.object_id||''', this.value);">');
								htp.p('<optgroup label="Formato"></optgroup>');
								if i.zindex = 'row' then
									htp.p('<option value="row" selected>'||fun.lang('Horizontal')||'</option>');
								else
									htp.p('<option value="row">'||fun.lang('Horizontal')||'</option>');
								end if;
								if i.zindex = 'column' then
									htp.p('<option value="column" selected>'||fun.lang('Vertical')||'</option>');
								else
									htp.p('<option value="column">'||fun.lang('Vertical')||'</option>');
								end if;
							htp.p('</select>');

							
							
							htp.p('<input style="left:52px; width:60px;"  title="'||fun.lang('Cor do Fundo')||'" onkeypress="if(event.which == ''13''){ this.blur(); }" onblur="dashboard('''||prm_objeto||''', ''background_article'', '''||i.object_id||''', this.value);" value="'||ws_bgColor_article||'" >');	
							--htp.p('<input style="left:96px; width:74px;" autocomplete="on" type="text" placeholder="" title="DICA: pode ser usado transparent no campo de cor" style="width: 70px;" value="'||bgColor_article||'" oninput="this.previousElementSibling.value = this.value; ">');
							
							htp.p('<input id="'||i.object_id||'ordem" onkeypress="if(event.which == ''13''){ this.blur(); }" onblur="dashboard('''||prm_objeto||''', ''ordem'', '''||i.object_id||''', this.value);" value="'||nvl(i.posx, 1)||'" placeholder="'||fun.lang('ordem')||'" title="'||fun.lang('ORDEM')||'">');

							htp.p('<input onkeypress="if(event.which == ''13''){ this.blur(); }" onblur="dashboard('''||prm_objeto||''', ''porcentagem'', '''||i.object_id||''', this.value);" value="'||i.porcentagem||'" placeholder="'||fun.lang('medida')||'" title="'||fun.lang('MEDIDA')||'">');

                            htp.p('<img title="'||fun.lang('Inserir objeto')||'" src="'||nvl(fun.ret_var('OWNER_BI'),'DWU')||'.fcl.download?arquivo=folder.png" onclick="closeSideBar(''attriblist''); document.getElementById(''attriblist'').classList.toggle(''open''); ajax(''list'', ''lista_objetos'', '''', false, ''attriblist'');">');
							htp.p('<a class="adddash" title="'||fun.lang('adicionar bloco')||'" onclick="dashboard('''', ''insertnv1'', '''||prm_objeto||''');">+</a>');
						htp.p('</div>');
					end if;

					for a in (select object_id, posy, posx, zindex from object_location where trim(screen) = trim(i.object_id) and object_id not like 'ARTICLE%' order by posx) loop
						obj.show_objeto(a.object_id, a.posx, a.posy, '', prm_zindex => a.zindex, prm_dashboard => 'true', prm_screen => prm_screen, prm_usuario => ws_usuario);
					end loop;

				htp.p('</article>');
			end loop;

		htp.p('</section>');
	end if;

	exception 
		when ws_nouser then
			htp.p('Sem permiss&atilde;o!');
		when others then
			insert into bi_log_sistema values(sysdate, 'SHOW_OBJETO ('||prm_objeto||'): '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, ws_usuario, 'ERRO');
			commit;	
			htp.p('</div>');
end SHOW_OBJETO;


procedure subquery ( prm_objid       varchar2 default null,
					 prm_parametros  varchar2 default '1|1',
					 prm_micro_visao varchar2 default null,
					 prm_coluna	 	 varchar2 default null,            -- coluna da subquery
					 prm_agrupador	 varchar2 default null,
					 prm_rp		 	 varchar2 default 'GROUP',
					 prm_colup	 	 varchar2 default null,
					 prm_screen		 varchar2 default 'DEFAULT',
					 prm_ccount		 char default '0',
					 prm_drill		 char default 'N',
					 prm_ordem		 number default 1,                 -- ordem da subquery 
					 prm_self        varchar2 default null,
					 prm_usuario 	 varchar2 default null,
					 prm_cd_goto     varchar2 default null,
                     prm_popup_drill varchar2 default 'false' ) as


	cursor crs_micro_visao is
			select	rtrim(cd_grupo_funcao) as cd_grupo_funcao
			from 	MICRO_VISAO where nm_micro_visao = prm_micro_visao;

	ws_micro_visao crs_micro_visao%rowtype;

	cursor crs_xgoto(prm_usuario varchar2) is
			select	rtrim(cd_objeto_go) as cd_objeto_go
			from 	GOTO_OBJETO where cd_objeto = prm_objid and
			        cd_objeto_go not in ( select cd_objeto from OBJECT_RESTRICTION where USUARIO = prm_usuario )
			order by cd_objeto_go;

	cursor nc_colunas is 
	        select a.*, 'N' invisivel_objeto, 0 qt_destaque_celula, 0 qt_destaque_linha, 0 qt_destaque_total , 0 qt_destaque_refcol
              from MICRO_COLUNA a 
             where cd_micro_visao = prm_micro_visao;

	ws_xgoto crs_xgoto%rowtype;

	type ws_tmcolunas is table of nc_colunas%ROWTYPE
			    		index by pls_integer;

	type generic_cursor is ref cursor;

	crs_saida generic_cursor;

	ret_coluna			varchar2(4000);
	ret_mcol			ws_tmcolunas;     -- Colunas da micro visão 
	ret_scol            ws_tmcolunas;     -- Colunas do Select 
    
    -- para aplicar destaques baseados em outras colunas
    ws_pre_suf_alias    varchar2(100); 
	arr_destaq_col      DBMS_SQL.VARCHAR2_TABLE; 
	arr_destaq_val      DBMS_SQL.VARCHAR2_TABLE;
    ret_colgrp          varchar2(2000);

	ws_ncolumns			DBMS_SQL.VARCHAR2_TABLE;
	ws_pvcolumns		DBMS_SQL.VARCHAR2_TABLE;
	ws_mfiltro			DBMS_SQL.VARCHAR2_TABLE;
	ws_vcol				DBMS_SQL.VARCHAR2_TABLE;
	ws_vcon				DBMS_SQL.VARCHAR2_TABLE;

	ws_drill			varchar2(40);
	ws_zebrado			varchar2(20);
	ws_zebrado_d		varchar2(40);
	ws_queryoc			clob;
	ws_pipe				char(1);

	ws_posx				varchar(5);
	ws_posy				varchar(5);

	ret_colup			long;
	ws_lquery			number;
	ws_counterid			number := 0;
	ws_counter			number;
	ws_ccoluna			number;
	ws_xcoluna			number := 0;
	ws_bindn			number := 0;
	ws_scol				number := 0;
	ws_cspan			number := 0;
	ws_xcount			number := 0;

	ws_texto			long;
	ws_nm_var			long;
	ws_content_ant		long;
	ws_content			long;
	ws_colup			long;
	ws_coluna			long;
	ws_agrupador		long;
	ws_rp				long;
	ws_xatalho			long;
	ws_atalho			long;
	ws_parametros		long;
	ws_agrupador_max    number;

	ws_acesso			exception;
	ws_semquery			exception;
	ws_sempermissao		exception;
	ws_pcursor			integer;
	ws_cursor			integer;
	ws_linhas			integer;
	ws_query_montada	dbms_sql.varchar2a;
	ws_query_count      dbms_sql.varchar2a;
	ws_query_pivot		long;
	ws_sql				long;
	ws_sql_pivot		long;
	ws_binds            long; 

	ws_titulo			varchar2(150);
	ws_mode				varchar2(30);
	ws_idcol			varchar2(120);
	ws_firstid			char(1);

	ws_vazio			boolean := True;
	ws_nodata       	exception;
	ws_invalido			exception;
	ws_close_html		exception;
	ws_mount			exception;
	ws_parseerr			exception;

	ws_posicao			varchar2(2000) := ' ';
	ws_drill_atalho		varchar2(3000);
	ws_ctemp			varchar2(40);
	ws_jump				varchar2(600);
	ws_sem				varchar2(40);
	ws_step             number;
	ws_stepper          number := 0;
	ws_linha            number := 0;
	ws_fixed            varchar2(40);
	ws_ct_top           number := 0;
	ws_pivot            varchar2(300);
	ret_coltot          varchar2(2000);
	ws_temp_valor       number := 0;
	ws_isolado          varchar2(60);
	ws_repeat           varchar2(60) := 'show';
	ws_cab_cross        varchar2(4000) := 'N';
	ws_col_aux          varchar2(500);
    --
    ws_com_cod_prin     varchar2(10); 
	ws_cd_lig_prin      varchar2(300); 
	--
	ws_subquery         varchar2(600);
	ws_ordem            number;
	ws_color            varchar2(60);
	ws_self             varchar2(400);
	ws_count            number;
	ws_cor              varchar2(400);
	ws_fix              varchar2(80);
	ws_inv              varchar2(5); 
    ws_usuario          varchar2(80);
	ws_admin            varchar2(20); 
	ws_cols_inv         varchar2(1000); 
	ws_style_cel        varchar2(1000);
	ws_blink_cel        varchar2(2000);
    ws_blink_linha      varchar2(4000) := 'N/A';
  	ws_data_i           number; 
	ws_prop_usuario_anotacao  varchar2(4000); 
	ws_anot_cond        varchar2(32000); 
	ws_condicao    		varchar2(32000); 
	ws_usua_perm   		varchar2(32000); 
	ws_anot_texto  		varchar2(32000); 
	ws_anot_svg    		varchar2(4000); 
	ws_anot_class  		varchar2(20); 
	rec_tab				DBMS_SQL.DESC_TAB;
	dat_coluna          date;
	ws_log_exec         varchar2(10);
	ws_log_exec_id           varchar2(200);

    ws_ordem_query      varchar2(400);
    ws_ordem_drill      varchar2(400);
	ws_quebra_texto     varchar2(20);


    -- subprocedures copiadas da procedure consulta
    procedure ret_column_value (prm_counter     number,
	                            prm_dat_coluna   out date,
								prm_ret_coluna   out varchar2,
								prm_content      out varchar2,
								prm_content_anot out varchar2) as
	begin
		begin
			prm_content := null;
			prm_dat_coluna := null;
			prm_ret_coluna := null;

			if rec_tab(prm_counter).col_type = 12 then
				dbms_sql.column_value(ws_cursor, prm_counter, prm_dat_coluna);
				if ret_mcol(ws_ccoluna).nm_mascara = 'SEM' then
					prm_content := to_char(prm_dat_coluna, 'DD/MM/RRRR HH24:MI');
				else
					prm_content := prm_dat_coluna;
				end if;
				prm_content_anot := prm_content;
				prm_ret_coluna   := prm_dat_coluna;
			else
				begin
					dbms_sql.column_value(ws_cursor, prm_counter, prm_ret_coluna);
				exception when others then
					dbms_sql.column_value(ws_cursor, prm_counter, prm_ret_coluna);
				end;
				-- ws_content_anot := prm_ret_coluna; 

				prm_content := replace(prm_ret_coluna,'"',     '&#34;');
				prm_content := replace(prm_content,chr(39), '&#39;');
				prm_content := replace(prm_content,'/',     '&#47;');
				prm_content := replace(prm_content,'<',	  '&#60;');
				prm_content := replace(prm_content,'>',	  '&#62;');
			
			end if;
		exception when others then
			dbms_sql.column_value(ws_cursor, prm_counter, prm_ret_coluna);
			prm_content := prm_ret_coluna;
		end;	

		if instr(prm_content, '[LC]') > 0 then 
			prm_content := replace(prm_content, '[LC]', '');
		end if;		
	end ret_column_value; 


	procedure monta_arr_destaque as 
		ws_dat_aux        date;
		ws_ret_aux        varchar2(4000);
		ws_destaq_content varchar2(5000);
		ws_anot_aux       varchar2(5000);
	begin
		arr_destaq_col.delete;
		arr_destaq_val.delete;
		for a in 1..ws_ncolumns.count  loop
			ret_column_value (a, ws_dat_aux, ws_ret_aux, ws_destaq_content, ws_anot_aux);
			arr_destaq_val(a) := ws_destaq_content; 
			arr_destaq_col(a) := rec_tab(a).col_name; 
		end loop;
	exception when others then 
		insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values(sysdate, 'SUBQUERY MONTA_ARR ['||prm_objid||']:'||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, ws_usuario, 'ERRO');
		commit;
	end monta_arr_destaque; 

begin


    ws_usuario := prm_usuario;
    if ws_usuario is null then    
        ws_usuario := gbl.getUsuario;
    end if;
	ws_admin   := gbl.getnivel; 

	if nvl(fun.ret_var('LOG_EXEC'),'N') in ('S','D') then 
		ws_log_exec    := fun.ret_var('LOG_EXEC');
		ws_log_exec_id := null;
	end if; 	

    ws_ordem  := prm_ordem+1;
	ws_counter := 1;

	ws_prop_usuario_anotacao := nvl(fun.getprop (prm_objid, 'USUARIO_ANOTACAO'),'NENHUM');

	-- Pega a coluna da subquery conforma a ordem que está sendo aberta
	for i in (select column_value from table(fun.vpipe((fun.getprop(prm_objid,'SUBQUERY'))))) loop
	    if ws_counter = ws_ordem then
		    ws_subquery := i.column_value;
		end if;
		ws_counter := ws_counter+1;
	end loop;

	-- Pega a cor de fundo da Subquery conforme o nível aberto 
	ws_cor := fun.getprop(prm_objid, 'SUBQUERY-COR');
    begin
        select cor into ws_color from (select nvl(column_value, '#EFEFEF') cor, rownum linha from table(fun.vpipe(ws_cor))) where linha = prm_ordem;
        if instr(ws_color, '#') > 1 then
    	    ws_color := substr(ws_color, 2, length(ws_color)-1);
        end if;
    exception when others then
	    ws_color := '#EFEFEF';
	end;

	htp.p('<style>');
	htp.p('table#'||prm_objid||'trlc tbody tr.nivel'||ws_ordem||', table#'||prm_objid||'c tbody tr.nivel'||ws_ordem||', div#'||prm_objid||'trlheader table tbody tr.nivel'||ws_ordem||' { background-color: '||ws_color||' !important; }');
	htp.p('div#'||prm_objid||'header table tbody tr.nivel'||ws_ordem||', div#'||prm_objid||'trlfixed ul li.nivel'||ws_ordem||', div#'||prm_objid||'fixed ul li.nivel'||ws_ordem||' { background-color: '||ws_color||' !important; }'); 
	htp.p('div#'||prm_objid||'trlfixed ul li.nivel'||ws_ordem||', div#'||prm_objid||'fixed ul li.nivel'||ws_ordem||', div#'||prm_objid||'trlfixed ul li.nivel'||ws_ordem||' { text-indent: '||ws_ordem||'px; }');
	htp.p('div#'||prm_objid||'fixed ul li.nivel'||ws_ordem||', table#'||prm_objid||'trlc tbody tr.nivel'||ws_ordem||' td:nth-child(2), table#'||prm_objid||'c tbody tr.nivel'||ws_ordem||' td:nth-child(2) { text-indent: '||ws_ordem||'px; }');
	htp.p('table#'||prm_objid||'c tbody tr.nivel'||ws_ordem||' td:nth-child(3), div#'||prm_objid||'trlheader table tbody tr.nivel'||ws_ordem||' td:nth-child(2), div#'||prm_objid||'trlheader table tbody tr.nivel'||ws_ordem||' td:nth-child(3) { text-indent: '||ws_ordem||'px; }');
	htp.p('div#'||prm_objid||'header table tbody tr.nivel'||ws_ordem||' td:nth-child(2), div#'||prm_objid||'header table tbody tr.nivel'||ws_ordem||' td:nth-child(3) { text-indent: '||ws_ordem||'px; }');
	if fun.getprop(prm_objid,'FIXAR_TOT') = 'S' then
	    htp.p('table#'||prm_objid||'trlc tbody tr:last-child td { bottom: 0; position: sticky; }');
	end if;
	htp.p('</style>');

    ws_zebrado   := 'First';

	ws_isolado   := fun.getprop(prm_objid, 'FILTRO');
	ws_colup     := prm_colup;
	ws_coluna    := prm_coluna;
	ws_agrupador := fun.conv_template(prm_micro_visao, prm_agrupador);
	ws_rp	     := 'GROUP';

	open  crs_micro_visao;
	fetch crs_micro_visao into ws_micro_visao;
	close crs_micro_visao;

	ws_texto      := prm_parametros;
    ws_parametros := prm_parametros;
	ws_self       := prm_self;

	if instr(ws_self, '|') = 1 then
	    ws_self := substr(ws_self, 2 ,length(ws_self)-1);
	end if;

	ws_self := replace(ws_self, '||', '|');
    
    --teste goto_objeto
    ws_ordem_drill := null;
    if prm_popup_drill <> 'false' and nvl(prm_cd_goto,0) <> 0 then 
        -- Procura ordenação da drill,  1-prm_screm+ws_usuario, 2-DEFAULT+ws_usuario, 3-DEFAULT+DWU
        for a in 1..3 loop
            if ws_ordem_drill is null then 
                select max(upper(propriedade)) 
                  into ws_ordem_drill 
                  from object_attrib 
                 where cd_object = prm_objid||'trl'||prm_cd_goto
                   and cd_prop   = 'ORDEM' 
                   and screen    = decode(a,1,prm_screen,'DEFAULT') 
                   and owner     = decode(a,3,'DWU',ws_usuario);
            end if; 
        end loop; 
        --
        select nvl(ws_coluna, max(cs_coluna)), nvl(max(cs_agrupador), ws_agrupador), nvl(max(cs_colup), ws_colup), nvl(ws_ordem_drill, max(orderby))
          into ws_coluna, ws_agrupador, ws_colup, ws_ordem_drill 
          from GOTO_OBJETO
         where cd_goto_objeto = prm_cd_goto ; 
        --
    end if;
    ws_ordem_query := null;
    if prm_popup_drill <> 'false' and ws_ordem_drill is not null then 
        ws_ordem_query := ws_ordem_drill;
    else
        ws_ordem_query := fun.getprop(prm_objid,'SUBQUERY_ORDEM');
	end if; 	

    if instr(ws_coluna, '|') > 0 then
	    ws_coluna := substr(ws_coluna, 0, length(ws_coluna)-1);
	end if;

	ws_sql := core.MONTA_QUERY_DIRECT(prm_micro_visao, ws_coluna, ws_parametros, ws_rp, ws_colup, ws_query_pivot, ws_query_montada, ws_lquery, ws_ncolumns, ws_pvcolumns, ws_agrupador, ws_mfiltro, prm_objid, fun.getprop(prm_objid,'SUBQUERY_ORDEM',prm_screen,'DWU'), prm_screen => prm_screen, prm_cross => 'N', prm_cab_cross => ws_cab_cross, prm_self => 'SUBQUERY_'||ws_self,prm_usuario => ws_usuario, prm_popup_drill=>prm_popup_drill );

	ws_sql_pivot := ws_query_pivot;
	ws_counter   := 0;
	ws_counterid := 1;
    ws_step      := 0;

	ws_repeat := 'show';
	ws_firstid := 'Y';
    ws_agrupador_max :=0;

	-- Faz substituição dos BINDs
	ws_cursor := dbms_sql.open_cursor;
	dbms_sql.parse( c => ws_cursor, statement => ws_query_montada, lb => 1, ub => ws_lquery, lfflg => true, language_flag => dbms_sql.native );
	dbms_sql.describe_columns(ws_cursor, ws_counter, rec_tab);
	ws_binds := core.bind_direct(replace(ws_parametros||'|'||ws_self, '||', '|'), ws_cursor, '', prm_objid, prm_micro_visao, prm_screen,prm_usuario => ws_usuario);
	ws_binds := replace(ws_binds, 'Binds Carregadas=|', '');
	-- Pega o texto da Query 
	ws_queryoc := '';
	ws_counter := 0;
	loop
	    ws_counter := ws_counter + 1;
	    if  ws_counter > ws_query_montada.COUNT then
	    	exit;
	    end if;
	    ws_queryoc := ws_queryoc||ws_query_montada(ws_counter);
		htp.p(ws_query_montada(ws_counter));
	end loop;

	if ws_admin = 'A' then  -- Grava a ultima query executada para o objeto
		begin  
			ws_queryoc := substr(fun.replace_binds_clob (ws_queryoc, ws_binds),1,32000); 
			delete bi_object_query where cd_object = prm_objid and nm_usuario = ws_usuario;
			insert into bi_object_query (cd_object, nm_usuario, dt_ultima_execucao, query) values (prm_objid, ws_usuario, sysdate, ws_queryoc ); 
		exception when others then 
			insert into bi_log_sistema values (sysdate,'Erro gravando em bi_object_query ['||prm_objid||']:'|| DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, ws_usuario,'ERRO');
		end; 
		commit;	
	end if;
	if ws_log_exec in ('S','D') then 
		fun.log_exec_atu ('INSERT', ws_log_exec, ws_log_exec_id, prm_objid, ws_usuario, 'SUBQUERY', 10, 'INICIO', ws_queryoc); 
	end if; 

	-- Define o tamanho das colunas do do cursor 
	ws_counter := 0;
	loop
	    ws_counter := ws_counter + 1;
	    exit when (ws_counter > ws_ncolumns.COUNT); 
	    	begin
				if rec_tab(ws_counter).col_type = 12 then
					dbms_sql.define_column(ws_cursor, ws_counter, dat_coluna);

				else
					dbms_sql.define_column(ws_cursor, ws_counter, ret_coluna, 3000);

				end if;
			exception 
			    when others then
				    dbms_sql.define_column(ws_cursor, ws_counter, ret_coluna, 3000);

			end;
	end loop; 
    dbms_sql.describe_columns(ws_cursor, ws_counter, rec_tab);
	ws_linhas := dbms_sql.execute(ws_cursor);


	-- Carrega todas as colunas da visão num array 
	open nc_colunas;
	loop
		fetch nc_colunas bulk collect into ret_mcol limit 2000;
		exit when nc_colunas%NOTFOUND;
	end loop;
	close nc_colunas;

	-- Carrega as colunas da query (com as propriedades de cada coluna) (carrega também)
	ws_cols_inv := fun.getprop(prm_objid, 'VISIVEL');	
	ws_counter  := 0;
	loop
	    ws_counter := ws_counter + 1;
	    exit when (ws_counter > ws_ncolumns.COUNT); 
		ws_ccoluna := 0;
		loop
			ws_ccoluna := ws_ccoluna + 1;
			exit when (ws_ccoluna > ret_mcol.COUNT);
			if ret_mcol(ws_ccoluna).cd_coluna = ws_ncolumns(ws_counter)  then
				ret_scol(ws_counter) := ret_mcol(ws_ccoluna);
				ws_ccoluna := -1 ;
				exit;
			end if;
			if ws_ccoluna <> -1 then -- se não encontrou cria a linha sem propriedades 
				ret_scol(ws_counter).cd_coluna := ws_ncolumns(ws_counter);
			end if; 
		end loop;
		if fun.setem(ws_cols_inv, ret_scol(ws_counter).cd_coluna) then  -- Verifica se está parametrizada como invisivel no objeto 
			ret_scol(ws_counter).invisivel_objeto := 'S'; 	
		end if; 
	end loop;


	-- Pega do select somente as colunas agrupadoras - ws_vcol e ws_vcon 
	ws_counter := 0;
	loop
	    ws_counter := ws_counter + 1;
	    exit when (ws_counter > ws_ncolumns.COUNT-2); 
	    if  ret_scol(ws_counter).st_agrupador = 'SEM' then
	        ws_vcol(ws_counter) := ret_scol(ws_counter).cd_coluna;
	        ws_vcon(ws_counter) := 'First';
	    end if;
	end loop;


	-- Verifica se a coluna da consulta principal tem e mostra o código
	select cs_coluna     into ws_col_aux      from ponto_avaliacao where cd_ponto = prm_objid;
	select column_value  into ws_col_aux      from table(fun.vpipe((ws_col_aux))) where rownum = 1;
	select st_com_codigo, cd_ligacao into ws_com_cod_prin, ws_cd_lig_prin from micro_coluna where cd_coluna = ws_col_aux and cd_micro_visao = prm_micro_visao;

	-- Percorre as LINHAS retornadas pelo select 
	--------------------------------------------------------------------
	loop
	    ws_linhas := dbms_sql.fetch_rows(ws_cursor);
	    if  ws_linhas = 1 then
		    ws_vazio := False;
	    else
            if  ws_vazio = True then
	            dbms_sql.close_cursor(ws_cursor);
      		    raise ws_nodata;
        	end if;
        	exit;
	    end if;

        ws_blink_linha := 'N/A';
		ws_linha  := ws_linha + 1;
		ws_ct_top := ws_ct_top + 1;

		if  ws_zebrado in ('First','Escuro') then
			ws_zebrado   := 'Claro';
			ws_zebrado_d := 'Distinto_claro';
		else
			ws_zebrado   := 'Escuro';
			ws_zebrado_d := 'Distinto_escuro';
		end if;

	    -- Monta o atalho para abertura dos outros níveis ou DRILLS
		ws_xatalho := '';
	    ws_pipe    := '';
	    ws_bindn := 1;
		if  ws_bindn = 1 or ws_ncolumns(ws_bindn) <> ws_ncolumns(ws_bindn-1) then
            begin -- copiado da consulta card 434a nao trazendo datas por exception ORA-06562
                if rec_tab(ws_bindn).col_type = 12 then
                    dbms_sql.column_value(ws_cursor, ws_bindn, dat_coluna);
                    ws_vcon(ws_bindn) := to_char(dat_coluna,'dd/mm/rrrr hh24:mi:ss');     -- Card: 536a - 22/05/2024 
                    -- ws_cod_coluna := dat_coluna;
                    ret_coluna    := dat_coluna;
                else
                    dbms_sql.column_value(ws_cursor, ws_bindn, ret_coluna);
                    ws_vcon(ws_bindn) := ret_coluna;
                    -- ws_cod_coluna := ret_coluna;
                end if;
            exception when others then
                dbms_sql.column_value(ws_cursor, ws_bindn, ret_coluna);
                ws_vcon(ws_bindn) := ret_coluna;
                -- ws_cod_coluna := ret_coluna;
            end;
		    -- dbms_sql.column_value(ws_cursor, ws_bindn, ret_coluna);
		    -- ws_vcon(ws_bindn) := ret_coluna;
		    if  nvl(ws_vcon(ws_bindn),'%*') <> '%*' then
		        ws_xatalho := ws_xatalho||ws_pipe;
				ws_xatalho := trim(ws_xatalho)||ws_vcol(ws_bindn)||'|'||replace(ws_vcon(ws_bindn),'|','@PIPE@');   -- Subsitui |, se houver no texto (para resolver erro nos parametros da DRILL)  
				ws_pipe    := '|';
		    end if;
		end if;

		ws_drill_atalho := replace('|'||trim(ws_xatalho),'||','|');
		if(instr(ws_drill_atalho, '|', 1, 1) = 1) then
		  ws_drill_atalho := substr(ws_drill_atalho,2,length(ws_drill_atalho));   -- Retira o Pipe da frente se existir 
		end if;




		-- Define as colunas fixas da tabela 
		ws_fixed := nvl(fun.getprop(prm_objid, 'FIXED-N'), '9999') + 1;

		if length(fun.getprop(prm_objid,'TOTAL_GERAL_TEXTO')) > 0 and ws_fixed > 0 then
		    ws_fixed := 999;
		end if;
		if ws_fixed > 1 then
			ws_fix   := 'fixsub';
			ws_fixed := ws_fixed-1;
		else
			ws_fix   := '';
		end if;


		-- Define o tipo de seta 
		if(length(ws_subquery) > 0) then
		    ws_jump := 'seta';
		else
		    ws_jump := 'setadown';
		end if;
		

		-- Abre a linha <TR> 
		if(ws_zebrado = 'Escuro') then
			htp.p('<tr data-tipo="'||ws_zebrado||'" class="es sub nivel'||ws_ordem||'">');
		else
			htp.p('<tr data-tipo="'||ws_zebrado||'" class="cl sub nivel'||ws_ordem||'">');
		end if;

		-- Cria a primeira coluna com a seta 
		htp.p('<td class="'||ws_jump||' '||ws_fix||'" data-ordem="'||ws_ordem||'" data-valor="'||replace(ws_parametros||'|'||ws_drill_atalho, '||', '|')||'" data-self="'||ws_drill_atalho||'"  data-subquery="'||ws_subquery||'"></td>');
		ws_anot_cond := replace(ws_parametros||'|'||ws_drill_atalho, '||', '|'); 



		-- Percorre as COLUNAS/CAMPOS  da linha 
		--------------------------------------------------------------------
	    ws_counter := 0;
		ws_data_i  := 0;
		loop
            ws_blink_cel := '';
			ws_counter := ws_counter + 1;
			ws_data_i  := ws_data_i  + 1; 

			exit when (ws_counter > ws_ncolumns.COUNT-2); 

			begin
				if(ws_counter) < ws_step-(ws_stepper) then
					ws_atalho := ws_mfiltro(ws_counter+1);
				else
					ws_atalho := '';
				end if;
			exception
				when others then
				ws_atalho := '';
			end;
			ws_drill_atalho := replace(trim(ws_atalho)||'|'||trim(ws_xatalho),'||','|');
			if(instr(ws_drill_atalho, '|', 1, 1) = 1) then
				ws_drill_atalho := substr(ws_drill_atalho,2,length(ws_drill_atalho));
			end if;


			ws_idcol := '';
			/*********** 	
			-- Analisar se pode e precisa colocar esse ID já que fica o mesmo da primeira linha da consulta 
			if  ws_firstid = 'Y' then
				ws_idcol := ' id="'||prm_objid||ws_counter||'l" ';
			end if;
			*****************/ 

			ws_fix   := null;
			if ret_scol(ws_counter).st_agrupador = 'SEM' then 
				if ws_fixed > 1 then
					ws_fix   := 'fixsub';
					ws_fixed := ws_fixed - 1;
				end if;
				ws_fix:= ws_fix||' colagr';
			end if;	 
			
			ws_quebra_texto := '';
			if ret_scol(ws_counter).quebra_texto = 'S' then 
				ws_quebra_texto := ' quebra-texto ';
			end if; 

			-- Define se oculta a coluna inteira ou código 
			ws_inv := '';
			if ret_scol(ws_counter).invisivel_objeto = 'S' then 
				ws_inv := 'inv';
			elsif ws_counter > 1 then 
				if ret_scol(ws_counter).st_agrupador = 'SEM' then

					-- Se a coluna atual é diferente da anterior e igual a proxima, então é a coluna do código, verifica se mostra o código ou não  				
					if ret_scol(ws_counter).cd_coluna <> ret_scol(ws_counter-1).cd_coluna and ret_scol(ws_counter).cd_coluna = ret_scol(ws_counter+1).cd_coluna then 
						if ret_scol(ws_counter).st_com_codigo = 'N' then 
							ws_inv := 'inv';
						end if; 
					end if;	
				end if;
			end if; 	

			if length(trim(ws_atalho)) > 0 and ws_ct_top = 1 then
				ws_pivot := 'data-p="'||trim(ws_atalho)||'" ';
			else
				ws_pivot := '';
			end if;
			
			-- Pega o conteúdo do campo/coluna  
			
			--dbms_sql.column_value(ws_cursor, ws_counter, ret_coluna);

			begin

				if rec_tab(ws_counter).col_type = 12 then
					dbms_sql.column_value(ws_cursor, ws_counter, dat_coluna);

					if ret_scol(ws_counter).nm_mascara = 'SEM' then
						ws_content := to_char(dat_coluna, 'DD/MM/YYYY HH24:MI');

					else
						ws_content := dat_coluna;

					end if;
					ret_coluna      := dat_coluna;
				else
					begin

						dbms_sql.column_value(ws_cursor, ws_counter, ret_coluna);

					exception when others then

						dbms_sql.column_value(ws_cursor, ws_counter, ret_coluna);
					end;
					--ws_content_anot := ret_coluna; 
					ws_content := replace(ret_coluna,'"',     '&#34;');
					ws_content := replace(ws_content,chr(39), '&#39;');
					ws_content := replace(ws_content,'/',     '&#47;');
					ws_content := replace(ws_content,'<',	  '&#60;');
					ws_content := replace(ws_content,'>',	  '&#62;');
					
				end if;
				
			exception when others then
				dbms_sql.column_value(ws_cursor, ws_counter, ret_coluna);
				ws_content := ret_coluna;
			end;

			/* ret_coluna := replace(ret_coluna,'"','*');
			ret_coluna := replace(ret_coluna,'/',' ') ;*/

            -- Verifica se tem destaque para a coluna -- v001
            select sum(DECODE(lower(tipo_destaque),'normal',1,'celula barra',1,0)), 
                   sum(DECODE(lower(tipo_destaque),'linha' ,1,'estrela',     1,0)), 
                   sum(DECODE(lower(tipo_destaque),'total' ,1,'total barra', 1,0)),
                   sum(DECODE(instr(conteudo,'!['),0,0,1))
              into ret_scol(ws_counter).qt_destaque_celula,
                   ret_scol(ws_counter).qt_destaque_linha, 
                   ret_scol(ws_counter).qt_destaque_total,
                   ret_scol(ws_counter).qt_destaque_refcol
              from destaque
             where ( cd_usuario in (ws_usuario, 'DWU') OR cd_usuario in (select cd_group from gusers_itens where cd_usuario = ws_usuario) ) 
               and cd_objeto      = prm_objid 
               and cd_coluna      = ret_scol(ws_counter).cd_coluna; 

			-- Coluna agrupadora 
			if ret_scol(ws_counter).st_agrupador = 'SEM' then 
				
				ws_content := fun.ifmascara(ws_content,rtrim(ret_scol(ws_counter).nm_mascara),prm_micro_visao, ret_scol(ws_counter).cd_coluna, prm_objid, '', ret_scol(ws_counter).formula, prm_screen); 

				-- Aplica destaque NORMAL na celula  (se existir) 
				ws_blink_cel := fun.check_blink(prm_objid, ret_scol(ws_counter).cd_coluna, ws_content, '', prm_screen, ws_usuario, prm_pre_suf_alias => ws_pre_suf_alias, prm_ar_colref => arr_destaq_col, prm_ar_colval => arr_destaq_val);
				
				-- Coluna do código ou da Descrição se a coluna principal não tem ligação(código)
				if ws_counter = 1 then 

					-- Se o agrupador da consulta principal tem ligação - ( tem 2 colunas )
					if ws_cd_lig_prin <> 'SEM' then  

						if ret_scol(ws_counter).cd_ligacao = 'SEM' then   -- Coluna da subquery não tem ligação (tem 1 coluna) - Cria uma coluna 

							ws_style_cel := ''; 
							if ws_com_cod_prin = 'N' then  -- Se não imprimiu o código da Principal, oculta também a coluna do código 
								ws_style_cel := 'style="display: none;"'; 
							end if; 	
							htp.p('<td '||ws_idcol||' data-i="'||ws_data_i||'" class="'||ws_fix||' '||ws_inv||ws_quebra_texto||'" '||ws_style_cel||'></td>');  -- Cria uma coluna em branco antes 

							ws_style_cel := ''; 
							ws_data_i    := ws_data_i + 1; 
							ws_fixed     := ws_fixed - 1;
						else 
							ws_style_cel := ''; 
							if ws_com_cod_prin = 'N' then  -- Se não imprimiu o código da Principal, oculta também o código da subquery 
								ws_style_cel := 'style="display: none;"'; 
							end if; 	

							if ret_scol(ws_counter).st_com_codigo = 'N' then -- Se não deve imprimir o código, deixa a coluna em branco  
								ws_content := ''; 
							end if; 	
						end if; 
					
						htp.p('<td '||ws_idcol||' data-i="'||ws_data_i||'" class="'||ws_fix||' '||ws_inv||ws_quebra_texto||'" '||ws_style_cel||' '||ws_blink_cel||'>'||ws_content||'</td>');
					
					-- Se a consulta principal não tem código - (tem somente 1 coluna)
					else 
						if ret_scol(ws_counter).cd_ligacao <> 'SEM' then  -- Tem código, mas não pode ser impresso (não cria o TD)
							ws_data_i := ws_data_i - 1; 							
						else 
							htp.p('<td '||ws_idcol||' data-i="'||ws_data_i||'" class="'||ws_fix||' '||ws_inv||ws_quebra_texto||'" '||ws_blink_cel||'>'||ws_content||'</td>');
						end if; 
					end if; 
				else 
                    htp.p('<td '||ws_idcol||' data-i="'||ws_data_i||'" class="'||ws_fix||' '||ws_inv||ws_quebra_texto||'" >'||ws_content||'</td>');
				end if;

			--- Coluna de valores 
			else
				-- Aplica destaque NORMAL na celula  (se existir) (aplica no conteudo sem formatação para o sisteme reconhecer o tipo number)
                if ret_scol(ws_counter).qt_destaque_celula > 0 then
                    arr_destaq_col.delete;
                    arr_destaq_val.delete;
                    ws_pre_suf_alias:= null;
                    if ret_scol(ws_counter).qt_destaque_refcol > 0 then
                        monta_arr_destaque;
                        ws_pre_suf_alias := substr(rec_tab(ws_counter).col_name,1,instr(rec_tab(ws_counter).col_name,ws_ncolumns(ws_counter))-1)||'|'||   -- prefixo 
				                            substr(rec_tab(ws_counter).col_name,instr(rec_tab(ws_counter).col_name,ws_ncolumns(ws_counter))+length(ws_ncolumns(ws_counter)),1000);  -- sufixo 
                    end if;
                    ws_blink_cel := fun.check_blink(prm_objid, ret_scol(ws_counter).cd_coluna, ret_coluna, '', prm_screen, ws_usuario, prm_pre_suf_alias => ws_pre_suf_alias, prm_ar_colref => arr_destaq_col, prm_ar_colval => arr_destaq_val);
                end if;
				-- ws_blink_cel := fun.check_blink(prm_objid, ret_scol(ws_counter).cd_coluna, ws_content, '', prm_screen, ws_usuario);

				ws_content := fun.um(ret_scol(ws_counter).cd_coluna, prm_micro_visao, fun.ifmascara(ws_content,rtrim(ret_scol(ws_counter).nm_mascara), prm_micro_visao, ret_scol(ws_counter).cd_coluna, prm_objid, '', ret_scol(ws_counter).formula, prm_screen)); 
				if ret_scol(ws_counter).st_agrupador in ('PSM','PCT') then
					ws_content := ' ';
				end if;

				ws_anot_svg   := '';
				ws_anot_class := ''; 
				if ws_prop_usuario_anotacao <> 'NENHUM' then  -- Permite anotação no objeto 
					ws_condicao  := replace(ws_anot_cond||'|'||prm_parametros,'||','|'); 
					ws_usua_perm := ws_usuario; 
					fcl.anotacao_texto ( 'TEXTO', prm_objid, prm_screen, null, ret_scol(ws_counter).cd_coluna, ws_condicao, ws_usua_perm, ws_anot_texto);
					if ws_anot_texto is not null then 
						ws_anot_svg   := '<span>'||fun.ret_svg('anotacao_marcacao')||'</span>'; 
						ws_anot_class := ' anotacao '; 
					end if; 
				end if; 
				
				-- ADICIONADO FUN.RET_SINAL PARA APLICAR O FAROL EM SUBQUERY. 07/08/23
				ws_content := ws_content||fun.ret_sinal(prm_objid, ret_scol(ws_counter).cd_coluna, ws_content);
				htp.p('<td '||ws_idcol||' data-i="'||ws_data_i||'" class="'||ws_fix||' '||ws_inv||ws_anot_class||ws_quebra_texto||'" '||ws_blink_cel||'>'||ws_anot_svg||ws_content||'</td>');
			end if;

            if ret_scol(ws_counter).qt_destaque_linha > 0 then
                arr_destaq_col.delete;
                arr_destaq_val.delete;
                ws_pre_suf_alias := null;
                if ret_scol(ws_counter).qt_destaque_refcol > 0 then
                    monta_arr_destaque;
                    ws_pre_suf_alias := substr(rec_tab(ws_counter).col_name,1,instr(rec_tab(ws_counter).col_name,ws_ncolumns(ws_counter))-1)||'|'||   -- prefixo 
                                        substr(rec_tab(ws_counter).col_name,instr(rec_tab(ws_counter).col_name,ws_ncolumns(ws_counter))+length(ws_ncolumns(ws_counter)),1000);  -- sufixo 
                end if;
                ws_blink_linha := fun.check_blink_linha(prm_objid, ret_scol(ws_counter).cd_coluna, ws_linha, ret_coluna, prm_screen, prm_pre_suf_alias => ws_pre_suf_alias, prm_ar_colref => arr_destaq_col, prm_ar_colval => arr_destaq_val);
            end if;

	    end loop;
        if ws_blink_linha <> 'N/A' then 
            htp.p(ws_blink_linha); 
        end if;

	    ws_firstid := 'N';

	    htp.tableRowClose;

	end loop;
	dbms_sql.close_cursor(ws_cursor);

	if ws_log_exec in ('S','D') then 
		fun.log_exec_atu ('FIM', ws_log_exec, ws_log_exec_id, prm_objid, ws_usuario, 'SUBQUERY', 20, 'FINALIZADO', null); 
	end if; 


exception
	when others	then
		if ws_log_exec in ('S','D') then 
			fun.log_exec_atu ('FIM', ws_log_exec, ws_log_exec_id, prm_objid, ws_usuario, 'SUBQUERY', 20, 'FINALIZADO - ERRO OUTROS', null); 
		end if; 

	    insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - SUBQUERY', ws_usuario, 'ERRO');
        commit;
end subquery;

procedure lista_cidades ( prm_estado     varchar2 default null,
						prm_regiao     varchar2 default null,
						prm_coluna     varchar2 default 'CD',
						prm_obj        varchar2 default null,
						prm_screen     varchar2 default null,
						prm_visao      varchar2 default null,
						prm_parametros varchar2 default null ) as
	
	cursor crs_filtros is
		select cd_coluna, decode(condicao, 'IGUAL', '=', 'DIFERENTE', '<>', 'MAIOR', '>', 'MENOR', '<', 'MAIOROUIGUAL', '>=', 'MENOROUIGUAL', '<=', 'LIKE', ' like ', 'NOTLIKE', ' not like ', '=') as regra, conteudo from (
			select 
				decode(substr(trim(cd_coluna),1,2),'M_',substr(trim(cd_coluna),3,length(trim(cd_coluna))),trim(cd_coluna)) as cd_coluna,
				'IGUAL'                           as condicao,
				replace(trim(CONTEUDO), '$[NOT]', '') as conteudo
			from   FLOAT_FILTER_ITEM
			where
				trim(cd_usuario) = gbl.getUsuario and
				trim(screen) = trim(prm_screen) and
				/*instr(trim(conteudo), '$[NOT]') <> 0 and*/
				trim(cd_coluna) not in (select cd_coluna from filtros where condicao = 'NOFLOAT' and tp_filtro = 'objeto' and trim(micro_visao) = trim(prm_visao) and trim(cd_objeto) = trim(prm_obj)) and
				decode(substr(trim(cd_coluna),1,2),'M_',substr(trim(cd_coluna),3,length(trim(cd_coluna))),trim(cd_coluna)) in ( 
					select trim(CD_COLUNA)
					from   MICRO_COLUNA mc
					where  trim(mc.CD_MICRO_VISAO) = trim(prm_visao)				 
				)  and
				length(trim(CONTEUDO)) > 0
				and cd_coluna in ('NM_CIDADE', 'CD_CIDADE', 'CD_ESTADO')
			
			union all

			select
				trim(cd_coluna)	as cd_coluna,
				trim(condicao)		as condicao,
				trim(conteudo)		as conteudo
			from 	FILTROS t1
			where	trim(micro_visao) = rtrim(prm_visao) and
				tp_filtro   = 'geral' and
				st_agrupado = 'N' and 
				(rtrim(cd_usuario)  in (gbl.getUsuario, 'DWU') or trim(cd_usuario) in (select cd_group from gusers_itens where cd_usuario = gbl.getUsuario))
				and length(trim(CONTEUDO)) > 0
				and cd_coluna in ('NM_CIDADE', 'CD_CIDADE', 'CD_ESTADO')

			union

			select
				trim(cd_coluna)	    as cd_coluna,
				trim(condicao)		as condicao,
				trim(conteudo)		as conteudo
			from 	FILTROS
			where	trim(micro_visao) = trim(prm_visao)  and
				tp_filtro = 'objeto' and
				( trim(cd_objeto) = trim(prm_obj) or (trim(cd_objeto) = trim(prm_screen) and (nvl(fun.GETPROP(trim(prm_obj),'FILTRO'), 'N/A') <>'ISOLADO' and nvl(fun.GETPROP(trim(prm_obj),'FILTRO'), 'N/A') <> 'COM CORTE')) )
				and trim(cd_usuario)  = 'DWU' 
				and length(trim(CONTEUDO)) > 0 
				and CONDICAO <> 'NOFLOAT'
				and CONDICAO <> 'NOFILTER'
				and cd_coluna in ('NM_CIDADE', 'CD_CIDADE', 'CD_ESTADO')

			union all
			
			SELECT
				TRIM(CD_COLUNA)	AS CD_COLUNA,
				TRIM(CONDICAO)		AS CONDICAO,
				TRIM(CONTEUDO)		AS CONTEUDO
			FROM 	FILTROS
			WHERE	RTRIM(MICRO_VISAO) = RTRIM(prm_visao)  AND
				( RTRIM(CD_OBJETO) = TRIM(prm_obj) OR (RTRIM(CD_OBJETO) = TRIM(prm_screen)) )
			AND TRIM(CD_USUARIO)  = 'DWU' 
			AND LENGTH(TRIM(CONTEUDO)) > 0  AND 
			CONDICAO = 'NOFILTER' and cd_coluna in ('NM_CIDADE', 'CD_CIDADE', 'CD_ESTADO')

			union all
			
			SELECT
				TRIM(CD_COLUNA)	AS CD_COLUNA,
				TRIM(CD_CONDICAO)		AS CONDICAO,
				TRIM(CD_CONTEUDO)		AS CONTEUDO
			FROM 	table(fun.vpipe_par((prm_parametros))) 
			where cd_coluna in ('NM_CIDADE', 'CD_CIDADE', 'CD_ESTADO')
		) 
		group by cd_coluna, condicao, conteudo
		order by cd_coluna, condicao, conteudo;

	ws_filtro crs_filtros%rowtype;
	
	ws_name     number;
	ws_desc     varchar2(200);
	ws_count    number;
	ws_sql      varchar2(20000);
	ws_regra    varchar2(10000);
	ws_json     clob;
	ws_nmcidade varchar2(200);
	ws_cdcidade varchar2(200);
	ws_estado   varchar2(200);
	ws_conteudo varchar2(400);

	ws_cursor	integer;
	ws_linhas	integer;

begin
	
	ws_name  := 0;
	ws_count := 0;

	if nvl(fun.ret_var('NOVA_TABELA_CIDADES'),'N') = 'S' then 
		ws_sql := 'select json, nm_cidade, cd_cidade, cd_estado from bi_cidades';
	else 
		ws_sql := 'select json, nm_cidade, cd_cidade, cd_estado from bi_cidades_brasil';
	end if; 	
	ws_sql := ws_sql||' where trim(cd_estado) in (select trim(column_value) from table((fun.vpipe(nvl('''||prm_estado||''', ''RN|RJ|MG|AL|ES|SP|PR|RS|AM|RR|AC|PE|MA|PB|SE|RO|AP|CE|BA|MT|SC|GO|DF|TO|PI|MS|PA'')))))'; 
	
	if prm_regiao is not null then 
		if prm_estado is null then 
			ws_sql := ws_sql||' and trim(cd_regiao) in (select trim(column_value) from table((fun.vpipe(nvl('''||prm_regiao||''', ''S|SE|N|NE|C'')))))'; 
		else 
			ws_sql := ws_sql||' or trim(cd_regiao) in (select trim(column_value) from table((fun.vpipe(nvl('''||prm_regiao||''', ''S|SE|N|NE|C'')))))'; 
		end if;
	end if; 	

	insert into err_txt(txt) values (ws_sql);

	open crs_filtros;
		loop
			fetch crs_filtros into ws_filtro;
			exit when crs_filtros%notfound;

				ws_conteudo := ws_filtro.conteudo;

				if substr(ws_filtro.conteudo,1,2) = '$[' then
					ws_conteudo := fun.gparametro(ws_filtro.conteudo, prm_screen => prm_screen);
				end if;

				if substr(ws_filtro.conteudo,1,2) = '#[' then
					ws_conteudo := fun.ret_var(ws_filtro.conteudo,gbl.getUsuario);
				end if;

				if UPPER(substr(ws_filtro.conteudo,1,5)) = 'EXEC=' then
					ws_conteudo := fun.xexec(ws_filtro.conteudo, prm_screen);
				end if;
			
				ws_regra := ws_regra||' or '||trim(ws_filtro.cd_coluna)||' '||trim(ws_filtro.regra)||' '||chr(39)||trim(ws_conteudo)||chr(39);

		end loop;
	close crs_filtros;

	if length(ws_regra) > 0 then
		ws_sql := ws_sql||' and ('||substr(ws_regra, 4, length(ws_regra))||') ';
	end if;

	if nvl(fun.ret_var('NOVA_TABELA_CIDADES'),'N') = 'S' then 
		ws_sql := ws_sql||' order by cd_estado, cd_cidade, sq_json asc';
	else 
		ws_sql := ws_sql||' order by cd_estado, cd_cidade, sequencia asc';
	end if; 	


	ws_cursor := dbms_sql.open_cursor;

	dbms_sql.parse(ws_cursor, ws_sql, DBMS_SQL.NATIVE);
	
	dbms_sql.define_column(ws_cursor, 1, ws_json);
	dbms_sql.define_column(ws_cursor, 2, ws_nmcidade, 200);
	dbms_sql.define_column(ws_cursor, 3, ws_cdcidade, 200);
	dbms_sql.define_column(ws_cursor, 4, ws_estado, 200);
	
	ws_linhas := dbms_sql.execute(ws_cursor);

	loop

		ws_linhas := dbms_sql.fetch_rows(ws_cursor);
		if  ws_linhas <> 1 then exit; end if;

		dbms_sql.column_value(ws_cursor, 1, ws_json);
		dbms_sql.column_value(ws_cursor, 2, ws_nmcidade);
		dbms_sql.column_value(ws_cursor, 3, ws_cdcidade);
		dbms_sql.column_value(ws_cursor, 4, ws_estado);
		
		if ws_cdcidade <> ws_name then
			if ws_count > 0 then
				if nvl(fun.ret_var('NOVA_TABELA_CIDADES'),'N') = 'S' then 	
					htp.p(' }}');
				else  
					htp.p('] }}');
				end if; 
				--	
				htp.p('</li>');
			end if;
			ws_name := ws_cdcidade;
			ws_desc := ws_nmcidade;
			htp.p('<li data-sigla="'||ws_name||'" data-sigla2="'||fun.ptg_trans(upper(ws_desc))||'" data-nome="'||ws_desc||'">');
			
			if nvl(fun.ret_var('NOVA_TABELA_CIDADES'),'N') = 'S' then 
				htp.p('{ "type": "Feature", "properties": { "name": "'||ws_name||'", "nome": "'||fun.ptg_trans(upper(ws_desc))||'", "sigla": "'||ws_name||'" }, "geometry": { "type": "MultiPolygon", "coordinates": ');
			else 
				htp.p('{ "type": "Feature", "properties": { "name": "'||ws_name||'", "nome": "'||fun.ptg_trans(upper(ws_desc))||'", "sigla": "'||ws_name||'" }, "geometry": { "type": "MultiPolygon", "coordinates": [');
			end if; 	
			ws_count := ws_count+1;
		end if;
			
		htp.prn(trim(ws_json));
				
	end loop;

	dbms_sql.close_cursor(ws_cursor);
	
	if nvl(fun.ret_var('NOVA_TABELA_CIDADES'),'N') = 'S' then 	
		htp.p(' }}');
	else 
		htp.p('] }}');
	end if; 		
	htp.p('</li>');

exception when others then
	htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
end lista_cidades;

procedure lista_estados ( prm_estado     varchar2 default null,
						prm_regiao     varchar2 default null,
						prm_coluna     varchar2 default 'CD',
						prm_obj        varchar2 default null,
						prm_screen     varchar2 default null,
						prm_visao      varchar2 default null,
						prm_parametros varchar2 default null ) as

	cursor crs_filtros is
		select cd_coluna, decode(condicao, 'IGUAL', '=', 'DIFERENTE', '<>', 'MAIOR', '>', 'MENOR', '<', 'MAIOROUIGUAL', '>=', 'MENOROUIGUAL', '<=', 'LIKE', ' like ', 'NOTLIKE', ' not like ', '=') as regra, conteudo from (
			/***** coomentado para, mostrar todos os estados, a não ser que seja passado estados nos parametros prm_estado ou prm_parametros
			select 
				decode(substr(trim(cd_coluna),1,2),'M_',substr(trim(cd_coluna),3,length(trim(cd_coluna))),trim(cd_coluna)) as cd_coluna,
				'IGUAL'                           as condicao,
				replace(trim(CONTEUDO), '$[NOT]', '') as conteudo
			from   FLOAT_FILTER_ITEM
			where
				trim(cd_usuario) = gbl.getUsuario and
				trim(screen) = trim(prm_screen) and
				trim(cd_coluna) not in (select cd_coluna from filtros where condicao = 'NOFLOAT' and tp_filtro = 'objeto' and trim(micro_visao) = trim(prm_visao) and trim(cd_objeto) = trim(prm_obj)) and
				decode(substr(trim(cd_coluna),1,2),'M_',substr(trim(cd_coluna),3,length(trim(cd_coluna))),trim(cd_coluna)) in ( 
					select trim(CD_COLUNA)
					from   MICRO_COLUNA mc
					where  trim(mc.CD_MICRO_VISAO) = trim(prm_visao)				 
				)  and
				length(trim(CONTEUDO)) > 0
				and cd_coluna = 'CD_ESTADO'
			
			union all

			select
				trim(cd_coluna)	as cd_coluna,
				trim(condicao)		as condicao,
				trim(conteudo)		as conteudo
			from 	FILTROS t1
			where	trim(micro_visao) = rtrim(prm_visao) and
				tp_filtro   = 'geral' and
				st_agrupado = 'N' and 
				(rtrim(cd_usuario)  in (gbl.getUsuario, 'DWU') or trim(cd_usuario) in (select cd_group from gusers_itens where cd_usuario = gbl.getUsuario))
				and length(trim(CONTEUDO)) > 0
				and cd_coluna = 'CD_ESTADO'

			union

			select
				trim(cd_coluna)	    as cd_coluna,
				trim(condicao)		as condicao,
				trim(conteudo)		as conteudo
			from 	FILTROS
			where	trim(micro_visao) = trim(prm_visao)  and
				tp_filtro = 'objeto' and
				( trim(cd_objeto) = trim(prm_obj) or (trim(cd_objeto) = trim(prm_screen) and (nvl(fun.GETPROP(trim(prm_obj),'FILTRO'), 'N/A')<>'ISOLADO' and nvl(fun.GETPROP(trim(prm_obj),'FILTRO'), 'N/A') <> 'COM CORTE')) )
				and trim(cd_usuario)  = 'DWU' 
				and length(trim(CONTEUDO)) > 0 
				and CONDICAO <> 'NOFLOAT'
				and CONDICAO <> 'NOFILTER'
				and cd_coluna = 'CD_ESTADO'

			union all
			
			SELECT
				TRIM(CD_COLUNA)	AS CD_COLUNA,
				TRIM(CONDICAO)		AS CONDICAO,
				TRIM(CONTEUDO)		AS CONTEUDO
			FROM 	FILTROS
			WHERE	RTRIM(MICRO_VISAO) = RTRIM(prm_visao)  AND
				( RTRIM(CD_OBJETO) = TRIM(prm_obj) OR (RTRIM(CD_OBJETO) = TRIM(prm_screen)) )
			AND TRIM(CD_USUARIO)  = 'DWU' 
			AND LENGTH(TRIM(CONTEUDO)) > 0  AND 
			CONDICAO = 'NOFILTER' and cd_coluna = 'CD_ESTADO'

			union all
			***********/ 			
			SELECT
				TRIM(CD_COLUNA)	AS CD_COLUNA,
				TRIM(CD_CONDICAO)		AS CONDICAO,
				TRIM(CD_CONTEUDO)		AS CONTEUDO
			FROM 	table(fun.vpipe_par((prm_parametros))) where cd_coluna = 'CD_ESTADO'
		) 
		group by cd_coluna, condicao, conteudo
		order by cd_coluna, condicao, conteudo;

	ws_filtro crs_filtros%rowtype;
	
	ws_name     varchar2(40);
	ws_desc     varchar2(400);
	ws_count    number;
	ws_sql      varchar2(20000);
	ws_regra    varchar2(10000);
	ws_json     clob;
	ws_nmestado varchar2(200);
	ws_cdestado varchar2(200);
	ws_conteudo varchar2(400);
	ws_condicao varchar2(50);

	ws_cursor	integer;
	ws_linhas	integer;

begin

	ws_count := 0;
	ws_name  := '123';
	ws_condicao := '';

	if nvl(fun.ret_var('NOVA_TABELA_CIDADES'),'N') = 'S' then 
		ws_sql := 'select cd_estado, nm_estado, json from bi_estados';
	else 
		ws_sql := 'select cd_estado, nm_estado, json from bi_estados_brasil';
	end if; 		
	
	if prm_estado is not null then 
		ws_condicao := ' or';
		ws_sql := ws_sql||' where trim(cd_estado) in (  select trim(column_value) from table(fun.vpipe('''||prm_estado||''')) )'; 
	else 
		ws_condicao := ' and';
		ws_sql := ws_sql||' where 1=1'; 
	end if; 	

	if prm_regiao is not null then 
		ws_sql := ws_sql||ws_condicao||' trim(cd_regiao) in (select trim(column_value) from table((fun.vpipe(nvl('''||prm_regiao||''', ''S|SE|N|NE|C'')))))'; 
	end if; 	

	open crs_filtros;
		loop
			fetch crs_filtros into ws_filtro;
			exit when crs_filtros%notfound;

				ws_conteudo := ws_filtro.conteudo;

				if substr(ws_filtro.conteudo,1,2) = '$[' then
					ws_conteudo := fun.gparametro(ws_filtro.conteudo, prm_screen => prm_screen);
				end if;

				if substr(ws_filtro.conteudo,1,2) = '#[' then
					ws_conteudo := fun.ret_var(ws_filtro.conteudo,gbl.getUsuario);
				end if;

				if UPPER(substr(ws_filtro.conteudo,1,5)) = 'EXEC=' then
					ws_conteudo := fun.xexec(ws_filtro.conteudo, prm_screen);
				end if;
			
				ws_regra := ws_regra||' or '||trim(ws_filtro.cd_coluna)||' '||trim(ws_filtro.regra)||' '||chr(39)||trim(ws_conteudo)||chr(39);

		end loop;
	close crs_filtros;

	if length(ws_regra) > 0 then
		ws_sql := ws_sql||' and ('||substr(ws_regra, 4, length(ws_regra))||') ';
	end if;

	if nvl(fun.ret_var('NOVA_TABELA_CIDADES'),'N') = 'S' then 
		ws_sql := ws_sql||' order by cd_estado, sq_json asc';
	else 
		ws_sql := ws_sql||' order by cd_estado, sequencia asc';
	end if; 	

	ws_cursor := dbms_sql.open_cursor;

	insert into err_txt(txt) values (ws_sql);

	dbms_sql.parse(ws_cursor, ws_sql, DBMS_SQL.NATIVE);

	dbms_sql.define_column(ws_cursor, 1, ws_cdestado, 200);
	dbms_sql.define_column(ws_cursor, 2, ws_nmestado, 200);
	dbms_sql.define_column(ws_cursor, 3, ws_json);

	ws_linhas := dbms_sql.execute(ws_cursor);

	loop

		ws_linhas := dbms_sql.fetch_rows(ws_cursor);
		if  ws_linhas <> 1 then exit; end if;

		dbms_sql.column_value(ws_cursor, 1, ws_cdestado);
		dbms_sql.column_value(ws_cursor, 2, ws_nmestado);
		dbms_sql.column_value(ws_cursor, 3, ws_json);
		
		if ws_cdestado <> ws_name then
			if ws_count > 0 then
				htp.p(' }}');
				htp.p('</li>');
			end if;
			ws_name := ws_cdestado;
			ws_desc := ws_nmestado;
			htp.p('<li data-sigla="'||ws_name||'" data-nome="'||ws_desc||'">');
			htp.prn('{ "type": "Feature", "properties": { "name": "'||ws_name||'", "nome": "'||ws_desc||'", "sigla": "'||ws_name||'" }, "geometry": { "type": "MultiPolygon", "coordinates": ');
			ws_count := ws_count+1;
		end if;

		htp.prn(trim(ws_json));
				
	end loop;

	dbms_sql.close_cursor(ws_cursor);
	
	htp.prn(' }}');
	htp.p('</li>');

exception when others then
	htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
end lista_estados;

procedure lista_regioes (   prm_regiao     varchar2 default null,
							prm_coluna     varchar2 default 'CD',
							prm_obj        varchar2 default null,
							prm_screen     varchar2 default null,
							prm_visao      varchar2 default null,
							prm_parametros varchar2 default null ) as

	ws_name     varchar2(40);
	ws_desc     varchar2(400);
	ws_sql      varchar2(20000);
	ws_cursor	integer;
	ws_linhas   integer;
	ws_count    number;
	ws_json     clob;
	ws_cdregiao varchar2(200);
	ws_nmregiao varchar2(200);

begin

	ws_count := 0;

	ws_sql := ' select cd_regiao, nm_regiao, json from bi_regioes';

	if prm_regiao is not null then 
		ws_sql := ws_sql||' where trim(cd_regiao) in (  select trim(column_value) from table(fun.vpipe('''||prm_regiao||''')) )'; 
	else 
		ws_sql := ws_sql||' where 1=1'; 
	end if; 	

	ws_cursor := dbms_sql.open_cursor;

	dbms_sql.parse(ws_cursor, ws_sql, DBMS_SQL.NATIVE);

	dbms_sql.define_column(ws_cursor, 1, ws_cdregiao, 200);
	dbms_sql.define_column(ws_cursor, 2, ws_nmregiao, 200);
	dbms_sql.define_column(ws_cursor, 3, ws_json);

	ws_linhas := dbms_sql.execute(ws_cursor);

	insert into err_txt(txt) values (ws_sql);

	loop

		ws_linhas := dbms_sql.fetch_rows(ws_cursor);
		if  ws_linhas <> 1 then exit; end if;

		dbms_sql.column_value(ws_cursor, 1, ws_cdregiao);
		dbms_sql.column_value(ws_cursor, 2, ws_nmregiao);
		dbms_sql.column_value(ws_cursor, 3, ws_json);
		
		ws_name := ws_cdregiao;
		ws_desc := ws_nmregiao;
		htp.p('<li data-sigla="'||ws_name||'" data-nome="'||ws_desc||'">');
		htp.prn('{ "type": "Feature", "properties": { "name": "'||ws_name||'", "nome": "'||ws_desc||'", "sigla": "'||ws_name||'" }, "geometry": { "type": "MultiPolygon", "coordinates": ');

		htp.prn(trim(ws_json));

		htp.prn(' }}');
		htp.p('</li>');

		ws_count := ws_count+1;
				
	end loop;

	dbms_sql.close_cursor(ws_cursor);
	

exception when others then
	htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);

end lista_regioes;
procedure section_submenu (prm_objeto       varchar2,
						   prm_screen       varchar2,
						   prm_zindex	    varchar2) is 
	ws_style_aux           varchar2(200); 
	ws_posicao_section     varchar2(200); 
	ws_bgColor_section     varchar2(200); 
	ws_altura_section      varchar2(200); 
	ws_padding_section     varchar2(200); 

begin

	ws_posicao_section    := nvl(fun.getprop(prm_objeto,'POSICAO_SECTION',NULL,'DWU','SECTION'),null);
	ws_bgColor_section    := nvl(fun.getprop(prm_objeto,'BGCOLOR_SECTION',NULL,'DWU','SECTION'),'TRANSPARENT');
	ws_altura_section     := nvl(fun.getprop(prm_objeto,'ALTURA_SECTION',NULL,'DWU','SECTION'),'60px');
	ws_padding_section    := nvl(fun.getprop(prm_objeto,'PADDING_SECTION',NULL,'DWU','SECTION'),'10px');

	htp.p('<div class="submenu" onmousedown="event.stopPropagation();">');
		-- Botão adicionar Bloco 
		htp.p('<a class="adddash" title="'||fun.lang('adicionar bloco')||'" onclick="dashboard('''', ''insert'', '''||prm_objeto||''');">+</a>');
		-- Lista orientação 
		ws_style_aux := '';
		if ws_posicao_section in('SUPERIOR','INFERIOR') then 
			ws_style_aux := 'style="left:72px;"';
		end if;
		htp.p('<select '||ws_style_aux||' onchange="dashboard(document.getElementById(''current_screen'').value, ''rowcolumn'', '''||prm_objeto||''',  this.value);">');
			htp.p('<optgroup label="'||fun.lang('Formato')||'"></optgroup>');
			if prm_zindex = 'row' then
				htp.p('<option value="row" selected>'||fun.lang('Horizontal')||'</option>');
			else
				htp.p('<option value="row">'||fun.lang('Horizontal')||'</option>');
			end if;
			if prm_zindex = 'column' then
				htp.p('<option value="column" selected>'||fun.lang('Vertical')||'</option>');
			else
				htp.p('<option value="column">'||fun.lang('Vertical')||'</option>');
			end if;
		htp.p('</select>');

		-- Lista posição do bloco 
		ws_style_aux := 'style="left:122px;"';
		if ws_posicao_section in('SUPERIOR','INFERIOR') then 
			ws_style_aux := 'style="left:160px;"';
		end if;
		htp.p('<select '||ws_style_aux||' onchange="dashboard(document.getElementById(''current_screen'').value, ''posicao_section'', '''||prm_objeto||''',  this.value);">');
			htp.p('<optgroup label="'||fun.lang('Posi&ccedil;&atilde;o')||'"></optgroup>');
			if ws_posicao_section = 'SUPERIOR'  then
				htp.p('<option value="SUPERIOR" selected>'||fun.lang('Superior')||'</option>');
			else
				htp.p('<option value="SUPERIOR">'||fun.lang('Superior')||'</option>');
			end if;
			if ws_posicao_section = 'INFERIOR' then
				htp.p('<option value="INFERIOR" selected>'||fun.lang('Inferior')||'</option>');
			else
				htp.p('<option value="INFERIOR">'||fun.lang('Inferior')||'</option>');
			end if;
			if ws_posicao_section is null then
				htp.p('<option value="" selected>'||fun.lang('Normal')||'</option>');
			else
				htp.p('<option value="">'||fun.lang('Normal')||'</option>');
			end if;
		htp.p('</select>');
		
		-- Margem interna 
		if ws_posicao_section in('SUPERIOR','INFERIOR') then 
			htp.p('<input style="left:249px; top: auto; bottom: 4px; width:60px;"  title="Margem interna" onkeypress="if(event.which == ''13''){ this.blur(); }" onblur="dashboard('''||prm_screen||''', ''padding_section'', '''||prm_objeto||''', this.value);" value="'||ws_padding_section||'" >');	
		else 
			htp.p('<input style="left:208px; top: auto; bottom: 4px; width:60px;"  title="Margem interna" onkeypress="if(event.which == ''13''){ this.blur(); }" onblur="dashboard('''||prm_screen||''', ''padding_section'', '''||prm_objeto||''', this.value);" value="'||ws_padding_section||'" >');	
		end if;
		-- Altura do bloco 
		if ws_posicao_section in('SUPERIOR','INFERIOR') then 
			htp.p('<input style="left:318px; top: auto; bottom: 4px; width:60px;"  title="Altura m&iacute;nima" onkeypress="if(event.which == ''13''){ this.blur(); }" onblur="dashboard('''||prm_screen||''', ''altura_section'', '''||prm_objeto||''', this.value);" value="'||ws_altura_section||'" >');	
		end if;
		
		htp.p('<input style="left:4px; width:60px;"  title="'||fun.lang('Cor do Fundo')||'" onkeypress="if(event.which == ''13''){ this.blur(); }" onblur="dashboard('''||prm_screen||''', ''background_section'', '''||prm_objeto||''', this.value);" value="'||ws_bgColor_section||'" >');	
		
		htp.p(fun.excluir_dash(prm_objeto));
	htp.p('</div>');

end section_submenu; 

end OBJ;
