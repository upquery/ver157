create or replace package body ETF  is

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--     	cópia da FUN 
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function randomCode( prm_tamanho number default 10) return varchar2 as 

    ws_code varchar2(200);

begin

    select xmlagg(xmlelement("r", ch)).extract('//text()').getstringval() into ws_code from
    (
        select distinct first_value(ch) over (partition by lower(ch)) as ch
        from (
            select substr('abcdefghijklmnpqrstuvwxyzABCDEFGHIJKLMNPQRSTUVWXYZ123456789',
                level, 1) as ch
            from dual 
            connect by level <= 59
            order by dbms_random.value
            )
        where rownum <= prm_tamanho
    );

    return ws_code;

end randomCode;


function cdesc ( prm_codigo  char  default null,
                 prm_tabela  char default null,
                 prm_reverse boolean default false ) return varchar2 as

    ws_descricao varchar2(800);

    ws_sql  varchar2(2000);

    cursor crs_cdesc is
    select nds_tfisica, nds_cd_codigo, nds_cd_empresa, nds_cd_descricao
    from CODIGO_DESCRICAO
    where nds_tabela = upper(prm_tabela);

    ws_cdesc crs_cdesc%rowtype;
    ws_cursor integer;
    --WS_PAR_EMP
    WS_LINHAS number;
    WS_OWNER VARCHAR2(100);

begin

     -- RETIRADO O EXECUTE IMMEDIATE POR QUESTÃO DE AUMENTO DE USO DE PROCESSAMENTO 04/04/2022

    Open  crs_cdesc;
    Fetch crs_cdesc into ws_cdesc;
    close crs_cdesc;
    
    -- condição criada para trazer as mascaras do BI e não do owner. 28/12/2022
    IF ws_cdesc.nds_tfisica IN ('MASCARAS') THEN
        WS_OWNER:=nvl(etf.ret_var('OWNER_BI'),'DWU');
    ELSE
        WS_OWNER:=nvl(etf.ret_var('OWNER_TABLE_DATA'),'DWU');
    END IF;
    
    -- teste para verificar se ligação é igual a 'SEM'
    IF NVL(PRM_TABELA,'SEM') = 'SEM' THEN

        RETURN(PRM_CODIGO);
    END IF;
   

    if prm_reverse = false then
        ws_sql := 'select '||rtrim(ws_cdesc.nds_cd_descricao)||' from '||WS_OWNER||'.'||ws_cdesc.nds_tfisica||' where '||ws_cdesc.nds_cd_codigo||' = :coluna';
    else
        ws_sql := 'select '||rtrim(ws_cdesc.nds_cd_codigo)||'    from '||WS_OWNER||'.'||ws_cdesc.nds_tfisica||' where '||ws_cdesc.nds_cd_descricao||' = :coluna';
    end if;
    
    ws_cursor := dbms_sql.open_cursor;

    begin
        dbms_sql.parse(ws_cursor, ws_sql, DBMS_SQL.NATIVE);
        dbms_sql.define_column(ws_cursor, 1, ws_descricao, 400);
        DBMS_SQL.BIND_VARIABLE(ws_cursor, ':coluna',prm_codigo);

        ws_linhas := dbms_sql.execute(ws_cursor);

        ws_linhas := dbms_sql.fetch_rows(ws_cursor);

        dbms_sql.column_value(ws_cursor, 1, ws_descricao);

        dbms_sql.close_cursor(ws_cursor);
    exception
        when others then
            dbms_sql.close_cursor(ws_cursor);
    end;

    return(nvl(trim(ws_descricao), prm_codigo));

exception when others then
       return(prm_codigo);
end CDESC;

-------------------------------------------------------------------------------------------------------

function ret_var  ( prm_variavel   varchar2 default null, 
                    prm_usuario    varchar2 default 'DWU' ) return varchar2 as
    ws_count      number; 
    ws_variavel   varchar2(200); 
    ws_conteudo   var_conteudo.conteudo%type; 
begin 
    ws_variavel := replace(replace(prm_variavel, '#[', ''), ']', '');
    ws_conteudo := null; 

    select count(*), max(conteudo) into ws_count, ws_conteudo 
      from VAR_CONTEUDO
	 where USUARIO  = prm_usuario 
	   and VARIAVEL = ws_variavel; 
    
    if ws_count = 0 then -- Se não encontrou para o usuário, procura no usuário padrão DWU 
        select count(*), max(conteudo) into ws_count, ws_conteudo 
          from VAR_CONTEUDO
	     where USUARIO  = 'DWU' 
	       and VARIAVEL = ws_variavel; 
    end if; 

    return ws_conteudo; 

exception when others then
    return '';
end ret_var;

-------------------------------------------------------------------------------------------------------

procedure execute_now ( prm_comando  varchar2 default null,
                        prm_repeat  varchar2 default  'S' ) as

    job_id          number;
    ws_owner        varchar2(90);
    ws_name         varchar2(90);
    ws_line         number;
    ws_caller       varchar2(90);
    ws_count        number := 0;
    ws_dt_next      date; 

begin

    if prm_repeat = 'N' then
	    select count(*) into ws_count from all_jobs where what = trim(prm_comando)||';';
    end if;
    
    OWA_UTIL.WHO_CALLED_ME(ws_owner, ws_name, ws_line, ws_caller);
	
    if ws_count = 0 then
        if etf.ret_var('CLIENTE') = '000000116' THEN  -- Quebra galho na Agrosul para compesar hora errada no JOB
            DBMS_JOB.SUBMIT(job => job_id, what => trim(prm_comando)||';', next_date => sysdate+((1/1440)/40)-((1/24)*2), interval => NULL);
        else 
            DBMS_JOB.SUBMIT(job => job_id, what => trim(prm_comando)||';', next_date => sysdate+((1/1440)/40), interval => NULL);
        end if;     
        commit;
    end if;
EXCEPTION WHEN OTHERS THEN
    insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - EXECUTE_NOW', etf.getUsuario, 'ERRO');
    commit;
end EXECUTE_NOW;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

function vpipe ( prm_entrada varchar2,
                 prm_divisao varchar2 default '|' ) return CHARRET pipelined as

   ws_bindn      number;
   ws_texto      varchar2(32000);
   ws_nm_var      varchar2(32000);
   ws_flag         char(1);

begin

   ws_flag  := 'N';
   ws_bindn := 0;
   ws_texto := prm_entrada;

   loop
       if  ws_flag = 'Y' then
           exit;
       end if;

       if  nvl(instr(ws_texto,prm_divisao),0) = 0 then
      ws_flag  := 'Y';
      ws_nm_var := ws_texto;
       else
      ws_nm_var := substr(ws_texto, 1 ,instr(ws_texto,prm_divisao)-1);
      ws_texto  := substr(ws_texto, length(ws_nm_var||prm_divisao)+1, length(ws_texto));
       end if;

       ws_bindn := ws_bindn + 1;
       pipe row (ws_nm_var);

   end loop;

exception
   when others then
      pipe row(sqlerrm||'=VPIPE');

end VPIPE;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

function vpipe_clob ( prm_entrada clob,
                      prm_divisao varchar2 default '|' ) return CHARRET pipelined as

   ws_bindn      number;
   ws_texto      varchar2(32000);
   ws_nm_var     varchar2(32000);
   ws_flag       char(1);

begin

   ws_flag  := 'N';
   ws_bindn := 0;
   ws_texto := prm_entrada;

   loop
       if  ws_flag = 'Y' then
           exit;
       end if;

       if  nvl(instr(ws_texto,prm_divisao),0) = 0 then
            ws_flag  := 'Y';
            ws_nm_var := ws_texto;
       else
            ws_nm_var := substr(ws_texto, 1 ,instr(ws_texto,prm_divisao)-1);
            ws_texto  := substr(ws_texto, length(ws_nm_var||prm_divisao)+1, length(ws_texto));
       end if;

       ws_bindn := ws_bindn + 1;
       pipe row (ws_nm_var);

   end loop;

exception
   when others then
      pipe row(sqlerrm||'=VPIPE_CLOB');

end VPIPE_CLOB;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

function vpipe_par ( prm_entrada varchar ) return tab_parametros pipelined as

   ws_bindn      number;
   ws_texto      long;
   ws_nm_var     long;
   ws_condicao   long;
   ws_flag       char(1);
   ws_step       integer;
   ws_p1         varchar2(4000);

begin

/*CREATE TYPE GER_PARAMETROS AS OBJECT
            ( CD_COLUNA    VARCHAR2(4000),
              CD_CONTEUDO  VARCHAR2(4000),
              cd_condicao  varchar2(4000));

CREATE TYPE TAB_PARAMETROS
            AS TABLE OF GER_PARAMETROS;*/

   ws_flag  := 'N';
   ws_bindn := 0;
   ws_texto := prm_entrada;
   ws_step  := 0;

   loop
       if  ws_flag = 'Y' then
           exit;
       end if;

       if  nvl(instr(ws_texto,'|'),0) = 0 then
           ws_flag  := 'Y';
           ws_nm_var := ws_texto;
       else
           ws_nm_var := substr(ws_texto, 1 ,instr(ws_texto,'|')-1);
           ws_texto := substr(ws_texto, length(ws_nm_var||'|')+1, length(ws_texto));
       end if;

        ws_bindn := ws_bindn + 1;
	    If  Ws_Step = 1 Then
			Select Decode(Substr(Ws_Nm_Var,1,2),'$[',Decode(Upper(Substr(Ws_Nm_Var,3,Instr(Ws_Nm_Var,']')-3)),'IGUAL','IGUAL','DIFERENTE','DIFERENTE','MAIOR','MAIOR','MENOR','MENOR','MAIOROUIGUAL','MAIOROUIGUAL','MENOROUIGUAL','MENOROUIGUAL','LIKE','LIKE','NOTLIKE','NOTLIKE','NULO','NULO','NNULO','NNULO','IGUAL'),'IGUAL') Into Ws_Condicao From Dual;
			select Decode(Substr(ws_nm_var,1,2),'$[',Substr(ws_nm_var,Instr(ws_nm_var,']')+1,Length(ws_nm_var)),ws_nm_var) into ws_nm_var from DUAL;

			pipe row (GER_PARAMETROS (trim(ws_p1), replace(trim(ws_nm_var), '$[CONCAT]', '||'), trim(ws_condicao)) );
			ws_step := 0;
		else
			ws_p1   := ws_nm_var;
			ws_step := 1;
		end if;
   end loop;

exception
   When Others Then
      pipe row(GER_PARAMETROS('=RET_LIST','XXX',''));

end VPIPE_PAR;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

function lang ( prm_texto varchar2 default null ) return varchar2 as

    ws_traduzido   varchar2(4000);
    ws_padrao      varchar2(40);
    ws_cont        integer;    
Begin
    
    if nvl(etf.ret_var('LANG'), 'N') = 'S' then
        ws_padrao := etf.getLang;
        ws_traduzido := prm_texto;

        /***** Desativado, não deve ser utilizado comando de insert dentro de funções, pois elas podem ser utilizadas em select
        select count(*) into ws_cont from utl_traducoes_feitas where texto = prm_texto;
        if ws_cont = 0 then 
            insert into utl_traducoes_feitas (texto,fixado) values (prm_texto,'N'); 
        end if; 
        ****/ 

        begin

            if ws_padrao = 'ENGLISH' then
                select max(traduzido_ingles) into ws_traduzido
                from utl_traducoes_feitas where texto=prm_texto;
            end if;

            if ws_padrao = 'SPANISH' then
                select max(traduzido_espanhol) into ws_traduzido
                from utl_traducoes_feitas where texto=prm_texto;
            end if;

            if ws_padrao = 'ITALIAN' then
                select max(traduzido_italiano) into ws_traduzido
                from utl_traducoes_feitas where texto=prm_texto;
            end if;

            if ws_padrao = 'GERMAN' then
                select max(traduzido_alemao) into ws_traduzido
                from utl_traducoes_feitas where texto=prm_texto;
            end if;

        exception
            when others then 
            ws_traduzido := '*'||prm_texto;
        end;

        return (nvl(ws_traduzido, '*'||prm_texto));
    else
        return prm_texto;
    end if;

end LANG;



function xexec ( ws_content  varchar2 default null ) return varchar2 as   -- Copia da FUN com simplificações para utilização somente pelo processo de ETL 
    ws_tcont        varchar2(3000);
    ws_calculado    varchar2(2000);
    ws_cursor       integer;
    ws_linhas       integer;
    ws_sql          varchar2(2000);
begin

    ws_tcont := ws_content;

    if  UPPER(substr(ws_tcont,1,5)) = 'EXEC=' then
        WS_TCONT := REPLACE(UPPER(WS_TCONT), 'EXEC=','');
        WS_TCONT := REPLACE(WS_TCONT, '$[NOW]', trim(to_char(sysdate, 'DD/MM/YYYY HH24:MI')));
        WS_TCONT := REPLACE(WS_TCONT, '$[DOWNLOAD]', ''||nvl(etf.ret_var('OWNER_BI'),'DWU')||'.fcl.download?arquivo=');
        
        ws_sql := 'select '||trim(ws_tcont)||' from dual';
        ws_cursor := dbms_sql.open_cursor;
        dbms_sql.parse(ws_cursor, ws_sql, DBMS_SQL.NATIVE);
        dbms_sql.define_column(ws_cursor, 1, ws_calculado, 600);

        ws_linhas := dbms_sql.execute(ws_cursor);
        ws_linhas := dbms_sql.fetch_rows(ws_cursor);

        dbms_sql.column_value(ws_cursor, 1, ws_calculado);
        dbms_sql.close_cursor(ws_cursor);
        ws_tcont := ws_calculado;
    end if;

    return(ws_tcont);

exception when others then
    return(ws_tcont);
end xexec;



----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Gera e retorna ID único 
function gen_id return varchar2 is

	    ws_chave_final      varchar2(100);
        ws_ant_chave        varchar2(100);
        ws_tempo            varchar2(100);
        ws_chave            varchar2(100);
        p_id_cliente        varchar2(10);

begin
        begin
        p_id_cliente   := to_char(sysdate,'SSHH24SSDD');
        ws_chave_final := '';
        ws_ant_chave   := etf.send_id;
        ws_chave       := ws_ant_chave||etf.check_id(ws_ant_chave);
        ws_tempo       := to_char(sysdate,'DDMMYYYYHH24MISS');

        ws_chave_final := ws_chave_final||substr(ws_chave,1, 1)||substr(ws_tempo,14 ,1);
        ws_chave_final := ws_chave_final||substr(ws_chave,2, 1)||substr(ws_tempo,13 ,1);
        ws_chave_final := ws_chave_final||substr(ws_chave,3, 1)||substr(ws_tempo,12 ,1);
        ws_chave_final := ws_chave_final||substr(ws_chave,4, 1)||substr(ws_tempo,11 ,1);
        ws_chave_final := ws_chave_final||substr(ws_chave,5, 1)||substr(ws_tempo,10 ,1);
        ws_chave_final := ws_chave_final||substr(ws_chave,6, 1)||substr(ws_tempo,9 ,1);
        ws_chave_final := ws_chave_final||substr(ws_chave,7, 1)||substr(ws_tempo,8 ,1);
        ws_chave_final := ws_chave_final||substr(ws_chave,8, 1)||substr(ws_tempo,7 ,1);
        ws_chave_final := ws_chave_final||substr(ws_chave,9, 1)||substr(ws_tempo,6 ,1);
        ws_chave_final := ws_chave_final||substr(ws_chave,10,1)||substr(ws_tempo,5 ,1);
        ws_chave_final := ws_chave_final||substr(ws_chave,11,1)||substr(ws_tempo,4 ,1);
        ws_chave_final := ws_chave_final||substr(ws_chave,12,1)||substr(ws_tempo,3 ,1);
        ws_chave_final := ws_chave_final||substr(ws_chave,13,1)||substr(ws_tempo,2 ,1);
        ws_chave_final := ws_chave_final||substr(ws_chave,14,1)||substr(ws_tempo,1 ,1);

        ws_chave_final := substr(ws_chave_final,28,1)||substr(ws_chave_final,1,1)||substr(p_id_cliente,8,1)||substr(ws_chave_final,9,1)||
                          substr(ws_chave_final,25,1)||substr(ws_chave_final,2,1)||substr(p_id_cliente,7,1)||substr(ws_chave_final,10,1)||
                          substr(ws_chave_final,23,1)||substr(ws_chave_final,3,1)||substr(p_id_cliente,6,1)||substr(ws_chave_final,11,1)||
                          substr(ws_chave_final,26,1)||substr(ws_chave_final,4,1)||substr(p_id_cliente,5,1)||substr(ws_chave_final,12,1)||
                          substr(ws_chave_final,21,1)||substr(ws_chave_final,5,1)||substr(p_id_cliente,4,1)||substr(ws_chave_final,13,1)||
                          substr(ws_chave_final,24,1)||substr(ws_chave_final,6,1)||substr(p_id_cliente,3,1)||substr(ws_chave_final,14,1)||
                          substr(ws_chave_final,22,1)||substr(ws_chave_final,7,1)||substr(p_id_cliente,2,1)||substr(ws_chave_final,15,1)||
                          substr(ws_chave_final,27,1)||substr(ws_chave_final,8,1)||substr(p_id_cliente,1,1)||substr(ws_chave_final,16,1)||
                          substr(ws_chave_final,21,1)||substr(ws_chave_final,20,1)||substr(ws_chave_final,19,1)||substr(ws_chave_final,18,1)||
                          substr(ws_chave_final,17,1);
        end;
        return(ws_chave_final);
end gen_id;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

function send_id ( prm_cliente varchar2 default null ) return varchar2 as

  type           tp_array is table of varchar2(2000) index by binary_integer;
  ws_array       tp_array;
  ws_counter     integer;
  ws_indice      varchar2(1);
  ws_session     varchar2(2);
  ws_indice_fake varchar2(1);
  ws_imei        varchar2(30);
  ws_origem      varchar2(30);

begin

  ws_imei         := '01275600346'||substr(prm_cliente, 7, 3)||'3877';
 
  ws_array(0)     := 'QPWOLASJIE';
  ws_array(1)     := 'ESLWPQMZNB';
  ws_array(2)     := 'YTRUIELQCB';
  ws_array(3)     := 'RADIOSULTE';
  ws_array(4)     := 'RITALQWCVM';
  ws_array(5)     := 'ZMAKQOCJDE';
  ws_array(6)     := 'YTHEDJKSPQ';
  ws_array(7)     := 'PIRALEZOUT';
  ws_array(8)     := 'HJWPAXOQTI';
  ws_array(9)     := 'DFRTEOAPQX';

  ws_indice       := substr(to_char(sysdate,'SS'),2,1);

  select  substr(ws_array(ws_indice),(to_number(substr(sid,1,1))+1),1)||substr(ws_array(ws_indice),(to_number(substr(serial#,1,1))+1),1)
          into ws_session
  from    v$session
  where   audsid  = sys_context('USERENV', 'SESSIONID');

  ws_indice_fake := abs((to_number(ws_indice)-to_number(substr(to_char(sysdate,'SS'),1,1))));

  ws_imei := substr(ws_array(ws_indice_fake),(to_number(substr(ws_imei,9, 1))+1),1)||
             substr(ws_array(ws_indice_fake),(to_number(substr(ws_imei,10,1))+1),1)||
             substr(ws_array(ws_indice_fake),(to_number(substr(ws_imei,11,1))+1),1);

  ws_indice_fake := substr(ws_array(2),(to_number(substr(ws_indice_fake, 1,1)+1)),1);
  ws_indice      := substr(ws_array(1),(to_number(substr(ws_indice,      1,1)+1)),1);

  return(ws_imei||ws_session||ws_indice||ws_indice_fake);

end send_id;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

function check_id ( prm_chave varchar2 default null, prm_cliente varchar2 default null ) return varchar2 as

	type tp_array is table of varchar2(2000) index by binary_integer;
	ws_array       tp_array;
	ws_counter     integer;
	ws_indice      varchar2(1);
	ws_indice_fake varchar2(1);
	ws_session     varchar2(2);
	ws_check_imei  varchar2(3);
	ws_imei        varchar2(30);
	ws_retorno     varchar2(30);

begin

    ws_imei     := '01275600346'||substr(prm_cliente, 7, 3)||'3877';

	ws_array(0) := 'QPWOLASJIE';
	ws_array(1) := 'ESLWPQMZNB';
	ws_array(2) := 'YTRUIELQCB';
	ws_array(3) := 'RADIOSULTE';
	ws_array(4) := 'RITALQWCVM';
	ws_array(5) := 'ZMAKQOCJDE';
	ws_array(6) := 'YTHEDJKSPQ';
	ws_array(7) := 'PIRALEZOUT';
	ws_array(8) := 'HJWPAXOQTI';
	ws_array(9) := 'DFRTEOAPQX';

	ws_indice      := (instr(ws_array(1),substr(prm_chave,6,1)))-1;
	ws_indice_fake := (instr(ws_array(2),substr(prm_chave,7,1)))-1;
	ws_session     := (instr(ws_array(ws_indice), substr(prm_chave,4,1))-1) ||	
                      (instr(ws_array(ws_indice), substr(prm_chave,5,1))-1);
	ws_check_imei  := (instr(ws_array(ws_indice_fake),substr(prm_chave,1,1))-1) ||  
                      (instr(ws_array(ws_indice_fake),substr(prm_chave,2,1))-1) ||
	                  (instr(ws_array(ws_indice_fake),substr(prm_chave,3,1))-1);

	ws_indice      := substr(to_char(sysdate,'SS'),2,1);
	ws_indice_fake := abs((to_number(ws_indice)-to_number(substr(to_char(sysdate,'SS'),1,1))));
	ws_session     := substr(ws_array(abs(abs(ws_indice - ws_indice_fake))),(to_number(substr(ws_session,1,1))+1),1) ||
	                  substr(ws_array(abs(abs(ws_indice - ws_indice_fake))),(to_number(substr(ws_session,2,1))+1),1);
	ws_imei        := substr(ws_array(ws_indice_fake),(to_number(substr(ws_imei,12, 1))+1),1)||
	                  substr(ws_array(ws_indice_fake),(to_number(substr(ws_imei,13, 1))+1),1)||
	                  substr(ws_array(ws_indice_fake),(to_number(substr(ws_imei,14, 1))+1),1);

	ws_indice_fake := substr(ws_array(4),(to_number(substr(ws_indice_fake, 1,1)+1)),1);
	ws_indice      := substr(ws_array(5),(to_number(substr(ws_indice, 1,1)+1)),1);

	if ws_check_imei <> substr(ws_imei,9,3) then
	    ws_retorno := 'ERRO';
	else
	    ws_retorno := ws_imei||ws_session||ws_indice||ws_indice_fake;
	end if;

	return(ws_retorno);

end check_id;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

function getSessao  ( prm_cod varchar2 default null ) return varchar2  as

	ws_valor varchar2(80);

begin

    select 	valor into ws_valor
	from	bi_sessao
	where	cod = prm_cod and valor in (select usu_nome from usuarios);

	return ws_valor;
    
exception when others then
    return '';
end getSessao;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--     	cópia da GBL 
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

function getLang return varchar2 as

	ws_valor varchar2(80) := 'PORTUGUESE';

begin
	
	if nvl(etf.ret_var('LANG'), 'N') = 'S' then
		select propriedade into ws_valor from object_attrib where owner = etf.getUsuario and cd_prop = 'LINGUAGEM';
	end if;

	return nvl(ws_valor, 'PORTUGUESE');
exception when others then
	return 'PORTUGUESE';
end getLang;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

function getUsuario return varchar2 as

	ws_id varchar2(20);
	ws_user varchar2(80) := 'NOUSER';

begin

	if nvl(etf.ret_var('XE'), 'N') = 'S' then
		return user;
	end if;

	begin
		ws_user := etf.getSessao(Owa_Cookie.Get('SESSION').Vals(1));
	exception when others then
		select Sys_Context('userenv','sid') into ws_id From dual;
		ws_user := etf.getSessao('ANONYMOUS'||ws_id);
	end;

	return nvl(ws_user, 'NOUSER');
exception when others then
	return ws_user;
end getUsuario;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--     	cópia da SCH - chama a SCH
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

procedure alert_online (p_id            in out number,
                        p_bloco		    varchar2 default null,
                        p_inicio        date     default null,
                        p_fim		    date     default null,
                        p_parametro	    varchar2 default null,
                        p_status 	    varchar2 default null,
                        p_obs	        varchar2 default null,
                        p_st_notify     varchar2 default 'REGISTRO',
                        p_mail_notify   varchar2 default 'N',
                        p_pipe_tabelas  varchar2 default null ) as  
begin 
    execute immediate 'begin sch.alert_online (:p_id, :p_bloco, :p_inicio, :p_fim, :p_parametro, :p_status, :p_obs, :p_st_notify, :p_mail_notify, :p_pipe_tabelas); end;' 
                                using in out p_id, in p_bloco, in p_inicio, in p_fim, in p_parametro, in p_status, in p_obs, in p_st_notify, in p_mail_notify, in p_pipe_tabelas ;
end alert_online; 



----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Executa do novo processo de integração 
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure exec_integrador(prm_run_id            in varchar2,
                          prm_data_ini          in varchar2 default null,
                          prm_data_fim          in varchar2 default null,
                          prm_status_fila       in varchar2 default 'A',
                          prm_tempo_loop        in number   default 30,
                          prm_erro_step        out varchar2) as 

ws_dh_inicio  date;
ws_id_alert   number;
ws_tabelas    varchar2(100);
ws_error      varchar2(4000);
ws_status     varchar2(30);

ws_step_id        varchar2(50);   -- nome da ação
ws_tipo_comando   varchar2(50);   -- tipo ação
ws_comando        clob;           -- query inserir
ws_comando_limpar varchar2(4000); -- query deletar
ws_tab_destino    varchar2(50);   -- tabela destino
ws_unid_id        varchar2(50);   -- id da fila
ws_conexao        varchar2(200);  -- id da conexão 

ws_dh_ini_aguardar   date;
ws_status_integracao varchar2(10) := 'A';
ws_erro_integracao   varchar2(4000);
ws_st_notify         varchar2(20); 

begin

    ws_dh_inicio := sysdate;
    ws_id_alert  := null; 
    ws_tabelas   := '';   

    --Coletar informações necessárias da ELT_STEP
    select step_id, tipo_comando, comando, comando_limpar, tbl_destino, id_conexao
      into ws_step_id, ws_tipo_comando, ws_comando, ws_comando_limpar, ws_tab_destino, ws_conexao
      from etl_step
     where run_id = prm_run_id;

    etf.alert_online(ws_id_alert, 'EXEC_INTEGRADOR', ws_dh_inicio, null,prm_run_id||'-'||ws_step_id||' '||ws_tipo_comando||' '||prm_data_ini||' '||prm_data_fim ,'ATUALIZANDO','', 'REGISTRO', 'N', ws_tabelas);     

    ------------------------------------------------------------------------------------
    -- INSERIR AÇÃO NA FILA 
    ------------------------------------------------------------------------------------
    
    -- Fazer o replace do comando de insercao e delecao de acordo com as parametrizações
    if ws_tipo_comando = 'FULL' then
        null;
    elsif ws_tipo_comando = 'SCHEDULER' then
        ws_comando        := replace(replace(ws_comando,       '$[DATA_INI]',chr(39)||prm_data_ini||chr(39)),'$[DATA_FIM]',chr(39)||prm_data_fim||chr(39));
        ws_comando_limpar := replace(replace(ws_comando_limpar,'$[DATA_INI]',chr(39)||prm_data_ini||chr(39)),'$[DATA_FIM]',chr(39)||prm_data_fim||chr(39));
    end if;

    select etf.gen_id into ws_unid_id from dual;
    
    -- Inserir ação na fila
    insert into etl_fila (id_uniq,    run_id,     tbl_destino,    comando,    comando_limpar,  dt_criacao, dt_inicio, dt_final, status,          erros,  id_conexao)
                  values (ws_unid_id, prm_run_id, ws_tab_destino, ws_comando, ws_comando_limpar, sysdate,  null,      null,     prm_status_fila, null, ws_conexao );
    commit;


    ------------------------------------------------------------------------------------
    -- AGUARDAR OPERAÇÃO DE POPULAR TABELA SER CONCLUÍDA 
    ------------------------------------------------------------------------------------
    -- Loop para aguardar finalizar carga dos dados.
    -- Se ficar mais que o tempo enviado por parametro nesse laço ele pula fora e indica o erro de "timeout"
    -- Se finalizar com erro ele tambem pula fora e registra o erro gravado na etl_fila
    -- Se finalizar ele pula fora com sucesso

    ws_dh_ini_aguardar := sysdate;

    while (sysdate - ws_dh_ini_aguardar) <= prm_tempo_loop/1440 and ws_status_integracao in ('A','R') 
    loop
        select status, erros 
          into ws_status_integracao, ws_erro_integracao
          from etl_fila
         where id_uniq = ws_unid_id 
           and run_id  = prm_run_id;
        --   
        dbms_lock.sleep(10);           
    end loop;

    if ws_status_integracao in ('A','R') then  --Se saiu do loop e o status ainda é A ou R, é pq estorou o timeout
        ws_error     := 'Aguardando integracao a mais de '||prm_tempo_loop||' minutos.(ETF)';
        ws_status    := 'ERRO';
        ws_st_notify := 'ENVIO'; 
        update etl_fila set status = 'E', erros = ws_error
         where id_uniq = ws_unid_id 
           and run_id  = prm_run_id;
        commit;            
    elsif ws_status_integracao = 'E' THEN
        ws_error     := ws_erro_integracao;
        ws_status    := 'ERRO';
        ws_st_notify := 'ENVIO'; 
    else 
        ws_error     := null;
        ws_status    := 'FINALIZADO';
        ws_st_notify := 'REGISTRO'; 
    END IF;

    prm_erro_step := ws_status;  -- Retorna o Status

    etf.alert_online(ws_id_alert, 'EXEC_INTEGRADOR', ws_dh_inicio, sysdate, null, ws_status, ws_error, ws_st_notify, 'N', ws_tabelas); 

exception when others then
    ws_error      := substr(dbms_utility.format_error_stack||'-'||dbms_utility.format_error_backtrace,1,3999); 
    ws_status     := 'ERRO';
    ws_st_notify  := 'ENVIO'; 
    prm_erro_step := ws_status;    
    etf.alert_online(ws_id_alert, 'EXEC_INTEGRADOR', ws_dh_inicio, sysdate, null, ws_status, ws_error, ws_st_notify, 'N', ws_tabelas);     
end exec_integrador;




----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Executa do novo processo de integração 
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure exec_step_integrador(prm_run_step_id    in varchar2, 
                               prm_log_id         in varchar2 default null,
                               prm_step_id        in varchar2 default null,
                               prm_comando        in varchar2 default null,
                               prm_comando_limpar in varchar2 default null,
                               prm_retorno       out clob, 
                               prm_status        out varchar2 ) as 

    cursor c_run is 
        select run_id, step_id, qt_tentativas
        from   etl_run_step 
        where  run_step_id = prm_run_step_id ;

    cursor c_step (p_step_id   varchar2) is 
        select ds_step, tipo_comando, comando, comando_limpar, tbl_destino, id_conexao
        from   etl_step 
        where  step_id = p_step_id ; 

    ws_step     c_step%rowtype; 

    ws_minuto_espera number; 
    ws_dh_inicio     date;
    ws_id_alert      number;
    ws_tabelas       varchar2(100);
    ws_erro          varchar2(32000);
    ws_status_alert  varchar2(30);

    ws_unid_id        varchar2(50);   -- id da fila
    ws_id_conexao     varchar2(200);  -- id da conexão 
    ws_tbl_destino    varchar2(200);  

    ws_par_dt_ini     varchar2(20); 
    ws_par_dt_fim     varchar2(20); 

    ws_dh_ini_aguardar   date;
    ws_status_integracao varchar2(10) := 'A';
    ws_erro_integracao   varchar2(4000);
    ws_st_notify         varchar2(20); 
    ws_parametros        varchar2(2000); 
    ws_conteudo          varchar2(2000);
    ws_step_id           varchar2(200);
    ws_ret_processa      varchar2(2000);
    ws_run_step_id       etl_run_step.run_step_id%type;
    ws_run_id            etl_run_step.run_id%type;
    ws_qt_tentativas     etl_run_step.qt_tentativas%type;
    ws_comando           etl_step.comando%type; 
    ws_comando_limpar    etl_step.comando_limpar%type;  
    ws_raise_retorno     exception; 

begin
    ws_erro       := null;
    ws_dh_inicio  := sysdate;
    ws_id_alert   := null; 
    ws_tabelas    := '';   
    prm_retorno   := null;
    prm_status    := null;

    ws_run_id        := null;
    ws_run_step_id   := prm_run_step_id;
    ws_step_id       := prm_step_id; 
    ws_parametros    := null;  
    ws_qt_tentativas := 1; 

    if nvl(ws_run_step_id,'N/A') = 'TESTE_CONEXAO' then        -- Teste de conexão de banco de dados do cliente 
        ws_id_conexao    := prm_step_id;
        ws_run_id        := ws_run_step_id;
        ws_step_id       := ws_run_step_id;
        ws_tbl_destino   := null;
        ws_minuto_espera := 5;
    else 
        -- Busca dados da ação
        if ws_run_step_id is not null then 
            open  c_run;
            fetch c_run into ws_run_id, ws_step_id, ws_qt_tentativas;
            close c_run; 
        end if;     

        if ws_step_id is null then       
            ws_erro := 'Nao foi possivel identificar a acao(STEP) a ser executada';
            raise ws_raise_retorno;     
        end if; 
        open  c_step (ws_step_id);
        fetch c_step into ws_step;
        close c_step; 

        ws_id_conexao     := ws_step.id_conexao;
        ws_tbl_destino    := ws_step.tbl_destino; 
        ws_comando        := nvl(prm_comando,        ws_step.comando);
        ws_comando_limpar := nvl(prm_comando_limpar, ws_step.comando_limpar);

        -- Busca o parametro de minutos de espera na tarefa, se não existe cria  
        if ws_run_id is null then 
            ws_minuto_espera := 30;
        else     
            ws_minuto_espera := null; 
            begin 
                select to_number(nvl(conteudo,'0')) into ws_minuto_espera from etl_run_param 
                where run_id       = ws_run_id 
                and cd_parametro = 'MINUTO_ESPERA' ; 
            exception when no_data_found then
                ws_minuto_espera := 30;
                insert into etl_run_param (run_id, cd_parametro, conteudo, st_ativo) values (ws_run_id, 'MINUTO_ESPERA', ws_minuto_espera,'S'); 
                commit; 
            end;     
        end if;
        if ws_minuto_espera is null then       
            ws_erro := 'Parametro [MINUTO_ESPERA] nao informado, ou com conteudo invalido';
            raise ws_raise_retorno;     
        end if; 

        -- Substritui os parametros dos comandos de extrasão e limpeza (se existir parametros)
        if ws_run_step_id is not null then 
            etf.exec_param_substitui (ws_run_id, ws_run_step_id, ws_step_id, ws_comando_limpar, ws_parametros, ws_erro); 
            if ws_erro is not null then 
                raise ws_raise_retorno; 
            end if;

            etf.exec_param_substitui (ws_run_id, ws_run_step_id, ws_step_id, ws_comando, ws_parametros, ws_erro); 
            if ws_erro is not null then 
                raise ws_raise_retorno; 
            end if;     
        end if;     

        if nvl(trim(ws_comando),'NA') = 'NA' then 
            ws_erro := 'Comando a ser executado esta em branco, verifique o comando e os parametros da acao e da tarefa.';
            raise ws_raise_retorno; 
        end if; 
        
        if instr(ws_comando,'$[') > 0 or instr(ws_comando_limpar,'$[') > 0 then 
            ws_erro := 'Nao foi possivel substituir todos os parametros dos comandos, verifique os parametros da acao e da tarefa';
            raise ws_raise_retorno; 
        end if; 

        ws_parametros := 'Param['||ws_parametros||']';

        etf.alert_online(ws_id_alert, 'EXEC_INTEGRADOR', ws_dh_inicio, null, ws_run_step_id||'-'||ws_step_id||'('||ws_step.ds_step||')'||'-'||ws_step.tipo_comando||'-'||ws_parametros, 'ATUALIZANDO','', 'REGISTRO', 'N', ws_tabelas);
    end if; 

    -- Inserir ação na fila
    -------------------------------------------------------------------------------
    -- select etf.gen_id into ws_unid_id from dual;
    ws_unid_id := to_char(sysdate,'yymmddhh24miss')||rpad(etf.randomCode(),10,'x');
    insert into etl_fila (id_uniq,    run_id,    tbl_destino,    comando,    comando_limpar,   dt_criacao, dt_inicio, dt_final, status,  erros,  id_conexao,    run_step_id,    step_id,    qt_tentativas,    log_id)
                  values (ws_unid_id, ws_run_id, ws_tbl_destino, ws_comando, ws_comando_limpar, sysdate,   null,      null,     'A',     null,   ws_id_conexao, ws_run_step_id, ws_step_id, ws_qt_tentativas, prm_log_id);
    commit;
    if etf.ret_var('SERVIDOR_ETL') is not null then 
        ws_ret_processa := etf.etl_fila_processa(etf.ret_var('SERVIDOR_ETL'), 'ADD_FILA|'||etf.ret_var('CLIENTE')||'|'||ws_unid_id);
        if ws_ret_processa not like 'OK|%' then 
            update etl_fila set status = 'E', erros = ws_ret_processa
             where id_uniq = ws_unid_id ;
             commit; 
        end if; 
    end if; 

    ------------------------------------------------------------------------------------
    -- AGUARDAR OPERAÇÃO DE POPULAR TABELA SER CONCLUÍDA 
    ------------------------------------------------------------------------------------
    -- Loop para aguardar finalizar carga dos dados.
    -- Se ficar mais que o tempo enviado por parametro nesse laço ele pula fora e indica o erro de "timeout"
    -- Se finalizar com erro ele tambem pula fora e registra o erro gravado na etl_fila
    -- Se finalizar ele pula fora com sucesso

    ws_dh_ini_aguardar := sysdate;

    while (sysdate - ws_dh_ini_aguardar) <= ws_minuto_espera/1440 and ws_status_integracao in ('A','R') 
    loop
        select status, erros 
          into ws_status_integracao, ws_erro_integracao
          from etl_fila
         where id_uniq            = ws_unid_id
           and nvl(run_step_id,0) = nvl(ws_run_step_id,0) ;
        dbms_lock.sleep(10);           
    end loop;

    if ws_status_integracao in ('A','R') then  --Se saiu do loop e o status ainda é A ou R, é pq estorou o timeout
        prm_status      := 'ERRO';
        ws_erro         := 'ACAO:'||nvl(ws_step.ds_step,ws_step_id)||', Erro: '||'Aguardando integracao a mais de '||ws_minuto_espera||' minutos.';
        ws_status_alert := 'ERRO';
        ws_st_notify    := 'ENVIO'; 
        if ws_erro is not null then 
            insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values (sysdate , 'exec_step_integrador('||nvl(ws_step.ds_step,ws_step_id)||') erro: '||substr(ws_erro,1,200) , 'DWU', 'ERRO');
            commit; 
        end if; 
        update etl_fila set status = 'E', erros = ws_erro 
         where id_uniq            = ws_unid_id
           and nvl(run_step_id,0) = nvl(ws_run_step_id,0) ;
        commit;            
    elsif ws_status_integracao in ('E','W') THEN
        if ws_status_integracao = 'W' THEN
            prm_status      := 'ALERTA';
        else    
            prm_status      := 'ERRO';
        end if;
        ws_status_alert := 'ERRO';
        ws_st_notify    := 'ENVIO'; 
        ws_erro         := nvl(ws_erro_integracao,'Erro/Alerta na execucao da fila pelo Integrador');
    else 
        prm_status      := 'CONCLUIDO';
        ws_status_alert := 'FINALIZADO';
        ws_st_notify    := 'REGISTRO'; 
        ws_erro         := ws_erro_integracao;
    END IF;

    prm_retorno := ws_erro;  -- Esse retorno por não necessáriamento ser um erro, pode ser um log retornado pelo integrador 

    if nvl(ws_run_step_id,'N/A') <> 'TESTE_CONEXAO' then 
        etf.alert_online(ws_id_alert, 'EXEC_STEP_INTEGRADOR', ws_dh_inicio, sysdate, null, ws_status_alert, substr(ws_erro,1,200), ws_st_notify, 'N', ws_tabelas); 
    end if;     

exception
    when ws_raise_retorno then 
        prm_retorno := ws_erro; 
        prm_status  := 'ERRO';
    when others then
        ws_erro := substr(dbms_utility.format_error_stack||'-'||dbms_utility.format_error_backtrace,1,3900); 
        if nvl(ws_run_step_id,'N/A') <> 'TESTE_CONEXAO' then 
            etf.alert_online(ws_id_alert, 'EXEC_STEP_INTEGRADOR', ws_dh_inicio, sysdate, null, 'ERRO', ws_erro, 'ENVIO', 'N', ws_tabelas);     
        end if;
        insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values (sysdate , 'exec_step_integrador('||ws_step_id||') erro: '||ws_erro , 'DWU', 'ERRO');
        commit; 
        --
        prm_retorno := ws_erro; 
        prm_status  := 'ERRO';
end exec_step_integrador;


-------------------------------------------------------------------------------------------------------
procedure exec_schdl as 

    cursor c_tarefas is
    	select etl_schedule.run_id, etl_schedule.p_semana, etl_schedule.p_mes, etl_schedule.p_hora, etl_schedule.p_quarter, etl_schedule.p_dia_mes
      	  from etl_run, etl_schedule
         where etl_run.run_id             = etl_schedule.run_id 
	       and nvl(etl_run.st_ativo,'N')  = 'S' ;  -- somente tarefas ativa

    ws_reg_online       varchar2(100);
    ws_noact            exception;
    ws_check            number     := 0;
    ws_check_semana     number     := 0;
	ws_check_dia_mes    number     := 0;
	ws_check_mes        number     := 0;	
	ws_check_hora       number     := 0;
	ws_check_quarter    number     := 0;

    ws_date             date;
    ws_semana           integer;
    ws_dia_mes          integer;
    ws_mes              integer;
    ws_hora             integer;
    ws_quarter          integer;

 BEGIN

    ws_date    := sysdate;
    ws_semana  := to_number(to_char(ws_date,'D'));
    ws_dia_mes  := to_number(to_char(ws_date,'DD'));
    ws_mes     := to_number(to_char(ws_date,'MM'));
    ws_hora    := to_number(to_char(ws_date,'HH24'));
    ws_quarter := to_number(to_char(ws_date,'MI'));
	
	delete from etl_status where dt_inicial < add_months(sysdate, -1);
	commit;

    if upper(etf.ret_var('ETL_ATIVO')) <> 'SIM' then
        raise ws_noact;
    end if;

    for a in c_tarefas loop
        -- precisa zerar pois pode retornar mais de uma linha...
        ws_check_semana  := 0;
        ws_check_dia_mes := 0;
        ws_check_mes     := 0;	
        ws_check_hora    := 0;
        ws_check_quarter := 0;
		if (nvl(a.p_semana,  'N/A') <> 'N/A' or nvl(a.p_dia_mes, 'N/A') <> 'N/A' ) and 
		   nvl(a.p_mes,     'N/A') <> 'N/A' and 
		   nvl(a.p_hora,    'N/A') <> 'N/A' and 
		   nvl(a.p_quarter, 'N/A') <> 'N/A' then
		
            if a.p_dia_mes is not null then
                select count(column_value) into ws_check_dia_mes from table(fun.vpipe(a.p_dia_mes)) where column_value = ws_dia_mes;
            end if;
            if a.p_semana is not null then
				select count(column_value) into ws_check_semana  from table(fun.vpipe(a.p_semana))  where column_value = ws_semana;
			end if;
            select count(column_value) into ws_check_mes from table(etf.vpipe(a.p_mes))     where column_value = ws_mes;
            select count(column_value) into ws_check_hora from table(etf.vpipe(a.p_hora))     where column_value = ws_hora;
            select count(column_value) into ws_check_quarter from table(etf.vpipe(a.p_quarter))     where column_value = ws_quarter;
			if (ws_check_dia_mes + ws_check_semana + ws_check_mes + ws_check_hora + ws_check_quarter) >= 4 then
				exec_run(a.run_id);
			end if;
		end if; 
    end loop;

    -- Cria Job para cancelar ações executando a um determinando tempo (não cria o job, se já estiver executando)
    etf.execute_now('etf.canc_step_tempo_limite', 'N');   

 exception
    when ws_noact then
        insert into log_eventos values(sysdate , '[ETL]-TAREFA DESATIVADA' , 'DWU' , 'ETL' , 'OK', '0');
        commit;
    when others then
        insert into log_eventos values(sysdate , '[ETL]-ERRO:'||dbms_utility.format_error_stack||dbms_utility.format_error_backtrace, user , 'ETL' , 'ERRO', '0');
        commit;
end exec_schdl;


procedure exec_run (prm_run_id      varchar2,
                    prm_run_step_id varchar2 default null) as

    cursor c_rs is
		select rs.run_step_id, rs.run_id, rs.step_id, rs.ordem, rs.dependence_id, es.comando, er.ds_run, es.step_id es_step_id 
		  from etl_step es, etl_run er, etl_run_step rs
	     where es.step_id(+)  = rs.step_id
           and er.run_id      = rs.run_id  
		   and rs.run_id      = prm_run_id
           and rs.run_step_id = nvl(prm_run_step_id, rs.run_step_id)
		order by ordem ;
	
	ws_rs c_rs%rowtype;
	
	ws_comando           varchar2(12000);
	ws_count_run         number;
    ws_count_step        number;
	ws_job_id            varchar2(20); 
	ws_raise_executando  exception; 
	ws_log_id            varchar2(100); 
	ws_status            varchar2(20); 
    ws_unico             varchar2(1); 

begin

    ws_log_id := to_char(sysdate,'yymmddhh24miss')||'-'||replace(prm_run_id,'RUN_',''); -- Esse ID de log é utilizado para identificar o job e outros processos, não deve ser alterado 

	select count(*) into ws_count_run
	  from etl_run      
	 where run_id = prm_run_id
	   and last_status in ('AGUARDANDO','EXECUTANDO') ;  
    
    if ws_count_run > 0 then -- Se estiver rodando verifica se realmente tem ação executando 
        etf.etl_atu_status ('RUN', prm_run_id, ws_status);  -- Verifica, atualiza e retorna o status da tarefa 
        if ws_status not in ('AGUARDANDO','EXECUTANDO') then 
           ws_count_run := 0;        
        end if; 
    end if; 

	if ws_count_run > 0 then 
		raise ws_raise_executando; 
	end if; 

	-- Atualiza Situação da tarefa e gera log 
	ws_status := 'AGUARDANDO'; 
	etf.etl_atu_status('RUN', prm_run_id, ws_status);
	etf.etl_log_gera  ('RUN', ws_log_id, prm_run_id, 0, 0, 0, ws_status, sysdate);
    commit; 
    -- Mata job com base na ação (what) do job, caso tenha ficado de processos anteriores 
    for a in (select job from all_jobs where lower(what) like 'etf.exec_run_step(%-'||replace(prm_run_id,'RUN_','')||'''%' order by job) loop 
        begin 
            etf.job_remove(a.job); 
        exception when others then 
            null;
        end;
        commit; 
    end loop; 
	-- Mata Jobs que podem ter ficado presos na execução anterior 
	-- for a in ( select job_id from etl_run_step where run_id = prm_run_id and job_id is not null) loop 
	-- 	begin 
	-- 		etf.job_remove(a.job_id); 
	-- 	exception when others then 
	-- 		null;
	-- 	end; 	
	-- 	commit;  
	-- end loop; 
    
    -- Atualiza os parametros da tarefa, caso tenha sido adicionado algum novo parametro nas ações - já tem commit na procedure 
    etf.etl_run_param_atu(prm_run_id) ; 
    --
	update etl_run_step
	   set last_status = 'AGUARDANDO', job_id = null, dh_inicio = null, dh_fim = null
	 where run_id      = prm_run_id
       and run_step_id = nvl(prm_run_step_id, run_step_id); 

    ws_unico := 'N';
    if prm_run_step_id is not null then 
        ws_unico := 'S';
    end if;     
	-- Cria um JOB para cada passo (execução a cada 10 segundos)
	for a in c_rs loop 
        if a.es_step_id is null then 
		    etf.etl_log_gera ('RUN_STEP', ws_log_id, a.run_id, a.run_step_id, a.step_id, a.ordem, 'ERRO', sysdate, 'A&ccedil;&atilde;o n&atilde;o cadastrada, recadastre ou retire da tarefa');
            update etl_run_step 
               set last_status = 'ERRO'
             where run_step_id = a.run_step_id;              
        else     
            etf.etl_log_gera ('RUN_STEP', ws_log_id, a.run_id, a.run_step_id, a.step_id, a.ordem, 'AGUARDANDO', sysdate);
            ws_comando := 'etf.exec_run_step('''||a.run_step_id||''','''||ws_log_id||''', '''||ws_unico||''');';
            DBMS_JOB.SUBMIT(job => ws_job_id, what => ws_comando, next_date => sysdate+(1/24/60/30), interval => 'sysdate+(1/24/60/15)');  -- intervalo de 5 segundos, comecando 2 em segundos  
            update etl_run_step 
            set job_id = ws_job_id 
            where run_step_id = a.run_step_id;  
            commit; 
        end if; 
	end loop; 	

exception 
	when ws_raise_executando then 
		ws_status := 'CANCELADO';
 		etf.etl_log_gera  ('RUN', ws_log_id, prm_run_id, 0, 0, 0, ws_status, sysdate, 'Tarefa anterior ainda executando.');   -- Gera somente log da tarefa (não atualiza status) 		
		commit; 
	when others then 	
		rollback; 
		ws_status := 'ERRO';
		etf.etl_atu_status('RUN', prm_run_id, ws_status);
 		etf.etl_log_gera  ('RUN', ws_log_id, prm_run_id, 0, 0, 0, ws_status, sysdate, 'Erro nao tratado, verifique o log de erros do sistema.');
		insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values (sysdate , 'exec_run('||ws_rs.ds_run||') erro: '||dbms_utility.format_error_stack||dbms_utility.format_error_backtrace , 'DWU', 'ERRO');
        commit;
end exec_run; 


procedure exec_run_step (prm_run_step_id varchar2,
						 prm_log_id      varchar2,
                         prm_unico       varchar2 default 'N') as

    cursor c_rs is
		select rs.run_step_id, rs.run_id, rs.step_id, rs.ordem, nvl(rs.dependence_id,'ANTERIOR') dependence_id, rs.job_id, rs.last_status, 
               es.tipo_execucao, es.comando, nvl(es.ds_step,es.step_id) ds_step, es.step_id es_step_id 
		  from etl_step es, etl_run_step rs
	     where es.step_id     = rs.step_id 
		   and rs.run_step_id = prm_run_step_id ; 
	
	cursor c_rs_ante (prm_run_id varchar2, prm_ordem number) is 
		select run_step_id 
		  from etl_run_step  
		 where run_id = prm_run_id 
		   and ordem  < prm_ordem 
	     order by ordem desc;  	   

	ws_rs c_rs%rowtype;

	ws_count   			 number;
	ws_comando 			 varchar2(12000);
	ws_run_step_id_ante  varchar2(20); 
	ws_status_ante       varchar2(20);
	ws_case_erro_ante    varchar2(20); 
	ws_executa           varchar2(1); 
	ws_status            varchar2(20); 
    ws_status_run        varchar2(20);   
	ws_sq_log 			 number; 
    ws_erro              varchar2(4000); 
    ws_erro_clob         clob; 
    ws_etapa             varchar2(20); 

	ws_raise_concluido   exception; 

begin 	

    ws_etapa := 'INICIO'; 

    open  c_rs;
    fetch c_rs into ws_rs;
	close c_rs;

	-- Se já finalizou, interrompe essa procedure, atualiza log do STEP e remove o JOB   
	---------------------------------------------------------------------------------
	if ws_rs.last_status in ('CONCLUIDO','CANCELADO','ERRO','ALERTA') then 
		raise ws_raise_concluido; 
	end if; 

	-- Monta o comando PL/SQL do STEP  
	---------------------------------------------------------------------------------
	ws_etapa := 'COMANDO'; 
    if ws_rs.tipo_execucao in ('SQL','PL/SQL') then 
        ws_comando :=            'begin etf.exec_step('''||ws_rs.run_step_id||''', prm_log_id => :1, prm_retorno => :2, prm_status => :3); end;'; 
    else
        ws_comando := 'begin etf.exec_step_integrador('''||ws_rs.run_step_id||''', prm_log_id => :1, prm_retorno => :2, prm_status => :3); end;';     
	end if; 

	-- Verifica se depende de uma Açao anterior e qual a situação dessa ação 
	---------------------------------------------------------------------------------
	ws_etapa := 'PENDENCIA'; 
    ws_executa := 'S'; 
	if ws_rs.dependence_id = 'NENHUMA' then 
		ws_executa := 'S';
	else 
        for a in (select column_value run_step_id_ante from table(etf.vpipe(ws_rs.dependence_id))) loop 
            if ws_executa = 'S' then 
                if a.run_step_id_ante = 'ANTERIOR' then 
                    open  c_rs_ante (ws_rs.run_id, ws_rs.ordem); 
                    fetch c_rs_ante into ws_run_step_id_ante; 
                    close c_rs_ante;
                else 
                    ws_run_step_id_ante := a.run_step_id_ante; 
                end if; 

                select count(*), max(last_status), max(case_erro) 
                    into ws_count, ws_status_ante, ws_case_erro_ante   
                    from etl_run_step 
                    where run_step_id = ws_run_step_id_ante; 

                if ws_count = 0 or prm_unico = 'S' then 
                    ws_executa := 'S';
                else 
                    if ws_status_ante in ('CONCLUIDO', 'ERRO','CANCELADO','ALERTA')  then 	
                        ws_executa := 'S';
                        if ws_status_ante in ('ERRO','CANCELADO') and ws_case_erro_ante = 'PARAR' then 
                            ws_executa := 'P';
                        end if; 
                    else 
                        ws_executa := 'N';
                    end if;    
                end if; 	
            end if; 
        end loop; 
	end if; 

	-- Verifica se a mesma Ação está sendo executada (talvez por outra tarefa) 
	-----------------------------------------------------------------------------------
    ws_etapa := 'PENDENCIA (SELF)'; 
	select count(*) into ws_count
  	  from etl_run_step 
	 where step_id     = ws_rs.step_id
	   and dh_inicio  >= trunc(sysdate-1)
	   and last_status = 'EXECUTANDO' ; 
	if ws_count > 0 then 
		ws_executa := 'A';
	end if; 

	-- Executa o ação (STEP) 
	---------------------------------------------------------------------------------
    ws_etapa := 'EXECUTA'; 
    ws_erro  := null; 
	if ws_executa = 'S' then 

        ws_status     := 'EXECUTANDO' ; 
        ws_status_run := null;

		ws_etapa := 'EXECUTA (STATUS)'; 
		etf.etl_atu_status('RUN_STEP', ws_rs.run_step_id, ws_status);       -- Atualiza Status da ação 
        etf.etl_atu_status('RUN', ws_rs.run_id, ws_status_run);             -- Atualiza Status da tarefa 
        etf.etl_log_gera ('RUN_STEP', prm_log_id, ws_rs.run_id, prm_run_step_id, ws_rs.step_id, ws_rs.ordem, ws_status, sysdate);	-- Gera/atualiza Log da ação 
		etf.etl_log_gera ('RUN', prm_log_id, ws_rs.run_id, 0, 0, 0, ws_status_run, sysdate);			                            -- Gera/atualiza Log da tarefa 
		commit;
		
        ws_etapa := 'EXECUTA (COMANDO)'; 
        execute immediate ws_comando using in prm_log_id, out ws_erro_clob, out ws_status;
        if ws_erro_clob is not null then 
            ws_erro   := substr(ws_erro_clob,1,3900); 
        end if;     
	elsif ws_executa = 'P' then 
        ws_status := 'CANCELADO'; 
        ws_erro   := 'Acao cancelada por problema na acao anterior.'; 
	else 
        ws_status := null;
	end if; 
	ws_etapa  := 'EXECUTA (FIM)'; 

    if ws_status is not null then -- Se executou algo na ação 
	    etf.etl_atu_status('RUN_STEP', ws_rs.run_step_id, ws_status);   -- Atualiza Status da ação                 
	    etf.etl_log_gera  ('RUN_STEP', prm_log_id, ws_rs.run_id, prm_run_step_id, ws_rs.step_id, ws_rs.ordem, ws_status, sysdate, ws_erro);  -- Atualiza log da ação 
	    commit;
    end if;     

    ws_etapa      := 'FIM (LOG)';
    ws_status_run := null;
	etf.etl_atu_status ('RUN', ws_rs.run_id, ws_status_run);                               -- Atualiza status TAREFA 
	etf.etl_log_gera   ('RUN', prm_log_id, ws_rs.run_id, 0, 0, 0, ws_status_run, sysdate); -- Atualiza log TAREFA  	
    commit; 
	--
exception 
	when ws_raise_concluido then 
		if ws_rs.job_id is not null then 
			begin etf.job_remove(ws_rs.job_id);  exception when others then null;	end; 	 -- Encerra a execução do job 
		end if; 	
		etf.etl_log_gera      ('RUN_STEP', prm_log_id, ws_rs.run_id, prm_run_step_id, ws_rs.step_id, ws_rs.ordem, ws_rs.last_status, sysdate); -- Atualiza log da Ação 
		commit; 		
		--
    when others then
		--
		if ws_rs.job_id is not null then 
			begin etf.job_remove(ws_rs.job_id);  exception when others then null;	end; 	 -- Encerra a execução do job 
		end if; 	
        --        
        ws_erro := substr(dbms_utility.format_error_stack,1,3900); 
        --if ws_rs.tipo_execucao = 'INTEGRADOR' then    
        --    ws_erro := dbms_utility.format_error_stack; 
        --end if;     
        if ws_erro is null then 
            ws_erro := 'Erro executando comando ['||ws_comando||'] etapa ['||ws_etapa||'], verifique o log de erros do sistema.';             
        end if; 
        --
        ws_status     := 'ERRO' ; 
        ws_status_run := null;
		etf.etl_atu_status('RUN_STEP', prm_run_step_id, ws_status);      -- Atualiza situação da Ação 
		etf.etl_atu_status('RUN', ws_rs.run_id, ws_status_run);          -- Atualiza situação da tarefa 		

        etf.etl_log_gera ('RUN_STEP', prm_log_id, ws_rs.run_id, prm_run_step_id, ws_rs.step_id, ws_rs.ordem, ws_status,     sysdate, ws_erro);   -- Atualiza log da Ação 
		etf.etl_log_gera ('RUN',      prm_log_id, ws_rs.run_id, 0,               0,             0,           ws_status_run, sysdate); -- Atualiza log TAREFA 
        commit; 
        --
		insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values (sysdate , 'exec_run_step [acao:'||ws_rs.ds_step||', etapa:'||ws_etapa||'] erro: '||dbms_utility.format_error_stack||dbms_utility.format_error_backtrace , 'DWU', 'ERRO');
		commit; 
        -- 
end exec_run_step;


----------------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure exec_step (prm_run_step_id   in  varchar2,
                     prm_log_id        in  varchar2,
                     prm_retorno       out clob,
                     prm_status        out varchar2) as 

    cursor c_rs is 
        select rs.run_step_id, rs.run_id, es.step_id, es.ds_step, es.comando, es.comando_limpar, es.tbl_destino, es.id_conexao
          from etl_step es, etl_run_step rs
         where es.step_id     = rs.step_id 
           and rs.run_step_id = prm_run_step_id ;
    ws_rs              c_rs%rowtype; 
    ws_erro            varchar2(4000);
    ws_parametros      varchar2(4000); 
    ws_comando         varchar2(32000); 
    ws_raise_retorno   exception; 
begin
    ws_erro       := null;
    prm_retorno   := null;  
    prm_status    := null;

    -- Busca dados da ação
    open  c_rs;
    fetch c_rs into ws_rs;
    close c_rs; 
    
    -- Substitui o conteúdo dos parametros 
    etf.exec_param_substitui (ws_rs.run_id, ws_rs.run_step_id, ws_rs.step_id, ws_rs.comando, ws_parametros, ws_erro); 
    if ws_erro is not null then 
        raise ws_raise_retorno; 
    end if;     

    -- Monta comando 
	ws_comando := trim(ws_rs.comando); 
	if substr(ws_comando,length(ws_comando),1) <> ';' then 
		ws_comando := ws_comando||';'; 
	end if; 	
	ws_comando := 'begin '||ws_comando||' end;'; 
    ws_parametros := 'Param['||ws_parametros||']';

    -- Executa comando 
    execute immediate ws_comando;
    commit;
    prm_status := 'CONCLUIDO';
exception 
    when ws_raise_retorno then 
        prm_retorno := ws_erro;
        prm_status  := 'ERRO';
    when others then
        ws_erro := substr(dbms_utility.format_error_stack||'-'||dbms_utility.format_error_backtrace,1,3900); 
        insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values (sysdate , 'exec_step('||nvl(ws_rs.ds_step,ws_rs.step_id)||') erro: '||ws_erro , 'DWU', 'ERRO');
        commit; 
        prm_retorno := ws_erro; 
        prm_status  := 'ERRO';
end exec_step;



----------------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure exec_param_substitui (prm_run_id          in varchar2, 
                                prm_run_step_id     in varchar2,
                                prm_step_id         in varchar2,
                                prm_comando     in out varchar2,
                                prm_parametros  in out varchar2,
                                prm_erro        in out varchar2 ) as 
    ws_parametros    varchar2(4000); 
    ws_comando       varchar2(32000); 
    ws_conteudo      varchar2(32000);
    ws_erro          varchar2(300);  
    ws_id_entreaspas varchar2(10);  
    ws_raise_param   exception; 
    ws_raise_retorno exception;  

begin 
    ws_parametros := null;   
    ws_comando    := prm_comando; 
    ws_comando    := regexp_replace(ws_comando,':RUN_ID',      chr(39)||prm_run_id||chr(39)      ,1,0,'i');
    ws_comando    := regexp_replace(ws_comando,':RUN_STEP_ID', chr(39)||prm_run_step_id||chr(39) ,1,0,'i');
    ws_comando    := regexp_replace(ws_comando,':STEP_ID',     chr(39)||prm_step_id||chr(39)     ,1,0,'i');

    for a in (select '$['||cd_parametro||']' as parametro, conteudo, cd_parametro, id_entreaspas 
                from etl_run_param 
               where run_id = prm_run_id 
                 and instr(upper(ws_comando), '$['||cd_parametro||']') > 0
             ) loop

        -- ws_id_entreaspas := null;
        -- select max(id_entreaspas) into ws_id_entreaspas 
        --   from etl_step_param 
        --  where step_id      = prm_step_id 
        --    and cd_parametro = a.cd_parametro;
        -- --            
        -- if ws_id_entreaspas is null then 
        --     select max(id_entreaspas) into ws_id_entreaspas 
        --       from etl_step_param b, etl_run_step a
        --      where b.step_id      = a.step_id 
        --        and a.run_id       = prm_run_id
        --        and b.cd_parametro = a.cd_parametro;
        -- end if; 
        -- ws_id_entreaspas := nvl(ws_id_entreaspas,'S');

        ws_id_entreaspas := nvl(a.id_entreaspas,'N');
        ws_conteudo      := a.conteudo;
        if ws_conteudo is null then
            ws_erro := a.parametro; 
            raise ws_raise_param;     
        end if;
        
        if instr(upper(ws_conteudo),'EXEC=') > 0 then 
            ws_conteudo := replace(ws_conteudo,'exec=','EXEC='); 
            ws_conteudo := etf.xexec (ws_conteudo); 
        end if;     
        if ws_id_entreaspas = 'S' then 
            ws_conteudo := chr(39)||ws_conteudo||chr(39);
        end if;    
        ws_comando := replace(ws_comando,  a.parametro, ws_conteudo );
        if ws_parametros is not null then 
            ws_parametros := ws_parametros||', ';
        end if;     
        ws_parametros := ws_parametros||a.parametro||'='||ws_conteudo;
    end loop; 

    prm_comando := ws_comando; 

    if instr(ws_comando,'$[') > 0 then 
        ws_erro := substr(ws_comando, instr(ws_comando,'$[',1,1),  instr(ws_comando,']',1,1)-instr(ws_comando,'$[',1,1)+1 ); 
        ws_erro := 'Nao foi possivel substituir o parametro '||ws_erro||' do comando da acao.'; 
        raise ws_raise_retorno; 
    end if; 

exception 
    when ws_raise_param then 
        ws_erro := 'Parametro ['||ws_erro||'] nao informado, ou com conteudo invalido';
    when ws_raise_retorno then 
        prm_erro := ws_erro; 
    when others then 
        prm_erro := 'Erro substituindo parametros, verifique o log de erros do sistema.';        
        ws_erro := substr(dbms_utility.format_error_stack||'-'||dbms_utility.format_error_backtrace,1,3900); 
        insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values (sysdate , 'exec_param_substitui(run_id:'||prm_run_id||') erro: '||ws_erro , 'DWU', 'ERRO');
        commit; 
end exec_param_substitui;                                




procedure stop_run (prm_run_id          varchar2,
                    prm_retorno  in out varchar2) as
    ws_count    number; 
    ws_usuario  varchar2(100); 

begin
	ws_usuario := gbl.getUsuario; 
	ws_count := 0;   

	update etl_log set status = 'CANCELADO', dh_fim = sysdate, ds_log = 'Execucao cancelada pelo Usuario ['||ws_usuario||']'
	 where run_id = prm_run_id
	   and status in ('AGUARDANDO','EXECUTANDO') ;  
	if sql%found then 
		ws_count := ws_count + 1 ;
	end if; 	

    -- Mata jobs com base no último job de cada ação da tarefa 
	for a in (select job_id, run_id from etl_run_step 
	           where run_id = prm_run_id
	             and last_status in ('AGUARDANDO','EXECUTANDO') ) loop    
        ws_count := ws_count + 1; 
    	update etl_run_step set last_status = 'CANCELADO'
	     where run_id = a.run_id
	           and last_status in ('AGUARDANDO','EXECUTANDO') ;
        begin 
            etf.job_remove(a.job_id); 
        exception when others then 
            null;
        end;
        commit;
    end loop; 

    -- Mata job com base na ação (what) do job, caso tenha ficado de processos anteriores 
    for a in (select job from all_jobs where lower(what) like 'etf.exec_run_step(%-'||replace(prm_run_id,'RUN_','')||'''%' order by job) loop 
        ws_count := ws_count + 1; 
        begin 
            etf.job_remove(a.job); 
        exception when others then 
            null;
        end;
        commit;
    end loop; 

    if ws_count = 0 then
    	select count(*) into ws_count 
          from etl_run
	     where run_id = prm_run_id
	       and last_status in ('AGUARDANDO','EXECUTANDO');
    end if;        

    -- Se cancelou ações ou a tarefa ainda está como executando ou aguardando , cancela a tarefa 
    if ws_count > 0 then
	    update etl_run set last_status = 'CANCELADO', dh_envio = null     
	    where run_id = prm_run_id; 
    end if; 

    if ws_count = 0 then 
        prm_retorno := 'Tarefa n&atilde;o est&aacute; em execu&ccedil;&atilde;o';
    end if; 
exception when others then 
	prm_retorno := 'Erro cancelando execu&ccedil;&atilde;o da Tarefa, verifique o log de erros do sistema';
	insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values (sysdate , 'stop_run('||prm_run_id||') erro: '||substr(dbms_utility.format_error_stack||'-'||dbms_utility.format_error_backtrace,1,3900) , gbl.getUsuario, 'ERRO');
    commit; 
end stop_run;                     



------------------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_atu_status ( prm_tipo      varchar2, 
                           prm_id        varchar2,
                           prm_status in out varchar2 ) as 
	ws_qt_ag  integer;
	ws_qt_ex  integer;
	ws_qt_er  integer;
    ws_qt_al  integer;
    ws_qt_ca  integer; 
    ws_dh_i   date := null;
    ws_dh_f   date := null; 

begin 
    if prm_tipo = 'RUN_STEP' then 
        if prm_status in ('EXECUTANDO') then 
            ws_dh_i :=  sysdate; 
        elsif prm_status in ('CONCLUIDO', 'ERRO','CANCELADO','ALERTA') then 
            ws_dh_f :=  sysdate; 
        end if; 

        update etl_run_step 
		   set last_status = prm_status, 
		       dh_inicio   = nvl(nvl(ws_dh_i, dh_inicio),ws_dh_f),
               dh_fim      = nvl(ws_dh_f, dh_fim)
		 where run_step_id = prm_id;

    elsif prm_tipo = 'RUN' then 
        if prm_status is null then 
            select sum(decode(last_status,'ERRO',1,0)), 
                   sum(decode(last_status,'CANCELADO',1,0)), 
                   sum(decode(last_status,'AGUARDANDO',1,0)), 
                   sum(decode(last_status,'EXECUTANDO',1,0)),
                   sum(decode(last_status,'ALERTA',1,0))
              into ws_qt_er, ws_qt_ca, ws_qt_ag, ws_qt_ex, ws_qt_al 
              from etl_run_step
             where run_id = prm_id ; 

            if    ws_qt_ex > 0 then   prm_status := 'EXECUTANDO';
            elsif ws_qt_ag > 0 then   prm_status := 'AGUARDANDO'; 
            elsif ws_qt_er > 0 then   prm_status := 'ERRO'; 
            elsif ws_qt_ca > 0 then   prm_status := 'CANCELADO'; 
            elsif ws_qt_al > 0 then   prm_status := 'ALERTA'; 
            else                      prm_status := 'CONCLUIDO';  
            end if; 
        end if;

        update etl_run 
           set last_run    = sysdate, 
               last_status = prm_status,
               dh_envio    = null 
         where run_id = prm_id;
    end if; 
    --    
    commit;  
	--
end etl_atu_status; 	


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure etl_log_gera ( prm_tipo         varchar2, 
                         prm_log_id       varchar2,
	                     prm_run_id       varchar2,
						 prm_run_step_id  varchar2 default 0, 
						 prm_step_id      varchar2 default null,  
						 prm_ordem        number, 						 
						 prm_status       varchar2, 
						 prm_data         date,  
						 prm_ds           varchar2 default null ) as 
	ws_sq_log    number; 
    ws_dh_inicio date;
	ws_dh_fim    date;
begin
    -- Define o tipo de log e pega a seguencia de execução da ação 
    ---------------------------------------------------------------------------------
	if prm_tipo = 'RUN' then
        ws_sq_log := 0; 
	else 
	    ws_sq_log := null ;
		if prm_status = 'AGUARDANDO' then 
			ws_sq_log := 99999; 
        elsif prm_status in ('EXECUTANDO', 'CANCELADO') then
    		select nvl(max(sq_log),0)+1 into ws_sq_log
		      from etl_log 
		     where log_id   = prm_log_id 
		       and run_id   = prm_run_id 
		       and tp_log  <> 'RUN'
               and sq_log  <> 99999; 
		end if; 	
	end if; 

	ws_dh_inicio := null;
    if prm_tipo = 'RUN_STEP' and prm_status = 'EXECUTANDO' and prm_data is not null then
        ws_dh_inicio := prm_data;
    end if; 

	ws_dh_fim := null;
	if prm_status in ('CONCLUIDO','ERRO','CANCELADO','ALERTA') then 
		ws_dh_fim := prm_data;
	end if; 	

	update etl_log
	   set status    = prm_status,
           dh_inicio = nvl(ws_dh_inicio, dh_inicio),
		   dh_fim    = nvl(ws_dh_fim, dh_fim),
		   ds_log    = nvl(substr(prm_ds,1,490), ds_log),
		   sq_log    = nvl(ws_sq_log, sq_log)  
	 where log_id        = prm_log_id 
	   and run_id        = prm_run_id
	   and run_step_id   = prm_run_step_id 
       and tp_log        = prm_tipo ; 

	if sql%notfound then 
		insert into etl_log (log_id,     sq_log,           tp_log,   ds_log,               run_id,     run_step_id,     step_id,     ordem,     dh_inicio, dh_fim,    status ) 
		             values (prm_log_id, nvl(ws_sq_log,0), prm_tipo, substr(prm_ds,1,490), prm_run_id, prm_run_step_id, prm_step_id, prm_ordem, prm_data,  ws_dh_fim, prm_status); 
	end if; 						
	--
    commit; 
    --
exception when others then 
	insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values (sysdate , 'etl_log_gera [acao:'||prm_step_id||' erro: '||dbms_utility.format_error_stack||dbms_utility.format_error_backtrace , 'DWU', 'ERRO');
	commit; 
end etl_log_gera; 						 


procedure etl_run_param_atu(prm_run_id varchar2) as 
    ws_comando   clob;
    ws_param     varchar2(500); 
    ws_params    clob; 
    ws_terminou  varchar2(1); 
    ws_pos_i     integer;
    ws_pos_f     integer; 
    ws_count integer; 
begin 

    for a in 1..2 loop
        select count(*) into ws_count from etl_run_param 
         where run_id       = prm_run_id 
           and cd_parametro = decode(a,1,'MINUTO_ESPERA','MINUTO_ESPERA_PLSQL');
        if ws_count = 0 then 
            insert into etl_run_param (run_id, cd_parametro, conteudo, st_ativo) 
                               values (prm_run_id, decode(a,1,'MINUTO_ESPERA','MINUTO_ESPERA_PLSQL'), decode(a,1,60,180),'S'); 
        end if; 
    end loop;

	update etl_run_param 
	   set st_ativo = 'N' 
	 where run_id = prm_run_id
       and cd_parametro NOT IN ('MINUTO_ESPERA','MINUTO_ESPERA_PLSQL');

    for a in (select st.comando, st.comando_limpar
   				 from etl_step st, etl_run_step rs
  				where st.step_id = rs.step_id 
    			  and rs.run_id  = prm_run_id) loop
        ws_comando := a.comando||' '||a.comando_limpar; 
        --
        ws_count := 0 ;
        ws_terminou := 'N';
        while ws_terminou = 'N' loop 
            ws_count := ws_count + 1; 
            ws_pos_i := instr(ws_comando,'$[',1,1); 
            ws_pos_f := instr(ws_comando,']',ws_pos_i,1);
            if ws_pos_i > 0 then 
                ws_param   := trim(substr(ws_comando, ws_pos_i, ws_pos_f - ws_pos_i + 1 ));
                ws_param   := replace(replace(ws_param,'$['),']'); 
                if length(ws_param) > 0 then 
                    update etl_run_param 
                        set st_ativo     = 'S'
                        where run_id       = prm_run_id
                        and cd_parametro = ws_param;
                    if sql%notfound then 
                        insert into etl_run_param (run_id,     cd_parametro, st_ativo, id_entreaspas) 
                                           values (prm_run_id, ws_param,     'S',      'N'); 
                    end if; 
                end if; 
                ws_comando := substr(ws_comando, ws_pos_f + 1, 99999);
            else     
                ws_terminou := 'S'; 
            end if;     
        end loop; 
    end loop;
    commit; 
    --
end etl_run_param_atu; 

-----------------------------------------------------------------------------------------------------
-- Envio das últimas tarefas executadas 
-----------------------------------------------------------------------------------------------------
procedure etl_envio_status as 
    ws_run_id        etl_run.run_id%type;      
    ws_ds_run        etl_run.ds_run%type;
    ws_last_status   etl_run.last_status%type; 
    ws_last_run      etl_run.last_run%type;
    ws_string        varchar2(1000);
    ws_command       varchar2(2000);
    ws_param         varchar2(2000);
begin 
    for a in ( select run_id, ds_run, last_status, last_run, st_ativo from etl_run where dh_envio is null ) loop    
        ws_param := 'DH_ENVIO|'||to_char(sysdate,'ddmmyyyyhh24miss')||
                   '|RUN_ID|'  ||a.run_id||
                   '|DS_RUN|'  ||a.ds_run||
                   '|LAST_STATUS|'||a.last_status||
                   '|LAST_RUN|'||to_char(a.last_run,'ddmmyyyyhh24miss')||
                   '|ST_ATIVO|'||a.st_ativo;
        SELECT rawtohex(ws_param) INTO ws_param from dual;  -- Converte para hexadecimal para evitar problema na URL 
        ws_command := 'http://'||etf.ret_var('URL_UPDATE')||'/dwu.renew?prm_par=TIPO|102|CLIENTE|'||etf.ret_var('CLIENTE')||'|PARAM_HEXADECIMAL|'||ws_param;

        begin
            ws_string  := utl_http.request(ws_command);
            if ws_string <> 'OK REGISTRADO' then 
                insert into bi_log_sistema (dt_log, ds_log,nm_usuario, nm_procedure) values(sysdate, 'etl_envio_status:'||ws_string, 'DWU', 'ERRO');
                commit; 
            end if; 
        exception
            when others then
                insert into PENDING_REGS values (sysdate,ws_command,'P');
            commit;
        end;
        update etl_run set dh_envio = sysdate 
         where run_id = a.run_id; 
        --
        commit; 
        -- 
    end loop; 
    --
end; 

-----------------------------------------------------------------------------------------------------
-- Ativa/Inativa usuário do BI - Utilizada especificamente para processos externos ao bi como processos de carga/integração
-----------------------------------------------------------------------------------------------------
procedure usuarios_set_status ( prm_usu_nome            varchar2 default null,
					            prm_id_usuario_externo  varchar2 default null,
							    prm_status              varchar2 default null, 
							    prm_erro_retorno    out varchar2 ) as
	ws_raise_erro exception;							  
begin
    prm_erro_retorno := null;

	if prm_usu_nome is null and prm_id_usuario_externo is null then 
		prm_erro_retorno := 'Deve ser informado um dos dois primeiros parametros que representam a identificacao do usuario'; 
		raise ws_raise_erro;
	end if;

	if nvl(prm_status,'x') not in ('A','I') then 
		prm_erro_retorno := 'Deve ser informado A ou I no parametro de status do usuario'; 
		raise ws_raise_erro;
  	end if; 

	if prm_usu_nome is not null then 
		update usuarios set status = prm_status where usu_nome = prm_usu_nome;
	elsif prm_id_usuario_externo is not null then 
		update usuarios set status = prm_status where id_usuario_externo = prm_id_usuario_externo;
	end if; 
	if sql%notfound then 
		prm_erro_retorno := 'Usuario nao localizado'; 
		raise ws_raise_erro;
	end if;
    commit;
exception when ws_raise_erro then 
	null;	
end usuarios_set_status;							  

-----------------------------------------------------------------------------------------------------
-- Remove o Job e mata a sessão Encerra/cancela ações executando a mais de um determinado tempo 
-----------------------------------------------------------------------------------------------------
procedure job_remove (prm_job_id   varchar2) as 
    ws_sid    varchar2(20) := null;
    ws_serial varchar2(20) := null;
begin

    if prm_job_id is not null then 
        select max(sid)     into ws_sid    from dba_jobs_running where job = prm_job_id;
        select max(serial#) into ws_serial from v$session        where sid = ws_sid;
        if ws_sid is not null  and ws_serial is not null then 
            begin  execute immediate 'alter system kill session '''||ws_sid||','||ws_serial||''' IMMEDIATE ';  exception when others then  null;     end; 
        end if;    
        begin dbms_job.remove(prm_job_id);  exception when others then null;	end; 	 -- Encerra a execução do job 
    end if; 
end job_remove;    


-----------------------------------------------------------------------------------------------------
-- Encerra/cancela ações executando a mais de um determinado tempo 
-----------------------------------------------------------------------------------------------------
procedure canc_step_tempo_limite as 
    ws_minuto_espera  number := null; 
    ws_minuto_exec    number := null; 
    ws_status         varchar2(50);
    ws_status_run     varchar2(50);
    ws_log_id         varchar2(100); 
    ws_sid            varchar2(20);
    ws_serial         varchar2(20);
    ws_erro           varchar2(200);
    ws_qt_cancelado   integer; 
begin 

    ws_qt_cancelado := 0;
    for a in (select run_id, run_step_id, step_id, ordem, dh_inicio, dh_fim, job_id from etl_run_step where last_status = 'EXECUTANDO') loop 
        begin 
            select max(conteudo) into ws_minuto_espera 
              from etl_run_param 
             where run_id       = a.run_id 
               and cd_parametro = 'MINUTO_ESPERA_PLSQL' ;
        exception when others then       
            null; 
        end;

        ws_minuto_espera := nvl(ws_minuto_espera,60);
        ws_minuto_exec   := round((nvl(a.dh_fim,sysdate) - a.dh_inicio)*24*60,1);

        if ws_minuto_exec > ws_minuto_espera then 

            -- Encerra o job e sessão do job 
            etf.job_remove(a.job_id); 
            
            -- Atualiza o status da ação de da tarefa 
            ws_log_id     := null;
            ws_status     := 'CANCELADO';
            ws_status_run := null;
            ws_erro       := 'Cancelado pois atingiu o tempo limite de execucao de '||ws_minuto_espera||' minutos';
    		etf.etl_atu_status('RUN_STEP', a.run_step_id, ws_status);       -- Atualiza Status da ação para cancelado 
            etf.etl_atu_status('RUN', a.run_id, ws_status_run);             -- Atualiza Status da tarefa 

            -- Atualiza o log da ação e da tarefa 
            select max(log_id) into ws_log_id from etl_log
             where run_id  = a.run_id 
               and step_id = a.step_id
               and dh_fim is null;
            if ws_log_id is not null then 
                etf.etl_log_gera ('RUN_STEP', ws_log_id, a.run_id, a.run_step_id, a.step_id, a.ordem, ws_status, sysdate, ws_erro);	-- Gera/atualiza Log da ação 
		        etf.etl_log_gera ('RUN',      ws_log_id, a.run_id, 0, 0, 0, ws_status_run, sysdate);			            -- Gera/atualiza Log da tarefa 
            end if; 
            
            insert into etl_log_envio (run_id, step_id, dh_log, tp_log, ds_log) 
                               values (a.run_id, a.step_id, sysdate, 'ALERTA', 'Tarefa cancela por tempo de execucao ('||ws_minuto_exec||' mi)'); 

            ws_qt_cancelado := ws_qt_cancelado + 1;
            commit; 

        end if; 
    end loop ;    

    if ws_qt_cancelado > 0 then 
        etf.envia_log; 
    end if; 

end canc_step_tempo_limite; 


procedure envia_log as
    ws_cliente       varchar2(20); 
    ws_ds_run        varchar2(100); 
    ws_param         varchar2(32000);
    ws_command       varchar2(32000);
    ws_string        varchar2(100); 
    ws_id_enviado    varchar2(1);
    nao_enviar          exception; 
begin 
    ws_cliente          := upd.ret_var('CLIENTE'); 

    --if upd.tipo_ambiente(ws_cliente) in ('DESENV','HOMOLOGA') then  -- DESENV E HOMOLOGA, não envia logs 
    --    raise nao_enviar; 
    --end if; 

    -- Marca como E os logs a enviar 
    update etl_log_envio 
       set id_enviado = 'E'
     where nvl(id_enviado,'N') = 'N';
    
    for a in (select rowid, run_id, step_id, dh_log, tp_log, ds_log from etl_log_envio where id_enviado = 'E')  loop 

        select substr(max(ds_run),1,99) into ws_ds_run from etl_run where run_id = a.run_id; 
        ws_param := 'RUN_ID|'    ||a.run_id||                               --1
                    '|DS_RUN|'   ||ws_ds_run||                              --2 
                    '|STEP_ID|'  ||a.step_id||                              --3
                    '|DH_LOG|'   ||to_char(a.dh_log,'ddmmyyyyhh24miss')||   --4                        
                    '|TP_LOG|'   ||a.tp_log||                               --5
                    '|DS_LOG|'   ||replace(a.ds_log,'|','-')||              --6
                    '|DH_ENVIO|' ||to_char(sysdate,'ddmmyyyyhh24miss') ;    --7

        SELECT rawtohex(ws_param) INTO ws_param from dual;
        ws_command := 'http://'||upd.ret_var('URL_UPDATE')||'/dwu.renew?prm_par=TIPO|105|CLIENTE|'||upd.ret_var('CLIENTE')||'|PARAM_HEXADECIMAL|'||ws_param;
        
        begin
            ws_string  := substr(utl_http.request(ws_command),1,100);
        exception
            when others then
                ws_string := 'NOK';
        end;

        if ws_string like 'OK%' then 
            ws_id_enviado := 'S';
        else 
            ws_id_enviado := 'N';
            insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values (sysdate, 'Erro etf.envia_log (retorno do envia): '|| ws_string, 'DWU', 'ERRO');                    
        end if; 
  
        update etl_log_envio 
           set id_enviado = ws_id_enviado,
               dh_envio   = decode(ws_id_enviado,'S',sysdate,null)
         where rowid = a.rowid;

    end loop;     
    --
    commit; 
    --
exception
    when nao_enviar then 
        null; 
    when others then 
        rollback; 
        insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values (sysdate, 'Erro etf.envia_log(OTHERS): '|| DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 'DWU', 'ERRO'); 
        commit; 
end envia_log;


function etl_fila_processa (prm_servico     varchar2, 
                           prm_comando      varchar2) return varchar2 as 

    c  utl_tcp.connection;
    ws_ret_val    varchar2(32766);
    ws_fluxo      number;
    ws_host       varchar2(20);
    ws_port       varchar2(5);
    ws_erro       varchar(200);
    ws_raise_erro exception; 
begin
    if instr(prm_servico,':') = 0 then 
        ws_erro := 'ERRO|Serviço inválido ['||prm_servico||']';
        raise ws_raise_erro;
    end if;  
    ws_host    := substr(prm_servico,1,instr(prm_servico,':')-1) ;
    ws_port    := substr(prm_servico,instr(prm_servico,':')+1, length(prm_servico));

    c := utl_tcp.open_connection(remote_host => ws_host, remote_port => ws_port, charset => 'utf-8');  
    ws_ret_val := utl_tcp.write_line(c, prm_comando);
    utl_tcp.flush(c);
    ws_fluxo   := utl_tcp.available(c,0);
    ws_ret_val := '';
    ws_fluxo   := utl_tcp.read_text(c, ws_ret_val, 1024);
    utl_tcp.close_connection(c);
    
    return ws_ret_val;

exception 
    when ws_raise_erro then 
        return ws_erro;    
    when others then
        return substr(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,1000);    
end etl_fila_processa;


END ETF;
