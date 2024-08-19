create or replace package body ETL  is

g_separador_comando varchar2(10) := '|';

-------------------------------------------------------------------------------------------------------
function ret_comando_param ( prm_comando  varchar2, 
                             prm_parte    number   ) return varchar2 as  
	ws_count integer := 0; 
	ws_counteudo varchar2(4000); 
begin 
	for a in (select * from table(fun.vpipe2(prm_comando,g_separador_comando))) loop  -- usado vpipe2 que aceita até 4000 caracteres, o vpipe atual aceita somente 500
		ws_count := ws_count + 1;	
		if ws_count = prm_parte then 
			return a.column_value;
		end if; 
	end loop; 	 
	return '';
end ret_comando_param;

-------------------------------------------------------------------------------------------------------

function ret_conexao_param ( prm_id_conexao     varchar2, 
                             prm_step_id        varchar2, 
                             prm_cd_parametro   varchar2) return varchar2 as  
	ws_conteudo       varchar2(4000); 
	ws_id_conexao     varchar2(200); 
	ws_erro           varchar2(300); 
	ws_raise_erro     exception; 
begin 
	ws_id_conexao := null;
	if prm_id_conexao is not null then 
		ws_id_conexao := prm_id_conexao;
	else 
		select max(id_conexao) into ws_id_conexao 
		  from etl_step 
		 where step_id = prm_step_id; 
	end if; 
	if ws_id_conexao is null then 
		ws_erro := 'Nao identificado o ID_CONEXAO para busca do parametro'; 
		raise ws_raise_erro; 
	end if; 	

	select max(conteudo) into ws_conteudo  
     from etl_conexoes
    where id_conexao   = ws_id_conexao 
	  and cd_parametro = prm_cd_parametro;
  
	return ws_conteudo;
exception when ws_raise_erro then 
	Raise_Application_Error (-20101, 'Erro ret_conexao_param: '||ws_erro);		
end ret_conexao_param;


-------------------------------------------------------------------------------------------------------
function prn_a_status  (prm_status varchar2) return varchar2 is 
	ws_cor     varchar2(10);
	ws_classe  varchar2(20);
	ws_hint    varchar2(200);
	ws_status  varchar2(200);
begin 
	ws_classe := '';
	if    prm_status = 'AGUARDANDO' then  	ws_cor := '#F6C21A';   ws_hint := 'Aguardando o inicio da execu&ccedil;&atilde;o pelo Integrador.';
	elsif prm_status = 'EXECUTANDO' then   	ws_cor := '#F6C21A';   ws_hint := 'Sendo executado pelo Integrador.';         ws_classe := 'executando' ; 
	elsif prm_status = 'CONCLUIDO'  then 	ws_cor := '#3C8846';   ws_hint := 'Conclu&iacute;do com sucesso.';
	elsif prm_status = 'ERRO'       then 	ws_cor := '#F2142B';   ws_hint := 'Erro durante a execu&ccedil;&atilde;o.';
	elsif prm_status = 'CANCELADO'  then 	ws_cor := '#F2142B';   ws_hint := 'Cancelado.';
	elsif prm_status = 'ALERTA'     then 	ws_cor := '#F6C21A';   ws_hint := 'Conclu&iacute;do com alerta para poss&iacute;vel erro no retorno obtido pelo Integrador.';
	end if; 
	ws_status := prm_status;
	if prm_status = 'ALERTA' then 
		ws_status := 'CONCLUIDO';
	end if;
	return '<a class="'||ws_classe||'" style="background: '||ws_cor||' !important;" title="'||ws_hint||'" >'||ws_status||'</a>'; 
end;  






----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_fix ( prm_cod  varchar2 default null,
                    prm_tipo varchar2 default 'run' ) as
	ws_cod varchar2(40);
begin
    if prm_tipo = 'RUN' then
        update etl_run set last_status = 'CONCLUIDO' where run_id = prm_cod;
	    commit;
	else
        update etl_step set last_status = 'CONCLUIDO' where step_id = prm_cod;
	    commit;
		select run_id into ws_cod from etl_step where step_id = prm_cod;
		update etl_run set last_status = 'CONCLUIDO' where run_id = ws_cod;
	    commit;
	end if;
	htp.p('OK|Registro atualizado');
exception 
	when others then 	
		htp.p('ERRO|Erro atualizando situa&ccedil;&atilde;o da tarefa');
    	insert into bi_log_sistema values(sysdate, 'etl_fix (others) :'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getusuario, 'ERRO');
		commit;
end etl_fix;



----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure menu_etl (prm_menu      varchar2, 
		            prm_tipo      varchar2 default null,
					prm_id_copia  varchar2 default null) as 
	ws_step    etl_step%rowtype; 
	ws_onkeypress      varchar2(500); 
	ws_onkeypress_int  varchar2(500); 
	ws_onkeypress_cod  varchar2(500); 
	ws_onkeypress_num  varchar2(500); 
	ws_onkeypress_pipe varchar2(500); 
	ws_param           varchar2(4000); 
	ws_title           varchar2(300); 
	ws_tipo_comando    varchar2(200);

begin 

	ws_onkeypress      := ' onkeypress="proxCampo(event,this);"'; 
	ws_onkeypress_int  := ' onkeypress="if(!input(event, ''integer'')) {event.preventDefault();} else {proxCampo(event,this);}"'; 
	ws_onkeypress_cod  := ' onkeypress="if(!input(event, ''ID''))      {event.preventDefault();} else {proxCampo(event,this);}"'; 		
	ws_onkeypress_pipe := ' onkeypress="if(!input(event, ''nopipe''))      {event.preventDefault();} else {proxCampo(event,this);}"'; 		

	case 
	when prm_menu = 'etl_conexoes' then 	

		htp.p('<h4>'||fun.lang('CONEX&Otilde;ES')||'</h4>');

		htp.p('<span class="script" onclick="call(''menu_etl'', ''prm_menu=etl_conexoes&prm_tipo=''+this.nextElementSibling.title, ''etl'').then(function(resposta){ '||
		       ' if(resposta.indexOf(''ERRO|'') == -1){ alerta(''feed-fixo'', resposta.split(''|'')[1]); } else { document.getElementById(''painel'').innerHTML = resposta; }  });"></span>');
		fcl.fakeoption('prm_db', fun.lang('TIPO CONEX&Atilde;O'), prm_tipo, 'lista-etl-db', 'N', 'N', null);

		if prm_tipo is not null then 
			ws_param := 'prm_id_conexao|prm_db'; 
			htp.p('<input type="text" id="prm_id_conexao" title="Informe um c&oacute;digo indentificador para a conex&atilde;o"  data-min="1"  placeholder="ID CONEX&Atilde;O" data-encode="S" class="up" '||ws_onkeypress||'/>');
			for a in (select cd_parametro, nm_parametro from etl_tipo_conexao where tp_conexao = prm_tipo and tp_parametro = 'CONEXAO' order by ordem_tela) loop 
				htp.p('<input type="text" id="prm_'||a.cd_parametro||'" data-min="1" placeholder="'||upper(a.nm_parametro)||'" data-encode="S" '||ws_onkeypress||'/>');
				ws_param := ws_param||'|prm_'||a.cd_parametro; 
			end loop;

			htp.p('<a class="addpurple followed" title="'||fun.lang('Adicionar conex&atilde;o')||'" data-sup="etl_conexoes" '||  
		           'data-req="etl_conexoes_insert" data-par-agrupa="S" data-par="'||ws_param||'" '||
				   'data-res="etl_conexoes_list" data-msg="'||fun.lang('Adicionado com sucesso')||'" data-pkg="etl">'||fun.lang('ADICIONAR')||'</a>');
		end if; 
	when prm_menu = 'etl_step' then

		htp.p('<h4>'||fun.lang('A&Ccedil;&Otilde;ES / COMANDOS')||'</h4>');

		htp.p('<span class="script" onclick="call(''menu_etl'', ''prm_menu=etl_step&prm_tipo=''+this.nextElementSibling.title, ''etl'').then(function(resposta){ '||
		      ' if(resposta.indexOf(''ERRO|'') == -1){ alerta(''feed-fixo'', resposta.split(''|'')[1]); } else { document.getElementById(''painel'').innerHTML = resposta; }  });"></span>');
		fcl.fakeoption('prm_tipo_execucao', fun.lang('TIPO EXECU&Ccedil;&Atilde;O'), prm_tipo, 'lista-etl-tipo-execucao', 'N', 'N', null);				

		if prm_tipo is not null then 
			
			ws_step := null;
			if prm_id_copia is not null then 
				select * into ws_step from etl_step where step_id = prm_id_copia;  
			end if; 
			htp.p('<input type="hidden" id="prm_id_copia"   value="'||prm_id_copia||'">');	

			if prm_tipo <> 'PL/SQL' then
				if prm_id_copia is null then 
					fcl.fakeoption('prm_id_conexao', fun.lang('Conex&atilde;o'), null, 'lista-etl-conexao', 'N', 'N', null);
				else 
					htp.p('<input type="hidden"   id="prm_id_conexao"     values="'||ws_step.id_conexao||'">');	 
				end if; 	
			else 	
				htp.p('<input type="hidden"   id="prm_id_conexao"     values="">');	
			end if; 
			
			ws_tipo_comando := null;
			if prm_id_copia is not null then 
				ws_tipo_comando := ws_step.tipo_comando;
			end if; 

			htp.p('<span class="script" onclick="let vid = ''''; if (document.getElementById(''prm_tipo_comando'').title==''FULL''){vid=''ETL_TAUX_'';}else{vid=''ETL_V_'';}; document.getElementById(''prm_step_id'').value=vid; document.getElementById(''prm_tbl_destino'').value=vid; "></span>');
			fcl.fakeoption('prm_tipo_comando', fun.lang('TIPO COMANDO'), ws_tipo_comando, 'lista-etl-tipo-comando', 'N', 'N', null);				

			htp.p('<input type="text"   id="prm_step_id"   data-min="1" data-encode="N" placeholder="'||fun.lang('ID')||'" class="up" '||ws_onkeypress_cod||
			      'onchange="document.getElementById(''prm_tbl_destino'').value = document.getElementById(''prm_step_id'').value"  value="'||ws_step.step_id||'" />');
			if prm_tipo <> 'PL/SQL' then
				htp.p('<input type="text"   id="prm_tbl_destino"    data-min="1" data-encode="S" placeholder="'||fun.lang('TABELA DE DESTINO') ||'" '||ws_onkeypress_cod||' value="'||ws_step.tbl_destino||'">');	
			else 	
				htp.p('<input type="hidden"   id="prm_tbl_destino"    values="">');	
			end if; 

			htp.p('<a class="addpurple followed" title="'||fun.lang('Adicionar A&ccedil;&atilde;o')||'" data-sup="etl_step"'||  
	        	   'data-req="etl_step_insert" data-par="prm_step_id|prm_tipo_execucao|prm_tipo_comando|prm_id_conexao|prm_tbl_destino|prm_id_copia" '||
			   	   'data-res="etl_step_list" data-msg="'||fun.lang('Adicionado com sucesso')||'" data-pkg="etl">'||fun.lang('ADICIONAR')||'</a>');
		end if; 
	when prm_menu = 'etl_run' then 	

		htp.p('<h4>'||fun.lang('TAREFAS')||'</h4>');
		htp.p('<input type="hidden" id="painel-atributos" data-refresh="etl_run_list" data-refresh-ativo="S" data-pkg="etl">');

		htp.p('<input type="text"   id="prm_ds_run"   data-min="1" data-encode="S" placeholder="'||fun.lang('DESCRI&Ccedil&Atilde;O TAREFA')||'" '||ws_onkeypress_pipe||'/>');

		htp.p('<a class="addpurple followed" title="'||fun.lang('Adicionar Tarefa')||'" data-sup="etl_run"'||  
	           'data-req="etl_run_insert" data-par="prm_ds_run" '||
			   'data-res="etl_run_list" data-msg="'||fun.lang('Adicionado com sucesso')||'" data-pkg="etl">'||fun.lang('ADICIONAR')||'</a>');
	
	when prm_menu = 'etl_schedule' then 	
		htp.p('<h4>'||fun.lang('HOR&Aacute;RIO AGENDAMENTO')||'</h4>');
		htp.p('<input type="hidden" id="painel-atributos" data-refresh="" data-pkg="" >');

		fcl.fakeoption('prm_p_semana', fun.lang('Dias/semana'), '', 'lista-semanas', 'N', 'S', prm_min => 1);
		fcl.fakeoption('prm_p_dia_mes', fun.lang('Dias do m&ecirc;s'), '', 'lista-dia-mes', 'N', 'S', prm_min=>1); 
        fcl.fakeoption('prm_p_mes', fun.lang('Meses'), '', 'lista-meses', 'N', 'S', prm_min => 1);
		fcl.fakeoption('prm_p_hora', fun.lang('Hora'), '', 'lista-horas', 'N', 'S', prm_min => 1);
		fcl.fakeoption('prm_p_quarter', fun.lang('Minuto'), '', 'lista-minutos', 'N', 'S', prm_min => 1);		

		htp.p('<a class="addpurple followed" title="'||fun.lang('Adicionar agendamento')||'" data-sup="etl_schedule"'||  
	           'data-req="etl_schedule_insert" data-par="prm_run_id|prm_p_semana|prm_p_mes|prm_p_hora|prm_p_quarter|prm_p_dia_mes" '||
			   'data-res="etl_schedule_list" data-res-par="prm_run_id" data-msg="'||fun.lang('Adicionado com sucesso')||'" data-pkg="etl">'||fun.lang('ADICIONAR')||'</a>');
	when prm_menu = 'etl_run_step' then 	

		htp.p('<h4>'||fun.lang('TAREFAS / A&Ccedil;&Otilde;ES')||'</h4>');
		htp.p('<input type="hidden" id="painel-atributos" data-refresh="etl_run_step_list" data-refresh-ativo="N" data-pkg="etl" >');

		htp.p('<input type="text" id="prm_ordem" data-min="1" data-encode="N" placeholder="'||fun.lang('ORDEM EXECU&Ccedil;&Atilde;O') ||'" '||ws_onkeypress_int||' style="display:block;" >');
		fcl.fakeoption('prm_step_id', fun.lang('A&ccedil;&atilde;o'), null, 'lista-etl-step', 'N', 'N', null);				

		htp.p('<a class="addpurple followed" title="'||fun.lang('Adicionar a&ccedil;&atilde;o na tarefa')||'" data-sup="etl_run_step"'||  
	           'data-req="etl_run_step_insert" data-par="prm_run_id|prm_ordem|prm_step_id" '||
			   'data-res="etl_run_step_list" data-res-par="prm_run_id" data-msg="'||fun.lang('Adicionado com sucesso')||'" data-pkg="etl">'||fun.lang('ADICIONAR')||'</a>');

	when prm_menu = 'etl_step_param' then 	

		htp.p('<h4>'||fun.lang('PAR&Acirc;METROS EXECU&Ccedil;&Atilde;O')||'</h4>');
		htp.p('<input type="hidden" id="painel-atributos" data-refresh="" data-pkg="etl" >');

		htp.p('<input type="text"   id="prm_cd_parametro" data-min="1" data-encode="N" placeholder="'||fun.lang('NOME/ID')||'" class="up" '||ws_onkeypress_cod||'/>');
		htp.p('<input type="text"   id="prm_ds_parametro" data-min="1" data-encode="S" placeholder="'||fun.lang('DESCRI&Ccedil;&Atilde;O') ||'" '||ws_onkeypress||'>');
		
		htp.p('<a class="addpurple followed" title="'||fun.lang('Adicionar a&ccedil;&atilde;o na tarefa')||'" data-sup="etl_step_param"'||  
	           'data-req="etl_step_param_insert" data-par="prm_step_id|prm_cd_parametro|prm_ds_parametro" '||
			   'data-res="etl_step_param_list" data-res-par="prm_step_id" data-msg="'||fun.lang('Adicionado com sucesso')||'" data-pkg="etl">'||fun.lang('ADICIONAR')||'</a>');

	end case; 

exception when others then 
   	insert into bi_log_sistema values(sysdate, 'menu_etl (others) :'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getusuario, 'ERRO');
	commit;
	htp.p('ERRO|Erro montando tela, verifique o log de erros do sistema'); 
end menu_etl; 



----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_conexoes_list as 

	ws_host         varchar2(4000); 
	ws_porta        varchar2(4000); 
	ws_db           varchar2(4000); 
	ws_database     varchar2(4000); 
	ws_usuario      varchar2(4000); 
	ws_senha        varchar2(4000); 
	ws_conteudo     varchar2(4000); 	
	ws_svg_database varchar2(2000); 
begin 

	htp.p('<input type="hidden" id="content-atributos" data-refresh="etl_conexoes_list" data-pkg="etl" >');

	ws_svg_database := fun.ret_svg('database_conect'); 
	for a in (select distinct conteudo as db from etl_conexoes where cd_parametro = 'DB' and conteudo is not null order by 1) loop 
		--htp.p('<h2>'||a.db||'</h2>');
		htp.p('<table class="linha">');
			htp.p('<thead>');
				htp.p('<tr>');
					htp.p('<th>TIPO CONEX&Atilde;O</th>');
					htp.p('<th>ID CONEX&Atilde;O</th>');
					for b in (select nm_parametro from etl_tipo_conexao where tp_conexao = a.db and tp_parametro = 'CONEXAO' order by ordem_tela) loop 
						htp.p('<th>'||fun.lang(b.nm_parametro)||'</th>');								
					end loop;
					htp.p('<th></th>');
					htp.p('<th></th>');
					htp.p('<th></th>');
				htp.p('</tr>');
			htp.p('</thead>');
			
			htp.p('<tbody id="ajax" >');
				for con in (select distinct id_conexao FROM etl_conexoes where cd_parametro = 'DB' and conteudo = a.db order by 1) loop 	
					htp.p('<tr id="'||con.id_conexao||'">');
						htp.p('<td><div>'||a.db||'</div></td>');
						htp.p('<td><div>'||con.id_conexao||'</div></td>');
						for campo in (select cd_parametro from etl_tipo_conexao where tp_conexao = a.db and tp_parametro = 'CONEXAO' order by ordem_tela) loop 
							select max(conteudo) into ws_conteudo from etl_conexoes where id_conexao = con.id_conexao and cd_parametro = campo.cd_parametro ;
							ws_conteudo := replace(ws_conteudo,'"', '&#34;');
							htp.p('<td><input id="prm_'||lower(campo.cd_parametro)||'_'||con.id_conexao||'" type="text" data-min="1" data-default="'||ws_conteudo||'" value="'||ws_conteudo||'" '||
							       'onblur=" if (this.value !== this.getAttribute(''data-default'')) { call(''etl_conexoes_update'', ''prm_id_conexao='||con.id_conexao||'&prm_cd_parametro='||upper(campo.cd_parametro)||'&prm_conteudo=''+this.value,''ETL'').then(function(resposta){alerta(''feed-fixo'',resposta.split(''|'')[1]); });}" /></td>');
						end loop;
						
						if a.db in ('ODBC', 'FIREBIRD', 'POSTGRESQL', 'MYSQL', 'MSSQL', 'ORACLE', 'AWS', 'CACHE') then 
							
							htp.p('<td class="etl_testar_conexao">');
								htp.p('<a class="addpurple" title="Testar conex&atilde;o" onclick="etl_conexoes_teste(this,'''||con.id_conexao||''');">'||fun.lang('TESTAR')||'</a>');
							htp.p('</td>');

							htp.p('<td class="etl_atalho" title="Log de execu&ccedil;&atilde;o da a&ccedil;&atilde;o" '||
							      ' onclick="carregaTelasup(''etl_fila_list'', ''prm_tp=TESTE_CONEXAO&prm_id='||con.id_conexao||''', ''ETL'', ''none'','''','''',''etl_conexoes_list||ETL|etl_conexoes|||'');">');
								htp.p('<svg viewBox="0 0 600 600" xml:space="preserve"><g><path d="M486.201,196.124h-13.166V132.59c0-0.396-0.062-0.795-0.115-1.196c-0.021-2.523-0.825-5-2.552-6.963L364.657,3.677 c-0.033-0.031-0.064-0.042-0.085-0.073c-0.63-0.707-1.364-1.292-2.143-1.795c-0.229-0.157-0.461-0.286-0.702-0.421 c-0.672-0.366-1.387-0.671-2.121-0.892c-0.2-0.055-0.379-0.136-0.577-0.188C358.23,0.118,357.401,0,356.562,0H96.757 C84.894,0,75.256,9.651,75.256,21.502v174.613H62.092c-16.971,0-30.732,13.756-30.732,30.733v159.812 c0,16.968,13.761,30.731,30.732,30.731h13.164V526.79c0,11.854,9.638,21.501,21.501,21.501h354.776 c11.853,0,21.501-9.647,21.501-21.501V417.392h13.166c16.966,0,30.729-13.764,30.729-30.731V226.854 C516.93,209.872,503.167,196.124,486.201,196.124z M96.757,21.502h249.054v110.009c0,5.939,4.817,10.75,10.751,10.75h94.972v53.861 H96.757V21.502z M317.816,303.427c0,47.77-28.973,76.746-71.558,76.746c-43.234,0-68.531-32.641-68.531-74.152 c0-43.679,27.887-76.319,70.906-76.319C293.389,229.702,317.816,263.213,317.816,303.427z M82.153,377.79V232.085h33.073v118.039 h57.944v27.66H82.153V377.79z M451.534,520.962H96.757v-103.57h354.776V520.962z M461.176,371.092 c-10.162,3.454-29.402,8.209-48.641,8.209c-26.589,0-45.833-6.698-59.24-19.664c-13.396-12.535-20.75-31.568-20.529-52.967 c0.214-48.436,35.448-76.108,83.229-76.108c18.814,0,33.292,3.688,40.431,7.139l-6.92,26.37 c-7.999-3.457-17.942-6.268-33.942-6.268c-27.449,0-48.209,15.567-48.209,47.134c0,30.049,18.807,47.771,45.831,47.771 c7.564,0,13.623-0.852,16.21-2.152v-30.488h-22.478v-25.723h54.258V371.092L461.176,371.092z"></path><path d="M212.533,305.37c0,28.535,13.407,48.64,35.452,48.64c22.268,0,35.021-21.186,35.021-49.5 c0-26.153-12.539-48.655-35.237-48.655C225.504,255.854,212.533,277.047,212.533,305.37z"></path></g></svg>');
							htp.p('</td>');

						else 
							htp.p('<td style="width :0px; border-right: 0px;"></td>');
							htp.p('<td style="width :0px; border-right: 0px;"></td>');
						end if;

						htp.p('<td  class="etl_atalho">');
							fcl.button_lixo('etl_conexoes_delete','prm_id_conexao', con.id_conexao, prm_tag => 'a', prm_pkg => 'ETL');
						htp.p('</td>');
					htp.p('</tr>');						
				end loop; 	
			
			htp.p('</tbody>');
		htp.p('</table>');	
	end loop; 


end etl_conexoes_list; 


procedure etl_conexoes_valida (prm_acao           varchar2, 
						 	   prm_campo          varchar2, 
                               prm_conteudo       varchar2,
							   prm_retorno    out varchar2 ) as 
	ws_count integer; 							  	
begin 
	prm_retorno := null;
	if prm_campo in ('ID_CONEXAO','DB', 'HOST','DATABASE','USUARIO','SENHA') then  
		if instr(prm_conteudo,' ') <> 0 then 
			prm_retorno := '['||prm_campo||'] n&atilde;o pode conter espa&ccedil;os em branco'; 
		end if; 	
	end if; 

	if prm_conteudo is null and prm_campo in ('ID_CONEXAO','DB', 'HOST','DATABASE','USUARIO','SENHA') then  
		prm_retorno := '['||prm_campo||'] deve ser preenchido'; 
	end if; 

	if prm_campo = 'HOST' then  
		if instr(prm_conteudo,',') <> 0 then 
			prm_retorno := '['||prm_campo||'] n&atilde;o pode conter VIRGULA'; 
		end if; 	
	end if; 

	if prm_acao = 'I' and prm_campo = 'ID_CONEXAO'  then  
		select count(*) into ws_count from etl_conexoes 
		 where id_conexao = prm_conteudo; 
		if ws_count > 0 then 
			prm_retorno := 'J&aacute; existe uma conex&atilde;o cadastrada com esse ID'; 
		end if; 	
	end if; 
end etl_conexoes_valida;  							   



----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_conexoes_insert ( prm_parametros    varchar2, 
							    prm_conteudos     varchar2 ) as 
	type ws_tp_conteudos is table of varchar2(200) index by pls_integer;
	ws_conteudos		ws_tp_conteudos ;

	ws_idx        integer; 
	ws_conteudo   varchar2(4000); 
	ws_id_conexao varchar2(200); 

	ws_erro     varchar2(300); 
	raise_erro  exception;
begin 

	-- Grava todos os conteudos em um array 
	ws_idx := 0 ;
	for a in (select column_value conteudo from table(fun.vpipe(prm_conteudos))) loop 
		ws_idx := ws_idx + 1; 
		ws_conteudos(ws_idx) := a.conteudo; 
	end loop; 
	
	-- Passa por todos os parametros, pega o conteúdo e grava na tabela 
	ws_idx        := 0; 
	for a in (select upper(column_value) cd_parametro from table(fun.vpipe(prm_parametros)) where column_value is not null ) loop 
		ws_idx      := ws_idx + 1; 
		ws_conteudo := ws_conteudos(ws_idx); 
		
		if ws_idx = 1 then 
			ws_id_conexao := null; 
			if a.cd_parametro = 'ID_CONEXAO' then 
				ws_id_conexao := upper(ws_conteudo);
				ws_conteudo   := upper(ws_conteudo);  
			end if; 	
			-- Valida o ID da conexão 
			etl_conexoes_valida ('I', 'ID_CONEXAO', ws_id_conexao, ws_erro);  
			if ws_erro is not null then 
				raise raise_erro; 
			end if; 
		end if; 

		etl_conexoes_valida ('I', a.cd_parametro, ws_conteudo, ws_erro); 
		if ws_erro is not null then 
			raise raise_erro; 
		end if; 

		begin 
			insert into etl_conexoes (id_conexao, cd_parametro, conteudo) values (ws_id_conexao, a.cd_parametro, ws_conteudo);
		exception when others then 
				rollback; 
    			insert into bi_log_sistema values(sysdate, 'etl_conexoes_insert (insert) :'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getusuario, 'ERRO');
				commit;
				ws_erro	:= 'Erro inserindo parametro ['||a.cd_parametro||'], verique o log de erros do sistema';
				raise raise_erro; 
		end; 
	end loop; 
	--
	commit; 
	--
	htp.p('OK|Registro atualizado');
exception 
	when raise_erro then 
		rollback; 
		htp.p('ERRO|'||ws_erro);
	when others then 	
		rollback; 
		ws_erro	:= 'Erro inserindo registro, verique o log de erros do sistema';
		htp.p('ERRO|'||ws_erro);
    	insert into bi_log_sistema values(sysdate, 'etl_conexoes_update (others) :'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getusuario, 'ERRO');
		commit;
end etl_conexoes_insert; 


----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_conexoes_update ( prm_id_conexao    varchar2, 
                                prm_cd_parametro  varchar2,
							    prm_conteudo      varchar2 ) as 
	raise_erro  exception; 							   
	ws_erro     varchar2(300); 
begin 

	etl_conexoes_valida ('U',prm_cd_parametro, prm_conteudo, ws_erro); if ws_erro is not null then raise raise_erro; end if; 

	update etl_conexoes 
	   set conteudo = prm_conteudo 
	 where id_conexao   = prm_id_conexao 
	   and cd_parametro = prm_cd_parametro;
	if sql%notfound then    
		insert into etl_conexoes (id_conexao, cd_parametro, conteudo) values (prm_id_conexao, prm_cd_parametro, prm_conteudo); 
	end if;        
	commit; 
	htp.p('OK|Registro atualizado');
exception 
	when raise_erro then 
		htp.p('ERRO|'||ws_erro);
	when others then 	
		ws_erro	:= 'Erro alterando registro, verifique o log de erros do sistema.';
		htp.p('ERRO|'||ws_erro);
    	insert into bi_log_sistema values(sysdate, 'etl_conexoes_update (others) :'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getusuario, 'ERRO');
		commit;
end etl_conexoes_update; 




----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_conexoes_delete ( prm_id_conexao    varchar2 ) as 
	ws_count    integer; 
	ws_erro     varchar2(300); 
	raise_erro  exception; 							   
begin 

	select count(*) into ws_count 
	  from etl_step 
	 where id_conexao = prm_id_conexao; 
	if ws_count > 0 then 
		ws_erro := 'Existem A&ccedil;&otilde;es com essa conex&atilde;o, exclua essas A&ccedil;&otilde;es para liberar a exclus&atilde;o dessa conex&atilde;o'; 
		raise raise_erro; 
	end if; 

	delete etl_conexoes where id_conexao = prm_id_conexao;  
	commit;  

	htp.p('OK|Registro exclu&iacute;do');

exception 
	when raise_erro then 
		htp.p('ERRO|'||ws_erro);
	when others then 	
		ws_erro	:= 'Erro excluindo registro, verifique o log de erros do sistema.';
		htp.p('ERRO|'||ws_erro);
    	insert into bi_log_sistema values(sysdate, 'etl_conexoes_delete (others) :'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getusuario, 'ERRO');
		commit;
end etl_conexoes_delete; 


procedure etl_conexoes_teste(prm_id_conexao   in varchar2 ) as 
    ws_retorno clob; 
    ws_status  varchar2(100); 
	ws_count   integer ;
begin
	select count(*) into ws_count from etl_fila where RUN_ID = 'TESTE_CONEXAO' and run_step_id = 'TESTE_CONEXAO' and status in ('A','R'); 
	if ws_count > 0 then
		ws_retorno := 'ERRO|J&aacute; existe um teste de conex&atilde;o sendo executado';
	else
    	etf.exec_step_integrador('TESTE_CONEXAO', prm_step_id => prm_id_conexao, prm_retorno => ws_retorno, prm_status => ws_status );
		if ws_status = 'CONCLUIDO' then
			ws_retorno := 'Teste realizado com sucesso';
		else
			ws_retorno := 'Erro na conex&atilde;o, entre nos logs para verificar o erro';
		end if;
		ws_retorno := ws_status||'|'||ws_retorno;
	end if; 	
	htp.p(ws_retorno); 
exception when others then
	ws_retorno := 'ERRO|Erro executando teste, verifique o log de erros do sistema';
	htp.p(ws_retorno);	
	insert into bi_log_sistema values(sysdate, 'etl_conexoes_teste (others) :'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getusuario, 'ERRO');
	commit; 
end etl_conexoes_teste; 



----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_step_list (prm_step_id  varchar2 default null,
						 prm_order    varchar2 default '1',
						 prm_dir      varchar2 default '1') as 
	cursor c1 is 
		select * from etl_step 
		 where step_id = nvl(prm_step_id, step_id)
		  order by case when prm_dir = '1' then decode(prm_order, '1', step_id, '2', tipo_execucao, '3', tipo_comando, '4', comando, '5', comando_limpar, '6', id_conexao, '7', tbl_destino, step_id) end asc,
		           case when prm_dir = '2' then decode(prm_order, '1', step_id, '2', tipo_execucao, '3', tipo_comando, '4', comando, '5', comando_limpar, '6', id_conexao, '7', tbl_destino, step_id) end desc; 

	ws_onkeypress      varchar2(300); 
	ws_onkeypress_int  varchar2(300); 
	ws_eventoGravar    varchar2(2000); 
	ws_evento          varchar2(2000); 
	ws_desc            varchar2(100); 
	ws_dir             number := 1;
	ws_comando         clob;
	ws_comando_l       clob; 

begin 
	ws_onkeypress     := ' onkeypress="proxCampo(event,this);"'; 
	ws_onkeypress_int := ' onkeypress="if(!input(event, ''integer'')) {event.preventDefault();} "';
	ws_eventoGravar   := ' "requestDefault(''etl_step_update'', ''prm_step_id=#ID#&prm_cd_parametro=#CAMPO#&prm_conteudo=''+#VALOR#,this,#VALOR#,'''',''ETL'');"'; 

	htp.p('<input type="hidden" id="content-atributos" data-pkg="etl" data-par-col="prm_step_id" data-par-val="'||prm_step_id||'" >');
	htp.p('<input type="hidden" id="prm_step_id" value="'||prm_step_id||'">');	

	htp.p('<table class="linha">');
		htp.p('<thead>');
			htp.p('<tr>');
				htp.p('<th title="ID da a&ccedil;&atilde;o">');  
					htp.p('<a class="red" onclick="var dir = order('''', ''ajax''); ajax(''list'', ''etl_step_list'', ''prm_order=1&prm_dir=''+dir, false, ''content'','''','''',''ETL'');">'||fun.lang('ID A&Ccedil;&Atilde;O')||'</a>');
				htp.p('</th>');
				htp.p('<th title="Tipo execu&ccedil;&atilde;o da a&ccedil;&atilde;o" style="width:40px;">');
					htp.p('<a class="red" onclick="var dir = order('''', ''ajax''); ajax(''list'', ''etl_step_list'', ''prm_order=2&prm_dir=''+dir, false, ''content'','''','''',''ETL'');">'||fun.lang('TP EXEC')||'</a>');
				htp.p('</th>');
				htp.p('<th title="Tipo de comando" style="width:40px;">');
					htp.p('<a class="red" onclick="var dir = order('''', ''ajax''); ajax(''list'', ''etl_step_list'', ''prm_order=3&prm_dir=''+dir, false, ''content'','''','''',''ETL'');">'||fun.lang('TP COM')||'</a>');
				htp.p('</th>');
				htp.p('<th title="Comando de extra&ccedil;&atilde;o dos dados">');				
					htp.p('<a class="red" onclick="var dir = order('''', ''ajax''); ajax(''list'', ''etl_step_list'', ''prm_order=4&prm_dir=''+dir, false, ''content'','''','''',''ETL'');">'||fun.lang('COMANDO')||'</a>');
				htp.p('</th>');
				htp.p('<th title="Comando de limpeza da tabela de destino">');
					htp.p('<a class="red" onclick="var dir = order('''', ''ajax''); ajax(''list'', ''etl_step_list'', ''prm_order=5&prm_dir=''+dir, false, ''content'','''','''',''ETL'');">'||fun.lang('COMANDO LIMPEZA')||'</a>');
				htp.p('</th>');
				htp.p('<th title="Conex&atilde;o Utilizada">');
					htp.p('<a class="red" onclick="var dir = order('''', ''ajax''); ajax(''list'', ''etl_step_list'', ''prm_order=6&prm_dir=''+dir, false, ''content'','''','''',''ETL'');">'||fun.lang('CONEX&Atilde;O')||'</a>');
				htp.p('</th>');
				htp.p('<th title="Tabela atualizada no BI">');
					htp.p('<a class="red" onclick="var dir = order('''', ''ajax''); ajax(''list'', ''etl_step_list'', ''prm_order=7&prm_dir=''+dir, false, ''content'','''','''',''ETL'');">'||fun.lang('TABELA DESTINO')||'</a>');
				htp.p('</th>');
				htp.p('<th></th>');
				htp.p('<th></th>');
				if prm_step_id is null then
					htp.p('<th></th>');
				end if;	
				htp.p('<th></th>');
			htp.p('</tr>');
		htp.p('</thead>');

		if to_number(prm_dir) = 1 then
			ws_dir := 2;
		end if;

		htp.p('<tbody id="ajax" data-dir="'||ws_dir||'">');
			for a in c1 loop 
				ws_evento := replace(ws_eventoGravar,'#ID#',a.step_id); 
				htp.p('<tr id="'||a.step_id||'">');
					htp.p('<td>'||a.step_id||'</td>');
	
			        -- ws_comando   := replace(fun.html_trans(a.comando),chr(10),'<br>');
					ws_comando := fun.html_trans(a.comando);
					ws_comando_l := replace(fun.html_trans(a.comando_limpar),chr(10),'<br>');

					select max(nvl(ds_item, ds_abrev)) into ws_desc from bi_lista_padrao where cd_lista = 'ETL_TIPO_EXECUCAO' and cd_item = a.tipo_execucao;  
					htp.p('<td class="etl_tp_exec">'||ws_desc||'</td>');

					htp.p('<td>');
						htp.p('<a class="script" data-default="'||a.tipo_comando||'" onclick='||replace(replace(ws_evento,'#CAMPO#','TIPO_COMANDO'),'#VALOR#','this.nextElementSibling.title')||'></a>');
						fcl.fakeoption('prm_tipo_comando_'||a.step_id, fun.lang('Tipo Comando'), a.tipo_comando, 'lista-etl-tipo-comando', 'N', 'N', null, prm_min => 1);
					htp.p('</td>');

					htp.p('<td title="'||ws_comando||'" class="etl_modal_comando" style="cursor: pointer;">');
						htp.p('<input id="prm_comando_'||a.step_id||'" class="readonly" style="text-transform: none !important;" data-min="1" value="'||replace(fun.html_trans(a.comando),chr(10),' ')||'" />');
					htp.p('</td>');

					if a.tipo_execucao <> 'PL/SQL' then 
						htp.p('<td title="'||ws_comando_l||'" class="etl_modal_comando_limpar" style="cursor: pointer;">');
							htp.p('<input id="prm_comando_limpar_'||a.step_id||'" class="readonly" style="text-transform: none !important;" data-min="1" value="'||ws_comando_l||'" />');
						htp.p('</td>');
						htp.p('<td>');
							htp.p('<a class="script" data-default="'||a.id_conexao||'" onclick='||replace(replace(ws_evento,'#CAMPO#','ID_CONEXAO'),'#VALOR#','this.nextElementSibling.title')||'></a>');
							fcl.fakeoption('prm_id_conexao_'||a.step_id, fun.lang('Conex&atilde;o'), a.id_conexao, 'lista-etl-conexao', 'N', 'N', null, prm_min => 1);
						htp.p('</td>');
						htp.p('<td><input id="prm_tbl_destino_'   ||a.step_id||'" type="text" data-min="1" data-default="'||a.tbl_destino    ||'" onblur='||replace(replace(ws_evento,'#CAMPO#','TBL_DESTINO'),   '#VALOR#','this.value')||' value="'||a.tbl_destino||'" /></td>');
					else 
						htp.p('<td></td>');
						htp.p('<td></td>');
						htp.p('<td></td>');
					end if;

					--htp.p('<td class="etl_atalho" title="Par&acirc;metros utilizados na execu&ccedil;&atilde;o da a&ccedil;&atilde;o" style="width: 30px;"'||
					--       ' onclick="carregaTelasup(''etl_step_param_list'', ''prm_step_id='||a.step_id||''', ''ETL'', ''etl_step_param'','''','''',''etl_step_list|prm_step_id='||prm_step_id||'|ETL|etl_step|||'');">');
					--	htp.p('<svg xmlns="http://www.w3.org/2000/svg" style="margin: 0 2px; height: 24px; width: 24px; float: left;" viewBox="0 0 24 24"><path d="M6 18h-2v5h-2v-5h-2v-3h6v3zm-2-17h-2v12h2v-12zm11 7h-6v3h2v12h2v-12h2v-3zm-2-7h-2v5h2v-5zm11 14h-6v3h2v5h2v-5h2v-3zm-2-14h-2v12h2v-12z"/></svg>');
					--htp.p('</td>');

					htp.p('<td class="etl_atalho" title="Log de execu&ccedil;&atilde;o da a&ccedil;&atilde;o" '||
					      ' onclick="carregaTelasup(''etl_log_list'', ''prm_tp=STEP&prm_id='||a.step_id||''', ''ETL'', ''none'','''','''',''etl_step_list|prm_step_id='||prm_step_id||'|ETL|etl_step|||'');">');
						htp.p('<svg viewBox="0 0 600 600" xml:space="preserve"><g><path d="M486.201,196.124h-13.166V132.59c0-0.396-0.062-0.795-0.115-1.196c-0.021-2.523-0.825-5-2.552-6.963L364.657,3.677 c-0.033-0.031-0.064-0.042-0.085-0.073c-0.63-0.707-1.364-1.292-2.143-1.795c-0.229-0.157-0.461-0.286-0.702-0.421 c-0.672-0.366-1.387-0.671-2.121-0.892c-0.2-0.055-0.379-0.136-0.577-0.188C358.23,0.118,357.401,0,356.562,0H96.757 C84.894,0,75.256,9.651,75.256,21.502v174.613H62.092c-16.971,0-30.732,13.756-30.732,30.733v159.812 c0,16.968,13.761,30.731,30.732,30.731h13.164V526.79c0,11.854,9.638,21.501,21.501,21.501h354.776 c11.853,0,21.501-9.647,21.501-21.501V417.392h13.166c16.966,0,30.729-13.764,30.729-30.731V226.854 C516.93,209.872,503.167,196.124,486.201,196.124z M96.757,21.502h249.054v110.009c0,5.939,4.817,10.75,10.751,10.75h94.972v53.861 H96.757V21.502z M317.816,303.427c0,47.77-28.973,76.746-71.558,76.746c-43.234,0-68.531-32.641-68.531-74.152 c0-43.679,27.887-76.319,70.906-76.319C293.389,229.702,317.816,263.213,317.816,303.427z M82.153,377.79V232.085h33.073v118.039 h57.944v27.66H82.153V377.79z M451.534,520.962H96.757v-103.57h354.776V520.962z M461.176,371.092 c-10.162,3.454-29.402,8.209-48.641,8.209c-26.589,0-45.833-6.698-59.24-19.664c-13.396-12.535-20.75-31.568-20.529-52.967 c0.214-48.436,35.448-76.108,83.229-76.108c18.814,0,33.292,3.688,40.431,7.139l-6.92,26.37 c-7.999-3.457-17.942-6.268-33.942-6.268c-27.449,0-48.209,15.567-48.209,47.134c0,30.049,18.807,47.771,45.831,47.771 c7.564,0,13.623-0.852,16.21-2.152v-30.488h-22.478v-25.723h54.258V371.092L461.176,371.092z"></path><path d="M212.533,305.37c0,28.535,13.407,48.64,35.452,48.64c22.268,0,35.021-21.186,35.021-49.5 c0-26.153-12.539-48.655-35.237-48.655C225.504,255.854,212.533,277.047,212.533,305.37z"></path></g></svg>');
					htp.p('</td>');

					if prm_step_id is null then 
						htp.p('<td class="etl_atalho" title="Copiar a&ccedil;&atilde;o" '||
					    	  ' onclick="call(''menu_etl'', ''prm_menu=etl_step&prm_tipo='||a.tipo_execucao||'&prm_id_copia='||a.step_id||''', ''fcl'').then(function(resposta){ '||
		      			  	'          if(resposta.indexOf(''ERRO|'') == -1){ alerta(''feed-fixo'', resposta.split(''|'')[1]); } else { document.getElementById(''painel'').innerHTML = resposta; }  });">');
							htp.p('<svg viewBox="0 0 28 28"><path d="M13.508 11.504l.93-2.494 2.998 6.268-6.31 2.779.894-2.478s-8.271-4.205-7.924-11.58c2.716 5.939 9.412 7.505 9.412 7.505zm7.492-9.504v-2h-21v21h2v-19h19zm-14.633 2c.441.757.958 1.422 1.521 2h14.112v16h-16v-8.548c-.713-.752-1.4-1.615-2-2.576v13.124h20v-20h-17.633z"></path></svg>');
						htp.p('</td>');
					end if; 

					htp.p('<td>');
						fcl.button_lixo('etl_step_delete','prm_step_id', a.step_id, prm_tag => 'a', prm_pkg => 'ETL');
					htp.p('</td>');
				htp.p('</tr>');						
			end loop; 	
			
		htp.p('</tbody>');
	htp.p('</table>');	
	
	htp.p('<div id="modal-box" style="display: contents;"></div>');

end etl_step_list; 




----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_step_insert (prm_step_id        varchar2,
						   prm_tipo_execucao  varchar2,
						   prm_tipo_comando   varchar2,
						   prm_id_conexao     varchar2,
						   prm_tbl_destino    varchar2,
						   prm_id_copia       varchar2 default null) as 

	ws_step_id  varchar2(100); 
	ws_run_id   number; 
	ws_count    integer; 
	ws_erro     varchar2(300); 
	ws_tipo_comando  varchar2(1000);
	ws_id_conexao    varchar2(1000);
	ws_tbl_destino   varchar2(200); 
	ws_comando         clob; 
	ws_comando_limpar  clob; 
	raise_erro  exception;
begin 

	ws_step_id := upper(trim(prm_step_id)); 

	if instr(ws_step_id,' ') > 0 then 
		ws_erro := 'ID da a&ccedil;&atilde;o n&atilde;o pode conter espa&ccedil;os'; 
		raise raise_erro;
	end if; 	

	select count(*) into ws_count from etl_step where step_id = ws_step_id; 
	if ws_count > 0 then 
		ws_erro := 'J&aacute; existe uma a&ccedil;&atilde;o cadastrada com esse ID'; 
		raise raise_erro;
	end if; 	

	ws_comando        := null;
	ws_comando_limpar := 'DELETE '||prm_tbl_destino;
	ws_tipo_comando   := prm_tipo_comando; 
	ws_id_conexao     := prm_id_conexao; 

	if prm_id_copia is not null then 
		select tipo_comando, id_conexao, comando, comando_limpar, tbl_destino
		  into ws_tipo_comando, ws_id_conexao, ws_comando, ws_comando_limpar, ws_tbl_destino 
		  from etl_step where step_id = prm_id_copia;
		ws_comando_limpar := REGEXP_REPLACE(ws_comando_limpar, ws_tbl_destino, prm_tbl_destino, 1, 0, 'i');   
	end if; 			  

	insert into etl_step (run_id, step_id, id_conexao, tipo_execucao, tipo_comando, tbl_destino, comando, comando_limpar)
	              values (null, ws_step_id, ws_id_conexao, prm_tipo_execucao, ws_tipo_comando, prm_tbl_destino, ws_comando, ws_comando_limpar );
	--if prm_id_copia is not null then 
	--	insert into etl_step_param (step_id, cd_parametro, ds_parametro, id_entreaspas) 
	--	                           (select ws_step_id, a.cd_parametro, a.ds_parametro, a.id_entreaspas from etl_step_param a
	--							    where a.step_id = prm_id_copia );
	--end if; 			  

	commit; 			  
	htp.p('OK|Registro inserido');

exception 
	when raise_erro then 
		htp.p('ERRO|'||ws_erro);
	when others then 	
		ws_erro	:= 'Erro inserindo registro, verique o log de erros do sistema';
		htp.p('ERRO|'||ws_erro);
    	insert into bi_log_sistema values(sysdate, 'etl_step_insert (others) :'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getusuario, 'ERRO');
		commit;
end etl_step_insert; 



----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_step_update ( prm_step_id       varchar2, 
                           	prm_cd_parametro  varchar2,
						   	prm_conteudo      varchar2 ) as 
	ws_parametro varchar2(4000);
	ws_id_conexao varchar2(200);
	ws_tp_conexao varchar2(100);
	ws_comando   clob;     
	ws_conteudo  clob; 
	ws_alerta    varchar2(300);
	ws_erro      varchar2(300); 
	raise_erro   exception;
begin 
	ws_parametro := upper(trim(prm_cd_parametro)); 
	ws_conteudo  := prm_conteudo; 

    if ws_parametro in ('STP_ORDER') and ws_conteudo is null then 
		ws_erro := 'Ordem deve ser preenchida';
		raise raise_erro; 
	end if; 	

	if ws_parametro = 'TIPO_COMANDO' then 
		select comando into ws_comando from etl_step where step_id = prm_step_id; 
		if ws_conteudo = 'FULL' and ws_comando like '%$[%]%' then 
			ws_alerta := '! Alerta, comando do tipo FULL n&atilde;o deve conter par&acirc;metros de data';
		end if;
	end if; 

	if ws_parametro = 'COMANDO_LIMPAR' then
		if ws_conteudo like '%:[%' then
			ws_tp_conexao := etl.ret_conexao_param(null,prm_step_id,'DB');  
			--   
			if ws_tp_conexao not in ('EXCEL','TXT') then 
				ws_erro := 'O par&acirc;metro :[n,n] deve ser utilizado somente em a&ccedil;&otilde;es de importa&ccedil;&atilde;o de arquivo.'; 
				raise raise_erro; 
			else
				if length(ws_conteudo)-length(replace(ws_conteudo,'[')) <> length(ws_conteudo)-length(replace(ws_conteudo,']')) then
					ws_erro := 'Par&acirc;metro :[n,n] n&atilde;o foi aberto ou encerrado corretamente'; 
					raise raise_erro; 
				end if; 
			end if; 
		end if;
	end if;

	update etl_step 
	   set ds_step        = decode(ws_parametro, 'DS_STEP',        ws_conteudo, ds_step       ), 
	       id_conexao     = decode(ws_parametro, 'ID_CONEXAO',     ws_conteudo, id_conexao    ), 
		   tipo_execucao  = decode(ws_parametro, 'TIPO_EXECUCAO',  ws_conteudo, tipo_execucao ), 
		   tipo_comando   = decode(ws_parametro, 'TIPO_COMANDO',   ws_conteudo, tipo_comando  ), 
		   tbl_destino    = decode(ws_parametro, 'TBL_DESTINO',    ws_conteudo, tbl_destino   ), 
		   comando        = decode(ws_parametro, 'COMANDO',        ws_conteudo, comando       ), 
		   comando_limpar = decode(ws_parametro, 'COMANDO_LIMPAR', ws_conteudo, comando_limpar)
	 where step_id = prm_step_id; 
	if sql%notfound then 
		ws_erro := 'N&atilde;o localizado A&ccedil;&atilde;o com esse ID, recarrega a tela e tente novamente'; 
		raise raise_erro; 
	end if;  	    

	commit; 
	htp.p('OK|Registro alterado'||ws_alerta);

exception 
	when raise_erro then 
		htp.p('ERRO|'||ws_erro);
	when others then 	
		ws_erro	:= 'Erro alterando registro, verique o log de erros do sistema';
		htp.p('ERRO|'||ws_erro);
    	insert into bi_log_sistema values(sysdate, 'etl_step_update (others) :'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getusuario, 'ERRO');
		commit;
end etl_step_update;



----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_step_comando_update ( prm_step_id     varchar2, 
                             	    prm_coluna      varchar2,
									prm_parametros  varchar2 ) as 
	ws_tp_conexao  varchar2(100); 
	ws_tp_execucao varchar2(100); 
	ws_tp_comando  varchar2(100);
	ws_parametros  varchar2(32000);
	ws_comando     clob; 
	ws_erro        varchar2(300); 
	ws_line_type   varchar2(2000); 
	ws_alerta      varchar2(300);
	raise_erro     exception;
begin 

    if upper(trim(prm_coluna)) not in ('COMANDO') then 
		ws_erro := 'Processo de altera&ccedil;&atilde;o deve ser utilizado somente para a coluna COMANDO';
		raise raise_erro; 
	end if; 	


	ws_parametros := replace(prm_parametros,'$[','###['); -- Retira o $ para não dar problema no vpipe_par
	ws_comando    := null;
	ws_tp_conexao := etl.ret_conexao_param(null,prm_step_id,'DB');  
	select max(tipo_execucao), max(tipo_comando) into ws_tp_execucao, ws_tp_comando from etl_step where step_id = prm_step_id; 

	for a in (select t1.cd_parametro, t1.nm_parametro, replace(t2.cd_conteudo,'###[','$[') cd_conteudo -- Retornando o [ para $[ (dos parametros)  		
                from etl_tipo_conexao t1, table(fun.vpipe_par(ws_parametros)) t2  
               where t1.tp_conexao   = ws_tp_conexao
                 and t1.tp_parametro = 'COMANDO'
				 and t1.tp_execucao   = ws_tp_execucao
                 and t1.cd_parametro = upper(t2.cd_coluna) 
				 and t2.cd_coluna is not null 
               order by t1.ordem_comando ) loop 
		-- Validar conteudo dos parametros ------------------- 		
		if a.cd_parametro = 'LINE_TYPE' then 
			a.cd_conteudo := trim(a.cd_conteudo);
			ws_line_type := a.cd_conteudo; 
			if upper(a.cd_conteudo) not in ('FULL_LINE','FULL_CONTENT','OCCUR_LINE') then 
				ws_erro := 'Conte&uacute;do incorreto para o par&acirc;metro ['||nvl(a.nm_parametro, a.cd_parametro)||']';
				raise raise_erro; 
			end if; 
		end if; 

		if a.cd_parametro = 'OCCUR_LINE' then 
			if upper(ws_line_type) = 'OCCUR_LINE' and a.cd_conteudo is null then 
				ws_erro := 'Para esse tipo de registro deve ser informado o par&acirc;metro ['||nvl(a.nm_parametro, a.cd_parametro)||']';
				raise raise_erro; 
			elsif upper(ws_line_type) <> 'OCCUR_LINE' then  
				a.cd_conteudo := '';
			end if; 
		end if; 

		-- Monta comando ------------------- 			
		if ws_comando is null then 
			ws_comando := a.cd_conteudo;  		
		else 
			ws_comando := ws_comando||g_separador_comando||a.cd_conteudo;  
		end if;	
	end loop; 			

	ws_alerta := '';
	if ws_tp_comando = 'FULL' and ws_comando like '%$[%]%' then 
		ws_alerta := '! Alerta, comando do tipo FULL n&atilde;o deve conter par&acirc;metros de data';
	end if;

	update etl_step 
	   set comando = ws_comando 
	 where step_id = prm_step_id; 
	if sql%notfound then 
		ws_erro := 'N&atilde;o localizado A&ccedil;&atilde;o com esse ID, recarrega a tela e tente novamente'; 
		raise raise_erro; 
	end if;  	    

	commit; 
	htp.p('OK|Registro alterado'||ws_alerta||'|'||replace(ws_comando,'|','[#SEP#]'));

exception 
	when raise_erro then 
		htp.p('ERRO|'||ws_erro);
	when others then 	
		ws_erro	:= 'Erro alterando registro, verique o log de erros do sistema';
		htp.p('ERRO|'||ws_erro);
    	insert into bi_log_sistema values(sysdate, 'etl_step_comando_update (others) :'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getusuario, 'ERRO');
		commit;
end etl_step_comando_update;


----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_step_delete ( prm_step_id varchar2 ) as 
	ws_count    integer; 
	ws_erro     varchar2(300); 
	ws_ds_run   varchar2(300); 
	raise_erro  exception; 							   
begin 
	
	ws_ds_run := null;
	select max(ds_run) into ws_ds_run  
	  from etl_run a, etl_run_step b
	 where a.run_id  = b.run_id 
	   and b.step_id = prm_step_id; 
	
	if ws_ds_run is not null then 
		ws_erro := 'A&ccedil;&atilde;o n&atilde;o pode ser exclu&iacute;da porque est&aacute; sendo utilizada na tarefa ['||ws_ds_run||']';
		raise raise_erro; 
	end if;  

	delete etl_step where step_id = prm_step_id ;
	delete etl_step_param where step_id = prm_step_id ;
	commit;

	htp.p('OK|Registro exclu&iacute;do');

exception 
	when raise_erro then 
		htp.p('ERRO|'||ws_erro);
	when others then 	
		ws_erro	:= 'Erro excluindo registro, verique o log de erros do sistema.';
		htp.p('ERRO|'||ws_erro);
    	insert into bi_log_sistema values(sysdate, 'etl_step_delete (others) :'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getusuario, 'ERRO');
		commit;
end etl_step_delete; 


----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_fila_list (prm_tp       varchar2 default null,
						 prm_id       varchar2 default null,
						 prm_order    varchar2 default null,
                         prm_dir      varchar2 default null,
						 prm_linhas	  varchar2 default '50') as 
	ws_order   varchar2(3); 
	ws_dir     varchar2(1);

	cursor c1 is
		select * 
		 from ( select t1.id_uniq, t1.run_id, nvl(t2.ds_run,t1.run_id) ds_run, t1.step_id, t1.id_conexao, t1.tbl_destino, t1.comando, t1.comando_limpar, t1.dt_criacao, t1.dt_inicio, t1.dt_final, t1.status, t1.erros,
					t1.nr_tentativa, t1.qt_tentativas, decode(status,'A','Aguardando', 'F','Finalizado', 'E','Erro', 'C','Cancelado', '') ds_status, t1.dados_retorno 
				from etl_fila t1 left join etl_run t2 on t2.run_id = t1.run_id 
				where ( ( prm_tp is null ) or 
						( prm_tp = 'RUN'           and t1.run_id      = prm_id) or 
						( prm_tp = 'RUN_STEP'      and t1.run_step_id = prm_id and t1.run_step_id is not null) or 
						( prm_tp = 'STEP'          and t1.step_id     = prm_id and t1.step_id     is not null) or 
						( prm_tp = 'LOG'           and t1.log_id      = prm_id and t1.log_id      is not null) or 
						( prm_tp = 'TESTE_CONEXAO' and t1.run_id      = 'TESTE_CONEXAO' and t1.id_conexao = prm_id) 
					)
				order by case when ws_dir = '1' then decode(ws_order, '1', t2.ds_run, '2', t1.step_id, '3', comando, '4', comando_limpar, '5', to_char(dt_criacao,'YYMMDDHH24MI'),'6', to_char(dt_inicio,'YYMMDDHH24MI'), '7', to_char(dt_final,'YYMMDDHH24MI'), '8', status, '9', nr_tentativa, erros) end asc,
						case when ws_dir = '2' then decode(ws_order, '1', t2.ds_run, '2', t1.step_id, '3', comando, '4', comando_limpar, '5', to_char(dt_criacao,'YYMMDDHH24MI'),'6', to_char(dt_inicio,'YYMMDDHH24MI'), '7', to_char(dt_final,'YYMMDDHH24MI'), '8', status, '9', nr_tentativa, erros) end desc 
			   ) 
         where rownum <= decode(prm_linhas,'TODAS',999999,to_number(prm_linhas));

	ws_eventoGravar    varchar2(2000); 
	ws_evento          varchar2(2000); 
	ws_comando         clob;
	ws_comando_l       clob;
	ws_erros           clob;
	ws_count           number ;
	ws_onclick_th      varchar2(2000);
	ws_dir_next        varchar2(1); 
	ws_dados_ret       clob;
begin 
	ws_order := nvl(prm_order,'5');
	ws_dir   := nvl(prm_dir  ,'2'); 

	htp.p('<input type="hidden" id="content-atributos" data-refresh="etl_fila_list" data-pkg="etl" >');
	ws_onclick_th := 'var dir = order('''', ''ajax''); ajax(''list'', ''etl_fila_list'', ''prm_tp='||prm_tp||'&prm_id='||prm_id||'&prm_order=#ORDEM&prm_dir=''+dir, false, ''content'','''','''',''ETL'');'; 

	htp.p('<div id="searchbar" data-stop="S">');
		htp.p('<label>Filtrar linhas</label>');
		htp.p('<select id="searchbar" onchange="carregaTelasup(''etl_fila_list'', ''prm_tp='||prm_tp||'&prm_id='||prm_id||'&prm_linhas=''+this.value, ''ETL'', ''none'','''','''','''');">');
			for a in (select '<option '||decode(prm_linhas,'50',   'selected','')||' value="50">50 linhas</option>'   as opt from dual union all 
					  select '<option '||decode(prm_linhas,'100',  'selected','')||' value="100">100 linhas</option>' as opt from dual union all 
					  select '<option '||decode(prm_linhas,'150',  'selected','')||' value="150">150 linhas</option>' as opt from dual union all 
					  select '<option '||decode(prm_linhas,'200',  'selected','')||' value="200">200 linhas</option>' as opt from dual union all 
					  select '<option '||decode(prm_linhas,'250',  'selected','')||' value="250">250 linhas</option>' as opt from dual union all 
					  select '<option '||decode(prm_linhas,'500',  'selected','')||' value="500">500 linhas</option>' as opt from dual union all 
					  select '<option '||decode(prm_linhas,'TODAS','selected','')||' value="TODAS">todas</option>'    as opt from dual 
			         ) loop 
				htp.p(a.opt);		
			end loop;			
		htp.p('</select>');
	htp.p('</div>');

	htp.p('<h2>FILA INTEGRADOR</h2>');
	htp.p('<table class="linha">');
		htp.p('<thead>');
			htp.p('<tr>');
				htp.p('<th title="Tarefa que executou a&ccedil;&atilde;o">');              				htp.p('<a class="red" onclick="'||replace(ws_onclick_th,'#ORDEM','1') ||'">'||fun.lang('TAREFA')||'</a>');				htp.p('</th>');
				htp.p('<th title="A&ccedil;&atilde;o que inseriu o registro na fila do integrador">'); 	htp.p('<a class="red" onclick="'||replace(ws_onclick_th,'#ORDEM','2') ||'">'||fun.lang('A&Ccedil;&Atilde;O')||'</a>');	htp.p('</th>');
				htp.p('<th title="Comando de extra&ccedil;&atilde;o dos dados">');    					htp.p('<a class="red" onclick="'||replace(ws_onclick_th,'#ORDEM','3') ||'">'||fun.lang('COMANDO')||'</a>'); 				htp.p('</th>');
				htp.p('<th title="Comando de limpeza da tabela de destino">'); 					        htp.p('<a class="red" onclick="'||replace(ws_onclick_th,'#ORDEM','4') ||'">'||fun.lang('COM.LIMPAR')||'</a>'); 			htp.p('</th>');
				htp.p('<th title="Data de cria&ccedil;&atilde;o do registro na fila">'); 				htp.p('<a class="red" onclick="'||replace(ws_onclick_th,'#ORDEM','5') ||'">'||fun.lang('DT CRIA&Ccedil&AtildeO')||'</a>'); 				htp.p('</th>');
				htp.p('<th title="Data e hora inicial da execu&ccedil;&atilde;o do integrador">'); 		htp.p('<a class="red" onclick="'||replace(ws_onclick_th,'#ORDEM','6') ||'">'||fun.lang('DT INICIO')||'</a>'); 			htp.p('</th>');
				htp.p('<th title="Data e hora final da execu&ccedil;&atilde;o do integrador">'); 		htp.p('<a class="red" onclick="'||replace(ws_onclick_th,'#ORDEM','7') ||'">'||fun.lang('DT FIM')||'</a>'); 				htp.p('</th>');
				htp.p('<th title="Situa&ccedil;&atilde;o da execu&ccedil;&atilde;o do comando">'); 		htp.p('<a class="red" onclick="'||replace(ws_onclick_th,'#ORDEM','8') ||'">'||fun.lang('STATUS')||'</a>'); 				htp.p('</th>');
				htp.p('<th title="Quantidade de tentativas de execu&ccedil;&atilde;o no integrador">'); htp.p('<a class="red" onclick="'||replace(ws_onclick_th,'#ORDEM','9') ||'">'||fun.lang('TENT.')||'</a>'); 				htp.p('</th>');
				htp.p('<th title="Mensagem de retorno da execu&ccedil;&atilde;o">'); 					htp.p('<a class="red" onclick="'||replace(ws_onclick_th,'#ORDEM','10')||'">'||fun.lang('RETORNO')||'</a>'); 			htp.p('</th>');
				htp.p('<th></th>');
			htp.p('</tr>');
		htp.p('</thead>');

		if to_number(ws_dir) = 1 then
			ws_dir_next := 2;
		else 	
			ws_dir_next := 1;
		end if;

		htp.p('<tbody id="ajax" data-dir="'||ws_dir_next||'">');
			ws_count := 0;
			for a in c1 loop 
				ws_count  := ws_count + 1;
				exit when(ws_count > 1000); 
				ws_evento    := replace(ws_eventoGravar,'#ID#',a.id_uniq); 
		        ws_comando   := replace(fun.html_trans(a.comando),chr(10),'<br>');
				ws_comando_l := replace(fun.html_trans(a.comando_limpar),chr(10),'<br>');
				ws_erros     := replace(fun.html_trans(a.erros),chr(10),'<br>');
				ws_dados_ret := a.dados_retorno;
				if ws_dados_ret is not null then 
					if length(ws_dados_ret) > 15000 then 
						ws_dados_ret := substr(ws_dados_ret,1,8000)||chr(10)||' ... '||chr(10)||substr(ws_dados_ret,length(ws_dados_ret)-7000,7000)||chr(10);
					else 	
						ws_dados_ret := ws_dados_ret||chr(10);
					end if;
					ws_dados_ret := replace(fun.html_trans(ws_dados_ret),chr(10),'<br>');
				end if; 

				htp.p('<tr id="'||a.id_uniq||'">');
					htp.p('<td class="etl_col_ds_tarefa" style="width: 70px !important;">  <input disabled title="'||a.ds_run||'" value="'||a.ds_run||'"/> </td>'); --  style="min-width:200px"
					htp.p('<td class="etl_col_ds_acao"   style="width: 130px !important;"> <input disabled title="'||a.step_id||'  -  '||a.id_conexao||'  -  '||a.tbl_destino||'" value="'||a.step_id||'"/> </td>'); --  style="min-width:200px"

					htp.p('<td style="width: 100px !important;">'); 
						htp.p('<input class="zoom_column" readonly value="'||ws_comando||'"  onclick="modal_txt_sup(event,this.value);"/>'); 
					htp.p('</td>');
					
					htp.p('<td style="width: 100px !important;">'); 
						htp.p('<input class="zoom_column" readonly value="'||ws_comando_l||'" onclick="modal_txt_sup(event,this.value);"/>'); 
					htp.p('</td>');
					htp.p('<td class="etl_col_dh"><input disabled value="'||TO_CHAR(a.dt_criacao, 'DD/MM/YYYY HH24:MI:SS')||'"/></td>');
					htp.p('<td class="etl_col_dh"><input disabled value="'||TO_CHAR(a.dt_inicio, 'DD/MM/YYYY HH24:MI:SS') ||'"/></td>');
					htp.p('<td class="etl_col_dh"><input disabled value="'||TO_CHAR(a.dt_final, 'DD/MM/YYYY HH24:MI:SS')  ||'"/></td>');
					htp.p('<td class="etl_qt_tent"> <input disabled value="'||a.ds_status||'"/></td>');
					htp.p('<td class="etl_qt_tent"> <input disabled value="'||nvl(a.nr_tentativa,'1')||'/'||nvl(a.qt_tentativas,'1')||'"/></td>');
					htp.p('<td>'); 
						htp.p('<input class="zoom_column" readonly value="'||ws_erros||'" onclick="modal_txt_sup(event,this.value);"/>'); 
					htp.p('</td>');

					if ws_dados_ret is null then 
						htp.p('<td></td>'); 
					else 
						htp.p('<td class="etl_atalho" title="Dados retornados na integra&ccedil;&atilde;o" style="width: 30px;" onclick="modal_txt_sup(event,this.children[0].value,''top-center'');">');
							htp.p('<input type="hidden" value="'||ws_dados_ret||'" />');
							htp.p(fun.ret_svg('data_download'));
						htp.p('</td>');
					end if; 	

				htp.p('</tr>');						
			end loop; 	
			
		htp.p('</tbody>');
	htp.p('</table>');	
	
	htp.p('<div id="modal-txt" class="modal-txt"></div>');
exception when others then 	
   	insert into bi_log_sistema values(sysdate, 'etl_fila_list (others) :'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getusuario, 'ERRO');
	commit;
	Raise_Application_Error (-20101, DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);	
end etl_fila_list ; 



----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_run_list (prm_order    varchar2 default '2', 
                        prm_dir      varchar2 default '1') as 
	cursor c1 is  
		select a.run_id, a.ds_run, a.data, a.last_run, a.st_suspenso, a.last_status, st_ativo 
          from etl_run a 
	  order by case when prm_dir = '1' then decode(prm_order, '1', run_id, '2', ds_run, '3', to_char(data,'YYMMDDHH24MI'), '4', st_ativo, '5', to_char(last_run, 'YYMMDDHH24MI'), '6', last_status, ds_run) end asc,
			   case when prm_dir = '2' then decode(prm_order, '1', run_id, '2', ds_run, '3', to_char(data,'YYMMDDHH24MI'), '4', st_ativo, '5', to_char(last_run, 'YYMMDDHH24MI'), '6', last_status, ds_run) end desc ; 

	ws_eventoGravar    varchar2(2000); 
	ws_evento          varchar2(2000); 
	ws_dir             number := 1;
begin 
	ws_eventoGravar := ' "requestDefault(''etl_run_update'', ''prm_run_id=#ID#&prm_cd_parametro=#CAMPO#&prm_conteudo=''+#VALOR#,this,#VALOR#,'''',''ETL'');"'; 

	htp.p('<input type="hidden" id="content-atributos" data-refresh="etl_run_list" data-pkg="etl">');

	htp.p('<table class="linha">');
		htp.p('<thead>');
			htp.p('<tr>');
				htp.p('<th title="ID da tarefa">');
					htp.p('<a class="red" onclick="var dir = order('''', ''ajax''); ajax(''list'', ''etl_run_list'', ''prm_order=1&prm_dir=''+dir, false, ''content'','''','''',''ETL'');">'||fun.lang('ID_TAREFA')||'</a>');
				htp.p('</th>');
				htp.p('<th title="Nome da tarefa">');
					htp.p('<a class="red" onclick="var dir = order('''', ''ajax''); ajax(''list'', ''etl_run_list'', ''prm_order=2&prm_dir=''+dir, false, ''content'','''','''',''ETL'');">'||fun.lang('NOME TAREFA')||'</a>');
				htp.p('</th>');
				htp.p('<th title="Data da cria&ccedil;&atlde;o da tarefa">');
					htp.p('<a class="red" onclick="var dir = order('''', ''ajax''); ajax(''list'', ''etl_run_list'', ''prm_order=3&prm_dir=''+dir, false, ''content'','''','''',''ETL'');">'||fun.lang('CRIA&Ccedil;&Atilde;O')||'</a>');
				htp.p('</th>');
				htp.p('<th title="Situa&ccedil;&atlde;o da tarefa">');
					htp.p('<a class="red" onclick="var dir = order('''', ''ajax''); ajax(''list'', ''etl_run_list'', ''prm_order=4&prm_dir=''+dir, false, ''content'','''','''',''ETL'');">'||fun.lang('ATIVA')||'</a>');
				htp.p('</th>');
				htp.p('<th title="&Uacute;ltima execu&ccedil;&atlde;o">');
					htp.p('<a class="red" onclick="var dir = order('''', ''ajax''); ajax(''list'', ''etl_run_list'', ''prm_order=5&prm_dir=''+dir, false, ''content'','''','''',''ETL'');">'||fun.lang('&Uacute;LTIMA EXEC.')||'</a>');
				htp.p('</th>');
				htp.p('<th title="Situa&ccedil;&atlde;o da &uacute;ltima execu&ccedil;&atlde;o" style="text-align: center;width: 100px;">');
					htp.p('<a class="red" onclick="var dir = order('''', ''ajax''); ajax(''list'', ''etl_run_list'', ''prm_order=6&prm_dir=''+dir, false, ''content'','''','''',''ETL'');">'||fun.lang('SITUA&Ccedil;&Atilde;O')||'</a>');
				htp.p('</th>');
				htp.p('<th></th>');
				htp.p('<th></th>');
				htp.p('<th></th>');
				htp.p('<th></th>');
				htp.p('<th></th>');
				htp.p('<th></th>');
				htp.p('<th></th>');
				htp.p('<th></th>');
			htp.p('</tr>');
		htp.p('</thead>');

		if to_number(prm_dir) = 1 then
			ws_dir := 2;
		end if;

		htp.p('<tbody id="ajax" data-dir="'||ws_dir||'">');
			for a in c1 loop 

				ws_evento := replace(ws_eventoGravar,'#ID#',a.run_id); 
				htp.p('<tr id="'||a.run_id||'">');
					htp.p('<td><input id="prm_runid_'||a.run_id||'" disabled value="'||a.run_id||'" /></td>');
					htp.p('<td><input id="prm_ds_run_'||a.run_id||'" data-min="1" data-default="'||a.ds_run||'" onblur='||replace(replace(ws_evento,'#CAMPO#','DS_RUN'),'#VALOR#','this.value')||' value="'||a.ds_run||'" /></td>');
					htp.p('<td><input id="prm_data_'||a.run_id||'" disabled value="'||to_char(a.data,'DD/MM/YYYY HH24:MI')||'" /></td>');

					htp.p('<td>');
						htp.p('<select  id="st_ativo'||a.run_id||'" onchange='||replace(replace(ws_evento,'#CAMPO#','ST_ATIVO'),'#VALOR#','this.value')||'>');
							for b in (select 'N' opc, 'N&atilde;o' dsc, decode(a.st_ativo,'N', 'selected','') sel from dual union all 
									  select 'S' opc, 'Sim'        dsc, decode(a.st_ativo,'S', 'selected','') sel from dual) loop 
								htp.p('<option value="'||b.opc||'" '||b.sel||'>'||b.dsc||'</option>');
							end loop; 
						htp.p('</select>');
				    htp.p('</td>');

					htp.p('<td><input id="prm_last_run_'||a.run_id||'" disabled value="'||to_char(a.last_run,'DD/MM/YYYY HH24:MI')||'" /></td>');				
					htp.p('<td class="etl_status">'||prn_a_status(a.last_status)||'</td>');

					htp.p('<td><div style="width: 1px !important; min-width: 1px !important;"></div></td>');  -- Cria uma divisao 

					htp.p('<td class="etl_atalho" title="Agenda de execu&ccedil;&otilde;es da tarefa" '||
					      ' onclick="carregaTelasup(''etl_schedule_list'', ''prm_run_id='||a.run_id||''', ''ETL'', ''etl_schedule'','''','''',''etl_run_list||ETL|etl_run|||'');">');
						htp.p('<svg height="512pt" width="512pt" viewBox="-34 0 512 512.04955" xmlns="http://www.w3.org/2000/svg"><path d="m.0234375 290.132812c-.02734375 121.429688 97.5703125 220.324219 218.9882815 221.898438 121.421875 1.574219 221.550781-94.753906 224.671875-216.144531 3.125-121.386719-91.917969-222.734375-213.257813-227.40625v-17.28125h17.066407c14.136718 0 25.597656-11.460938 25.597656-25.597657 0-14.140624-11.460938-25.601562-25.597656-25.601562h-51.199219c-14.140625 0-25.601563 11.460938-25.601563 25.601562 0 14.136719 11.460938 25.597657 25.601563 25.597657h17.066406v17.28125c-119.054687 4.707031-213.183594 102.507812-213.3359375 221.652343zm187.7343745-264.53125c0-4.714843 3.820313-8.535156 8.535157-8.535156h51.199219c4.710937 0 8.53125 3.820313 8.53125 8.535156 0 4.710938-3.820313 8.53125-8.53125 8.53125h-51.199219c-4.714844 0-8.535157-3.820312-8.535157-8.53125zm238.933594 264.53125c0 113.109376-91.691406 204.800782-204.800781 204.800782-113.105469 0-204.800781-91.691406-204.800781-204.800782 0-113.105468 91.695312-204.800781 204.800781-204.800781 113.054687.132813 204.667969 91.746094 204.800781 204.800781zm0 0"/><path d="m315.3125 127.402344c-57.828125-33.347656-129.046875-33.347656-186.878906 0-.136719.070312-.296875.070312-.441406.144531-.148438.078125-.214844.222656-.351563.308594-28.179687 16.4375-51.625 39.882812-68.0625 68.0625-.085937.136719-.222656.210937-.304687.347656-.085938.136719-.078126.300781-.148438.445313-33.347656 57.828124-33.347656 129.050781 0 186.878906.070312.144531.070312.300781.148438.445312.074218.144532.289062.347656.417968.535156 16.429688 28.097657 39.835938 51.472657 67.949219 67.875.136719.085938.214844.222657.351563.308594.136718.085938.433593.160156.648437.265625 57.714844 33.175781 128.71875 33.175781 186.433594 0 .214843-.105469.445312-.148437.648437-.265625.207032-.121094.214844-.222656.351563-.308594 28.117187-16.410156 51.523437-39.800781 67.949219-67.90625.128906-.1875.300781-.335937.417968-.539062.121094-.203125.078125-.296875.148438-.445312 33.347656-57.828126 33.347656-129.046876 0-186.878907-.070313-.144531-.070313-.296875-.148438-.441406-.074218-.148437-.21875-.214844-.304687-.34375-16.433594-28.183594-39.882813-51.632813-68.0625-68.070313-.136719-.085937-.214844-.222656-.351563-.308593-.136718-.082031-.261718-.039063-.410156-.109375zm49.777344 70.203125-7.050782 4.070312c-2.660156 1.515625-4.308593 4.339844-4.3125 7.402344-.007812 3.058594 1.625 5.890625 4.28125 7.417969 2.65625 1.523437 5.925782 1.507812 8.566407-.039063l7.058593-4.078125c11.027344 21.488282 17.332032 45.09375 18.488282 69.222656h-25.164063c-4.710937 0-8.53125 3.820313-8.53125 8.53125 0 4.714844 3.820313 8.535157 8.53125 8.535157h25.164063c-1.15625 24.128906-7.460938 47.730469-18.488282 69.222656l-7.058593-4.082031c-2.640625-1.546875-5.910157-1.5625-8.566407-.035156-2.65625 1.523437-4.289062 4.355468-4.28125 7.417968.003907 3.0625 1.652344 5.886719 4.3125 7.398438l7.050782 4.070312c-13.140625 20.265625-30.40625 37.53125-50.671875 50.671875l-4.070313-7.050781c-1.511718-2.660156-4.335937-4.308594-7.398437-4.3125-3.0625-.007812-5.894531 1.625-7.417969 4.28125-1.527344 2.65625-1.511719 5.925781.035156 8.566406l4.082032 7.058594c-21.492188 11.027344-45.09375 17.332031-69.222657 18.488281v-25.164062c0-4.710938-3.820312-8.53125-8.535156-8.53125-4.710937 0-8.53125 3.820312-8.53125 8.53125v25.164062c-24.128906-1.15625-47.734375-7.460937-69.222656-18.488281l4.078125-7.058594c1.546875-2.640625 1.5625-5.910156.039062-8.566406-1.527344-2.65625-4.359375-4.289062-7.417968-4.28125-3.0625.003906-5.886719 1.652344-7.402344 4.3125l-4.070313 7.050781c-20.265625-13.140625-37.53125-30.40625-50.667969-50.671875l7.046876-4.070312c2.660156-1.511719 4.308593-4.335938 4.316406-7.398438.007812-3.0625-1.628906-5.894531-4.285156-7.417968-2.652344-1.527344-5.921876-1.511719-8.566407.035156l-7.054687 4.082031c-11.03125-21.492187-17.335938-45.09375-18.492188-69.222656h25.164063c4.714843 0 8.535156-3.820313 8.535156-8.535157 0-4.710937-3.820313-8.53125-8.535156-8.53125h-25.164063c1.15625-24.128906 7.460938-47.734374 18.492188-69.222656l7.054687 4.078125c2.644531 1.546875 5.914063 1.5625 8.566407.039063 2.65625-1.527344 4.292968-4.359375 4.285156-7.417969-.007813-3.0625-1.65625-5.886719-4.316406-7.402344l-7.046876-4.070312c13.136719-20.265625 30.402344-37.53125 50.667969-50.671875l4.070313 7.050781c1.515625 2.660156 4.339844 4.308594 7.402344 4.316406 3.058593.003907 5.890624-1.628906 7.417968-4.285156 1.523438-2.65625 1.507813-5.921875-.039062-8.566406l-4.078125-7.054688c21.488281-11.03125 45.09375-17.335937 69.222656-18.492187v25.164062c0 4.714844 3.820313 8.535156 8.53125 8.535156 4.714844 0 8.535156-3.820312 8.535156-8.535156v-25.164062c24.128907 1.15625 47.730469 7.460937 69.222657 18.492187l-4.082032 7.054688c-1.546875 2.644531-1.5625 5.910156-.035156 8.566406 1.523438 2.65625 4.355469 4.289063 7.417969 4.285156 3.0625-.007812 5.886719-1.65625 7.398437-4.316406l4.070313-7.050781c20.265625 13.140625 37.53125 30.40625 50.671875 50.671875zm0 0"/><path d="m230.425781 266.101562v-86.902343c0-4.710938-3.820312-8.53125-8.535156-8.53125-4.710937 0-8.53125 3.820312-8.53125 8.53125v86.902343c-11.757813 4.15625-18.808594 16.179688-16.699219 28.46875 2.109375 12.285157 12.761719 21.269532 25.230469 21.269532s23.125-8.984375 25.230469-21.269532c2.109375-12.289062-4.941406-24.3125-16.695313-28.46875zm-8.535156 32.566407c-4.710937 0-8.53125-3.820313-8.53125-8.535157 0-4.710937 3.820313-8.53125 8.53125-8.53125 4.714844 0 8.535156 3.820313 8.535156 8.53125 0 4.714844-3.820312 8.535157-8.535156 8.535157zm0 0"/></svg>');						
					htp.p('</td>');

					htp.p('<td class="etl_atalho" title="Lista de A&ccedil;&otilde;es" '||
							  ' onclick="carregaTelasup(''etl_run_step_list'', ''prm_run_id='||a.run_id||''', ''ETL'', ''etl_run_step'','''','''',''etl_run_list||ETL|etl_run|||'');">');
						htp.p('<svg style="height: 30px; width: 30px;" viewBox="0 0 24 24" clip-rule="evenodd" fill-rule="evenodd" stroke-linejoin="round" stroke-miterlimit="2" xmlns="http://www.w3.org/2000/svg"><path d="m21 4c0-.478-.379-1-1-1h-16c-.62 0-1 .519-1 1v16c0 .621.52 1 1 1h16c.478 0 1-.379 1-1zm-16.5.5h15v15h-15zm13.5 10.75c0-.414-.336-.75-.75-.75h-4.5c-.414 0-.75.336-.75.75s.336.75.75.75h4.5c.414 0 .75-.336.75-.75zm-11.772-.537 1.25 1.114c.13.116.293.173.455.173.185 0 .37-.075.504-.222l2.116-2.313c.12-.131.179-.296.179-.459 0-.375-.303-.682-.684-.682-.185 0-.368.074-.504.221l-1.66 1.815-.746-.665c-.131-.116-.293-.173-.455-.173-.379 0-.683.307-.683.682 0 .188.077.374.228.509zm11.772-2.711c0-.414-.336-.75-.75-.75h-4.5c-.414 0-.75.336-.75.75s.336.75.75.75h4.5c.414 0 .75-.336.75-.75zm-11.772-1.613 1.25 1.114c.13.116.293.173.455.173.185 0 .37-.074.504-.221l2.116-2.313c.12-.131.179-.296.179-.46 0-.374-.303-.682-.684-.682-.185 0-.368.074-.504.221l-1.66 1.815-.746-.664c-.131-.116-.293-.173-.455-.173-.379 0-.683.306-.683.682 0 .187.077.374.228.509zm11.772-1.639c0-.414-.336-.75-.75-.75h-4.5c-.414 0-.75.336-.75.75s.336.75.75.75h4.5c.414 0 .75-.336.75-.75z"/></svg>');
					htp.p('</td>');

					htp.p('<td class="etl_atalho" title="Par&acirc;metros utilizados nas a&ccedil;&otilde;es da tarefa" '||
							  ' onclick="carregaTelasup(''etl_run_param_list'', ''prm_run_id='||a.run_id||''', ''ETL'', ''none'','''','''',''etl_run_list||ETL|etl_run|||'');">');
						htp.p('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M6 18h-2v5h-2v-5h-2v-3h6v3zm-2-17h-2v12h2v-12zm11 7h-6v3h2v12h2v-12h2v-3zm-2-7h-2v5h2v-5zm11 14h-6v3h2v5h2v-5h2v-3zm-2-14h-2v12h2v-12z"/></svg>');
					htp.p('</td>');

					htp.p('<td class="etl_atalho" title="Executar a tarefa manualmente uma &uacute;nica vez" '||
						  ' onclick="if(!confirm(''Confirma a execu\u00e7\u00e3o da tarefa?'')){ return false; }  call(''etl_run_exec'', ''prm_run_id='||a.run_id||''', ''ETL'').then(function(resposta){ alerta('''',resposta.split(''|'')[1]); if (resposta.split(''|'')[0] == ''OK'') {ajax(''list'', ''etl_run_list'', '''', true, ''content'','''','''',''ETL''); } });">');
						htp.p('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M12 2c5.514 0 10 4.486 10 10s-4.486 10-10 10-10-4.486-10-10 4.486-10 10-10zm0-2c-6.627 0-12 5.373-12 12s5.373 12 12 12 12-5.373 12-12-5.373-12-12-12zm-3 17v-10l9 5.146-9 4.854z"/></svg>');
					htp.p('</td>');

					htp.p('<td class="etl_atalho" title="Cancelar a execu&ccedil;&atilde;o atual" '||
						  ' onclick="if(!confirm(''Confirma o cancelamento da execu\u00e7\u00e3o da tarefa?'')){ return false; } call(''etl_run_stop'', ''prm_run_id='||a.run_id||''', ''ETL'').then(function(resposta){ alerta('''',resposta.split(''|'')[1]); if (resposta.split(''|'')[0] == ''OK'') {ajax(''list'', ''etl_run_list'', '''', true, ''content'','''','''',''ETL''); } });">');
						htp.p('<svg viewBox="0 0 512 512"> <g><g><path d="M256,0C114.609,0,0,114.609,0,256c0,141.391,114.609,256,256,256c141.391,0,256-114.609,256-256C512,114.609,397.391,0,256,0z M256,472c-119.297,0-216-96.703-216-216S136.703,40,256,40s216,96.703,216,216S375.297,472,256,472z"/><rect x="176" y="176" width="160" height="160"/></g></g></svg>');
					htp.p('</td>');

					htp.p('<td class="etl_atalho" title="Log de execu&ccedil;&atilde;o da tarefa" '||
						      ' onclick="carregaTelasup(''etl_log_list'', ''prm_tp=RUN&prm_id='||a.run_id||''', ''ETL'', ''none'','''','''',''etl_run_list||ETL|etl_run|||'');">');
						htp.p('<svg viewBox="0 0 600 600" xml:space="preserve"><g><path d="M486.201,196.124h-13.166V132.59c0-0.396-0.062-0.795-0.115-1.196c-0.021-2.523-0.825-5-2.552-6.963L364.657,3.677 c-0.033-0.031-0.064-0.042-0.085-0.073c-0.63-0.707-1.364-1.292-2.143-1.795c-0.229-0.157-0.461-0.286-0.702-0.421 c-0.672-0.366-1.387-0.671-2.121-0.892c-0.2-0.055-0.379-0.136-0.577-0.188C358.23,0.118,357.401,0,356.562,0H96.757 C84.894,0,75.256,9.651,75.256,21.502v174.613H62.092c-16.971,0-30.732,13.756-30.732,30.733v159.812 c0,16.968,13.761,30.731,30.732,30.731h13.164V526.79c0,11.854,9.638,21.501,21.501,21.501h354.776 c11.853,0,21.501-9.647,21.501-21.501V417.392h13.166c16.966,0,30.729-13.764,30.729-30.731V226.854 C516.93,209.872,503.167,196.124,486.201,196.124z M96.757,21.502h249.054v110.009c0,5.939,4.817,10.75,10.751,10.75h94.972v53.861 H96.757V21.502z M317.816,303.427c0,47.77-28.973,76.746-71.558,76.746c-43.234,0-68.531-32.641-68.531-74.152 c0-43.679,27.887-76.319,70.906-76.319C293.389,229.702,317.816,263.213,317.816,303.427z M82.153,377.79V232.085h33.073v118.039 h57.944v27.66H82.153V377.79z M451.534,520.962H96.757v-103.57h354.776V520.962z M461.176,371.092 c-10.162,3.454-29.402,8.209-48.641,8.209c-26.589,0-45.833-6.698-59.24-19.664c-13.396-12.535-20.75-31.568-20.529-52.967 c0.214-48.436,35.448-76.108,83.229-76.108c18.814,0,33.292,3.688,40.431,7.139l-6.92,26.37 c-7.999-3.457-17.942-6.268-33.942-6.268c-27.449,0-48.209,15.567-48.209,47.134c0,30.049,18.807,47.771,45.831,47.771 c7.564,0,13.623-0.852,16.21-2.152v-30.488h-22.478v-25.723h54.258V371.092L461.176,371.092z"></path><path d="M212.533,305.37c0,28.535,13.407,48.64,35.452,48.64c22.268,0,35.021-21.186,35.021-49.5 c0-26.153-12.539-48.655-35.237-48.655C225.504,255.854,212.533,277.047,212.533,305.37z"></path></g></svg>');
					htp.p('</td>');

					htp.p('<td>');
						fcl.button_lixo('etl_run_delete','prm_run_id', a.run_id, prm_tag => 'a', prm_pkg => 'ETL');
					htp.p('</td>');
				htp.p('</tr>');						
			end loop; 	
			
		htp.p('</tbody>');
	htp.p('</table>');	
end etl_run_list; 


----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_run_insert (prm_ds_run varchar2) as 

	ws_run_id   varchar2(50); 
	ws_count    integer; 
	ws_erro     varchar2(300); 
	raise_erro  exception;
begin 

	select count(*) into ws_count from etl_run where ds_run = trim(prm_ds_run);
	if ws_count > 0 then 
		ws_erro := 'J&aacute; existe uma tarefa com esse nome'; 
		raise raise_erro;
	end if; 	
	--
	ws_run_id := 'RUN_'||to_char(sysdate,'yymmddhh24miss')||'_'||round(dbms_random.value(10,99));
	--
	insert into etl_run  (run_id, ds_run, data, st_ativo) values (ws_run_id, trim(prm_ds_run), sysdate, 'N' );  -- Cria como INATIVO
	insert into etl_run_param (run_id, cd_parametro, conteudo, st_ativo) values (ws_run_id, 'MINUTO_ESPERA', 30,'S'); 
	insert into etl_run_param (run_id, cd_parametro, conteudo, st_ativo) values (ws_run_id, 'MINUTO_ESPERA_PLSQL', 180,'S');   -- 3 horas
	commit; 			  
	--
	htp.p('OK|Registro inserido');
exception 
	when raise_erro then 
		htp.p('ERRO|'||ws_erro);
	when others then 	
		ws_erro	:= 'Erro inserindo registro, verique o log de erros do sistema';
		htp.p('ERRO|'||ws_erro);
    	insert into bi_log_sistema values(sysdate, 'etl_run_insert (others) :'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getusuario, 'ERRO');
		commit;
end etl_run_insert; 


----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_run_update ( prm_run_id       varchar2, 
                           prm_cd_parametro  varchar2,
						   prm_conteudo      varchar2 ) as 
	ws_parametro varchar2(4000);
	ws_conteudo  varchar2(32000); 
	ws_erro      varchar2(300); 
	raise_erro   exception;
begin 
	ws_parametro := upper(trim(prm_cd_parametro)); 
	ws_conteudo  := trim(prm_conteudo); 

    if ws_parametro in ('DS_RUN') and ws_conteudo is null then 
		ws_erro := 'Nome da tarefa deve ser preenchido';
		raise raise_erro; 
	end if; 	

	update etl_run  
	   set ds_run   = decode(ws_parametro, 'DS_RUN',   ws_conteudo, ds_run),
	       st_ativo = decode(ws_parametro, 'ST_ATIVO', ws_conteudo, st_ativo)
	 where run_id = prm_run_id; 
	if sql%notfound then 
		ws_erro := 'N&atilde;o localizada tarefa com o ID ['||prm_run_id||'], recarrega a tela e tente novamente'; 
		raise raise_erro; 
	end if;  	    

	commit; 
	htp.p('OK|Registro alterado');

exception 
	when raise_erro then 
		htp.p('ERRO|'||ws_erro);
	when others then 	
		ws_erro	:= 'Erro alterando registro, verique o log de erros do sistema';
		htp.p('ERRO|'||ws_erro);
    	insert into bi_log_sistema values(sysdate, 'etl_run_update (others) :'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getusuario, 'ERRO');
		commit;
end etl_run_update;



----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_run_delete (prm_run_id varchar2 ) as 
	ws_count    integer; 
	ws_erro     varchar2(300); 
	raise_erro  exception; 							   
begin 

	select count(*) into ws_count from etl_run_step where run_id = prm_run_id; 
	if ws_count > 0 then 
		ws_erro := 'Existem a&ccedil;&otilde;es para essa tarefa, primeiro exclua as ac&otilde;es da tarefa'; 
		raise raise_erro; 
	end if; 

	select count(*) into ws_count from etl_schedule where run_id = prm_run_id; 
	if ws_count > 0 then 
		ws_erro := 'Existem agendamento para essa tarefa, primeiro exclua os agendamentos de execu&ccedil;&atilde;o dessa tarefa'; 
		raise raise_erro; 
	end if; 	

	delete etl_run       where run_id = prm_run_id ;
	delete etl_run_param where run_id = prm_run_id ;

	commit;  
	htp.p('OK|Registro exclu&iacute;do');

exception 
	when raise_erro then 
		htp.p('ERRO|'||ws_erro);
	when others then 	
		ws_erro	:= 'Erro excluindo registro, verique o log de erros do sistema.';
		htp.p('ERRO|'||ws_erro);
    	insert into bi_log_sistema values(sysdate, 'etl_run_delete (others) :'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getusuario, 'ERRO');
		commit;
end etl_run_delete; 



----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_schedule_list(prm_run_id     varchar2) as 

	cursor c_lista (p_cd_lista varchar2, p_valores varchar2) is  
	select listagg(ds_abrev,', ') within group (order by nr_ordem) 
      from bi_lista_padrao 
     where cd_lista = p_cd_lista 
       and cd_item in (select column_value from table(fun.vpipe(p_valores)) ) ; 

    ws_eventoVerificar  varchar2(2000); 
	ws_eventoGravar     varchar2(2000); 
	ws_desc             varchar2(400);  

begin 
    ws_eventoVerificar  := 'if(document.getElementById(this.parentNode.parentNode.id+''#CAMPO#'').title.length > 0){if(confirm(''Deseja substituir o agendamento de Dias #DOCAMPO1# para Dias #DOCAMPO2#?'' )){document.getElementById(this.parentNode.parentNode.id+''#CAMPO#'').title = '''';document.getElementById(this.parentNode.parentNode.id+''#CAMPO#'').setAttribute(''data-default'', '''');document.getElementById(this.parentNode.parentNode.id+''#CAMPO#'').children[0].innerHTML = '''';#GRAVAR#} else {carregaTelasup(''etl_schedule_list'', ''prm_run_id='||prm_run_id||''', ''ETL'', ''etl_schedule'','''','''',''etl_run_list||ETL|etl_run|||'');}} else {#GRAVAR#}';
	ws_eventoGravar := 'requestDefault(''etl_schedule_update'', ''prm_schedule_id=#ID#&prm_cd_parametro=#CAMPO#&prm_conteudo=''+this.nextElementSibling.title,this,this.nextElementSibling.title,'''',''ETL'', ()=>{carregaTelasup(''etl_schedule_list'', ''prm_run_id='||prm_run_id||''', ''ETL'', ''etl_schedule'','''','''',''etl_run_list||ETL|etl_run|||'');});'; 

	htp.p('<input type="hidden" id="content-atributos" data-pkg="etl" >');
	htp.p('<input type="hidden" id="prm_run_id" value="'||prm_run_id||'">');	

	htp.p('<table class="linha">');

		htp.p('<thead>');
			htp.p('<tr>');
				HTP.P('<th>'||FUN.LANG('DIAS DA SEMANA')||'</th>');
                HTP.P('<th>'||FUN.LANG('DIAS DO M&Ecirc;S')||'</th>');
				HTP.P('<th>'||FUN.LANG('M&Ecirc;S')||'</th>');
				HTP.P('<th>'||FUN.LANG('HORA')||'</th>');
				HTP.P('<th>'||FUN.LANG('INTERVALO DE TEMPO')||'</th>');
                HTP.P('<th></th>');
			htp.p('</tr>');
		htp.p('</thead>');

		htp.p('<tbody id="ajax" >');

			for a in (select * from etl_schedule where run_id = prm_run_id order by schedule_id desc) loop

				htp.p('<tr id="'||a.schedule_id||'">');

					ws_desc := null;
					open  c_lista ('DIA_SEMANA', a.p_semana);
					fetch c_lista into ws_desc;
					close c_lista; 
					htp.p('<td>');
						htp.p('<a class="script" data-default="'||a.p_semana||'" onclick="'||replace(replace(replace(replace(ws_eventoVerificar, '#CAMPO#', '-dia_mes'), '#DOCAMPO1#', 'do M&ecirc;s'), '#DOCAMPO2#', 'da Semana'), '#GRAVAR#', replace(replace(ws_eventoGravar,'#CAMPO#','P_SEMANA'), '#ID#', a.schedule_id))||'"></a>');
						fcl.fakeoption(a.schedule_id||'-semanas', '', a.p_semana, 'lista-semanas', 'N', 'S', prm_desc => ws_desc );						
					htp.p('</td>');
					
                    ws_desc := null;
					open  c_lista ('DIA_MES', a.p_dia_mes);
					fetch c_lista into ws_desc;
					close c_lista; 
					htp.p('<td class="fake-list">');
						htp.p('<a class="script" data-default="'||a.p_dia_mes||'" onclick="'||replace(replace(replace(replace(ws_eventoVerificar, '#CAMPO#', '-semanas'), '#DOCAMPO1#', 'da Semana'), '#DOCAMPO2#', 'do M&ecirc;s'), '#GRAVAR#', replace(replace(ws_eventoGravar,'#CAMPO#','P_DIA_MES'), '#ID#', a.schedule_id))||'"></a>');
						fcl.fakeoption(a.schedule_id||'-dia_mes', '', a.p_dia_mes, 'lista-dia-mes', 'N', 'S', prm_desc => ws_desc);						
					htp.p('</td>');

					ws_desc := null;
					open  c_lista ('MES', a.p_mes);
					fetch c_lista into ws_desc;
					close c_lista; 
					htp.p('<td class="fake-list" >');
						htp.p('<a class="script" data-default="'||a.p_mes||'" onclick="'||replace(replace(ws_eventoGravar,'#CAMPO#','P_MES'), '#ID#', a.schedule_id)||'"></a>');
						fcl.fakeoption(a.schedule_id||'-mes', '', a.p_mes, 'lista-meses', 'N', 'S', prm_desc => ws_desc, prm_min => 1);
					htp.p('</td>');

					ws_desc := null;
					open  c_lista ('HORA', a.p_hora);
					fetch c_lista into ws_desc;
					close c_lista;
					htp.p('<td>');
						htp.p('<a class="script" data-default="'||a.p_hora||'" onclick="'||replace(replace(ws_eventoGravar,'#CAMPO#','P_HORA'), '#ID#', a.schedule_id)||'"></a>');
						fcl.fakeoption(a.schedule_id||'-horas', '', a.p_hora, 'lista-horas', 'N', 'S', prm_desc => ws_desc, prm_min => 1);
					htp.p('</td>');

					ws_desc := null;
					open  c_lista ('MINUTO', a.p_quarter);
					fetch c_lista into ws_desc;
					close c_lista; 
					htp.p('<td>');
						htp.p('<a class="script" data-default="'||a.p_quarter||'" onclick="'||replace(replace(ws_eventoGravar,'#CAMPO#','P_QUARTER'), '#ID#', a.schedule_id)||'"></a>');
						fcl.fakeoption(a.schedule_id||'-minutos', '', a.p_quarter, 'lista-minutos', 'N', 'S', prm_desc => ws_desc, prm_min => 1);
					htp.p('</td>');

					htp.p('<td>');
						fcl.button_lixo('etl_schedule_delete','prm_schedule_id', a.schedule_id, prm_tag => 'a', prm_pkg => 'ETL');
					htp.p('</td>');
				htp.p('</tr>');						
			end loop; 	
			
		htp.p('</tbody>');
	htp.p('</table>');	


end etl_schedule_list; 

----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_schedule_insert (prm_run_id        varchar2,
							   prm_p_semana      varchar2,
						   	   prm_p_mes         varchar2,
							   prm_p_hora        varchar2, 
						   	   prm_p_quarter     varchar2,
                               prm_p_dia_mes     varchar2) as 
	ws_schedule_id   number; 
	ws_count         integer; 
	ws_erro          varchar2(300); 
    ws_semana        varchar2(120);

	raise_erro  exception;
begin 

	select count(*) into ws_count from etl_run where run_id = prm_run_id ; 
	if ws_count = 0 then 
		ws_erro := 'N&atilde;o localizado Tarefa referente a esse agendamento, feche a tela e abra novamente';
		raise raise_erro;
	end if;

    if prm_p_semana is null and prm_p_dia_mes is null then
        ws_erro := 'Deve ser informado o Dia da Semana ou o Dia do M&ecirc;s!';
        raise raise_erro;
    elsif prm_p_semana is not null and prm_p_dia_mes is not null then
        ws_erro := 'Deve ser informado o Dia da Semana ou o Dia do M&ecirc;s!';
        raise raise_erro;
    end if;

    ws_semana := prm_p_semana;
    

	select nvl(max(to_number(schedule_id)),0)+1 into ws_schedule_id from etl_schedule; 

	insert into etl_schedule (run_id, schedule_id, p_semana, p_mes, p_hora, p_quarter, p_dia_mes )
	                  values (prm_run_id, ws_schedule_id, ws_semana, prm_p_mes, prm_p_hora, prm_p_quarter, prm_p_dia_mes );

	commit; 			  
	htp.p('OK|Registro inserido');

exception 
	when raise_erro then
		htp.p('ERRO|'||ws_erro);
	when others then 	
		ws_erro	:= 'Erro inserindo registro, verique o log de erros do sistema';
		htp.p('ERRO|'||ws_erro);
    	insert into bi_log_sistema values(sysdate, 'etl_schedule_insert (others) :'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getusuario, 'ERRO');
		commit;
end etl_schedule_insert; 


----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_schedule_update ( prm_schedule_id   varchar2, 
                           	    prm_cd_parametro  varchar2,
						   	    prm_conteudo      varchar2 ) as 
	ws_parametro varchar2(4000);
	ws_conteudo  varchar2(32000); 
    ws_semana    varchar2(4000) := null;
    ws_dia_mes   varchar2(4000) := null;
	ws_erro      varchar2(300); 
	raise_erro   exception;
    ws_teste     number;
begin 
	ws_parametro := upper(trim(prm_cd_parametro)); 
	ws_conteudo  := prm_conteudo; 

    if ws_conteudo is null and ws_parametro not in ('P_DIA_MES', 'P_SEMANA')then 
		ws_erro := 'Campo deve ser preenchido';
		raise raise_erro; 
    elsif ws_parametro = 'P_SEMANA' and ws_conteudo is not null then
        select count(1) into ws_teste
        from etl_schedule
        where schedule_id = prm_schedule_id
        and p_dia_mes is not null;
        if ws_teste > 0 then
            ws_dia_mes := null;
            ws_semana := ws_conteudo;
        end if;
    elsif ws_parametro = 'P_DIA_MES' and ws_conteudo is not null then
        select count(1) into ws_teste
        from etl_schedule
        where schedule_id = prm_schedule_id
        and p_semana is not null;
        if ws_teste > 0 then
            ws_semana := null;
            ws_dia_mes := ws_conteudo;
        end if;
    elsif ws_conteudo is null and ws_parametro = 'P_DIA_MES'then
        select count(1) into ws_teste
        from etl_schedule
        where schedule_id = prm_schedule_id
        and p_semana is null;
        if ws_teste > 0 then
            ws_erro := 'Deve ser informado o Dia da Semana ou o Dia do M&ecirc;s!';
            raise raise_erro;
        end if;
	elsif ws_conteudo is null and ws_parametro = 'P_SEMANA'then
        select count(1) into ws_teste
        from etl_schedule
        where schedule_id = prm_schedule_id
        and p_dia_mes is null;
        if ws_teste > 0 then
            ws_erro := 'Deve ser informado o Dia da Semana ou o Dia do M&ecirc;s!';
            raise raise_erro;
        end if;
    else
        select p_semana, p_dia_mes
          into ws_semana, ws_dia_mes
          from etl_schedule
         where schedule_id = prm_schedule_id;
    end if; 	

	update etl_schedule
	   set p_semana       = decode(ws_parametro, 'P_SEMANA',  ws_conteudo, ws_semana ), 
	       p_mes          = decode(ws_parametro, 'P_MES',     ws_conteudo, p_mes     ), 
		   p_hora         = decode(ws_parametro, 'P_HORA',    ws_conteudo, p_hora    ), 
		   p_quarter      = decode(ws_parametro, 'P_QUARTER', ws_conteudo, p_quarter ),
           p_dia_mes      = decode(ws_parametro, 'P_DIA_MES', ws_conteudo, ws_dia_mes)  
	 where schedule_id = prm_schedule_id; 
	if sql%notfound then 
		ws_erro := 'N&atilde;o localizado agendamento com esse ID, recarrega a tela e tente novamente'; 
		raise raise_erro; 
	end if;  	    

	commit; 
	htp.p('OK|Registro alterado');

exception 
	when raise_erro then 
		htp.p('ERRO|'||ws_erro);
	when others then 	
		ws_erro	:= 'Erro alterando registro, verique o log de erros do sistema';
		htp.p('ERRO|'||ws_erro);
    	insert into bi_log_sistema values(sysdate, 'etl_schedule_update (others) :'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getusuario, 'ERRO');
		commit;
end etl_schedule_update;



----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_schedule_delete (prm_schedule_id varchar2 ) as 
	ws_count    integer; 
	ws_erro     varchar2(300); 
	raise_erro  exception; 							   
begin 

	delete etl_schedule where schedule_id = prm_schedule_id ;

	commit;  
	htp.p('OK|Registro exclu&iacute;do');

exception 
	when raise_erro then 
		htp.p('ERRO|'||ws_erro);
	when others then 	
		ws_erro	:= 'Erro excluindo registro, verifique o log de erros do sistema.';
		htp.p('ERRO|'||ws_erro);
    	insert into bi_log_sistema values(sysdate, 'etl_schedule_delete (others) :'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getusuario, 'ERRO');
		commit;
end etl_schedule_delete; 


----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_run_step_list(prm_run_id     varchar2) as 

	ws_onkeypress_int  varchar2(1000); 
	ws_eventoGravar    varchar2(1000); 
	ws_evento          varchar2(1000); 
	ws_desc	           varchar2(400);  
	ws_id_conexao      varchar2(200);
	ws_tp_conexao      varchar2(200);

begin 
	ws_onkeypress_int := ' onkeypress="if(!input(event, ''integer'')) {event.preventDefault();} "';
	ws_eventoGravar   := ' "requestDefault(''etl_run_step_update'', ''prm_run_step_id=#ID#&prm_cd_parametro=#CAMPO#&prm_conteudo=''+#VALOR#,this,#VALOR#,'''',''ETL'');"'; 

	htp.p('<input type="hidden" id="content-atributos" data-refresh="etl_run_step_list" data-refresh-ativo="N" data-pkg="etl" data-par-col="prm_run_id" data-par-val="'||prm_run_id||'">');
	htp.p('<input type="hidden" id="prm_run_id" value="'||prm_run_id||'">');	

	htp.p('<table class="linha">');

		htp.p('<thead>');
			htp.p('<tr>');
				HTP.P('<th title="Ordem da execu&ccedil;&atilde;o da tarefa">'    ||FUN.LANG('ORDEM')||'</th>');
				HTP.P('<th title="A&ccedil;&atilde;o/tarefa executada.">'         ||FUN.LANG('A&Ccedil;&Otilde;ES')||'</th>');
				HTP.P('<th></th>');				
				HTP.P('<th title="A&ccedil;&otilde;es a serem concluidas antes.">'    ||FUN.LANG('DEPEND&Ecirc;NCIA')||'</th>');	
				HTP.P('<th title="O que fazer caso ocorra algum erro?" style="width: 85px;">'  ||FUN.LANG('CASO ERRO')||'</th>');
				HTP.P('<th title="Quantidade de tentativas caso ocorra erro na execu&ccedil;&atilde;o." style="width: 50px;">'  ||FUN.LANG('TENT.')||'</th>');
				HTP.P('<th style="min-width: 112px;" title="Inicio da &uacute;ltima execu&ccedil;&atilde;o.">'     ||FUN.LANG('INIC EXECU&Ccedil;&Atilde;O')||'</th>');
				HTP.P('<th style="min-width: 112px;" title="Fim da &uacute;ltima execu&ccedil;&atilde;o.">'        ||FUN.LANG('FIM EXECU&Ccedil;&Atilde;O')||'</th>');
				HTP.P('<th style="width: 100px; text-align: center;" title="Situa&ccedil;&atilde;o da &uacute;ltima execu&ccedil;&atilde;o.">'   ||FUN.LANG('SITUA&Ccedil;&Atilde;O')||'</th>');
				HTP.P('<th></th>');
				HTP.P('<th></th>');
				HTP.P('<th></th>');
				HTP.P('<th></th>');
			htp.p('</tr>');
		htp.p('</thead>');

		htp.p('<tbody id="ajax" >');

			for a in (select * from etl_run_step where run_id = prm_run_id order by ordem) loop

				ws_evento := replace(ws_eventoGravar,'#ID#',a.run_step_id); 

				htp.p('<tr id="'||a.run_step_id||'">');

					htp.p('<td style="width: 60px !important;"><input id="prm_ordem_'||a.run_step_id||'" style="min-width: 60px !important; width: 60px !important;" data-min="1" data-default="'||a.ordem||'" '||ws_onkeypress_int||' onblur='||replace(replace(ws_evento,'#CAMPO#','ORDEM'),'#VALOR#','this.value')||' value="'||a.ordem||'" /></td>');

					select max(id_conexao) into ws_id_conexao from etl_step where step_id = a.step_id; 
					begin ws_tp_conexao := etl.ret_conexao_param(ws_id_conexao,null,'DB'); exception when others then ws_tp_conexao := 'N/A'; end; 
					htp.p('<td class="fake-list" style="border-right: none; max-width: 170px !important;">');
						htp.p('<a class="script" data-default="'||a.step_id||'" onclick='||replace(replace(ws_evento,'#CAMPO#','STEP_ID'),'#VALOR#','this.nextElementSibling.title')||'></a>');
						fcl.fakeoption('prm_step_id_'||a.run_step_id, '', a.step_id, 'lista-etl-step', prm_editable=>'S', prm_multi=>'N', prm_desc => a.step_id, prm_min => 1, prm_class_adic => ' fakelist-border-right' );
					htp.p('</td>');

					htp.p('<td class="etl_atalho" title="Abre a tela de cadastro de A&ccedil;&otilde;es" style="width: 30px;"'||
							  ' onclick="carregaTelasup(''etl_step_list'', ''prm_step_id='||a.step_id||''', ''ETL'', '''','''','''',''etl_run_step_list|prm_run_id='||prm_run_id||'|ETL|etl_run_step|||'');">');
						htp.p('<svg style="height: 32px; width: 32px; float: left;" viewBox="0 0 24 24" clip-rule="evenodd" fill-rule="evenodd" stroke-linejoin="round" stroke-miterlimit="2" xmlns="http://www.w3.org/2000/svg"><path d="m21 4c0-.478-.379-1-1-1h-16c-.62 0-1 .519-1 1v16c0 .621.52 1 1 1h16c.478 0 1-.379 1-1zm-16.5.5h15v15h-15zm12.5 10.75c0-.414-.336-.75-.75-.75h-8.5c-.414 0-.75.336-.75.75s.336.75.75.75h8.5c.414 0 .75-.336.75-.75zm0-3.248c0-.414-.336-.75-.75-.75h-8.5c-.414 0-.75.336-.75.75s.336.75.75.75h8.5c.414 0 .75-.336.75-.75zm0-3.252c0-.414-.336-.75-.75-.75h-8.5c-.414 0-.75.336-.75.75s.336.75.75.75h8.5c.414 0 .75-.336.75-.75z" fill-rule="nonzero"/></svg>');
					htp.p('</td>');

					ws_desc := null;
					select listagg(rs.ordem||'-'||st.step_id, ';') within group (order by rs.ordem) into ws_desc 
				  	  from etl_step st, etl_run_step rs
				 	 where st.step_id = rs.step_id
				   	   and rs.run_step_id in (select column_value from table(fun.vpipe(a.dependence_id)) )
				   	   and rs.run_id = a.run_id ; 
					if ws_desc is null then 
						ws_desc := replace(a.dependence_id,'|',';'); 
					end if;
					htp.p('<td class="fake-list" style="max-width: 170px !important;">');
						htp.p('<a class="script" data-default="'||a.dependence_id||'" onclick='||replace(replace(ws_evento,'#CAMPO#','DEPENDENCE_ID'),'#VALOR#','this.nextElementSibling.title')||'></a>');
						fcl.fakeoption('prm_dependence_id_'||a.run_step_id, '', a.dependence_id, 'lista-etl-step-dependence', prm_editable=>'S', prm_multi=>'S', prm_desc => ws_desc, prm_min => 1, prm_adicional=> a.run_id||'|'||a.run_step_id, prm_class_adic => ' fakelist-border-left');
					htp.p('</td>');

					htp.p('<td>');
						htp.p('<select  id="caso_erro_'||a.run_step_id||'" onchange='||replace(replace(ws_evento,'#CAMPO#','CASE_ERRO'),'#VALOR#','this.value')||'>');
							for b in (select 'CONTINUAR' opc, 'Continuar'  dsc, decode(a.case_erro,'CONTINUAR', 'selected','') sel from dual union all 
									  select 'PARAR'     opc, 'Parar'      dsc, decode(a.case_erro,'PARAR',     'selected','') sel from dual) loop 
								htp.p('<option value="'||b.opc||'" '||b.sel||'>'||b.dsc||'</option>');
							end loop; 
						htp.p('</select>');
				    htp.p('</td>');

					htp.p('<td class="etl_qt_tent"><input id="prm_qt_tentativas_'||a.run_step_id||'" data-min="1" data-default="'||a.qt_tentativas||'" '||ws_onkeypress_int||' onblur='||replace(replace(ws_evento,'#CAMPO#','QT_TENTATIVAS'),'#VALOR#','this.value')||' value="'||a.qt_tentativas||'" /></td>');

					htp.p('<td><div>'||to_char(a.dh_inicio,'dd/mm/yy hh24:mi:ss')||'</div></td>');
					htp.p('<td><div>'||to_char(a.dh_fim,   'dd/mm/yy hh24:mi:ss')||'</div></td>');
					htp.p('<td class="etl_status">'||prn_a_status(a.last_status)||'</td>');
					htp.p('<td><div style="width: 1px !important; min-width: 1px !important;"></div></td>');

					if ws_tp_conexao = 'SSW' then   
						htp.p('<td style="width: 30px;"></td>');
					else 	
						htp.p('<td class="etl_atalho" title="Executar a tarefa manualmente uma &uacute;nica vez" '||
							  ' onclick="if(!confirm(''Confirma a execu\u00e7\u00e3o da \u00e7\u00e3o?'')){ return false; }  call(''etl_run_exec'', ''prm_run_id='||a.run_id||'&prm_run_step_id='||a.run_step_id||''', ''ETL'').then(function(resposta){ alerta('''',resposta.split(''|'')[1]); if (resposta.split(''|'')[0] == ''OK'') {ajax(''list'', ''etl_run_step_list'', ''prm_run_id='||prm_run_id||''', true, ''content'','''','''',''ETL''); } });">');
							htp.p('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M12 2c5.514 0 10 4.486 10 10s-4.486 10-10 10-10-4.486-10-10 4.486-10 10-10zm0-2c-6.627 0-12 5.373-12 12s5.373 12 12 12 12-5.373 12-12-5.373-12-12-12zm-3 17v-10l9 5.146-9 4.854z"/></svg>');
						htp.p('</td>');
					end if; 	

					htp.p('<td class="etl_atalho" title="Log de execu&ccedil;&otilde;o da a&ccedil;&atilde;o" '||
					      ' onclick="'||'carregaTelasup(''etl_log_list'', ''prm_tp=RUN_STEP&prm_id='||a.run_step_id||''', ''ETL'','''','''','''',''etl_run_step_list|prm_run_id='||prm_run_id||'|ETL|etl_run_step|||'');">');
						htp.p('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 600" xml:space="preserve"><g><path d="M486.201,196.124h-13.166V132.59c0-0.396-0.062-0.795-0.115-1.196c-0.021-2.523-0.825-5-2.552-6.963L364.657,3.677 c-0.033-0.031-0.064-0.042-0.085-0.073c-0.63-0.707-1.364-1.292-2.143-1.795c-0.229-0.157-0.461-0.286-0.702-0.421 c-0.672-0.366-1.387-0.671-2.121-0.892c-0.2-0.055-0.379-0.136-0.577-0.188C358.23,0.118,357.401,0,356.562,0H96.757 C84.894,0,75.256,9.651,75.256,21.502v174.613H62.092c-16.971,0-30.732,13.756-30.732,30.733v159.812 c0,16.968,13.761,30.731,30.732,30.731h13.164V526.79c0,11.854,9.638,21.501,21.501,21.501h354.776 c11.853,0,21.501-9.647,21.501-21.501V417.392h13.166c16.966,0,30.729-13.764,30.729-30.731V226.854 C516.93,209.872,503.167,196.124,486.201,196.124z M96.757,21.502h249.054v110.009c0,5.939,4.817,10.75,10.751,10.75h94.972v53.861 H96.757V21.502z M317.816,303.427c0,47.77-28.973,76.746-71.558,76.746c-43.234,0-68.531-32.641-68.531-74.152 c0-43.679,27.887-76.319,70.906-76.319C293.389,229.702,317.816,263.213,317.816,303.427z M82.153,377.79V232.085h33.073v118.039 h57.944v27.66H82.153V377.79z M451.534,520.962H96.757v-103.57h354.776V520.962z M461.176,371.092 c-10.162,3.454-29.402,8.209-48.641,8.209c-26.589,0-45.833-6.698-59.24-19.664c-13.396-12.535-20.75-31.568-20.529-52.967 c0.214-48.436,35.448-76.108,83.229-76.108c18.814,0,33.292,3.688,40.431,7.139l-6.92,26.37 c-7.999-3.457-17.942-6.268-33.942-6.268c-27.449,0-48.209,15.567-48.209,47.134c0,30.049,18.807,47.771,45.831,47.771 c7.564,0,13.623-0.852,16.21-2.152v-30.488h-22.478v-25.723h54.258V371.092L461.176,371.092z"></path><path d="M212.533,305.37c0,28.535,13.407,48.64,35.452,48.64c22.268,0,35.021-21.186,35.021-49.5 c0-26.153-12.539-48.655-35.237-48.655C225.504,255.854,212.533,277.047,212.533,305.37z"></path></g></svg>');
					htp.p('</td>');

					htp.p('<td>');
						fcl.button_lixo('etl_run_step_delete','prm_run_step_id', a.run_step_id, prm_tag => 'a', prm_pkg => 'ETL');
					htp.p('</td>');
				htp.p('</tr>');						
			end loop; 	
			
		htp.p('</tbody>');
	htp.p('</table>');	

exception when others then
   	insert into bi_log_sistema values(sysdate, 'etl_run_step_list :'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getusuario, 'ERRO');
	commit;
	Raise_Application_Error (-20101, 'Erro etl_run_step_list');	
end etl_run_step_list; 


----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_run_step_insert (prm_run_id        varchar2,
                               prm_ordem         varchar2,
						       prm_step_id       varchar2) as 
	ws_run_step_id   number; 
	ws_count         integer; 
	ws_erro          varchar2(300); 
	raise_erro       exception;
begin 

	select count(*) into ws_count from etl_run_step where run_id = prm_run_id and ordem = prm_ordem; 
	if ws_count > 0 then 
		ws_erro := 'J&aacute; existe uma a&ccedil;&atilde;o cadastrada com essa ordem, informe outro valor para o campo ORDEM EXECU&Ccedil;&Atilde;O'; 
		raise raise_erro;
	end if; 	

	select nvl(max(to_number(run_step_id)),0)+1 into ws_run_step_id from etl_run_step; 

	insert into etl_run_step (run_step_id, ordem, run_id, step_id, qt_tentativas)
	                  values (ws_run_step_id, prm_ordem, prm_run_id, prm_step_id, 1);

	commit; 			  
	htp.p('OK|Registro inserido');

exception 
	when raise_erro then 
		htp.p('ERRO|'||ws_erro);
	when others then 	
		ws_erro	:= 'Erro inserindo registro, verique o log de erros do sistema';
		htp.p('ERRO|'||ws_erro);
    	insert into bi_log_sistema values(sysdate, 'etl_run_step_insert (others) :'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getusuario, 'ERRO');
		commit;
end etl_run_step_insert; 



----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_run_step_update ( prm_run_step_id   varchar2, 
                           	    prm_cd_parametro  varchar2,
						   	    prm_conteudo      varchar2 ) as 
	ws_parametro varchar2(4000);
	ws_conteudo  varchar2(32000); 
	ws_run_id    varchar2(30); 
	ws_erro      varchar2(300); 
	ws_count     integer; 
	raise_erro   exception;
begin 
	ws_parametro := upper(trim(prm_cd_parametro)); 
	ws_conteudo  := prm_conteudo; 

    if ws_conteudo is null then 
		ws_erro := 'Campo deve ser preenchido';
		raise raise_erro; 
	end if; 	

	-- Não permite alterar a ordem se já estiver outra ação com essa ordem 
	if prm_cd_parametro = 'ORDEM' then 
		select run_id  into ws_run_id from etl_run_step where run_step_id = prm_run_step_id; 
		select count(*) into ws_count from etl_run_step where run_id = ws_run_id and ordem = prm_conteudo and run_step_id <> prm_run_step_id; 
		if ws_count > 0 then 
			ws_erro := 'J&aacute; existe uma a&ccedil;&atilde;o cadastrada com essa ordem, informe outro valor para o campo ORDEM'; 
			raise raise_erro;
		end if; 	
	end if; 

	if prm_cd_parametro = 'QT_TENTATIVAS' then 
		if ws_conteudo < 1 or ws_conteudo > 10 then 
			ws_erro := 'Quantidade de tentativas deve estar entre 1 e 10.'; 
			raise raise_erro;
		end if; 	
	end if; 

	update etl_run_step
	   set ordem         = decode(ws_parametro, 'ORDEM',         ws_conteudo, ordem),
	       step_id       = decode(ws_parametro, 'STEP_ID',       ws_conteudo, step_id),
		   case_erro     = decode(ws_parametro, 'CASE_ERRO',     ws_conteudo, case_erro),
		   dependence_id = decode(ws_parametro, 'DEPENDENCE_ID', ws_conteudo, dependence_id),
		   qt_tentativas = decode(ws_parametro, 'QT_TENTATIVAS', ws_conteudo, qt_tentativas)
	 where run_step_id = prm_run_step_id;
	if sql%notfound then 
		ws_erro := 'N&atilde;o localizado tarefa para atualiza&ccedil;&atilde;o, recarrega a tela e tente novamente'; 
		raise raise_erro; 
	end if;

	commit; 
	htp.p('OK|Registro alterado');

exception 
	when raise_erro then 
		htp.p('ERRO|'||ws_erro);
	when others then 	
		ws_erro	:= 'Erro alterando registro, verique o log de erros do sistema';
		htp.p('ERRO|'||ws_erro);
    	insert into bi_log_sistema values(sysdate, 'etl_run_step_update (others) :'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getusuario, 'ERRO');
		commit;
end etl_run_step_update;



----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_run_step_delete (prm_run_step_id varchar2 ) as 
	ws_erro     varchar2(300); 
begin 

	delete etl_run_step where run_step_id = prm_run_step_id ;

	commit;  
	htp.p('OK|Registro exclu&iacute;do');

exception 
	when others then 	
		ws_erro	:= 'Erro excluindo registro, verifique o log de erros do sistema.';
		htp.p('ERRO|'||ws_erro);
    	insert into bi_log_sistema values(sysdate, 'etl_run_step_delete (others) :'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getusuario, 'ERRO');
		commit;
end etl_run_step_delete; 



----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_step_param_list(prm_step_id     varchar2) as 
	ws_eventoGravar  varchar2(300); 
	ws_evento        varchar2(300); 
	ws_checked       varchar2(20); 	
begin 

	ws_eventoGravar := '"requestDefault(''etl_step_param_update'', ''prm_step_id=#ID#&prm_cd_parametro=#PAR#&prm_campo=#CAMPO#&prm_conteudo=''+#VALOR#,this,#VALOR#,'''',''ETL''); "'; 

	htp.p('<input type="hidden" id="content-atributos" data-pkg="etl" data-par-col="" data-par-val="">');
	htp.p('<input type="hidden" id="prm_step_id" value="'||prm_step_id||'">');	

	htp.p('<table class="linha">');
		htp.p('<thead>');
			htp.p('<tr>');
				HTP.P('<th title="Nome/identificador do par&acirc;metro">'                           ||FUN.LANG('NOME/ID PAR&Acirc;METRO')||'</th>');
				HTP.P('<th title="Descri&ccedil;&atilde;o do par&acirc;metro">'                      ||FUN.LANG('DESCRI&Ccedil;&Atilde;O PAR&Acirc;METRO')||'</th>');
				HTP.P('<th title="Colocar conte&uacute;do entre aspas" style="text-align: center;">' ||FUN.LANG('ENTRE ASPAS')||'</th>');
				HTP.P('<th></th>');
				HTP.P('<th></th>');
			htp.p('</tr>');
		htp.p('</thead>');

		htp.p('<tbody id="ajax" >');
			for a in (select step_id, cd_parametro, ds_parametro, nvl(id_entreaspas,'S') id_entreaspas  
			            from etl_step_param 
					   where step_id = prm_step_id 
					   order by cd_parametro ) loop

				ws_evento := replace(replace(ws_eventoGravar,'#ID#', a.step_id),'#PAR#', a.cd_parametro); 
				ws_checked := null; 
				if nvl(a.id_entreaspas,'S') = 'S' then 
					ws_checked := ' checked ';
				end if; 	
				htp.p('<tr id="'||a.step_id||'">');
					htp.p('<td><div>'||a.cd_parametro||'</div></td>');
					htp.p('<td><input id="prm_ds_parametro_'||a.cd_parametro||'"  data-min="1" data-default="'||a.ds_parametro||'"  value="'||a.ds_parametro||'" onblur='||replace(replace(ws_evento,'#CAMPO#','DS_PARAMETRO'),'#VALOR#','this.value')||' /></td>');
					htp.p('<td><input id="prm_id_entreaspas_'||a.cd_parametro||'" data-min="1" value="'||a.id_entreaspas||'" type="checkbox" '||ws_checked||' onchange='||replace(replace(ws_evento,'#CAMPO#','ID_ENTREASPAS'),'#VALOR#','((this.checked)?''S'':''N'')')||' /></td>');					
					htp.p('<td><div style="width: 1px !important; min-width: 1px !important;"></div></td>');
					htp.p('<td>');
						fcl.button_lixo('etl_step_param_delete','prm_step_id|prm_cd_parametro', a.step_id||'|'||a.cd_parametro, prm_tag => 'a', prm_pkg => 'ETL');
					htp.p('</td>');
				htp.p('</tr>');						
			end loop; 	
		htp.p('</tbody>');
	htp.p('</table>');	

end etl_step_param_list; 



----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_step_param_insert (prm_step_id        varchar2,
                         	     prm_cd_parametro   varchar2,
								 prm_ds_parametro   varchar2 ) as 
	ws_cd_parametro  varchar2(100); 
	ws_run_id   number; 
	ws_count    integer; 
	ws_erro     varchar2(300); 
	raise_erro  exception;
begin 

	ws_cd_parametro := upper(trim(prm_cd_parametro)); 

	if instr(ws_cd_parametro,' ') > 0 then 
		ws_erro := 'NOME/ID do par&acirc;metro n&atilde;o pode conter espa&ccedil;os'; 
		raise raise_erro;
	end if; 	

	select count(*) into ws_count from etl_step_param where step_id = prm_step_id and cd_parametro = ws_cd_parametro; 
	if ws_count > 0 then 
		ws_erro := 'J&aacute; existe um par&acirc;metro cadastrado com esse NOME/ID'; 
		raise raise_erro;
	end if; 	

	insert into etl_step_param (step_id,     cd_parametro,    ds_parametro,     id_entreaspas)
	                    values (prm_step_id, ws_cd_parametro, prm_ds_parametro, 'S');

	commit; 			  
	htp.p('OK|Registro inserido');

exception 
	when raise_erro then 
		htp.p('ERRO|'||ws_erro);
	when others then 	
		ws_erro	:= 'Erro inserindo registro, verique o log de erros do sistema';
		htp.p('ERRO|'||ws_erro);
    	insert into bi_log_sistema values(sysdate, 'etl_step_param_insert (others) :'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getusuario, 'ERRO');
		commit;
end etl_step_param_insert; 


----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_step_param_update ( prm_step_id       varchar2, 
                            	  prm_cd_parametro  varchar2,
								  prm_campo         varchar2, 
						   	      prm_conteudo      varchar2 ) as 
	ws_campo     varchar2(4000);
	ws_conteudo  varchar2(32000); 
	ws_erro      varchar2(300); 
	raise_erro   exception;
begin 
	ws_campo     := upper(trim(prm_campo)); 
	ws_conteudo  := prm_conteudo; 

	update etl_step_param
	   set ds_parametro  = decode(ws_campo, 'DS_PARAMETRO',   ws_conteudo, ds_parametro),
	   	   id_entreaspas = decode(ws_campo, 'ID_ENTREASPAS',  ws_conteudo, id_entreaspas)
	 where cd_parametro = prm_cd_parametro 
	   and step_id      = prm_step_id;
	if sql%notfound then 
		ws_erro := 'N&atilde;o localizado par&acirc;metro para atualiza&ccedil;&atilde;o, recarrega a tela e tente novamente'; 
		raise raise_erro; 
	end if;

	commit; 
	htp.p('OK|Registro alterado');

exception 
	when raise_erro then 
		htp.p('ERRO|'||ws_erro);
	when others then 	
		ws_erro	:= 'Erro alterando registro, verique o log de erros do sistema';
		htp.p('ERRO|'||ws_erro);
    	insert into bi_log_sistema values(sysdate, 'etl_step_param_update (others) :'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getusuario, 'ERRO');
		commit;
end etl_step_param_update;

----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_step_param_delete (prm_step_id      varchar2,
                                 prm_cd_parametro varchar2) as 
	ws_count        integer; 
	ws_erro         varchar2(300); 
	ws_raise_erro   exception; 
begin 

	select count(*) into ws_count 
	 from etl_step 
	where step_id = prm_step_id 
	  and ( instr( upper(comando), '$['||prm_cd_parametro||']' ) + instr( upper(comando_limpar), '$['||prm_cd_parametro||']'))  > 0 ; 
	if ws_count > 0 then 
		ws_erro := 'Comando da a&ccedil;&atilde;o utiliza esse par&acirc;metro, primeiro altere o comando retirando o par&acirc;metro'; 
		raise ws_raise_erro; 
	end if; 

	delete etl_step_param where step_id = prm_step_id and cd_parametro = prm_cd_parametro ;
	commit;  
	htp.p('OK|Registro exclu&iacute;do');

exception 
	when ws_raise_erro then 	
		htp.p('ERRO|'||ws_erro);
	when others then 	
		ws_erro	:= 'Erro excluindo registro, verique o log de erros do sistema';
		htp.p('ERRO|'||ws_erro);
    	insert into bi_log_sistema values(sysdate, 'etl_step_param_delete (others) :'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getusuario, 'ERRO');
		commit;
end etl_step_param_delete; 



----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_run_param_list(prm_run_id     varchar2) as 
	ws_ds_parametro varchar2(200); 
	ws_checked      varchar2(20); 
	ws_evento       varchar2(2000);
	ws_eventoGravar varchar2(2000);
	ws_conteudo     etl_run_param.conteudo%type; 
begin 

	-- Atualiza os parametros da tarefa, caso tenha sido adicionado algum novo parametro nas ações - já tem commit na procedure 
	etf.etl_run_param_atu(prm_run_id); 

	ws_eventoGravar := '"requestDefault(''etl_run_param_update'', ''prm_run_id=#ID#&prm_cd_parametro=#PAR#&prm_campo=#CAMPO#&prm_conteudo=''+#VALOR#,this,#VALOR#,'''',''ETL''); "'; 

	ws_eventoGravar := '"requestDefault(''etl_run_param_update'', ''prm_run_id=#ID#&prm_cd_parametro=#PAR#&prm_campo=#CAMPO#&prm_conteudo=''+#VALOR#,this,#VALOR#,'''',''ETL''); "'; 

	htp.p('<input type="hidden" id="content-atributos" data-pkg="etl" data-par-col="prm_run_id" data-par-val="'||prm_run_id||'">');
	htp.p('<input type="hidden" id="prm_run_id" value="'||prm_run_id||'">');	

	htp.p('<h2>PAR&Acirc;METROS EXECU&Ccedil;&Atilde;O</h2>');

	htp.p('<table class="linha">');
		htp.p('<thead>');
			htp.p('<tr>');
				HTP.P('<th title="Nome par&acirc;metro.">'                                              ||FUN.LANG('NOME/ID PAR&Acirc;METRO')||'</th>');
				HTP.P('<th title="Coloca o conte&uacute;do entre aspas." style="text-align: center;">'  ||FUN.LANG('ENTRE ASPAS')||'</th>');
				HTP.P('<th title="Conte&uacute;do/valor do par&acirc;metro.">'                          ||FUN.LANG('CONTE&Uacute;DO / VALOR')||'</th>');
			htp.p('</tr>');
		htp.p('</thead>');

		htp.p('<tbody id="ajax" >');
			for a in (select run_id, cd_parametro, conteudo, id_entreaspas, decode(nvl(id_entreaspas,'N'),'S','checked','') checked
			            from etl_run_param 
					   where run_id   = prm_run_id 
					     and st_ativo = 'S' 
			           order by decode(cd_parametro,'MINUTO_ESPERA',1, 'MINUTO_ESPERA_PLSQL',2,3), cd_parametro ) loop
				
				ws_evento := replace(replace(ws_eventoGravar,'#ID#', a.run_id),'#PAR#', a.cd_parametro); 
				ws_conteudo := replace(a.conteudo,'"', '&#34;');
				htp.p('<tr id="'||a.run_id||'">');
					htp.p('<td class="etl_cd_parametro"><div title="'||a.cd_parametro||'">'||a.cd_parametro||'</div></td>');
					htp.p('<td class="etl_entreaspas">  <div><input id="prm_id_entreaspas_'||a.cd_parametro||'" data-min="1" value="'||a.id_entreaspas||'" type="checkbox" '||a.checked||' onchange='||replace(replace(ws_evento,'#CAMPO#','ID_ENTREASPAS'),'#VALOR#','((this.checked)?''S'':''N'')')||' /></div></td>');					
					htp.p('<td><input id="prm_conteudo_'||a.run_id||'" style="border: none;" data-min="1" data-default="'||ws_conteudo||'" value="'||ws_conteudo||'" '||
						  'onblur='||replace(replace(ws_evento,'#CAMPO#','CONTEUDO'),'#VALOR#','this.value')||' /></td>');
				htp.p('</tr>');						
			end loop; 	
		htp.p('</tbody>');
	htp.p('</table>');	

end etl_run_param_list; 



----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_run_param_update ( prm_run_id        varchar2, 
                           	     prm_cd_parametro  varchar2,
								 prm_campo         varchar2, 
						   	     prm_conteudo      varchar2 ) as 
	ws_parametro varchar2(4000);
	ws_conteudo  varchar2(32000); 
	ws_run_id    varchar2(30); 
	ws_erro      varchar2(300); 
	ws_nr_aux    integer; 
	raise_erro   exception;
begin 
	ws_parametro := upper(trim(prm_cd_parametro)); 
	ws_conteudo  := prm_conteudo; 

    if ws_conteudo is null then 
		ws_erro := 'Campo deve ser preenchido';
		raise raise_erro; 
	end if; 	
	
	if ws_parametro in ('MINUTO_ESPERA','MINUTO_ESPERA_PLSQL') then 
		ws_erro := null;
		begin 
			ws_nr_aux := ws_conteudo;
			if ws_nr_aux <= 0 then 
				ws_erro := 'Conte&uacute;do inv&aacute;lido, conte&uacute;do deve ser um n&uacute;mero inteiro maior que zero';		
			end if; 	
		exception when others then 
			ws_erro := 'Conte&uacute;do inv&aacute;lido, conte&uacute;do deve ser um n&uacute;mero inteiro';		
		end; 	
		if ws_erro is not null then 
			raise raise_erro;
		end if; 	
	end if; 


	update etl_run_param 
	   set id_entreaspas = decode(prm_campo,'ID_ENTREASPAS',ws_conteudo,id_entreaspas), 
	       conteudo      = decode(prm_campo,'CONTEUDO'     ,ws_conteudo,conteudo) 
	 where cd_parametro  = ws_parametro 
	   and run_id        = prm_run_id;
	if sql%notfound then 
		ws_erro := 'Par&acirc;metro n&atilde;o localizado para atualiza&ccedil;&atilde;o'; 
		raise raise_erro; 
	end if;

	commit; 
	htp.p('OK|Registro alterado');

exception 
	when raise_erro then 
		htp.p('ERRO|'||ws_erro);
	when others then 	
		ws_erro	:= 'Erro alterando registro, verique o log de erros do sistema';
		htp.p('ERRO|'||ws_erro);
    	insert into bi_log_sistema values(sysdate, 'etl_run_param_update (others) :'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getusuario, 'ERRO');
		commit;
end etl_run_param_update;




----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_log_list(prm_tp       varchar2,
                       prm_id       varchar2,
					   prm_linhas	varchar2 default '50') as 
	cursor c1 is  
	   select run_id, run_step_id, log_id, tp_log, ds_log, decode(step_id,'0',null,step_id) as step_id, dh_inicio, dh_fim, status, sq_log, 
	          decode(ordem,'0',null,ordem) as ordem
       from (select *
             from etl_log 
             where (( prm_tp = 'RUN'      and run_id      = prm_id) or 
                   ( prm_tp = 'RUN_STEP' and run_step_id = prm_id and run_step_id is not null) or 
                   ( prm_tp = 'STEP'     and step_id     = prm_id and step_id     is not null))
             order by log_id desc, sq_log, ordem)
        where rownum <= CASE WHEN prm_linhas = 'TODAS' THEN 999999 ELSE TO_NUMBER(prm_linhas) END;

	ws_ds_run       varchar2(300); 	
	ws_style_linha  varchar2(50); 
	ws_style_bg     varchar2(50); 
	ws_log_ante     varchar2(50);
	ws_tp_log       varchar2(100);
	ws_ds_log       clob; 
	ws_dados_ret    clob; 
	ws_svg_dados    varchar2(4000); 
begin
	ws_svg_dados := fun.ret_svg('data_download'); 

	htp.p('<div id="searchbar" data-stop="S">');
		htp.p('<label>Filtrar linhas</label>');
		htp.p('<select id="searchbar" onchange="carregaTelasup(''etl_log_list'', ''prm_tp='||prm_tp||'&prm_id='||prm_id||'&prm_linhas=''+this.value, ''ETL'', ''none'','''','''',''etl_step_list|prm_step_id='||prm_id||'|ETL|etl_step|||'');">');
			if prm_linhas = '50' then
				htp.p('<option selected value="50">50 linhas</option>');
			else
				htp.p('<option value="50">50 linhas</option>');
			end if;
			if prm_linhas = '100' then
				htp.p('<option selected value="100">100 linhas</option>');
			else
				htp.p('<option value="100">100 linhas</option>');
			end if;
			if prm_linhas = '250' then
				htp.p('<option selected value="250">250 linhas</option>');
			else
				htp.p('<option value="250">250 linhas</option>');
			end if;
			if prm_linhas = '500' then
				htp.p('<option selected value="500">500 linhas</option>');
			else
				htp.p('<option value="500">500 linhas</option>');
			end if;
			if prm_linhas = 'TODAS' then
				htp.p('<option selected value="TODAS">todas</option>');
			else
				htp.p('<option value="TODAS">todas</option>');
			end if;			
		htp.p('</select>');

	htp.p('</div>');

	htp.p('<input type="hidden" id="content-atributos" data-refresh="etl_log_list" data-refresh-ativo="S" data-pkg="etl" data-par-col="prm_tp|prm_id|prm_linhas" data-par-val="'||prm_tp||'|'||prm_id||'|'||prm_linhas||'">');

	htp.p('<h2>LOG EXECU&Ccedil;&Otilde;ES</h2>');

	htp.p('<table class="linha">');

		htp.p('<thead>');
			htp.p('<tr>');
				HTP.P('<th title="Tarefa executada">' 								 ||FUN.LANG('TAREFA')||'</th>');
				HTP.P('<th title="Tipo de LOG">' 			        				 ||FUN.LANG('TIPO')||'</th>');
				HTP.P('<th title="Ordem da a&ccedil;&atilde;o na tarefa">'           ||FUN.LANG('ORDEM')||'</th>');				
				HTP.P('<th title="A&ccedil;&atilde;o executada">'                    ||FUN.LANG('A&Ccedil;&Atilde;O')||'</th>');
				HTP.P('<th title="Inicio da a&ccedil;&atilde;o">'                    ||FUN.LANG('INICIO')||'</th>');
				HTP.P('<th title="Fim da a&ccedil;&atilde;o">'                       ||FUN.LANG('FIM')||'</th>');
				HTP.P('<th title="Situa&ccedil;&atilde;o da a&ccedil;&atilde;o">'    ||FUN.LANG('SITUA&Ccedil;&Atilde;O')||'</th>');
				HTP.P('<th title="Descri&ccedil;&atilde;o Erro">'                    ||FUN.LANG('RETORNO EXECU&Ccedil;&Atilde;O')||'</th>');
				HTP.P('<th></th>');
			htp.p('</tr>');
		htp.p('</thead>');

		htp.p('<tbody id="ajax" >');

			ws_log_ante := 'N/A';
			for a in c1 loop

				if    a.tp_log = 'RUN'      then   ws_tp_log := 'TAREFA';
				elsif a.tp_log = 'RUN_STEP' then   ws_tp_log := 'ACAO';
				else                               ws_tp_log := a.sq_log;
				end if; 

				if ws_log_ante <> a.log_id then 
					if ws_style_bg is null then 
						ws_style_bg := ' background-color: #ecf5fd; ';
					else 	
						ws_style_bg := null;
					end if; 
					ws_log_ante := a.log_id; 
				end if; 		

				ws_style_linha := ''; 
				if a.tp_log = 'TAREFA' then 
					ws_style_linha := 'font-weight: bolder;'; 
				end if;
				
				ws_ds_log := replace(fun.html_trans(a.ds_log),chr(10),'<br>');

				htp.p('<tr style="'||ws_style_bg||'">');

					ws_ds_run    := null;
					ws_dados_ret := null;
					select max(nvl(ds_run,run_id)) into ws_ds_run    from etl_run where run_id = a.run_id ;
					begin 
						select dados_retorno into ws_dados_ret 
						  from etl_fila 
						 where log_id      = a.log_id 
						   and run_step_id = a.run_step_id
						   and rownum      = 1; 
					exception when others then
						null;
					end;
					if ws_dados_ret	is not null then 
						if length(ws_dados_ret) > 15000 then 
							ws_dados_ret := substr(ws_dados_ret,1,8000)||chr(10)||' ... '||chr(10)||substr(ws_dados_ret,length(ws_dados_ret)-7000,7000)||chr(10);
						else 	
							ws_dados_ret := ws_dados_ret;
						end if; 	
						ws_dados_ret := replace(fun.html_trans(ws_dados_ret),chr(10),'<br>');
					end if; 

					htp.p('<td class="etl_col_ds_tarefa" style="width: 130px;">   <input disabled title="'||ws_ds_run||'" value="'||ws_ds_run||'"/></td>');					
					htp.p('<td class="etl_col_tipo">                              <input disabled title="'||ws_tp_log||'" value="'||ws_tp_log||'"/></td>');
					htp.p('<td class="etl_col_ordem">                             <input disabled title="'||a.ordem  ||'" value="'||a.ordem||'"/></td>');
					htp.p('<td class="etl_col_ds_acao" style="width: 130px;">     <input disabled title="'||a.step_id||'" value="'||a.step_id||'"/></td>');					
					htp.p('<td class="etl_col_dh">                                <input disabled title="'||to_char(a.dh_inicio,'dd/mm/yyyy hh24:mi:ss')||'" value="'||to_char(a.dh_inicio,'dd/mm/yyyy hh24:mi:ss')||'"/></td>');
					htp.p('<td class="etl_col_dh">                                <input disabled title="'||to_char(a.dh_fim,'dd/mm/yyyy hh24:mi:ss')||'" value="'||to_char(a.dh_fim,'dd/mm/yyyy hh24:mi:ss')||'"/></td>');
					htp.p('<td class="etl_status">'||prn_a_status(a.status)||'</td>');
					htp.p('<td>'); 
						htp.p('<input class="zoom_column" readonly value="'||ws_ds_log||'" onclick="modal_txt_sup(event,this.value);"/>'); 
					htp.p('</td>');
					if ws_dados_ret is null then 
						htp.p('<td></td>'); 
					else 	
						htp.p('<td class="etl_atalho" title="Dados retornados na integra&ccedil;&atilde;o" style="width: 30px;" onclick="modal_txt_sup(event,this.children[0].value,''top-center'');">');
							htp.p('<input type="hidden" value="'||ws_dados_ret||'" />');
							htp.p(ws_svg_dados);
						htp.p('</td>');
					end if;
				htp.p('</tr>');						
			end loop; 	
			
		htp.p('</tbody>');
	htp.p('</table>');	
	
	htp.p('<div id="modal-txt" class="modal-txt"></div>');
end etl_log_list;  


----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_run_exec (prm_run_id      varchar2,
                        prm_run_step_id varchar2 default null) as
	ws_count      number;
	ws_raise_erro exception; 
	ws_erro       varchar2(200); 

begin

	select count(*) into ws_count 
	  from etl_run      
	 where run_id = prm_run_id
	   and last_status in ('AGUARDANDO','EXECUTANDO') ;

	if ws_count = 0 then 
	    select count(*) into ws_count 
	      from etl_run_step
	     where run_id = prm_run_id
		   and run_step_id = nvl(prm_run_step_id, run_step_id)
	       and last_status in ('AGUARDANDO','EXECUTANDO') ;  
		if ws_count > 0 and prm_run_step_id is not null then  
			ws_erro := 'A&ccedil;&atilde;o j&aacute; est&aacute; em execu&ccedil;&atilde;o, reatualize a tela ou verifique o log da tarefa';
			raise ws_raise_erro;
		end if; 	
	end if; 
	if ws_count > 0 then  
		ws_erro := 'Tarefa j&aacute; est&aacute; em execu&ccedil;&atilde;o, reatualize a tela ou verifique o log da tarefa';
		raise ws_raise_erro;
	end if; 	

   	select count(*) into ws_count 
      from etl_run_step
     where run_id = prm_run_id ; 

	if ws_count = 0 then  
		ws_erro := 'Tarefa n&atilde;o possui a&ccedil;&otilde;es cadastradas';
		raise ws_raise_erro;
	end if; 	 

	etf.exec_run(prm_run_id, prm_run_step_id);

	htp.p('OK|Tarefa iniciada com sucesso, acompanhe a execu&ccedil;&atilde;o pelo log'); 
exception 
	when ws_raise_erro then
		htp.p('ERRO|'||ws_erro); 
	when others then
		ws_erro := 'Erro iniciando Tarefa, verifique o log de erros do sistema';
		htp.p('ERRO|'||ws_erro); 
		insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values (sysdate , 'etl_run_exec('||prm_run_id||') erro: '||substr(dbms_utility.format_error_stack||'-'||dbms_utility.format_error_backtrace,1,3900) , gbl.getUsuario, 'ERRO');
        commit; 
end etl_run_exec; 



----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_run_stop (prm_run_id varchar2) as
	ws_count      number;
	ws_qt_run     number;   
	ws_qt_step    number;   
	ws_raise_erro exception; 
	ws_retorno   varchar2(1000); 
	ws_usuario    varchar2(100);

begin
	ws_retorno := null; 

	etf.stop_run (prm_run_id, ws_retorno);

	if ws_retorno is not null then 
		htp.p('ERRO|'||ws_retorno); 
	else 		
		htp.p('OK|Execu&ccedil;&atilde;o cancelada com sucesso'); 
	end if; 	

exception when others then
	ws_retorno := 'Erro cancelando execu&ccedil;&atilde;o da Tarefa, verifique o log de erros do sistema';
	htp.p('ERRO|'||ws_retorno); 
	insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values (sysdate , 'etl_run_exec('||prm_run_id||') erro: '||substr(dbms_utility.format_error_stack||'-'||dbms_utility.format_error_backtrace,1,3900) , gbl.getUsuario, 'ERRO');
    commit; 
end etl_run_stop; 



----------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_step_comando ( prm_step_id  varchar2, 
                             prm_coluna   varchar2) as 
	cursor c_param is 
		select t1.* 
		  from etl_tipo_conexao t1, etl_conexoes t2, etl_step t3
		 where t1.tp_conexao   = t2.conteudo		 		 
	   	   and t1.tp_parametro = 'COMANDO'
		   and t1.tp_execucao   = t3.tipo_execucao 
	   	   and t2.id_conexao   = t3.id_conexao 
	       and t2.cd_parametro = 'DB'
	       and t3.step_id      = prm_step_id
		order by t1.ordem_tela  ;

	ws_param          c_param%rowtype; 
	ws_tem_param      varchar2(1); 
    ws_comando        clob;
	ws_comando_parte  clob;
	ws_titulo         varchar2(100);
	ws_title          varchar2(4000); 
	ws_erro           varchar2(200); 
	ws_onkeypress     varchar2(1000); 
	ws_htp_param      varchar2(32000); 
	ws_htp_salvar     varchar2(32000); 
	ws_htp_fechar     varchar2(1000); 
	ws_ds_parametro   varchar2(30000); 
	ws_qtd_li         integer;  
	ws_raise_erro     exception; 
begin

	begin 
		select decode(prm_coluna, 'COMANDO',comando, 'COMANDO_LIMPAR', comando_limpar) into ws_comando    
	  	  from etl_step 
	     where step_id = prm_step_id;
	exception when others then 
		ws_erro := 'Erro obtendo comando, fecha a tela e abra novamente.';
		raise ws_raise_erro;	 
	end; 	

	if prm_coluna = 'COMANDO_LIMPAR' then 
		ws_titulo := 'COMANDO LIMPEZA';
		ws_title  := 'Informe o comando a ser executado.'||chr(10)||'Informe $[PARAMETRO] para fazer refer&ecirc;ncia a par&acirc;metros da Tarefa.'||chr(10)||'Informe :[n,n] para fazer refer&ecirc;ncia a linhas e colunas no caso de importa&ccedil;&atilde;o de arquivos.';
	else 
		ws_titulo := prm_coluna;
		ws_title  := 'Informe o comando a ser executado.';
	end if;	
	
	ws_tem_param := 'N';	
	if upper(prm_coluna) = 'COMANDO' then 
		open c_param;
		fetch c_param into ws_param; 
		if c_param%found then 
			ws_tem_param := 'S';
		end if; 	
		close c_param; 
	end if;

	ws_onkeypress     := ' onkeypress="if(!input(event, ''nopipe'')) {event.preventDefault();} else {proxCampo(event,this);}"'; 
	ws_htp_fechar     := '<a class="addpurple" onclick="document.getElementById(''modal'||prm_step_id||''').classList.remove(''expanded''); setTimeout(function(){ document.getElementById(''modal'||prm_step_id||''').remove(); }, 200);">FECHAR</a>'; 

   	htp.p('<div class="modal" style="overflow: auto;" id="modal'||prm_step_id||'">');
       	htp.p('<h2 style="font-family: var(--fonte-secundaria); font-size: 20px; margin: 10px 5px 5px; padding: 10px 0px 5px 0px;">'||ws_titulo||'</h2>');

		if ws_tem_param = 'N' then 		
			htp.p('<div id="modal-input-text" style="overflow: auto;" class="ace_editor ace-tm" contenteditable="true" title="'||ws_title||'" onkeypress="var tamanho = this.innerHTML.toString().length; if(tamanho > 32000){ event.preventDefault(); return false;  };">'||ws_comando||'</div>');
			ws_htp_salvar := '<a class="addpurple" onclick="let conteudo = ace_editor.getValue(); call(''etl_step_update'', ''prm_step_id='||prm_step_id||'&prm_cd_parametro='||prm_coluna||'&prm_conteudo=''+encodeURIComponent(conteudo), ''etl'').then(function(resposta){ '||
												' alerta('''', resposta.split(''|'')[1]); if(resposta.indexOf(''ERRO|'') == -1){ document.getElementById(''prm_'||lower(prm_coluna)||'_'||prm_step_id||''').value = conteudo; }  });">SALVAR</a>'; 
		else 
			ws_qtd_li := 0 ;
				
			htp.p('<ul class="form">'); 
			htp.p('<li></li>'); 
			for a in c_param loop 
				ws_qtd_li := ws_qtd_li + 1;
				ws_comando_parte := nvl(etl.ret_comando_param(ws_comando, a.ordem_comando),a.vl_default); 
				ws_comando_parte := replace(replace(replace(replace(replace(ws_comando_parte,'&','&amp;'),'"','&quot;'),chr(39),'&#039;'),'<','&lt;'),'>','&gt;');
				ws_ds_parametro  := replace(replace(replace(replace(replace(a.ds_parametro,  '&','&amp;'),'"','&quot;'),chr(39),'&#039;'),'<','&lt;'),'>','&gt;');
				htp.p('<li style="list-style: none; display: flex;">'); 
					htp.p('<span class="etl_label" style="">'||a.nm_parametro||'</span>'); 
					htp.p('<span class="etl_input" style="flex: 1; display: flex; flex-direction: column;" title="'||a.ds_parametro||'">'); 
						htp.p('<input id="etl_com_'||a.cd_parametro||'" type="text" style="" title="'||ws_ds_parametro||'" data-encode="S" '||ws_onkeypress||' value="'||ws_comando_parte||'"/>');
					htp.p('</span>'); 
					if ws_htp_param is not null then 
						ws_htp_param := ws_htp_param||' + ''|'' + ';
					end if;	
					ws_htp_param := ws_htp_param||''''||upper(a.cd_parametro)||'|'' + document.getElementById(''etl_com_'||a.cd_parametro||''').value.replace(''|'',''#PIPE#'') ';  
				htp.p('</li>'); 
			end loop; 	
			for a in ws_qtd_li..9 loop 
				htp.p('<li style="border-bottom: none;"></li>'); 
			end loop; 	
			htp.p('</ul>'); 

			ws_htp_salvar := '<a class="addpurple" onclick="let parametros = '||ws_htp_param||'; console.log(parametros);">SALVAR</a>'; 

			ws_htp_salvar := '<a class="addpurple" onclick="let ws_parametros = encodeURIComponent('||ws_htp_param||'); call(''etl_step_comando_update'', ''prm_step_id='||prm_step_id||'&prm_coluna='||prm_coluna||'&prm_parametros=''+ws_parametros, ''etl'').then(function(resposta){ '||
												' alerta('''', resposta.split(''|'')[1]); if(resposta.split(''|'')[0] == ''OK''){ document.getElementById(''prm_'||lower(prm_coluna)||'_'||prm_step_id||''').value = resposta.split(''|'')[2].split(''[#SEP#]'').join(''|''); }  });">SALVAR</a>'; 

		end if; 

		htp.p('<div style="display: flex; width: 70%; margin: 0 auto;">');
			htp.p(ws_htp_salvar);	
			htp.p(ws_htp_fechar);
		htp.p('</div>');			

	htp.p('</div>');
exception 
	when ws_raise_erro then 
		htp.p('ERRO|'||ws_erro);

end etl_step_comando;



END ETL;
