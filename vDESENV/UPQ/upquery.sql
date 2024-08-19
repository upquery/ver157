create or replace package body UpQuery  is


procedure main  ( prm_parametros	 varchar2 default null,
			      prm_micro_visao    char default null,
			      prm_coluna	     char default null,
			      prm_agrupador	     char default null,
			      prm_rp		     char default 'ROLL',
			      prm_colup	         char default null,
			      prm_comando	     char default 'MOUNT',
			      prm_mode	         char default 'NO',
			      prm_objid	         char default null,
			      prm_screen	     char default 'DEFAULT',
			      prm_posx	         char default null,
			      prm_posy	         char default null,
			      prm_ccount	     char default '0',
			      prm_drill	         char default 'N',
			      prm_ordem	         char default '0',
			      prm_zindex	     char default 'auto',
                  prm_track          varchar2 default null,
                  prm_objeton        varchar2 default null,
			      prm_self           varchar2 default null,
				  prm_dashboard      varchar2 default 'false' ) as

	/*cursor crs_micro_visao is
			select	rtrim(cd_grupo_funcao) as cd_grupo_funcao
			from 	MICRO_VISAO where nm_micro_visao = prm_micro_visao;

	ws_micro_visao crs_micro_visao%rowtype;*/

	cursor crs_xgoto(prm_usuario varchar2) is
			select	rtrim(cd_objeto_go) as cd_objeto_go
			from 	GOTO_OBJETO where cd_objeto = prm_objid and
			        cd_objeto_go not in ( select cd_objeto from OBJECT_RESTRICTION where USUARIO = prm_usuario )
			order by cd_objeto_go;

	ws_xgoto crs_xgoto%rowtype;


	type ws_tmcolunas is table of MICRO_COLUNA%ROWTYPE
			    		index by pls_integer;

	type generic_cursor is ref cursor;

	crs_saida generic_cursor;

	cursor nc_colunas is select * from MICRO_COLUNA where cd_micro_visao = prm_micro_visao;

	ret_coluna			varchar2(4000);
	ws_coluna_sup       varchar2(4000);
	dat_coluna          date;
	ret_mcol			ws_tmcolunas;
	ws_ncolumns			DBMS_SQL.VARCHAR2_TABLE;
	ws_coluna_ant		DBMS_SQL.VARCHAR2_TABLE;
	ws_pvcolumns		DBMS_SQL.VARCHAR2_TABLE;
	ws_mfiltro			DBMS_SQL.VARCHAR2_TABLE;
	ws_vcol				DBMS_SQL.VARCHAR2_TABLE;
	ws_vcon				DBMS_SQL.VARCHAR2_TABLE;
	ws_drill			varchar2(40);
	ws_objid			varchar2(120);
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
	ws_coluna_sup_ant   varchar2(4000);
	ws_content			long;
	ws_content_sum      long;
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
	--ws_script			long;
	--ws_locais			long;
	ws_titulo			varchar2(400);
	ws_nome             varchar2(400);
	ws_subtitulo		varchar2(400);
	--ws_temptxt			varchar2(3000);
	ws_mode				varchar2(30);
	ws_idcol			varchar2(120);
	ws_cleardrill		varchar2(120);
	ws_firstid			char(1);
	ws_vazio			boolean := True;
	ws_nodata       	exception;
	ws_invalido			exception;
	--ws_ponto_avalicao	exception;
	ws_close_html	    exception;
	ws_mount			exception;
	ws_parseerr			exception;
    ws_nova_sessao      exception;
	ws_posicao			varchar2(2000) := ' ';
	ws_drill_atalho		varchar2(4000);
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
	ws_largura          varchar2(60) := '0';
	--ws_larguran         number;
	--ws_talk             varchar2(40) := 'talk';
	ws_linha            number := 0;
	ws_linha_col        number := 0;
	ws_fixed            number;
	ws_fix              varchar2(80);
	ws_ct_top           number := 0;
	ws_top              number := 0;
	ws_tmp_check        varchar2(300);
	ws_check            varchar2(300);
	ws_row              number;
	ws_pivot            varchar2(300);
	ws_distinctmed      number := 0;
	ws_cab_cross        varchar2(4000);
    ret_colgrp          varchar2(2000);
	ret_coltot          varchar2(2000);
	ws_temp_valor       number := 0;
	ws_temp_valor2      number := 0;
    ws_total_linha      number := 0;
	ws_acumulada_linha  number := 0;
	ws_linha_acumulada  varchar2(10);
	ws_total_acumulado  varchar2(10);
	--ws_omitir           char(1);
	ws_limite_i         varchar2(10);
	ws_limite_f         varchar2(10);
	ws_isolado          varchar2(60);
	ws_repeat           varchar2(60) := 'show';
	ws_subquery         varchar2(600);
	ws_propagation      varchar2(400);
	ws_order            varchar2(90);
	ws_alinhamento      varchar2(80);
	ws_nm_var_al        varchar2(400);
	ws_cd_coluna        varchar2(400);
	ws_texto_al         varchar2(4000);
	ws_array_atual      DBMS_SQL.VARCHAR2_TABLE;
	ws_class_atual      DBMS_SQL.VARCHAR2_TABLE;
	ws_array_anterior   DBMS_SQL.VARCHAR2_TABLE;
	ws_count            number := 0;
	dimensao_soma       number := 1;
	ws_blink_linha      varchar2(4000) := 'N/A';
	ws_chave            varchar2(100);
	ws_tempo            date;
	ws_tpt              varchar2(400);
	ws_excel            clob;
	ws_saida            varchar2(10) := 'S';
	ws_pivot_coluna     varchar2(4000);
	ws_show_active      varchar2(2);
	--ws_semlinha         exception;
	ws_full             varchar2(10);
	ws_show_only        varchar2(10);
	ws_count_visivel    number;
	ws_hint             varchar2(2000);
	ws_semacesso        exception;
	--ws_string           varchar2(2000);
	--ws_screen           varchar2(200);
	ws_borda            varchar2(60);
    ws_null             varchar2(1) := null;
    ws_conteudo_ant     varchar2(4000);
    ws_calculada        varchar2(800);
    ws_calculada_n      varchar2(200);
    ws_calculada_m      varchar2(200);
    ws_amostra          number := 0;
	--ws_shared           number;
	ws_binds            varchar2(3000);
	ws_ordem_arrow      varchar2(100);
	ws_diferenca        varchar2(4000);
	ws_colunas_valor    number;
	/*variaveis de redundancia*/
	ws_html             varchar2(2000);
	ws_classe           varchar2(400);
	ws_cod_coluna       varchar2(2000);
	rec_tab             dbms_sql.desc_tab;
    ws_cod              varchar2(80);
	--ws_negative_margin  varchar2(200) := '8px';
	ws_linha_calculada  varchar2(20);
	ws_alinhamento_tit  varchar2(80);
	ws_usuario          varchar2(80);
	ws_login            exception;
	ws_cookie           owa_cookie.cookie;
	ws_cut              varchar2(120);
	name_arr owa_cookie.vc_arr;
    vals_arr owa_cookie.vc_arr;
	vals_ret INTEGER;
	ws_admin            varchar2(4);
	ws_tempo_query   number := 0;
	ws_tempo_avg     number := 0;
	ws_query_hint    varchar2(80);
	ws_erroMsg varchar2(100) := 'SISTEMA TEMPORARIAMENTE INDISPON&Iacute;VEL!';
	ws_owner_bi          varchar2(20); 
	ws_netwall_externo   varchar2(1); 

begin

	ws_owner_bi := nvl(fun.ret_var('OWNER_BI'),'DWU'); 

    if fun.check_sys <> 'OPEN' then
		raise ws_acesso;
	end if;
	
	if nvl(fun.ret_var('XE'), 'N') = 'S' then
		ws_usuario := user;
	else
		begin
			ws_cookie := owa_cookie.get('SESSION');
			ws_cut    := ws_cookie.vals(1);

			if nvl(fun.getSessao(ws_cut), 'DWU') = 'DWU' then
				raise ws_login;
			end if;
		exception when others then
			if nvl(fun.ret_var('BLOQUEIO_SISTEMA'),'N') = 'S' then 	-- cod #103
				ws_erroMsg:= 'SISTEMA EM MANUTEN&Ccedil;&Atilde;O!';
				raise ws_acesso;
			else			  
				raise ws_login;
			end if;
		end;
		ws_usuario := gbl.getUsuario;
	end if;
	
	ws_admin   := gbl.getNivel;

	/**** Desativado - a validação do netwall já é realizada no login 
	if  not fun.check_netwall(ws_usuario)  then
		insert into bi_log_sistema values(sysdate, 'USU&Aacute;RIO SEM ACESSO, BLOQUEIO DE NETWALL', ws_usuario, 'EVENTO');
        commit;
        raise ws_semacesso;
    end if;
	****************/ 
	
	if prm_comando = 'MOUNT' then
		raise ws_mount;
    end if;

exception
    when ws_login then

		select decode(count(*),0,'N','S') into ws_netwall_externo from user_netwall where tp_net_address = 'E'; 

	    htp.p('<html id="html" oncontextmenu="donut(event); return false;">');

				htp.p('<head>');

					htp.p('<link rel="manifest" href="'||ws_owner_bi||'.fcl.downloadOpen?arquivo=manifest">');
					htp.p('<meta http-equiv="cache-control" content="max-age=0" />');
					htp.p('<meta http-equiv="cache-control" content="no-cache" />');
					htp.p('<meta name="apple-mobile-web-app-capable" content="black-translucent" />');
					htp.p('<meta http-equiv="Pragma" content="no-cache"/>');
					htp.p('<meta name="mobile-web-app-capable" content="yes" />');
					
					htp.p('<link rel="favicon" type="image/png" href="'||fun.r_gif('upquery-icon','PNG')||'" />');
					htp.p('<link rel="icon" type="image/png" href="'||fun.r_gif('ipad','PNG')||'" />');
					htp.p('<link rel="shortcut icon apple-touch-icon" href="'||fun.r_gif('ipad','PNG')||'" />');
					htp.p('<link rel="apple-touch-icon" href="'||fun.r_gif('ipad','PNG')||'" />');
					htp.p('<link rel="apple-touch-startup-image" href="'||fun.r_gif('logo','PNG')||'">');
					htp.p('<meta name="theme-color" content="#9a9a9a"/>');
					htp.p('<meta name="apple-mobile-web-app-status-bar-style" content="black">');
					htp.p('<meta name="viewport" content="width=device-width; initial-scale=1; viewport-fit=cover; user-scalable=0">');
										
					htp.p('<script>const OWNER_BI = "'||ws_owner_bi||'"; </script>');

					fcl.monta_css_var_arquivos; -- monta variáveis com os nomes do arquivos (deve ser chamado somente no head )
					htp.p('<link rel="stylesheet" href="'||ws_owner_bi||'.fcl.downloadOpen?arquivo=tema">');
					htp.p('<script src="'||ws_owner_bi||'.fcl.downloadOpen?arquivo=js"></script>');
				    htp.p('<link rel="stylesheet" href="'||ws_owner_bi||'.fcl.downloadOpen?arquivo=css">');

					htp.p('<link href="https://fonts.googleapis.com/css?family=Montserrat" rel="stylesheet" type="text/css">');
					htp.p('<link href="https://fonts.googleapis.com/css?family=Quicksand" rel="stylesheet" type="text/css">');
					htp.p('<link href="https://fonts.googleapis.com/css?family=Source+Sans+Pro&display=swap" rel="stylesheet" type="text/css">'); 

						fcl.keywords;

				htp.p('</head>');

				htp.p('<body>');
				 	htp.p('<div id="extra">');
						htp.p('<input type="hidden" name="sis-netwall-externo" id="sis-netwall-externo" value="'||ws_netwall_externo||'" />');           -- Faz validação de netwall com ip externo (S/N)
					htp.p('</div">');

					fun.setSessao(prm_data => sysdate);
	                fcl.loginScreen;
				htp.p('</body>');
				
		htp.p('</html>');
	when ws_nova_sessao then
	    fcl.loginScreen;
    when ws_mount then
		fun.setSessao(prm_data => sysdate);
	    fcl.iniciar;
    when ws_close_html then
	    fcl.POSICIONA_OBJETO('newquery','DWU','DEFAULT','DEFAULT');
	when ws_parseerr   then
	    if ws_vazio then
            insert into log_eventos values(sysdate, prm_micro_visao||'/'||ws_coluna||'/'||trim(ws_parametros)||'/'||ws_rp||'/'||ws_colup||'/'||WS_AGRUPADOR, ws_usuario, 'VAZIO', 'NODATA', '01');
	        insert into bi_log_sistema values(sysdate, 'VAZIO: '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - VAZIO', ws_usuario, 'ERRO');
            commit;
		else
            insert into log_eventos values(sysdate, prm_micro_visao||'/'||ws_coluna||'/'||trim(ws_parametros)||'/'||ws_rp||'/'||ws_colup||'/'||WS_AGRUPADOR, ws_usuario, 'NOVAZIO', 'PARSE', '01');
		end if;
	    commit;
		htp.p('<span style="margin: 10px; display: block; text-align: center; font-weight: bold; font-family: var(--fonte-primaria);">'||fun.subpar(fun.getprop(prm_objid,'ERR_SD', prm_tipo => 'CONSULTA'), prm_screen)||'</span>');
		if ws_admin = 'A' then
		
		    ws_queryoc := '';
		
		    htp.p('<textarea class="errorquery">');
				ws_counter := 0;
				--begin
					loop
						ws_counter := ws_counter + 1;
						if  ws_counter > ws_query_montada.COUNT then
							exit;
						end if;
						ws_queryoc := ws_queryoc||ws_query_montada(ws_counter);
					end loop;
					fcl.replace_binds(ws_queryoc, ws_binds);
				--exception when others then
				--    htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
				--end;
		    htp.p('</textarea>');
			
		end if;
		htp.p('</span></div>');
	when ws_invalido   then
        insert into log_eventos values(sysdate, prm_micro_visao||'/'||ws_coluna||'/'||trim(ws_parametros)||'/'||ws_rp||'/'||ws_colup||'/'||WS_AGRUPADOR, ws_usuario, 'INVALIDO', 'E-ACC', '01');
	    insert into bi_log_sistema values(sysdate, 'INV&Aacute;LIDO: '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - INVALIDO', ws_usuario, 'ERRO');
        commit;
	    fcl.negado(fun.lang('Parametros Invalidos'));
	when ws_acesso	     then
			-------------------------------	ALTERADO O DESIGN IMPLANTAR DEPOIS NO CSSS	------------------------------------
			htp.p('<!doctype html public "-//W3C//DTD html 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">');
			htp.p('<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="pt-br" lang="pt-br" style="height: 100%;">');

				htp.p('<head>');
					htp.p('<link rel="stylesheet" href="'||ws_owner_bi||'.fcl.downloadOpen?arquivo=tema">');
					htp.prn('<style> 
							body{background: center;background-image:url('||ws_owner_bi||'.fcl.downloadOpen?arquivo=logo);background-repeat: no-repeat;height: 100%;}
							span{position: absolute;top: calc(80% - 10px);left: calc(50% - 300px);width: 600px;height: 100px;background-color: var(--input-color);border-radius:12px;text-align: center;line-height: 100px;font-weight: bold;font-size: 18px;color: var(--amarelo-secundario);font-family: var(--fonte-terciaria);}
						</style>');
				htp.p('</head>');

				htp.p('<body style="background: center;background-image:url('||ws_owner_bi||'.fcl.downloadOpen?arquivo=logo);background-repeat: no-repeat;height: 100%;">');

					htp.p('<span>'||fun.lang(ws_erroMsg)||'</span>');

				htp.p('</body>');

			htp.p('</html>');

	when ws_semquery     then
        insert into log_eventos values(sysdate, prm_micro_visao||'/'||ws_coluna||'/'||trim(ws_parametros)||'/'||ws_rp||'/'||ws_colup||'/'||WS_AGRUPADOR, ws_usuario, 'SEMQUERY', 'SEMQUERY', '01');
	    insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - SEMQUERY', ws_usuario, 'ERRO');
        commit;
	    fcl.negado('['||prm_micro_visao||']-['||prm_objid||']-'||fun.lang('Relat&oacute;rio Sem Query'));
	when ws_nodata	     then
		insert into log_eventos values(sysdate, prm_micro_visao||'/'||ws_coluna||'/'||trim(ws_parametros)||'/'||ws_rp||'/'||ws_colup||'/'||WS_AGRUPADOR, ws_usuario, 'NODATA', 'NODATA', '01');
        insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - NODATA', ws_usuario, 'ERRO');
        commit;
		
		if length(fun.getprop(prm_objid, 'BORDA_COR', prm_tipo => 'CONSULTA')) > 0 then
			ws_borda := 'border: 1px solid '||trim(fun.getprop(prm_objid, 'BORDA_COR', prm_tipo => 'CONSULTA'))||';';
		end if;

		htp.p('<div id="'||ws_objid||'" onmousedown="'||ws_propagation||'" class="dragme front" data-visao="'||prm_micro_visao||'" data-drill="'||prm_drill||'" style="'||ws_posicao||' background-color: '||fun.getprop(prm_objid, 'FUNDO_VALOR', prm_tipo => 'CONSULTA')||'; '||ws_borda||'">');
        
		htp.p('<span class="turn">');

			if to_number(fun.ret_var('ORACLE_VERSION')) > 10 then
				select count(*) into ws_counter from table(fun.vpipe_par(prm_coluna));
				if ws_counter = 0 and nvl(trim(prm_colup), 'null') = 'null' then
					htp.p('<span class="arrowturn">&#x21B2;</span>');
					if length(trim(fun.show_filtros(trim(ws_parametros), ws_cursor, '', prm_objid, prm_micro_visao, prm_screen))) > 3 then
						htp.p('<span class="filtros">F</span>');
					end if;
				end if;
			end if;

			if length(trim(fun.show_filtros(trim(ws_parametros), ws_cursor, '', prm_objid, prm_micro_visao, prm_screen))) > 3 then
				if ws_counter <> 0 OR nvl(trim(prm_colup), 'null') <> 'null' then
					htp.p('<span class="filtros">F</span>');
				end if;
			end if;
			
			if length(trim(fun.show_destaques(trim(ws_parametros), ws_cursor, '', prm_objid, prm_micro_visao, prm_screen))) > 3 then
				htp.p('<span class="destaques">');
					htp.p('<svg style="height: calc(100% - 10px); width: calc(100% - 10px); margin: 5px; fill: #333; pointer-events: none;" enable-background="new -1.23 -8.789 141.732 141.732" height="141.732px" id="Livello_1" version="1.1" viewBox="-1.23 -8.789 141.732 141.732" width="141.732px" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><g id="Livello_100"><path d="M139.273,49.088c0-3.284-2.75-5.949-6.146-5.949c-0.219,0-0.434,0.012-0.646,0.031l-42.445-1.001l-14.5-37.854   C74.805,1.824,72.443,0,69.637,0c-2.809,0-5.168,1.824-5.902,4.315L49.232,42.169L6.789,43.17c-0.213-0.021-0.43-0.031-0.646-0.031   C2.75,43.136,0,45.802,0,49.088c0,2.1,1.121,3.938,2.812,4.997l33.807,23.9l-12.063,37.494c-0.438,0.813-0.688,1.741-0.688,2.723   c0,3.287,2.75,5.952,6.146,5.952c1.438,0,2.766-0.484,3.812-1.29l35.814-22.737l35.812,22.737c1.049,0.806,2.371,1.29,3.812,1.29   c3.393,0,6.143-2.665,6.143-5.952c0-0.979-0.25-1.906-0.688-2.723l-12.062-37.494l33.806-23.9   C138.15,53.024,139.273,51.185,139.273,49.088"/></g><g id="Livello_1_1_"/></svg>');
				htp.p('</span>');
			end if;
			
		htp.p('</span>');

		htp.p('<ul id="'||ws_objid||'-filterlist" style="display: none;" >');
			htp.p(fun.show_filtros(trim(ws_parametros), ws_cursor, ws_isolado, prm_objid, prm_micro_visao, prm_screen));
		htp.p('</ul>');
		
		htp.p('<ul id="'||ws_objid||'-destaquelist" style="display: none;" >');
			htp.p(fun.show_destaques(trim(ws_parametros), ws_cursor, ws_isolado, prm_objid, prm_micro_visao, prm_screen));
		htp.p('</ul>');
		
		
		if instr(ws_objid, 'trl') = 0 then
	        htp.p('<span id="'||ws_objid||'sync" class="sync"><img src="'||ws_owner_bi||'.fcl.download?arquivo=sinchronize.png" /></span>');
        end if;
	    
		if ws_admin = 'A' then
	    	 htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options closed" id="'||ws_objid||'more">');
				htp.p(fun.showtag(prm_objid, 'atrib', prm_screen));
				htp.p('<span class="preferencias" data-visao="'||prm_micro_visao||'" data-drill="'||prm_drill||'" title="'||fun.lang('Propriedades')||'"></span>');
				htp.p(fun.showtag(prm_objid, 'filter', prm_micro_visao));
				htp.p('<span class="sigma" title="'||fun.lang('Linha calculada')||'"></span>');
				htp.p('<span class="lightbulb" title="Drill"></span>');
	   			htp.p(fun.showtag(ws_objid||'c', 'excel'));
				htp.p('<span class="data_table" title="'||fun.lang('Alterar Consulta')||'"></span>');
				htp.p(fun.showtag('', 'star'));
				fcl.button_lixo('dl_obj', prm_objeto=> prm_objid, prm_tag => 'span');
			htp.p('</span>');

			if prm_drill = 'Y' then
			    htp.p('<a class="fechar" id="'||ws_objid||'fechar" title="'||fun.lang('Fechar')||'"></a>');
			end if;

	    else
	        if prm_drill = 'Y' then
	   		    htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options closed" id="'||ws_objid||'more" style="max-width: 106px; max-height: 26px;">');
	   		else
	   		    htp.p('<span title="'||fun.lang('Op&ccedil;&otilde;es')||'" class="options closed" id="'||ws_objid||'more" style="right: 0; max-width: 106px; max-height: 26px;">');
	   		end if;
			    htp.p('<span class="lightbulb" title="Drill"></span>');
				--htp.p(fun.showtag(prm_objid, 'post'));
			    htp.p(fun.showtag(ws_objid||'c', 'excel'));
				htp.p(fun.showtag('', 'star'));
			htp.p('</span>');
			if prm_drill = 'Y' then
			    htp.p('<a class="fechar" id="'||ws_objid||'fechar" title="'||fun.lang('Fechar')||'"></a>');
			end if;
	   end if;

	   htp.p('<div class="wd_move" style="text-align: '||fun.getprop(prm_objid,'ALIGN_TIT', prm_tipo => 'CONSULTA')||'; height: 16px; font-weight: bold; margin: 6px 28px; background-color: '||fun.getprop(prm_objid,'FUNDO_TIT', prm_tipo => 'CONSULTA')||'; color: '||fun.getprop(prm_objid,'FONTE_TIT', prm_tipo => 'CONSULTA')||'">'||ws_nome||'</div>');

	   if ws_admin = 'A' then
		   htp.p('<span class="errorquery">'||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - others</span>');
	   end if;

	   htp.p('</div>');
	   htp.p('</div>');
	   htp.p('<div></div>');
		
	when ws_sempermissao then
		fcl.negado(prm_micro_visao||' - '||fun.lang('Sem Permiss&atilde;o Para Este Filtro')||'.');
	when ws_semacesso then
		fcl.negado(prm_micro_visao||' - '||fun.lang('Sem Permiss&atilde;o de acesso')||'.');
		-- aux.check_list(ws_usuario, 'iniciar');
	when others	     then

		htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
		insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - UPQUERY', ws_usuario, 'ERRO');

end main;

procedure direct (  prm_usuario  varchar2 default null,
					prm_password varchar2 default null ) as 

	ws_show varchar2(10);

begin


	select show_only into ws_show from usuarios where upper(usu_nome) = upper(prm_usuario);

	if ws_show = 'S' then
		fcl.login (prm_usuario, prm_password, prm_prazo => 99999);
		fcl.iniciar;
	else
		htp.p('Sem permissao!');
	end if;
exception when others then
	htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
end direct;

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
					 prm_usuario	 varchar2 default null ) as

	cursor crs_micro_visao is
			select	rtrim(cd_grupo_funcao) as cd_grupo_funcao
			from 	MICRO_VISAO where nm_micro_visao = prm_micro_visao;

	ws_micro_visao crs_micro_visao%rowtype;

	cursor crs_xgoto(prm_usuario varchar2) is
			select	rtrim(cd_objeto_go) as cd_objeto_go
			from 	GOTO_OBJETO where cd_objeto = prm_objid and
			        cd_objeto_go not in ( select cd_objeto from OBJECT_RESTRICTION where USUARIO = prm_usuario )
			order by cd_objeto_go;

	ws_xgoto crs_xgoto%rowtype;

	type ws_tmcolunas is table of MICRO_COLUNA%ROWTYPE
			    		index by pls_integer;

	type generic_cursor is ref cursor;

	crs_saida generic_cursor;

	cursor nc_colunas is select * from MICRO_COLUNA where cd_micro_visao = prm_micro_visao;

	ret_coluna			varchar2(4000);
	ret_mcol			ws_tmcolunas;

	ws_ncolumns			DBMS_SQL.VARCHAR2_TABLE;
	ws_coluna_ant			DBMS_SQL.VARCHAR2_TABLE;
	ws_pvcolumns			DBMS_SQL.VARCHAR2_TABLE;
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
	ws_content_ant			long;
	ws_content			long;
	ws_colup			long;
	ws_coluna			long;
	ws_agrupador			long;
	ws_rp				long;
	ws_xatalho			long;
	ws_atalho			long;
	ws_parametros			long;
	ws_agrupador_max    number;

	ws_acesso			exception;
	ws_semquery			exception;
	ws_sempermissao			exception;
	ws_pcursor			integer;
	ws_cursor			integer;
	ws_linhas			integer;
	ws_query_montada		dbms_sql.varchar2a;
	ws_query_count          dbms_sql.varchar2a;
	ws_query_pivot			long;
	ws_sql				long;
	ws_sql_pivot			long;
	--ws_script			long;
	--ws_locais			long;
	ws_titulo			varchar2(150);
	--ws_temptxt			varchar2(3000);
	ws_mode				varchar2(30);
	ws_idcol			varchar2(120);
	ws_cleardrill		varchar2(120);
	ws_firstid			char(1);

	ws_vazio			boolean := True;
	ws_nodata       		exception;
	ws_invalido			exception;
	--ws_ponto_avalicao		exception;
	ws_close_html			exception;
	ws_mount			exception;
	ws_parseerr			exception;

	ws_posicao			varchar2(2000) := ' ';
	ws_drill_atalho		varchar2(3000);
	ws_ctemp			varchar2(40);
	ws_tmp_jump			varchar2(300);
	ws_jump				varchar2(600);
	ws_sem				varchar2(40);
	ws_title 			clob;
	ws_gotocounter		number;
	--ws_timer            number;
	ws_step             number;
	ws_stepper          number := 0;
	--ws_talk             varchar2(40) := 'talk';
	ws_linha            number := 0;
	ws_fixed            varchar2(40);
	ws_ct_top           number := 0;
	ws_top              number := 0;
	ws_tmp_check        varchar2(300);
	ws_check            varchar2(300);
	ws_row              number;
	ws_pivot            varchar2(300);
    ret_colgrp          varchar2(2000);
	ret_coltot          varchar2(2000);
	ws_temp_valor       number := 0;
    ws_total_linha      number := 0;
	ws_acumulada_linha  number := 0;
	ws_linha_acumulada  varchar2(10);
	ws_total_acumulado  varchar2(10);
	--ws_omitir           char(1);
	ws_limite_i         varchar2(10);
	ws_limite_f         varchar2(10);
	ws_isolado          varchar2(60);
	ws_repeat           varchar2(60) := 'show';
	ws_cab_cross        varchar2(4000) := 'N';
	ws_cod              varchar2(200);
	ws_cod_ac           varchar2(200);
	ws_subquery         varchar2(600);
	ws_ordem            number;
	ws_color            varchar2(60);
	ws_space            varchar2(90);
	ws_space_at         varchar2(90);
	ws_self             varchar2(400);
	ws_count            number;
	ws_cor              varchar2(400);
	ws_blink_linha      varchar2(4000) := 'N/A';
	ws_tpt              varchar2(400);
	ws_order            number;
	ws_fix              varchar2(80);
    ws_usuario          varchar2(80);

begin


    ws_usuario := prm_usuario;
    if ws_usuario is null then    
        ws_usuario := gbl.getUsuario;
    end if;

    ws_ordem  := prm_ordem+1;
	ws_counter := 1;
	for i in (select column_value from table(fun.vpipe((fun.getprop(prm_objid,'SUBQUERY'))))) loop
	    if ws_counter = ws_ordem then
		    ws_subquery := i.column_value;
		end if;
		ws_counter := ws_counter+1;
	end loop;

	ws_counter := 1;
	loop
		if ws_counter = ws_ordem then
			exit;
		else
			ws_space := ws_space;
			ws_space_at := ws_space_at;
		end if;
	    ws_counter := ws_counter+1;
	end loop;

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

	select cs_coluna into ws_cod from ponto_avaliacao where cd_ponto = prm_objid;
	select column_value into ws_cod from table(fun.vpipe((ws_cod))) where rownum = 1;
	select st_com_codigo into ws_cod from micro_coluna where cd_coluna = ws_cod and cd_micro_visao = prm_micro_visao;

    ws_zebrado := 'First';

    if  not fun.check_user(ws_usuario) or not fun.check_netwall(ws_usuario) or fun.check_sys <> 'OPEN' then
	    if  not fun.check_user(ws_usuario) then
            insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - CHECK_USER', ws_usuario, 'ERRO');
            commit;
		end if;
	    if  not fun.check_netwall(ws_usuario) then
            insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - CHECK_NETWALL', ws_usuario, 'ERRO');
            commit;
		end if;
	    if  fun.check_sys <> 'OPEN' then
            insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - CHECK_SYS', ws_usuario, 'ERRO');
            commit;
		end if;
        raise ws_acesso;
    end if;

	ws_isolado := fun.getprop(prm_objid, 'FILTRO');

	/*fcl.refresh_Session;*/

	ws_colup     := prm_colup;
	ws_coluna    := prm_coluna;
	ws_agrupador := fun.conv_template(prm_micro_visao, prm_agrupador);
	ws_rp	     := 'GROUP';

	open crs_micro_visao;
	fetch crs_micro_visao into ws_micro_visao;
	close crs_micro_visao;

	ws_texto := prm_parametros;

    ws_parametros := prm_parametros;

	open nc_colunas;
	    loop
			fetch nc_colunas bulk collect into ret_mcol limit 400;
			exit when nc_colunas%NOTFOUND;
	    end loop;
	close nc_colunas;

	ws_counter := 0;

	ws_sem := 1;


	ws_self := prm_self;

	if instr(ws_self, '|') = 1 then
	    ws_self := substr(ws_self, 2 ,length(ws_self)-1);
	end if;

	ws_self := replace(ws_self, '||', '|');

    /*if substr(ws_coluna, length(ws_coluna)) = '|' then
	    ws_coluna := substr(ws_coluna, 0, length(ws_coluna)-1);
	end if;*/

	--ws_coluna := substr(ws_self, 0, instr(ws_self, '|')-1);

	--ws_colup := substr(ws_self, 0, instr(ws_self, '|')-1);

    
    if instr(ws_coluna, '|') > 0 then
	    ws_coluna := substr(ws_coluna, 0, length(ws_coluna)-1);
	end if;

	/*
		htp.p('coluna => '||ws_coluna);
		htp.p('parametros => '||ws_parametros);
		htp.p('rp => '||ws_rp);
		htp.p('colup => '||ws_colup);
	*/

	--insert into log_eventos values(sysdate, prm_micro_visao||'/'||ws_coluna||'/->'||ws_self||'<-|'||ws_parametros||'/'||ws_rp||'/'||ws_colup||'/'||WS_AGRUPADOR, ws_usuario, 'SUBQUERY', 'SUBQUERY', '01');

	ws_sql := core.MONTA_QUERY_DIRECT(prm_micro_visao, ws_coluna, ws_parametros, ws_rp, ws_colup, ws_query_pivot, ws_query_montada, ws_lquery, ws_ncolumns, ws_pvcolumns, ws_agrupador, ws_mfiltro, prm_objid, fun.getprop(prm_objid,'SUBQUERY_ORDEM'), prm_screen => prm_screen, prm_cross => 'N', prm_cab_cross => ws_cab_cross, prm_self => 'SUBQUERY_'||ws_self,prm_usuario => ws_usuario);

	/*if length(ws_parametros) > 3 then
	    ws_self := ws_self||'|'||replace(ws_parametros, '1|1', '');
	end if;*/

    insert into log_eventos values(sysdate, prm_micro_visao||'/'||ws_coluna||'/->'||ws_self||'<-|'||ws_parametros||'/'||ws_rp||'/'||ws_colup||'/'||WS_AGRUPADOR, ws_usuario, 'SUBQUERY', 'SUBQUERY', '01');

	ws_queryoc := '';
	ws_counter := 0;
	ws_gotocounter := 0;

	loop
	    ws_counter := ws_counter + 1;
	    if  ws_counter > ws_query_montada.COUNT then
	    	exit;
	    end if;
	    ws_queryoc := ws_queryoc||ws_query_montada(ws_counter);
		htp.p(ws_query_montada(ws_counter));
	end loop;

	/*if ws_sql = 'Sem Query' then
	   raise ws_semquery;
	end if;*/

	ws_sql_pivot := ws_query_pivot;

	/*open crs_xgoto(ws_usuario);
	loop
	    fetch crs_xgoto into ws_xgoto;
	    exit when crs_xgoto%notfound;
		ws_gotocounter := ws_gotocounter+1;
	end loop;
	close crs_xgoto;*/

	ws_counter   := 0;
	ws_counterid := 1;
	ws_ccoluna   := 0;
    ws_step := 0;

	ws_repeat := 'show';
	ws_firstid := 'Y';
    ws_agrupador_max :=0;


	ws_cursor := dbms_sql.open_cursor;
	dbms_sql.parse( c => ws_cursor, statement => ws_query_montada, lb => 1, ub => ws_lquery, lfflg => true, language_flag => dbms_sql.native );

	

	ws_sql := core.bind_direct(replace(ws_parametros||'|'||ws_self, '||', '|'), ws_cursor, '', prm_objid, prm_micro_visao, prm_screen,prm_usuario => ws_usuario);

	ws_counter := 0;
	loop
	    ws_counter := ws_counter + 1;
	    if  ws_counter > ws_ncolumns.COUNT then
	    	exit;
	    end if;
	    dbms_sql.define_column(ws_cursor, ws_counter, ret_coluna, 2000);
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
		dbms_sql.column_value(ws_cursor, ws_ccoluna, ret_coluna);

		if  ret_mcol(ws_xcoluna).st_agrupador = 'SEM' then
		    ws_ctcol  := ws_ctcol + 1;
		end if;
		if  nvl(ret_coluna,'%*') = '%*' and ret_mcol(ws_xcoluna).st_agrupador = 'SEM' then
		    ws_ctnull := ws_ctnull + 1;
			ret_colgrp := 1;
		end if;

	  end loop;

	    ws_xatalho := '';
	    ws_pipe    := '';
	    ws_bindn := 1;
	    --while ws_bindn is not null loop
		if  ws_bindn = 1 or ws_ncolumns(ws_bindn) <> ws_ncolumns(ws_bindn-1) then
		    dbms_sql.column_value(ws_cursor, ws_bindn, ret_coluna);
		    ws_vcon(ws_bindn) := ret_coluna;
		    if  nvl(ws_vcon(ws_bindn),'%*') <> '%*' then
		        ws_xatalho := ws_xatalho||ws_pipe;
			ws_xatalho := trim(ws_xatalho)||ws_vcol(ws_bindn)||'|'||ws_vcon(ws_bindn);
			ws_pipe    := '|';
		    end if;
		end if;
		--ws_bindn := ws_vcol.NEXT(ws_bindn);
	    --end loop;

		dbms_sql.column_value(ws_cursor, ws_ncolumns.COUNT-1, ret_colgrp);
		dbms_sql.column_value(ws_cursor, ws_ncolumns.COUNT, ret_coltot);
		ws_linha := ws_linha+1;
		
		ws_fixed := nvl(fun.getprop(prm_objid, 'FIXED-N'), '9999')+1;
		if length(fun.getprop(prm_objid,'TOTAL_GERAL_TEXTO')) > 0 and ws_fixed > 0 then
		    ws_fixed := 999;
		end if;


		if(ws_zebrado = 'Escuro') then
			htp.p('<tr data-tipo="'||ws_zebrado||'" class="es sub nivel'||ws_ordem||'">');
		else
			htp.p('<tr data-tipo="'||ws_zebrado||'" class="cl sub nivel'||ws_ordem||'">');
		end if;

		if(length(ws_tmp_jump) > 5) then
		    ws_check := ws_tmp_check;
		end if;

		ws_drill_atalho := replace('|'||trim(ws_xatalho),'||','|');
		if(instr(ws_drill_atalho, '|', 1, 1) = 1) then
		  ws_drill_atalho := substr(ws_drill_atalho,2,length(ws_drill_atalho));
		end if;

		ws_jump := ws_tmp_jump;

		if(length(ws_subquery) > 0) then
		    ws_jump := 'seta';
		else
		    ws_jump := 'setadown';
		end if;

		/*if fun.verifica_post(prm_objid, ws_drill_atalho) then
			ws_jump := ws_jump||' flag';
		end if;*/
		
		if ws_fixed > 1 then
			ws_fix   := 'fixsub';
			ws_fixed := ws_fixed-1;
		else
			ws_fix   := '';
		end if;


		if ret_colgrp = 0 then
		    htp.p('<td '||ws_check||' class="'||ws_jump||' '||ws_fix||'" data-ordem="'||ws_ordem||'" data-valor="'||replace(ws_parametros||'|'||ws_drill_atalho, '||', '|')||'" data-self="'||ws_drill_atalho||'"  data-subquery="'||ws_subquery||'"></td>');
		end if;

	    ws_counter := 0;
		ws_limite_i := fun.getprop(prm_objid,'COLUNA_INICIAL');
        ws_limite_f := fun.getprop(prm_objid,'COLUNA_FINAL');
        ws_total_acumulado := fun.getprop(prm_objid,'TOTAL_ACUMULADO');
		ws_linha_acumulada := fun.getprop(prm_objid,'LINHA_ACUMULADA');
	loop
		ws_counter := ws_counter + 1;

		if fun.getprop(prm_objid,'NO_TUP') <> 'S' or ws_pvcolumns.COUNT = 0 then
			if  ws_counter > ws_ncolumns.COUNT-2 then
				exit;
			end if;
		else
		  if  ws_counter > ws_ncolumns.COUNT-2 then
				exit;
			end if;
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

	  if  ws_ccoluna > ret_mcol.COUNT then
          ws_ccoluna := ws_ccoluna - 1;
          exit;
      end if;

      if ret_mcol(ws_ccoluna).cd_coluna = ws_ncolumns(ws_counter)  then
           exit;
      end if;


      ws_ccoluna := ws_ccoluna + 1;

  end loop;

		dbms_sql.column_value(ws_cursor, ws_counter, ret_coluna);

		ret_coluna := replace(ret_coluna,'"','*');
		ret_coluna := replace(ret_coluna,'/',' ');

		if  ws_firstid = 'Y' then
		    ws_idcol := ' id="'||prm_objid||ws_counter||'l" ';
		else
		    ws_idcol := '';
		end if;

		ws_drill_atalho := replace(trim(ws_atalho)||'|'||trim(ws_xatalho),'||','|');
		if(instr(ws_drill_atalho, '|', 1, 1) = 1) then
		  ws_drill_atalho := substr(ws_drill_atalho,2,length(ws_drill_atalho));
		end if;

		/*if fun.verifica_post(prm_objid, ws_drill_atalho) then
			if(length(ws_jump) > 5) then
			     ws_jump := ' padding-left: 13px; background: url('||fun.r_gif('flag', 'PNG')||'); ';
		    end if;
		end if;*/

		if(length(ws_jump) > 1) then
		  ws_jump := 'style="'||ws_jump||'"';
		end if;
		
		if ws_fixed > 1 then
			ws_fix   := 'fixsub';
			ws_fixed := ws_fixed-1;
		else
			ws_fix   := '';
		end if;


		if(rtrim(ret_mcol(ws_ccoluna).st_invisivel) <> 'S') then
			if(rtrim(ret_mcol(ws_ccoluna).st_alinhamento) = 'RIGHT') then
				ws_jump := ws_jump||' class="dir"';
			end if;

			if(rtrim(ret_mcol(ws_ccoluna).st_alinhamento) = 'CENTER') then
				ws_jump := ws_jump||' class="cen"';
			end if;

			if ret_mcol(ws_ccoluna).st_com_codigo = 'N' and ret_mcol(ws_ccoluna).st_agrupador = 'SEM' and ret_mcol(ws_ccoluna).cd_ligacao <> 'SEM' then

				if length(ws_repeat) = 4 then
		            ws_repeat := 'hidden';
		        else
		            ws_repeat := 'show';
		        end if;
			elsif ret_mcol(ws_ccoluna).st_agrupador = 'SEM' then
				ws_jump := '';
			end if;
		else
			ws_jump := ws_jump||' class="no_font"';
		end if;

		if length(trim(ws_atalho)) > 0 and ws_ct_top = 1 then
		    ws_pivot := 'data-p="'||trim(ws_atalho)||'" ';
		else
		    ws_pivot := '';
		end if;
		

		if  ws_linha_acumulada = 'S' and ret_mcol(ws_ccoluna).st_agrupador <> 'SEM' and ws_counter < ws_ncolumns.COUNT and ret_colgrp = 0  THEN

			if  ws_counter > ws_limite_i and ws_counter < (ws_ncolumns.COUNT)-ws_limite_f then
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

		--htp.p(ws_content);

 
	 select st_com_codigo into ws_cod_ac from micro_coluna where cd_micro_visao = prm_micro_visao and cd_coluna = ret_mcol(ws_ccoluna).cd_coluna;
	 /*if ret_colgrp = 0 then*/

	  
	   
		if  ret_mcol(ws_ccoluna).st_agrupador = 'SEM' and ws_content = ws_coluna_ant(ws_counter) then
			
			if length(ws_repeat) = 4 then
			    htp.p('<td class="'||ws_fix||'" '||ws_idcol||' data-i="'||ws_counter||'">'||fcl.fpdata((ws_ctnull - ws_ctcol),0,'','')||fun.ifmascara(ws_content,rtrim(ret_mcol(ws_ccoluna).nm_mascara), prm_micro_visao, ret_mcol(ws_ccoluna).cd_coluna, prm_objid, '', ret_mcol(ws_ccoluna).formula, prm_screen)||'</td>');
			end if;
		else
		    if ret_mcol(ws_ccoluna).st_agrupador = 'SEM' then
				if length(ws_repeat) = 4 then
					if ws_cod = 'S' then
					    
					    htp.p('<td '||ws_idcol||' class="'||ws_fix||'" data-i="'||ws_counter||'">'||fun.ifmascara(ws_content,rtrim(ret_mcol(ws_ccoluna).nm_mascara),prm_micro_visao, ret_mcol(ws_ccoluna).cd_coluna, prm_objid, '', ret_mcol(ws_ccoluna).formula, prm_screen)||'</td>');
					else
					    if ws_counter = 1 then

							if ws_cod_ac <> 'S' then
				            	htp.p('<td '||ws_idcol||' class="'||ws_fix||'" data-i="'||ws_counter||'">'||fun.ifmascara(ws_content,rtrim(ret_mcol(ws_ccoluna).nm_mascara),prm_micro_visao, ret_mcol(ws_ccoluna).cd_coluna, prm_objid, '', ret_mcol(ws_ccoluna).formula, prm_screen)||'</td>');

							end if;
						else
						    htp.p('<td '||ws_idcol||' class="'||ws_fix||'" data-i="'||ws_counter||'">'||fun.ifmascara(ws_content,rtrim(ret_mcol(ws_ccoluna).nm_mascara),prm_micro_visao, ret_mcol(ws_ccoluna).cd_coluna, prm_objid, '', ret_mcol(ws_ccoluna).formula, prm_screen)||'</td>');

						end if;
					end if;
				
				end if;
			else
		        if(ret_mcol(ws_ccoluna).st_agrupador in ('PSM','PCT') and ret_colgrp <> 0) or (ret_mcol(ws_ccoluna).st_gera_rel = 'N' and ret_colgrp <> 0) then
		            ws_content := ' ';
		        end if;
					if fun.getprop(prm_objid,'SO_TOT', prm_tipo => 'CONSULTA') <> 'S' or ret_coltot = 1 or nvl(prm_drill, 'C') = 'C' then

						htp.p('<td data-i="'||ws_counter||'" '||ws_idcol||fun.check_blink_total(prm_objid, ret_mcol(ws_ccoluna).cd_coluna, ws_content, '', prm_screen)||' '||ws_jump||' '||ws_pivot||'>');

							if ret_colgrp <> 0 then 
								if ret_coltot <> 1 then
								
									htp.prn(fun.um(ret_mcol(ws_ccoluna).cd_coluna, prm_micro_visao, fun.ifmascara(ws_content,rtrim(ret_mcol(ws_ccoluna).nm_mascara), prm_micro_visao, ret_mcol(ws_ccoluna).cd_coluna, prm_objid, '', ret_mcol(ws_ccoluna).formula, prm_screen)));
									
								else
									htp.prn(fun.um(ret_mcol(ws_ccoluna).cd_coluna, prm_micro_visao, fun.ifmascara(ws_content,rtrim(ret_mcol(ws_ccoluna).nm_mascara), prm_micro_visao, ret_mcol(ws_ccoluna).cd_coluna, prm_objid, '', ret_mcol(ws_ccoluna).formula, prm_screen)));
								end if;
							else
								htp.prn(fun.um(ret_mcol(ws_ccoluna).cd_coluna, prm_micro_visao, fun.ifmascara(ws_content,rtrim(ret_mcol(ws_ccoluna).nm_mascara), prm_micro_visao, ret_mcol(ws_ccoluna).cd_coluna, prm_objid, '', ret_mcol(ws_ccoluna).formula, prm_screen)));
							end if;


							if(fun.ret_sinal(prm_objid,ret_mcol(ws_ccoluna).cd_coluna, ws_content) <> 'nodata') then
								htp.p(fun.ret_sinal(prm_objid,ret_mcol(ws_ccoluna).cd_coluna, ws_content));
								
							end if;

						htp.p('</td>');

					end if;
			end if;


		if length(fun.check_blink_linha(prm_objid, ret_mcol(ws_ccoluna).cd_coluna, ws_linha, ret_coluna, prm_screen)) > 7 and ret_colgrp = 0 then
		    ws_blink_linha := fun.check_blink_linha(prm_objid, ret_mcol(ws_ccoluna).cd_coluna, ws_linha, ret_coluna, prm_screen);
		end if;


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
	ws_total_linha := 0;
	ws_acumulada_linha := 0;
	dbms_sql.close_cursor(ws_cursor);
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

exception
	when others	     then
	    insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - SUBQUERY', ws_usuario, 'ERRO');
        commit;
end subquery;

procedure consulta_dados ( prm_objid         varchar2 default null,
                           prm_screen        varchar2 default null,
						   prm_micro_visao   varchar2 default null, 
						   prm_coluna        varchar2 default null,
						   prm_parametros    varchar2 default null, 
						   prm_rp            varchar2 default null, 
						   prm_colup         varchar2 default null,
						   prm_agrupador     varchar2 default null,
						   prm_self          varchar2 default null ) as

    type ws_tmcolunas is table of MICRO_COLUNA%ROWTYPE index by pls_integer;
	
	cursor nc_colunas is select * from MICRO_COLUNA where cd_micro_visao = prm_micro_visao;

	ws_firstid		 char(1);
    ws_linhas        integer;
	ws_cursor		 integer;
	ws_vazio         boolean;
	ws_linha_ac      varchar2(10);
	ws_saida         varchar2(10) := 'S';
	ws_limite_i      varchar2(10);
	ws_limite_f      varchar2(10);
	ws_total_ac      varchar2(10);
	ws_repeat        varchar2(60) := 'show';
	ws_usuario       varchar2(80);
	ws_alinhamento   varchar2(80);
	ws_objid		 varchar2(120);
	ws_idcol		 varchar2(120);
	ws_zebrado       varchar2(120);
	ws_zebrado_d     varchar2(120);
	ws_pipe          varchar2(200);
	ws_cod_coluna    varchar2(200);
	ws_calculada_n   varchar2(200);
    ws_calculada_m   varchar2(200);
	ws_hint          varchar2(300);
	ws_pivot         varchar2(300);
	ws_check         varchar2(300);
	ws_tmp_check     varchar2(300);
	ws_tmp_jump		 varchar2(300);
	ws_ordem         varchar2(400);
	ws_nm_var_al     varchar2(400);
	ws_cd_coluna     varchar2(400);
	ws_jump			 varchar2(600);
	ws_subquery      varchar2(600);
	ws_conteudo_ant  varchar2(800);
	ws_calculada     varchar2(800);
	ret_colgrp       varchar2(2000);
	ret_coltot       varchar2(2000);
	ws_drill_atalho  varchar2(3000);
	ws_binds         varchar2(3000);
	ret_coluna		 varchar2(4000);
	ws_texto_al      varchar2(4000);
	ws_pivot_coluna  varchar2(4000);
	ws_cab_cross     varchar2(4000);
	ws_blink_linha   varchar2(4000) := 'N/A';
	ws_owner_bi      varchar2(20);
	ws_atalho        clob;
	ws_xatalho       clob;
	ws_excel         clob;
	ws_content_ant	 clob;
	ws_content		 long;
	ws_parametros	 long;
	ws_sql			 long;
	ws_query_pivot   long;
	ws_count         number := 0;
	ws_scol			 number := 0;
	ws_temp_valor    number := 0;
	ws_temp_valor2   number := 0;
	ws_total_linha   number := 0;
	ws_ac_linha      number := 0;
	ws_countor       number;
	ws_countv        number;
	ws_step          number;
	ws_stepper       number;
	ws_top           number;
	ws_ct_top        number;
	ws_counter       number;
	ws_ccoluna       number;
	ws_chcor         number;
	ws_ctnull        number;
	ws_ctcol         number;
	ws_xcoluna       number;
	ws_bindn         number;
	ws_linha         number;
	ws_linha_col     number;
	ws_amostra       number;
	ws_lquery		 number;
	dimensao_soma    number := 1;
	ws_nodata        exception;
	ws_coluna_ant    dbms_sql.varchar2_table;
	ws_arr_atual     dbms_sql.varchar2_table;
	ws_arr_anterior  dbms_sql.varchar2_table;
	ws_vcol			 dbms_sql.varchar2_table;
	ws_vcon			 dbms_sql.varchar2_table;
	ws_ncolumns	     dbms_sql.varchar2_table;
	ws_mfiltro	     dbms_sql.varchar2_table;
	ws_array_atual   dbms_sql.varchar2_table;
	ws_class_atual   dbms_sql.varchar2_table;
	ws_pvcolumns     dbms_sql.varchar2_table;
	ws_query_montada dbms_sql.varchar2a;
	ws_query_count   dbms_sql.varchar2a;

	ret_mcol         ws_tmcolunas;

begin
	ws_owner_bi := nvl(fun.ret_var('OWNER_BI'),'DWU'); 
    ws_usuario  := gbl.getUsuario;

    open nc_colunas;
	loop
	    fetch nc_colunas bulk collect into ret_mcol limit 400;
	    exit when nc_colunas%NOTFOUND;
	end loop;
	close nc_colunas;

    ws_ordem := '';
	ws_countor := 0;
	select count(*) into ws_countor from object_attrib where cd_object = prm_objid and CD_PROP = 'ORDEM' and owner = ws_usuario;
	if ws_countor = 1 then
	    select upper(propriedade) into ws_ordem from object_attrib where cd_object = prm_objid and CD_PROP = 'ORDEM' and owner = ws_usuario;
	else
	    select count(*) into ws_countor from object_attrib where cd_object = prm_objid and CD_PROP = 'ORDEM' and owner = 'DWU';
	    if ws_countor = 1 then
	        select upper(propriedade) into ws_ordem from object_attrib where cd_object = prm_objid and CD_PROP = 'ORDEM' and owner = 'DWU';
	    end if;
	end if;


    ws_sql := core.MONTA_QUERY_DIRECT(prm_micro_visao, prm_coluna, prm_parametros, prm_rp, prm_colup, ws_query_pivot, ws_query_montada, ws_lquery, ws_ncolumns, ws_pvcolumns, prm_agrupador, ws_mfiltro, prm_objid, ws_ordem, prm_screen => prm_screen, prm_cross => 'N', prm_cab_cross => ws_cab_cross, prm_self => prm_self);

	ws_counter := 0;

    /*loop
	    ws_counter := ws_counter + 1;
	    if  ws_counter > ws_query_montada.COUNT then
	    	exit;
	    end if;
	    htp.p(ws_query_montada(ws_counter));
	    
	end loop;*/
	
	ws_cursor := dbms_sql.open_cursor;
	dbms_sql.parse( c => ws_cursor, statement => ws_query_montada, lb => 1, ub => ws_lquery, lfflg => true, language_flag => dbms_sql.native );


	ws_binds := core.bind_direct(ws_parametros, ws_cursor, '', prm_objid, prm_micro_visao, prm_screen);
		
    ws_binds := replace(ws_binds, 'Binds Carregadas=|', '');
	/*ws_cursor := prm_cursor;*/
	

		ws_counter := 0;
	loop
	    ws_counter := ws_counter + 1;
	    if  ws_counter > ws_ncolumns.COUNT then
	    	exit;
	    end if;
	    dbms_sql.define_column(ws_cursor, ws_counter, ret_coluna, 2000);
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
	

	ws_counter := 0;
	
	loop
	    ws_counter := ws_counter + 1;
	    if  ws_counter > ws_ncolumns.COUNT then
	    	exit;
	    end if;
	    dbms_sql.define_column(ws_cursor, ws_counter, ret_coluna, 2000);
	end loop;
	ws_linhas := dbms_sql.execute(ws_cursor);
	
	

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
			dbms_sql.column_value(ws_cursor, ws_ccoluna, ret_coluna);


			if  ret_mcol(ws_xcoluna).st_agrupador = 'SEM' then
				ws_ctcol  := ws_ctcol + 1;
			end if;
			if  nvl(ret_coluna,'%*') = '%*' and ret_mcol(ws_xcoluna).st_agrupador = 'SEM' then
				ws_ctnull := ws_ctnull + 1;
				ws_chcor := 1;
			end if;

	    end loop;

	    ws_xatalho := '';
	    ws_pipe    := '';
	    ws_bindn := ws_vcol.FIRST;
	    while ws_bindn is not null loop
		if  ws_bindn = 1 or ws_ncolumns(ws_bindn) <> ws_ncolumns(ws_bindn-1) then
		    dbms_sql.column_value(ws_cursor, ws_bindn, ret_coluna);
		    ws_vcon(ws_bindn) := ret_coluna;
		    if  nvl(ws_vcon(ws_bindn),'%*') <> '%*' then
		        ws_xatalho := ws_xatalho||ws_pipe;
			ws_xatalho := trim(ws_xatalho)||ws_vcol(ws_bindn)||'|'||ws_vcon(ws_bindn);
			ws_pipe    := '|';
		    end if;
		end if;
		ws_bindn := ws_vcol.NEXT(ws_bindn);
	    end loop;


		dbms_sql.column_value(ws_cursor, ws_ncolumns.COUNT-1, ret_colgrp);
		dbms_sql.column_value(ws_cursor, ws_ncolumns.COUNT, ret_coltot);

		ws_linha := ws_linha+1;
		ws_linha_col := ws_linha_col+1;

		
        
        ws_amostra := to_number(fun.getprop(prm_objid,'AMOSTRA'));
        
        if (ws_linha > ws_amostra and ws_amostra <> 0) then
			exit;
		end if;


			if ret_colgrp = 0 then
			    if(ws_zebrado = 'Escuro') then
				    if ws_saida <> 'O' then
				        htp.p('<tr class="es">');
				    end if;
				    if ws_saida = 'S' or ws_saida = 'O' then
				        fcl.gera_conteudo(ws_excel, ws_saida, '<Row>', '', '');
				    end if;
				else
				    if ws_saida <> 'O' then
				        htp.p('<tr class="cl">');
					end if;
					if ws_saida = 'S' or ws_saida = 'O' then
				        fcl.gera_conteudo(ws_excel, ws_saida, '<Row>', '', '');
				    end if;
				end if;
			else
				
				if ws_saida <> 'O' then
					if ret_coltot = 1 then
						htp.p('<tr class="total geral">');
					else
					    if fun.getprop(prm_objid,'SO_TOT') <> 'S' then
						    htp.p('<tr class="total normal">');
						end if;
					end if;
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

			ws_drill_atalho := replace('|'||trim(ws_xatalho),'||','|');
			
			if(instr(ws_drill_atalho, '|', 1, 1) = 1) then
			    ws_drill_atalho := substr(ws_drill_atalho,2,length(ws_drill_atalho));
			end if;

			ws_jump := ws_tmp_jump;

			if fun.verifica_post(prm_objid, ws_drill_atalho) then
				ws_jump := ws_jump||' flag';
			end if;

			ws_cod_coluna := ret_coluna;

			if ret_colgrp = 0 then
			    if ws_saida <> 'O' then
				    htp.p('<td '||ws_check||' title="'||ret_coluna||'" class="'||ws_jump||'" data-subquery="'||ws_subquery||'" data-ordem="1" data-valor="'||ws_drill_atalho||'"></td>');
				end if;
			else
			    if ret_coltot = 1 then
			        if ws_saida <> 'O' then
					    htp.p('<td style="text-align: right;" colspan="'||dimensao_soma||'" data-valor="'||ws_drill_atalho||'">'||fun.getprop(prm_objid,'TOTAL_GERAL_TEXTO')||'</td>');
					end if;
				else
			        if ws_saida <> 'O' then
					    /* diferente do total geral */
						if fun.getprop(prm_objid,'SO_TOT') <> 'S' then
							htp.p('<td data-valor="'||ws_drill_atalho||'"></td>');
						end if;
					end if;
				end if;
			end if;

		    ws_counter := 0;
			ws_limite_i := fun.getprop(prm_objid,'COLUNA_INICIAL');
	        ws_limite_f := fun.getprop(prm_objid,'COLUNA_FINAL');
	        ws_total_ac := fun.getprop(prm_objid,'TOTAL_ACUMULADO');
			ws_linha_ac := fun.getprop(prm_objid,'LINHA_ACUMULADA');
			

			loop
				ws_counter := ws_counter + 1;

				if fun.getprop(prm_objid,'NO_TUP') <> 'S' or ws_pvcolumns.COUNT = 0 then
					if  ws_counter > ws_ncolumns.COUNT-2 then
						exit;
					end if;
				else
				  if  ws_counter > ws_ncolumns.COUNT-2 then
						exit;
					end if;
				end if;
				begin
				    if(ws_counter) < ws_step-ws_stepper then
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
				

					if  ws_ccoluna > ret_mcol.COUNT then
				        ws_ccoluna := ws_ccoluna - 1;
				        exit;
				    end if;

				    if ret_mcol(ws_ccoluna).cd_coluna = ws_ncolumns(ws_counter)  then
				        exit;
				    end if;

				    ws_ccoluna := ws_ccoluna + 1;

				end loop;
				
		        dbms_sql.column_value(ws_cursor, ws_counter, ret_coluna);

				ret_coluna := replace(ret_coluna,'"','*');
				ret_coluna := replace(ret_coluna,'/',' ');

				ws_content := ret_coluna;    

				begin
				
					if ws_linha > 1 then
						if trim(ret_coluna) = trim(ws_arr_anterior(ws_counter)) and fun.getprop(prm_objid,'NAO_REPETIR') = 'S' and ret_mcol(ws_ccoluna).st_agrupador = 'SEM' then
							ws_content := '';
						end if;
					end if;
				exception when others then
				    htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			    end;

				if ws_firstid = 'Y' then
				    ws_idcol := ' id="'||ws_objid||ws_counter||'l" ';
				else
				    ws_idcol := '';
				end if;

				ws_drill_atalho := replace(trim(ws_atalho)||'|'||trim(ws_xatalho),'||','|');
				
				if(instr(ws_drill_atalho, '|', 1, 1) = 1) then
				    ws_drill_atalho := substr(ws_drill_atalho,2,length(ws_drill_atalho));
				end if;

				ws_jump := '';

				if(length(ws_jump) > 1) then
				  ws_jump := 'style="'||ws_jump||'"';
				end if;

				if(rtrim(ret_mcol(ws_ccoluna).st_invisivel) <> 'S') then

					if  rtrim(substr(ret_mcol(ws_ccoluna).formula,1,8))='FLEXCOL=' then
					    begin
							ws_texto_al     := replace(ret_mcol(ws_ccoluna).formula,'FLEXCOL=','');
							ws_nm_var_al    := substr(ws_texto_al, 1 ,instr(ws_texto_al,'|')-1);
							ws_cd_coluna := fun.gparametro(trim(ws_nm_var_al), prm_screen => prm_screen);
							select nvl(st_alinhamento, 'LEFT') into ws_alinhamento
							from MICRO_COLUNA
							where cd_micro_visao = prm_micro_visao and
							cd_coluna = ws_cd_coluna;
						exception when others then
						    ws_alinhamento := ret_mcol(ws_ccoluna).st_alinhamento;
						end;
		            else
				        ws_alinhamento := ret_mcol(ws_ccoluna).st_alinhamento;
				    end if;

					if ret_colgrp = 0 and nvl(ret_mcol(ws_ccoluna).color, 'transparent') <> 'transparent' then
					    ws_jump := ws_jump||'style="background-color: '||ret_mcol(ws_ccoluna).color||';"';
					end if;

					if ws_alinhamento = 'RIGHT' then
						ws_jump := ws_jump||' class="dir"';
					elsif ws_alinhamento = 'CENTER' then
						ws_jump := ws_jump||' class="cen"';
					end if;
				else
					ws_jump := ws_jump||' class="no_font"';
				end if;
				

				if ws_content = '"' then
				    ws_jump := ws_jump||' class="cen"';
				end if;

				ws_jump := trim(ws_jump);

				if ret_mcol(ws_ccoluna).st_com_codigo = 'N' and ret_mcol(ws_ccoluna).st_agrupador = 'SEM' and ret_mcol(ws_ccoluna).cd_ligacao <> 'SEM' then

					if length(ws_repeat) = 4 then
			            ws_repeat := 'hidden';
			        else
			            ws_repeat := 'show';
			        end if;
				end if;

				ws_pivot := 'data-p="'||trim(ws_atalho)||'"';

				if ws_linha_ac = 'S' and ret_mcol(ws_ccoluna).st_agrupador <> 'SEM' and ws_counter < ws_ncolumns.COUNT and ret_colgrp = 0  THEN
		            if ws_counter > ws_limite_i and ws_counter < (ws_ncolumns.COUNT)-ws_limite_f and ws_scol = 1 then
						begin
							ws_temp_valor := to_number(nvl(ret_coluna, '0'));
						exception when others then
						    ws_temp_valor := 0;
						end;

						ws_ac_linha := ws_ac_linha + ws_temp_valor;
						ws_content  := ws_ac_linha;
					end if;
				end if;

				ws_pivot_coluna := '';


				for i in (select cd_conteudo from table(fun.vpipe_par(trim(ws_atalho)))) loop
				    ws_pivot_coluna := ws_pivot_coluna||'-'||replace(i.cd_conteudo, '|', '-');
				end loop;

				select ret_mcol(ws_ccoluna).cd_coluna||'-'||ws_pivot_coluna into ws_pivot_coluna from dual;

				if length(ws_pivot_coluna) = length(ret_mcol(ws_ccoluna).cd_coluna||'-') then
				    ws_pivot_coluna := ret_mcol(ws_ccoluna).cd_coluna;
				end if;

				ws_pivot_coluna := replace(ws_pivot_coluna, '--', '-');
				
				ws_hint := '';
				
				if nvl(ret_mcol(ws_ccoluna).limite, 0) > 0 and length(ws_content) > nvl(ret_mcol(ws_ccoluna).limite, 0) then
				    ws_hint := ws_content;
				    ws_content := substr(ws_content, 0, ret_mcol(ws_ccoluna).limite);
				end if;
				
				if nvl(ws_hint, 'N/A') <> 'N/A' then
				    ws_hint := 'title="'||ws_hint||'"';
				end if;
				

				
				select count(*) into ws_countv from table(fun.vpipe((select propriedade from object_attrib where cd_object = prm_objid and cd_prop = 'VISIVEL'))) where column_value = ret_mcol(ws_ccoluna).cd_coluna;

        		if ws_countv = 0 or nvl(ret_mcol(ws_ccoluna).url, 'N/A') <> 'N/A' then

					if ret_mcol(ws_ccoluna).st_agrupador = 'SEM' and ws_content = ws_coluna_ant(ws_counter) then
						if length(ws_repeat) = 4 then
							if ws_saida <> 'O' then
								if ws_countv = 0 then
									htp.tableData( fcl.fpdata((ws_ctnull - ws_ctcol),0,'','')||fun.ifmascara(ws_content,rtrim(ret_mcol(ws_ccoluna).nm_mascara), prm_micro_visao, ret_mcol(ws_ccoluna).cd_coluna, prm_objid, '', ret_mcol(ws_ccoluna).formula, prm_screen), calign => '', cattributes => ''||ws_hint||'  data-i="'||ws_counter||'" '||ws_idcol||fun.check_blink(prm_objid, ret_mcol(ws_ccoluna).cd_coluna, ws_content, '', prm_screen)||' '||ws_jump||'');
								end if;
								if nvl(ret_mcol(ws_ccoluna).url, 'N/A') <> 'N/A' then
									htp.p('<td onmouseleave="out_evento();" class="imgurl" data-url="'||replace(replace(ret_mcol(ws_ccoluna).url,'"',''), '$[DOWNLOAD]', ''||ws_owner_bi||'.fcl.download?arquivo=')||'" data-i="'||ws_counter||'" '||ws_idcol||fun.check_blink(prm_objid, ret_mcol(ws_ccoluna).cd_coluna, ws_content, '', prm_screen)||' '||ws_jump||' '||ws_pivot||'>');
									htp.p('<svg style="border-radius: 2px; padding: 0px 1px; background: #DEDEDE; width: 14px;" version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" 	 viewBox="0 0 58 58" style="enable-background:new 0 0 58 58;" xml:space="preserve"> <g> 	<path d="M57,6H1C0.448,6,0,6.447,0,7v44c0,0.553,0.448,1,1,1h56c0.552,0,1-0.447,1-1V7C58,6.447,57.552,6,57,6z M56,50H2V8h54V50z" 		/> 	<path d="M16,28.138c3.071,0,5.569-2.498,5.569-5.568C21.569,19.498,19.071,17,16,17s-5.569,2.498-5.569,5.569 		C10.431,25.64,12.929,28.138,16,28.138z M16,19c1.968,0,3.569,1.602,3.569,3.569S17.968,26.138,16,26.138s-3.569-1.601-3.569-3.568 		S14.032,19,16,19z"/> 	<path d="M7,46c0.234,0,0.47-0.082,0.66-0.249l16.313-14.362l10.302,10.301c0.391,0.391,1.023,0.391,1.414,0s0.391-1.023,0-1.414 		l-4.807-4.807l9.181-10.054l11.261,10.323c0.407,0.373,1.04,0.345,1.413-0.062c0.373-0.407,0.346-1.04-0.062-1.413l-12-11 		c-0.196-0.179-0.457-0.268-0.72-0.262c-0.265,0.012-0.515,0.129-0.694,0.325l-9.794,10.727l-4.743-4.743 		c-0.374-0.373-0.972-0.392-1.368-0.044L6.339,44.249c-0.415,0.365-0.455,0.997-0.09,1.412C6.447,45.886,6.723,46,7,46z"/> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
								end if;
							end if;
							if ws_saida = 'S' or ws_saida = 'O' then
								fcl.gera_conteudo(ws_excel, ws_saida ,'<Cell> <Data ss:Type="String">'||fun.ptg_trans(fun.ifmascara(ws_content,rtrim(ret_mcol(ws_ccoluna).nm_mascara),prm_micro_visao, ret_mcol(ws_ccoluna).cd_coluna, prm_objid, '', ret_mcol(ws_ccoluna).formula, prm_screen))||'</Data></Cell>', '', '');
							end if;
						end if;
					else
						if ret_mcol(ws_ccoluna).st_agrupador = 'SEM' then
							if length(ws_repeat) = 4 then
								if ret_coltot = 1 and length(fun.getprop(prm_objid,'TOTAL_GERAL_TEXTO')) > 0  then
									if ws_saida <> 'O' then
										htp.p('<td class="inv"></td>');
									end if;
								else
									if ws_saida <> 'O' then
										if ret_coltot <> 1 then
											if ws_countv = 0 then
												htp.tableData(fcl.fpdata((ws_ctnull - ws_ctcol),0,'','')||fun.ifmascara(ws_content,rtrim(ret_mcol(ws_ccoluna).nm_mascara),prm_micro_visao, ret_mcol(ws_ccoluna).cd_coluna, prm_objid, '', ret_mcol(ws_ccoluna).formula, prm_screen), calign => '', cattributes => ''||ws_hint||' data-i="'||ws_counter||'" '||ws_idcol||fun.check_blink(prm_objid, ret_mcol(ws_ccoluna).cd_coluna, ws_content, '', prm_screen)||' '||ws_jump||'');
											end if;
											if nvl(ret_mcol(ws_ccoluna).url, 'N/A') <> 'N/A' then
												htp.p('<td onmouseleave="out_evento();" class="imgurl" data-url="'||replace(replace(replace(replace(replace(ret_mcol(ws_ccoluna).url,'"',''), '$[DOWNLOAD]', ''||ws_owner_bi||'.fcl.download?arquivo='), '$[SELF]', ws_cod_coluna), chr(39), ''), '|', '')||'" data-i="'||ws_counter||'" '||ws_idcol||fun.check_blink(prm_objid, ret_mcol(ws_ccoluna).cd_coluna, ws_content, '', prm_screen)||' '||ws_jump||' '||ws_pivot||'>');
												htp.p('<svg style="border-radius: 2px; padding: 0px 1px; background: #DEDEDE; width: 14px;" version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" 	 viewBox="0 0 58 58" style="enable-background:new 0 0 58 58;" xml:space="preserve"> <g> 	<path d="M57,6H1C0.448,6,0,6.447,0,7v44c0,0.553,0.448,1,1,1h56c0.552,0,1-0.447,1-1V7C58,6.447,57.552,6,57,6z M56,50H2V8h54V50z" 		/> 	<path d="M16,28.138c3.071,0,5.569-2.498,5.569-5.568C21.569,19.498,19.071,17,16,17s-5.569,2.498-5.569,5.569 		C10.431,25.64,12.929,28.138,16,28.138z M16,19c1.968,0,3.569,1.602,3.569,3.569S17.968,26.138,16,26.138s-3.569-1.601-3.569-3.568 		S14.032,19,16,19z"/> 	<path d="M7,46c0.234,0,0.47-0.082,0.66-0.249l16.313-14.362l10.302,10.301c0.391,0.391,1.023,0.391,1.414,0s0.391-1.023,0-1.414 		l-4.807-4.807l9.181-10.054l11.261,10.323c0.407,0.373,1.04,0.345,1.413-0.062c0.373-0.407,0.346-1.04-0.062-1.413l-12-11 		c-0.196-0.179-0.457-0.268-0.72-0.262c-0.265,0.012-0.515,0.129-0.694,0.325l-9.794,10.727l-4.743-4.743 		c-0.374-0.373-0.972-0.392-1.368-0.044L6.339,44.249c-0.415,0.365-0.455,0.997-0.09,1.412C6.447,45.886,6.723,46,7,46z"/> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
											end if;
										end if;
									end if;
									if ws_saida = 'S' or ws_saida = 'O' then
										fcl.gera_conteudo(ws_excel, ws_saida ,'<Cell> <Data ss:Type="String">'||fun.ptg_trans(fun.ifmascara(ws_content,rtrim(ret_mcol(ws_ccoluna).nm_mascara),prm_micro_visao, ret_mcol(ws_ccoluna).cd_coluna, prm_objid, '', ret_mcol(ws_ccoluna).formula, prm_screen))||'</Data></Cell>', '', '');
									end if;
								end if;
							end if;
						else
							if(ret_mcol(ws_ccoluna).st_agrupador in ('PSM','PCT') and ret_colgrp <> 0) or (ret_mcol(ws_ccoluna).st_gera_rel = 'N' and ret_colgrp <> 0) then
								ws_content := ' ';
							end if;
							if ret_colgrp <> 0 then
								if ws_total_ac = 'S' and ws_scol = 1 then
									if ws_counter+ws_ctnull > ws_limite_i+ws_ctcol and ws_counter < (ws_ncolumns.COUNT)-ws_limite_f then
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
								
								if ws_saida = 'S' or ws_saida = 'O' then
									fcl.gera_conteudo(ws_excel, ws_saida ,'<Cell> <Data ss:Type="String">'||fun.ptg_trans(fun.ifmascara(ws_content,rtrim(ret_mcol(ws_ccoluna).nm_mascara), prm_micro_visao, ret_mcol(ws_ccoluna).cd_coluna, prm_objid, '', ret_mcol(ws_ccoluna).formula, prm_screen))||'</Data></Cell>', '', '');
								end if;

								if length(fun.getprop(prm_objid,'CALCULADA')) > 0 then
									for i in(select column_value as valor from table(fun.vpipe((fun.getprop(prm_objid,'CALCULADA'))))) loop
										if instr(i.valor, '<') > 0 then
											if substr(i.valor, 0, instr(i.valor, '<')-1) = ret_mcol(ws_ccoluna).cd_coluna then
												htp.p('<td></td>');
											end if;
										end if;
									end loop;
								end if;

								if ws_saida <> 'O' then
									htp.tableData(fun.um(ret_mcol(ws_ccoluna).cd_coluna, prm_micro_visao, fun.ifmascara(ws_content,rtrim(ret_mcol(ws_ccoluna).nm_mascara), prm_micro_visao, ret_mcol(ws_ccoluna).cd_coluna, prm_objid, '', ret_mcol(ws_ccoluna).formula, prm_screen)), calign => '', cattributes => ''||ws_hint||' data-i="'||ws_counter||'" '||ws_idcol||fun.check_blink_total(prm_objid, ret_mcol(ws_ccoluna).cd_coluna, ws_content, '', prm_screen)||
									' '||ws_jump||' '||ws_pivot||' ' );
								end if;
								
								if(fun.ret_sinal(prm_objid,ret_mcol(ws_ccoluna).cd_coluna, ws_content) <> 'nodata') then
									htp.tableData(fun.ret_sinal(prm_objid,ret_mcol(ws_ccoluna).cd_coluna, ws_content), cattributes => 'style="width: 12px; padding: 0; text-align: center;"');
									if ws_saida = 'S' or ws_saida = 'O' then
										fcl.gera_conteudo(ws_excel, ws_saida ,'<Cell> <Data ss:Type="String"></Data></Cell>', '', '');
									end if;
								end if;

								if length(fun.getprop(prm_objid,'CALCULADA')) > 0 then
									for i in(select column_value as valor from table(fun.vpipe((fun.getprop(prm_objid,'CALCULADA'))))) loop
										if instr(i.valor, '>') > 0 then
											if substr(i.valor, 0, instr(i.valor, '>')-1) = ret_mcol(ws_ccoluna).cd_coluna then
												htp.p('<td></td>');
											end if;
										end if;
									end loop;
								end if;

							else
								if ws_saida = 'S' or ws_saida = 'O' then
									fcl.gera_conteudo(ws_excel, ws_saida ,'<Cell> <Data ss:Type="String">'||fun.ptg_trans(fun.ifmascara(ws_content,rtrim(ret_mcol(ws_ccoluna).nm_mascara), prm_micro_visao, ret_mcol(ws_ccoluna).cd_coluna, prm_objid, '', ret_mcol(ws_ccoluna).formula, prm_screen))||'</Data></Cell>', '', '');
								end if;
								
								begin
									if length(fun.getprop(prm_objid,'CALCULADA')) > 0 then
										for i in(select column_value as valor, rownum as linha from table(fun.vpipe((fun.getprop(prm_objid,'CALCULADA'))))) loop
											if instr(i.valor, '<') > 0 then
												if substr(i.valor, 0, instr(i.valor, '<')-1) = ret_mcol(ws_ccoluna).cd_coluna then
													ws_calculada := fun.xexec('EXEC='||substr(i.valor, instr(i.valor, '<')+1), prm_screen, ws_content, ws_conteudo_ant);
													
													select nvl(mascara, trim(ret_mcol(ws_ccoluna).nm_mascara)) into ws_calculada_m from(select column_value as mascara, rownum as linha from table(fun.vpipe((fun.getprop(prm_objid,'CALCULADA_M'))))) where linha = i.linha;
													htp.p('<td '||ws_jump||'>'||fun.ifmascara(ws_calculada, ws_calculada_m, prm_micro_visao, ret_mcol(ws_ccoluna).cd_coluna, prm_objid, '', ret_mcol(ws_ccoluna).formula, prm_screen)||'</td>');
												end if;
											end if;
										end loop;
									end if;
								exception when others then
									htp.p('<td '||ws_jump||' data-err="'||sqlerrm||'">err</td>');
								end;

								if ws_saida <> 'O' then
									htp.tableData(fun.um(ret_mcol(ws_ccoluna).cd_coluna, prm_micro_visao, fun.ifmascara(ws_content, rtrim(ret_mcol(ws_ccoluna).nm_mascara), prm_micro_visao, ret_mcol(ws_ccoluna).cd_coluna, prm_objid, '', ret_mcol(ws_ccoluna).formula, prm_screen)), calign => '', cattributes => ''||ws_hint||' data-i="'||ws_counter||'" '||ws_idcol||
									' '||ws_jump||' '||ws_pivot||' ' );

									begin
										if length(fun.getprop(prm_objid,'CALCULADA')) > 0 then
											for i in(select column_value as valor, rownum as linha from table(fun.vpipe((fun.getprop(prm_objid,'CALCULADA'))))) loop
												if instr(i.valor, '>') > 0 then
													if substr(i.valor, 0, instr(i.valor, '>')-1) = ret_mcol(ws_ccoluna).cd_coluna then
														ws_calculada := fun.xexec('EXEC='||substr(i.valor, instr(i.valor, '>')+1), prm_screen, ws_content, ws_conteudo_ant);

														select nvl(mascara, trim(ret_mcol(ws_ccoluna).nm_mascara)) into ws_calculada_m from(select column_value as mascara, rownum as linha from table(fun.vpipe((fun.getprop(prm_objid,'CALCULADA_M'))))) where linha = i.linha;
														htp.p('<td '||ws_jump||'>'||fun.ifmascara(ws_calculada, ws_calculada_m, prm_micro_visao, ret_mcol(ws_ccoluna).cd_coluna, prm_objid, '', ret_mcol(ws_ccoluna).formula, prm_screen)||'</td>');
													end if;
												end if;
											end loop;
										end if;
									exception when others then
										htp.p('<td '||ws_jump||' data-err="'||sqlerrm||'">err</td>');
									end;

								end if;
								
								if(fun.ret_sinal(prm_objid,ret_mcol(ws_ccoluna).cd_coluna, ws_content) <> 'nodata') then
									if ws_saida <> 'O' then
										htp.tableData(fun.ret_sinal(prm_objid,ret_mcol(ws_ccoluna).cd_coluna, ws_content), cattributes => ''||ws_hint||' '||'style="width: 12px; padding: 0; text-align: center;"');
									end if;
									if ws_saida = 'S' or ws_saida = 'O' then
										fcl.gera_conteudo(ws_excel, ws_saida ,'<Cell><Data ss:Type="String"></Data></Cell>', '', '');
									end if;
								end if;
								
							end if;
						end if;
					end if;
				end if;

				if length(fun.check_blink_linha(prm_objid, ret_mcol(ws_ccoluna).cd_coluna, ws_linha, ret_coluna, prm_screen)) > 7 and ret_colgrp = 0 then
				    ws_blink_linha := fun.check_blink_linha(prm_objid, ret_mcol(ws_ccoluna).cd_coluna, ws_linha, ret_coluna, prm_screen);
				end if;

				if length(ws_repeat) = 4 then
				    ws_count := ws_count+1;
					ws_array_atual(ws_count) := ret_coluna;
					ws_class_atual(ws_count) := ws_jump;
				end if;

				ws_jump := '';
				ws_check := '';

				ws_coluna_ant(ws_counter) := ret_coluna;
				ws_arr_anterior(ws_counter) := ret_coluna;

		        ws_conteudo_ant := ws_content;

	    	end loop;

			if ws_saida <> 'O' then
			    if ws_blink_linha <> 'N/A' then htp.p(ws_blink_linha); end if;
			end if;

		    ws_blink_linha := 'N/A';

		    ws_firstid := 'N';
		    if ws_saida = 'S' or ws_saida = 'O' then
	            fcl.gera_conteudo(ws_excel, ws_saida, '</Row>', '', '');
	        end if;
		    htp.p('</tr>');

		
		ws_ac_linha := 0;
		ws_total_linha := 0;
		ws_count := 0;
		
	end loop;

	ws_total_linha := 0;
	ws_ac_linha := 0;
	dbms_sql.close_cursor(ws_cursor);

	if ws_saida <> 'O' then
		if fun.getprop(prm_objid,'TOTAL_SEPARADO') = 'S' then
			ws_blink_linha := 'N/A';
			htp.p('<tr class="total duplicado" data-i="0">');
				htp.p('<td colspan="'||dimensao_soma||'" style="text-align: right;">'||fun.getprop(prm_objid,'TOTAL_SEPARADO_TEXTO')||'</td>');
				for i in dimensao_soma..ws_array_atual.count loop
					 begin
						 ws_array_atual(i) := to_number(nvl(trim(ws_array_atual(i-1)), 0))+to_number(nvl(trim(ws_array_atual(i)), 0));
						 htp.p('<td '||ws_class_atual(i)||' '||fun.check_blink_total(prm_objid, ret_mcol(ws_ccoluna).cd_coluna, ws_array_atual(i), '', prm_screen)||'>'||fun.ifmascara(ws_arr_atual(i),rtrim(ret_mcol(ws_ccoluna).nm_mascara), prm_micro_visao, ret_mcol(ws_ccoluna).cd_coluna, prm_objid, '', ret_mcol(ws_ccoluna).formula, prm_screen)||'</td>');

						 if length(fun.check_blink_linha(prm_objid, ret_mcol(ws_ccoluna).cd_coluna, ws_linha+1, ret_coluna, prm_screen)) > 7 then
							 ws_blink_linha := fun.check_blink_linha(prm_objid, ret_mcol(ws_ccoluna).cd_coluna, ws_linha+1, ret_coluna, prm_screen);
						 end if;
						 if ws_blink_linha <> 'N/A' then htp.p(ws_blink_linha); end if;
						 ws_blink_linha := 'N/A';
					 exception when others then
						 htp.p('<td></td>');
					 end;
				end loop;
			htp.p('</tr>');
		end if;
	end if;

end consulta_dados;

end UpQuery;
