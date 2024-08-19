create or replace package body IMP is


	procedure import_test (  prm_arquivo     varchar2 default null,
							 prm_tabela      varchar2 default null,
							 --prm_usuario   varchar2 default 'DWU',
							 --prm_comma     varchar2 default null,
							 --prm_decimal   varchar2 default null,
							 prm_cabecalho   varchar2 default '0',
							 prm_acao        varchar2 default null) as
						
						
	    ws_count            number;
	    ws_counter          number;
	    ws_minus            number;  
	    ws_insert_format    varchar2(8000);
	    ws_create           varchar2(8000);
	    ws_lista            varchar2(4000);
	    ws_erro             varchar2(4000);
	    ws_linha            varchar2(4000);
		ws_usuario			varchar2(300);
	    ws_import_err       exception;
	    ws_semmodelo        exception;
	    ws_errocoluna       exception;
	    ws_date             date;
		ws_tabela			varchar2(200);
		ws_linhas_inseridas varchar2(10);

        begin

			ws_usuario := gbl.getusuario;
			ws_date := sysdate;
			
			select nm_tabela into ws_tabela from modelo_cabecalho where upper(nm_modelo) = upper(prm_tabela); 
			
			-- Verifica se já existe uma tabela com o mesmo nome no banco;
			select count(*) into ws_count from all_tables where owner = nvl(fun.ret_var('OWNER_TABLE_DATA'),'DWU') and table_name = upper(ws_tabela); 
			
			if ws_count = 0 then

			   select count(*) into ws_count from modelo_coluna where upper(nm_modelo) = upper(prm_tabela);
			   
			   
			   if ws_count <> 0 then
			   
			   select listagg(NM_COLUNA||' '||DECODE(upper(TP_COLUNA), 'VARCHAR2', 'VARCHAR2(200)', TP_COLUNA), ', ') within group
			   (order by NR_COLUNA) NM_COLUNA into ws_lista from modelo_coluna where upper(nm_modelo) = upper(prm_tabela) order by nr_coluna;
			   
			   ws_create := 'create table '||nvl(fun.ret_var('OWNER_TABLE_DATA'),'DWU')||'.'||upper(ws_tabela)||'('; 
			   
			   ws_create := ws_create||ws_lista;
			   
			   ws_create := ws_create||')';

			   execute immediate (ws_create);
			   
			   commit;
			   
			   else
			   
				   raise ws_semmodelo;
			   
			   end if;

			else

			    select count(*) into ws_minus from (
				    select column_name from all_tab_columns where table_name = upper(ws_tabela) 
			    minus
			    select nm_coluna from modelo_coluna where nm_modelo = upper(prm_tabela)
			    );

				if ws_minus = 0 then
				--Começa a verificação de colunas;
					select count(*) into ws_minus from (
					select nm_coluna from modelo_coluna where nm_modelo = upper(prm_tabela)
					minus
					select column_name from all_tab_columns where table_name = upper(ws_tabela) 
					);

					if ws_minus <> 0 then
					   raise ws_errocoluna;
					end if;

				else
				   raise ws_errocoluna;
				end if;

				if prm_acao = 'DELETE' then
				
				    ws_create := 'delete from '||nvl(fun.ret_var('OWNER_TABLE_DATA'),'DWU')||'.'||upper(ws_tabela)||''; 
				   
				   execute immediate (ws_create);
				   
				end if;

				select count(*) into ws_count from modelo_coluna where upper(nm_modelo) = upper(prm_tabela);
				   
				if ws_count = 0 then
				   
				    ws_counter := 0;
				   
				    for i in (select column_name, data_type from all_tab_columns where upper(table_name) = upper(ws_tabela)) loop 
					   ws_counter := ws_counter+1;
					   insert into modelo_coluna (id_coluna, nm_modelo, nr_coluna, nm_coluna, nm_destino, tp_coluna, trfs_coluna) values (ws_counter, upper(prm_tabela), ws_counter, i.column_name, i.column_name, lower(i.data_type), '');
				    end loop;
				    commit;
				   
				end if;
				   
			end if;

			import_xls ( lower(prm_arquivo), prm_tabela, '', '', '', prm_cabecalho);

			exception
			    when ws_errocoluna then
				htp.p('FAIL 1'||fun.lang('N&uacute;mero ou nome de colunas do modelo n&atilde;o respeitam as da tabela'));
			when ws_semmodelo then
				htp.p('FAIL 2'||fun.lang('Importa&ccedil;&atilde;o precisa no m&iacute;nimo de um modelo de colunas ou uma tabela selecionada.'));
			when ws_import_err then
				Insert Into bi_log_sistema Values(Sysdate , DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - IMPORT' , ws_usuario , 'ERRO');
				commit;
				htp.p('FAIL 3');
			when others then
				Insert Into bi_log_sistema Values(Sysdate , DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - IMPORT' , ws_usuario , 'ERRO');
				commit;
				htp.p('FAIL 4');
    end import_test;

    procedure import_xls ( prm_arquivo     varchar2 default null,
						   prm_tabela      varchar2 default null,
						   prm_usuario     varchar2 default 'DWU',
						   prm_comma       varchar2 default null,
						   prm_decimal     varchar2 default null,
						   prm_cabecalho   varchar2 default '0' ) as
		
		ws_usuario        	varchar2(300); 
		ws_usuario_arquivo 	varchar2(300); 
		ws_nome_arquivo     varchar2(300);

		cursor c_localiza_arquivo  is 
			select name, usuario, blob_content 
			  from tab_documentos 
			 where lower(name) in ( replace(lower(prm_arquivo), '.xlsx', '')||'.xlsx', replace(lower(prm_arquivo), '.ods', '')||'.ods' ) 
			   and usuario in ('DWU','ANONYMOUS', ws_usuario ) ; 

		cursor crs_seq ( p_nome varchar2,  p_usuario  varchar2) is
			 Select '1' as X,
					cell_type, cell,
					decode(cell_type,'S',string_val,'D',date_val,'N',number_val,'') conteudo,
					row_nr, col_nr
			  from Table( as_read_xlsx.Read( (Select Blob_Content From tab_documentos 
				                               Where name    = p_nome 
										         and usuario = p_usuario ), 1 ) ) 
			 where nvl(sheet_nr,1) = 1
			 order by row_nr, col_nr;

		cursor c_colunas  is
			select * from MODELO_COLUNA
			where upper(nm_modelo) = upper(prm_tabela)
			order by nr_coluna;

		cursor c_mod_col (p_nr_coluna  number ) is
			select * from MODELO_COLUNA
			where upper(nm_modelo) = upper(prm_tabela)
			  and nr_coluna        = p_nr_coluna ;

        type ws_tmcolunas is table of MODELO_COLUNA%ROWTYPE
        index by pls_integer;


		ws_row_ant          	number;
		ws_insert_format    	varchar2(32000);
		ws_create           	varchar2(8000);
		ws_lista            	varchar2(6000);
		ws_erro             	varchar2(6000);
		ws_linha            	varchar2(26000);
		ws_transform        	varchar2(400);
		ws_replacein        	varchar2(400);
		ws_replaceout       	varchar2(400);
		ws_mascara          	varchar2(400);
		ws_col              	number;
		ws_virgula          	varchar2(10);
		ws_valor            	varchar2(25000);
		ws_tabela				varchar2(200);
		ws_cell             	varchar2(10); 
        ws_nm_rotina            varchar2(40);
        ws_comando              varchar2(32000);

		ws_qt_ins  				number;
		ws_qt_arquvos       	number;
		ws_arquivo 				blob;

		Ws_Seq        			Crs_Seq%Rowtype;
		wt_mod_col    			c_mod_col%Rowtype; 

		ws_valida_number    	number;
		ws_valida_date      	date; 

		ws_erro_insert			exception;
		ws_erro_conteudo_arq    exception;
		ws_erro_conteudo_cel	exception;



		begin

            ws_usuario := gbl.getUsuario; 

			select nm_tabela into ws_tabela from modelo_cabecalho where upper(nm_modelo) = upper(prm_tabela); 

     		ws_qt_arquvos := 0;
			for a in c_localiza_arquivo loop 
				ws_qt_arquvos		:= ws_qt_arquvos + 1 ;
				ws_nome_arquivo     := a.name ; 
				ws_usuario_arquivo	:= a.usuario; 
				ws_arquivo      	:= a.blob_content;
			end loop; 

			if ws_qt_arquvos = 1 then

				insert into bi_log_sistema values(sysdate , 'COME&Ccedil;O DA IMPORTA&Ccedil;&Atilde;O('||upper(prm_tabela)||')', ws_usuario, 'EVENTO');
				commit;

				-- Monta a clausula do INSERT com as colunas do modelo e monta arrays   ws_item_array e ws_item_type
				-------------------------------------------------------------------------------------------------------
				ws_insert_format := ''; 
				ws_virgula       := '';
				for a in c_colunas loop 
					ws_insert_format := ws_insert_format||ws_virgula||a.nm_coluna;
					ws_virgula       := ',';
				end loop; 
				ws_insert_format := 'insert into '||nvl(fun.ret_var('OWNER_TABLE_DATA'),'DWU')||'.'||ws_tabela||' ('||ws_insert_format||') values ('; 



				-- Monta os dados de cada linha do arquivo e executa o insert na tabela 
				-------------------------------------------------------------------------------------------------------
				ws_qt_ins  := 0;
				ws_linha   := '';  -- Linha a variável linha para montar com a próxima linha do arquivo 
				ws_virgula := '';
				ws_col     := 0;
                ws_row_ant := 0; 
				ws_cell    := null; 

				Open Crs_Seq(ws_nome_arquivo, ws_usuario_arquivo);
				Loop
					Fetch Crs_Seq Into Ws_Seq;
					Exit When Crs_Seq%Notfound;

					if ws_seq.row_nr is null then 
					   ws_valor := ws_seq.conteudo;
		               raise ws_erro_conteudo_arq; 
					end if; 

					ws_cell := ws_seq.cell; 
					if ws_seq.row_nr > prm_cabecalho then   -- linhas ignoradas do arquivo (cabeçalho)

						-- Insere o registro montado com todas as colunas da linha anterior (quando chega na próxima linha do arquivo) 
						--------------------------------------------------------------------------------------------------------------------------
						if ws_row_ant <> Ws_Seq.row_nr and ws_seq.row_nr > (prm_cabecalho + 1)  then  
							begin
								ws_qt_ins := ws_qt_ins + 1;
								execute immediate (ws_insert_format||ws_linha||')');
							exception
								when others then
								raise ws_erro_insert;
							end;
							ws_linha   := '';  -- Linha a variável linha para montar com a próxima linha do arquivo 
							ws_virgula := '';
							ws_col     := 0;
						end if ;


						-- Monta a linha com os dados a serem inseridos  
						--------------------------------------------------------------------------------------------------------------------------
						ws_col		:= ws_col + 1;
						wt_mod_col	:= null;
						open  c_mod_col(ws_col);
						fetch c_mod_col into wt_mod_col;
						close c_mod_col; 
                            
						if wt_mod_col.nr_coluna is not null then   -- Se o número da coluna existe no modelo, se não existe ignora a coluna do arquivo 

								wt_mod_col.tp_coluna := nvl(lower(wt_mod_col.tp_coluna),'N/A'); 
								ws_valor 			 := replace(Ws_Seq.conteudo, chr(39), '');                              -- Retira aspas simples do conteudo da coluna 
								ws_valor 			 := replace(ws_valor, wt_mod_col.replacein, wt_mod_col.replaceout);     -- substitui do replacein por replaceout
								
								if nvl(trim(wt_mod_col.trfs_coluna), 'N/A') <> 'N/A' then -- Se tem transformação cadastrada, faz a transformação com a mascara 
									begin
										ws_valor := chr(39)||trim(to_char(ws_valor, wt_mod_col.mascara))||chr(39);    -- Tenta aplicar a máscara, se foi informado 
									exception when others then
										ws_valor := chr(39)||ws_valor||chr(39);
									end;
								else 	-- Faz as conversões conforme o tipo de dado 
									if wt_mod_col.tp_coluna = 'null' then
										ws_valor := 'NULL';
									end if;

									if  wt_mod_col.tp_coluna = 'number' then
										ws_valor := replace(nvl(ws_valor, 0),',','.');    -- Se for número substitui virgula por ponto 
										begin 
										   ws_valida_number := ws_valor;
										exception when others then 
										   raise ws_erro_conteudo_cel; 
										end;   
									end if;

									if  wt_mod_col.tp_coluna = 'varchar2' then
										if nvl(wt_mod_col.mascara, 'N/A') <> 'N/A' then  -- Tenta aplicar a máscara, se foi informado 
											begin
												ws_valor := chr(39)||trim(to_char(ws_valor, wt_mod_col.mascara))||chr(39);
											exception when others then
												ws_valor := chr(39)||ws_valor||chr(39);
											end;
										else
											ws_valor := chr(39)||ws_valor||chr(39);
										end if;
									end if;

									if  wt_mod_col.tp_coluna = 'date' then
										begin
										    if nvl(wt_mod_col.mascara, 'N/A') <> 'N/A' then    -- Tenta aplicar a máscara, se foi informado 
												ws_valida_date := to_date(trim(ws_valor), wt_mod_col.mascara); 
												ws_valor := 'to_date('||trim(ws_valor)||', '''||wt_mod_col.mascara||''')';
											else 
												ws_valida_date := to_date(trim(ws_valor)); 
												ws_valor := 'to_date('||ws_valor||')';
											end if; 	
										exception when others then 
											raise ws_erro_conteudo_cel; 
										end; 	
									end if;
								end if;

								ws_linha   := ws_linha||ws_virgula||ws_valor;
								ws_virgula := ',';
						end if;
						
					end if;

					ws_row_ant := Ws_Seq.row_nr;
				End Loop;
				close Crs_Seq;

				-- Insere a ultima linha do arquivo 
				begin
					ws_qt_ins := ws_qt_ins + 1;
					execute immediate (ws_insert_format||ws_linha||')');
				exception
					when others then
					raise ws_erro_insert;
				end;

				commit;  -- COMMIT APLICADO PARA O INSERT COMPLETO DAS LINHAS DO EXCEL. 17/02/2022


				insert into bi_log_sistema values(sysdate, 'FIM DA IMPORTA&Ccedil;&Atilde;O('||upper(prm_tabela)||'). Registros importados: '||ws_qt_ins||', total de linhas do arquivo:'||ws_row_ant, ws_usuario , 'EVENTO');
				commit;

                select nm_rotina_plsql into ws_nm_rotina from modelo_cabecalho where upper(nm_modelo) = upper(prm_tabela);
                
                if ws_nm_rotina is not null then
                    select comando
                      into ws_comando
                      from etl_step
                     where step_id = ws_nm_rotina;

                    if substr(ws_comando, -1) <> ';' then
                        ws_comando := ws_comando||';';
                    end if;
                    ws_comando := 'begin '||ws_comando||' end;';

                    execute immediate ws_comando;
                    commit;
                end if;

				htp.p('IMP Gerado com sucesso. Total de linhas inseridas: '||ws_qt_ins||' linhas');
			
                if ws_nm_rotina is not null then
                    htp.p('P&oacute;s-rotina executada com sucesso!');
                end if;
                
			else
				insert into bi_log_sistema values(sysdate, 'N&uacute;mero inv&aacute;lido de arquivos #'||ws_qt_arquvos, ws_usuario , 'import_xls');
				commit;
				if ws_qt_arquvos = 0 then 
					htp.p('FAIL Arquivo com nome <'||ws_nome_arquivo||'> n&atilde;o localizado no sistema');
				else 	
					htp.p('FAIL Existe mais de um arquivo no sistema com o nome <'||ws_nome_arquivo||'>');
				end if; 
			end if;
		exception
			when ws_erro_insert then
				ROLLBACK;
				insert into bi_log_sistema values(sysdate , 'Erro ao inserir linha <'||ws_row_ant||'> da arquivo. '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - '||ws_insert_format||ws_linha||')', ws_usuario, 'ERRO');
				commit;
			    htp.p('FAIL Erro importando linha ' ||ws_row_ant||', verifique o conte&uacute;do do arquivo ou a configura&ccedil;&atilde;o da importa&ccedil;&atilde;o do modelo');				
			when ws_erro_conteudo_arq then
				ROLLBACK;
				insert into bi_log_sistema values(sysdate , 'Conteúdo do arquivo não reconhecido como XLSX. Erro package AR_READ_XLSX.READ: '||ws_valor, ws_usuario, 'ERRO');
				commit;
			    htp.p('FAIL Formato de arquivo inv&aacute;lido, para importa&ccedil;&atilde;o o arquivo deve estar no formato MS-Excel (.xlsx)');			
			when ws_erro_conteudo_cel then
				ROLLBACK;
				insert into bi_log_sistema values(sysdate , 'Erro na importação da linha '||ws_row_ant||' coluna '||ws_col||' convertendo conte&uacute;do <'||ws_valor||'> para '||upper(wt_mod_col.tp_coluna), ws_usuario, 'ERRO');
				commit;
			    htp.p('FAIL Erro na importa&ccedil;&atilde;o da linha '||ws_row_ant||' coluna '||ws_col||' convertendo conte&uacute;do <'||ws_valor||'> para '||upper(wt_mod_col.tp_coluna) );			
			when others then
				insert into bi_log_sistema values(sysdate , 'Erro importação arquivo, linha: '||ws_row_ant||', coluna: '||ws_col||'. '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - '||ws_insert_format||ws_linha, ws_usuario, 'ERRO');
				commit;
				htp.p('FAIL Erro importando linha '||ws_row_ant||' coluna '||ws_col||', verifique o conte&uacute;do da celula ou a configura&ccedil;&atilde;o da importa&ccedil;&atilde;o');
	end import_xls;




	procedure main ( prm_modelo varchar2 default null,
					 prm_tabela varchar2 default null ) as

		ws_admin          varchar2(20); 

		cursor crs_colunas (prm_tabela varchar2) is
			select 1 ordem, 0 column_id, nm_modelo, nr_coluna, nm_coluna, nm_destino, tp_coluna, trfs_coluna, id_coluna, replacein, replaceout, mascara
			  from modelo_coluna 
		     where upper(nm_modelo) = upper(prm_modelo) 
			union all  
			select 2 ordem, column_id, prm_modelo as nm_modelo, null as nr_coluna, column_name as nm_coluna, '' as nm_destino, '' as tp_coluna, '' as trfs_coluna,
			       null as id_coluna, '' as replacein, '' as replaceout, '' as mascara
			  from all_tab_columns 
			 where owner      =  nvl(fun.ret_var('OWNER_TABLE_DATA'),'DWU')
			   and table_name = upper(prm_tabela) 
			   and column_name not in (select nm_coluna from modelo_coluna where upper(nm_modelo) = upper(prm_modelo) )  
			   and ws_admin   = 'A'
			 order by ordem, nr_coluna, column_id, nm_modelo;

		ws_coluna  crs_colunas%rowtype;
			 
		cursor crs_cabecalho is
			select nm_arquivo, nm_tabela, st_cabecalho, st_acao, nm_rotina_plsql
			  from modelo_cabecalho 
			 where upper(nm_modelo) = upper(prm_modelo)  
			order by nm_tabela;
	   
		ws_cabecalho crs_cabecalho%rowtype;

		ws_clickcoluna    varchar2(2000);
		ws_readonly       varchar2(200);
		ws_usuario        varchar2(200); 
		ws_msg_excluir    varchar2(500);  
		ws_checked        varchar2(20);
		ws_style_checkbox varchar2(40); 

		begin

			ws_usuario := gbl.getUsuario; 
			ws_admin   := gbl.getNivel(ws_usuario); 
			if ws_admin = 'A' then
				ws_readonly := '';
			else
				ws_readonly := 'style="background: #AAA; color: #666;" readonly disabled';
			end if;
		    ws_msg_excluir := 'Aten\u00e7\u00e3o, a coluna ser\u00e1 exclu\u00edda somente deste modelo.\nPara excluir da tabela no banco de dados contate o administrador do sistema. \n\nDeseja realmente excluir?'; 			

			htp.p('<select id="import-tabela-ut" style="float: right; margin: 10px 10px 0 0;" onchange="call(''main'', ''prm_modelo=''+this.value, ''imp'').then(function(resposta){ document.getElementById(''content'').innerHTML = resposta; });">');
			htp.p('<option value="" readonly>'||fun.lang('Selecione uma importa&ccedil;&atilde;o')||'</option>');
			
			for i in(select distinct upper(nm_modelo) as nm_modelo from modelo_cabecalho where nm_modelo is not null order by nm_modelo asc) loop

				if i.nm_modelo = upper(prm_modelo) then
					htp.p('<option value="'||i.nm_modelo||'" selected>'||i.nm_modelo||'</option>');
				else
					htp.p('<option value="'||i.nm_modelo||'">'||i.nm_modelo||'</option>');
				end if;
			end loop;    
			htp.p('</select>');


		if nvl(prm_modelo, 'N/A') <> 'N/A' then
			
				open  crs_cabecalho;
				fetch crs_cabecalho into ws_cabecalho;
				close crs_cabecalho;

				if ws_admin <> 'A' then
					ws_style_checkbox := 'display: none;'; 
				end if; 	

				htp.p('<h4 style="margin: 16px 2px;">'||fun.lang('CONFIGURA&Ccedil;&Atilde;O DA IMPORTA&Ccedil;&Atilde;O')||'</h4>');

				htp.p('<label style="font-size: 10px; font-weight: bold; font-family: ''montserrat'';">'||fun.lang('ARQUIVO')||': </label>');
				htp.p('<a class="script" onclick="call(''import_cabecalho'', ''prm_arquivo=''+document.getElementById(''import-arquivo-ut'').title.replace('''||nvl(fun.ret_var('OWNER_BI'),'DWU')||'.fcl.download?arquivo='', '''').replace(''.xlsx'', '''')+''&prm_tabela=''+document.getElementById(''import-tabela-ut'').value+''&prm_cabecalho=''+document.getElementById(''import-cabecalho-ut'').value+''&prm_acao=''+document.getElementById(''import-acao-ut'').value+''&prm_evento=ARQUIVO'', ''imp'').then(function(resposta){ if(resposta.indexOf(''FAIL'') == -1){ alerta(''feed-fixo'', TR_AL); } else { alerta(''feed-fixo'', TR_ER); }  });"></a>');
				fcl.fakeoption('import-arquivo-ut', ws_cabecalho.nm_arquivo, ws_cabecalho.nm_arquivo, 'lista-xls', 'N', 'N');
				htp.p('<a style="font-size: 10px; font-weight: bold; font-family: ''montserrat''; border-radius: 2px; background: linear-gradient(#EFEFEF, #FFF); border: 1px solid #999; padding-bottom: 6px; padding-top: 6px; padding-left: 6px; padding-right: 6px; margin-bottom: 1px; letter-spacing: 0.5px; text-align: center;" onclick="uploadevoltarbotoes(''upload'')">Upload</a>');

				htp.p('<label style="font-size: 10px; font-weight: bold; font-family: ''montserrat'';">'||fun.lang('LINHAS IGNORADAS')||': </label>');
				htp.p('<input style="max-width: 100px" type="text" id="import-cabecalho-ut" onkeypress="return input(event, ''integer'');" onblur="call(''import_cabecalho'', ''prm_arquivo=''+document.getElementById(''import-arquivo-ut'').title.replace('''||nvl(fun.ret_var('OWNER_BI'),'DWU')||'.fcl.download?arquivo='', '''').replace(''.xlsx'', '''')+''&prm_tabela=''+document.getElementById(''import-tabela-ut'').value+''&prm_cabecalho=''+document.getElementById(''import-cabecalho-ut'').value+''&prm_acao=''+document.getElementById(''import-acao-ut'').value+''&prm_evento=CABECALHO'', ''imp'').then(function(resposta){ if(resposta.indexOf(''FAIL'') == -1){ alerta(''feed-fixo'', TR_AL); } else { alerta(''feed-fixo'', TR_ER); }  });" value="'||ws_cabecalho.st_cabecalho||'" />');

				
				htp.p('<label style="font-size: 10px; font-weight: bold; font-family: ''montserrat'';">'||fun.lang('A&Ccedil;&Atilde;O')||': </label><select id="import-acao-ut" onchange="call(''import_cabecalho'', ''prm_arquivo=''+document.getElementById(''import-arquivo-ut'').title.replace('''||nvl(fun.ret_var('OWNER_BI'),'DWU')||'.fcl.download?arquivo='', '''').replace(''.xlsx'', '''')+''&prm_tabela=''+document.getElementById(''import-tabela-ut'').value+''&prm_cabecalho=''+document.getElementById(''import-cabecalho-ut'').value+''&prm_acao=''+document.getElementById(''import-acao-ut'').value+''&prm_evento=ACAO'', ''imp'').then(function(resposta){ if(resposta.indexOf(''FAIL'') == -1){ alerta(''feed-fixo'', TR_AL); } else { alerta(''feed-fixo'', TR_ER); }  });">');
				if ws_cabecalho.st_acao = 'ADD' then
					htp.p('<option value="ADD" selected>ADICIONAR A TABELA</option>');
					htp.p('<option value="DELETE">LIMPAR TABELA E ADICIONAR</option>');
				else
					htp.p('<option value="ADD">ADICIONAR A TABELA</option>');
					htp.p('<option value="DELETE" selected>LIMPAR TABELA E ADICIONAR</option>');
				end if;
				htp.p('</select>');

				if nvl(prm_modelo, 'N/A') <> 'N/A' then
					htp.p('<label style="font-size: 10px; font-weight: bold; font-family: ''montserrat'';">TABELA: </label>');
					htp.p('<input type="text" readonly class="readonly" value="'||ws_cabecalho.nm_tabela||'">');
				end if;

                if nvl(prm_modelo, 'N/A') <> 'N/A' then
                    htp.p('<label style="font-size: 10px; font-weight: bold; font-family: ''montserrat'';">P&Oacute;S-ROTINA: </label>');
                    if  ws_admin = 'A' then
                        --htp.p('<input type="text" readonly class="readonly" value="'||ws_cabecalho.nm_rotina_plsql||'">');
                        htp.p('<a class="script" onclick="call(''import_cabecalho'', ''prm_modelo=''+document.getElementById(''import-tabela-ut'').value+''&prm_evento=ROTINA&prm_rotina=''+document.getElementById(''import-pos-rotina-upd'').title, ''imp'').then(function(resposta){ if(resposta.indexOf(''FAIL'') == -1){ alerta(''feed-fixo'', TR_AL); } else { alerta(''feed-fixo'', TR_ER); }  });"></a>');
                        fcl.fakeoption('import-pos-rotina-upd', fun.lang('P&oacute;s-Rotina PL/SQL'), ws_cabecalho.nm_rotina_plsql, 'lista-step-plsql', 'N', 'N');
                    else
                        htp.p('<input type="text" readonly class="readonly" value="'||ws_cabecalho.nm_rotina_plsql||'">');
                    end if;
                end if;

				htp.p('<table class="linha">');
					htp.p('<thead>');
					htp.p('<tr>');
					htp.p('<th style="width: 30px;'||ws_style_checkbox||'">'||fun.lang('IMPORTAR')||'</th>');

					htp.p('<th>'||fun.lang('COLUNA')||'</th>');
					htp.p('<th title="Ordem das colunas precisam ser as mesmas tanto na tabela quanto no arquivo">'||fun.lang('ORDEM DA COLUNA')||'</th>');
					htp.p('<th>'||fun.lang('TIPO')||'</th>');
					--htp.p('<th colspan="1"></th>');
					htp.p('<th colspan="2" style="text-align: center;">SUBSTITUIR</th>');
					htp.p('<th colspan="2"></th>');
					htp.p('</tr>');
					htp.p('</thead>');

					htp.p('<tbody>');

						for ws_coluna in crs_colunas (ws_cabecalho.nm_tabela) loop 
								
								htp.p('<tr>');

									ws_checked := null; 
									if ws_coluna.ordem = 1 then -- tem no modelo 
										ws_checked := ' checked ';
									end if; 
									htp.p('<td style="'||ws_style_checkbox||'">');
										htp.p('<input type = "checkbox" '||ws_checked||' onchange="importEditColumn(this, '''||ws_coluna.nm_modelo||''');" style="width:20px !important; height:20px !important;"/>');
									htp.p('</td>');

									htp.p('<td>');
										htp.p('<input readonly class="readonly" value="'||ws_coluna.nm_coluna||'" />');
									htp.p('</td>');

									htp.p('<td>');
										htp.p('<input '||ws_readonly||' data-default="'||ws_coluna.nr_coluna||'" onblur="importEditColumn(this, '''||ws_coluna.nm_modelo||''');" type="number" value="'||ws_coluna.nr_coluna||'" />');
									htp.p('</td>');

									htp.p('<td style="width: 120px;">');

										htp.p('<select '||ws_readonly||' style="width: 120px;" onchange="importEditColumn(this, '''||ws_coluna.nm_modelo||''');">');
											if ws_coluna.tp_coluna = 'varchar2' then
												htp.p('<option value="varchar2" selected>VARCHAR2</option>');
											else
												htp.p('<option value="varchar2">VARCHAR2</option>');
											end if;

											if ws_coluna.tp_coluna = 'number' then
											htp.p('<option value="number" selected>NUMBER</option>');
											else
												htp.p('<option value="number">NUMBER</option>');
											end if;

											/*if ws_coluna.tp_coluna = 'date' then
												htp.p('<option value="date" selected>DATA</option>');
											else
												htp.p('<option value="date">DATA</option>');
											end if;*/

											if ws_coluna.tp_coluna = 'null' then
												htp.p('<option value="null" selected>NULL</option>');
											else
												htp.p('<option value="null">NULL</option>');
											end if;
										htp.p('</select>');
												
									htp.p('</td>');

									-- Comentado pois não foi encotrado uma utilidade atual
									--htp.p('<td style="width: 128px;">');
									--	htp.p('<input type="text" onblur="importEditColumn(this, '''||ws_coluna.nm_modelo||''');" value="'||ws_coluna.trfs_coluna||'" placeholder="TRANSFORMA&Ccedil;&Atilde;O" title="$[SELF] retorna o valor da coluna"/>');
									--htp.p('</td>');

									htp.p('<td style="width: 80px;">');
										htp.p('<input type="text" onblur="importEditColumn(this, '''||ws_coluna.nm_modelo||''');" placeholder="ENTRADA" style="text-transform: uppercase; width: 80px;" value="'||ws_coluna.replacein||'" title="" />');
									htp.p('</td>');

									htp.p('<td style="width: 80px;">');
										htp.p('<input type="text" onblur="importEditColumn(this, '''||ws_coluna.nm_modelo||''');" placeholder="SA&Iacute;DA" style="text-transform: uppercase; width: 80px;" value="'||ws_coluna.replaceout||'" title="" />');
									htp.p('</td>');

									htp.p('<td style="width: 80px;">');
										htp.p('<input type="text" onblur="importEditColumn(this, '''||ws_coluna.nm_modelo||''');" placeholder="M&Aacute;SCARA" style="text-transform: uppercase; width: 80px;" value="'||ws_coluna.mascara||'" title="" />');
									htp.p('</td>');
					
									/*******    substituido delete pelo checkbox 
									htp.p('<td class="noborder">');
										if ws_admin = 'A' then
											--htp.p('<a class="remove" title="'||fun.lang('excluir')||'" onclick="var row = this.parentNode.parentNode; if(confirm('''||ws_msg_excluir||''')){ call(''import_change'', ''prm_modelo='||ws_coluna.nm_modelo||'&prm_numero=''+document.getElementById('''||ws_coluna.nm_modelo||'-'||ws_coluna.id_coluna||'-numero'').value+''&prm_nome=&prm_destino=&prm_tipo=&prm_trfs=''+document.getElementById('''||ws_coluna.nm_modelo||'-'||ws_coluna.id_coluna||'-trfs'').value+''&prm_op=DELETE&prm_id='||ws_coluna.id_coluna||''', ''imp'').then(function(resposta){ if(resposta.indexOf(''FAIL'') == -1){ alerta(''feed-fixo'', TR_EX); row.remove(); call(''main'', ''prm_modelo=''+document.getElementById(''import-tabela-ut'').value, ''imp'').then(function(resposta){ document.getElementById(''content'').innerHTML = resposta; }); }  });}">X</a>');
											htp.p('<a class="remove" title="'||fun.lang('excluir')||'" onclick="var row = this.parentNode.parentNode; if(confirm('''||ws_msg_excluir||''')){ call(''import_change'', ''prm_modelo='||ws_coluna.nm_modelo||'&prm_nome='||ws_coluna.nm_coluna||'&prm_op=DELETE'', ''imp'').then(function(resposta){ if(resposta.indexOf(''FAIL'') == -1){ alerta(''feed-fixo'', TR_EX); row.remove(); call(''main'', ''prm_modelo=''+document.getElementById(''import-tabela-ut'').value, ''imp'').then(function(resposta){ document.getElementById(''content'').innerHTML = resposta; }); }  });}">X</a>');											
										else
											htp.p('<a class="noremove">X</a>');
										end if;
									htp.p('</td>');
									************/ 

								htp.p('</tr>');
						end loop;

					htp.p('</tbody>');
				htp.p('</table>');

				htp.p('<a class="rel_button" style="position: relative !important; font-weight: bold; font-family: ''montserrat''; border-radius: 2px; background: linear-gradient(#EFEFEF, #FFF); padding: 10px; border: 1px solid #999; font-size: 20px; letter-spacing: 0.5px; margin: 20px auto 0 auto; display: block; width: 254px; text-align: center;" onclick="importGenerateData(this);">IMPORTAR DADOS</a>');

				if gbl.getNivel = 'A' then
					htp.p('<a class="exclude" title="" onclick="if(confirm(TR_CE)){ call(''importDelete'', ''prm_modelo=''+get(''import-tabela-ut'').value, ''imp'').then(function(res){ if(res.indexOf(''ok'') != -1){ alerta(''feed-fixo'', TR_EX); call(''main'', ''prm_modelo='', ''imp'').then(function(resposta){ document.getElementById(''content'').innerHTML = resposta; }); } else { alerta(''feed-fixo'', TR_ER); } }); }"></a>');
				end if;

		end if;

	end main;

	procedure import_cabecalho ( prm_modelo    varchar2 default null,
								 prm_arquivo   varchar2 default null,
								 prm_tabela    varchar2 default null,
								 prm_cabecalho varchar2 default null,
								 prm_acao      varchar2 default null,
								 prm_evento    varchar2 default null,
                                 prm_rotina    varchar2 default null ) as

		ws_count   number;
		ws_fail    exception;
	    ws_id      number;
	    ws_err     varchar2(80);

		begin

    case prm_evento
        when 'ARQUIVO' then

            update modelo_cabecalho
            set nm_arquivo = fun.converte(prm_arquivo)
            where upper(nm_modelo) = upper(prm_tabela);

            ws_count := SQL%ROWCOUNT;

			if ws_count <> 0 then
				commit;
			else
				raise ws_fail;
			end if;

        when 'CABECALHO' then

            update modelo_cabecalho
            set st_cabecalho = fun.converte(prm_cabecalho)
            where upper(nm_modelo) = upper(prm_tabela);
           
            ws_count := SQL%ROWCOUNT;
			
			if ws_count <> 0 then
				commit;
			else
				raise ws_fail;
			end if;

        when 'ACAO' then

            update modelo_cabecalho
            set st_acao = prm_acao
            where upper(nm_modelo) = upper(prm_tabela);

            ws_count := SQL%ROWCOUNT;

			if ws_count <> 0 then
				commit;
			else
				raise ws_fail;
			end if;

        when 'ROTINA' then

            update modelo_cabecalho
            set nm_rotina_plsql = prm_rotina
            where upper(nm_modelo) = upper(prm_modelo);

            ws_count := SQL%ROWCOUNT;

            if ws_count <> 0 then
                commit;
            else
                raise ws_fail;
            end if;

        else

            select count(*) into ws_count from modelo_cabecalho where upper(trim(nm_modelo)) = upper(prm_modelo) ;
            if ws_count = 0 then
                insert into modelo_cabecalho ( nm_arquivo, nm_tabela, st_cabecalho, st_acao, nm_modelo, nm_rotina_plsql) values ( fun.converte(prm_arquivo), upper(prm_tabela), prm_cabecalho, prm_acao, upper(prm_modelo), prm_rotina );

   				ws_count := SQL%ROWCOUNT;

   				if ws_count = 1 then
       				commit;

					ws_count := 0;
					select max(id_coluna) into ws_id from modelo_coluna;

					begin
						for i in(select column_name from all_tab_cols where table_name = upper(prm_tabela) order by column_id) loop

							ws_count := ws_count+1;
							begin
								insert into modelo_coluna ( id_coluna, nm_modelo, nr_coluna, nm_coluna, nm_destino, tp_coluna, trfs_coluna, replacein, replaceout, mascara ) values ( nvl(ws_id, 0)+ws_count, upper(prm_modelo), ws_count, i.column_name, '', 'VARCHAR2', '', '', '', '');
								commit;
							exception when others then
								htp.p(sqlerrm);
							end;
						end loop;
					exception when others then
						htp.p(sqlerrm);
					end;

   				else
					ws_err := 'IMPOSS&Iacute;VEL ADICIONAR CABECALHO';
					raise ws_fail;
				end if;
			else
   				ws_err := 'DUPLICADO';
   				raise ws_fail;
			end if;

    	end case;

exception
    when ws_fail then
        rollback;
        htp.p('FAIL '||ws_err);
    when others then
        rollback;
        htp.p('FAIL');
end import_cabecalho;

procedure import_change ( prm_modelo     varchar2  default  null,
                          prm_numero     number    default  null,
                          prm_nome       varchar2  default  null,
                          prm_destino    varchar2  default  null,
                          prm_tipo       varchar2  default  'varchar2',
                          prm_trfs       varchar2  default  null,
						  prm_replacein  varchar2  default  null,
						  prm_replaceout varchar2  default  null,
						  prm_mascara    varchar2  default  null,
                          prm_op         varchar2  default  null ) as
 						  --prm_id         number    default  null ) as

    ws_count number;
    ws_fail  exception;
    ws_key   number;
    ws_inc   number;
	ws_nr_coluna  number; 

begin

    if prm_op = 'DELETE' then
		delete from modelo_coluna where upper(nm_modelo) = upper(prm_modelo) and upper(nm_coluna) = upper(prm_nome);
        if SQL%ROWCOUNT <> 0 then 
            commit;
        else
            raise ws_fail;
        end if;
    else
		update 	modelo_coluna
		set		nm_coluna   = prm_nome,
				nm_destino  = prm_destino,
				tp_coluna   = prm_tipo,
				trfs_coluna = fun.converte(prm_trfs),
				replacein   = prm_replacein,
				replaceout  = prm_replaceout,
				mascara     = prm_mascara,
				nr_coluna   = prm_numero
		where 	nm_coluna 	= upper(prm_nome)
		  and  	nm_modelo 	= upper(prm_modelo);
		
		if sql%notfound then 
			select max(nvl(id_coluna,0)) + 1, max(decode(nm_modelo, prm_modelo, nr_coluna,0)) + 1 into ws_key, ws_nr_coluna  
			  from modelo_coluna ; 
			loop
				ws_inc := ws_inc+1;
				select count(*) into ws_count from modelo_coluna where id_coluna = ws_key;
				if ws_count > 0 then
					select ws_key+ws_inc into ws_key from dual;
				else
					exit;
				end if;
			end loop;

			insert into modelo_coluna (id_coluna, nm_modelo, nr_coluna, nm_coluna, nm_destino, tp_coluna, trfs_coluna, replacein, replaceout, mascara)
			                   values (ws_key, upper(prm_modelo), nvl(prm_numero,ws_nr_coluna), upper(prm_nome), upper(prm_destino), prm_tipo, upper(fun.converte(prm_trfs)), prm_replacein, prm_replaceout, prm_mascara);
  
		end if; 


		/* 
		select count(*) into ws_count 
		  from modelo_coluna 
		 where nm_modelo = prm_modelo 
		   and nm_coluna = prm_nome;

        if ws_count <> 0 then

			update 	modelo_coluna
			set		nm_coluna   = prm_nome,
					nm_destino  = prm_destino,
					tp_coluna   = prm_tipo,
					trfs_coluna = fun.converte(prm_trfs),
					replacein   = prm_replacein,
					replaceout  = prm_replaceout,
					mascara     = prm_mascara,
					nr_coluna   = prm_numero
			where 	nm_coluna 	= prm_nome
			and   	nm_modelo 	= prm_modelo;

            ws_count := SQL%ROWCOUNT;

            if ws_count <> 0 then
                commit;
            else
                raise ws_fail;
            end if;

        else

            select nvl2(max(id_coluna), max(id_coluna), 0)+1 into ws_key from modelo_coluna;

			loop

				ws_inc := ws_inc+1;

				select count(*) into ws_count from modelo_coluna where id_coluna = ws_key;

				if ws_count > 0 then
					select ws_key+ws_inc into ws_key from dual;
				else
					exit;
				end if;

			end loop;

			insert into modelo_coluna
				(id_coluna, nm_modelo, nr_coluna, nm_coluna, nm_destino, tp_coluna, trfs_coluna, replacein, replaceout, mascara)
			values
				(ws_key, upper(prm_modelo), nvl(prm_numero, (select max(nr_coluna)+1 from modelo_coluna where nm_modelo = upper(prm_modelo))), upper(prm_nome), upper(prm_destino), prm_tipo, upper(fun.converte(prm_trfs)), prm_replacein, prm_replaceout, prm_mascara);

			ws_count := SQL%ROWCOUNT;
			
			if ws_count <> 0 then
				commit;
			else
				raise ws_fail;
			end if;
		
		end if;
        ********************/ 

   end if;

exception
    when ws_fail then
        rollback;
        htp.p('FAIL');
    when others then
		rollback;
		insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values(sysdate, substr('import_change:'||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,3999), gbl.getUsuario, 'ERRO');	
		commit;
        htp.p('FAIL');
end import_change;

procedure importDelete ( prm_modelo varchar2 default null ) as

	ws_count number;

begin

	delete from modelo_cabecalho where upper(trim(nm_modelo)) = upper(trim(prm_modelo));
           
    ws_count := SQL%ROWCOUNT;
           
    if ws_count <> 0 then
        delete from modelo_coluna where upper(trim(nm_modelo)) = upper(trim(prm_modelo));
		commit;
    end if;
	htp.p('ok');
exception when others then
	htp.p('fail '||sqlerrm);
end importDelete;

procedure executenow ( prm_comando  varchar2 default null ) as

    job_id          number;
    ws_owner        varchar2(90);
    ws_name         varchar2(90);
    ws_line         number;
    ws_caller       varchar2(90);

begin
   
owa_util.who_called_me(ws_owner, ws_name, ws_line, ws_caller);

        dbms_job.submit(job => job_id,what => trim(prm_comando)||';',next_date => sysdate+((1/1440)/60), interval => null);
        commit;

end executenow;

end IMP;
