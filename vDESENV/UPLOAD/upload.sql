create or replace package body upload is

	procedure main ( prm_alternativo varchar2 default null ) as
	
	begin

    htp.p('<div id="containerArquivos" style="margin: 0;">');

      htp.p(fun.lang('Arquivos para upload')||': <input type="file" multiple id="arquivos" name="arquivos" style="max-width: 330px; border: inherit; border-radius: 0;");">');
        
      htp.p('<button id="btnUploadArquivos" onclick="uploadArquivos('''|| prm_alternativo ||''')">upload</button>');
      
    htp.p('</div>');

  end main;

  procedure upload (arquivo  IN  varchar2, prm_usuario varchar2 default null, prm_nm_arquivo varchar2 default null ) AS
        
    l_nome_real       varchar2(1000);
    ws_usuario        varchar2(80);
    ws_doc_limit      varchar2(100);
    ws_objeto         varchar2(100);
    ws_carrega_painel varchar2(100);
    ws_doc_size       number;
    ws_count          number; 
    ws_nofile         exception;
    ws_limit_doc      exception;
    ws_many_rows      exception;
    ws_existe_dwu     exception;
    ws_existe_atual   exception;

  begin

    /******************************************************
    * Observações quando o OWNER do BI for diferente de DWU: 
    * - O arquivo sempre e gravado na TAB_DOCUMENTOS do owner DWU, isso está parametrizado na dads.conf do servidor, se o owner do BI não for DWU tem que alterar na dads.conf para o novo owner 
    * - Mesmo inserido no DWU, o update abaixo é realizado no OWNER onde o BI está instalado, então pode ocorrer o erro de inserir em um OWNER e fazer o update em outro
    * - Para resolver esse problema nas bases de desenv e homologação, foi colocado um insert nesta procedure para buscar o arquivo inserido no DWU 
    ************************************************************************/
    if nvl(arquivo, 'N/A') = 'N/A' then
        raise ws_nofile;
    end if;

    ws_usuario := nvl(prm_usuario, gbl.getUsuario);

    if (gbl.getNivel = 'A' and nvl(prm_usuario, 'N/A') = 'N/A') or ws_usuario ='NOUSER' then
        ws_usuario := nvl(fun.ret_var('OWNER_BI'),'DWU');
    end if;

    if ws_usuario = nvl(fun.ret_var('OWNER_BI'),'DWU') then  -- Se for o owner do BI grava o usuário como DWU (usuário de sistema default)
        ws_usuario := 'DWU'; 
    end if;   
    
    if prm_nm_arquivo is not null then 
        l_nome_real := prm_nm_arquivo;
    else 
        l_nome_real := lower(replace(substr(arquivo, instr(arquivo, '/') + 1), ' ', '_'));
    end if;    

    begin

        -- Owner do BI diferente de DWU, transfere do usuário DWU para o owner do BI 
        -- Adicinado para resolver problema nas bases desenv e homologa com OWNER diferente de DWU, o novo owner do BI precisa ter grant de select de delete na DWU.tab_documentos 
        ------------------------------------------------------------------------------------
        if nvl(fun.ret_var('OWNER_BI'),'DWU') <> 'DWU' then
            begin 
                execute immediate 'insert into tab_documentos (select * from dwu.tab_documentos where name = '''||arquivo||''' )' ;  
                execute immediate 'delete dwu.tab_documentos where name = '''||arquivo||''' ' ;  
            exception when others then null ;
                null;
            end;   
        end if; 

        -- Se o usuário não for ADM (dwu) não pode importar um arquivo já existente no usuário DWU 
        if ws_usuario <> 'DWU' then
            select count(*) into ws_count from tab_documentos
             where  trim(lower(name)) = l_nome_real 
               and  usuario           = 'DWU';
            if ws_count > 0 then 
              htp.p('alerta(''msg'', '''||fun.lang('Arquivo j&aacute; existe no sistema no usu&aacute;rio Administrador, altere o nome do arquivo e tente importar novamente')||'!''); if(document.getElementById(''browseredit'')){ var valor = document.getElementById(''browseredit'').className; ajax(''list'', ''anexo'', ''prm_chave=''+valor, false, ''editb'', '''', '''', ''bro''); } else { ajax(''list'', ''uploaded'', ''prm_chave='||prm_usuario||''', false, ''content'');  carregaPainel(''upload'', '''||prm_usuario||'''); }');            
              rollback;
              raise ws_existe_dwu; 
            end if;    
            
            select count(*) into ws_count from tab_documentos
              where trim(lower(name)) = l_nome_real
                and usuario = ws_usuario;
            if ws_count > 0 then 
              htp.p('alerta(''msg'', '''||fun.lang('Arquivo j&aacute; existe no sistema no usu&aacute;rio atual , altere o nome do arquivo e tente importar novamente')||'!''); if(document.getElementById(''browseredit'')){ var valor = document.getElementById(''browseredit'').className; ajax(''list'', ''anexo'', ''prm_chave=''+valor, false, ''editb'', '''', '''', ''bro''); } else { ajax(''list'', ''uploaded'', ''prm_chave='||prm_usuario||''', false, ''content'');  carregaPainel(''upload'', '''||prm_usuario||'''); }');            
              rollback;
              raise ws_existe_atual; 
            end if;  
            

        else 
            delete from tab_documentos   -- retirado o dwu
             where  trim(lower(name)) = l_nome_real 
               and  usuario = 'DWU';
        end if; 

        update tab_documentos     -- retirado o dwu
            set name         = l_nome_real,
                usuario      = coalesce(ws_usuario, prm_usuario, 'DWU'),
                last_updated = sysdate    -- corrigido a data de inclusão do arquivo, a data utilizada pelo navegador geralmente não bate data do banco de dados
          where name = arquivo;

        -- testa se o usuário vem do browser
        if ws_usuario like 'BRO_%' then

          begin
            select doc_size into ws_doc_size from tab_documentos where name = l_nome_real and usuario like 'BRO_%';
          exception
            when too_many_rows then
              rollback;
              htp.p('alerta(''msg'', '''||fun.lang('Esse arquivo j&aacute; foi feito o upload')||'!''); if(document.getElementById(''browseredit'')){ var valor = document.getElementById(''browseredit'').className; ajax(''list'', ''anexo'', ''prm_chave=''+valor, false, ''editb'', '''', '''', ''bro''); } else { ajax(''list'', ''uploaded'', ''prm_chave='||prm_usuario||''', false, ''content'');  carregaPainel(''upload'', '''||prm_usuario||'''); }');
              raise ws_many_rows;
          end;

          -- pega o id do objeto para setar a propriedade na object_attrib
          ws_objeto :=  substr(ws_usuario, 1 ,instr(ws_usuario,'|')-1);
          ws_doc_limit:=to_number(nvl(fun.getprop(ws_objeto,'LIMIT_DOC_BRO'),'99999'));
         
          -- Caso o admin popule o campo com valor 0 em vez de deixar em branco quando não quer limite
          if ws_doc_limit = 0 then
            ws_doc_limit := 99999;
          end if;

          -- compara o tamanho em bytes
          if ws_doc_size > (ws_doc_limit*1024) then
            rollback;
            htp.p('alerta(''msg'', '''||fun.lang('Arquivo excedeu o tamanho limite de '||ws_doc_limit||'kb')||'!''); if(document.getElementById(''browseredit'')){ var valor = document.getElementById(''browseredit'').className; ajax(''list'', ''anexo'', ''prm_chave=''+valor, false, ''editb'', '''', '''', ''bro''); } else { ajax(''list'', ''uploaded'', ''prm_chave='||prm_usuario||''', false, ''content'');  carregaPainel(''upload'', '''||prm_usuario||'''); }');
            raise ws_limit_doc;
          end if;
            
        end if;

        commit;
        htp.p('alerta(''msg'', '''||fun.lang('Arquivo enviado com sucesso')||'!''); if(document.getElementById(''browseredit'')){ var valor = document.getElementById(''browseredit'').className; ajax(''list'', ''anexo'', ''prm_chave=''+valor, false, ''editb'', '''', '''', ''bro''); } else if (parent.document.getElementById(''painel'').firstChild.innerHTML.indexOf(''AVISO'')>-1) {} else { ajax(''list'', ''uploaded'', ''prm_chave='||prm_usuario||''', false, ''content''); if(document.getElementById(''btnVoltar'')){ var valor = ''VOLTAR'' + document.getElementById(''btnVoltar'').getAttribute(''data-valor''); carregaPainel(''upload'', valor); } else { carregaPainel(''upload'', '''||prm_usuario||''');} }');
    
    exception 
      when ws_existe_atual then
        insert into bi_log_sistema values (sysdate, 'UPLOAD.UPLOAD - Arquivo ja existe no sistema no usuario atual', ws_usuario, 'ERRO');
        commit;

      when ws_existe_dwu then
        insert into bi_log_sistema values (sysdate, 'UPLOAD.UPLOAD - Arquivo ja existe no sistema no usuario administrador', ws_usuario, 'ERRO');
        commit;

      when ws_nofile then
          htp.p('Nenhum arquivo selecionado!');

      when ws_limit_doc then
        insert into bi_log_sistema values (sysdate, 'Excedeu o tamanho limite do arquivo de '||ws_doc_limit||'kb - UPLOAD BROWSER SIZE', ws_usuario, 'ERRO');
        commit;

      when ws_many_rows then
        insert into bi_log_sistema values (sysdate, 'J&aacute; existe um arquivo com o mesmo nome para essa linha - UPLOAD BROWSER SIZE', ws_usuario, 'ERRO');
        commit;

      when others then
          htp.p(fun.lang('Carregado ') || l_nome_real || fun.lang(' ERRO.'));
          htp.p(sqlerrm);
    END;
  exception
    when ws_nofile then
      htp.p('Nenhum arquivo selecionado!');
      htp.p('alerta(''msg'', '''||fun.lang('Nenhum arquivo selecionado')||'!''); if(document.getElementById(''browseredit'')){ var valor = document.getElementById(''browseredit'').className; ajax(''list'', ''anexo'', ''prm_chave=''+valor, false, ''editb'', '''', '''', ''bro''); } else { ajax(''list'', ''uploaded'', ''prm_chave='||prm_usuario||''', false, ''content'');  carregaPainel(''upload'', '''||prm_usuario||'''); }');
    
    when others then 
      htp.p(sqlerrm);

  end upload;

  PROCEDURE download IS

    l_nome  VARCHAR2(255);
    
  BEGIN

    l_nome := SUBSTR(OWA_UTIL.get_cgi_env('PATH_INFO'), 2);
    WPG_DOCLOAD.download_file(l_nome);

  EXCEPTION

    WHEN OTHERS THEN
      HTP.htmlopen;
      HTP.headopen;
      HTP.title(fun.lang('Arquivo Carregado.'));
      HTP.headclose;
      HTP.bodyopen;
      HTP.header(1, 'STATUS');
      HTP.print('Carregado ' || l_nome || ' ERRO.');
      HTP.print(SQLERRM);
      HTP.bodyclose;
      HTP.htmlclose;

  END download;

  Procedure Download ( arquivo  In  Varchar2 ) As
    L_Blob_Content  Tab_Documentos.Blob_Content%Type;
    l_mime_type     TAB_DOCUMENTOS.mime_type%TYPE;

    n_name          varchar2(4000);

  BEGIN
      /*fcl.refresh_Session;*/
    SELECT blob_content,
          mime_type,
      name
    INTO   l_blob_content,
          L_Mime_Type,
      n_name
    From   Tab_Documentos
    WHERE  name = arquivo and (usuario = 'DWU' or usuario = 'SYS');

    OWA_UTIL.mime_header(l_mime_type, FALSE);
    HTP.p('Content-Length: ' || DBMS_LOB.getlength(l_blob_content));
    HTP.p('Content-Disposition: filename="'||n_name||'"');
    OWA_UTIL.http_header_close;

    WPG_DOCLOAD.download_file(l_blob_content);
  EXCEPTION
    WHEN OTHERS THEN
      HTP.htmlopen;
      HTP.headopen;
      HTP.title('ARQUIVO');
      HTP.headclose;
      HTP.bodyopen;
      HTP.header(1, 'ERRO');
      HTP.print(SQLERRM);
      HTP.bodyclose;
      HTP.htmlclose;
  End Download;
	
end upload;


