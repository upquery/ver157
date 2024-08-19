create or replace package body COM is

procedure modal ( prm_id number ) as 

    ws_msg     varchar2(30000);
	ws_assunto varchar2(1000);
				  
begin

    select msg, assunto into ws_msg, ws_assunto from bi_report_list where id = prm_id;

    htp.p('<div class="modal" id="modal'||prm_id||'">');
        htp.p('<h2 style="font-family: var(--fonte-secundaria); font-size: 20px; margin: 10px 5px 5px; padding: 10px 0px 5px 0px;">MENSAGEM DO EMAIL</h2>');
		htp.p('<div id="pell-editor'||prm_id||'" class="pell-bar"></div>');
		htp.p('<div id="modal-output'||prm_id||'" class="editable" contenteditable="true" title="Aceita #[PARAMETRO_USUARIO], @[OBJETO_VALOR], @#[OBJETO_VALOR], #[VARIAVEL_AMBIENTE], $[TELA], $[USUARIO], $[OBJETO]" onkeypress="var tamanho = this.innerHTML.toString().length; if(tamanho > 4000){ event.preventDefault(); return false;  } console.log(this.innerHTML.toString().length);">'||ws_msg||'</div>');
		htp.p('<div style="display: flex; width: 70%; margin: 0 auto;">');
			-- htp.p('<a class="addpurple" onclick="call(''updateReport'', ''prm_id='||prm_id||'&prm_coluna=msg&prm_valor=''+encodeURIComponent(document.getElementById(''modal-output'||prm_id||''').innerHTML), ''com'').then(function(res){ if(res.indexOf(''ok'') != -1){ alerta('''', TR_AL); document.getElementById(''modal'||prm_id||''').classList.remove(''expanded''); setTimeout(function(){ document.getElementById(''modal'||prm_id||''').remove(); }, 200); document.getElementById(''modalclick'||prm_id||''').children[0].value = document.getElementById(''modal-output'||prm_id||''').innerHTML;} else { alerta('''', TR_ER); } });">SALVAR</a>');			
			htp.p('<a class="addpurple" onclick="requestDefault(''updateReport'', ''prm_id='||prm_id||'&prm_coluna=msg&prm_valor=''+encodeURIComponent(document.getElementById(''modal-output'||prm_id||''').innerHTML), this );">SALVAR</a>');	
			htp.p('<a class="addpurple" onclick="document.getElementById(''modal'||prm_id||''').classList.remove(''expanded''); setTimeout(function(){ document.getElementById(''modal'||prm_id||''').remove(); }, 200);">FECHAR</a>');
	    htp.p('</div>');
	htp.p('</div>');

end modal;

procedure report as

	ws_usuario  varchar2(200); 
	ws_admin    varchar2(10);

    cursor crs_report is 
	  select id, usuario, id_ativo, decode(usuario,'DWU','ADMIN',usuario) as nm_usuario, assunto, msg, r.cd_objeto, o.nm_objeto, o.tp_objeto, email,largura_folha,altura_folha,id_situacao_envio
	    from objetos o, bi_report_list r
	   where o.cd_objeto(+) = r.cd_objeto 
	     and ( ws_admin = 'A' or r.usuario = ws_usuario);

	ws_report     crs_report%rowtype;
	ws_title         varchar2(200);
	ws_classe        varchar2(100);
	ws_tipo_envio    varchar2(10); 
	ws_ds_tp_objeto  varchar2(40);
	ws_email_manual  varchar2(300);
	ws_checked       varchar2(100);
	--
begin

	ws_usuario := gbl.getUsuario; 
	ws_admin   := gbl.getNivel;

	ws_tipo_envio := upper(nvl(fun.ret_var('COM_TIPO_ENVIO'),'R'));
	-- Atualiza reports que estão aguardando na fila 
   	com.checkFila ;    -- Executa somente se 

	htp.p('<input type="hidden" id="content-atributos" data-refresh="report" data-refresh-pkg="com"  data-pkg="com" >');

	htp.p('<div class="searchbar">');
	htp.p('</div>');

    htp.p('<table class="linha">');
			htp.p('<thead>');
				htp.p('<tr>');
				    htp.p('<th title="Endere&ccedil;os de email de destino.">EMAIL</th>');
					htp.p('<th title="">'||fun.lang('USU&Aacute;RIO')||'</th>');
					htp.p('<th>'||fun.lang('ASSUNTO')||'</th>');
					htp.p('<th>'||fun.lang('MENSAGEM')||'</th>');
					if ws_tipo_envio = 'R' then -- Serviço de envio de email remoto 
						htp.p('<th title="Tela a ser enviada anexa ao email.">'||fun.lang('TELA')||'</th>');
					else -- Serviço de envio de email local
						htp.p('<th title="Objeto a ser enviado anexo ao email.">'||fun.lang('OBJETO')||'</th>');
						htp.p('<th title="Tipo de objeto.">'||fun.lang('TIPO')||'</th>');					
						htp.p('<th style="width: 85px;" title="Largura(resolu&ccedil;&atilde;o) de visualiza&ccedil;&atilde;o da tela.">'||fun.lang('LARGURA')||'</th>');
						htp.p('<th style="width: 85px;" title="Altura(resolu&ccedil;&atilde;o) de visualiza&ccedil;&atilde;o da tela">'||fun.lang('ALTURA')||'</th>');
						htp.p('<th style="width: 85px;" title="Identificador de Ativo">'||fun.lang('ATIVO')||'</th>');
						htp.p('<th></th>');
						htp.p('<th></th>');
					end if;						
					htp.p('<th></th>');
					htp.p('<th></th>');
					htp.p('<th></th>');
					htp.p('<th></th>');
					htp.p('<th></th>');
				htp.p('</tr>');
			htp.p('</thead>');

			htp.p('<tbody id="ajax" >');
			
				open crs_report;
				    loop
					    fetch crs_report into ws_report;
					    exit when crs_report%notfound;

						ws_ds_tp_objeto := fun.lista_padrao_ds('REPORT_TP_CONTEUDO',ws_report.tp_objeto); 
						
						-- Busca emails adicionandos manualmente, que não estão entre os emails cadastrados no sistema
						ws_email_manual := null; 
						select listagg(column_value,'|') within group (order by column_value) into ws_email_manual 
 					      from table(fun.vpipe(ws_report.email)) t1 
                         where not exists (select 1 from usuarios 
						                    where nvl(upper(usu_email),'.') = t1.column_value
                                              and status = 'A' 
						                  ); 	   
						htp.p('<tr id="'||ws_report.id||'">');
						    
							htp.p('<td>');
								htp.p('<a class="script" data-default="'||ws_report.email||'" onclick="requestDefault(''updateReport'', ''prm_id='||ws_report.id||'&prm_coluna=email&prm_valor=''+this.nextElementSibling.title, this, this.nextElementSibling.title);"></a>');
							    fcl.fakeoption('prm_email_'||ws_report.id||'', '' , ws_report.email, 'lista-email', 'N', 'S', prm_min => 1, prm_desc => replace(ws_report.email,'|',', '), prm_fixed => ws_email_manual);
							htp.p('</td>');
							
							htp.p('<td class="fake-list">');
							    --htp.p('<a class="script com_enviar" data-default="'||ws_report.usuario||'" title="usuario"></a>');
								htp.p('<a class="script" data-default="'||ws_report.usuario||'" onclick="requestDefault(''updateReport'', ''prm_id='||ws_report.id||'&prm_coluna=usuario&prm_valor=''+this.nextElementSibling.title, this, this.nextElementSibling.title);"></a>');								
							    fcl.fakeoption('prm_usuario_'||ws_report.id||'', 'Usu&aacute;rio', ws_report.usuario, 'lista-usuarios-admin', 'N', 'N', prm_min => 1, prm_desc => ws_report.nm_usuario);
							htp.p('</td>');
							
							htp.p('<td><input id="prm_assunto_'||ws_report.id||'" data-min="1" data-default="'||ws_report.assunto||'" onblur="requestDefault(''updateReport'', ''prm_id='||ws_report.id||'&prm_coluna=assunto&prm_valor=''+this.value, this, this.value);" value="'||ws_report.assunto||'" /></td>');

							--ajustar o default
							htp.p('<td title="Clique para editar" class="com_modal" id="modalclick'||ws_report.id||'" style="cursor: pointer;">');
							    htp.p('<input class="readonly" data-min="1" value="'||replace(replace(regexp_replace(ws_report.msg, '<.+?>'), chr(34), ''), chr(39), '')||'" style="text-transform: none;"/>');
							htp.p('</td>');

							htp.p('<td>');
								htp.p('<a class="script" data-default="'||ws_report.cd_objeto||'" onclick="requestDefault(''updateReport'', ''prm_id='||ws_report.id||'&prm_coluna=objeto&prm_valor=''+this.nextElementSibling.title, this, this.nextElementSibling.title);"></a>');
		                        if ws_tipo_envio = 'R' then -- Remoto (envio somente de tela)
									fcl.fakeoption('prm_objeto_'||ws_report.id||'', '', ws_report.cd_objeto, 'lista-objetos-report-tela', 'N', 'N', prm_visao=>'prm_usuario_'||ws_report.id, prm_desc => ws_report.nm_objeto, prm_min => 1, prm_adicional => ws_report.id);
								else
									fcl.fakeoption('prm_objeto_'||ws_report.id||'', '', ws_report.cd_objeto, 'lista-objetos-report', 'N', 'N', prm_visao=>'prm_usuario_'||ws_report.id, prm_desc => ws_report.nm_objeto, prm_min => 1, prm_adicional => ws_report.id);
								end if;	
							htp.p('</td>');
							
							if ws_tipo_envio = 'L' then -- Serviço de envio de email local
								htp.p('<td><input class="readonly" disabled id="prm_ds_tp_objeto_'||ws_report.id||'" value="'||ws_ds_tp_objeto||'" /></td>');
								htp.p('<td><input id="prm_largura_folha_'||ws_report.id||'" data-default="'||ws_report.largura_folha||'" onblur="requestDefault(''updateReport'', ''prm_id='||ws_report.id||'&prm_coluna=largura_folha&prm_valor=''+this.value, this, this.value);" value="'||ws_report.largura_folha||'" /></td>');
								htp.p('<td><input id="prm_altura_folha_'||ws_report.id||'"  data-default="'||ws_report.altura_folha||'" onblur="requestDefault(''updateReport'', ''prm_id='||ws_report.id||'&prm_coluna=altura_folha&prm_valor=''+this.value, this, this.value);" value="'||ws_report.altura_folha||'" /></td>');							
							end if; 

							ws_checked := null; 
							if ws_report.id_ativo = 'S' then 
								ws_checked := ' checked ';
							end if; 
							-- htp.p('<td style="width: 90px !important;"><div><input type="checkbox"/></div></td>');
							
							htp.p('<td style="width: 90px !important;"><div><input id="prm_id_ativo_'||ws_report.id||'" type="checkbox" '||ws_checked||' value="'||ws_report.id_ativo||'"  data-default="'||nvl(ws_report.id_ativo,'N')||'" data-coluna="id_ativo" onblur="requestDefault(''updateReport'', ''prm_id='||ws_report.id||'&prm_coluna=ATIVO&prm_valor=''+(this.checked == true ? ''S'':''N''), this, this.checked == true ? ''S'':''N'');" /></div></td>');
					
							htp.p('<td class="com_enviar" title="Filtros">');
								--htp.p('<svg style="margin: 0 2px; height: 24px; width: 24px; float: left;" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"width="550.801px" height="550.801px" viewBox="0 0 550.801 550.801" style="enable-background:new 0 0 550.801 550.801;"xml:space="preserve"> <g> <g> <path d="M277.425,402.116c-20.208,0-31.87,19.833-31.87,44.317c-0.2,24.88,11.853,43.934,31.681,43.934 c20.018,0,31.683-18.858,31.683-44.508C308.918,421.949,297.644,402.116,277.425,402.116z"/> <path d="M475.095,131.992c-0.032-2.526-0.833-5.021-2.568-6.993L366.324,3.694c-0.021-0.034-0.062-0.045-0.084-0.076 c-0.633-0.707-1.36-1.29-2.141-1.804c-0.232-0.15-0.475-0.285-0.718-0.422c-0.675-0.366-1.382-0.67-2.13-0.892 c-0.19-0.058-0.38-0.14-0.58-0.192C359.87,0.114,359.037,0,358.203,0H97.2C85.292,0,75.6,9.693,75.6,21.601v507.6 c0,11.913,9.692,21.601,21.6,21.601H453.6c11.908,0,21.601-9.688,21.601-21.601V133.202 C475.2,132.796,475.137,132.398,475.095,131.992z M147.382,513.691c-14.974,0-29.742-3.892-37.125-7.979l6.022-24.485 c7.963,4.082,20.216,8.164,32.843,8.164c13.613,0,20.799-5.643,20.799-14.196c0-8.169-6.21-12.825-21.956-18.457 c-21.766-7.583-35.962-19.644-35.962-38.687c0-22.354,18.668-39.461,49.57-39.461c14.776,0,25.661,3.111,33.431,6.613 l-6.613,23.904c-5.244-2.521-14.575-6.207-27.4-6.207c-12.836,0-19.045,5.822-19.045,12.63c0,8.358,7.38,12.05,24.289,18.463 c23.127,8.553,34.024,20.608,34.024,39.076C200.253,495.023,183.336,513.691,147.382,513.691z M332.237,534.284 c-18.657-5.442-34.204-11.074-51.701-18.468c-2.911-1.16-6.022-1.745-9.134-1.936c-29.542-1.936-57.14-23.715-57.14-66.482 c0-39.261,24.877-68.808,63.942-68.808c40.047,0,62.006,30.322,62.006,66.087c0,29.742-13.796,50.735-31.104,58.504v0.785 c10.115,2.922,21.39,5.253,31.684,7.378L332.237,534.284z M441.492,511.745h-81.833V380.737h29.742V486.86h52.091V511.745z M97.2,366.752V21.601h250.203v110.515c0,5.961,4.831,10.8,10.8,10.8H453.6l0.011,223.836H97.2z"/> <path d="M334.114,171.171c0.475-1.308,0.812-2.647,0.812-4.063c0-17.386-37.568-26.765-72.924-26.765 c-35.321,0-72.879,9.379-72.879,26.765c0,1.416,0.33,2.761,0.81,4.074l-0.188,0.335c-1.616,2.932-2.415,5.89-2.415,8.801v21.513 c0,3.312,1.042,6.492,2.89,9.498l-0.242,0.411c-1.762,3.056-2.647,6.151-2.647,9.208v21.508c0,3.208,0.983,6.286,2.731,9.208 l-0.084,0.134c-1.762,3.051-2.647,6.152-2.647,9.202v21.51c0,19.122,32.801,34.093,74.672,34.093 c41.916,0,74.717-14.971,74.717-34.093v-21.51c0-3.056-0.886-6.162-2.669-9.208l-0.073-0.118c1.734-2.927,2.742-6.004,2.742-9.218 v-21.508c0-3.061-0.886-6.167-2.669-9.218l-0.231-0.396c1.846-3.011,2.9-6.186,2.9-9.508v-21.513c0-2.911-0.812-5.877-2.415-8.81 L334.114,171.171z M328.715,282.509c0,12.351-27.38,26.093-66.712,26.093c-39.295,0-66.68-13.742-66.68-26.093v-20.231 c12.263,11.232,37.492,18.396,66.68,18.396c29.228,0,54.456-7.169,66.712-18.407V282.509z M328.715,242.455 c0,12.34-27.38,26.093-66.712,26.093c-39.295,0-66.68-13.753-66.68-26.093v-20.234c12.263,11.227,37.492,18.398,66.68,18.398 c29.228,0,54.456-7.172,66.712-18.409V242.455z M328.715,201.825c0,12.34-27.38,26.093-66.712,26.093 c-39.295,0-66.68-13.748-66.68-26.093v-17.9c11.984,10.156,39.772,15.422,66.68,15.422c26.944,0,54.72-5.266,66.712-15.422 V201.825z"/> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
							    htp.p('<svg style="margin: 0 2px; height: 26px; width: 26px; float: left;" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="56.805px" height="56.805px" viewBox="0 0 56.805 56.805" style="enable-background:new 0 0 56.805 56.805;" xml:space="preserve"> <g> <g id="_x32_7"> <g> <path d="M56.582,4.352c-0.452-1.092-1.505-1.796-2.685-1.796H2.908c-1.18,0-2.233,0.704-2.685,1.796 c-0.451,1.091-0.204,2.336,0.63,3.171l20.177,20.21V53.02c0,0.681,0.55,1.229,1.229,1.229c0.68,0,1.229-0.549,1.229-1.229V27.223 c0-0.327-0.13-0.64-0.36-0.87L2.591,5.782c-0.184-0.185-0.14-0.385-0.098-0.487C2.537,5.19,2.646,5.019,2.908,5.019h50.99 c0.26,0,0.37,0.173,0.414,0.276c0.042,0.103,0.086,0.303-0.099,0.487L33.679,26.353c-0.23,0.23-0.36,0.543-0.36,0.87v18.412 c0,0.681,0.55,1.229,1.229,1.229c0.681,0,1.229-0.55,1.229-1.229V27.732l20.177-20.21C56.785,6.688,57.033,5.443,56.582,4.352z"></path> </g> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');  								
							htp.p('</td>');

							htp.p('<td class="com_enviar" title="Agendamento">');
								htp.p('<svg  style="margin: 0 2px; height: 24px; width: 24px; float: left;" height="512pt" viewBox="-34 0 512 512.04955" width="512pt" xmlns="http://www.w3.org/2000/svg"><path d="m.0234375 290.132812c-.02734375 121.429688 97.5703125 220.324219 218.9882815 221.898438 121.421875 1.574219 221.550781-94.753906 224.671875-216.144531 3.125-121.386719-91.917969-222.734375-213.257813-227.40625v-17.28125h17.066407c14.136718 0 25.597656-11.460938 25.597656-25.597657 0-14.140624-11.460938-25.601562-25.597656-25.601562h-51.199219c-14.140625 0-25.601563 11.460938-25.601563 25.601562 0 14.136719 11.460938 25.597657 25.601563 25.597657h17.066406v17.28125c-119.054687 4.707031-213.183594 102.507812-213.3359375 221.652343zm187.7343745-264.53125c0-4.714843 3.820313-8.535156 8.535157-8.535156h51.199219c4.710937 0 8.53125 3.820313 8.53125 8.535156 0 4.710938-3.820313 8.53125-8.53125 8.53125h-51.199219c-4.714844 0-8.535157-3.820312-8.535157-8.53125zm238.933594 264.53125c0 113.109376-91.691406 204.800782-204.800781 204.800782-113.105469 0-204.800781-91.691406-204.800781-204.800782 0-113.105468 91.695312-204.800781 204.800781-204.800781 113.054687.132813 204.667969 91.746094 204.800781 204.800781zm0 0"/><path d="m315.3125 127.402344c-57.828125-33.347656-129.046875-33.347656-186.878906 0-.136719.070312-.296875.070312-.441406.144531-.148438.078125-.214844.222656-.351563.308594-28.179687 16.4375-51.625 39.882812-68.0625 68.0625-.085937.136719-.222656.210937-.304687.347656-.085938.136719-.078126.300781-.148438.445313-33.347656 57.828124-33.347656 129.050781 0 186.878906.070312.144531.070312.300781.148438.445312.074218.144532.289062.347656.417968.535156 16.429688 28.097657 39.835938 51.472657 67.949219 67.875.136719.085938.214844.222657.351563.308594.136718.085938.433593.160156.648437.265625 57.714844 33.175781 128.71875 33.175781 186.433594 0 .214843-.105469.445312-.148437.648437-.265625.207032-.121094.214844-.222656.351563-.308594 28.117187-16.410156 51.523437-39.800781 67.949219-67.90625.128906-.1875.300781-.335937.417968-.539062.121094-.203125.078125-.296875.148438-.445312 33.347656-57.828126 33.347656-129.046876 0-186.878907-.070313-.144531-.070313-.296875-.148438-.441406-.074218-.148437-.21875-.214844-.304687-.34375-16.433594-28.183594-39.882813-51.632813-68.0625-68.070313-.136719-.085937-.214844-.222656-.351563-.308593-.136718-.082031-.261718-.039063-.410156-.109375zm49.777344 70.203125-7.050782 4.070312c-2.660156 1.515625-4.308593 4.339844-4.3125 7.402344-.007812 3.058594 1.625 5.890625 4.28125 7.417969 2.65625 1.523437 5.925782 1.507812 8.566407-.039063l7.058593-4.078125c11.027344 21.488282 17.332032 45.09375 18.488282 69.222656h-25.164063c-4.710937 0-8.53125 3.820313-8.53125 8.53125 0 4.714844 3.820313 8.535157 8.53125 8.535157h25.164063c-1.15625 24.128906-7.460938 47.730469-18.488282 69.222656l-7.058593-4.082031c-2.640625-1.546875-5.910157-1.5625-8.566407-.035156-2.65625 1.523437-4.289062 4.355468-4.28125 7.417968.003907 3.0625 1.652344 5.886719 4.3125 7.398438l7.050782 4.070312c-13.140625 20.265625-30.40625 37.53125-50.671875 50.671875l-4.070313-7.050781c-1.511718-2.660156-4.335937-4.308594-7.398437-4.3125-3.0625-.007812-5.894531 1.625-7.417969 4.28125-1.527344 2.65625-1.511719 5.925781.035156 8.566406l4.082032 7.058594c-21.492188 11.027344-45.09375 17.332031-69.222657 18.488281v-25.164062c0-4.710938-3.820312-8.53125-8.535156-8.53125-4.710937 0-8.53125 3.820312-8.53125 8.53125v25.164062c-24.128906-1.15625-47.734375-7.460937-69.222656-18.488281l4.078125-7.058594c1.546875-2.640625 1.5625-5.910156.039062-8.566406-1.527344-2.65625-4.359375-4.289062-7.417968-4.28125-3.0625.003906-5.886719 1.652344-7.402344 4.3125l-4.070313 7.050781c-20.265625-13.140625-37.53125-30.40625-50.667969-50.671875l7.046876-4.070312c2.660156-1.511719 4.308593-4.335938 4.316406-7.398438.007812-3.0625-1.628906-5.894531-4.285156-7.417968-2.652344-1.527344-5.921876-1.511719-8.566407.035156l-7.054687 4.082031c-11.03125-21.492187-17.335938-45.09375-18.492188-69.222656h25.164063c4.714843 0 8.535156-3.820313 8.535156-8.535157 0-4.710937-3.820313-8.53125-8.535156-8.53125h-25.164063c1.15625-24.128906 7.460938-47.734374 18.492188-69.222656l7.054687 4.078125c2.644531 1.546875 5.914063 1.5625 8.566407.039063 2.65625-1.527344 4.292968-4.359375 4.285156-7.417969-.007813-3.0625-1.65625-5.886719-4.316406-7.402344l-7.046876-4.070312c13.136719-20.265625 30.402344-37.53125 50.667969-50.671875l4.070313 7.050781c1.515625 2.660156 4.339844 4.308594 7.402344 4.316406 3.058593.003907 5.890624-1.628906 7.417968-4.285156 1.523438-2.65625 1.507813-5.921875-.039062-8.566406l-4.078125-7.054688c21.488281-11.03125 45.09375-17.335937 69.222656-18.492187v25.164062c0 4.714844 3.820313 8.535156 8.53125 8.535156 4.714844 0 8.535156-3.820312 8.535156-8.535156v-25.164062c24.128907 1.15625 47.730469 7.460937 69.222657 18.492187l-4.082032 7.054688c-1.546875 2.644531-1.5625 5.910156-.035156 8.566406 1.523438 2.65625 4.355469 4.289063 7.417969 4.285156 3.0625-.007812 5.886719-1.65625 7.398437-4.316406l4.070313-7.050781c20.265625 13.140625 37.53125 30.40625 50.671875 50.671875zm0 0"/><path d="m230.425781 266.101562v-86.902343c0-4.710938-3.820312-8.53125-8.535156-8.53125-4.710937 0-8.53125 3.820312-8.53125 8.53125v86.902343c-11.757813 4.15625-18.808594 16.179688-16.699219 28.46875 2.109375 12.285157 12.761719 21.269532 25.230469 21.269532s23.125-8.984375 25.230469-21.269532c2.109375-12.289062-4.941406-24.3125-16.695313-28.46875zm-8.535156 32.566407c-4.710937 0-8.53125-3.820313-8.53125-8.535157 0-4.710937 3.820313-8.53125 8.53125-8.53125 4.714844 0 8.535156 3.820313 8.535156 8.53125 0 4.714844-3.820312 8.535157-8.535156 8.535157zm0 0"/></svg>');
							htp.p('</td>');

							htp.p('<td class="com_enviar" title="Enviar">');
								htp.p('<svg style="margin: 0 2px; height: 24px; width: 24px; float: left;" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 488.721 488.721" style="enable-background:new 0 0 488.721 488.721;" xml:space="preserve"> <g> <g> <path d="M483.589,222.024c-5.022-10.369-13.394-18.741-23.762-23.762L73.522,11.331C48.074-0.998,17.451,9.638,5.122,35.086 C-1.159,48.052-1.687,63.065,3.669,76.44l67.174,167.902L3.669,412.261c-10.463,26.341,2.409,56.177,28.75,66.639 c5.956,2.366,12.303,3.595,18.712,3.624c7.754,0,15.408-1.75,22.391-5.12l386.304-186.982 C485.276,278.096,495.915,247.473,483.589,222.024z M58.657,446.633c-8.484,4.107-18.691,0.559-22.798-7.925 c-2.093-4.322-2.267-9.326-0.481-13.784l65.399-163.516h340.668L58.657,446.633z M100.778,227.275L35.379,63.759 c-2.722-6.518-1.032-14.045,4.215-18.773c5.079-4.949,12.748-6.11,19.063-2.884l382.788,185.173H100.778z"/> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>');
							htp.p('</td>');

							htp.p('<td class="etl_atalho" title="Copiar a&ccedil;&atilde;o" '||
					    	  ' onclick="carregaPainel(''report'', '''|| ws_report.id ||''')">');
							htp.p('<svg viewBox="0 0 28 28"><path d="M13.508 11.504l.93-2.494 2.998 6.268-6.31 2.779.894-2.478s-8.271-4.205-7.924-11.58c2.716 5.939 9.412 7.505 9.412 7.505zm7.492-9.504v-2h-21v21h2v-19h19zm-14.633 2c.441.757.958 1.422 1.521 2h14.112v16h-16v-8.548c-.713-.752-1.4-1.615-2-2.576v13.124h20v-20h-17.633z"></path></svg>');
							htp.p('</td>');

							if ws_tipo_envio = 'L' then -- Serviço de envio de email local
								htp.p('<td class="com_enviar" title="Log">');
									htp.p('<svg style="margin: 0 2px; height: 24px; width: 24px; float: left;" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 600 600" xml:space="preserve"><g><path d="M486.201,196.124h-13.166V132.59c0-0.396-0.062-0.795-0.115-1.196c-0.021-2.523-0.825-5-2.552-6.963L364.657,3.677 c-0.033-0.031-0.064-0.042-0.085-0.073c-0.63-0.707-1.364-1.292-2.143-1.795c-0.229-0.157-0.461-0.286-0.702-0.421 c-0.672-0.366-1.387-0.671-2.121-0.892c-0.2-0.055-0.379-0.136-0.577-0.188C358.23,0.118,357.401,0,356.562,0H96.757 C84.894,0,75.256,9.651,75.256,21.502v174.613H62.092c-16.971,0-30.732,13.756-30.732,30.733v159.812 c0,16.968,13.761,30.731,30.732,30.731h13.164V526.79c0,11.854,9.638,21.501,21.501,21.501h354.776 c11.853,0,21.501-9.647,21.501-21.501V417.392h13.166c16.966,0,30.729-13.764,30.729-30.731V226.854 C516.93,209.872,503.167,196.124,486.201,196.124z M96.757,21.502h249.054v110.009c0,5.939,4.817,10.75,10.751,10.75h94.972v53.861 H96.757V21.502z M317.816,303.427c0,47.77-28.973,76.746-71.558,76.746c-43.234,0-68.531-32.641-68.531-74.152 c0-43.679,27.887-76.319,70.906-76.319C293.389,229.702,317.816,263.213,317.816,303.427z M82.153,377.79V232.085h33.073v118.039 h57.944v27.66H82.153V377.79z M451.534,520.962H96.757v-103.57h354.776V520.962z M461.176,371.092 c-10.162,3.454-29.402,8.209-48.641,8.209c-26.589,0-45.833-6.698-59.24-19.664c-13.396-12.535-20.75-31.568-20.529-52.967 c0.214-48.436,35.448-76.108,83.229-76.108c18.814,0,33.292,3.688,40.431,7.139l-6.92,26.37 c-7.999-3.457-17.942-6.268-33.942-6.268c-27.449,0-48.209,15.567-48.209,47.134c0,30.049,18.807,47.771,45.831,47.771 c7.564,0,13.623-0.852,16.21-2.152v-30.488h-22.478v-25.723h54.258V371.092L461.176,371.092z"></path><path d="M212.533,305.37c0,28.535,13.407,48.64,35.452,48.64c22.268,0,35.021-21.186,35.021-49.5 c0-26.153-12.539-48.655-35.237-48.655C225.504,255.854,212.533,277.047,212.533,305.37z"></path></g></svg>');
								htp.p('</td>');

								ws_title := fun.lista_padrao_ds('REPORT_STATUS',ws_report.id_situacao_envio ); 
								if ws_report.id_situacao_envio = 'F' then 	
									ws_classe      := ' class="com_status com_status_enviado"' ;
								elsif nvl(ws_report.id_situacao_envio,'A') in ('A','R','P') then 	
									ws_classe      := ' class="com_status com_status_aguardando"' ;
								else
									ws_classe      := ' class="com_status com_status_erro"' ;
								end if; 	
								
								htp.p('<td id="td_report_status" title="'||ws_title||'"><span id="span_report_status" '||ws_classe||'></span></td>');
							end if; 

							htp.p('<td>');
							    fcl.button_lixo('deleteReport','prm_id', ws_report.id, prm_tag => 'a', prm_pkg => 'COM');
							htp.p('</td>');

						htp.p('</tr>');
				    end loop;
				close crs_report;

			htp.p('</tbody>');
		htp.p('</table>');

		htp.p('<div id="modal-box" style="display: contents;"></div>');

end report;

procedure addReport ( prm_usuario  varchar2 default null,
                      prm_assunto  varchar2 default null,
					  prm_msg      varchar2 default null,
					  prm_objeto   varchar2 default null,
					  prm_email    varchar2 default null,
					  prm_id_anterior varchar2 default null ) as

	ws_count number := 0; 
	ws_error exception;				  
	ws_id    number := 0;				  
begin

    select max(id) into ws_id from bi_report_list;

	if nvl(ws_id, 0) = 0 then
        ws_id := 1;
	else
        ws_id := ws_id+1;
	end if;

    insert into bi_report_list (id, usuario, assunto, msg, cd_objeto, email) values (ws_id, prm_usuario, prm_assunto, prm_msg, prm_objeto, prm_email);

	ws_count := SQL%ROWCOUNT;
			
	if prm_id_anterior is not null then	

		for a in (select * from bi_report_filter where report_id = prm_id_anterior) loop 
			addreportfilter(ws_id, a.nm_usuario, a.micro_visao, a.coluna, a.condicao, a.valor);
		end loop;

		for a in (select * from bi_report_schedule where report_id = prm_id_anterior) loop 
			addreportschedule(ws_id, a.semana, a.dia_mes, a.mes, a.hora, a.quarter);
		end loop;

	end if;

	if ws_count = 1 then
		commit;
	else
		rollback;
		raise ws_error;
	end if;

	htp.p('ok');

exception 
    when ws_error then
        htp.p('ERRO AO INSERIR REPORT');
	when others then
	    htp.p('ERRO '||SQLERRM);
end addReport;

procedure deleteReport ( prm_id number ) as

    ws_count number := 0; 
	ws_error exception;				  

begin

    delete from bi_report_list where id = prm_id;
	ws_count := SQL%ROWCOUNT;
			
	if ws_count = 1 then
        delete from bi_report_filter   where report_id = prm_id;
		delete from bi_report_schedule where report_id = prm_id;
		commit;
	else
		rollback;
		raise ws_error;
	end if;

	htp.p('ok');

exception 
    when ws_error then
        htp.p('ERRO AO EXCLUIR REPORT');
	when others then
	    htp.p('ERRO '||SQLERRM);
end deleteReport;

procedure updateReport ( prm_id number,
                         prm_coluna varchar2 default null,
						 prm_valor  clob ) as

    ws_count    number := 0; 
	ws_msg      varchar2(100); 
	ws_cd_tp    varchar2(200); 
	ws_ds_tp    varchar2(200); 
	ws_valor_n  number; 	  
	ws_error    exception;
begin

	ws_cd_tp := null; 
	ws_ds_tp := null; 

	if upper(prm_coluna) in ('LARGURA_FOLHA','ALTURA_FOLHA') then
		begin 
			ws_valor_n := to_number(prm_valor); 
		exception when others Then
			ws_msg := 'Deve ser informado um n&uacute;mero inteiro v&aacute;lido';
			raise ws_error;
		end; 	
	end if; 

    case upper(prm_coluna)
		when 'OBJETO' then
			if prm_valor is null then 
				ws_msg := 'Objeto deve ser selecionando';
				raise ws_error;
			else 
				update bi_report_list set cd_objeto = prm_valor
				where id = prm_id;
				select max(tp_objeto) into ws_cd_tp from objetos where cd_objeto = to_char(prm_valor); 
				ws_ds_tp := fun.lista_padrao_ds('REPORT_TP_CONTEUDO',ws_cd_tp); 
			end if; 	
		when 'USUARIO' then
			update bi_report_list set usuario = prm_valor
			where id = prm_id;
		when 'ASSUNTO' then
			if prm_valor is null then 
				ws_msg := 'Assunto deve ser informado';
				raise ws_error;
			else 
				update bi_report_list set assunto = prm_valor
				where id = prm_id;
			end if	;
		when 'MSG' then
		
			update bi_report_list set msg = to_clob(prm_valor)
			where id = prm_id;

		when 'EMAIL' then
			
			if prm_valor is null then 
				ws_msg := 'Email deve ser informado';
				raise ws_error;
			elsif length(prm_valor) > 4000 then 
				ws_msg := 'Email n&atilde;o pode conter mais de 4000 caracteres';
				raise ws_error; 
			else 
				update bi_report_list set email = replace(prm_valor,',','|') 
				where id = prm_id;
			end if; 
		when 'LARGURA_FOLHA' then
			update bi_report_list set largura_folha = ws_valor_n
			where id = prm_id;
		when 'ALTURA_FOLHA' then
			update bi_report_list set altura_folha = ws_valor_n
			where id = prm_id;
		when 'ATIVO' then
			update bi_report_list set id_ativo = trim(prm_valor)
			where id = prm_id;

	end case;

	ws_count := SQL%ROWCOUNT;
			
	if ws_count = 1 then
		commit;
	else
		rollback;
		ws_msg := 'Erro atualizando o report.';
		raise ws_error;
	end if;

	htp.p('OK||'||ws_ds_tp);

exception 
    when ws_error then
        htp.p('ERRO|'||ws_msg);
	when others then
	    htp.p('ERRO|Erro atualizando o report:'||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
end updateReport;

procedure reportSchedule (  prm_id varchar2 default null ) as

    cursor crs_schedules is
	select id, report_id, semana, mes, hora, quarter, ultimo_status, ultima_data, dia_mes 
	  from bi_report_schedule
	 where report_id = prm_id;

	cursor c_lista (p_cd_lista varchar2, p_valores varchar2) is  
	select listagg(ds_abrev,', ') WITHIN GROUP (ORDER BY nr_ordem) 
      from bi_lista_padrao 
     where cd_lista = p_cd_lista 
       and cd_item in (select column_value from table(fun.vpipe(p_valores)) ) ; 
 
	ws_schedule crs_schedules%rowtype;
	ws_desc varchar2(500);
    
    ws_eventoVerificar  varchar2(2000);
    ws_eventoGravar     varchar2(2000);
begin
    
	htp.p('<input type="hidden" id="prm_id" value="'||prm_id||'">');

	htp.p('<table class="linha">');
		htp.p('<thead>');
			htp.p('<tr >');
				htp.p('<th title="Dias da semana em que ser&atilde;o enviados e-mails, este campo ser&aacute; ignorado se o dia do m&ecirc;s for informado.">'||fun.lang('DIAS DA SEMANA')||'</th>');
				htp.p('<th title="Dias do m&ecirc;s, se nenhum dia do m&ecirc;s for preenchido, todos ser&atilde;o selecionados.">'||fun.lang('DIAS DO M&Ecirc;S')||'</th>');
				htp.p('<th title="Meses em que ser&atilde;o enviados os e-mails.">'||fun.lang('M&Ecirc;S')||'</th>');
				htp.p('<th title="Horas em que ser&atilde;o enviados os e-mails.">'||fun.lang('HORAS')||'</th>');
				htp.p('<th title="Minutos em que ser&atilde;o enviado os e-mails.">'||fun.lang('MINUTO')||'</th>');
			htp.p('</tr>');
		htp.p('</thead>');
		htp.p('<tbody id="etl-schedule">');


        ws_eventoVerificar := 'if(document.getElementById(this.parentNode.parentNode.id+''#CAMPO_OPOSTO#'').title.length > 0){if(confirm(''Deseja substituir o agendamento de Dias #DOCAMPO1# para Dias #DOCAMPO2#?'' )){document.getElementById(this.parentNode.parentNode.id+''#CAMPO_OPOSTO#'').title = '''';document.getElementById(this.parentNode.parentNode.id+''#CAMPO_OPOSTO#'').setAttribute(''data-default'', '''');document.getElementById(this.parentNode.parentNode.id+''#CAMPO_OPOSTO#'').children[0].innerHTML = '''';#GRAVAR#} else {carregaTelasup(''reportSchedule'', ''prm_id=''+'||prm_id||', ''COM'', ''report_schedule'', '''', '''', '''');}} else {#GRAVAR#}';
        ws_eventoGravar := 'requestDefault(''updateReportSchedule'', ''prm_id=#SCH_ID#&prm_coluna=#CAMPO#&prm_valor=''+this.nextElementSibling.title, this, this.nextElementSibling.title, '''', ''com'', ()=>{carregaTelasup(''reportSchedule'', ''prm_id=''+'||prm_id||', ''COM'', ''report_schedule'', '''', '''', '''')});';

		open crs_schedules;
			loop
				fetch crs_schedules into ws_schedule;
				exit when crs_schedules%notfound;
				htp.p('<tr id="'||ws_schedule.id||'">');

					ws_desc := null;
					open  c_lista ('DIA_SEMANA', ws_schedule.semana);
					fetch c_lista into ws_desc;
					close c_lista; 
					htp.p('<td>');
						--htp.p('<a class="script com_enviar" title="semana"></a>');
						-- htp.p('<a class="script" data-default="'||ws_schedule.semana||'" onclick="requestDefault(''updateReportSchedule'', ''prm_id='||ws_schedule.id||'&prm_coluna=semana&prm_valor=''+this.nextElementSibling.title, this, this.nextElementSibling.title, null, null, carregaTelasup(''reportSchedule'', ''prm_id=''+'||prm_id||', ''COM'', ''report_schedule'', '''', '''', ''''));"></a>');
						htp.p('<a class="script" data-default="'||ws_schedule.semana||'" onclick="'||replace(replace(replace(replace(ws_eventoVerificar, '#CAMPO_OPOSTO#', '-dia_mes'), '#DOCAMPO1#', 'do M&ecirc;s'), '#DOCAMPO2#', 'da Semana'), '#GRAVAR#', replace(replace(ws_eventoGravar,'#CAMPO#','semana'), '#SCH_ID#', ws_schedule.id))||'"></a>');
						fcl.fakeoption(ws_schedule.id||'-semanas', '', ws_schedule.semana, 'lista-semanas', 'N', 'S', prm_desc => ws_desc );						
					htp.p('</td>');
					
					ws_desc := null;
					open  c_lista ('DIA_MES', ws_schedule.dia_mes);
					fetch c_lista into ws_desc;
					close c_lista; 
					htp.p('<td class="fake-list">');
						-- htp.p('<a class="script" data-default="'||ws_schedule.dia_mes||'" onclick="requestDefault(''updateReportSchedule'', ''prm_id='||ws_schedule.id||'&prm_coluna=dia_mes&prm_valor=''+this.nextElementSibling.title, this, this.nextElementSibling.title, null, null, carregaTelasup(''reportSchedule'', ''prm_id=''+'||prm_id||', ''COM'', ''report_schedule'', '''', '''', ''''));"></a>');
                        htp.p('<a class="script" data-default="'||ws_schedule.dia_mes||'" onclick="'||replace(replace(replace(replace(ws_eventoVerificar, '#CAMPO_OPOSTO#', '-semanas'), '#DOCAMPO1#', 'da Semana'), '#DOCAMPO2#', 'do M&ecirc;s'), '#GRAVAR#', replace(replace(ws_eventoGravar,'#CAMPO#','dia_mes'), '#SCH_ID#', ws_schedule.id))||'"></a>');
						fcl.fakeoption(ws_schedule.id||'-dia_mes', '', ws_schedule.dia_mes, 'lista-dia-mes', 'N', 'S', prm_desc => ws_desc );						
					htp.p('</td>');

					ws_desc := null;
					open  c_lista ('MES', ws_schedule.mes);
					fetch c_lista into ws_desc;
					close c_lista; 
					htp.p('<td class="fake-list" >');
						--htp.p('<a class="script com_enviar" title="mes"></a>');
						htp.p('<a class="script" data-default="'||ws_schedule.mes||'" onclick="requestDefault(''updateReportSchedule'', ''prm_id='||ws_schedule.id||'&prm_coluna=mes&prm_valor=''+this.nextElementSibling.title, this, this.nextElementSibling.title);"></a>');
						fcl.fakeoption(ws_schedule.id||'-mes', '', ws_schedule.mes, 'lista-meses', 'N', 'S', prm_desc => ws_desc, prm_min => 1);
					htp.p('</td>');

					ws_desc := null;
					open  c_lista ('HORA', ws_schedule.hora);
					fetch c_lista into ws_desc;
					close c_lista;
					htp.p('<td>');
						--htp.p('<a class="script com_enviar" title="hora"></a>');
						htp.p('<a class="script" data-default="'||ws_schedule.hora||'" onclick="requestDefault(''updateReportSchedule'', ''prm_id='||ws_schedule.id||'&prm_coluna=hora&prm_valor=''+this.nextElementSibling.title, this, this.nextElementSibling.title);"></a>');
						fcl.fakeoption(ws_schedule.id||'-horas', '', ws_schedule.hora, 'lista-horas', 'N', 'S', prm_desc => ws_desc, prm_min => 1);
					htp.p('</td>');

					ws_desc := null;
					open  c_lista ('MINUTO', ws_schedule.quarter);
					fetch c_lista into ws_desc;
					close c_lista; 
					htp.p('<td>');
						--htp.p('<a class="script com_enviar" title="quarter"></a>');
						htp.p('<a class="script" data-default="'||ws_schedule.quarter||'" onclick="requestDefault(''updateReportSchedule'', ''prm_id='||ws_schedule.id||'&prm_coluna=quarter&prm_valor=''+this.nextElementSibling.title, this, this.nextElementSibling.title);"></a>');
						fcl.fakeoption(ws_schedule.id||'-minutos', '', ws_schedule.quarter, 'lista-minutos', 'N', 'S', prm_desc => ws_desc, prm_min => 1);
					htp.p('</td>');

					htp.p('<td>');
						fcl.button_lixo('deleteReportSchedule','prm_id', ws_schedule.id, prm_tag => 'a', prm_pkg => 'COM');
					htp.p('</td>');
					
				htp.p('</tr>');
			end loop;
		close crs_schedules;
		
		htp.p('</tbody>');
	htp.p('</table>');
		
	htp.p('<div class="listar">');
		--htp.p('<a onclick="call(''report'', '''', ''COM'').then(function(resposta){ document.getElementById(''content'').innerHTML = resposta; call(''menu'', ''prm_menu=report'').then(function(resp){ document.getElementById(''painel'').innerHTML = resp; refreshSupBtn(''A''); }); });">'||fun.lang('VOLTAR')||'</a>');
		htp.p('<a onclick="carregaTelasup(''report'', '''', ''COM'', ''report'', '''', '''', '''')">'||fun.lang('VOLTAR')||'</a>');		
	htp.p('</div>');

end reportSchedule;

procedure addReportSchedule ( prm_id number, 
                              prm_semana varchar2, 
							  prm_dia_mes varchar2,
							  prm_mes varchar2, 
							  prm_hora varchar2, 
							  prm_quarter varchar2 ) as
	ws_id            number := 0;
	ws_erro          varchar2(200);
	ws_semana        varchar2(200);
	ws_dia_mes       varchar2(200);
	ws_raise_erro    exception; 
begin
	
	if prm_semana is null and prm_dia_mes is null then 
		ws_erro := 'Deve ser informado o Dia da Semana ou o Dia do M&ecirc;s';
		raise ws_raise_erro;
  elsif prm_semana is not null and prm_dia_mes is not null then
    ws_erro := 'Deve ser informado o Dia da Semana ou o Dia do M&ecirc;s';
		raise ws_raise_erro;
	end if;

	ws_semana  := prm_semana;
	ws_dia_mes := prm_dia_mes;

	if prm_dia_mes is not null then
		ws_semana := null;
	end if;	

    select nvl(max(id),0)+1 into ws_id from bi_report_schedule;

    insert into bi_report_schedule (id, report_id, semana, dia_mes, mes, hora, quarter) 
	                        values (ws_id, prm_id, ws_semana, ws_dia_mes, prm_mes, prm_hora, prm_quarter);
	commit;
	htp.p('OK|');

exception 
	when ws_raise_erro then 
		htp.p('ERRO|'||ws_erro);
	when others then
		insert into bi_log_sistema (dt_Log, ds_log, nm_usuario, nm_procedure) values (sysdate, 'addReportSchedule: '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getUsuario, 'ERRO');
		commit; 
		htp.p('ERRO|N&atilde;o foi poss&iacute;vel inserir o registro, entre em contato com o admistrador do sistema ou verifique o log de erros');
end addReportSchedule;

procedure deleteReportSchedule ( prm_id number ) as

    ws_count number := 0; 
	ws_error exception;				  

begin

    delete from bi_report_schedule where id = prm_id;

	ws_count := SQL%ROWCOUNT;
			
	if ws_count = 1 then
		commit;
	else
		rollback;
		raise ws_error;
	end if;

	htp.p('ok');

exception 
    when ws_error then
        htp.p('ERRO AO EXCLUIR HORÁRIO REPORT');
	when others then
	    htp.p('ERRO '||SQLERRM);
end deleteReportSchedule;

procedure updateReportSchedule ( prm_id     number,
                         		 prm_coluna varchar2 default null,
						 		 prm_valor  varchar2 default null ) as

    ws_count number := 0; 
	ws_erro        varchar2(200);	
	ws_raise_erro  exception;				  

begin


    case prm_coluna
		when 'semana' then

			update bi_report_schedule set semana = prm_valor, dia_mes = null
			where id = prm_id;

		when 'dia_mes' then
			update bi_report_schedule set dia_mes = prm_valor, semana = null
			where id = prm_id;

		when 'mes' then
			update bi_report_schedule set mes = prm_valor
			where id = prm_id;

		when 'hora' then
			update bi_report_schedule set hora = prm_valor
			where id = prm_id;

		when 'quarter' then
			update bi_report_schedule set quarter = prm_valor
			where id = prm_id;

		when 'ultimo_status' then
			update bi_report_schedule set ultimo_status = prm_valor
			where id = prm_id;

		when 'ultima_data' then
			update bi_report_schedule set ultima_data = prm_valor
			where id = prm_id;
	end case;

	ws_count := SQL%ROWCOUNT;
			
	if ws_count = 1 then
		select count(*) into ws_count 
		  from bi_report_schedule 
 		 where id = prm_id
		   and semana is null 
		   and dia_mes is null ;
		if ws_count > 0 then 
			rollback;
			ws_erro := 'N&atilde;o &eacute; poss&iacute;vel limpar esse campo, &eacute; obrigat&oacute;rio informar o dia da semana ou dia do m&ecirc;s';
			raise ws_raise_erro;
		end if;	
		commit;
	else
		rollback;
		ws_erro := 'Nenhum registro foi atualizado, entre em contato com o admistrador do sistema';
		raise ws_raise_erro;
	end if;

	htp.p('OK|');

exception 
    when ws_raise_erro then
        htp.p('ERRO|'||ws_erro);
	when others then
		insert into bi_log_sistema (dt_Log, ds_log, nm_usuario, nm_procedure) values (sysdate, 'addReportSchedule: '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getUsuario, 'ERRO');
		commit; 
		htp.p('ERRO|N&atilde;o foi poss&iacute;vel atualizar o registro, entre em contato com o admistrador do sistema ou verifique o log de erros');
end updateReportSchedule;

procedure reportFilter ( prm_report varchar2 default null ) as 

    cursor crs_filtros is
	select id, micro_visao, coluna, condicao, valor
	from   bi_report_filter
	where  report_id = prm_report;

	ws_filtro crs_filtros%rowtype;

begin

    htp.p('<table class="linha">');
	    htp.p('<thead>');
			htp.p('<tr>');
				htp.p('<th>VIEW</th>');
				htp.p('<th>'||fun.lang('COLUNA')||'</th>');
				htp.p('<th>'||fun.lang('CONDI&Ccedil;&Atilde;O')||'</th>');
				htp.p('<th>'||fun.lang('VALOR')||'</th>');
				htp.p('<th></th>');
			htp.p('</tr>');
		htp.p('</thead>');
		htp.p('<tbody class="ajax">');
			open crs_filtros;
				loop
					fetch crs_filtros into ws_filtro;
					exit when crs_filtros%notfound;
					htp.p('<tr>');
						
						htp.p('<td>'||ws_filtro.micro_visao||'</td>');
						
						htp.p('<td class="fake-list">');
                            htp.p('<a class="script" onclick="call(''updateReportFilter'',''prm_filter='||ws_filtro.id||'&prm_campo=coluna&prm_valor=''+encodeURIComponent(document.getElementById(''filtro-coluna-'||ws_filtro.id||''').title), ''COM'').then(function(resposta){ if(resposta.indexOf(''FAIL'') == -1){ alerta(''feed-fixo'', TR_AL); } });"></a>');
							fcl.fakeoption('filtro-coluna-'||ws_filtro.id, '', ws_filtro.coluna, 'lista-colunas', 'N', 'N', ''||ws_filtro.micro_visao||'', '');
						htp.p('</td>');
							
						htp.p('<td>');
							htp.p('<a class="script" onclick="call(''updateReportFilter'',''prm_filter='||ws_filtro.id||'&prm_campo=condicao&prm_valor=''+encodeURIComponent(document.getElementById(''filtro-condicao-'||ws_filtro.id||''').title), ''COM'').then(function(resposta){ if(resposta.indexOf(''FAIL'') == -1){ alerta(''feed-fixo'', TR_AL); } });"></a>');
							fcl.fakeoption('filtro-condicao-'||ws_filtro.id||'', '', ws_filtro.condicao, 'lista-condicoes', 'N', 'N', '', '', '', fun.dcondicao(ws_filtro.condicao));
						htp.p('</td>');

						htp.p('<td>');
							htp.p('<a class="script" onclick="call(''updateReportFilter'',''prm_filter='||ws_filtro.id||'&prm_campo=valor&prm_valor=''+encodeURIComponent(document.getElementById(''filtro-valor-'||ws_filtro.id||''').title), ''COM'').then(function(resposta){ if(resposta.indexOf(''FAIL'') == -1){ alerta(''feed-fixo'', TR_AL); } });"></a>');
							fcl.fakeoption('filtro-valor-'||ws_filtro.id, '', ws_filtro.valor, 'lista-valores', 'S', 'N', ''||ws_filtro.micro_visao||'', '', 'filtro-coluna-'||ws_filtro.id, ws_filtro.valor);
						htp.p('</td>');
						
						--htp.p('<td>'||ws_filtro.coluna||'</td>');
						--htp.p('<td>'||ws_filtro.condicao||'</td>');
						--htp.p('<td>'||ws_filtro.valor||'</td>');
						htp.p('<td>');
							fcl.button_lixo('deleteReportFilter','prm_filter', ws_filtro.id, prm_pkg => 'COM');
						htp.p('</td>');
					htp.p('</tr>');
				end loop;
			close crs_filtros;
		htp.p('</tbody>');
	htp.p('</table>');

	htp.p('<div class="listar">');
		-- htp.p('<a onclick="call(''report'', '''', ''COM'').then(function(resposta){ document.getElementById(''content'').innerHTML = resposta; call(''menu'', ''prm_menu=report'').then(function(resp){ document.getElementById(''painel'').innerHTML = resp; refreshSupBtn(''A''); }); });">'||fun.lang('VOLTAR')||'</a>');
		htp.p('<a onclick="carregaTelasup(''report'', '''', ''COM'', ''report'', '''', '''', '''')">'||fun.lang('VOLTAR')||'</a>');		
	htp.p('</div>');

end reportFilter;

procedure addReportFilter ( prm_report   varchar2, 
                            prm_usuario  varchar2,
							prm_visao    varchar2,
							prm_coluna   varchar2,
							prm_condicao varchar2,
							prm_conteudo varchar2 ) as
    ws_count number := 0; 
	ws_error exception;				  
	ws_id    number := 0;				  
begin

    select max(id) into ws_id from bi_report_filter;

	if nvl(ws_id, 0) = 0 then
        ws_id := 1;
	else
        ws_id := ws_id+1;
	end if;

    insert into bi_report_filter (coluna, condicao, id, micro_visao, nm_usuario, report_id, valor) 
	values (prm_coluna, prm_condicao, ws_id, prm_visao, prm_usuario, prm_report, prm_conteudo);

	ws_count := SQL%ROWCOUNT;
			
	if ws_count = 1 then
		commit;
	else
		rollback;
		raise ws_error;
	end if;

	htp.p('ok');

exception 
    when ws_error then
        htp.p('ERRO AO INSERIR REGRA DO REPORT');
	when others then
	    htp.p('ERRO '||SQLERRM);
end addReportFilter;

procedure updateReportFilter ( prm_filter number, 
							   prm_campo  varchar2 default null,
							   prm_valor  varchar2 default null ) as

	ws_count number;

begin

    case UPPER(prm_campo)

	when 'COLUNA' then

		update bi_report_filter
		set coluna = prm_valor
		where id = prm_filter;
		--commit;

	when 'CONDICAO' then

		update bi_report_filter
		set condicao = prm_valor
		where id = prm_filter;

	when 'VALOR' then

		update bi_report_filter
		set valor = prm_valor
		where id = prm_filter;

	when 'MICRO_VISAO' then

		update bi_report_filter
		set valor = prm_valor
		where id = prm_filter;

	end case;

	ws_count := sql%rowcount;

	if ws_count = 1 then
		htp.p('OK|');
		commit;
	else
		htp.p('ERRO|');
		rollback;
	end if;

exception when others then
	htp.p('ERRO|');
	rollback;
end updateReportFilter;


procedure deleteReportFilter ( prm_filter number ) as

	ws_count number;

begin

    delete from bi_report_filter
	where id = prm_filter;

	ws_count := sql%rowcount;

	if ws_count = 1 then
		htp.p('ok');
		commit;
	else
		htp.p('erro');
		rollback;
	end if;

exception when others then
	htp.p('erro');
	rollback;
end deleteReportFilter;



procedure reportLog (  prm_id varchar2 default null ) as

    cursor c_fila is
	select * from ( select * from bi_report_fila
					 where id_report = prm_id
					   and dt_criacao >= trunc(sysdate - 30)
					 order by dt_criacao desc, dt_inicio desc
		          )
	 where rownum <= 50; -- Lista somente as 50 primeiras linhas 

	ws_desc   varchar2(500);
	ws_style  varchar2(100); 
begin
    
    -- Atualiza reports que estão aguardando na fila 
    com.checkFila ; 

	htp.p('<input type="hidden" id="content-atributos" data-refresh="reportlog" data-pkg="com" data-par-col="prm_id" data-par-val="'||prm_id||'">');

	htp.p('<input type="hidden" id="prm_id" value="'||prm_id||'">');

	htp.p('<table class="linha">');
		htp.p('<thead>');
			htp.p('<tr >');
				htp.p('<th>'||fun.lang('CRIACAO')||'</th>');
				htp.p('<th>'||fun.lang('INICIO')||'</th>');
				htp.p('<th>'||fun.lang('FIM')||'</th>');
				htp.p('<th>'||fun.lang('SITUACAO')||'</th>');
				htp.p('<th>'||fun.lang('ERRO')||'</th>');
				--htp.p('<th>'||fun.lang('ÚLTIMA EXECU&Ccedil;&Atilde;O')||'</th>');
			htp.p('</tr>');
		htp.p('</thead>');
		htp.p('<tbody id="etl-schedule">');


		for a in c_fila loop
			htp.p('<tr>');

				ws_desc := fun.lista_padrao_ds('REPORT_STATUS', a.status);  	
				if a.status in ('E','EF','C') then 
					ws_style := ' style="line-height: 20px;color:var(--vermelho-secundario);"'; 
				else 
					ws_style := ' style="line-height: 20px;"'; 				
				end if; 
				htp.p('<td>'||to_char(a.dt_criacao,'DD/MM/YYYY HH24:MI:SS')||'</td>');
				htp.p('<td>'||to_char(a.dt_inicio,'DD/MM/YYYY HH24:MI:SS')||'</td>');
				htp.p('<td>'||to_char(a.dt_final,'DD/MM/YYYY HH24:MI:SS')||'</td>');
				htp.p('<td '||ws_style||'>'||ws_desc||'</td>');
				htp.p('<td '||ws_style||'>'||a.erros||'</td>');
			htp.p('</tr>');
		end loop;
		
		htp.p('</tbody>');
	htp.p('</table>');
		
	htp.p('<div class="listar">');
		--htp.p('<a onclick="call(''report'', '''', ''COM'').then(function(resposta){ document.getElementById(''content'').innerHTML = resposta; call(''menu'', ''prm_menu=report'').then(function(resp){ document.getElementById(''painel'').innerHTML = resp; refreshSupBtn(''A'');}); });">'||fun.lang('VOLTAR')||'</a>');
		htp.p('<a onclick="carregaTelasup(''report'', '''', ''COM'', ''report'', '''', '''', '''')">'||fun.lang('VOLTAR')||'</a>');				
	htp.p('</div>');

end reportLog;



procedure reportExec as 

    cursor crs_tarefas is
    	select t1.id, t2.semana, t2.dia_mes, t2.mes, t2.hora, t2.quarter, t2.ultimo_status, t2.ultima_data
    	  from  bi_report_schedule t2
		  left join bi_report_list t1 on t1.id = t2.report_id and t1.id_ativo = 'S';

	cursor c_fila (p_id number) is  
		select status
	      from bi_report_fila 
	     where id_report = p_id
	     order by dt_criacao desc;

    ws_date             date;
    ws_semana           number;
	ws_dia_mes          number;
    ws_mes              number;
    ws_hora             number;
    ws_quarter          number;
    ws_check            number     := 0;
	ws_check_semana     number     := 0;
	ws_check_dia_mes    number     := 0;
	ws_check_mes        number     := 0;	
	ws_check_hora       number     := 0;
	ws_check_quarter    number     := 0;

	ws_parametros       varchar2(800) := '';
	ws_status           varchar2(1); 	
	ws_erros            varchar2(4000); 

 BEGIN

	ws_date       := sysdate;
    ws_semana     := to_number(to_char(ws_date,'D'));
	ws_dia_mes    := to_number(to_char(ws_date,'DD'));
    ws_mes        := to_number(to_char(ws_date,'MM'));
    ws_hora       := to_number(to_char(ws_date,'HH24'));
    ws_quarter    := to_number(to_char(ws_date,'MI'));

    for a in crs_tarefas loop
		
		-- Faz o envio ou coloca na fila de envio 
		--------------------------------------------------------------------------------------
		if (nvl(a.semana,  'N/A') <> 'N/A' or nvl(a.dia_mes, 'N/A') <> 'N/A' ) and 
		   nvl(a.mes,     'N/A') <> 'N/A' and 
		   nvl(a.hora,    'N/A') <> 'N/A' and
		   nvl(a.quarter, 'N/A') <> 'N/A' then
			if a.dia_mes is not null then 
				select count(column_value) into ws_check_dia_mes from table(fun.vpipe(a.dia_mes)) where column_value = ws_dia_mes;
			else
				select count(column_value) into ws_check_semana  from table(fun.vpipe(a.semana))  where column_value = ws_semana;
			end if;
			select count(column_value) into ws_check_mes     from table(fun.vpipe(a.mes))     where column_value = ws_mes;
			select count(column_value) into ws_check_hora    from table(fun.vpipe(a.hora))    where column_value = ws_hora;
			select count(column_value) into ws_check_quarter from table(fun.vpipe(a.quarter)) where column_value = ws_quarter;

			if (ws_check_dia_mes + ws_check_semana + ws_check_mes + ws_check_hora + ws_check_quarter) >= 4 then 
				begin
					sendReport('JOB', a.id );
				exception when others then
					insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - COM', user, 'ERRO');
					commit;
				end;
			end if;		
		end if;
    end loop;

    -- Atualiza reports que estão aguardando na fila 
    com.checkFila ; 

 exception when others then
    insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - COM', user, 'ERRO');
    commit;
END reportExec;



procedure checkFila as 
	ws_qt_erro 			integer; 
	ws_qt_finalizado	integer;	
	ws_qt_aberto    	integer; 
	ws_qt_enviando     	integer; 
	ws_qt_relatorio     integer;              
	ws_qt_total     	integer; 
	ws_status  			varchar2(20); 
	ws_iu               varchar2(100); 
begin 

	if upper(nvl(fun.ret_var('COM_TIPO_ENVIO'),'R')) = 'L' then  
		
		for a in (select id, nvl(id_report_fila,'N/A') as id_report_fila, qt_tentativa_envio 
		            from bi_report_list 
				   where id_situacao_envio in ('A','R') ) loop  -- Aguardando o envio
			select sum(decode(status,'E',1,0)), 
				   sum(decode(status,'R',1,0)),
				   sum(decode(status,'P',1,0)),
			       sum(decode(status,'A',1,0)),
			       sum(decode(status,'F',1,0)), 
				   count(*)   
		      into ws_qt_erro, ws_qt_enviando, ws_qt_relatorio, ws_qt_aberto, ws_qt_finalizado, ws_qt_total 
	  		  from bi_report_fila 
			 where id_report_fila = a.id_report_fila; 
			--	
			if    ws_qt_erro       > 0 then ws_status := 'E';
			elsif ws_qt_enviando   > 0 then ws_status := 'R';
			elsif ws_qt_relatorio  > 0 then ws_status := 'P';
			elsif ws_qt_aberto     > 0 then ws_status := 'A';				
			elsif ws_qt_finalizado > 0 then ws_status := 'F';
			elsif ws_qt_total      > 0 then ws_status := 'E';
			else ws_status := 'EF';  -- Erro adicionando na fila 
			end if;  	 
			--
			if ws_status = 'E' and a.qt_tentativa_envio < 5 then 
				update bi_report_list 
				   set qt_tentativa_envio = qt_tentativa_envio + 1
				 where id = a.id; 
				--
				for b in ( select * from bi_report_fila where id_report_fila = a.id_report_fila and status = 'E') loop
					ws_iu := b.iu_report_fila||'-'||a.qt_tentativa_envio; --fun.randomCode(15)||'_'||b.id_report; 
					insert into bi_report_fila (iu_report_fila, id_report_fila, id_report, destinatario, assunto, mensagem, tp_conteudo, nm_conteudo, largura_folha, altura_folha, dt_criacao, status, erros)
										values (ws_iu, b.id_report_fila, b.id_report, b.destinatario, b.assunto, b.mensagem, b.tp_conteudo, b.nm_conteudo, b.largura_folha, b.altura_folha, sysdate, 'A', null) ; 
					update bi_report_fila
					   set status   = 'C'
					 where iu_report_fila = b.iu_report_fila; 
				end loop; 	   
			else 		
				update bi_report_list 
				   set id_situacao_envio = ws_status 
			 	 where id = a.id; 
				
				-- Comentando temporariamente para conseguir testar no Python 
				-- for b in (select nm_conteudo from bi_report_fila where id_report_fila = a.id_report_fila and tp_conteudo in ('EXCEL','HTML') and status  = 'F') loop   
				--	delete tab_documentos where name = b.nm_conteudo ;
				--end loop; 	 

			end if; 	

			commit; 	

		end loop; 	 	
		--
	end if; 	
exception when others then 
	insert into bi_log_sistema values(sysdate, 'checkFila: '||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 'DWU', 'ERRO');
    commit;
end checkFila; 



procedure sendReport( prm_chamada    varchar2 default 'BI', 
					  prm_id_report  varchar2) as 

	cursor c_report is 
		select * from bi_report_list 
		where id = prm_id_report ; 

	ws_rep         c_report%rowtype; 
	ws_com_end       varchar2(300);
	ws_apikey        varchar2(300);
	ws_parametros    varchar2(12000);
	ws_url           varchar2(2000);
	-- ws_url_tela      varchar2(2000);
	ws_token         varchar2(80);
	ws_msg           varchar2(18000);
	ws_comando       varchar2(32000);
	ws_retorno       varchar2(500); 
	ws_erro_sistema  varchar2(500); 
	ws_iu               varchar2(100);
	ws_id_fila          varchar2(100); 
    ws_tipo_envio       varchar2(10);
	ws_com_servico      varchar2(200);
	ws_com_porta        varchar2(200);
	ws_com_usuario      varchar2(200);
	ws_com_senha        varchar2(200);
	ws_ds_log_fila      varchar2(400);
	ws_ds_log_envio     varchar2(400);
	ws_id_situacao      varchar2(30); 
	ws_tp_objeto        varchar2(30); 
	ws_status           varchar2(2);
	ws_sq_destinatario  integer; 
	ws_usuario          varchar2(200);
	ws_tp_conteudo      varchar2(20);
	ws_nm_conteudo      varchar2(200);
	ws_raise_email   exception; 

begin

	ws_usuario     := gbl.getUsuario; 
	ws_tipo_envio  := upper(nvl(fun.ret_var('COM_TIPO_ENVIO'),'R')); 
	ws_com_servico := fun.ret_var('COM_SERVICO');
	ws_com_porta   := fun.ret_var('COM_PORTA');
	ws_com_usuario := fun.ret_var('COM_USUARIO');
	ws_com_senha   := fun.ret_var('COM_SENHA');	
	ws_com_end     := fun.ret_var('COM_END') ; 
	ws_apikey      := fun.ret_var('COM_KEY') ; 
	
	-- Valida parametrização de envio de email 
	if ws_com_end is null then 
		ws_retorno := 'Erro, falta parametrizacao de URL do BI do processo de REPORT.';
		raise ws_raise_email;
	end if; 
	if ws_tipo_envio = 'R' then 
		if ws_apikey is null then 
			ws_retorno := 'Erro, falta parametrizacao da Chave do processo de REPORT.';
			raise ws_raise_email;
		end if; 
	else
		if ws_com_servico is null or ws_com_porta is null or ws_com_usuario is null or ws_com_senha is null then 
			ws_retorno := 'Erro, falta parametrizacao de envio do REPORT, verifique servico, porta, usuario e senha do processo de REPORT.';
			raise ws_raise_email;			
		end if; 
	end if; 

	open  c_report;
	fetch c_report into ws_rep; 
	close c_report;

	-- Pega parametros de filtro 
	---------------------------------------------------------------------
	for i in(select coluna, decode(trim(condicao),'IGUAL','$[IGUAL]','DIFERENTE','$[DIFERENTE]','MAIOR','$[MAIOR]','MENOR','$[MENOR]','MAIOROUIGUAL','$[MAIOROUIGUAL]','MENOROUIGUAL','$[MENOROUIGUAL]','LIKE','$[LIKE]','NOTLIKE','$[NOTLIKE]','$[IGUAL]') as condicao, valor 
			from bi_report_filter 
			where report_id = prm_id_report
			) loop
		ws_parametros := ws_parametros||'|'||i.coluna||'|'||i.condicao||i.valor;
	end loop;
	if nvl(ws_parametros, 'N/A') <> 'N/A' then
		ws_parametros := substr(ws_parametros, 2, length(ws_parametros)-1);
	end if;

	-- Monta mensagem 
	ws_msg := ws_rep.msg; 
	ws_msg := replace(ws_msg, '$[SCREEN]', fun.nomeObjeto(ws_rep.cd_objeto));  
	ws_msg := replace(ws_msg, '$[TELA]', fun.nomeObjeto(ws_rep.cd_objeto));  	
	ws_msg := replace(ws_msg, '$[OBJETO]', fun.nomeObjeto(ws_rep.cd_objeto));
	ws_msg := replace(ws_msg, '$[USUARIO]',   ws_rep.usuario);
	ws_msg := fun.subpar(ws_msg, ws_rep.cd_objeto, prm_usuario => ws_rep.usuario, prm_param_filtro => ws_parametros);

	-- Verifica dados de envio do email 
	ws_retorno := null; 
	if ws_rep.email is null or ws_rep.cd_objeto is null or ws_rep.assunto is null or ws_msg is null then 
		ws_retorno := 'Erro nos dados do envio, todos os campos devem ser preenchidos';
		raise ws_raise_email;
	end if; 

	select max(tp_objeto) into ws_tp_objeto 
	  from objetos 
 	 where cd_objeto = ws_rep.cd_objeto ;

	-- Tipo de envio Remoto so envio TELA
	ws_retorno := null; 
	if ws_tipo_envio = 'R' and ws_tp_objeto <> 'SCREEN' then 
		ws_retorno := 'Tipo de envio parametrizado(Remoto) permite somente o envio de TELAS';
		raise ws_raise_email;
	end if; 

	if ws_tp_objeto = 'SCREEN' then  

		-- Monta URL da tela com um token
		------------------------------------------------------------------------
		delete from bi_sessao where valor = trim(upper(ws_rep.usuario)) and cod like ('ANONYMOUS%');
		commit;
		ws_token    := gbl.retToken(ws_rep.usuario, ws_rep.cd_objeto);
		ws_url      := '/'||nvl(fun.ret_var('OWNER_BI'),'DWU')||'.fcl.show_screen?prm_screen='||ws_rep.cd_objeto||'&prm_parametro='||ws_parametros||'&prm_clear=R&prm_token='||ws_token;

		ws_tp_conteudo := 'URL';
		ws_nm_conteudo  := ws_com_end||ws_url;
		ws_status   := 'A'; 
	elsif ws_tp_objeto = 'RELATORIO' then 
		ws_tp_conteudo := 'EXCEL';
		ws_nm_conteudo := null;
		ws_status      := 'P'; 
	elsif ws_tp_objeto = 'CONSULTA' then 
		ws_tp_conteudo := 'HTML';
		ws_nm_conteudo := null;
		ws_status      := 'P'; 
	else 
		ws_retorno := 'Tipo de objeto selecionado n&atilde;o corresponte a uma tela ou relat&oacute;rio';
		raise ws_raise_email;	
	end if; 

	-- Faz um envio para cada destinatario de email 
	ws_erro_sistema    := null;
	ws_sq_destinatario := 0;
	ws_id_fila         := fun.randomCode(15)||'_'||ws_rep.id;
	ws_rep.email       := replace(ws_rep.email,';','|');
	for b in (select column_value as destinatario from table(fun.vpipe(ws_rep.email)) where column_value is not null) loop
		
		ws_sq_destinatario := ws_sq_destinatario + 1; 
		if ws_erro_sistema is null then -- Se não deu erro no envio anterior 

			if ws_tipo_envio = 'R' then -- Envio remoto através do serviço/servidor upquery 
				ws_comando :=  'BEGIN '||nvl(fun.ret_var('OWNER_BI'),'DWU')||'.send_report(
										prm_to       => '''||b.destinatario   ||''',  
										prm_message  => '''||ws_msg      ||''',  
										prm_subject  => '''||ws_rep.assunto ||''',  
										prm_url_bi   => '''||ws_com_end  ||''', 
										prm_url_tela => '''||ws_url      ||''',   
										prm_apikey   => '''||ws_apikey   ||''',    
										prm_filename => ''relatorio.pdf'',
										prm_retorno  => :b1 );
								END;' ;
				begin 				
					execute immediate ws_comando using out ws_erro_sistema; 
				exception when others then 
					ws_erro_sistema := substr(DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,400); 
				end; 	

				if ws_erro_sistema is not null then 
					ws_retorno     := 'Erro enviando email, entre em contato com o administrador do sistema'; 
					ws_id_situacao := 'E'; 				
				else 
					ws_retorno     := 'Email enviado com sucesso'; 			
					ws_id_situacao := 'F'; 				
				end if; 	
				--
				update bi_report_list set id_situacao_envio = ws_id_situacao where id = prm_id_report;
				commit; 
				--
				if ws_id_situacao = 'E' then  -- Se deu erro no envio 
					raise ws_raise_email; 	
				end if; 			
			else 

				-- Insere na fila -  se for relatório insere com status P e depois executa o job que vai gerar o relatório, para somente depois enviar 
				-------------------------------------------------
 				begin 
					delete bi_report_fila 
					 where id_report    = ws_rep.id 
					   and destinatario = b.destinatario
					   and status      in ('A','P');
					ws_iu := fun.randomCode(15)||'_'||ws_rep.id;	
					insert into bi_report_fila (iu_report_fila, id_report_fila, id_report, destinatario, assunto, mensagem, tp_conteudo, nm_conteudo, largura_folha, altura_folha, dt_criacao, status, erros)
										values (ws_iu, ws_id_fila, ws_rep.id, b.destinatario, ws_rep.assunto, ws_msg, ws_tp_conteudo, ws_nm_conteudo, nvl(ws_rep.largura_folha,1920), nvl(ws_rep.altura_folha,1080), sysdate, ws_status, null) ; 
					ws_id_situacao := ws_status; 
					ws_retorno     := 'Adicionado a fila, aguardando o envio';
				exception when others then 
					ws_id_situacao  := 'EF'; 
					ws_retorno      := 'Erro adicionando email da fila de envio, verifique log do sistema'; 
					ws_erro_sistema := DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
				end; 												
				--
				update bi_report_list set id_situacao_envio = ws_id_situacao, id_report_fila = ws_id_fila, qt_tentativa_envio = 1 where id = ws_rep.id;
				commit; 
				--
				if ws_id_situacao not in ('A','P') then  -- Se deu erro ao inserir na fila 
					raise ws_raise_email; 	
				end if; 			
				--
			end if; 
		end if; 
	end loop; 
	--
	-- Se for relatório (e envio Local), cria o job que irá gerar o relatório e atualizar a fila 
	if ws_tipo_envio = 'L' then 
	    if ws_tp_objeto = 'RELATORIO' then
			fun.EXECUTE_NOW('com.geraRelatorio('||ws_rep.id||','''||ws_id_fila||''','''||ws_rep.usuario||''')' );
		elsif ws_tp_objeto = 'CONSULTA' then
			fun.EXECUTE_NOW('com.geraConsulta('||ws_rep.id||','''||ws_id_fila||''','''||ws_rep.usuario||''')' );
		end if; 	
	end if; 

	if prm_chamada = 'BI' then 
		htp.p('OK|'||ws_retorno);		
	end if; 		
	--
exception 
	when ws_raise_email then 
		if ws_erro_sistema is not null then
	    	insert into bi_log_sistema values(sysdate, 'COM.SENDREPORT : '||ws_erro_sistema, 'DWU', 'ERRO');
    		commit;
		end if; 
		if prm_chamada = 'BI' then 
			htp.p('ERRO|'||ws_retorno);		
		end if; 	
	when others then
		ws_erro_sistema := substr(DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,400); 
		ws_retorno      := 'Erro na prepara&ccedil;&atilde;o do email, entre em contato com o administrador do sistema'; 
    	insert into bi_log_sistema values(sysdate, 'COM.SENDREPORT (others) :'||ws_erro_sistema, 'DWU', 'ERRO');
    	commit;
		if prm_chamada = 'BI' then 
			htp.p('ERRO|'||ws_retorno);	
		end if; 	
end sendReport;


procedure geraRelatorio( prm_id_report       number, 
						 prm_id_report_fila  varchar2,
						 prm_usuario         varchar2 ) as 
	--
	cursor c_report is 
		select * from bi_report_list 
		where id = prm_id_report ; 
	--
	ws_rep           c_report%rowtype; 
	ws_atributos     varchar2(4000);
	ws_ds_erro       varchar2(300);   
	ws_nm_arq        varchar2(300);   
	ws_content_type  varchar2(100);  
	ws_screen        varchar2(100);   
	ws_blob          blob; 
	ws_status        varchar2(2);
	ws_parametros    varchar2(32000); 
	ws_raise_report  exception; 
begin

	open  c_report;
	fetch c_report into ws_rep;
	close c_report; 
	
	if ws_rep.id is null then 
		ws_ds_erro := 'Erro, nao existe REPORT cadastrado com esse ID <'||prm_id_report||'>.';
		raise ws_raise_report;
	end if; 
	
	select max(atributos) into ws_atributos from objetos where cd_objeto = ws_rep.cd_objeto;
	if ws_atributos is null then 
		ws_ds_erro := 'Erro, relatorio <'||ws_rep.cd_objeto||'> nao possui consulta cadastrada, corrija o relatorio.';
		raise ws_raise_report;
	end if; 

	select min(screen) into ws_screen 
	  from object_location l
     where l.screen like 'SRC_%'
       and l.object_id = ws_rep.cd_objeto
	   and fun.check_screen_access(l.screen, ws_rep.usuario, gbl.getnivel(nvl(ws_rep.usuario,'N')) ) > 0 ; 

	if ws_screen is null then 
		ws_ds_erro := 'Erro, relat&oacute;rio <'||ws_rep.cd_objeto||'> n&atilde;o pertence a uma tela ou o usu&aacute;rio n&atilde;o tem permiss&atilde;o a tela do relat&oacute;rio.';
		raise ws_raise_report;
	end if; 

	-- Pega parametros de filtro 
	---------------------------------------------------------------------
	ws_parametros := null;
	for i in(select coluna, decode(trim(condicao),'IGUAL','$[IGUAL]','DIFERENTE','$[DIFERENTE]','MAIOR','$[MAIOR]','MENOR','$[MENOR]','MAIOROUIGUAL','$[MAIOROUIGUAL]','MENOROUIGUAL','$[MENOROUIGUAL]','LIKE','$[LIKE]','NOTLIKE','$[NOTLIKE]','$[IGUAL]') as condicao, valor 
			   from bi_report_filter 
		  	  where report_id = prm_id_report
			) loop
		ws_parametros := ws_parametros||'|'||i.coluna||'|'||i.condicao||i.valor;
	end loop;
	if nvl(ws_parametros, 'N/A') <> 'N/A' then
		ws_parametros := substr(ws_parametros, 2, length(ws_parametros)-1);
	end if;


	ws_nm_arq := 'REL_'||ws_rep.cd_objeto||'_'||prm_id_report_fila||'.xls'; 
	delete tab_documentos where name = ws_nm_arq ;
 	insert into tab_documentos values(ws_nm_arq, 'application/octet', '', 'ascii', sysdate, 'LOCKED', '', 'DWU');
    commit;

	up_rel.main ( ws_rep.cd_objeto, ws_screen, null, user, ws_rep.usuario, ws_nm_arq, ws_parametros); 

	begin 
		select content_type, blob_content into ws_content_type, ws_blob
	      from tab_documentos 
	     where name = ws_nm_arq; 
	exception when others then 
		ws_ds_erro := 'Erro, relatorio nao gerou arquivo.';
		raise ws_raise_report;
	end;	 

	if ws_content_type = 'BLOB' then 
		ws_status := 'A';
		ws_ds_erro := null; 
	else 		         
		ws_status  := 'E';
		ws_ds_erro := substr(fun.b2c(ws_blob),1,3999); 
	end if; 

	update bi_report_fila set status = ws_status, nm_conteudo = ws_nm_arq, erros = ws_ds_erro  where id_report_fila = prm_id_report_fila;  	   
	update bi_report_list set id_situacao_envio = ws_status where id = prm_id_report ;		 
	commit; 
exception 
	when ws_raise_report then 
		update bi_report_fila set status = 'E', erros = ws_ds_erro  where id_report_fila = prm_id_report_fila; 
		update bi_report_list set id_situacao_envio = 'E' where id = prm_id_report ; 
	    commit;
	when others then
		ws_ds_erro      := 'Erro (Outros) tentando gerar o relat&oacute;rio - '||substr(DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,400); 
		update bi_report_fila set status = 'E',  erros   = ws_ds_erro where id_report_fila = prm_id_report_fila; 
		update bi_report_list set id_situacao_envio = 'E' where id = prm_id_report ; 
		commit; 
end geraRelatorio;



procedure geraConsulta ( prm_id_report       number, 
						 prm_id_report_fila  varchar2,
						 prm_usuario         varchar2 ) as 
	--
	cursor c_report is 
		select * from bi_report_list 
		where id = prm_id_report ; 
	--
	ws_rep           c_report%rowtype; 
	ws_ds_erro       varchar2(300);   
	ws_nm_arq        varchar2(300);   
	ws_content_type  varchar2(100);  
	ws_screen        varchar2(100);   
	ws_blob          blob; 
	ws_status        varchar2(2);
	ws_id            varchar2(200);
	ws_parametros    clob; 

	ws_raise_report  exception; 
begin

	open  c_report;
	fetch c_report into ws_rep;
	close c_report; 
	
	if ws_rep.id is null then 
		ws_ds_erro := 'Erro, nao existe REPORT cadastrado com esse ID <'||prm_id_report||'>.';
		raise ws_raise_report;
	end if; 

	select min(screen) into ws_screen 
	  from (select level as nivel, ol.screen 
		      from object_location ol
		     start with ol.object_id = ws_rep.cd_objeto
			 connect by prior ol.screen = ol.object_id
		    ) ol2
	  where ol2.screen like 'SRC_%'
	    and fun.check_screen_access(ol2.screen, ws_rep.usuario, nvl(gbl.getnivel(ws_rep.usuario),'N') ) > 0 ; 

	if ws_screen is null then 
		ws_ds_erro := 'Erro, consulta/objeto <'||ws_rep.cd_objeto||'> n&atilde;o pertence a uma tela ou o usu&aacute;rio n&atilde;o tem permiss&atilde;o a tela da consulta.';
		raise ws_raise_report;
	end if; 

	-- Pega parametros de filtro 
	---------------------------------------------------------------------
	ws_parametros := null;
	for i in(select coluna, decode(trim(condicao),'IGUAL','$[IGUAL]','DIFERENTE','$[DIFERENTE]','MAIOR','$[MAIOR]','MENOR','$[MENOR]','MAIOROUIGUAL','$[MAIOROUIGUAL]','MENOROUIGUAL','$[MENOROUIGUAL]','LIKE','$[LIKE]','NOTLIKE','$[NOTLIKE]','$[IGUAL]') as condicao, valor 
			   from bi_report_filter 
		  	  where report_id = prm_id_report
			) loop
		ws_parametros := ws_parametros||'|'||i.coluna||'|'||i.condicao||i.valor;
	end loop;
	if nvl(ws_parametros, 'N/A') <> 'N/A' then
		ws_parametros := substr(ws_parametros, 2, length(ws_parametros)-1);
	end if;

	ws_nm_arq := 'REL_'||ws_rep.cd_objeto||'_'||prm_id_report_fila||'.html'; 
	delete tab_documentos where name = ws_nm_arq ;
 	insert into tab_documentos values(ws_nm_arq, 'application/octet', '', 'ascii', sysdate, 'LOCKED', '', 'DWU');
    commit;

    obj.show_objeto( prm_drill      => 'R',  -- Report  
                     prm_objeto     => ws_rep.cd_objeto,
					 prm_parametros => ws_parametros, 
                     prm_posx       => '1',
                     prm_screen     => ws_screen,
                     prm_dashboard  => 'false',
                     prm_usuario    => ws_rep.usuario,
					 prm_objeton    => ws_nm_arq);

	begin 
		select content_type, blob_content into ws_content_type, ws_blob
	      from tab_documentos 
	     where name = ws_nm_arq; 
	exception when others then 
		ws_ds_erro := 'Erro, relatorio nao gerou arquivo da consulta.';
		raise ws_raise_report;
	end;	 

	if ws_content_type = 'BLOB' then 
		ws_status := 'A';
		ws_ds_erro := null; 
	else 		         
		ws_status  := 'E';
		ws_ds_erro := substr(fun.b2c(ws_blob),1,3999); 
	end if; 

	update bi_report_fila set status = ws_status, nm_conteudo = ws_nm_arq, erros = ws_ds_erro  where id_report_fila = prm_id_report_fila;  	   
	update bi_report_list set id_situacao_envio = ws_status where id = prm_id_report ;		 
	commit; 
exception 
	when ws_raise_report then 
		update bi_report_fila set status = 'E', erros = ws_ds_erro  where id_report_fila = prm_id_report_fila; 
		update bi_report_list set id_situacao_envio = 'E' where id = prm_id_report ; 
	    commit;
	when others then
		ws_ds_erro      := 'Erro (Outros) tentando gerar o relat&oacute;rio - '||substr(DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,400); 
		update bi_report_fila set status = 'E',  erros   = ws_ds_erro where id_report_fila = prm_id_report_fila; 
		update bi_report_list set id_situacao_envio = 'E' where id = prm_id_report ; 
		commit; 
end geraConsulta;


end COM;
