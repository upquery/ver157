create or replace package body CFG  is

    procedure menu_cfg (prm_menu varchar2) as
        ws_ativa_label_data varchar2(100) := 'onfocus="this.type=''date''; this.showPicker();" onblur="if (this.value === '''') {this.type=''text''}"';
    begin
        case prm_menu
        when 'avisos' then
            htp.p('<h4>'||fun.lang('CADASTRO DE AVISOS')||'</h4>');
            
            htp.p('<input type="text" maxlength="80" value="" placeholder="descri&ccedil;&atilde;o" id="prm_ds_aviso"  class="up"/>');
            htp.p('<input type="" value="" placeholder="data inicio" id="prm_dh_inicio" class="up" '||ws_ativa_label_data||'/>');
            htp.p('<input type="" value="" placeholder="data fim" id="prm_dh_fim" class="up" '||ws_ativa_label_data||'/>');
            htp.p('<a class="script" onclick="var valor=this.nextElementSibling.title; if(valor==''IMAGEM EXTERNA''){document.getElementById(''prm_nm_conteudo'').classList.remove(''invisible'');document.getElementById(''btn_upload_imagem'').classList.add(''invisible'')} else {document.getElementById(''prm_nm_conteudo'').classList.add(''invisible'');document.getElementById(''btn_upload_imagem'').classList.remove(''invisible'')}"></a>');
            fcl.fakeoption('prm_tp_conteudo', fun.lang('Tipo de Conte&uacute;do'), '', 'lista-tipo-conteudo-aviso', 'N', 'N', prm_desc => '');
            htp.p('<input type="text" maxlength="300" value="" placeholder="url da imagem" id="prm_nm_conteudo" class="up invisible"/>');
            --htp.p('<a id="btn_upload_imagem" class="addpurple invisible" onclick="getFileName(this);" title="ESCOLHER ARQUIVO..." data-default="ESCOLHER ARQUIVO...">Escolher Arquivo...</a>');
            htp.p('<a id="btn_upload_imagem" class="addpurple invisible" onclick="this.nextElementSibling.click();" title="ESCOLHER ARQUIVO..." data-default="ESCOLHER ARQUIVO...">Escolher Arquivo...</a>');
            htp.p('<input style="opacity: 0; position: fixed; top: -9999px; left: -9999px;" type="file" multiple id="arquivos" name="arquivos" onchange="mostrarArquivosSelecionados(''btn_upload_imagem'')"></input>');
            htp.p('<input type="hidden" value="CLIENTE" id="prm_tp_origem" />');
            fcl.fakeoption('prm_tela_aviso', fun.lang('Ir para tela'), '', 'lista-telas-usuario', 'N', 'N', prm_desc => '');
            fcl.fakeoption('prm_usuarios_aviso', 'Lista de Usu&aacute;rios', '', 'lista-usuario-grupo', 'N', 'S', prm_desc => '');
            -- htp.p('<a class="addpurple" title="'||fun.lang('Adicionar')||'" onclick="if(document.getElementById(''prm_tp_conteudo'').title ===''IMAGEM INTERNA''){document.getElementById(''prm_nm_conteudo'').value=document.getElementById(''btn_upload_imagem'').title;document.getElementById(''painel'').querySelector(''iframe'').contentWindow.document.body.children[0].submit()}"  data-req="adicionar_aviso" data-par="prm_ds_aviso|prm_dh_inicio|prm_dh_fim|prm_tp_conteudo|prm_nm_conteudo|prm_tp_origem|prm_tela_aviso|prm_usuarios_aviso" data-res="avisos" data-sup="avisos" data-pkg="cfg">'||fun.lang('ADICIONAR AVISO')||'</a>');
            htp.p('<a class="addpurple" title="'||fun.lang('Adicionar')||'" onclick="if(document.getElementById(''prm_tp_conteudo'').title ===''IMAGEM INTERNA''){document.getElementById(''prm_nm_conteudo'').value=document.getElementById(''btn_upload_imagem'').title;uploadArquivos('''');}"  data-req="adicionar_aviso" data-par="prm_ds_aviso|prm_dh_inicio|prm_dh_fim|prm_tp_conteudo|prm_nm_conteudo|prm_tp_origem|prm_tela_aviso|prm_usuarios_aviso" data-res="avisos" data-sup="avisos" data-pkg="cfg">'||fun.lang('ADICIONAR AVISO')||'</a>');
            -- htp.p('<span style="display:none">');
            -- upload.main();
            -- htp.p('</span>');
        end case;
    end menu_cfg;

    procedure avisos (prm_order   varchar2 default '2',
				      prm_dir     varchar2 default '1') as
        cursor c_avisos is
            select a.id_aviso, a.ds_aviso, a.dh_inicio, a.dh_fim, a.tp_usuario,
                   a.tp_conteudo, a.nm_conteudo, a.url_aviso, a.dh_alteracao, 
                   a.tp_origem, a.tela_aviso, o.nm_objeto nm_tela,
                   listagg(p.nm_usuario, '|')  within group (order by p.nm_usuario) as nm_usuarios_aviso
              from bi_avisos a
              left join bi_aviso_permissao p on a.id_aviso=p.id_aviso
              left join objetos o on a.tela_aviso = o.cd_objeto
             where tp_origem = 'CLIENTE'
             group by a.id_aviso, a.ds_aviso, a.dh_inicio, a.dh_fim, a.tp_usuario,
                      a.tp_conteudo, a.nm_conteudo, a.url_aviso, a.dh_alteracao, 
                      a.tp_origem,  a.tela_aviso, o.nm_objeto
             order by case when prm_dir = '1' then decode(prm_order, '1', to_char(a.id_aviso), '2', a.ds_aviso,
                                                          '3', to_char(a.dh_inicio, 'YYMMDDHH24MISS'),
                                                          '4', to_char(a.dh_fim, 'YYMMDDHH24MISS'),
                                                          '5', a.tp_usuario, '6', a.tp_conteudo, 
                                                          '7', a.nm_conteudo, '8', a.url_aviso, 
                                                          '9', to_char(a.dh_alteracao, 'YYMMDDHH24MISS'),
                                                          '10', a.tp_origem, '11', a.tela_aviso, 
                                                          '12', o.nm_objeto, to_char(a.id_aviso)) end asc,
                      case when prm_dir = '2' then decode(prm_order, '1', to_char(a.id_aviso), '2', a.ds_aviso,
                                                          '3', to_char(a.dh_inicio, 'YYMMDDHH24MISS'),
                                                          '4', to_char(a.dh_fim, 'YYMMDDHH24MISS'),
                                                          '5', a.tp_usuario, '6', a.tp_conteudo, 
                                                          '7', a.nm_conteudo, '8', a.url_aviso, 
                                                          '9', to_char(a.dh_alteracao, 'YYMMDDHH24MISS'),
                                                          '10', a.tp_origem, '11', a.tela_aviso, 
                                                          '12', o.nm_objeto, to_char(a.id_aviso)) end desc;

        ws_onchange varchar2(100) := 'onchange="atualizar_aviso(this);" ';
        ws_onclick varchar2(200);
        ws_dir number := 1;
    begin
        ws_onclick := 'onclick="var dir=order('''',''ajax''); ajax(''list'', ''avisos'', ''prm_order=#REP_ID_COL#&prm_dir=''+dir, false, ''content'', null, null, ''cfg'');"';
        htp.p('<table class="linha">');
        htp.p('<thead>');
        htp.p('<tr>');
            htp.p('<th>');
                htp.p('<a class="red" '||replace(ws_onclick,'#REP_ID_COL#', '1')||'>'||fun.lang('Nro. Aviso')||'</a>');
            htp.p('</th>');
            htp.p('<th>');
                htp.p('<a class="red" '||replace(ws_onclick,'#REP_ID_COL#', '2')||'>'||fun.lang('Descri&ccedil;&atilde;o')||'</a>');
            htp.p('</th>');
            htp.p('<th title="Data que o aviso come&ccedil;a a ser veiculado">');
                htp.p('<a class="red" '||replace(ws_onclick,'#REP_ID_COL#', '3')||'>'||fun.lang('Validade - In&iacute;cio')||'</a>');
            htp.p('</th>');
            htp.p('<th title="&Uacute;ltima data que o aviso ser&aacute; veiculado">');
                htp.p('<a class="red" '||replace(ws_onclick,'#REP_ID_COL#', '4')||'>'||fun.lang('Validade - Fim')||'</a>');
            htp.p('</th>');
            htp.p('<th title="URL => link para imagem externa &#10;BI => upload de arquivo para o programa">');
                htp.p('<a class="red" '||replace(ws_onclick,'#REP_ID_COL#', '6')||'>'||fun.lang('Tipo Conte&uacute;do')||'</a>');
            htp.p('</th>');
            htp.p('<th >');
                htp.p('<a class="red" '||replace(ws_onclick,'#REP_ID_COL#', '7')||'>'||fun.lang('Conte&uacute;do')||'</a>');
            htp.p('</th>');
            htp.p('<th title="Data e Hora da &uacute;ltima altera&ccedil;&atilde;o no aviso">');
                htp.p('<a class="red" '||replace(ws_onclick,'#REP_ID_COL#', '9')||'>'||fun.lang('&Uacute;ltima Altera&ccedil;&atilde;o')||'</a>');
            htp.p('</th>');
            htp.p('<th title="Opcional, adiciona um bot&atilde;o ao aviso que leva a tela selecionada">');
                htp.p('<a class="red" '||replace(ws_onclick,'#REP_ID_COL#', '12')||'>'||fun.lang('Ir para tela')||'</a>');
            htp.p('</th>');
            htp.p('<th title="Usu&aacute;rios que ver&atilde;o o aviso">');
                htp.p(fun.lang('Usu&aacute;rios'));
            htp.p('</th>');
            htp.p('<th title="Mostra novamente o aviso para todos os usu&aacute;rios, mesmo se marcado para n&atilde;o mostrar">'||fun.lang('Mostrar Novamente')||'</th>');--botao mostrar novamente
            htp.p('<th></th>');--botao excluir
        htp.p('</tr>');
        htp.p('</thead>');

        if to_number(prm_dir) = 1 then
			ws_dir := 2;
		end if;

        htp.p('<tbody id="ajax" data-dir="'||ws_dir||'">');
        for aviso in c_avisos loop
            htp.p('<tr id="tr_aviso_'||aviso.id_aviso||'">');
                htp.p('<span id="prm_id_aviso_'||aviso.id_aviso||'" title="'||aviso.id_aviso||'"/>');
                htp.p('<td>'||aviso.id_aviso||'</td>');
                htp.p('<td>');
                    htp.p('<input type="text" class="editable" onchange="atualizar_aviso('||aviso.id_aviso||', ''prm_ds_aviso'', this);" value="'||aviso.ds_aviso||'"/>');
                htp.p('</td>');
                htp.p('<td>');
                    htp.p('<input type="date" class="editable" onblur="atualizar_aviso('||aviso.id_aviso||', ''prm_dh_inicio'', this);" value="'||to_char(aviso.dh_inicio, 'YYYY-MM-DD')||'"/>');
                htp.p('</td>');
                htp.p('<td>');
                    htp.p('<input type="date" class="editable" onblur="atualizar_aviso('||aviso.id_aviso||', ''prm_dh_fim'', this);" value="'||to_char(aviso.dh_fim, 'YYYY-MM-DD')||'"/>');
                htp.p('</td>');
                htp.p('<td>');
                    htp.p('<a class="script" onclick="atualizar_aviso('||aviso.id_aviso||', ''prm_tp_conteudo'', this.nextElementSibling);"></a>');
                    if aviso.tp_conteudo = 'IMAGEM EXTERNA' then
                        fcl.fakeoption('prm_tp_conteudo_'||aviso.id_aviso, fun.lang('Tipo de Conteudo'), aviso.tp_conteudo, 'lista-tipo-conteudo-aviso', 'N', 'N', prm_desc =>'Imagem URL');
                    else
                        fcl.fakeoption('prm_tp_conteudo_'||aviso.id_aviso, fun.lang('Tipo de Conteudo'), aviso.tp_conteudo, 'lista-tipo-conteudo-aviso', 'N', 'N', prm_desc =>'Imagem BI');
                    end if;
                htp.p('</td>');
                htp.p('<td>');
                    if aviso.tp_conteudo = 'IMAGEM EXTERNA' then
                        htp.p('<input type="text" class="editable longname" onchange="atualizar_aviso('||aviso.id_aviso||', ''prm_nm_conteudo'', this);" value="'||aviso.nm_conteudo||'">');
                    else
                        --htp.p('<a class="script" onclick="this.nextElementSibling.title=this.nextElementSibling.innerHTML; this.parentElement.querySelector(''iframe'').contentWindow.document.body.children[0].submit();atualizar_aviso('||aviso.id_aviso||', ''prm_nm_conteudo'', this.nextElementSibling);"></a>');
                        -- htp.p('<a id="prm_nm_conteudo_'||aviso.id_aviso||'" class="editable addpurple" style="border-radius: 4px 0 0 4px; line-height: initial" onclick="getFileName(this);var updateImagem = setInterval(()=>{if(this.title!=this.getAttribute(''data-default'')){this.parentElement.querySelector(''iframe'').contentWindow.document.body.children[0].submit();atualizar_aviso('||aviso.id_aviso||', ''prm_nm_conteudo'', this);clearInterval(updateImagem)}},100);" title="'||aviso.nm_conteudo||'" data-default="'||aviso.nm_conteudo||'">'||aviso.nm_conteudo||'</a>');
                        htp.p('<span class="fakeoption">');
                        htp.p('<a id="prm_nm_conteudo_'||aviso.id_aviso||'" class="addpurple" style="margin:0 5px 0 0;min-width: -moz-available; min-width: -webkit-fill-available;" onclick="this.nextElementSibling.click();var updateImagem = setInterval(()=>{if(this.title!=this.getAttribute(''data-default'')){uploadArquivos('''', ''arquivos_'||aviso.id_aviso||''');atualizar_aviso('||aviso.id_aviso||', ''prm_nm_conteudo'', this);this.setAttribute(''data-default'',this.title);clearInterval(updateImagem)}},100);" title="'||aviso.nm_conteudo||'" data-default="'||aviso.nm_conteudo||'">'||aviso.nm_conteudo||'</a>');
                        htp.p('<input style="opacity: 0; position: fixed; top: -9999px; left: -9999px;" type="file" multiple id="arquivos_'||aviso.id_aviso||'" name="arquivos_'||aviso.id_aviso||'" onchange="mostrarArquivosSelecionados(''prm_nm_conteudo_'||aviso.id_aviso||''', ''arquivos_'||aviso.id_aviso||''')"></input>');
                        htp.p('</span>');
                        -- htp.p('<span style="display:none">');
                        -- upload.main();
                        -- htp.p('</span>');
                    end if;
                htp.p('</td>');
                htp.p('<td><input disabled value="'||to_char(aviso.dh_alteracao, 'DD/MM/YYYY HH24:MI:SS')||'"/></td>');
                htp.p('<td>');
                    htp.p('<a class="script" onclick="atualizar_aviso('||aviso.id_aviso||', ''prm_tela_aviso'', this.nextElementSibling);" ></a>');
                    fcl.fakeoption('prm_tela_aviso_'||aviso.id_aviso, fun.lang('Escolha uma tela'), aviso.tela_aviso, 'lista-telas-usuario', 'N', 'N', prm_desc => aviso.nm_tela);
                htp.p('</td>');
                htp.p('<td>');
                    htp.p('<a class="script" onclick="atualizar_aviso('||aviso.id_aviso||', ''prm_usuarios_aviso'', this.nextElementSibling);"></a>');
                    fcl.fakeoption('prm_usuarios_aviso_'||aviso.id_aviso, 'Lista de Usu&aacute;rios', aviso.nm_usuarios_aviso, 'lista-usuario-grupo', 'N', 'S', prm_desc => replace(replace(aviso.nm_usuarios_aviso, 'DWU', 'TODOS'),'|', ', '));
                htp.p('</td>');
                htp.p('<td><span class="fakeoption"><a class="addpurple" style="margin:0 5px 0 0;min-width: -moz-available; min-width: -webkit-fill-available;" title="mostrar_novamente" data-valor="'||aviso.id_aviso||'" onclick="aviso_mostrar_novamente(this);">Mostra Novamente</a></span></td>');
                htp.p('<td>
                    <a class="remove" data-require="remover_aviso" data-param="prm_id_aviso" data-valor="'||aviso.id_aviso||'" data-decode="" data-objeto="" data-pkg="cfg" title="Excluir">X</a>
                </td>');
            htp.p('</tr>');
        end loop;
        htp.p('</tbody>');
    exception when others then 
        rollback;
        insert into bi_log_sistema values(sysdate, 'avisos (others) :'||substr(DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,3900), gbl.getusuario, 'ERRO');
		commit;
    end avisos;

    procedure adicionar_aviso(prm_ds_aviso varchar2,
                              prm_dh_inicio varchar2 default to_char(sysdate, 'YYYY-MM-DD'),
                              prm_dh_fim varchar2 default null,
                              prm_tp_usuario varchar2 default 'TODOS',
                              prm_tp_conteudo varchar2 default 'IMAGEM EXTERNA',
                              prm_nm_conteudo varchar2,
                              prm_url_aviso varchar2 default null,
                              prm_tp_origem varchar2 default null,
                              prm_tela_aviso varchar2 default null,
                              prm_usuarios_aviso varchar2 default null) as
        ws_id_aviso number;
        ws_dh_inicio date;
        ws_dh_fim date;
        
        ws_err_msg varchar2(2000);
        raise_erro exception; 
    begin
        if prm_ds_aviso is null or prm_ds_aviso = '' then
            ws_err_msg := 'Descri&ccedil;&atilde;o precisa ser preenchida!';
            raise raise_erro;
        end if;
        if prm_nm_conteudo is null or prm_nm_conteudo = '' then
            ws_err_msg := 'Conte&uacute;do do aviso precisa ser preenchido!';
            raise raise_erro;
        end if;

        if prm_dh_inicio is not null then
            ws_dh_inicio := to_date(prm_dh_inicio, 'YYYY-MM-DD');
        end if;
        if prm_dh_fim is not null then
            ws_dh_fim := to_date(prm_dh_fim, 'YYYY-MM-DD')+0.99999;
        end if;
        if ws_dh_inicio is not null and ws_dh_fim is not null and ws_dh_fim <= ws_dh_inicio then
            ws_err_msg := 'Data final do aviso precisa ser maior que a data inicial!';
            raise raise_erro;
        end if;
        select max(id_aviso)
          into ws_id_aviso
          from bi_avisos;

        if ws_id_aviso > 100000 then
            ws_id_aviso := ws_id_aviso+1;
        else
            ws_id_aviso := 100001;
        end if;

        insert into bi_avisos (id_aviso, ds_aviso, dh_inicio, dh_fim, tp_usuario, tp_conteudo, nm_conteudo, url_aviso, dh_alteracao, tp_origem, tela_aviso)
        values (ws_id_aviso, prm_ds_aviso, ws_dh_inicio, ws_dh_fim, prm_tp_usuario, prm_tp_conteudo, prm_nm_conteudo, prm_url_aviso, sysdate, prm_tp_origem, prm_tela_aviso);
        
        if prm_usuarios_aviso is not null then
            for u in (select * from table(fun.vpipe(prm_usuarios_aviso))) loop
                insert into bi_aviso_permissao 
                values (u.column_value, ws_id_aviso, sysdate);
            end loop;
        end if;
        htp.p('OK|cadastro realizado com sucesso!');
    exception
      when raise_erro then
        rollback;
        htp.p('ERRO|'||ws_err_msg);
      when others then 
        rollback;
        htp.p('ERRO|OTHERS - conferir bi_log_sistema - "adicionar_aviso (others) :"!');
        insert into bi_log_sistema values(sysdate, 'adicionar_aviso (others) :'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getusuario, 'ERRO');
		commit;
    end adicionar_aviso;

    procedure remover_aviso(prm_id_aviso number) as
    begin
        delete from bi_avisos
         where id_aviso = prm_id_aviso;

        delete from bi_aviso_permissao
         where id_aviso = prm_id_aviso;

        delete from bi_aviso_usuario
         where id_aviso = prm_id_aviso;

        insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure)
        values (sysdate, 'aviso Nro '||prm_id_aviso||' removido por '||gbl.getusuario, gbl.getusuario, 'EVENTO');
        commit;
    exception
      when others then
        rollback;
        htp.p('ERRO|OTHERS - conferir bi_log_sistema - "remover_aviso (others) :"!');
        insert into bi_log_sistema values(sysdate, 'remover_aviso (others) :'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getusuario, 'ERRO');
		commit;
    end remover_aviso;

    procedure atualizar_aviso ( prm_id_aviso        number,
                                prm_cd_coluna       varchar2,
                                prm_conteudo        varchar2)
    is
        cursor c_avisos is
            select id_aviso, ds_aviso, dh_inicio, dh_fim, tp_usuario,
                   tp_conteudo, nm_conteudo, url_aviso, tp_origem, tela_aviso
              from bi_avisos
             where id_aviso = prm_id_aviso;

        ws_aviso c_avisos%rowtype;

        prm_ds_aviso        varchar2(100) := null;
        prm_dh_inicio       varchar2(100) := null;
        prm_dh_fim          varchar2(100) := null;
        prm_tp_conteudo     varchar2(100) := null;
        prm_nm_conteudo     varchar2(100) := null;
        prm_url_aviso       varchar2(100) := null;
        prm_tp_origem       varchar2(100) := null;
        prm_tela_aviso      varchar2(100) := null;
        prm_usuarios_aviso  varchar2(1000) := null;
        ws_conteudo         varchar2(1000) := null;
        ws_mudou            varchar2(1) := 'N';

        ws_update varchar2(4000);

        ws_exception exception;
        ws_err_msg varchar2(4000);
    begin

        open c_avisos;
        fetch c_avisos into ws_aviso;
        close c_avisos;

        case prm_cd_coluna
            when 'prm_ds_aviso' then 
                ws_conteudo := ''''||prm_conteudo||'''';
                if ws_aviso.ds_aviso <> prm_conteudo then 
                    ws_mudou := 'S';
                end if;
            when 'prm_dh_inicio' then
                if to_date(prm_conteudo, 'YYYY-MM-DD') >= ws_aviso.dh_fim then
                    ws_err_msg := 'Data inicial do aviso precisa ser menor que a data final!';
                    raise ws_exception;
                end if;
                ws_conteudo := 'to_date('''||prm_conteudo||''', ''YYYY-MM-DD'')'; 
                if ws_aviso.dh_inicio <> to_date(prm_conteudo, 'YYYY-MM-DD') then 
                    ws_mudou := 'S';
                end if;
            when 'prm_dh_fim' then 
                if to_date(prm_conteudo, 'YYYY-MM-DD')+0.99999 <= ws_aviso.dh_inicio then
                    ws_err_msg := 'Data final do aviso precisa ser maior que a data inicial!';
                    raise ws_exception;
                end if;
                if ws_aviso.dh_fim <> to_date(prm_conteudo, 'YYYY-MM-DD')+0.99999 then 
                    ws_mudou := 'S';
                end if;
                ws_conteudo := 'to_date('''||prm_conteudo||''', ''YYYY-MM-DD'')+0.99999';
            when 'prm_tp_conteudo' then 
                if ws_aviso.tp_conteudo <> prm_conteudo then 
                    ws_mudou := 'S';
                end if;
                ws_conteudo := ''''||prm_conteudo||'''';
            when 'prm_nm_conteudo' then
                if nvl(ws_aviso.nm_conteudo,'SEM_CONTEUDO') <> nvl(prm_conteudo,'SEM_CONTEUDO') then 
                    ws_mudou := 'S';
                end if; 
                ws_conteudo := ''''||prm_conteudo||'''';
            when 'prm_url_aviso' then 
                if nvl(ws_aviso.url_aviso,'SEM_URL') <> nvl(prm_conteudo,'SEM_URL') then 
                    ws_mudou := 'S';
                end if; 
                ws_conteudo := ''''||prm_conteudo||'''';
            when 'prm_tp_origem' then
                if ws_aviso.tp_origem <> prm_conteudo then 
                    ws_mudou := 'S';
                end if;  
                ws_conteudo := ''''||prm_conteudo||'''';
            when 'prm_tela_aviso' then 
                if nvl(ws_aviso.tela_aviso,'SEM_TELA') <> nvl(prm_conteudo,'SEM_TELA') then 
                    ws_mudou := 'S';
                end if; 
                ws_conteudo := ''''||prm_conteudo||'''';
            when 'prm_usuarios_aviso' then 
                prm_usuarios_aviso := prm_conteudo;
        end case;

        if prm_usuarios_aviso is null then
            if ws_mudou = 'S' then
                ws_update := 'update bi_avisos set '||substr(prm_cd_coluna, 5)||'='||ws_conteudo||', '
                            ||'      dh_alteracao=sysdate '
                            ||'where id_aviso = '||prm_id_aviso;
                execute immediate ws_update;
            
                if sql%rowcount <= 0 then
                    ws_err_msg := 'Nenhum aviso atualizado!';
                    raise ws_exception;
                end if;
                htp.p('OK|Aviso Nro. '||prm_id_aviso||' atualizado!');
            else 
                htp.p('ERRO|Aviso Nro. '||prm_id_aviso||' n&atilde;o foi atualizado!');
            end if;
        else 
            for usuario in (select column_value as nome from table(fun.vpipe(prm_usuarios_aviso))) loop
                update bi_aviso_permissao
                   set dh_liberacao=nvl(dh_liberacao,sysdate)
                 where nm_usuario = usuario.nome
                   and id_aviso = prm_id_aviso;
                
                if sql%rowcount = 0 then
                    insert into bi_aviso_permissao
                    values (usuario.nome, prm_id_aviso, sysdate);
                end if;
            end loop;
            for usuario in (select nm_usuario as nome from bi_aviso_permissao where id_aviso=prm_id_aviso) loop
                if (prm_usuarios_aviso not like '%'||usuario.nome||'%' ) then
                    delete from bi_aviso_permissao
                     where nm_usuario = usuario.nome
                       and id_aviso = prm_id_aviso;
                end if;
            end loop;
            htp.p('OK|Aviso Nro. '||prm_id_aviso||' atualizado!');
        end if;
    exception
      when ws_exception then
        rollback;
        htp.p('ERRO|'||ws_err_msg);
      when others then
        rollback;
        htp.p('ERRO|OTHERS - conferir bi_log_sistema - "atualizar_aviso (others) :"!');
        insert into bi_log_sistema values(sysdate, 'atualizar_aviso (others) :'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getusuario, 'ERRO');
		commit;
    end atualizar_aviso;

    procedure aviso_mostrar_novamente(prm_id_aviso number) as
    begin
        update bi_aviso_usuario
           set id_nao_mostrar='N',
               dh_nao_mostrar=null
         where id_aviso = prm_id_aviso;

        if (sql%rowcount > 0) then
            htp.p('OK|'||sql%rowcount||' registros atualizados para receber o aviso novamente!');
        elsif (sql%rowcount = 0) then
            htp.p('OK|N&atilde;o foi necess&aacute;rio atualizar registros!');
        else
            htp.p('ERRO|Erro - nenhum registro atualizado!');
        end if;
    exception
      when others then
        rollback;
        htp.p('ERRO|OTHERS - conferir bi_log_sistema - "aviso_mostrar_novamente (others) :"!');
        insert into bi_log_sistema values(sysdate, 'aviso_mostrar_novamente (others) :'||DBMS_UTILITY.FORMAT_ERROR_STACK||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getusuario, 'ERRO');
		commit;
    end aviso_mostrar_novamente;

    procedure ir_para_tela_aviso(prm_cd_tela varchar2) as
        ws_usuario varchar2(80);
        ws_tem_permissao number := 0;
    begin
        ws_usuario := gbl.getUsuario;
        ws_tem_permissao := fun.check_screen_access(prm_cd_tela, ws_usuario);
        if ws_tem_permissao > 0 then
            htp.p('OK|Redirecionando...');
        else
            htp.p('ERRO|Sem permissao para acessar a tela!');
        end if;
    end ir_para_tela_aviso;
end CFG;