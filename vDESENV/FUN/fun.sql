create or replace package body FUN  is

FUNCTION RET_LIST (	prm_condicoes varchar2 default null,
					prm_lista	out	DBMS_SQL.VARCHAR2_TABLE ) return varchar2 as

	ws_bindn		number;
	ws_texto		long;
	ws_nm_var		long;
	ws_flag			char(1);

begin

	ws_flag  := 'N';
	ws_bindn := 0;
	ws_texto := prm_condicoes;

	loop
	    if  ws_flag = 'Y' then
	        exit;
	    end if;

	    if  nvl(instr(ws_texto,'|'),0) = 0 then
		  ws_flag  := 'Y';
		  ws_nm_var := ws_texto;
	    else
		  ws_nm_var := substr(ws_texto, 1 ,instr(ws_texto,'|')-1);
		  ws_texto  := substr(ws_texto, length(ws_nm_var||'|')+1, length(ws_texto));
	    end if;

	    ws_bindn := ws_bindn + 1;
	    prm_lista(ws_bindn) := ws_nm_var;

	end loop;

        return fun.lang('Binds Carregadas');

exception
	when others then
		htp.p(sqlerrm||'=RET_LIST');

end RET_LIST;

-----
-- Atenção: essa function foi copiada para a package ETF, a alteração realizada aqui deve ser replicada para a package ETF 
---------------------------------------------------------------------------------------------------------------------------------
FUNCTION VPIPE ( prm_entrada varchar2,
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

/* Copia do VPIPE porém usando CHARRET2 que tem um tamanho maior */
FUNCTION VPIPE2 ( prm_entrada varchar2,
                  prm_divisao varchar2 default '|' ) return CHARRET2 pipelined as

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
      pipe row(sqlerrm||'=VPIPE2');

end VPIPE2;

-----
-- Atenção: essa function foi copiada para a package ETF, a alteração realizada aqui deve ser replicada para a package ETF 
---------------------------------------------------------------------------------------------------------------------------------
FUNCTION VPIPE_CLOB ( prm_entrada clob,
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


-----
-- Atenção: essa function foi copiada para a package ETF, a alteração realizada aqui deve ser replicada para a package ETF 
---------------------------------------------------------------------------------------------------------------------------------
function ret_var  ( prm_variavel   varchar2 default null, 
                    prm_usuario    varchar2 default 'DWU' ) return varchar2 as
    ws_count      number; 
    ws_variavel   varchar2(500); 
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


/*******
function ret_var  ( prm_variavel   varchar2 default null, 
                    prm_usuario    varchar2 default 'DWU' ) return varchar2 as
	cursor crs_variaveis is
		select conteudo
		  from VAR_CONTEUDO
		 where USUARIO  = prm_usuario 
		   and VARIAVEL = replace(replace(prm_variavel, '#[', ''), ']', '');

	ws_variaveis	crs_variaveis%rowtype;
begin
	Open  crs_variaveis;
	Fetch crs_variaveis into ws_variaveis;
	close crs_variaveis;

	return (ws_variaveis.conteudo);
exception when others then
    return '';
end ret_var;
************/ 

-----
-- Atenção: essa function foi copiada para a package ETF, a alteração realizada aqui deve ser replicada para a package ETF 
---------------------------------------------------------------------------------------------------------------------------------
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

procedure setSessao ( prm_cod   varchar2 default null,
                      prm_valor varchar2 default null,
                      prm_data  date     default null ) as

    ws_tipo varchar2(80);

begin

    --se não tiver valor é para excluir
    if nvl(prm_valor, 'N/A') = 'N/A' then
        --se tiver data é pra limpar todas daquela data para baixo
        if nvl(prm_data, sysdate-10) = sysdate-10 then
            delete from bi_sessao where cod = prm_cod;
        else
            delete from bi_sessao where dt_acesso <= prm_data;
        end if;
    else

        --select owa_util.get_cgi_env('HTTP_USER_AGENT') into ws_tipo from dual;

        merge into bi_sessao using dual on (cod = prm_cod)
        when not matched then
            insert values (prm_cod, 'USUARIO', nvl(prm_data, sysdate+0.5), prm_valor)
        when matched then
            update set valor = prm_valor;
    end if;

	commit;

end setSessao;

procedure SET_VAR  ( PRM_VARIAVEL   VARCHAR2 DEFAULT NULL,
                     prm_conteudo   varchar2 default null,
                     PRM_USUARIO    VARCHAR2 DEFAULT 'DWU' ) as

BEGIN
	
	update VAR_CONTEUDO set conteudo = prm_conteudo
	where upper(trim(VARIAVEL)) = REPLACE(REPLACE(upper(trim(PRM_VARIAVEL)), '#[', ''), ']', '') and
	USUARIO = PRM_USUARIO;
	commit;
	

end SET_VAR;

function GVALOR( prm_objeto	      varchar2 default null,
                 prm_screen       varchar2 default null,
                 prm_usuario      varchar2 default null,
                 prm_formatar     varchar2 default 'N',
                 prm_param_filtro varchar2 default null ) return varchar2 as

	ws_cd_micro_visao	PONTO_AVALIACAO.cd_micro_visao%type;
	ws_parametros		PONTO_AVALIACAO.parametros%type;
    ws_parametro        varchar2(800);
    ws_obj              varchar2(500);
    ws_ponto            varchar2(80);
    ws_valor            varchar2(32000);
    ws_valor_abrev      varchar2(200);
    ws_coluna           varchar2(200);     
    ws_mascara          varchar2(200);
    ws_formula          varchar2(32000); 
    ws_um_coluna        varchar2(100); 
    ws_um_obj           varchar2(100);

begin

    ws_obj := trim(replace(replace(prm_objeto, '@[', ''), ']', ''));
    
	select cd_micro_visao, parametros, cd_ponto into
	       ws_cd_micro_visao, ws_parametros, ws_ponto
	from   PONTO_AVALIACAO
	where  cd_ponto = ws_obj or cd_ponto = (select cd_objeto from objetos where cod = ws_obj);

    if prm_param_filtro is not null then -- Se passou parametro de filtro então contatena com o parametro do objeto valor 
        ws_parametros := ws_parametros||prm_param_filtro; 
    end if;  
    -- colacado esse nvl para caso a formula com objeto retornar null e a mesma ter continuidade como por exemplo ((null+null)/100) +1 consiga dar os nvls no valor nulo e some o +1
    -- esperar o suporte validar 100% para ver se não interfere com outros tipos de formulas. 
    ws_valor := nvl(substr(fun.valor_ponto( ws_parametros, ws_cd_micro_visao, ws_ponto, prm_screen, prm_usuario ),1,31999),0) ; 
    
    -- Se deve retornar o valor formatado com mascara e outros 
    if nvl(prm_formatar,'N') = 'S' then 
        if fun.getprop(prm_objeto,'ABREVIACAO') = 'S' then
            begin 
                ws_valor_abrev := ws_valor; 
                if    abs(ws_valor_abrev) >1000000000000 then   ws_valor_abrev:=round(ws_valor_abrev/1000000000000,2)|| ' T';
                elsif abs(ws_valor_abrev) >1000000000    then   ws_valor_abrev:=round(ws_valor_abrev/1000000000,2)|| ' B';
                elsif abs(ws_valor_abrev) >1000000       then   ws_valor_abrev:=round(ws_valor_abrev/1000000,2)|| ' M';
                elsif abs(ws_valor_abrev) >1000          then   ws_valor_abrev:=round(ws_valor_abrev/1000,2)|| ' K';
                else                                            ws_valor_abrev:=round(ws_valor_abrev,2);
                end if;
                ws_valor := replace(ws_valor_abrev,'.',',');
            exception when others then 
                null;
            end; 
        end if;		

        ws_coluna := substr(ws_parametros, 1 ,instr(ws_parametros,'|')-1); 
        select nm_mascara, nm_unidade, formula  into ws_mascara, ws_um_coluna, ws_formula
		  from micro_coluna
		 where cd_micro_visao = ws_cd_micro_visao 
		   and cd_coluna      = ws_coluna; 

        ws_valor := fun.ifmascara(ws_valor, rtrim(ws_mascara), ws_cd_micro_visao, ws_coluna, prm_objeto, '', ws_formula, prm_screen, prm_usuario);

        ws_um_obj := fun.getprop(trim(prm_objeto),'UM');
		if ws_um_obj is not null then
            ws_valor:= fun.um(null,null, ws_valor, ws_um_obj);
        else     
            if ws_um_coluna is not null then 
			    ws_valor := fun.UM(ws_coluna, ws_cd_micro_visao, ws_valor, ws_um_coluna);
            end if;     
		end if;

    end if; 

	return(ws_valor);
exception when others then
    htp.p(sqlerrm||''||ws_parametros||ws_parametro);
end GVALOR;


FUNCTION CHECK_BLINK ( prm_objeto    varchar2 default null,
                       prm_coluna    varchar2 default null,
                       prm_conteudo  varchar2 default null,
                       prm_original  varchar2 default null,
                       prm_screen    varchar2 default null,
                       prm_usuario   varchar2 default null,
                       prm_pre_suf_alias varchar2 default null,
                       prm_ar_colref DBMS_SQL.VARCHAR2_TABLE default TP_VARCHAR2_TABLE,
                       prm_ar_colval DBMS_SQL.VARCHAR2_TABLE default TP_VARCHAR2_TABLE) return char is
	
    cursor crs_blinks is
		--select TIPO_DESTAQUE, CONDICAO, fun.CONVERT_PAR(CONTEUDO, prm_screen => prm_screen, prm_pre_suf_alias => prm_pre_suf_alias, prm_ar_colref => prm_ar_colref, prm_ar_colval => prm_ar_colval) as CONTEUDO, -- isso gera erro no Oracle 11
        select TIPO_DESTAQUE, CONDICAO, CONTEUDO, COR_FUNDO, COR_FONTE, nvl(prioridade, 0)
		  from destaque t1
	 	 where (cd_usuario in ( prm_usuario, 'DWU') or cd_usuario in (select cd_group from gusers_itens where cd_usuario = prm_usuario)) 
           and cd_objeto   = prm_objeto 
           and cd_coluna   = prm_coluna 
           and tipo_destaque IN ('normal','celula barra')
		order by prioridade asc;

	-- ws_blink 	crs_blinks%rowtype;

    ws_cor_fundo     varchar2(40);
    ws_cor_fonte     varchar2(40);
    ws_saida         varchar2(2000);
    ws_saida_1        varchar2(2000);
    ws_blink_count   number;
    
    ws_conteudo_aux varchar2(2000);
    ws_conteudo      number;
    ws_valor         number;
    ws_conteudo_char varchar2(200);
    ws_valor_char    varchar2(200);
    ws_tipo          varchar2(80);
    ws_usuario       varchar2(80);
    ws_nulo          varchar2(1) := null;

begin

	ws_saida := prm_original;
	
    ws_cor_fonte   := 'NOBLINK';
    ws_blink_count := 0; 
    
    for ws_blink in crs_blinks loop

        ws_blink_count  := ws_blink_count + 1;  
        ws_conteudo_aux := fun.CONVERT_PAR(ws_blink.conteudo, prm_screen => prm_screen, prm_pre_suf_alias => prm_pre_suf_alias, prm_ar_colref => prm_ar_colref, prm_ar_colval => prm_ar_colval);
        --
        if fun.isnumber(prm_conteudo) and fun.isnumber(ws_conteudo_aux) then
            ws_conteudo := to_number(ws_conteudo_aux);
            ws_valor    := to_number(prm_conteudo);
            fun.blink_condition(ws_blink.condicao, ws_valor, ws_conteudo, ws_blink.cor_fundo, ws_blink.cor_fonte, ws_saida_1, ws_cor_fundo, ws_cor_fonte, prm_original => ws_saida);
        else
            ws_conteudo_char := ws_conteudo_aux;
            ws_valor_char    := prm_conteudo;
            fun.blink_condition(ws_blink.condicao, ws_valor_char, ws_conteudo_char, ws_blink.cor_fundo, ws_blink.cor_fonte, ws_saida_1, ws_cor_fundo, ws_cor_fonte, prm_original => ws_saida);
        end if;

        if ws_cor_fonte <> 'NOBLINK' then 
            select tp_objeto into ws_tipo from objetos where cd_objeto = prm_objeto;

            if ws_blink.tipo_destaque = 'celula barra' and ws_tipo = 'CONSULTA' then  
                ws_saida := 'style="background: linear-gradient(to right, '||ws_cor_fundo||' '||ws_valor||'%, transparent '||(ws_valor)||'%); background-position-x: 0px !important; color:'||ws_cor_fonte||'; "';  
            else 
                if ws_tipo = 'CONSULTA' then
                    if nvl(ws_cor_fundo, 'N/A') = 'N/A' then
                        ws_saida := 'style=" color:'||ws_cor_fonte||'; " ';
                    else
                        ws_saida := 'style=" background-color:'||ws_cor_fundo||'; color:'||ws_cor_fonte||'; " ';
                    end if;
                else
                    if nvl(ws_cor_fundo, 'N/A') = 'N/A' then
                        ws_saida := 'color:'||ws_cor_fonte||'; ';
                    else
                        ws_saida := 'background-color:'||ws_cor_fundo||' !important; color:'||ws_cor_fonte||' !important; ';
                    end if;
                end if;
            end if; 
        end if;
        
    end loop;
    
    if ws_blink_count > 0 then 
        return(ws_saida);
    else 
        return(ws_nulo);        
	end if;

	exception when others then
		return(ws_nulo);
end CHECK_BLINK;


procedure blink_condition ( prm_condicao  in  varchar2,
                            prm_valor     in  varchar2,
                            prm_conteudo  in  varchar2,
                            prm_cor_fundo in  varchar2,
                            prm_cor_fonte in  varchar2,
                            ws_saida      out varchar2,
                            ws_cor_fundo  out varchar2,
                            ws_cor_fonte  out varchar2,
                            prm_original  in  varchar2) as
    ws_valor_n    number;
    ws_conteudo_n number; 
    ws_valor_d    date;
    ws_conteudo_d date;  
    ws_valor_c    varchar2(4000);
    ws_conteudo_c varchar2(4000);  
    ws_tipo       varchar2(1); 
    
begin

    case prm_condicao
        when 'LIKE' then
            if  prm_valor like prm_conteudo then
                ws_cor_fundo := prm_cor_fundo;
                ws_cor_fonte := prm_cor_fonte;
            end if;
        when 'NOTLIKE' then
            if  prm_valor not like prm_conteudo then
                ws_cor_fundo := prm_cor_fundo;
                ws_cor_fonte := prm_cor_fonte;
            end if;
        when 'IGUAL' then
            if  prm_valor = prm_conteudo then
                ws_cor_fundo := prm_cor_fundo;
                ws_cor_fonte := prm_cor_fonte;
            end if;
        when 'DIFERENTE' then
            if  prm_valor <> prm_conteudo then
                ws_cor_fundo := prm_cor_fundo;
                ws_cor_fonte := prm_cor_fonte;
            end if;
        else     
            
            begin 
                ws_valor_n    := to_number(prm_valor);
                ws_conteudo_n := to_number(prm_conteudo);
                ws_tipo       := 'N'; 
            exception when others then 
                begin 
                    ws_valor_d    := to_date(prm_valor);
                    ws_conteudo_d := to_date(prm_conteudo); 
                    ws_tipo       := 'D';
                exception when others then 
                    ws_valor_c    := upper(prm_valor);
                    ws_conteudo_c := upper(prm_conteudo); 
                    ws_tipo       := 'C';
                end; 
            end; 

            if prm_condicao = 'MAIOR' then
                if (ws_tipo = 'N' and ws_valor_n > ws_conteudo_n) or 
                   (ws_tipo = 'D' and ws_valor_d > ws_conteudo_d) or 
                   (ws_tipo = 'C' and ws_valor_c > ws_conteudo_c) then   
                   ws_cor_fundo := prm_cor_fundo;
                   ws_cor_fonte := prm_cor_fonte;
                end if;    
            elsif prm_condicao = 'MAIOROUIGUAL' then
                if (ws_tipo = 'N' and ws_valor_n >= ws_conteudo_n) or 
                   (ws_tipo = 'D' and ws_valor_d >= ws_conteudo_d) or 
                   (ws_tipo = 'C' and ws_valor_c >= ws_conteudo_c) then   
                   ws_cor_fundo := prm_cor_fundo;
                   ws_cor_fonte := prm_cor_fonte;
                end if;    
            elsif prm_condicao = 'MENOR' then
                if (ws_tipo = 'N' and ws_valor_n < ws_conteudo_n) or 
                   (ws_tipo = 'D' and ws_valor_d < ws_conteudo_d) or 
                   (ws_tipo = 'C' and ws_valor_c < ws_conteudo_c) then   
                   ws_cor_fundo := prm_cor_fundo;
                   ws_cor_fonte := prm_cor_fonte;
                end if;    
            elsif prm_condicao =  'MENOROUIGUAL' then
                if (ws_tipo = 'N' and ws_valor_n <= ws_conteudo_n) or 
                   (ws_tipo = 'D' and ws_valor_d <= ws_conteudo_d) or 
                   (ws_tipo = 'C' and ws_valor_c <= ws_conteudo_c) then   
                   ws_cor_fundo := prm_cor_fundo;
                   ws_cor_fonte := prm_cor_fonte;
                end if;    
            else
                ws_saida := prm_original;
            end if;     
    end case;


end blink_condition;



/****************** BKP - 03/04/2023 - antes do card: 679S - Destaque do tipo linha 
procedure blink_condition ( prm_condicao  in  varchar2,
                            prm_valor     in  varchar2,
                            prm_conteudo  in  varchar2,
                            prm_cor_fundo in  varchar2,
                            prm_cor_fonte in  varchar2,
                            ws_saida      out varchar2,
                            ws_cor_fundo  out varchar2,
                            ws_cor_fonte  out varchar2,
                            prm_original  in  varchar2) as

    
begin
    
    case prm_condicao
        when 'IGUAL' then
            if  prm_valor = prm_conteudo then
                ws_cor_fundo := prm_cor_fundo;
                ws_cor_fonte := prm_cor_fonte;
            end if;
        when 'DIFERENTE' then
            if  prm_valor <> prm_conteudo then
                ws_cor_fundo := prm_cor_fundo;
                ws_cor_fonte := prm_cor_fonte;
            end if;
        when 'MAIOR' then
            begin
                if to_number(prm_valor) > to_number(prm_conteudo) then
                    ws_cor_fundo := prm_cor_fundo;
                    ws_cor_fonte := prm_cor_fonte;
                end if;
            exception when others then
                if prm_valor > prm_conteudo then
                    ws_cor_fundo := prm_cor_fundo;
                    ws_cor_fonte := prm_cor_fonte;
                end if;
            end;
        when 'MENOR' then
            begin
                if to_number(prm_valor) < to_number(prm_conteudo) then
                    ws_cor_fundo := prm_cor_fundo;
                    ws_cor_fonte := prm_cor_fonte;
                end if;
            exception when others then
                if prm_valor < prm_conteudo then
                    ws_cor_fundo := prm_cor_fundo;
                    ws_cor_fonte := prm_cor_fonte;
                end if;
            end;
        when 'MAIOROUIGUAL' then
            begin
                if to_number(prm_valor) >= to_number(prm_conteudo) then
                    ws_cor_fundo := prm_cor_fundo;
                    ws_cor_fonte := prm_cor_fonte;
                end if;
            exception when others then
                if prm_valor >= prm_conteudo then
                    ws_cor_fundo := prm_cor_fundo;
                    ws_cor_fonte := prm_cor_fonte;
                end if;
            end;
        when 'MENOROUIGUAL' then
             begin
                if to_number(prm_valor) <= to_number(prm_conteudo) then
                    ws_cor_fundo := prm_cor_fundo;
                    ws_cor_fonte := prm_cor_fonte;
                end if;
            exception when others then
                if prm_valor <= prm_conteudo then
                    ws_cor_fundo := prm_cor_fundo;
                    ws_cor_fonte := prm_cor_fonte;
                end if;
            end;
        when 'LIKE' then
            if  prm_valor like prm_conteudo then
                ws_cor_fundo := prm_cor_fundo;
                ws_cor_fonte := prm_cor_fonte;
            end if;
        when 'NOTLIKE' then
            if  prm_valor not like prm_conteudo then
                ws_cor_fundo := prm_cor_fundo;
                ws_cor_fonte := prm_cor_fonte;
            end if;
        else
            ws_saida := prm_original;
    end case;


end blink_condition;
**************************/ 

FUNCTION CHECK_BLINK_TOTAL ( prm_objeto   varchar2 default null,
                             prm_coluna   varchar2 default null,
                             prm_conteudo varchar2 default null,
                             prm_original varchar2 default null,
                             prm_screen   varchar2 default null,
                             prm_pre_suf_alias varchar2 default null,
                             prm_ar_colref DBMS_SQL.VARCHAR2_TABLE default TP_VARCHAR2_TABLE,
					         prm_ar_colval DBMS_SQL.VARCHAR2_TABLE default TP_VARCHAR2_TABLE ) return char is
	
    cursor crs_blinks(prm_usuario varchar2) is
		--select TIPO_DESTAQUE, CONDICAO, fun.CONVERT_PAR(CONTEUDO, prm_screen => prm_screen, prm_pre_suf_alias => prm_pre_suf_alias, prm_ar_colref => prm_ar_colref, prm_ar_colval => prm_ar_colval) as CONTEUDO, COR_FUNDO, COR_FONTE, prioridade   -- isso gera erro no Oracle 11
        select TIPO_DESTAQUE, CONDICAO, CONTEUDO, COR_FUNDO, COR_FONTE, prioridade
		  from destaque
		 where ( cd_usuario in ( prm_usuario, 'DWU') OR cd_usuario in (select cd_group from gusers_itens where cd_usuario = prm_usuario)) 
           and cd_objeto   = prm_objeto 
           and cd_coluna   = prm_coluna 
           and tipo_destaque in ('total', 'total barra')
	 	 order by prioridade asc;

    ws_cor_fundo        varchar2(40);
    ws_cor_fonte        varchar2(40);
    ws_usuario          varchar2(80);
    ws_saida            varchar2(2000);
    ws_saida_1          varchar2(2000);
    ws_blink_count      number;
    ws_conteudo_aux     varchar2(200);
    ws_conteudo         VARCHAR2(200);
    ws_valor            VARCHAR2(200);
    ws_nulo             varchar2(1) := null;

begin

    ws_usuario := gbl.getUsuario;

	ws_saida       := prm_original;
    ws_blink_count := 0;
	
	for ws_blink in crs_blinks(ws_usuario) loop 

		ws_blink_count  := ws_blink_count + 1; 
        ws_conteudo_aux := fun.CONVERT_PAR(ws_blink.conteudo, prm_screen => prm_screen, prm_pre_suf_alias => prm_pre_suf_alias, prm_ar_colref => prm_ar_colref, prm_ar_colval => prm_ar_colval ); 

        begin
            ws_conteudo := nvl(to_number(ws_conteudo_aux),0);
        exception when others then
            ws_conteudo := ws_conteudo_aux;
        end;
    
        begin
            ws_valor := nvl(to_number(prm_conteudo),0);
        exception when others then
            ws_valor := prm_conteudo;
        end;

        ws_cor_fundo := 'NOBLINK';
        ws_cor_fonte := 'NOBLINK';

        fun.blink_condition(ws_blink.condicao, ws_valor, ws_conteudo, ws_blink.cor_fundo, ws_blink.cor_fonte, ws_saida_1, ws_cor_fundo, ws_cor_fonte, prm_original => ws_saida);

        if ws_cor_fundo <> 'NOBLINK' and ws_cor_fonte <> 'NOBLINK' then 
            if ws_blink.tipo_destaque = 'total barra' then 
                ws_saida := 'style="background: linear-gradient(to right, '||ws_cor_fundo||' '||ws_valor||'%, transparent '||(ws_valor)||'%); background-position-x: 0px !important; color:'||ws_cor_fonte||'; "';  
            else 
                if nvl(ws_cor_fundo, 'N/A') = 'N/A' then
                    ws_saida := 'style=" color:'||ws_cor_fonte||' !important; " ';
                else
                    ws_saida := 'style=" background-color:'||ws_cor_fundo||' !important; color:'||ws_cor_fonte||' !important;" ';
                end if;
            end if;     
        end if;
			
	end loop;
	
		
	
    if ws_blink_count > 0 then 
    	return(ws_saida);
    else
	    return(ws_nulo);
	end if;

exception when others then
	return(ws_nulo);
end CHECK_BLINK_TOTAL;


FUNCTION CHECK_BLINK_LINHA ( prm_objeto   varchar2 default null,
                             prm_coluna   varchar2 default null,
                             prm_linha    varchar2 default null,
                             prm_conteudo varchar2 default null,
                             prm_screen   varchar2 default null,
                             prm_pre_suf_alias varchar2 default null,
                             prm_ar_colref DBMS_SQL.VARCHAR2_TABLE default TP_VARCHAR2_TABLE,
					   		 prm_ar_colval DBMS_SQL.VARCHAR2_TABLE default TP_VARCHAR2_TABLE ) return varchar2 is
	cursor crs_blinks(prm_usuario varchar2) is
		--select CONDICAO, fun.CONVERT_PAR(CONTEUDO, prm_screen => prm_screen, prm_pre_suf_alias => prm_pre_suf_alias, prm_ar_colref => prm_ar_colref, prm_ar_colval => prm_ar_colval) as CONTEUDO,   -- isso gera erro no Oracle 11
        select CONDICAO, CONTEUDO, COR_FUNDO, COR_FONTE, cd_usuario, tipo_destaque, prioridade
		  from destaque
	 	 where ( cd_usuario in (prm_usuario, 'DWU') OR cd_usuario in (select cd_group from gusers_itens where cd_usuario = prm_usuario) ) 
           and cd_objeto      = trim(prm_objeto) 
           and tipo_destaque in ('linha', 'estrela') 
           and cd_coluna      = trim(prm_coluna)
		order by prioridade asc;

	ws_blink 	crs_blinks%rowtype;
    ws_cor_fundo     varchar2(80);
    ws_cor_fonte     varchar2(80);
	ws_saida         varchar2(4000) := '';
    ws_saida_1       varchar2(4000) := '';
    -- ws_blink_count   number;	
	ws_conteudo_aux  varchar2(2000);
    ws_conteudo      varchar2(2000);
	ws_valor         varchar2(2000);
	ws_conteudo_n    number;
	ws_valor_n       number;
    ws_nulo          varchar2(1) := null;
    ws_tipo          varchar2(120);
    ws_tipo_destaque varchar2(120);
    ws_usuario       varchar2(120);

begin

    ws_usuario := gbl.getUsuario;
	
    ws_saida     := null; 
    ws_cor_fundo := 'NOBLINK';
	ws_cor_fonte := 'NOBLINK';

	for ws_blink in crs_blinks(ws_usuario) loop

        ws_conteudo_aux := fun.CONVERT_PAR(ws_blink.conteudo, prm_screen => prm_screen, prm_pre_suf_alias => prm_pre_suf_alias, prm_ar_colref => prm_ar_colref, prm_ar_colval => prm_ar_colval); 
        ws_valor_n      := 0;
        ws_conteudo_n   := 0;
        ws_conteudo     := ws_conteudo_aux;
        ws_valor        := prm_conteudo;

        if fun.isnumber(prm_conteudo) and fun.isnumber(ws_conteudo_aux) then 
            ws_valor_n    := to_number(prm_conteudo);
            ws_conteudo_n := to_number(ws_conteudo_aux);
            fun.blink_condition(ws_blink.condicao, ws_valor_n, ws_conteudo_n, ws_blink.cor_fundo, ws_blink.cor_fonte, ws_saida_1, ws_cor_fundo, ws_cor_fonte, ws_saida);
            ws_tipo_destaque := ws_blink.tipo_destaque;
        else 
            fun.blink_condition(ws_blink.condicao, upper(ws_valor), upper(ws_conteudo), ws_blink.cor_fundo, ws_blink.cor_fonte, ws_saida_1, ws_cor_fundo, ws_cor_fonte, ws_saida);
            ws_tipo_destaque := ws_blink.tipo_destaque;
        end if; 

        select tp_objeto into ws_tipo from objetos where trim(cd_objeto) = trim(prm_objeto);
                
        if ws_tipo = 'BROWSER' then
            if upper(trim(ws_blink.cd_usuario)) in (ws_usuario, 'DWU') and (trim(ws_cor_fundo) <> 'NOBLINK' and trim(ws_cor_fonte) <> 'NOBLINK') then
                if ws_tipo_destaque = 'estrela' then
                    ws_saida := ws_saida_1||ws_saida||' <style> tr#'||prm_linha||' td.destaqueicon { background-color:'||ws_cor_fundo||' !important; } tr#'||prm_linha||' td.destaqueicon svg { fill:'||ws_cor_fonte||' !important; }</style>';
                else
                    ws_saida := ws_saida_1||ws_saida||' <style> tr#'||prm_linha||' td, tr#'||prm_linha||' td input, tr#'||prm_linha||' td select, tr#'||prm_linha||' td span { background-color:'||ws_cor_fundo||' !important; color:'||ws_cor_fonte||' !important; }</style>';
                end if;
            end if;
        else
            if ws_cor_fundo <> 'NOBLINK' and ws_cor_fonte <> 'NOBLINK' then 
                ws_saida := ws_saida_1||ws_saida||'<td class="print" title="'||ws_valor_n||' - '||ws_conteudo_n||' - '||ws_valor||' - '||ws_conteudo||'" style="display: none; visibility: hidden;">background:'||ws_cor_fundo||' !important; color:'||ws_cor_fonte||' !important;</td>';
            end if;
        end if;

	end loop;

	return(ws_saida);
		
exception when others then
	return(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
end CHECK_BLINK_LINHA;


FUNCTION WACESSO ( prm_who varchar2 default 'ALL') return CHARRET pipelined is
	cursor crs_role is
		select  cd_role, tipo
		from	ROLES
		where	cd_usuario=gbl.getUsuario;

	ws_role		crs_role%rowtype;

	ws_count	number;

begin

	select nvl(count(*),0) into ws_count
	from ROLES
	where cd_usuario = gbl.getUsuario and tipo='ONLY';

	if  prm_who='ALL' then
	    if  ws_count = 0 then
		open crs_role;
		loop
		   fetch crs_role into ws_role;
			 exit when crs_role%notfound;
		   pipe row (ws_role.cd_role);
		end loop;
		close crs_role;
	    else
		if  ws_count > 1 then
		    pipe row ('ERROR');
		else
		    select max(cd_role) into ws_role.cd_role
		    from ROLES
		    where cd_usuario=gbl.getUsuario and tipo='ONLY';
		    pipe row (ws_role.cd_role);
		end if;
	    end if;
	else
	    select max(cd_role) into ws_role.cd_role
	    from ROLES
	    where cd_usuario=gbl.getUsuario and tipo='ME';
	    pipe row (ws_role.cd_role);
	end if;

end WACESSO;


FUNCTION WHO return varchar as

  ws_saida  varchar2(80);
  ws_nulo   varchar2(1) := null;

begin

  select COLUMN_VALUE into ws_saida
  from table(fun.wacesso('ME'));

 return (ws_saida);

exception
    when others then
         return(ws_nulo);
end WHO;


FUNCTION GPARAMETRO ( prm_parametro varchar2 default null, 
                      prm_desc      varchar2 default 'N',
                      prm_screen    varchar2 default null, 
                      prm_usuario   varchar2 default null,
                      prm_valida    varchar2 default 'N' ) return varchar2 as

    ws_conteudo varchar2(500);
    ws_saida    varchar2(200);
    ws_desc     varchar2(200);
    ws_usuario  varchar2(80);
    ws_eh_par_u varchar2(1);
    ws_eh_float varchar2(1);
    ws_eh_par_p varchar2(1);

    ws_filtro   number;
    ws_formato  number;
    ws_nulo     varchar2(1) := null;

begin
    if prm_usuario is not null then 
        ws_usuario := prm_usuario;
    else     
        ws_usuario := gbl.getUsuario;
    end if; 

        

    ws_conteudo := prm_parametro;
    ws_conteudo := replace(ws_conteudo, '$[','');
    ws_conteudo := replace(ws_conteudo, ']', '');

    ws_eh_par_u := 'S';
    begin

        select nvl(conteudo,' ') into ws_saida  -- Retirado o upper, 16/03/2023 - card 668s
          from  PARAMETRO_USUARIO
         where cd_usuario             = ws_usuario 
           and upper(trim(cd_padrao)) = replace(upper(trim(ws_conteudo)),'@PIPE@','');

    exception
         when others then
              begin
                   select nvl(conteudo,' ') into ws_saida  -- Retirado o upper, 16/03/2023 - card 668s
                     from   PARAMETRO_USUARIO
                    where cd_usuario             = 'DWU' 
                      and upper(trim(cd_padrao)) = replace(upper(trim(ws_conteudo)),'@PIPE@','');
              exception
                   when others then 
                        ws_saida    := '';
                        ws_eh_par_u := 'N'; 

              end;
    end;

    if ws_saida is null then
        select min(nvl(conteudo,' ')) into ws_saida
        from  float_filter_item
        where upper(trim(cd_coluna)) = upper(trim(ws_conteudo))
          and (prm_screen is null or (prm_screen is not null and prm_screen = screen));
        if fun.isnumber(ws_saida) then
            ws_saida := to_number(ws_saida);
        end if;
    end if;

    ws_eh_float := 'N'; 
    select count(*) into ws_filtro
      from FLOAT_FILTER_ITEM
     where cd_usuario = ws_usuario 
       and cd_coluna  = ws_conteudo 
       and screen     = prm_screen;

    if  ws_filtro > 0 then
        ws_eh_float := 'S';     
    end if; 

    if  ws_filtro = 1 then
        begin
             select nvl(max(conteudo),' ') into ws_saida
             from   FLOAT_FILTER_ITEM
             where cd_usuario = ws_usuario 
               and cd_coluna  = ws_conteudo 
               and screen     = prm_screen;
        exception
             when others then
                  ws_saida := ' ';
        end;
    elsif ws_filtro > 1 then
        begin
            select listagg(conteudo, '/') within group (order by conteudo) into ws_saida
              from FLOAT_FILTER_ITEM
             where cd_usuario = ws_usuario 
               and cd_coluna  = ws_conteudo 
               and screen     = prm_screen;
        exception
             when others then
                  ws_saida := ' ';
        end;
        if length(ws_saida) > 30 then
            ws_saida := substr(ws_saida, 1, 30)||'...';
        end if;
	end if;

    ws_eh_par_p := 'N';

    if  prm_desc = 'Y' then
        begin
            select nvl(CD_LIGACAO,'SEM') into ws_desc
              from PARAMETRO_PADRAO
             where cd_padrao=ws_conteudo;
            ws_eh_par_p := 'S';             
        exception
            when others then 
                ws_desc     := 'SEM';
                ws_eh_par_p := 'N'; 
        end;
        if  ws_desc <> 'SEM' then
            ws_formato := fun.getprop(ws_conteudo,'FORMATO');
            if ws_filtro > 1  and ws_formato <> 1 then
                if ws_formato = 0 then
                    select listagg(column_value||' - '||fun.cdesc(column_value,ws_desc),'/') within group (order by column_value) into ws_saida
                      from table(fun.vpipe(ws_saida, '/'));
                else
                    select listagg(fun.cdesc(column_value,ws_desc),'/') within group (order by column_value) into ws_saida
                      from table(fun.vpipe(ws_saida, '/'));
                end if;
                if length(ws_saida) > 30 then
                    ws_saida := (substr(ws_saida, 1, 30))||'...';
                end if;
            else
                ws_saida := fun.cdesc(ws_saida,ws_desc);
            end if;
        end if;
    end if;

    if prm_valida = 'S' and ws_saida is null and ws_eh_par_u = 'N' and ws_eh_par_p = 'N' and ws_eh_float = 'N' then 
        return '#ERROI#Par&acirc;metro '||upper(trim(ws_conteudo))||' n&atilde;o identificado como FILTRO de float de tela#ERROF#';
    end if; 

    return(ws_saida);

exception when others then
    return(sqlerrm);
end GPARAMETRO;

FUNCTION GFORMULA ( prm_texto        varchar2 default null,
                    prm_micro_visao  varchar2 default null,
                    prm_agrupador    varchar2 default null,
                    prm_inicio       varchar2 default 'NO',
                    prm_final        varchar2 default 'NO',
                    prm_screen       varchar2 default null,
                    prm_recurs       varchar2 default null,
                    prm_flexcol      varchar2 default 'N',
                    prm_flexend      varchar2 default 'N' ) return varchar2 as

    ws_texto      varchar2(8000);
    ws_flex_text  varchar2(8000);
    ws_funcao     varchar2(8000);
	ws_var        varchar2(8000);
	ws_agrupador  varchar2(100);
	ws_fix_agrupador varchar2(100);
	ws_tipo       varchar2(1);
	ws_calculada  varchar2(1);
	ws_formula    varchar2(8000);
	ws_nm_var     varchar2(8000);
	ws_recurs     varchar2(2);
	ws_flexcol    varchar2(8000);
	ws_flexend    varchar2(8000);

    ws_count number;

    ws_nulo varchar2(1) := null;

begin

    ws_count := 0;
    ws_texto := prm_texto;
    ws_funcao := '';
    ws_recurs := prm_recurs;
    ws_flexcol := 'N';
    ws_flexend := prm_flexend;
    

    if rtrim(substr(ws_texto,1,8))='FLEXCOL=' then
        ws_texto := replace(ws_texto,'FLEXCOL=','');
        ws_nm_var := substr(ws_texto, 1 ,instr(ws_texto,'|')-1);
        ws_texto  := substr(ws_texto, length(ws_nm_var||'|')+1, length(ws_texto));

	    begin
            SELECT decode(st_agrupador,'SEM','',st_agrupador) into ws_agrupador
            FROM   MICRO_COLUNA
            where  cd_coluna=fun.gparametro(trim(ws_nm_var), '', prm_screen) and cd_micro_visao=prm_micro_visao;
		exception when others then
            insert into log_eventos values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, user, 'FORMULA', 'ERRORGFORMULA', '01');
        end;

        if prm_agrupador = 'EXT' then
            ws_flex_text := fcl.fpdata(prm_inicio,'NO','',prm_inicio)||replace(ws_texto,'$[FLEXCOL]','??????')||fcl.fpdata(prm_final,'NO','',prm_final);
            ws_flex_text := fun.gformula(ws_flex_text,prm_micro_visao,'EXT','','',prm_screen,'N','N');
            ws_texto := fun.GFORMULA('$['||fun.gparametro(trim(ws_nm_var), prm_screen => prm_screen)||']',prm_micro_visao,'EXT','','',prm_screen,'N','N',ws_flex_text);
        else
            ws_texto  := fcl.fpdata(prm_inicio,'NO','',prm_inicio)||replace(ws_texto,'$[FLEXCOL]',fun.GFORMULA('$['||fun.gparametro(trim(ws_nm_var), prm_screen => prm_screen)||']',prm_micro_visao,ws_agrupador,'','',prm_screen,prm_recurs,'N'))||fcl.fpdata(prm_final,'NO','',prm_final);
        end if;
        ws_funcao := ws_texto;
    else
        ws_texto := upper(ws_texto)||'[END]';

        loop
            ws_count := ws_count + 1;
            if substr(ws_texto,ws_count,5)='[END]' then
                exit;
            end if;

            if substr(ptg_trans(ws_texto),ws_count,1) in (',','_','Q','W','E','R','T','Y','U','I','O','P','A','S','D','F','G','H','J','K','L','Z','X','C','V','B','N','M') then
                ws_funcao := ws_funcao||substr(ws_texto,ws_count,1);
            end if;

            if substr(ws_texto,ws_count,1) in ('+','-','/','*','(',')','>', '<', chr(39), '|', '=', ':') then
                ws_funcao := ws_funcao||substr(ws_texto,ws_count,1);
            end if;

            if substr(ws_texto,ws_count,1) in (' ','?','.','0','1','2','3','4','5','6','7','8','9') then
                ws_funcao := ws_funcao||substr(ws_texto,ws_count,1);
            end if;

            if substr(ws_texto,ws_count,1) in ('$', '@', '&', '#') then
                ws_tipo := substr(ws_texto,ws_count,1);
                ws_var  := '';
                ws_count := ws_count + 1;
                if substr(ws_texto,ws_count,1)<>'[' then
                    return('ERRO');
                else
                    loop
                        ws_count  := ws_count + 1;
                        if substr(ws_texto,ws_count,1)=']' then
                            if ws_tipo = '$' then
                                begin
                                    SELECT decode(st_agrupador,'SEM','',st_agrupador), tipo, formula
                                    into ws_agrupador, ws_calculada, ws_formula
                                    FROM MICRO_COLUNA
                                    where cd_coluna = ws_var and
                                    cd_micro_visao=prm_micro_visao;
                                end;

                                ws_fix_agrupador := ws_agrupador;

                                if ws_recurs = 'S' then
                                    ws_agrupador := 'EXT';
                                end if;

                                if prm_flexcol <> 'N' then
                                    if prm_flexcol not in ('S','Y') then
                                        ws_funcao := ws_funcao||prm_inicio||replace(prm_flexcol,'$[FLEXCOL]','$['||ws_var||']')||prm_final;
                                    else
                                        if prm_flexcol = 'Y' then
                                            ws_funcao := ws_funcao||fun.GFORMULA(ws_formula,prm_micro_visao,ws_agrupador,'','',prm_screen,'N','N',prm_flexend);
                                        else
                                            ws_funcao := ws_funcao||'('||ws_var||')';
                                        end if;
                                    end if;
                                else
                                    if prm_agrupador = 'EXT' then
                                        if prm_inicio = 'NO' and prm_final = 'NO' then
                                            if ws_calculada = 'C' then
                                                ws_funcao := ws_funcao||fcl.fpdata(ws_agrupador,'EXT','',ws_agrupador)||'('||fun.GFORMULA(ws_formula,prm_micro_visao,ws_agrupador,'','',prm_screen,'S',prm_flexcol,prm_flexend)||')';
                                            else
                                                ws_funcao := ws_funcao||fcl.fpdata(ws_agrupador,'EXT','',ws_agrupador)||'('||ws_var||')';
                                            end if;
                                        else
                                            if ws_calculada = 'C' then
                                                ws_funcao := ws_funcao||fcl.fpdata(ws_agrupador,'EXT','',ws_agrupador)||'('||prm_inicio||fun.GFORMULA(ws_formula,prm_micro_visao,ws_agrupador,'','',prm_screen,'S',prm_flexcol,prm_flexend)||prm_final||')';
                                            else
                                                if prm_flexend = 'N' then
                                                    ws_funcao := ws_funcao||fcl.fpdata(ws_agrupador,'EXT','',ws_agrupador)||'('||prm_inicio||ws_var||prm_final||')';
                                                else
                                                    ws_funcao := ws_funcao||ws_fix_agrupador||'('||prm_inicio||replace(ws_flexend,'??????',ws_var)||prm_final||')';
                                                end if;
                                            end if;
                                        end if;
                                    else
                                        if ws_calculada = 'C' then
                                            ws_funcao := ws_funcao||fcl.fpdata(ws_agrupador,'EXT',ws_agrupador,'')||'('||fun.GFORMULA(ws_formula,prm_micro_visao,'EXT','','',prm_screen,'S',prm_flexcol,prm_flexend)||')';
                                        else
                                            ws_funcao := ws_funcao||'('||ws_var||')';
                                        end if;
                                    end if;
                                end if;
                            else
                                if ws_tipo = '&' then
                                    ws_funcao := ws_funcao||chr(39)||fun.gparametro('$['||ws_var||']', prm_screen => prm_screen)||chr(39);
                                else
                                    if ws_tipo = '#' then
                                        ws_funcao := ws_funcao||fun.ret_var(ws_var, user);
                                    else
                                        ws_funcao := ws_funcao||fun.gvalor(ws_var, prm_screen);
                                    end if;
                                end if;
                            end if;
                            exit;
                        end if;
                        ws_var := ws_var||substr(ws_texto,ws_count,1);
                    end loop;
                end if;
            end if;
        end loop;
    end if;

return(ws_funcao);
exception when others then
htp.p(ws_nulo);

end GFORMULA;

function gformula2 ( prm_micro_visao  varchar2 default null,
                     prm_coluna       varchar2 default null,
                     prm_screen       varchar2 default null,
                     prm_inside       varchar2 default 'N',
                     prm_objeto       varchar2 default null,
                     prm_inicio       varchar2 default null,
                     prm_final        varchar2 default null,
                     prm_formula      varchar2 default null,
                     prm_valida       varchar2 default 'N',
					 prm_conexao_jet  varchar2 default null ) return varchar2 as

    ws_funcao    varchar2(4000);
    ws_formula   varchar2(32000);
    ws_flexcol   varchar2(80);
    ws_agrupador varchar2(80);
    ws_count     number;
    ws_variavel  varchar2(32000);
    ws_variavel_aux varchar2(32000);
    ws_tipo      varchar2(20);
    ws_exist     number;
    ws_inside    varchar2(80);
    ws_flex      varchar2(1);
    ws_cs_coluna varchar2(200);
    ws_var       varchar2(800);
    erro_geral   exception; 
    
begin

    select count(*) into ws_exist 
      from micro_coluna
	  where cd_micro_visao   = prm_micro_visao 
        and upper(cd_coluna) = upper(replace(replace(prm_coluna, '$[', ''), ']', '')) 
        and tipo             = 'T';
	begin 
	    select formula, flexcol, st_agrupador into ws_formula, ws_flexcol, ws_agrupador 
          from micro_coluna
         where cd_micro_visao   = prm_micro_visao 
           and upper(cd_coluna) = upper(prm_coluna);
    exception when no_data_found then 
        if prm_valida = 'S' then 
            return '#ERROI#Coluna '||upper(prm_coluna)||' n&atilde;o pertence a micro vis&atilde;o#ERROF#'; 
        else 
            raise erro_geral; 
        end if; 
    end;     

    if prm_formula is not null then 
        ws_formula := prm_formula; 
    end if; 

    if ws_exist = 0 then

	    select regexp_count(ws_formula, '.\[[a-zA-Z0-9_]+\]') into ws_count from dual;
	    
	    for i in 1..ws_count loop
	        
	        select regexp_substr(ws_formula, '.\[[a-zA-Z0-9_]+\]', 1) into ws_variavel from dual;
	        
	        select count(*) into ws_exist from micro_coluna
	         where cd_micro_visao = prm_micro_visao 
               and cd_coluna      = replace(replace(ws_variavel, '$[', ''), ']', '') 
               and tipo           = 'T';
	        
	        if ws_exist = 0 then
	            
				if instr(ws_variavel, '$[FLEX_DIM]') > 0 and nvl(prm_objeto, 'N/A') <> 'N/A' then
			        select cs_coluna into ws_cs_coluna from ponto_avaliacao where cd_ponto = prm_objeto;
			        select column_value into ws_cs_coluna from table((fun.vpipe(ws_cs_coluna))) where rownum = 1;
			        ws_variavel := replace(ws_variavel, '$[FLEX_DIM]', ws_cs_coluna);
					ws_tipo := 'N';
					
			    else

					if trim(upper(ws_variavel)) = '$[FLEXCOL]' then
						
						ws_variavel := '$['||ws_flexcol||']'; -----
						ws_variavel := fun.gparametro(ws_variavel, prm_screen => prm_screen, prm_valida => prm_valida);
                        -- Verifica se é um gparametro válido 
                        if prm_valida = 'S' then 
                            if nvl(ws_variavel,'NA') like '%#ERROI#%' then                         
                                return ws_variavel; 
                            elsif ws_variavel is null then 
                                return '#ERROI#Parametro/filtro (FLEXCOL) '||ws_flexcol||' n&atilde;o possui valor para a tela ativa#ERROF#'; 
                            end if;      
                        end if; 

                        --if prm_valida = 'S' and ws_variavel like '%#ERROI#%' and nvl(prm_screen,'DEFAULT') <> 'DEFAULT' then 
                        --    return ws_variavel; 
                        --end if;     

						ws_flex := 'S';
						ws_tipo := 'EXT';
						ws_inside := 'N';
                        
						if ws_flex  = 'S' then
                            begin 
                                select st_agrupador into ws_agrupador 
                                  from micro_coluna 
                                 where cd_micro_visao         = prm_micro_visao
                                   and upper(trim(cd_coluna)) = upper(trim(replace(replace(ws_variavel, '$[', ''), ']', ''))) ;
                            exception when no_data_found then 
                                if prm_valida = 'S' then 
                                    return '#ERROI#Coluna (FLEXCOL)'||upper(trim(replace(replace(ws_variavel, '$[', ''), ']', '')))||' n&atilde;o pertence a micro vis&atilde;o#ERROF#'; 
                                else 
                                    raise erro_geral;     
                                end if;
                            end;     
						end if;
						
					else
						
						ws_tipo := trim(substr(ws_variavel, 1, 1));
						if ws_tipo = '$' then
							ws_tipo := 'EXT';
						end if;
						ws_inside := ws_agrupador;
					end if;
		        end if;

                case ws_tipo
		            when '$' then
                        ws_variavel_aux := ws_variavel; 
		                ws_variavel     := fun.gparametro(ws_variavel, prm_screen => prm_screen, prm_valida => prm_valida);
                        -- Verifica se é um gparametro válido 
                        if prm_valida = 'S' then 
                            if nvl(ws_variavel,'NA') like '%#ERROI#%' then                         
                                return ws_variavel; 
                            elsif ws_variavel is null then 
                                return '#ERROI#Parametro/filtro '||ws_variavel_aux||' n&atilde;o possui valor para a tela ativa#ERROF#'; 
                            end if;      
                        end if;                         

		            when '&' then
                        ws_variavel_aux := fun.gparametro(replace(ws_variavel, '&', '$'), prm_screen => prm_screen, prm_valida => prm_valida); 
		                ws_variavel     := chr(39)||ws_variavel_aux||chr(39);
                        -- Verifica se é um gparametro válido 
                        if prm_valida = 'S' and nvl(ws_variavel_aux,'NA') like '%#ERROI#%' and nvl(prm_screen,'DEFAULT') <> 'DEFAULT' then 
                            return ws_variavel_aux; 
                        end if;     
                        --
		            when '#' then
                        -- Valida a existencia na var_conteudo 
                        if prm_valida = 'S' then 
                            select count(*) into ws_count
                              from var_conteudo
	                         where usuario  in ('DWU', gbl.getUsuario) 
	                           and variavel = replace(replace(ws_variavel, '#[', ''), ']', '');
                            if ws_count = 0 then    
                                return '#ERROI#Var&iacute;avel de sistema '||ws_variavel||' n&atilde;o existe#ERROF#'; 
                            end if;     
                        end if;    
                        --
		                ws_variavel     := fun.ret_var(ws_variavel, gbl.getUsuario);
                        --
		            when 'EXT' then
                        ws_variavel := fun.gformula2(prm_micro_visao, replace(replace(ws_variavel, '$[', ''), ']', ''), prm_screen, ws_inside, prm_objeto, prm_inicio, prm_final, prm_valida => prm_valida);
		            when 'N' then
		                ws_variavel := ws_variavel;
                    when '@' then
                        -- Valida a existência do objeto informado na fórmula 
                        if prm_valida = 'S' then 
                            select count(*) into ws_count
                              from objetos 
	                         where cd_objeto = trim(replace(replace(ws_variavel, '@[', ''), ']', '')); 
                            if ws_count = 0 then    
                                return '#ERROI#Objeto '||ws_variavel||' n&atilde;o existe no sistema#ERROF#'; 
                            end if;     
                        end if;    
                        --
		                ws_variavel     := fun.gvalor(ws_variavel, prm_screen);
                        
                        if  prm_valida = 'S' and ws_variavel is null then
                            ws_variavel := 0;
                        end if;

                    else

                        ws_variavel := ws_variavel;

                    end case;
		        
		    else
		        
                if prm_inside  = 'EXT' then
                    begin 
                        select st_agrupador into ws_agrupador 
                          from micro_coluna 
                         where cd_micro_visao = prm_micro_visao
                           and upper(trim(cd_coluna)) = upper(trim(replace(replace(ws_variavel, '$[', ''), ']', ''))) ;
                    exception when no_data_found then 
                        if prm_valida = 'S' then 
                            return '#ERROI#Coluna (EXT)'||upper(trim(replace(replace(ws_variavel, '$[', ''), ']', '')))||' n&atilde;o pertence a micro vis&atilde;o#ERROF#'; 
                        else 
                            raise erro_geral;     
                        end if;
                    end;                             
                end if;
                    
                ws_variavel := fun.gformula2(prm_micro_visao, replace(replace(ws_variavel, '$[', ''), ']', ''), prm_screen, ws_agrupador, prm_objeto, prm_inicio, prm_final, prm_valida => prm_valida);

		    end if;

			select regexp_replace(ws_formula, '.\[[a-zA-Z0-9_]+\]', ws_variavel, 1, 1) into ws_formula from dual;
		    
	    end loop;

        ws_formula := replace(replace(ws_formula, chr(13), ''), chr(10), ' ');
	    

	    if ws_flex = 'S'  then

			if ws_agrupador = 'EXT' then
		        return '('||ws_formula||')';
		    else
		        if nvl(prm_inicio, 'N/A') <> 'N/A' then
					ws_formula := prm_inicio||ws_formula||prm_final;
				end if;
				
	            if ws_agrupador in ('PSM','PCT','CNT') then
					
                    ws_formula := fun.gformula2(prm_micro_visao, replace(replace(ws_formula, '$[', ''), ']', ''), prm_screen, ws_agrupador, prm_objeto, prm_inicio, prm_final, prm_valida => prm_valida);
                    
                    if ws_agrupador = 'PSM' then
						return 'trunc((ratio_to_report(sum('||ws_formula||')) over ()*100))';
					else
						if ws_agrupador = 'CNT' then
							return 'count(distinct '||ws_formula||')';
						else
							return 'trunc((ratio_to_report(count(distinct '||ws_formula||')) over ()*100))';
						end if;
					end if;
				else
					return ws_agrupador||'('||ws_formula||')';
				end if;
				
				
	        end if;
			
	    elsif prm_inside = 'EXT' then 
	        
			if nvl(prm_inicio, 'N/A') <> 'N/A' then
				ws_formula := prm_inicio||ws_formula||prm_final;
			end if;
			
	        if ws_agrupador = 'EXT' then
		        return '('||ws_formula||')';
		    else
		        if ws_agrupador <> 'SEM' then
		            
	                if ws_agrupador in ('PSM','PCT','CNT') then

                        ws_formula := fun.gformula2(prm_micro_visao, replace(replace(ws_formula, '$[', ''), ']', ''), prm_screen, ws_agrupador, prm_objeto, prm_inicio, prm_final, prm_valida => prm_valida);

						if ws_agrupador = 'PSM' then
							return 'trunc((ratio_to_report(sum('||ws_formula||')) over ()*100))';
						else
							if ws_agrupador = 'CNT' then
								return 'count(distinct '||ws_formula||')';
							else
								return 'trunc((ratio_to_report(count(distinct '||ws_formula||')) over ()*100))';
							end if;
						end if;
					else
						return ws_agrupador||'('||ws_formula||')';
					end if;
					
	            else
	                return '('||ws_formula||')';
	            end if;
	        end if;
	    else
		    if ws_agrupador = 'EXT' then
		        return ws_formula;
		    else
		        return ws_formula;
		    end if;
		end if;
		
	else	
		
        if prm_inside = 'EXT' then
            if ws_agrupador <> 'SEM' and ws_agrupador <> 'EXT' then
                if nvl(prm_inicio, 'N/A') <> 'N/A' then
				    return ws_agrupador||'('||prm_inicio||prm_coluna||prm_final||')';
				else
                    return ws_agrupador||'('||prm_coluna||')';
                end if;
            else
                --verifica se a core trouxe decode(prm_inicio,prm_final) para coluna pivotada
                if  nvl(prm_inicio, 'N/A') <> 'N/A' then
                    return '('||prm_inicio||prm_coluna||prm_final||')';
                else
                    return '('||prm_coluna||')';
                end if;

            end if;
        else
            return prm_coluna;
        end if;

    end if;
    
exception 
    when erro_geral then
        insert into bi_log_sistema values(sysdate, prm_coluna||'|'||prm_micro_visao||' == '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' -  '||ws_flexcol||' - GFORMULA', gbl.getUsuario, 'ERRO');
        commit;
    when others then
        insert into bi_log_sistema values(sysdate, prm_coluna||'|'||prm_micro_visao||' == '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' -  '||ws_flexcol||' - GFORMULA', gbl.getUsuario, 'ERRO');
        commit;
        if prm_valida = 'S' then 
            return '#ERROI#Erro resolvendo f&oacute;rmula, verifique campos e vari&aacute;veis informadas#ERROF#'; 
        end if; 
end gformula2;



function gformula_browser ( prm_micro_data  varchar2 default null,
                            prm_coluna      varchar2 default null,
                            prm_screen      varchar2 default null) return varchar2 as

    ws_funcao    varchar2(4000);
    ws_formula   varchar2(32000);
    ws_tipo      varchar2(20);
    ws_cd_coluna varchar2(100);   
    ws_count     number;
    ws_exist     number;
    ws_variavel  varchar2(32000);
    ws_retorno   varchar2(32000); 
    
begin

	/*select regexp_substr('$[teste]|ecampos$[cd_teste]123$[vl_campos]', '.\[[a-zA-Z0-9_]+\]', 1, level) groupe from dual
    connect by regexp_substr('$[teste]|ecampos$[cd_teste]123$[vl_campos]', '.\[[a-zA-Z0-9_]+\]', 1, level) is not null;*/
    
	ws_cd_coluna := upper(replace(replace(prm_coluna, '$[', ''), ']', ''));  

	select min(tipo), min(formula) into ws_tipo, ws_formula
 	  from data_coluna
	 where cd_micro_data = prm_micro_data 
       and cd_coluna      = ws_cd_coluna;
    
    if nvl(ws_tipo,'NA') <> 'VIRTUAL' then 
        return 'T1.'||ws_cd_coluna;
    else 

        if ws_formula is null then 
            return null;
        end if; 
            
        if  UPPER(substr(ws_formula,1,5)) = 'EXEC=' then
            ws_retorno := ''''||FUN.XEXEC(ws_formula, prm_screen)||'''' ;  -- retorna o resultado entre aspas 
        else 
            select regexp_count(ws_formula, '.\[[a-zA-Z0-9_]+\]') into ws_count from dual;
            
            for i in 1..ws_count loop
                
                select regexp_substr(ws_formula, '.\[[a-zA-Z0-9_]+\]', 1) into ws_variavel from dual;
                ws_tipo := trim(substr(ws_variavel, 1, 1));

                case ws_tipo
                    when '#' then
                        ws_variavel := fun.ret_var(ws_variavel, gbl.getUsuario);
                    when '$' then
                        ws_variavel := fun.gformula_browser(prm_micro_data, ws_variavel, prm_screen);
                    when 'N' then
                        ws_variavel := ws_variavel;
                    when '@' then
                        ws_variavel := fun.gvalor(ws_variavel, prm_screen);
                    else
                        ws_variavel := ws_variavel;
                end case;

                select regexp_replace(ws_formula, '.\[[a-zA-Z0-9_]+\]', ws_variavel, 1, 1) into ws_formula from dual;
                
            end loop;

            ws_retorno := replace(replace(ws_formula, chr(13), ''), chr(10), ' ');
        end if; 

        return ws_retorno ; 

    end if;
    
exception when others then
    insert into bi_log_sistema values(sysdate, 'GFORMULA_BROWSER:'||prm_micro_data||', erro: '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getUsuario, 'ERRO');
    commit;
end gformula_browser;



FUNCTION URL_DEFAULT ( prm_parametros	in  long,
					   prm_micro_visao	in  long,
					   prm_agrupadores	in out long,
					   prm_coluna		in out long,
					   prm_rp		    in out long,
					   prm_colup		in out long,
					   prm_comando		in  long,
					   prm_mode		    in out long ) return varchar2 as

	ws_url		long;
	ws_comando	long;
	ws_coluna	long;

	ws_pipe		char;
	ws_texto	long;
	ws_textot	long;
	ws_nm_var	long;
	ws_ctvar	integer;
	ws_restrict     varchar2(200);

	ws_agrupadores	DBMS_SQL.VARCHAR2_TABLE;
	ws_coldef	DBMS_SQL.VARCHAR2_TABLE;
	ws_cupdef	DBMS_SQL.VARCHAR2_TABLE;

    ws_nulo varchar2(1) := null;

begin

    /*Alimenta Agrupadores*/

	ws_texto  := prm_agrupadores;
	ws_textot := ws_texto;
	ws_ctvar  := 0;

	loop
	    if  ws_textot = '%END%' or trim(ws_textot) = ' ' then
	        exit;
	    end if;

	    if  nvl(instr(ws_textot,'|'),0) = 0 then
	        ws_nm_var := ws_textot;
	        ws_textot := '%END%';
	    else
            ws_texto  := '['||ws_textot||']';
            WS_NM_VAR := SUBSTR('['||ws_textot||']', 1 ,INSTR(ws_texto,'|')-1);
            ws_textot := REPLACE(WS_TEXTO, WS_NM_VAR||'|', '');
			
			--garantir limpeza da variavel
			ws_textot := REPLACE(ws_textot, '[', '');
			ws_textot := REPLACE(ws_textot, ']', '');
			ws_texto  := REPLACE(ws_texto, '[', '');
			ws_texto  := REPLACE(ws_texto, ']', '');
			ws_nm_var := REPLACE(ws_nm_var, '[', '');
			ws_nm_var := REPLACE(ws_nm_var, ']', '');
	    end if;

	    select count(*) into ws_restrict
            from column_restriction rst where rst.usuario = gbl.getUsuario and
                                              rst.cd_micro_visao = trim(prm_micro_visao) and
                                              rst.cd_coluna = ws_nm_var and
                                              rst.st_restricao = 'I';

            if  ws_restrict < 1 then
		ws_ctvar := ws_ctvar + 1;
	        ws_agrupadores(ws_ctvar) := ws_nm_var;
            end if;

	end loop;

    /*Alimenta Colunas*/

	ws_texto   := prm_coluna;
	ws_textot  := ws_texto;
	ws_ctvar   := 0;

	loop
	    if  ws_textot = '%END%' or trim(ws_textot) is null then
	        exit;
	    end if;

	    if  nvl(instr(ws_textot,'|'),0) = 0 then
	        ws_nm_var := ws_textot;
	        ws_textot := '%END%';
	    else
		ws_texto  := ws_textot;
		ws_nm_var := substr(ws_textot, 1 ,instr(ws_texto,'|')-1);
		ws_textot := replace(ws_texto, ws_nm_var||'|', '');
	    end if;

	    ws_ctvar := ws_ctvar + 1;
	    ws_coldef(ws_ctvar) := ws_nm_var;

	end loop;

    /* Alimenta Colups */

	ws_texto  := prm_colup;
	ws_textot := ws_texto;
	ws_ctvar  := 0;

	loop
	    if  ws_textot = '%END%' or trim(ws_textot) is null then
	        exit;
	    end if;

	    if  nvl(instr(ws_textot,'|'),0) = 0 then
	        ws_nm_var := ws_textot;
	        ws_textot := '%END%';
	    else
		ws_texto  := ws_textot;
		ws_nm_var := substr(ws_textot, 1 ,instr(ws_texto,'|')-1);
		ws_textot := replace(ws_texto, ws_nm_var||'|', '');
	    end if;

	    ws_ctvar := ws_ctvar + 1;
	    ws_cupdef(ws_ctvar) := ws_nm_var;

	end loop;


    /* Coloca comando ADICIONAR colunas */

	if  nvl(instr(prm_comando,'|'),0) > 0 then
	    ws_comando	:= substr(prm_comando, 1 ,instr(prm_comando,'|')-1);
	    ws_coluna	:= replace(prm_comando, ws_comando||'|', '');
	end if;

	if  ws_comando = 'COLUP' and not fun.setem(prm_colup,ws_coluna) then
	    ws_cupdef(ws_cupdef.COUNT+1) := ws_coluna;
	    ws_comando := 'DELCUP';
	end if;

	if  ws_comando = 'COLDOWN' and not fun.setem(prm_coluna,ws_coluna) then
	    ws_coldef(ws_coldef.COUNT+1) := ws_coluna;
	    ws_comando := 'DELCOL';
	end if;

	if  ws_comando = 'COLGRP' and not fun.setem(prm_agrupadores,ws_coluna) then
	    ws_agrupadores(ws_agrupadores.COUNT+1) := ws_coluna;
	end if;

    /* Recolocando Agrupadores */

	prm_agrupadores := '';
	ws_ctvar  := 0;
	loop
	    ws_ctvar := ws_ctvar + 1;
	    if  ws_ctvar > ws_agrupadores.COUNT then
	        exit;
	    end if;

	    if  ws_comando = 'COLLEFT' and ws_ctvar > 1 and ws_agrupadores.COUNT > 1 and ws_agrupadores(ws_ctvar)=ws_coluna then
	        ws_texto                   := ws_agrupadores(ws_ctvar-1);
	        ws_agrupadores(ws_ctvar-1) := ws_agrupadores(ws_ctvar);
	        ws_agrupadores(ws_ctvar)   := ws_texto;
	        exit;
	    end if;
	    if  ws_comando = 'COLRIGHT' and ws_ctvar < ws_agrupadores.COUNT and ws_agrupadores.COUNT > 1 and ws_agrupadores(ws_ctvar)=ws_coluna then
	        ws_texto                   := ws_agrupadores(ws_ctvar+1);
	        ws_agrupadores(ws_ctvar+1) := ws_agrupadores(ws_ctvar);
	        ws_agrupadores(ws_ctvar)   := ws_texto;
	        exit;
	    end if;
	end loop;
	ws_ctvar	:= 0;
	ws_pipe		:= '';
	loop
	    ws_ctvar := ws_ctvar + 1;
	    if  ws_ctvar > ws_agrupadores.COUNT then
	        exit;
	    end if;
	    if  ws_comando = 'DELETE' and ws_agrupadores(ws_ctvar) = ws_coluna then
	        ws_coluna := ws_coluna;
	    else
		prm_agrupadores := prm_agrupadores||ws_pipe||ws_agrupadores(ws_ctvar);
		ws_pipe := '|';
	    end if;
	end loop;

    /* Recolocando colunas */

	prm_coluna := '';
	ws_ctvar  := 0;
	loop
	    ws_ctvar := ws_ctvar + 1;
	    if  ws_ctvar > ws_coldef.COUNT then
	        exit;
	    end if;

	    if  ws_comando = 'COLLEFT' and ws_ctvar > 1 and ws_coldef.COUNT > 1 and ws_coldef(ws_ctvar)=ws_coluna then
	        ws_texto              := ws_coldef(ws_ctvar-1);
	        ws_coldef(ws_ctvar-1) := ws_coldef(ws_ctvar);
	        ws_coldef(ws_ctvar)   := ws_texto;
	        exit;
	    end if;
	    if  ws_comando = 'COLRIGHT' and ws_ctvar < ws_coldef.COUNT and ws_coldef.COUNT > 1 and ws_coldef(ws_ctvar)=ws_coluna then
	        ws_texto                   := ws_coldef(ws_ctvar+1);
	        ws_coldef(ws_ctvar+1) := ws_coldef(ws_ctvar);
	        ws_coldef(ws_ctvar)   := ws_texto;
	        exit;
	    end if;
	end loop;
	ws_ctvar	:= 0;
	ws_pipe		:= '';
	loop
	    ws_ctvar := ws_ctvar + 1;
	    if  ws_ctvar > ws_coldef.COUNT then
	        exit;
	    end if;
	    if  ws_comando in ('DELETE','DELCUP') and ws_coldef(ws_ctvar) = ws_coluna then
	        ws_coluna := ws_coluna;
	    else
		prm_coluna := prm_coluna||ws_pipe||ws_coldef(ws_ctvar);
		ws_pipe := '|';
	    end if;
	end loop;

    /* Recolocando Colup */

	prm_colup := '';
	ws_ctvar  := 0;
    
	loop
	    ws_ctvar := ws_ctvar + 1;
	    if  ws_ctvar > ws_cupdef.COUNT then
	        exit;
	    end if;

	    if  ws_comando = 'COLLEFT' and ws_ctvar > 1 and ws_cupdef.COUNT > 1 and ws_cupdef(ws_ctvar)=ws_coluna then
	        ws_texto              := ws_cupdef(ws_ctvar-1);
	        ws_cupdef(ws_ctvar-1) := ws_cupdef(ws_ctvar);
	        ws_cupdef(ws_ctvar)   := ws_texto;
	        exit;
	    end if;
	    if  ws_comando = 'COLRIGHT' and ws_ctvar < ws_cupdef.COUNT and ws_cupdef.COUNT > 1 and ws_cupdef(ws_ctvar)=ws_coluna then
	        ws_texto                   := ws_cupdef(ws_ctvar+1);
	        ws_cupdef(ws_ctvar+1) := ws_cupdef(ws_ctvar);
	        ws_cupdef(ws_ctvar)   := ws_texto;
	        exit;
	    end if;
	end loop;

	ws_ctvar	:= 0;
	ws_pipe		:= '';
	loop
	    ws_ctvar := ws_ctvar + 1;
	    if  ws_ctvar > ws_cupdef.COUNT then
	        exit;
	    end if;
	    if  ws_comando in ('DELETE','DELCOL') and ws_cupdef(ws_ctvar) = ws_coluna then
	        ws_coluna := ws_coluna;
	    else
		prm_colup := prm_colup||ws_pipe||ws_cupdef(ws_ctvar);
		ws_pipe := '|';
	    end if;
	end loop;

	if  ws_comando = 'DIRECT' then
	    prm_coluna := ws_coluna;
	end if;

    /* Remonta Query */

	ws_url := ''||nvl(fun.ret_var('OWNER_BI'),'DWU')||'.upquery.main'	||'?prm_parametros='||prm_parametros
					||'&prm_micro_visao='||prm_micro_visao;

	prm_coluna	:= trim(prm_coluna);
	prm_colup	:= trim(prm_colup);
	prm_agrupadores := trim(prm_agrupadores);

	if  prm_comando = 'ROLLOFF' then
	    ws_url := ws_url||'&prm_rp=CUBE';
	    prm_rp := 'CUBE';
	end if;

	if  prm_comando in ('ROLLON','INSPAV') then
	    ws_url := ws_url||'&prm_rp=ROLL';
	    prm_rp := 'ROLL';
	end if;

	if  prm_comando not in('ROLLON','ROLLOFF') then
	    ws_url := ws_url||'&prm_rp='||prm_rp;
	end if;

	if  prm_comando = 'EDMODEON' then
	    ws_url := ws_url||'&prm_mode=ED';
	    prm_mode := 'ED';
	end if;

	if  prm_comando = 'EDMODEOFF' then
	    ws_url := ws_url||'&prm_mode=NO';
	    prm_mode := 'NO';
	end if;

	if  prm_comando not in('EDMODEON','EDMODEOFF','INSPAV') then
	    ws_url := ws_url||'&prm_mode='||prm_mode;
	end if;

	if  prm_coluna <> ' ' then
	    ws_url := ws_url||'&prm_coluna='||prm_coluna;
	end if;

	if  prm_agrupadores <> ' ' then
	    ws_url := ws_url||'&prm_agrupador='||prm_agrupadores;
	end if;

	if  prm_colup <> ' ' then
	    ws_url := ws_url||'&prm_colup='||prm_colup;
	end if;

	return(ws_url);
exception when others then
    htp.p(ws_nulo);
end URL_DEFAULT;


FUNCTION VALOR_PONTO (  prm_parametros   varchar2 default null,
						prm_micro_visao	 varchar2 default null,
						prm_objeto		 varchar2 default null, 
						prm_screen       varchar2 default null,
                        prm_usuario      varchar2 default null ) return char as

	ret_coluna			long;

	ws_query_pivot		long;
 	ws_agrupador		long;
	ws_sql				long;
	ws_parametros		long;
 
	ws_lquery			number;
	ws_cursor			integer;
	ws_linhas			integer;
	ws_counter			integer;

	ws_query_montada	dbms_sql.varchar2a;
    ws_queryoc          varchar2(32000); 
	ws_ncolumns			DBMS_SQL.VARCHAR2_TABLE;
	ws_pvcolumns		DBMS_SQL.VARCHAR2_TABLE;
	ws_mfiltro			DBMS_SQL.VARCHAR2_TABLE;
	ws_cab_cross        varchar2(4000);
    ws_usuario          varchar2(200); 
	ws_admin            varchar2(10); 

    ws_excesso_filtro   exception; 

begin
    if nvl(prm_usuario,'NOUSER') <> 'NOUSER' then 
        ws_usuario := prm_usuario;
    else     
        ws_usuario := gbl.getUsuario;
    end if;  
	ws_admin   := nvl(gbl.getNivel(ws_usuario), 'N');

    ws_parametros := prm_parametros;

	if  SUBSTR(ws_parametros,LENGTH(ws_parametros),1)='|' then
	    ws_parametros := ws_parametros||'1|1';
	end if;

	ws_sql := core.MONTA_QUERY_DIRECT(prm_micro_visao, '', ws_parametros, 'SUMARY', '', ws_query_pivot, ws_query_montada, ws_lquery, ws_ncolumns, ws_pvcolumns, ws_agrupador, ws_mfiltro, prm_objeto, prm_screen => prm_screen, prm_cross => 'N', prm_cab_cross => ws_cab_cross,prm_usuario => ws_usuario);

	if ws_sql like 'Excesso de filtros%' then 
		raise ws_excesso_filtro; 
	end if; 

    -- Monta texto com o SQL 
	ws_queryoc := '';
	ws_counter := 0;
	loop
		ws_counter := ws_counter + 1;
		exit when (ws_counter > ws_query_montada.COUNT); 
		ws_queryoc := ws_queryoc||ws_query_montada(ws_counter);
	end loop;

	-- Grava a ultima query executada para o objeto - Se a função for chamada num SELECT esse insert vai dar erro, mas o erro vai ser ignorado pelo Exception
    if ws_admin = 'A' then  
		begin  
			delete bi_object_query where cd_object = prm_objeto and nm_usuario = ws_usuario;
			insert into bi_object_query (cd_object, nm_usuario, dt_ultima_execucao, query) values (prm_objeto, ws_usuario, sysdate, ws_queryoc ); 
		    commit;	
		exception when others then 
			null;
		end; 
	end if;



	ws_cursor := dbms_sql.open_cursor;

	dbms_sql.parse( c => ws_cursor, statement => ws_query_montada, lb => 1, ub => ws_lquery, lfflg => true, language_flag => dbms_sql.native );

	ws_sql := core.bind_direct(ws_parametros, ws_cursor, 'SUMARY', prm_objeto, prm_micro_visao, prm_screen,prm_usuario => prm_usuario);

	dbms_sql.define_column(ws_cursor, 1, ret_coluna, 40);
	ws_linhas := dbms_sql.execute(ws_cursor);
	ws_linhas := dbms_sql.fetch_rows(ws_cursor);
	dbms_sql.column_value(ws_cursor, 1, ret_coluna);
	dbms_sql.close_cursor(ws_cursor);

	return(ret_coluna);

exception
    when ws_excesso_filtro then 
        return(ws_sql); 
	when others	 then
	   return('0');
end VALOR_PONTO;


-----
-- Atenção: essa function foi copiada para a package ETF, a alteração realizada aqui deve ser replicada para a package ETF 
---------------------------------------------------------------------------------------------------------------------------------
FUNCTION CDESC ( prm_codigo  char  default null,
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
        WS_OWNER:=nvl(fun.ret_var('OWNER_BI'),'DWU');
    ELSE
        WS_OWNER:=nvl(fun.ret_var('OWNER_TABLE_DATA'),'DWU');
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

FUNCTION GETPROP (	prm_objeto  varchar2,
                    prm_prop    varchar2,
                    prm_screen  varchar2 default 'DEFAULT',
                    prm_usuario varchar2 default 'DWU',
                    prm_tipo    varchar2 default null ) return varchar2 RESULT_CACHE RELIES_ON (OBJECT_ATTRIB, OBJECT_PADRAO, BI_OBJECT_PADRAO) as

	ws_prop		varchar2(400);
    ws_valor    varchar2(4000);
    ws_tipo     varchar2(200);
    ws_count    integer;

    cursor c1 is 
        select propriedade, 1 
          from OBJECT_ATTRIB
         where navegador = 'DEFAULT' 
           and cd_object = trim(prm_objeto) 
           and cd_prop   = ws_prop
           and owner     in (prm_usuario, 'DWU') 
           and screen    in (prm_screen, 'DEFAULT') 
      order by decode(screen, prm_screen, 1, 2), decode(owner, prm_usuario, 1, 2);      

begin

    if nvl(prm_tipo, 'N/A') = 'N/A' then
        if prm_objeto = 'DEFAULT' then
            ws_tipo := 'DEFAULT';
        else
            select decode(tp_objeto, 'OBJETO', 'BARRAS', tp_objeto) into ws_tipo from OBJETOS where cd_objeto = trim(prm_objeto) ;
        end if;
    else
        ws_tipo := prm_tipo;
    end if;

    ws_prop := trim(prm_prop);

    ws_valor := null;
    ws_count := 0;
    open  c1; 
    fetch c1 into ws_valor, ws_count;
    close c1; 
    --
    if ws_count > 0 and ws_prop = 'NOME_PIVOT' then
        null;
    else
        if ws_valor is null then 
            select max(vl_default) into ws_valor 
            from OBJECT_PADRAO
            where cd_prop   = ws_prop 
            and ( (tp_objeto = ws_tipo) or ( ws_tipo in (select column_value from table(fun.vpipe(tp_objeto))))  ) ; 
        end if;     
        if ws_valor is null then 
            select max(vl_default) into ws_valor 
            from BI_OBJECT_PADRAO
            where cd_prop   = ws_prop 
            and ( (tp_objeto = ws_tipo) or  (ws_tipo in (select column_value from table(fun.vpipe(tp_objeto))))  )  ; 
        end if;     
    end if;

	return(trim(ws_valor));

	exception
		when others then
			return(ws_valor);
end GETPROP;


function getProps ( prm_objeto  varchar2,
                    prm_tipo    varchar2,
                    prm_prop    varchar2,
                    prm_usuario varchar2 default 'DWU',
                    prm_screen  varchar2 default null ) return arr RESULT_CACHE RELIES_ON (BI_OBJECT_PADRAO) as
    ws_arr arr;
    ws_count number;
    ws_prop  varchar2(4000); 
begin

    ws_arr    := arr();
    ws_count  := 1;

    for a in (select column_value cd_prop from table(fun.vpipe(prm_prop))) 
        loop 
            ws_prop := fun.getprop(prm_objeto, a.cd_prop, prm_screen, prm_usuario, prm_tipo );
            ws_arr.extend;
            ws_arr(ws_count) := ws_prop;
            ws_count := ws_count+1;
        end loop;    

        
    return ws_arr;

end getProps;

/**************************

FUNCTION GETPROP (	prm_objeto  varchar2,
					prm_prop    varchar2,
					prm_screen  varchar2 default 'DEFAULT',
                    prm_usuario varchar2 default 'DWU',
                    prm_tipo    varchar2 default null ) return varchar2 RESULT_CACHE RELIES_ON (OBJECT_ATTRIB, OBJECT_PADRAO, BI_OBJECT_PADRAO) as

	ws_prop		varchar2(400);
    ws_valor    varchar2(4000);
    ws_tipo     varchar2(200);

begin

    if nvl(prm_tipo, 'N/A') = 'N/A' then
        if prm_objeto = 'DEFAULT' then
            ws_tipo := 'DEFAULT';
        else
            select decode(tp_objeto, 'OBJETO', 'BARRAS', tp_objeto) into ws_tipo from OBJETOS where cd_objeto = trim(prm_objeto); --  and cd_usuario = 'DWU';
        end if;
    else
        ws_tipo := prm_tipo;
    end if;

    ws_prop := trim(prm_prop);

    select valor into ws_valor from (
        
        select propriedade AS VALOR
            from OBJECT_ATTRIB
            where owner = prm_usuario and
                navegador = 'DEFAULT' and
                cd_object = trim(prm_objeto) and
                cd_prop   = ws_prop
        
        union all
        
        select vl_default AS VALOR
			from OBJECT_PADRAO
			where cd_prop   = ws_prop and (
                (    tp_objeto = ws_tipo)
				or 
                (    ws_tipo in (select column_value from table(fun.vpipe(tp_objeto)))    )
			) and rownum = 1
        
        union all

        select vl_default AS VALOR
			from BI_OBJECT_PADRAO
			where cd_prop   = ws_prop and (
                ( tp_objeto = ws_tipo )
				or 
                ( ws_tipo in (select column_value from table(fun.vpipe(tp_objeto))))

			) and rownum = 1
    ) where rownum = 1;

	return(trim(ws_valor));

	exception
		when others then
			return(ws_valor);
end GETPROP;



function getProps (  prm_objeto  varchar2,
                     prm_tipo    varchar2,
					 prm_prop    varchar2,
                     prm_usuario varchar2 default 'DWU' ) return arr RESULT_CACHE RELIES_ON (BI_OBJECT_PADRAO) as

    ws_arr arr;
    ws_count number := 1;

    cursor crs_valores is
        select t0.cd_prop, coalesce(t3.propriedade, t2.vl_default, t1.vl_default, t0.vl_default) as valor
        from (select column_value cd_prop, null vl_default from table(fun.vpipe(prm_prop)) ) t0
        left join         
        bi_object_padrao t1     on  t1.cd_prop   = t0.cd_prop
                                and t1.tp_objeto = prm_tipo 
                                and nvl(t1.sufixo, 'N/A') <> 'N/A'
        left join 
        object_padrao    t2     on  t2.cd_prop   = t0.cd_prop 
                                and t2.tp_objeto =  prm_tipo 
        left join 
        object_attrib    t3     on  t3.cd_prop   = t0.cd_prop 
                                and t3.cd_object = prm_objeto 
                                and owner        = prm_usuario 
        order by t0.cd_prop;

    ws_valor crs_valores%rowtype;
    ws_attribs varchar2(4000);

begin

    ws_arr    := arr();

    open crs_valores;
    loop
            fetch crs_valores into ws_valor;
            exit when crs_valores%notfound;
            ws_arr.extend;
            ws_arr(ws_count) := ws_valor.valor;
            ws_count := ws_count+1;

    end loop;
    close crs_valores;

    return ws_arr;

end getProps;
*/


FUNCTION PUT_STYLE (  prm_objeto    varchar2,
					  prm_prop      varchar2,
					  prm_tp_objeto varchar2,
					  prm_value     varchar2 default null ) return varchar2 RESULT_CACHE RELIES_ON (BI_OBJECT_PADRAO) as

	ws_prop		   varchar2(70);
	ws_script	   varchar2(70);
	ws_propriedade varchar2(4000);
    ws_nulo        varchar2(1) := null;

begin

	select BI_OBJECT_PADRAO.script, nvl(OBJECT_ATTRIB.propriedade, BI_OBJECT_PADRAO.vl_default) into ws_script, ws_propriedade
	from   OBJECT_ATTRIB, BI_OBJECT_PADRAO
	where owner = 'DWU' and
	    OBJECT_ATTRIB.navegador = 'DEFAULT' and
		OBJECT_ATTRIB.screen    = 'DEFAULT' and
	    OBJECT_ATTRIB.cd_object = TRIM(prm_objeto) and
	    OBJECT_ATTRIB.cd_prop   = TRIM(prm_prop) and
        OBJECT_ATTRIB.cd_prop   = trim(BI_OBJECT_PADRAO.cd_prop) and
        decode(prm_tp_objeto, 'GRAFICO', 'BARRAS', prm_tp_objeto) = decode(trim(BI_OBJECT_PADRAO.tp_objeto), 'GRAFICO', 'BARRAS', trim(BI_OBJECT_PADRAO.tp_objeto)) AND ROWNUM = 1;

	begin
		select html into ws_script
		from script_to_html where script=trim(ws_script);
	exception
		when others then
		    ws_script := ws_script;
	end;

	if  nvl(trim(ws_script),'%*%') <> '%*%' and nvl(trim(ws_propriedade),'%*%') <> '%*%' then
        if(prm_value = 'value') then
		    return(rtrim(ws_propriedade));
		else
		    return(trim(ws_script)||':'||rtrim(ws_propriedade)||'; ');
		end if;
	else
	    return(ws_nulo);
	end if;

	exception
		when others then
		    RETURN(ws_nulo);
end PUT_STYLE;


FUNCTION RET_SINAL (  prm_objeto    varchar2,
					  prm_coluna    varchar2,
					  prm_conteudo  varchar2 ) return varchar2 as

	ws_prop		varchar2(70);
	ws_sinal	varchar2(70);
	ws_propriedade  varchar2(70);
	ws_tipo		varchar2(1);
	ws_fx01		varchar2(30);
	ws_fx02		varchar2(30);
	ws_fx03		varchar2(30);
	ws_fx04		varchar2(30);
	ws_fx05		varchar2(30);
    ws_usuario  varchar2(80);

begin

    ws_usuario := gbl.getUsuario;
   
    begin
	select nvl(cd_sinal,'%$%') into ws_sinal
	from   SINAL_COLUNA
	where  (cd_usuario = ws_usuario or cd_usuario in (select cd_group from gusers_itens where cd_usuario = ws_usuario) or cd_usuario = 'DWU') and
		cd_objeto = prm_objeto and
		cd_coluna = prm_coluna;
    exception
	when others then
	     RETURN('');
    end;

	if  ws_sinal='%$%' then
	    return('');
	end if;

    begin
	select nvl(fx_01,'%$%'), fx_02, fx_03, fx_04, fx_05, tp_sinal into ws_fx01, ws_fx02, ws_fx03, ws_fx04, ws_fx05, ws_tipo
	from   SINAIS
	where   cd_sinal=ws_sinal;
    exception
	when others then
	     RETURN(' ');
    end;

	if  ws_fx01 = '%$%' then
	    return('');
	end if;

	if  to_number(prm_conteudo) <= to_number(ws_fx01) then
	    return(htf.img(fun.r_gif('ind'||ws_tipo||'_1','PNG')));
	end if;

	if  to_number(prm_conteudo) <= to_number(ws_fx02) then
	    return(htf.img(fun.r_gif('ind'||ws_tipo||'_2','PNG')));
	end if;

	if  to_number(prm_conteudo) <= to_number(ws_fx03) then
	    return(htf.img(fun.r_gif('ind'||ws_tipo||'_3','PNG')));
	end if;

	if  to_number(prm_conteudo) <= to_number(ws_fx04) then
	    return(htf.img(fun.r_gif('ind'||ws_tipo||'_4','PNG')));
	end if;

	return(htf.img(fun.r_gif('ind'||ws_tipo||'_5','PNG')));

	exception
		when others then
		    RETURN('');

end RET_SINAL;


FUNCTION PUT_PAR ( prm_objeto     varchar2,
                   prm_prop       varchar2,
                   prm_tp_objeto  varchar2,
                   prm_owner      varchar2 default null ) return varchar2 as

 ws_prop         varchar2(70);
 ws_script       varchar2(70);
 ws_propriedade  varchar2(4000);
 ws_count        number;
 ws_usuario      varchar2(70);
 ws_count_dwu    number;
 ws_nulo         varchar2(1) := null;

begin

    if prm_owner is null then
        ws_usuario := gbl.getUsuario;
    else
		ws_usuario := prm_owner;
	end if;
	
	select count(*) into ws_count_dwu
	from OBJECT_ATTRIB
	where owner = 'DWU' and
	OBJECT_ATTRIB.navegador = 'DEFAULT' and
	OBJECT_ATTRIB.cd_object = TRIM(prm_objeto) and
	OBJECT_ATTRIB.cd_prop   = TRIM(prm_prop);
		

	if ws_count_dwu > 0 then
		
		select count(*) into ws_count_dwu
		from OBJECT_ATTRIB , OBJECT_PADRAO
		where owner = 'DWU' and
			OBJECT_ATTRIB.navegador = 'DEFAULT' and
			OBJECT_ATTRIB.cd_object = TRIM(prm_objeto) and
			OBJECT_ATTRIB.cd_prop   = TRIM(prm_prop) and
			OBJECT_ATTRIB.cd_prop   = trim(OBJECT_PADRAO.cd_prop) and
			prm_tp_objeto           = trim(OBJECT_PADRAO.tp_objeto);
			
		if ws_count_dwu > 0 then
		
			select OBJECT_PADRAO.script, propriedade into ws_script, ws_propriedade
			from OBJECT_ATTRIB , OBJECT_PADRAO
			where owner = 'DWU' and
				OBJECT_ATTRIB.navegador = 'DEFAULT' and
				OBJECT_ATTRIB.cd_object = TRIM(prm_objeto) and
				OBJECT_ATTRIB.cd_prop   = TRIM(prm_prop) and
				OBJECT_ATTRIB.cd_prop   = trim(OBJECT_PADRAO.cd_prop) and
				prm_tp_objeto           = trim(OBJECT_PADRAO.tp_objeto);
		else
		
		    select BI_OBJECT_PADRAO.script, propriedade into ws_script, ws_propriedade
			from OBJECT_ATTRIB , BI_OBJECT_PADRAO
			where owner = 'DWU' and
				OBJECT_ATTRIB.navegador = 'DEFAULT' and
				OBJECT_ATTRIB.cd_object = TRIM(prm_objeto) and
				OBJECT_ATTRIB.cd_prop   = TRIM(prm_prop) and
				OBJECT_ATTRIB.cd_prop   = trim(BI_OBJECT_PADRAO.cd_prop) and
				trim(BI_OBJECT_PADRAO.tp_objeto) LIKE '%'||prm_tp_objeto||'%';
		
		end if;
	else
	    select count(*) into ws_count
		from OBJECT_ATTRIB
		where owner = ws_usuario and
			OBJECT_ATTRIB.navegador = 'DEFAULT' and
			OBJECT_ATTRIB.cd_object = TRIM(prm_objeto) and
			OBJECT_ATTRIB.cd_prop   = TRIM(prm_prop);
	
		if  ws_count > 0 then
			select OBJECT_PADRAO.script, propriedade into ws_script, ws_propriedade
			from OBJECT_ATTRIB , OBJECT_PADRAO
			where owner = ws_usuario and
				OBJECT_ATTRIB.navegador = 'DEFAULT' and
				OBJECT_ATTRIB.cd_object = TRIM(prm_objeto) and
				OBJECT_ATTRIB.cd_prop   = TRIM(prm_prop) and
				OBJECT_ATTRIB.cd_prop   = trim(OBJECT_PADRAO.cd_prop) and
				trim(OBJECT_PADRAO.tp_objeto) LIKE '%'||prm_tp_objeto||'%';
		else
			select script, vl_default into ws_script, ws_propriedade
			from OBJECT_PADRAO where
			cd_prop = prm_prop and
			tp_objeto = prm_tp_objeto;
		end if;
	end if;

 if  nvl(trim(ws_script),'%*%') <> '%*%' and nvl(trim(ws_propriedade),'%*%') <> '%*%' then
     return(rtrim(ws_propriedade));
 else
     return(ws_nulo);
 end if;

 exception
  when others then
       RETURN(ws_nulo);

end PUT_PAR;


FUNCTION COL_NAME (	prm_cd_coluna   varchar2 default null,
					prm_micro_visao varchar2,
					prm_condicao	varchar2 default '',
					prm_conteudo	varchar2,
					prm_color       varchar2 default '#000000',
					prm_title       varchar2 default 'Filtro do drill',
					prm_repeat      boolean  default false,
					prm_agrupado    varchar2 default null ) return varchar as

	ws_count	number;
	ws_ligacao	varchar2(100);
	ws_retorno	varchar2(3000) := '';
	ws_coluna   varchar2(3000);
    ws_usuario  varchar2(80);
	ws_fundo    varchar2(40);
	ws_fonte    varchar2(40);
	ws_tipo     varchar2(40);
    ws_padrao   varchar2(200);

begin

    ws_padrao := gbl.getLang;
    
	begin
		select nvl((fun.utranslate('NM_ROTULO', prm_micro_visao, nm_rotulo, ws_padrao)), initcap(prm_cd_coluna)), cd_ligacao into ws_coluna, ws_ligacao
		from MICRO_COLUNA
		WHERE trim(CD_MICRO_VISAO)=trim(PRM_MICRO_VISAO) and trim(CD_COLUNA)=trim(PRM_CD_COLUNA);
	exception
		when others then
			ws_coluna := '';
			ws_ligacao := '';
	end;
    
	if length(trim(prm_conteudo)) > 0 then
		
        if prm_repeat = false then
			if prm_color <> 'destaque' then
				ws_retorno := '<li class="desc" title="'||prm_title||'">'||ws_coluna||' '||prm_condicao||'</li>';
			else
				ws_retorno := '<li class="desc" title="'||fun.lang(prm_color)||'">'||ws_coluna||' '||prm_condicao||' '||prm_conteudo||'</li>';
			end if;
		end if;

		if prm_color <> 'destaque' then
			if  ws_ligacao <> 'SEM' then
				ws_retorno := ws_retorno||' <li class="'||prm_color||' valor" title="'||trim(prm_cd_coluna)||': '||prm_conteudo||'">'||fun.cdesc(prm_conteudo,ws_ligacao)||' '||prm_agrupado||'</li>';
			else
				ws_retorno := ws_retorno||' <li class="'||prm_color||' valor" title="'||trim(prm_cd_coluna)||'">'||prm_conteudo||' '||prm_agrupado||'</li>';
			end if;
		else
            ws_usuario := gbl.getUsuario;
			select cor_fundo, cor_fonte, tipo_destaque into ws_fundo, ws_fonte, ws_tipo 
              from destaque t1 
             where cd_destaque = prm_title 
               and (t1.cd_usuario in (ws_usuario, 'DWU') or t1.cd_usuario in (select cd_group from gusers_itens t2 where t2.cd_usuario = ws_usuario)) 
               and cd_coluna = prm_cd_coluna 
               and rownum = 1;
			--ws_retorno := ws_retorno||' <li class="valor" title="'||fun.lang('Destaque')||'">VALOR: </li>';
			ws_retorno := ws_retorno||' <li class="valor" title="'||fun.lang('Destaque')||'">';
			ws_retorno := ws_retorno||' <span style="background-color: '||ws_fonte||';">FONTE</span><span style="background-color: '||ws_fundo||';">FUNDO</li>';
		end if;

	end if;

	return(ws_retorno);

end COL_NAME;

FUNCTION check_user ( prm_usuario varchar2 default user ) return boolean as

	ws_count	number := 0;

begin

	select count(*) into ws_count
	from USUARIOS
	WHERE usu_nome = prm_usuario and status='A';

	if  ws_count > 0 then
	    return(true);
	else
	    return(false);
	end if;

end check_user;

FUNCTION check_app_permission (prm_usuario varchar2 default user) return boolean AS

    ws_count number := 0;

begin
    select count(*) into ws_count
    from usuarios
    where usu_nome = prm_usuario and status='A' and app='S';

    if  ws_count > 0 then
	    return(true);
	else
	    return(false);
	end if;

end check_app_permission;

FUNCTION VCALC (  prm_cd_coluna   varchar2,
				  prm_micro_visao varchar2 ) return boolean as

	ws_tipo		char(1);

begin

	begin
		select nvl(TIPO,'A') into ws_tipo
		from MICRO_COLUNA
		WHERE trim(CD_MICRO_VISAO)=trim(PRM_MICRO_VISAO) and trim(CD_COLUNA)=trim(PRM_CD_COLUNA);
	exception
	     when others then
	        return(false);
	end;

	if  ws_tipo='C' then
	    return(true);
	else
	    return(false);
	end if;

end VCALC;


FUNCTION XCALC (  prm_cd_coluna    varchar2, 
                  prm_micro_visao  varchar2, 
                  prm_screen       varchar2 ) return varchar2 as

 ws_formula    varchar2(8000);
 ws_agrupador  varchar2(10);
 ws_flex       varchar2(80);
begin

    begin
    
		select nvl(FORMULA,' '), st_agrupador, flexcol into ws_formula, ws_agrupador, ws_flex
		from MICRO_COLUNA
		WHERE trim(CD_MICRO_VISAO)=trim(PRM_MICRO_VISAO) and trim(CD_COLUNA)=trim(PRM_CD_COLUNA);
    exception
        when others then
            ws_formula := ' ';
    end;

    if ws_agrupador = 'SEM' and nvl(ws_flex, 'N/A') = 'N/A' then
        ws_formula := fun.subpar(ws_formula, prm_screen);
    else
        ws_formula := fun.gformula2(prm_micro_visao, prm_cd_coluna, prm_screen);
    end if;

 return(ws_formula);

end XCALC;

FUNCTION XEXEC ( ws_content  varchar2 default null, 
	             prm_screen  varchar2 default null, 
	             prm_atual   varchar2 default null, 
	             prm_ant     varchar2 default null ) return varchar2 as

 ws_tcont  varchar2(3000);
 ws_calculado  varchar2(4000);

 ws_cursor integer;
 ws_linhas integer;
 ws_sql  varchar2(2000);
 ws_nulo varchar2(1) := null;

begin

 ws_tcont := ws_content;

 if  UPPER(substr(ws_tcont,1,5)) = 'EXEC=' then
     WS_TCONT := REPLACE(UPPER(WS_TCONT), 'EXEC=','');
     WS_TCONT := REPLACE(WS_TCONT, '$[SCREEN]', fun.nomeObjeto(prm_screen));
     WS_TCONT := REPLACE(WS_TCONT, '$[BEFORE]', NVL(PRM_ANT, 0));
     WS_TCONT := REPLACE(WS_TCONT, '$[SELF]', NVL(PRM_ATUAL, 0));
     WS_TCONT := REPLACE(WS_TCONT, '$[CONCAT]','||');
	 WS_TCONT := REPLACE(WS_TCONT, '$[NOW]', trim(to_char(sysdate, 'DD/MM/YYYY HH24:MI')));
	 WS_TCONT := REPLACE(WS_TCONT, '$[DOWNLOAD]', ''||nvl(fun.ret_var('OWNER_BI'),'DWU')||'.fcl.download?arquivo=');
     ws_tcont := fun.xformula(ws_tcont, prm_screen,'S');
     ws_sql := 'select '||trim(ws_tcont)||' from dual';
     ws_cursor := dbms_sql.open_cursor;
     dbms_sql.parse(ws_cursor, ws_sql, DBMS_SQL.NATIVE);
     dbms_sql.define_column(ws_cursor, 1, ws_calculado, 4000); -- estava 600, cortando textos longos do cliente Nogueira

     ws_linhas := dbms_sql.execute(ws_cursor);
     ws_linhas := dbms_sql.fetch_rows(ws_cursor);

     dbms_sql.column_value(ws_cursor, 1, ws_calculado);
     dbms_sql.close_cursor(ws_cursor);
     ws_tcont := ws_calculado;
 end if;

 return(ws_tcont);
 
 exception when others then
    return(ws_tcont);
end XEXEC;


FUNCTION SETEM (  prm_str1 varchar2,
				  prm_str2 varchar2 ) return boolean as
						
	ws_count number;
begin

   select count(*) into ws_count from table((fun.vpipe(prm_str1))) where prm_str2 = column_value;

	if  ws_count > 0 then
	    return (true);
	else
	    return (false);
	end if;

end SETEM;


function isnumber ( prm_valor varchar2 default null ) return boolean is
    ws_valor number;
begin
    ws_valor := to_number(prm_valor);
    return true;
exception when others then
    return false;
end;

function isnumber_sem_decimal (prm_valor varchar2 default null ) return boolean is
    ws_valor number;
begin
    ws_valor := to_number(prm_valor);
    return trunc(ws_valor) = ws_valor;
exception when others then
    return false;
end;

FUNCTION IFMASCARA ( str1 in varchar2,
                     cmascara varchar2,
                     prm_cd_micro_visao varchar2 default '$[no_mv]',
                     prm_cd_coluna varchar2 default '$[no_co]',
                     prm_objeto varchar2 default '$[no_ob]',
                     prm_tipo varchar2 default 'micro_coluna',
                     prm_formula varchar2 default null,
                     prm_screen  varchar2 default null,
                     prm_usuario varchar2 default null ) return varchar2 as

    Ws_Calculado     Varchar2(2600);

    Ws_Cursor          Integer;
    Ws_Linhas          Integer;
    ws_sql             varchar2(2600);

    Ws_Saida           Varchar2(800);
    Ws_Objeto          Varchar2(300);
    Ws_Coluna          Varchar2(300);
    ws_cmascara        varchar2(300);
    ws_cd_coluna       varchar2(300);
    ws_texto           varchar2(4000);
    ws_nm_var          varchar2(300);
    ws_flexcol         varchar2(300);
    ws_mascara_default varchar2(300);
    ws_img_tam         varchar2(300);
    ws_count           number;
    ws_usuario         varchar2(80);
    ws_script          varchar2(800);
    ws_cdesc_mascara   varchar2(500);

begin

    if nvl(prm_usuario, 'N/A') = 'N/A' then
        ws_usuario := gbl.getUsuario;
    else
        ws_usuario := prm_usuario;
    end if;
	 
	ws_cd_coluna := prm_cd_coluna;
    ws_cmascara  := cmascara;
    ws_texto     := prm_formula;
    ws_mascara_default := '';
     
    begin
        select flexcol into ws_flexcol
        from micro_coluna where 
        cd_micro_visao = trim(prm_cd_micro_visao) and
        cd_coluna      = trim(ws_cd_coluna);
    exception when others then
        ws_flexcol := '';
    end;
    
    if nvl(trim(ws_flexcol), 'N/A') <> 'N/A' then

        select count(*) into ws_count from parametro_usuario where cd_padrao = ws_flexcol and cd_usuario = ws_usuario;

        if ws_count <> 0 then
	        select  nm_mascara into ws_cmascara
	        from MICRO_COLUNA
	        where   cd_micro_visao = prm_cd_micro_visao and
	        upper(trim(cd_coluna)) = (select upper(trim(conteudo)) from parametro_usuario where cd_padrao = ws_flexcol and cd_usuario = ws_usuario);
	    else
            select  nm_mascara into ws_cmascara
	        from MICRO_COLUNA
	        where   cd_micro_visao = prm_cd_micro_visao and
	        upper(trim(cd_coluna)) = (select upper(trim(conteudo)) from parametro_usuario where cd_padrao = ws_flexcol and cd_usuario = 'DWU');
        end if;

    end if;

    if  ws_cd_coluna <> '$[no_co]' and prm_cd_micro_visao <> '$[no_mv]' then
        begin
            if prm_tipo = 'micro_coluna' then
                select nvl(ST_RESTRICAO,'NO') into ws_coluna
                from   COLUMN_RESTRICTION
                where  USUARIO        = ws_usuario and
                    CD_MICRO_VISAO = prm_cd_micro_visao and
                    CD_COLUNA      = ws_cd_coluna;
            else
                select nvl(ST_RESTRICAO,'NO') into ws_coluna
                from   COLUMN_RESTRICTION
                where  USUARIO        = ws_usuario and
                    CD_MICRO_VISAO = prm_cd_micro_visao and
                    CD_COLUNA      = ws_cd_coluna;
            end if;
        exception
              when others then ws_coluna := 'NO';
         end;
    else
          ws_coluna := 'NO';
    end if;

    if  prm_objeto <> '$[no_ob]' then
          begin
              select nvl(st_restricao,'NO') into ws_objeto
              from   object_restriction
              where  USUARIO        = ws_usuario and
                     CD_OBJETO      = prm_objeto;
          exception
              when others then ws_objeto := 'NO';
          end;
    else
          ws_objeto := 'NO';
    end if;

      if  ws_objeto = 'NO' and ws_coluna = 'NO' then
          if  ws_cmascara = 'SEM' then
              return (str1);
          else
              ws_cdesc_mascara := fun.cdesc(ws_cmascara,'MASCARAS');   
              if  substr(ws_cdesc_mascara,1,6)='IMAGEM' then 
                begin
                    --Se for mobile não aplica  id e o evento do click para abrir imagem com tamanho maior. 26/12/2022
                    if (instr(owa_util.get_cgi_env('HTTP_USER_AGENT'), 'Android') <> 0) or (instr(owa_util.get_cgi_env('HTTP_USER_AGENT'), 'iPhone') <> 0) then
                        ws_script:='';
                    else
                        ws_script:='id="ampliar_img" onclick="ampliar_img('''||prm_objeto||''','''||trim(str1)||''');"';
                    end if;
                exception
                  when others then
                    ws_script:='';
                end;
                   
                    ws_img_tam := ws_cdesc_mascara; 
                    ws_img_tam := substr(ws_img_tam, instr(ws_img_tam,'[')+1,999);  -- copia depois da [  
                    ws_img_tam := substr(ws_img_tam, 1, instr(ws_img_tam,']')-1);   -- copia até a ]  
                    ws_saida :=  '<img '||ws_script||'  src="'||trim(str1)||'" alt="Imagem" style="width: '||ws_img_tam||'px;" />';
                    return(ws_saida);                    
              elsif  substr(ws_cdesc_mascara,1,4)='DRE=' then
                  begin
                       ws_saida := to_number(str1);
                       ws_saida := fun.apply_dre_masc(substr(ws_cdesc_mascara,5,length(ws_cmascara)), str1);
                  exception
                       when others then
                            ws_saida := str1;
                  end;
                  return(ws_saida);
              elsif  substr(ws_cdesc_mascara,1,4)='LINK' Then 
                    if trim(upper(str1)) not like 'HTTP%' then 
						ws_saida := 'http://'||str1;
					end if;              
                    if str1 is not null then 
                        ws_saida := '<a class="link-data" onclick="if(('''||str1||''').length > 0){ event.stopPropagation(); window.open('''||str1||'''); }">'||str1||'</a>';
                    end if;
                    return(ws_saida);
              else
                  if  substr(ws_cdesc_mascara,1,5)='EXEC=' then
                      begin
                         ws_saida := replace(ws_cdesc_mascara,'EXEC=','');
                         Ws_Saida := Replace(Ws_Saida,'$[SELF]',Chr(39)||Str1||Chr(39));

                        Ws_Sql := 'select '||Rtrim(ws_saida)||' from dual';
                        Ws_Cursor := Dbms_Sql.Open_Cursor;
                        Dbms_Sql.Parse(Ws_Cursor, Ws_Sql, Dbms_Sql.Native);
                        dbms_sql.define_column(ws_cursor, 1, ws_calculado, 400);

                        Ws_Linhas := Dbms_Sql.Execute(Ws_Cursor);
                        ws_linhas := dbms_sql.fetch_rows(ws_cursor);

                        Dbms_Sql.Column_Value(Ws_Cursor, 1, Ws_Calculado);
                        Dbms_Sql.Close_Cursor(Ws_Cursor);
                        Ws_Saida := Ws_Calculado;

                      exception
                         when others then
                              ws_saida := '?MASC?';
                      end;
                      return (nvl(ws_saida, '&nbsp;'));
                  else

                    if ws_cdesc_mascara = '-' then
                       return('');
                    end if;

                    begin
                    --trecho comentado após mudanças na forma como a data é tratada na chamda da consulta
                        -- ws_saida := to_date(trim(str1));--pq faz isso???
                        -- if instr(ws_cdesc_mascara, 'HH24:MI') > 0 then
						    -- ws_saida := str1; 
                        -- else
					        ws_saida := to_char(to_date(trim(str1),'DD/MM/RRRR HH24:MI:SS'),ws_cdesc_mascara,'NLS_DATE_LANGUAGE='||fun.ret_var('LANG_DATE'));
					    -- end if;
					exception when others then
                            if upper(substr(cmascara,1,5))='(ABS)' then
                                ws_saida := to_char(abs(to_number(trim(str1))),ws_cdesc_mascara,'NLS_NUMERIC_CHARACTERS = '||CHR(39)||fun.ret_var('POINT')||CHR(39));
                            else
                                ws_saida := to_char(to_number(trim(str1)),ws_cdesc_mascara,'NLS_NUMERIC_CHARACTERS = '||CHR(39)||fun.ret_var('POINT')||CHR(39));
                            end if;
                    end;
                    return (ws_saida);
                  end if;
              end if;
          end if;
      else
          return('...');
      end if;

exception
    when others then
	RETURN(STR1);
End Ifmascara;

function mascaraJs ( prm_mascara varchar2, prm_tipo varchar2 default 'texto' ) return varchar2 as 

    ws_mascara varchar2(80);

begin

    case prm_tipo
        when 'texto' then
            ws_mascara := prm_mascara;
        when 'number' then
            ws_mascara := replace(prm_mascara, '0', '9');
            ws_mascara := replace(ws_mascara, 'G', '.');
            ws_mascara := replace(ws_mascara, 'D', ',');
        else
            ws_mascara := prm_mascara;
    end case;

    return ws_mascara;

end mascaraJs;

function um ( prm_coluna  varchar2 default '$[no_co]',
              prm_visao   varchar2 default '$[no_ob]',
              prm_content varchar2 default null,
              prm_um      varchar2 default null ) return varchar2 as
	  
	ws_unidade varchar2(20);
    ws_nulo    varchar2(1) := null; 

begin
    
	if length(trim(prm_content)) > 0 then
		
		if nvl(prm_um, 'N/A') = 'N/A' then
            select nm_unidade 
            into ws_unidade 
            from micro_coluna
            where cd_micro_visao = prm_visao and 
            cd_coluna = prm_coluna;
        else
            ws_unidade := prm_um;
        end if;
		
		if instr(ws_unidade, '>') = 1 then
			return prm_content||' '||trim(replace(ws_unidade, '>', ''));
		elsif instr(ws_unidade, '<') = 1 then
			return trim(replace(ws_unidade, '<', ''))||' '||prm_content;
		else
			return prm_content;
		end if;
		
	else
	
	    return ws_nulo;
		
	end if;
     
exception
    when others then
        return ws_nulo;
End um;


FUNCTION IFNOTNULL ( str1 in varchar2, str2 in varchar2 ) return varchar2 is

begin
   if (str1 is NULL)
     then return (NULL);
     else return (str2);
   end if;
end IFNOTNULL;


FUNCTION VERIFICA_DATA ( chk_data varchar default null ) return varchar2 as

	ws_data date;
	ws_erro exception;

begin
	if  chk_data = ' ' or nvl(chk_data,' ') = ' ' then
	    raise ws_erro;
	end if;

	ws_data := to_Date(chk_data,'dd/mm/yyyy');
	return (to_char(ws_data,'dd/mm/yyyy'));
exception
	when ws_erro then
		return ('Invalida');
	when others then
		return ('Invalida');

end VERIFICA_DATA;


FUNCTION R_GIF ( prm_gif_nome  varchar2 default null,
                 prm_type      varchar2 default 'GIF',
                 prm_location  varchar2 default 'LOCAL' ) return varchar2 as

        ws_url      varchar2(2000);

begin
        if  prm_location = 'LOCAL' then
            ws_url := ''||nvl(fun.ret_var('OWNER_BI'),'DWU')||'.fcl.download?arquivo='||prm_gif_nome||fcl.fpdata(prm_type,'GOO','','.'||lower(prm_type));
        else
            if  upper(prm_gif_nome) = 'PATH' then
                ws_url := fun.ret_var('URL_GIFS');
            else
                ws_url := fun.RET_VAR('URL_GIFS')||rtrim(prm_gif_nome)||fcl.fpdata(prm_type,'GOO','','.'||lower(prm_type));
            end if;
        end if;
 
 return ws_url;
 
 htp.p('');

end R_GIF;

FUNCTION SUBPAR ( prm_texto        varchar2 default null, 
                  prm_screen       varchar2 default null, 
                  prm_desc         varchar2 default 'Y',
                  prm_usuario      varchar2 default null,
                  prm_param_filtro varchar2 default null,
                  prm_valida       varchar2 default 'N' ) return varchar2 as

    ws_texto                varchar2(4000);
    ws_funcao               varchar2(4000);
    ws_funcao_aux           varchar2(4000);
    ws_var                  varchar2(4000);
    ws_agrupador            varchar2(20);
    ws_tipo                 varchar2(1);
    ws_tipo2                varchar2(1);
    ws_formatar             varchar2(1);
    ws_usuario              varchar2(80);
    ws_rotulo_destaque      varchar2(500);

    ws_count_aux            number;
    ws_count                number;

begin

    ws_count := 0;
    ws_texto := prm_texto||'#FIM';
    ws_funcao := '';

    loop
        ws_count := ws_count + 1;
        if  substr(ws_texto,ws_count,4) = '#FIM' then
            exit;
        end if;

        if  substr(ws_texto,ws_count,1) in ('$', '@', '#') and 
            not (substr(ws_texto,ws_count,1) = '#' and substr(ws_texto,ws_count,1) = '@' ) and    
            instr(prm_texto, '$') <> length(trim(prm_texto)) then
            ws_tipo     := substr(ws_texto,ws_count,1);
            ws_tipo2    := substr(ws_texto,ws_count+1,1);
            ws_var      := '';
            ws_formatar := 'N';
            if ws_tipo2 = '#' then 
                ws_formatar := 'S';
                ws_count    := ws_count + 2;
            else 
                ws_count    := ws_count + 1;
            end if;    
            
            if  substr(ws_texto,ws_count,1)<>'[' then
                ws_funcao := ws_funcao||substr(ws_texto,(ws_count-1),1);
                ws_funcao := ws_funcao||substr(ws_texto, ws_count,   1);
            else
                loop
                ws_count  := ws_count + 1;
                if  substr(ws_texto,ws_count,1)=']' then

                    if  ws_tipo = '$' then
                        ws_funcao_aux := fun.gparametro(upper(ws_var), prm_desc, prm_screen, prm_valida => prm_valida); 
                        ws_funcao     := ws_funcao||ws_funcao_aux;
                        -- Verifica se é um gparametro válido                         
                        if prm_valida = 'S' then 
                            if nvl(ws_funcao_aux,'NA') like '%#ERROI#%' then                         
                                return ws_funcao; 
                            elsif ws_funcao_aux is null then 
                                return '#ERROI#Parametro/filtro '||upper(ws_var)||' n&atilde;o possui valor para a tela ativa#ERROF#'; 
                            end if;      
                        end if; 
                        --
                        exit;
                    end if;

                    if  ws_tipo = '@' then
                        -- Valida a existência do objeto informado na fórmula 
                        if prm_valida = 'S' then 
                            select count(*) into ws_count_aux
                              from objetos 
	                         where cd_objeto = trim(replace(replace(upper(ws_var), '@[', ''), ']', '')); 
                            if ws_count_aux = 0 then    
                                return '#ERROI#Objeto '||upper(ws_var)||' n&atilde;o existe no sistema#ERROF#'; 
                            end if;     
                        end if;  
                        --
                        ws_funcao := ws_funcao||fun.gvalor(upper(ws_var), prm_screen, prm_usuario, prm_formatar => ws_formatar, prm_param_filtro => prm_param_filtro);
                        exit;
                    end if;

                    if  ws_tipo = '#' then
                        -- Valida a existencia da var_conteudo 
                        if prm_valida = 'S' then 
                            select count(*) into ws_count_aux
                              from var_conteudo
	                         where usuario  in ('DWU', gbl.getUsuario) 
	                           and variavel = replace(replace(upper(ws_var), '#[', ''), ']', '');
                            if ws_count_aux = 0 then    
                                return '#ERROI#Var&iacute;avel de sistema '||upper(ws_var)||' n&atilde;o existe#ERROF#'; 
                            end if;     
                        end if;  
                        --
                        ws_funcao := ws_funcao||fun.ret_var(upper(ws_var), user);
                        exit;
                    end if;

                end if;
                ws_var := ws_var||substr(ws_texto,ws_count,1);
                end loop;
            end if;
        else
            ws_funcao := ws_funcao||substr(ws_texto,ws_count,1);
        end if;

    end loop;

    if upper(substr(ws_funcao,1,5)) = 'EXEC=' THEN
        ws_funcao := fun.xexec(ws_funcao, prm_screen); --problema
    end if;

    if upper(substr(ws_funcao,1,4)) = 'AUX=' THEN

        begin
            --GARANTE QUE CASO O DESTAQUE POSSUI O MESMO CONTEÚDO TRAGA 1 NOME DE ROTULO JA QUE O OBJETO E VISÃO SÃO OS MESMO.
            SELECT DISTINCT(NM_ROTULO) INTO WS_ROTULO_DESTAQUE 
              FROM PONTO_AVALIACAO T1,DESTAQUE T2, MICRO_COLUNA T3  
             WHERE T1.CD_PONTO          = T2.CD_OBJETO 
               AND T2.CONTEUDO          = WS_FUNCAO 
               AND T3.CD_COLUNA         = REPLACE(WS_FUNCAO,'AUX=','')
               AND T1.CD_MICRO_VISAO    = T3.CD_MICRO_VISAO;
            
            WS_FUNCAO := 'AUX='||WS_ROTULO_DESTAQUE;

        exception
            when others then
                insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - SUBPAR AUX', user, 'ERRO');
                commit;
                return(WS_FUNCAO);
        end;

    end if;

    return(ws_funcao);

exception when others then
    insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - SUBPAR', user, 'ERRO');
    commit;
end SUBPAR;


FUNCTION CALL_DRILL ( prm_drill varchar default 'N', 
					  prm_parametros long,
					  prm_screen long,
					  prm_objid char default null,
					  prm_micro_visao char default null,
					  prm_coluna char default null,
					  prm_selected number default 1,
					  prm_track varchar2 default null, 
					  prm_objeton varchar2 default null ) return clob as
					   
	cursor crs_xgoto(prm_usuario varchar2) is
		select cd_objeto_go, (select tp_objeto from objetos where cd_objeto = cd_objeto_go) as tipo, (select nm_objeto from objetos where cd_objeto = cd_objeto_go) as nome
		from GOTO_OBJETO where cd_objeto = prm_objid and
		    fun.CHECK_PERMISSAO(cd_objeto_go) = 'S' and cd_objeto_go not in (select column_value from table(fun.vpipe(prm_track)) where column_value is not null) 
			and cd_objeto_go not in ( select cd_objeto from OBJECT_RESTRICTION where USUARIO = prm_usuario )
		order by tipo, nome;

	ws_xgoto crs_xgoto%rowtype;
	
    cursor crs_filtros_objeto is
        select trim(cd_coluna)||'|'||decode(rtrim(condicao),'IGUAL','$[IGUAL]','DIFERENTE','$[DIFERENTE]','MAIOR','$[MAIOR]','MENOR','$[MENOR]','MAIOROUIGUAL','$[MAIOROUIGUAL]','MENOROUIGUAL','$[MENOROUIGUAL]','LIKE','$[LIKE]','NOTLIKE','$[NOTLIKE]','$[IGUAL]')||rtrim(conteudo) as coluna
        from FILTROS
        where trim(micro_visao) = trim(prm_micro_visao) and
            trim(cd_objeto) in (trim(prm_objid), trim(prm_screen)) and
            trim(cd_usuario)  = 'DWU' and 
            tp_filtro = 'objeto' and
            ligacao <> 'or' and
			st_agrupado = 'N' and condicao <> 'NOFLOAT' AND CONDICAO <> 'NOFILTER';

    ws_filtros_objeto crs_filtros_objeto%rowtype;
					  
	ws_cleardrill varchar2(40);
	ws_counter number := 1;
	ws_godrill			long;
	ws_godrill2			long;
	ws_searchdrill		long;
	ws_ccoluna			number := 1;
	ws_coluna           long;
	ws_objid			varchar2(40);
	ws_parametros		clob;
	ws_filtro           number;
	ws_count            number;
	ws_grupo varchar2(40);
	ws_colup varchar2(2000);
	ws_reopen varchar2(8000);
	ws_objeton   varchar2(2000); 
    ws_subquery	varchar2(900);
	ws_rotulo   varchar2(900);
	ws_parametros_unicos long;
	ws_title            varchar2(800);
	
	type ws_tmcolunas is table of MICRO_COLUNA%ROWTYPE
	index by pls_integer;
	ret_mcol			ws_tmcolunas;
	ws_tipo             varchar2(40) := 'N/A';
    ws_usuario          varchar2(80);
	ws_admin            varchar2(20);
begin

    ws_usuario := gbl.getUsuario;
    ws_admin   := gbl.getNivel;

    ws_objeton := prm_objeton;
	ws_subquery := fun.put_par(prm_objid,'SUBQUERY', 'CONSULTA');
	ws_subquery := substr(ws_subquery, 1, length(ws_subquery)-1);
    select count(*) into ws_filtro from object_attrib where cd_prop = 'FILTRO' and propriedade = 'ISOLADO' and cd_object = prm_objid;
	
	if ws_filtro = 0 then
		open crs_filtros_objeto;
			loop
				fetch crs_filtros_objeto into ws_filtros_objeto;
				exit when crs_filtros_objeto%notfound;
				ws_parametros := ws_parametros||ws_filtros_objeto.coluna||'|';
				ws_parametros_unicos := ws_parametros||ws_filtros_objeto.coluna||'|';
			end loop;
		close crs_filtros_objeto;
	end if;
	
	ws_parametros := ws_parametros||prm_parametros;

    if  prm_drill = 'Y' then
	    ws_cleardrill := '';
	else
	    ws_cleardrill := 'cleardrill();';
	end if;

	ws_counter := 0;
	
	ws_objid := prm_objid;
	
	ws_parametros := replace(replace(ws_parametros, chr(39), '\&apos;'), '||', '$[CONCAT]');
	
	open crs_xgoto(ws_usuario);
		loop
			fetch crs_xgoto into ws_xgoto;
			exit when crs_xgoto%notfound;
			
			if ws_xgoto.tipo <> ws_tipo then
			    ws_searchdrill := ws_searchdrill||'<optgroup label="'||ws_xgoto.tipo||'">'||ws_xgoto.tipo||'</optgroup>';
				ws_tipo := ws_xgoto.tipo;
			end if;
			
			if fun.getprop(trim(ws_xgoto.cd_objeto_go),'FILTRO') = 'INTERROMPIDO' then
			    ws_searchdrill := ws_searchdrill||'<option data-param="'||ws_parametros_unicos||'" data-tipo="'||ws_xgoto.tipo||'" value="'||ws_xgoto.cd_objeto_go||'">'||fun.subpar(fun.utranslate('NM_OBJETO', ws_xgoto.cd_objeto_go, ws_xgoto.nome))||'</option>';			
			elsif fun.getprop(trim(ws_xgoto.cd_objeto_go),'FILTRO') = 'PASSIVO' then
			    ws_searchdrill := ws_searchdrill||'<option data-param="'||ws_parametros||'" data-tipo="'||ws_xgoto.tipo||'" value="'||ws_xgoto.cd_objeto_go||'">'||fun.subpar(fun.utranslate('NM_OBJETO', ws_xgoto.cd_objeto_go, ws_xgoto.nome))||'</option>';
			elsif fun.getprop(trim(ws_xgoto.cd_objeto_go),'FILTRO') = 'COM CORTE' then
			    ws_searchdrill := ws_searchdrill||'<option data-param="" data-tipo="'||ws_xgoto.tipo||'" value="'||ws_xgoto.cd_objeto_go||'">'||fun.subpar(fun.utranslate('NM_OBJETO', ws_xgoto.cd_objeto_go, ws_xgoto.nome))||'</option>';
			elsif fun.getprop(trim(ws_xgoto.cd_objeto_go),'FILTRO') = 'ISOLADO' then
			    ws_searchdrill := ws_searchdrill||'<option data-param="" data-isolado="S" data-tipo="'||ws_xgoto.tipo||'" value="'||ws_xgoto.cd_objeto_go||'">'||fun.subpar(fun.utranslate('NM_OBJETO', ws_xgoto.cd_objeto_go, ws_xgoto.nome))||'</option>';
			else
			    ws_searchdrill := ws_searchdrill||'<option data-param="'||ws_parametros||'" data-tipo="'||ws_xgoto.tipo||'" value="'||ws_xgoto.cd_objeto_go||'">'||fun.subpar(fun.utranslate('NM_OBJETO', ws_xgoto.cd_objeto_go, ws_xgoto.nome))||'</option>';
			end if;

			ws_counter := ws_counter + 1;
		end loop;
	close crs_xgoto;

	ws_count := 0;
	select count(*) into ws_count from object_attrib where owner = ws_usuario and cd_prop = 'DRILL' and propriedade = 'CENTER';
	
	ws_objeton := replace(ws_objeton, '>    >', '>');
	

	if instr(ws_objeton, 'REABRIR') <> 0 then
	    ws_reopen := '';
		ws_objeton := replace(ws_objeton, 'REABRIR', '');
	else
	    ws_reopen := '<option style="color: #CC3333;" value="'||ws_objid||'" data-param="'||ws_parametros||'">'||fun.lang('REABRIR')||'</option>';
	end if;
	
	if length(ws_objeton) = 3 then
	    ws_title := '';
	else
	    ws_title := ws_objeton;
	end if;
	
	ws_godrill := '<li><select style="float: left;" title="'||ws_title||'" onchange="drillChange(this, encodeURIComponent(this.options[this.selectedIndex].getAttribute(&#039;data-param&#039;)), &#039;'||prm_track||'&#039;, &#039;'||ws_objeton||'&#039;, &#039;'||ws_count||'&#039;, &#039;'||prm_objid||'&#039;);"><option value="" selected hidden>'||fun.lang('ABRIR')||':</option>'||ws_searchdrill||ws_reopen||'</select></li><li>';
	
	select nvl(cs_colup, 'n/a') into ws_colup from ponto_avaliacao where cd_ponto = prm_objid;
	if(ws_colup = 'n/a') then
	    ws_godrill := ws_godrill||'<span class="reorder" title="'||fun.lang('clique para alterar a ordem')||'"></span>';
	end if;

	select cd_grupo into ws_grupo from objetos where cd_objeto = prm_objid;

	ws_counter := 0;
	for a in(select nm_rotulo from micro_coluna where cd_coluna in (select * from table(fun.vpipe(prm_coluna))) and cd_micro_visao = prm_micro_visao) loop
		if ws_counter > 0 then
			ws_rotulo := ws_rotulo||'|'||replace(replace(a.nm_rotulo, chr(10), ''), chr(13), '');
		else
			ws_rotulo := replace(replace(a.nm_rotulo, chr(10), ''), chr(13), '');
		end if;
		ws_counter := ws_counter+1;
	end loop;

	if prm_selected = 1 then
		if ws_admin = 'A' then
			ws_godrill := ws_godrill||'<span class="bolt" title="'||fun.lang('ponto de avalia&ccedil;&atilde;o')||'" onclick="quickPa(&#039;'||prm_micro_visao||'&#039;, &#039;'||ws_grupo||'&#039;, &#039;VALOR&#039;, &#039;&#039;, &#039;&#039;, this);"></span></td>';
			ws_godrill := ws_godrill||'<span class="pizza" title="'||fun.lang('gr&aacute;fico de pizza')||'" onclick="quickPa(&#039;'||prm_micro_visao||'&#039;, &#039;'||ws_grupo||'&#039;, &#039;PIZZA&#039;, &#039;'||prm_coluna||'&#039;, &#039;'||ws_rotulo||'&#039;, this);"></span>';
			ws_godrill := ws_godrill||'<span class="grafico" title="'||fun.lang('gr&aacute;fico de linha')||'" onclick="quickPa(&#039;'||prm_micro_visao||'&#039;, &#039;'||ws_grupo||'&#039;, &#039;LINHAS&#039;, &#039;'||prm_coluna||'&#039;, &#039;'||ws_rotulo||'&#039;, this);"></span>';
			ws_godrill := ws_godrill||'<span class="bar" title="'||fun.lang('gr&aacute;fico de barra')||'" onclick="quickPa(&#039;'||prm_micro_visao||'&#039;, &#039;'||ws_grupo||'&#039;, &#039;BARRAS&#039;, &#039;'||prm_coluna||'&#039;, &#039;'||ws_rotulo||'&#039;, this);"></span>';
			ws_godrill := ws_godrill||'<span class="map" title="'||fun.lang('gr&aacute;fico de mapa')||'" onclick="quickPa(&#039;'||prm_micro_visao||'&#039;, &#039;'||ws_grupo||'&#039;, &#039;MAPA&#039;, &#039;'||prm_coluna||'&#039;, &#039;'||ws_rotulo||'&#039;, this);"></span>';
		    ws_godrill := ws_godrill||'<span class="gauge" title="'||fun.lang('ponteiro')||'" onclick="quickPa(&#039;'||prm_micro_visao||'&#039;, &#039;'||ws_grupo||'&#039;, &#039;PONTEIRO&#039;, &#039;'||prm_coluna||'&#039;, &#039;'||ws_rotulo||'&#039;, this);"></span>';
		else
			ws_godrill := ws_godrill||'<span class="pizza" title="'||fun.lang('gr&aacute;fico de pizza')||'" onclick="quickPa(&#039;'||prm_micro_visao||'&#039;, &#039;'||ws_grupo||'&#039;, &#039;PIZZA&#039;, &#039;'||prm_coluna||'&#039;, &#039;'||ws_rotulo||'&#039;, this);"></span>';
			ws_godrill := ws_godrill||'<span class="grafico" title="'||fun.lang('gr&aacute;fico de linha')||'" onclick="quickPa(&#039;'||prm_micro_visao||'&#039;, &#039;'||ws_grupo||'&#039;, &#039;LINHAS&#039;, &#039;'||prm_coluna||'&#039;, &#039;'||ws_rotulo||'&#039;, this);"></span>';
			ws_godrill := ws_godrill||'<span class="bar" title="'||fun.lang('gr&aacute;fico de barra')||'" onclick="quickPa(&#039;'||prm_micro_visao||'&#039;, &#039;'||ws_grupo||'&#039;, &#039;BARRAS&#039;, &#039;'||prm_coluna||'&#039;, &#039;'||ws_rotulo||'&#039;, this);"></span>';
		end if;
    end if;
	
	ws_godrill := ws_godrill||'';
	return(ws_godrill);
	
end CALL_DRILL;

FUNCTION NOME_COL ( prm_cd_coluna varchar2,
                    prm_micro_visao varchar2, 
                    prm_screen varchar2 default null ) return varchar2 as
					
    ws_nome_col varchar2(200);

begin

    select NM_ROTULO into ws_nome_col
    from MICRO_COLUNA
    WHERE trim(CD_MICRO_VISAO)=trim(PRM_MICRO_VISAO) and trim(CD_COLUNA)=trim(replace(PRM_CD_COLUNA, '|', ''));

    return(ws_nome_col);

exception
    when others then
        return(PRM_CD_COLUNA);
end NOME_COL;

FUNCTION MAPOUT ( prm_parametros   varchar2 default null,
				  prm_micro_visao  char default null,
				  prm_coluna       char default null,
				  prm_agrupador    char default null,
				  prm_mode         char default 'NO',
				  prm_objeto       varchar2 default null,
				  prm_screen       varchar2 default null,
				  prm_colup        varchar2 default null ) return varchar2 as

        cursor crs_colsb is
                         select column_value as cd_coluna
                         from TABLE(fun.VPIPE(prm_agrupador))
                         where trim(column_value) is not null;

        ws_colsb        crs_colsb%rowtype;

    cursor crs_micro_visao is
    select rtrim(cd_grupo_funcao) as cd_grupo_funcao
    from  MICRO_VISAO where nm_micro_visao = prm_micro_visao;

    ws_micro_visao   crs_micro_visao%rowtype;

    type ws_tmcolunas  is table of MICRO_COLUNA%ROWTYPE
            index by pls_integer;

    type generic_cursor is   ref cursor;

    crs_saida   generic_cursor;

    cursor nc_colunas is  select * from MICRO_COLUNA where cd_micro_visao = prm_micro_visao;


    ret_coluna   varchar2(100);
    ret_mcol   ws_tmcolunas;

    ws_ncolumns   DBMS_SQL.VARCHAR2_TABLE;
    ws_coluna_ant  DBMS_SQL.VARCHAR2_TABLE;
    ws_pvcolumns  DBMS_SQL.VARCHAR2_TABLE;
    ws_mfiltro   DBMS_SQL.VARCHAR2_TABLE;
    ws_vcol    DBMS_SQL.VARCHAR2_TABLE;
    ws_vcon    DBMS_SQL.VARCHAR2_TABLE;


    ws_grft    varchar2(40);
    ws_zebrado   varchar2(20);
    ws_pipe    char(1);
    ws_virg    char(1);
    ws_add    varchar(10);
    ws_goobjeto                     varchar2(100);
    ws_gocount                      number;

    ws_posx    varchar(5);
    ws_posy    varchar(5);

    ret_colup   long;
    ws_lquery   number;
    ws_valor   varchar2(40);
    ws_counter   number := 1;
    ws_counter_pv   number := 0;
    ws_ccoluna   number := 1;
    ws_xcoluna   number := 0;
    ws_ctx    number := 0;
    ws_chcor   number := 0;
    ws_bindn   number := 0;
    ws_scol    number := 0;
    ws_cspan   number := 0;
    ws_xcount   number := 0;
    ws_multi                        number := 0;
    ws_ct_agrupador                 number := 0;

    ws_fonte   long;
    ws_texto   long;
    ws_textot   long;
    ws_nm_var   long;
    ws_ct_var   long;
    ws_nulo    long;
    ws_content_ant   long;
    ws_url_default   long;
    ws_colup   long;
    ws_coluna   long;
    ws_agrupador   long;
    ws_rp    long;
    ws_xatalho   long;
    ws_atalho   long;
    ws_retorno   long;
    ws_parametros   long;
    ws_perc_col   long;
    ws_find_col   long;
    ws_parenty    long;

    ws_acesso   exception;
    ws_semquery   exception;
    ws_sempermissao   exception;
    ws_vcoluna   integer;
    ws_pcursor   integer;
    ws_cursor   integer;
    ws_cspanx   integer;
    ws_spac    integer;
    ws_linhas   integer;
    ws_query_montada  dbms_sql.varchar2a;
    ws_query_pivot   long;
    ws_sql    long;
    ws_sql_pivot   long;
    ws_chamada   long  := '$$';
    ws_script   long;
    ws_locais   long;
    ws_mode    varchar2(30);

    ws_vazio   boolean := True;
    ws_nodata         exception;
    ws_invalido   exception;
    ws_ponto_avalicao  exception;
    ws_close_html   exception;
    ws_mount   exception;

    ws_countl   number;

    ws_vpar    DBMS_SQL.VARCHAR2_TABLE;
    ws_categorias                   long;
    ws_datasets                     DBMS_SQL.VARCHAR2_TABLE;

    ws_ii varchar2(3);
    ws_count number;
    ws_cab_cross VARCHAR2(4000);
    ws_valorshow     varchar2(400);

begin

    ws_coluna    := prm_coluna;
    ws_agrupador := prm_agrupador;
    ws_mode      := prm_mode;
    ws_rp      := 'GRUPO';
    ws_grft      := ws_mode;
    ws_colup     := '';
    ws_parenty   := prm_colup;

    /* Define Objetos Temporários presentes na Area de pesquisa */

    open crs_micro_visao;
    fetch crs_micro_visao into ws_micro_visao;
    close crs_micro_visao;

    ws_texto := prm_parametros;
    ws_parametros := prm_parametros;
    ws_parametros := fun.check_value(ws_parametros);

    ws_url_default := fun.url_default( ws_parametros, prm_micro_visao, ws_agrupador, ws_coluna, ws_rp, ws_colup, '', ws_mode );

    open nc_colunas;
    loop
        fetch nc_colunas bulk collect into ret_mcol limit 200;
        exit when nc_colunas%NOTFOUND;
    end loop;
    close nc_colunas;

            ws_ctx := 0;
    open crs_colsb;
    loop
        fetch crs_colsb into ws_colsb;
        exit when crs_colsb%notfound;

                ws_ctx := ws_ctx + 1;
                ws_datasets(ws_ctx) := '<dataSet seriesName="'||replace(fun.utranslate('NM_ROTULO', prm_micro_visao, fun.check_rotuloc(ws_colsb.cd_coluna,prm_micro_visao, prm_screen)), '<BR>', '')||'"';

                select count(*) into ws_gocount
                from   TABLE(fun.VPIPE(ws_parenty))
                where trim(column_value) is not null and
                      column_value=ws_colsb.cd_coluna;

                if  ws_gocount < 1 then
                    ws_datasets(ws_ctx) := ws_datasets(ws_ctx)||' renderAs="Line" ';
                end if;


                ws_datasets(ws_ctx) := ws_datasets(ws_ctx)||'>';

    end loop;
    close crs_colsb;


    ws_counter := 0;
    loop
        ws_counter := ws_counter + 1;
        if  ws_counter > ret_mcol.COUNT then
        exit;
        end if;

        if  rtrim(ret_mcol(ws_counter).st_agrupador) <> 'SEM' and fun.setem(ws_agrupador,rtrim(ret_mcol(ws_counter).cd_coluna)) then
    ws_scol := ws_scol + 1;
        end if;

    end loop;

    ws_texto := ws_parametros;

    ws_sql := core.MONTA_QUERY_DIRECT(prm_micro_visao, ws_coluna, ws_parametros, ws_rp, ws_colup, ws_query_pivot, ws_query_montada, ws_lquery, ws_ncolumns, ws_pvcolumns, ws_agrupador, ws_mfiltro, prm_objeto, 'Y', prm_screen => prm_screen, prm_cross => 'N', prm_cab_cross => ws_cab_cross);


    ws_cursor := dbms_sql.open_cursor;

    dbms_sql.parse( c => ws_cursor, statement => ws_query_montada, lb => 1, ub => ws_lquery, lfflg => true, language_flag => dbms_sql.native );

    ws_sql := core.bind_direct(ws_parametros, ws_cursor, '', prm_objeto, prm_micro_visao, prm_screen );


    ws_coluna := fun.check_value(ws_coluna);

    ws_counter := 0;
    loop
        ws_counter := ws_counter + 1;
        if  ws_counter > ws_ncolumns.COUNT then
        exit;
        end if;
        dbms_sql.define_column(ws_cursor, ws_counter, ret_coluna, 40);
    end loop;
    ws_linhas := dbms_sql.execute(ws_cursor);


    ws_counter := 0;
    loop
        ws_counter := ws_counter + 1;
        if  ws_counter > ret_mcol.COUNT or ws_ncolumns(1) = ret_mcol(ws_counter).cd_coluna then
        exit;
        end if;
    end loop;

    ws_pipe     := 'B';
    ws_perc_col := '';

    ws_countl := 0;

    select count(*) into ws_multi
    from TABLE(fun.VPIPE(prm_agrupador))
    where trim(column_value) is not null;

    if  ws_multi > 1 then
        ws_retorno := ws_retorno||'<map decimalSeparator="," thousandSeparator="." fillColor="D7F4FF" includeValueInLabels="1" labelSepChar=": " baseFontSize="9"><data>'||chr(13);
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

            ws_xcount  := 0;
            ws_ctx     := 0;

            ws_xcount := ws_xcount + 1;
            ws_ctx    := ws_ctx    + 1;
            dbms_sql.column_value(ws_cursor, ws_xcount, ret_coluna);
            ws_perc_col := ret_coluna;
            ws_find_col := ws_perc_col;

            if ret_mcol(ws_counter).cd_ligacao <> 'SEM' then
                ws_xcount := ws_xcount + 1;
                ws_perc_col := ret_coluna;
                dbms_sql.column_value(ws_cursor, ws_xcount, ret_coluna);
            end if;

            if  ws_pipe = 'B' then
                ws_categorias := '<categories font="Arial" fontSize="12" fontColor="000000">';
            end if;
            
            ws_categorias := ws_categorias||chr(13)||'<category label="'||ws_perc_col||'"/>';
            ws_ct_agrupador := 0;

            loop
                ws_ct_agrupador := ws_ct_agrupador + 1;
                if  ws_ct_agrupador > ws_multi then
                    exit;
                end if;

                ws_xcount := ws_xcount + 1;
                ws_ctx    := ws_ctx    + 1;
                dbms_sql.column_value(ws_cursor, ws_xcount, ret_coluna);
                ws_perc_col := ret_coluna;

                ws_valor := to_number(nvl(ret_coluna,0));

                ws_datasets(ws_ct_agrupador) := ws_datasets(ws_ct_agrupador)||chr(13)||'<set value="'||ws_valor||'" />';

            end loop;

            ws_pipe := '0';

        end loop;

        ws_retorno := ws_retorno||chr(13)||ws_categorias||chr(13)||'</categories>';

        ws_ct_agrupador := 0;
        
        loop
            ws_ct_agrupador := ws_ct_agrupador + 1;
            if  ws_ct_agrupador > ws_multi then
                exit;
            end if;
            ws_retorno := ws_retorno||chr(13)||ws_datasets(ws_ct_agrupador)||chr(13)||'</dataSet>';
        end loop;
    else
        ws_retorno := ws_retorno||'<map borderColor="005879" fillColor="FFFFFF" numberSuffix="" includeValueInLabels="1" labelSepChar=": " baseFontSize="9"><data>'||chr(13);
 
	    loop
	        ws_countl := ws_countl+1;
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

            ws_xcount  := 0;

            ws_xcount := ws_xcount + 1;
            dbms_sql.column_value(ws_cursor, ws_xcount, ret_coluna);
            ws_perc_col := ret_coluna;
            ws_find_col := ws_perc_col;
            ws_xcount := ws_xcount + 1;
            dbms_sql.column_value(ws_cursor, ws_xcount, ret_coluna);
            
            if ret_mcol(ws_counter).cd_ligacao <> 'SEM' then
                ws_xcount := ws_xcount + 1;
                ws_perc_col := ret_coluna;
                dbms_sql.column_value(ws_cursor, ws_xcount, ret_coluna);
            end if;

            if fun.getprop(prm_objeto,'HIDDEN') = 1 then
                ws_valor := TRIM(to_char(ret_coluna,'99999999999'));
			else
				ws_valor := '';
			end if;

            case ws_find_col
                when 'AC' then ws_ii := '001';
                when 'AL' then ws_ii := '002';
                when 'AP' then ws_ii := '003';
                when 'AM' then ws_ii := '004';
                when 'BA' then ws_ii := '005';
                when 'CE' then ws_ii := '006';
                when 'DF' then ws_ii := '007';
                when 'ES' then ws_ii := '008';
                when 'GO' then ws_ii := '009';
                when 'MA' then ws_ii := '010';
                when 'MT' then ws_ii := '011';
                when 'MS' then ws_ii := '012';
                when 'MG' then ws_ii := '013';
                when 'PA' then ws_ii := '014';
                when 'PB' then ws_ii := '015';
                when 'PR' then ws_ii := '016';
                when 'PE' then ws_ii := '017';
                when 'PI' then ws_ii := '018';
                when 'RJ' then ws_ii := '019';
                when 'RN' then ws_ii := '020';
                when 'RS' then ws_ii := '021';
                when 'RO' then ws_ii := '022';
                when 'RR' then ws_ii := '023';
                when 'SC' then ws_ii := '024';
                when 'SP' then ws_ii := '025';
                when 'SE' then ws_ii := '026';
                when 'TO' then ws_ii := '027';
                else ws_ii := '*';
            end case;
	
            select count(*) into ws_gocount from GOTO_OBJETO where cd_objeto = prm_objeto and cd_objeto_go not in ( select cd_objeto from OBJECT_RESTRICTION where USUARIO = gbl.getUsuario );
            select count(*) into ws_count from FILTROS where trim(micro_visao) = trim(prm_micro_visao) and tp_filtro = 'objeto' and trim(cd_objeto) in (trim(prm_objeto)) and trim(cd_usuario)  = 'DWU' and condicao <> 'NOFLOAT';

		    ws_find_col := fun.check_value(ws_find_col);
		
            if ws_gocount = 1 then
                
                if ws_count > 0 then
                    select cd_objeto_go||ws_coluna||ws_find_col||'|'||prm_objeto||'|'||prm_screen||'|'||(select rtrim(cd_coluna)||'|'||decode(rtrim(condicao),'IGUAL','$[IGUAL]','DIFERENTE','$[DIFERENTE]','MAIOR','$[MAIOR]','MENOR','$[MENOR]','MAIOROUIGUAL','$[MAIOROUIGUAL]','MENOROUIGUAL','$[MENOROUIGUAL]','LIKE','$[LIKE]','NOTLIKE','$[NOTLIKE]','$[IGUAL]')||rtrim(conteudo) as coluna from FILTROS where trim(micro_visao) = trim(prm_micro_visao) and tp_filtro = 'objeto' and trim(cd_objeto) in (trim(prm_objeto)) and trim(cd_usuario)  = 'DWU' and condicao <> 'NOFLOAT') into ws_goobjeto from GOTO_OBJETO where cd_objeto = prm_objeto and cd_objeto_go not in ( select cd_objeto from OBJECT_RESTRICTION where USUARIO = gbl.getUsuario );
                else
                    select cd_objeto_go||ws_coluna||ws_find_col||'|'||prm_objeto||'|'||prm_screen into ws_goobjeto from GOTO_OBJETO where cd_objeto = prm_objeto and cd_objeto_go not in ( select cd_objeto from OBJECT_RESTRICTION where USUARIO = gbl.getUsuario );
                end if;
                
                ws_goobjeto := replace(ws_goobjeto, chr(39), '$[QUOTE]');
                ws_goobjeto := replace(ws_goobjeto, chr(34), '$[DQUOTE]');
                
                ws_retorno := ws_retorno||'<entity color="5BA6D7" id="'||ws_ii||'" value="'||ws_valor||'" link="JavaScript:showview('''||ws_goobjeto||'''); " ></entity> '||chr(13);
            elsif ws_gocount > 1 then
                if ws_count > 0 then
                    select ws_coluna||ws_find_col||'|'||(select rtrim(cd_coluna)||'|'||decode(rtrim(condicao),'IGUAL','$[IGUAL]','DIFERENTE','$[DIFERENTE]','MAIOR','$[MAIOR]','MENOR','$[MENOR]','MAIOROUIGUAL','$[MAIOROUIGUAL]','MENOROUIGUAL','$[MENOROUIGUAL]','LIKE','$[LIKE]','NOTLIKE','$[NOTLIKE]','$[IGUAL]')||rtrim(conteudo) as coluna from FILTROS where trim(micro_visao) = trim(prm_micro_visao) and tp_filtro = 'objeto' and trim(cd_objeto) in (trim(prm_objeto)) and trim(cd_usuario)  = 'DWU' and condicao <> 'NOFLOAT') into ws_goobjeto from GOTO_OBJETO where cd_objeto = prm_objeto and cd_objeto_go not in ( select cd_objeto from OBJECT_RESTRICTION where USUARIO = gbl.getUsuario ) and ROWNUM = 1;
                else
                    select ws_coluna||ws_find_col into ws_goobjeto from GOTO_OBJETO where cd_objeto = prm_objeto and cd_objeto_go not in ( select cd_objeto from OBJECT_RESTRICTION where USUARIO = gbl.getUsuario ) and ROWNUM = 1;
                end if;
                
                ws_goobjeto := replace(ws_goobjeto, chr(39), '$[QUOTE]');
                ws_goobjeto := replace(ws_goobjeto, chr(34), '$[DQUOTE]');
                
                ws_retorno := ws_retorno||'<entity color="5BA6D7" id="'||ws_ii||'" value="'||ws_valor||'" data-valor="'||prm_objeto||''||replace(ws_goobjeto, '%', '%25')||'" id="'||prm_objeto||'_linha_'||ws_countl||'" link="JavaScript: isJavaScriptCall=true; showview2('''||ws_ii||''');" ></entity> '||chr(13);
            else
                ws_retorno := ws_retorno||'<entity color="5BA6D7" id="'||ws_ii||'" value="'||ws_valor||'" ></entity> '||chr(13);
            end if;

        end loop;
    end if;

dbms_sql.close_cursor(ws_cursor);


ws_retorno := ws_retorno||chr(13)||'</data></map>';

return(ws_retorno);

exception
when others then
    insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - MAPOUT', gbl.getUsuario, 'ERRO');
    commit;
end MAPOUT;

-----
-- Atenção: essa function foi copiada para a package ETF, a alteração realizada aqui deve ser replicada para a package ETF 
---------------------------------------------------------------------------------------------------------------------------------
FUNCTION VPIPE_PAR ( prm_entrada varchar ) return TAB_PARAMETROS pipelined as

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


FUNCTION SHOW_FILTROS ( prm_condicoes   varchar2 default null,
					    prm_cursor      number   default 0,
					    prm_tipo        varchar2 default 'ATIVO',
					    prm_objeto      varchar2 default null,
					    prm_micro_visao varchar2 default null,
					    prm_screen      varchar2 default null,
                        prm_usuario     varchar2 default null ) return varchar2 as
         
		 cursor crs_filtrog(prm_usu varchar2) is -- Analisar se não tem como usar o cursor da package CORE e depois só listar os IGNORADOS 
		 select indice,trim(cd_usuario),micro_visao,cd_coluna,condicao,conteudo,ligacao, agrupado, max(color) as cor, max(title) as titulo 
           from ( -- Float FILTER - filtra valores IGUAIS ou DEFERENTES do informado no filtro 
                  select 'C'                                                                                                            as indice,
                         'DWU'                                                                                                          as cd_usuario,
                         trim(prm_micro_visao)                                                                                          as micro_visao,
                         decode(substr(trim(cd_coluna),1,2),'M_',substr(trim(cd_coluna),3,length(trim(cd_coluna))),trim(cd_coluna))     as cd_coluna,
                         decode(instr(trim(conteudo),'$[NOT]'),0,'IGUAL', 'DIFERENTE')                                                  as condicao,
                         replace(trim(CONTEUDO), '$[NOT]', '')                                                                          as conteudo,
                         'and'                                                                                                          as ligacao,
                         ''                                                                                                             as agrupado,
                         decode(fun.getprop(prm_objeto,'FILTRO_FLOAT'), 'S', 'parametro cut', 'parametro')                              as color,
                         'Filtro de parametro'                                                                                          as title
			        from FLOAT_FILTER_ITEM
			       where cd_usuario  = prm_usu 
				     and screen      = trim(prm_screen)
                     and fun.getprop(prm_objeto,'FILTRO_FLOAT') = 'N'   -- Atributo: BLOQUEAR FILTRO DO FLOAT (ignorar todos os float_filter do objeto) 
                     -- card 833s - and cd_coluna not in (select cd_coluna from filtros where condicao = 'NOFLOAT' and tp_filtro = 'objeto' and micro_visao = trim(prm_micro_visao) and cd_objeto = trim(prm_objeto)) 
                     and cd_coluna not in (select cd_coluna from filtros where tp_filtro = 'objeto' and micro_visao = trim(prm_micro_visao) and cd_objeto = trim(prm_objeto))  --card 833s
                     and cd_coluna in ( select trim(cd_coluna) from micro_coluna mc where mc.cd_micro_visao = trim(prm_micro_visao)   ) 
                     and length(trim(CONTEUDO)) > 0
                 --
		         union all
                 -- Filtros passados por parametro (drill e subquery)
	             select 
                        'A'                                                                             as indice,
                        'DWU'                                                                           as cd_usuario,
                        trim(prm_micro_visao)                                                           as micro_visao,
                        trim(cd_coluna)                                                                 as cd_coluna,
                        cd_condicao                                                                     as condicao,
                        trim(CD_CONTEUDO)                                                               as conteudo,
                        'and'                                                                           as ligacao,
                        ''                                                                              as agrupado,
                        decode(fun.getprop(prm_objeto,'FILTRO_DRILL'), 'S', 'drill cut','drill')        as color,
                        'Filtro da drill'                                                               as title
	               from table(fun.vpipe_par(prm_condicoes)) PC 
                  where cd_coluna <> '1' 
                    and fun.getprop(prm_objeto,'FILTRO_DRILL') = 'N'  -- Atributo: BLOQUEAR FILTRO DA DRILL (ignorar todos os filtros repassados por parametro (DRILL))                        
                    and cd_coluna in (select trim(cd_coluna) from micro_coluna     where cd_micro_visao = trim(prm_micro_visao) union all 
                                      select trim(cd_coluna) from micro_visao_fpar where cd_micro_visao = trim(prm_micro_visao)
                                     ) 
                    and trim(cd_coluna)||trim(cd_conteudo) not in ( select nof.cd_coluna||nof.conteudo 
                                                                      from filtros nof
				                                                     where nof.micro_visao = trim(prm_micro_visao)  
                                                                       and nof.condicao    = 'NOFILTER'  
                                                                       and nof.conteudo    = trim(pc.cd_conteudo)  
                                                                       and nof.cd_objeto   = trim(prm_objeto)
                                                                  )
                 --                                                                  
                 union all
                 -- Filtros de usuário 
                 select	'D'                         as indice,
                        rtrim(cd_usuario)	        as cd_usuario,
                        rtrim(micro_visao)	        as micro_visao,
                        rtrim(cd_coluna)	        as cd_coluna,
                        rtrim(condicao)		        as condicao,
                        rtrim(conteudo)		        as conteudo,
                        rtrim(ligacao)		        as ligacao,
                        ''                          as agrupado,
                        'usuario'                   as color,
                        'Filtro do usu&aacute;rio'  as title
			       from FILTROS t1
			      where	micro_visao = rtrim(prm_micro_visao) 
                    and tp_filtro   = 'geral' 
                    and st_agrupado = 'N' 
                    and (trim(cd_usuario)   in (prm_usu, 'DWU') or trim(cd_usuario) in (select cd_group from gusers_itens where trim(cd_usuario) = prm_usu))
        			and length(trim(CONTEUDO)) > 0
                 --   
			     union  
                 -- Filtro de objeto 
                 select	decode(cd_objeto, trim(prm_objeto), 'B', 'C')                                                                                   as indice,
                        trim(cd_usuario)	                                                                                                            as cd_usuario,
                        trim(micro_visao)	                                                                                                            as micro_visao,
                        trim(cd_coluna)	                                                                                                                as cd_coluna,
                        trim(condicao)		                                                                                                            as condicao,
                        trim(conteudo)		                                                                                                            as conteudo,
                        trim(ligacao)		                                                                                                            as ligacao,
                        decode(rtrim(st_agrupado), 'S', '(agrupado)', 'N', '', '')                                                                      as agrupado,
                        decode(trim(cd_objeto), trim(prm_screen), decode(fun.getprop(prm_objeto,'FILTRO_TELA'), 'S', 'objeto cut', 'objeto'), 'objeto') as color,
                        'Filtro da tela ou do objeto'                                                                                                   as title
			       from FILTROS
			      where micro_visao        = trim(prm_micro_visao)  
                    and CONDICAO not in ('NOFLOAT','NOFILTER') 
                    and tp_filtro          = 'objeto' 
                    and trim(cd_usuario)         = 'DWU' 
                    and ( (cd_objeto = trim(prm_objeto)) or 
                          (cd_objeto = trim(prm_screen) 
                           and nvl(fun.GETPROP(trim(prm_objeto),'FILTRO'), 'N/A') not in ('ISOLADO', 'COM CORTE') 
                           and cd_coluna not in (select t2.cd_coluna 
                                                   from filtros t2 
                                                  where t2.condicao    = 'NOFLOAT' 
                                                    and t2.micro_visao = trim(prm_micro_visao) 
                                                    and t2.cd_objeto   = trim(prm_objeto) 
                                                    and tp_filtro      = 'objeto'
                                                ) -- Ignora o filtro se ele estiver cadastrado no objeto como NOFLOAT                            
                          ) 
                        )
			        and length(trim(CONTEUDO)) > 0  
                 --
			     union all
                 --
                 SELECT
                        'E'                                                         as indice,
                        rtrim(cd_usuario)	                                        as cd_usuario,
                        rtrim(micro_visao)	                                        as micro_visao,
                        rtrim(cd_coluna)	                                        as cd_coluna,
                        rtrim(condicao)		                                        as condicao,
                        --rtrim(conteudo)		                                    as conteudo,
                        decode(condicao,'NOFLOAT','TODOS',rtrim(conteudo))          as conteudo,
                        rtrim(ligacao)		                                        as ligacao,
                        decode(rtrim(st_agrupado), 'S', '(agrupado)', 'N', '', '')  AS AGRUPADO,
                        'ignorado'                                                  AS COLOR,
                        'Filtro ignorado'                                           AS TITLE
			       from	filtros
			      where micro_visao = rtrim(prm_micro_visao)  
                    and ( cd_objeto = trim(prm_objeto) or (rtrim(cd_objeto) = trim(prm_screen)) )
			        and cd_usuario  = 'DWU' 
			        and ( ( length(trim(conteudo)) > 0 ) or (condicao = 'NOFLOAT') )
                    and condicao in ('NOFILTER','NOFLOAT')
            )
			group by indice,cd_usuario,micro_visao,cd_coluna,condicao,conteudo,ligacao, agrupado
            --order by cor, cd_usuario, micro_visao, cd_coluna, condicao, conteudo;
            order by indice, cd_coluna, condicao, cor, cd_usuario, micro_visao, conteudo;


    type type_filtro is table of crs_filtrog%rowtype  index by pls_integer; 
	reg_filtro                   type_filtro;

    ws_bindn        number;
    ws_distintos    long;
    ws_texto        long;
    ws_textot       long;
    ws_nm_var       long;
    ws_ct_var       long;
    ws_null         long;
    ws_retorno      long;
    ws_conteudo     varchar2(32000);
    ws_tcont        varchar2(32000);
    ws_condicao     varchar2(32000);
    ws_col_ant      varchar2(32000) := '';
    ws_condicao_ant varchar2(32000) := '';
    ws_indice_ant   varchar2(200)   := ''; 

    ws_cursor       integer;
    ws_linhas       integer;

    ws_calculado    varchar2(32000);
    ws_sql          varchar2(32000);

    crlf            varchar2( 2 ):= CHR( 13 ) || CHR( 10 );
 
    ws_filtro       varchar2(32000);
    ws_filtro_aux   varchar2(32000);
    ws_qt_filtro    integer; 
    ws_excedeu      varchar2(1); 
    ws_color        varchar2(200) := '';
    ws_usuario      varchar2(80);
    ws_repeat       boolean;

begin

    ws_usuario := prm_usuario;

    if nvl(ws_usuario, 'N/A') = 'N/A' then
        ws_usuario := gbl.getUsuario;
    end if;

    ws_bindn     := 1;
    ws_texto     := prm_condicoes;
    ws_qt_filtro := 0;
    ws_excedeu   := 'N'; 

    open crs_filtrog(ws_usuario);
    loop
        fetch crs_filtrog bulk collect into reg_filtro limit 4000;
        exit when crs_filtrog%NOTFOUND;
    end loop;
    close crs_filtrog;

    for a IN 1 .. reg_filtro.count loop

        if reg_filtro(a).conteudo like '%@PIPE@%' then 
            reg_filtro(a).conteudo := replace(reg_filtro(a).conteudo,'@PIPE@','|');
        end if; 

        ws_qt_filtro := ws_qt_filtro + 1;
        ws_tcont := reg_filtro(a).conteudo;

        if substr(ws_tcont,1,2) = '$[' then
            ws_tcont := fun.gparametro(ws_tcont, prm_screen => prm_screen);
        end if;
        
        if substr(ws_tcont,1,2) = '@[' then
            ws_tcont := fun.gvalor(ws_tcont, prm_screen => prm_screen);
        end if;

        if substr(ws_tcont,1,2) = '#[' then
            ws_tcont := fun.ret_var(ws_tcont, ws_usuario);
        end if;

        if UPPER(substr(ws_tcont,1,5)) = 'EXEC=' then
            ws_tcont := fun.xexec(ws_tcont, prm_screen);
        end if;

        ws_condicao := '***';
        case reg_filtro(a).condicao
            when 'IGUAL' then            
                ws_condicao := fun.lang('Igual a');
            when 'DIFERENTE' then            
                ws_condicao := fun.lang('Diferente de');
            when 'MAIOR' then            
                ws_condicao := fun.lang('Maior que');
            when 'MENOR' then            
                ws_condicao := fun.lang('Menor que');
            when 'MAIOROUIGUAL' then            
                ws_condicao := fun.lang('Maior ou igual a');
            when 'MENOROUIGUAL' then            
                ws_condicao := fun.lang('Menor ou igual a');
            when 'LIKE' then            
                ws_condicao := fun.lang('Semelhante a');
        else                                
            ws_condicao := '***';
        end case;
        
        ws_color := reg_filtro(a).cor;
        
        ws_filtro_aux := ''; 
        if ws_condicao_ant = ws_condicao and ws_col_ant = reg_filtro(a).cd_coluna and ws_indice_ant = reg_filtro(a).indice  then 
            ws_repeat := true;
        else 
            ws_repeat := false;
        end if;    
        ws_filtro_aux := fun.col_name(reg_filtro(a).cd_coluna, reg_filtro(a).micro_visao, ws_condicao, ws_tcont, reg_filtro(a).cor, fun.lang(reg_filtro(a).titulo), ws_repeat, reg_filtro(a).agrupado);        
        -- if ws_condicao_ant = ws_condicao then
        --     if ws_col_ant = reg_filtro(a).cd_coluna then
        --         ws_filtro_aux := fun.col_name(reg_filtro(a).cd_coluna, reg_filtro(a).micro_visao, ws_condicao, ws_tcont, reg_filtro(a).cor, fun.lang(reg_filtro(a).titulo), true, reg_filtro(a).agrupado);
        --     else
        --         ws_filtro_aux := fun.col_name(reg_filtro(a).cd_coluna, reg_filtro(a).micro_visao, ws_condicao, ws_tcont, reg_filtro(a).cor, fun.lang(reg_filtro(a).titulo), false, reg_filtro(a).agrupado);
        --     end if;
        -- else
        --     ws_filtro_aux := fun.col_name(reg_filtro(a).cd_coluna, reg_filtro(a).micro_visao, ws_condicao, ws_tcont, reg_filtro(a).cor, fun.lang(reg_filtro(a).titulo), false, reg_filtro(a).agrupado);
        -- end if;

        if length(ws_filtro||nvl(ws_filtro_aux,' ')) <= 31900 and ws_excedeu = 'N' then 
            ws_filtro := ws_filtro||ws_filtro_aux; 
        else     
            ws_filtro  := ws_filtro||' (Excedeu o limite de '||ws_qt_filtro||' itens selecionados nos filtros)'; 
            ws_excedeu := 'S'; 
        end if; 

        ws_bindn := ws_bindn + 1;

        ws_condicao_ant := ws_condicao;
        ws_col_ant      := reg_filtro(a).cd_coluna;
        ws_indice_ant   := reg_filtro(a).indice;

        if ws_excedeu = 'S' then 
            exit;
        end if;    
        
    end loop;


    /****************
    open crs_filtrog(ws_usuario);
    loop
        fetch crs_filtrog into ws_filtrog;
        exit when (crs_filtrog%notfound or ws_excedeu = 'S');

        if ws_filtrog.conteudo like '%@PIPE@%' then 
            ws_filtrog.conteudo := replace(ws_filtrog.conteudo,'@PIPE@','|');
        end if; 

        ws_qt_filtro := ws_qt_filtro + 1;
        ws_tcont := ws_filtrog.conteudo;

        if substr(ws_tcont,1,2) = '$[' then
            ws_tcont := fun.gparametro(ws_tcont, prm_screen => prm_screen);
        end if;

        if substr(ws_tcont,1,2) = '#[' then
            ws_tcont := fun.ret_var(ws_tcont, ws_usuario);
        end if;

        if UPPER(substr(ws_tcont,1,5)) = 'EXEC=' then
            ws_tcont := fun.xexec(ws_tcont, prm_screen);
        end if;

        ws_condicao := '***';
        case ws_filtrog.condicao
        when 'IGUAL'        then            ws_condicao := fun.lang('Igual a');
        when 'DIFERENTE'    then            ws_condicao := fun.lang('Diferente de');
        when 'MAIOR'        then            ws_condicao := fun.lang('Maior que');
        when 'MENOR'        then            ws_condicao := fun.lang('Menor que');
        when 'MAIOROUIGUAL' then            ws_condicao := fun.lang('Maior ou igual a');
        when 'MENOROUIGUAL' then            ws_condicao := fun.lang('Menor ou igual a');
        when 'LIKE'         then            ws_condicao := fun.lang('Semelhante a');
        else                                ws_condicao := '***';
        end case;
        
        ws_color := ws_filtrog.cor;
        
        ws_filtro_aux := ''; 
        if ws_condicao_ant = ws_condicao then
            if ws_col_ant = ws_filtrog.cd_coluna then
                ws_filtro_aux := fun.col_name(ws_filtrog.cd_coluna, ws_filtrog.micro_visao, ws_condicao, ws_tcont, ws_filtrog.cor, fun.lang(ws_filtrog.titulo), true, ws_filtrog.agrupado);
            else
                ws_filtro_aux := fun.col_name(ws_filtrog.cd_coluna, ws_filtrog.micro_visao, ws_condicao, ws_tcont, ws_filtrog.cor, fun.lang(ws_filtrog.titulo), false, ws_filtrog.agrupado);
            end if;
        else
            ws_filtro_aux := fun.col_name(ws_filtrog.cd_coluna, ws_filtrog.micro_visao, ws_condicao, ws_tcont, ws_filtrog.cor, fun.lang(ws_filtrog.titulo), false, ws_filtrog.agrupado);
        end if;

        if length(ws_filtro||nvl(ws_filtro_aux,' ')) <= 31900 and ws_excedeu = 'N' then 
            ws_filtro := ws_filtro||ws_filtro_aux; 
        else     
            ws_filtro  := ws_filtro||' (Excedeu o limite de '||ws_qt_filtro||' itens selecionados nos filtros)'; 
            ws_excedeu := 'S'; 
        end if; 

        ws_bindn := ws_bindn + 1;

        ws_condicao_ant := ws_condicao;
        ws_col_ant := ws_filtrog.cd_coluna;
        
    end loop;
    close crs_filtrog;
    ************************/ 

    return (ws_filtro);

exception
    when others then
        if upper(sqlerrm) like '%BUFFER TOO SMALL%' then 
            ws_filtro := 'Excedeu o limite de '||ws_qt_filtro||' itens selecionados nos filtros (SHOW_FILTROS).';
        else 
            ws_filtro := sqlerrm||'=SHOW_FILTROS';    
        end if; 

        htp.p(ws_filtro) ;
        return (ws_filtro);  

end SHOW_FILTROS;

FUNCTION show_destaques ( prm_condicoes   varchar2 default null,
					      prm_cursor      number   default 0,
					      prm_tipo        varchar2 default 'ATIVO',
					      prm_objeto      varchar2 default null,
					      prm_micro_visao varchar2 default null,
					      prm_screen      varchar2 default null,
                          prm_usuario     varchar2 default null ) return varchar2 as

		cursor crs_destaques(prm_usu varchar2) is
		select cd_coluna, condicao, conteudo, cor_fundo, cor_fonte, tipo_destaque, 
		(select cd_micro_visao from ponto_avaliacao where cd_ponto = prm_objeto) as micro_visao, cd_destaque
		  from destaque t1
		 where (t1.cd_usuario in ( prm_usu, 'DWU') or t1.cd_usuario in (select upper(trim(cd_group)) from gusers_itens t2 where t2.cd_usuario = prm_usu)) 
           and cd_objeto = prm_objeto;
		
	    type type_destaque is table of crs_destaques%rowtype  index by pls_integer; 
    	reg_destaque                 type_destaque;
        --ws_destaque crs_destaques%rowtype;

		ws_tcont        varchar2(800);
		ws_condicao     varchar2(800);
		ws_col_ant      varchar2(800) := '';
		ws_condicao_ant varchar2(800) := '';
		ws_filtro       varchar2(18000);
		ws_bindn        number;
        ws_usuario      varchar2(80);
begin

 ws_usuario := prm_usuario;

 if nvl(ws_usuario, 'N/A') = 'N/A' then
     ws_usuario := gbl.getUsuario;
 end if;

 open crs_destaques(ws_usuario);
 loop
    fetch crs_destaques bulk collect into reg_destaque limit 4000;
    exit when crs_destaques%NOTFOUND;
 end loop;
 close crs_destaques;

 for a IN 1 .. reg_destaque.count loop

    ws_tcont := reg_destaque(a).conteudo;

    if substr(ws_tcont,1,2) = '$[' then
        ws_tcont := fun.gparametro(ws_tcont, prm_screen => prm_screen);
    end if;
    
    if substr(ws_tcont,1,2) = '@[' then
        ws_tcont := fun.gvalor(ws_tcont, prm_screen => prm_screen);
    end if;

    if substr(ws_tcont,1,2) = '#[' then
        ws_tcont := fun.ret_var(ws_tcont, ws_usuario);
    end if;

    if UPPER(substr(ws_tcont,1,5)) = 'EXEC=' then
        ws_tcont := fun.xexec(ws_tcont, prm_screen);
    end if;

    case reg_destaque(a).condicao
    when 'IGUAL' then
        ws_condicao := fun.lang('Igual a');
    when 'DIFERENTE' then
        ws_condicao := fun.lang('Diferente de');
    when 'MAIOR' then
        ws_condicao := fun.lang('Maior que');
    when 'MENOR' then
        ws_condicao := fun.lang('Menor que');
    when 'MAIOROUIGUAL' then
        ws_condicao := fun.lang('Maior ou igual a');
    when 'MENOROUIGUAL' then
        ws_condicao := fun.lang('Menor ou igual a');
    when 'LIKE' then
        ws_condicao := fun.lang('Semelhante a');
    else
        ws_condicao := '***';
    end case;

	
	if ws_condicao_ant = ws_condicao then
	    if ws_col_ant = reg_destaque(a).cd_coluna then
	        ws_filtro := ws_filtro||fun.col_name(reg_destaque(a).cd_coluna, reg_destaque(a).micro_visao, ws_condicao, ws_tcont, 'destaque', reg_destaque(a).cd_destaque, false, '');
	    else
	        ws_filtro := ws_filtro||fun.col_name(reg_destaque(a).cd_coluna, reg_destaque(a).micro_visao, ws_condicao, ws_tcont, 'destaque', reg_destaque(a).cd_destaque, false, '');
	    end if;
	else
	        ws_filtro := ws_filtro||fun.col_name(reg_destaque(a).cd_coluna, reg_destaque(a).micro_visao, ws_condicao, ws_tcont, 'destaque', reg_destaque(a).cd_destaque, false, '');
	end if;
    ws_bindn := ws_bindn + 1;

	ws_condicao_ant := ws_condicao;
	ws_col_ant := reg_destaque(a).cd_coluna;

 end loop; 

 /*********************************** trocado por for de array para evitar lock do cursor 
 open crs_destaques(ws_usuario);
 loop
    fetch crs_destaques into ws_destaque;
    exit when crs_destaques%notfound;

    ws_tcont := ws_destaque.conteudo;

    if substr(ws_tcont,1,2) = '$[' then
        ws_tcont := fun.gparametro(ws_tcont, prm_screen => prm_screen);
    end if;
    
    if substr(ws_tcont,1,2) = '@[' then
        ws_tcont := fun.gvalor(ws_tcont, prm_screen => prm_screen);
    end if;

    if substr(ws_tcont,1,2) = '#[' then
        ws_tcont := fun.ret_var(ws_tcont, ws_usuario);
    end if;

    if UPPER(substr(ws_tcont,1,5)) = 'EXEC=' then
        ws_tcont := fun.xexec(ws_tcont, prm_screen);
    end if;

    case ws_destaque.condicao
    when 'IGUAL' then
        ws_condicao := fun.lang('Igual a');
    when 'DIFERENTE' then
        ws_condicao := fun.lang('Diferente de');
    when 'MAIOR' then
        ws_condicao := fun.lang('Maior que');
    when 'MENOR' then
        ws_condicao := fun.lang('Menor que');
    when 'MAIOROUIGUAL' then
        ws_condicao := fun.lang('Maior ou igual a');
    when 'MENOROUIGUAL' then
        ws_condicao := fun.lang('Menor ou igual a');
    when 'LIKE' then
        ws_condicao := fun.lang('Semelhante a');
    else
        ws_condicao := '***';
    end case;

	
	if ws_condicao_ant = ws_condicao then
	    if ws_col_ant = ws_destaque.cd_coluna then
	        ws_filtro := ws_filtro||fun.col_name(ws_destaque.cd_coluna, ws_destaque.micro_visao, ws_condicao, ws_tcont, 'destaque', ws_destaque.cd_destaque, false, '');
	    else
	        ws_filtro := ws_filtro||fun.col_name(ws_destaque.cd_coluna, ws_destaque.micro_visao, ws_condicao, ws_tcont, 'destaque', ws_destaque.cd_destaque, false, '');
	    end if;
	else
	        ws_filtro := ws_filtro||fun.col_name(ws_destaque.cd_coluna, ws_destaque.micro_visao, ws_condicao, ws_tcont, 'destaque', ws_destaque.cd_destaque, false, '');
	end if;
    ws_bindn := ws_bindn + 1;

	ws_condicao_ant := ws_condicao;
	ws_col_ant := ws_destaque.cd_coluna;
	
 end loop;
 close crs_destaques;
 *********************************/ 

  return (ws_filtro);

exception
 when others then
  htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||'=show_destaques');

end show_destaques;

FUNCTION PUT_VAR ( PRM_VARIAVEL VARCHAR2 DEFAULT NULL,
                   PRM_CONTEUDO VARCHAR2 DEFAULT NULL )  RETURN VARCHAR2 AS
											  
	WS_COUNT NUMBER;
BEGIN

    BEGIN
        SELECT COUNT(*) INTO WS_COUNT FROM VAR_CONTEUDO WHERE VARIAVEL = PRM_VARIAVEL;
		IF WS_COUNT = 0 THEN
		    INSERT INTO VAR_CONTEUDO (usuario, variavel, data, conteudo, locked)  
               VALUES('DWU', PRM_VARIAVEL, SYSDATE, PRM_CONTEUDO, 'N');
            RETURN('ok');
		else
		    update var_conteudo 
			set conteudo = PRM_CONTEUDO
			where variavel = prm_variavel;
		end if;
    EXCEPTION WHEN OTHERS THEN
        RETURN(SQLERRM);
	END;
END PUT_VAR;


FUNCTION CHECK_SYS  RETURN VARCHAR2 AS
    WS_CHECK      VARCHAR2(40);
    WS_CHECK1     VARCHAR2(40);
    WS_CHECK2     VARCHAR2(40);
BEGIN
    BEGIN
        BEGIN
            SELECT POSX INTO WS_CHECK1
            FROM   OBJECT_LOCATION
            WHERE  OWNER    ='DWU' AND
                NAVEGADOR='DEFAULT' AND
                OBJECT_ID='CONFIG';
            IF  WS_CHECK1 = '12px' THEN
                WS_CHECK1 := 'OPEN';
            elsif WS_CHECK1 = '13px' THEN
                WS_CHECK1 := 'BLOCK';
            else
                WS_CHECK1 := 'LOCKED';
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                WS_CHECK1 := 'LOCKED';
                insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values(sysdate, 'Erro FUN.CHECK_SYS (OBJECT_LOCATION): '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getUsuario, 'ERRO');
                commit; 

        END;

        BEGIN
            SELECT CONTEUDO INTO WS_CHECK2
            FROM   VAR_CONTEUDO
            WHERE  USUARIO ='DWU' AND
                VARIAVEL='LOCK_SYS';
            IF  WS_CHECK2 = 'OFF' THEN
                WS_CHECK2 := 'OPEN';
            ELSE
                WS_CHECK2 := 'LOCKED';
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                WS_CHECK2 := 'LOCKED';
                insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values(sysdate, 'Erro FUN.CHECK_SYS (VAR_CONTEUDO): '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getUsuario, 'ERRO');
                commit; 

        END;

    EXCEPTION
        WHEN OTHERS THEN
            WS_CHECK1 := 'LOCKED';
            WS_CHECK2 := 'LOCKED';
            insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values(sysdate, 'Erro FUN.CHECK_SYS (OUTROS): '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getUsuario, 'ERRO');
            commit; 
    END;
    IF  WS_CHECK1 = 'OPEN' AND WS_CHECK2 = 'OPEN' THEN
         WS_CHECK := 'OPEN';
    ELSE
	    if ws_check1 = 'BLOCK' then
		    WS_CHECK := 'BLOCK';
		else
            WS_CHECK := 'LOCKED';
	    end if;
    END IF;
    RETURN(WS_CHECK);
END CHECK_SYS;



FUNCTION RCONDICAO ( prm_variavel varchar) return char as

        ws_retorno   varchar2(50);

begin
     case upper(prm_variavel)
      when 'IGUAL' then
           ws_retorno := '=';
      when 'DIFERENTE' then
           ws_retorno := '<>';
      when 'MAIOR' then
           ws_retorno := '>';
      when 'MENOR' then
           ws_retorno := '<';
      when 'MAIOROUIGUAL' then
           ws_retorno := '>=';
      when 'MENOROUIGUAL' then
           ws_retorno := '<=';
      when 'LIKE' then
           ws_retorno := ' like ';
      when 'NOTLIKE' then
           ws_retorno := ' not like ';
      else
           ws_retorno := '***';
     end case;

     return (trim(ws_retorno));

end rcondicao;

function dcondicao ( prm_variavel varchar2 default null ) return varchar2 as

    ws_retorno   varchar2(40);

begin
    case upper(prm_variavel)
    when 'IGUAL' then
        ws_retorno := 'Igual a';
    when 'DIFERENTE' then
        ws_retorno := 'Diferente de';
    when 'MAIOR' then
        ws_retorno := 'Maior que';
    when 'MENOR' then
        ws_retorno := 'Menor que';
    when 'MAIOROUIGUAL' then
        ws_retorno := 'Maior ou igual a';
    when 'MENOROUIGUAL' then
        ws_retorno := 'Menor ou igual a';
    when 'LIKE' then
        ws_retorno := 'Semelhante a(like)';
    when 'NOTLIKE' then
        ws_retorno := 'Diferente de(not like)';
    when 'NOFLOAT' then
        ws_retorno := 'Ignorar float';  
    when 'NOFILTER' then
        ws_retorno := 'Ignorar filtro';       
    else
        ws_retorno := '***';
    end case;

     return (trim(ws_retorno));

end dcondicao;

function vpcondicao ( prm_variavel varchar2 default null ) return varchar2 as

    ws_retorno   varchar2(40);

begin
    case upper(trim(prm_variavel))
    when 'SEM' then
        ws_retorno := 'SEM';
    when 'DATA' then
        ws_retorno := 'DATA';
    when 'DATA2' then
        ws_retorno := 'DATA SEM CALEND&Aacute;RIO';
    when 'TEXTO' then
        ws_retorno := 'TEXTO';
    when 'LIGACAO' then
        ws_retorno := 'LIGA&Ccedil;&Atilde;O';
    
    else
        ws_retorno := prm_variavel;
    end case;

     return (trim(ws_retorno));

end vpcondicao;

FUNCTION CONVERT_PAR  ( prm_variavel      varchar2,
                        prm_aspas         varchar2 default null,
						prm_screen        varchar2 default null,
                        prm_pre_suf_alias varchar2 default null,
                        prm_ar_colref DBMS_SQL.VARCHAR2_TABLE default TP_VARCHAR2_TABLE,
                        prm_ar_colval DBMS_SQL.VARCHAR2_TABLE default TP_VARCHAR2_TABLE ) return varchar2 as

    ws_retorno   long;
    ws_pre       varchar(100);
    ws_suf       varchar(100);
    ws_col_real  varchar(1000);

begin

    ws_retorno := prm_variavel;

    if  substr(ws_retorno,1,2) = '$[' then
        ws_retorno := fun.gparametro(ws_retorno, prm_screen => prm_screen);
    end if;

    if  substr(ws_retorno,1,2) = '@[' then
        ws_retorno := fun.gvalor(ws_retorno, prm_screen => prm_screen);
    end if;
    
    -- Converte o nome da coluna pelo valor se foi informado o valor nos arrays passados por parâmetro
    if  instr(ws_retorno,'![') > 0 and prm_ar_colref.COUNT > 0 and prm_ar_colval.COUNT > 0 then 
        ws_pre := substr(prm_pre_suf_alias,1,instr(prm_pre_suf_alias,'|')-1);
        ws_suf := substr(prm_pre_suf_alias,instr(prm_pre_suf_alias,'|')+1,4000);
        for a in 1..prm_ar_colref.COUNT loop 
            ws_col_real := replace(replace('#'||prm_ar_colref(a)||'#', '#'||ws_pre, ''), ws_suf||'#','');
            ws_retorno := regexp_replace(ws_retorno, '\!\['||ws_col_real||'\]', prm_ar_colval(a),1,0,'i');
        end loop;
    end if; 

    if  UPPER(substr(ws_retorno,1,5)) = 'EXEC=' then
        ws_retorno := fun.xexec(ws_retorno, prm_screen);
    end if;

    return (prm_aspas||trim(ws_retorno)||prm_aspas);
exception when others then
    return prm_variavel;
end convert_par;

FUNCTION SUBVAR (  prm_texto varchar2 default null) return varchar2 as

 ws_texto varchar2(3000);
 ws_funcao varchar2(3000);
 ws_var  varchar2(1000);
 ws_agrupador varchar2(20);
 ws_tipo  varchar2(1);

 ws_count number;

begin

ws_count := 0;
ws_texto := prm_texto||'#FIM';
ws_funcao := '';

loop
    ws_count := ws_count + 1;
    if  substr(ws_texto,ws_count,4)='#FIM' then
        exit;
    end if;

    if  substr(ws_texto,ws_count,1) in ('$') then
        ws_tipo := substr(ws_texto,ws_count,1);
        ws_var  := '';
        ws_count := ws_count + 1;
        if  substr(ws_texto,ws_count,1)<>'[' then
            ws_funcao := ws_funcao||substr(ws_texto,(ws_count-1),1);
            ws_funcao := ws_funcao||substr(ws_texto, ws_count,   1);
        else
            loop
               ws_count  := ws_count + 1;
               if  substr(ws_texto,ws_count,1)=']' then
                   if  ws_tipo = '$' then
                       ws_funcao := ws_funcao||chr(39)||'||'||ws_var||'||'||chr(39);
                       exit;
                   end if;
               end if;
               ws_var := ws_var||substr(ws_texto,ws_count,1);
            end loop;
 end if;
    else
        ws_funcao := ws_funcao||substr(ws_texto,ws_count,1);
    end if;

end loop;

return(chr(39)||ws_funcao||chr(39));

end SUBVAR;

  /* CHECK_NETWALL - Verifica Permissões no NETWALL. */

FUNCTION CHECK_NETWALL ( prm_user  varchar2 default null, 
                         prm_ip    varchar2 default null ) return boolean as

    cursor crs_netwall is
    select * from user_netwall
    where trim(usuario) = upper(trim(prm_user))
    order by tipo_regra desc;

    ws_netwall    crs_netwall%rowtype;

    ws_dia_semana      char(1);
    ws_horario         integer;
    ws_remote_adr      varchar2(39);
    ws_check_pass      boolean := false;
    ws_ip_login        varchar2(100); 

begin

    ws_dia_semana := to_char(sysdate,'D');
    ws_horario    := to_char(sysdate,'HH24');
    ws_remote_adr := trim(owa_util.get_cgi_env('REMOTE_ADDR'));

	open crs_netwall;
		loop
			fetch crs_netwall into ws_netwall;
			exit when crs_netwall%notfound;

            if ws_netwall.tp_net_address = 'E' then  
                ws_ip_login := nvl(prm_ip, ' SEM IP EXTERNO'); 
            else     
                ws_ip_login := ws_remote_adr;
            end if; 

            if ws_ip_login <> 'SEM IP EXTERNO' then -- Não valida se a regra for de IP EXTERNO e não foi enviado o IP externo (o IP externo é enviado somente no momento do login)

                if ws_netwall.tipo_regra = 'L' then
                    if nvl(trim(ws_netwall.net_address),'NOADDR') = 'NOADDR' or trim(ws_netwall.net_address) = substr(ws_ip_login,1,length(trim(ws_netwall.net_address))) then
                            IF (WS_NETWALL.HR_INICIO=0 AND WS_NETWALL.HR_FINAL=24) OR (WS_HORARIO BETWEEN WS_NETWALL.HR_INICIO AND WS_NETWALL.HR_FINAL) OR (WS_NETWALL.HR_INICIO=99) OR (WS_NETWALL.HR_FINAL=99) THEN
                            if (ws_netwall.dia_semana = 0) or
                                (ws_netwall.dia_semana = ws_dia_semana) or
                                (ws_netwall.dia_semana = '9' and ws_dia_semana in ('7','1')) or
                                (ws_netwall.dia_semana = '8' and ws_dia_semana not in ('7','1')) then
                                ws_check_pass := true;
                            end if;
                        end if;
                    end if;
                end if;

                if ws_netwall.tipo_regra = 'B' then
                    if nvl(trim(ws_netwall.net_address),'NOADDR') = 'NOADDR' or trim(ws_netwall.net_address) = substr(ws_ip_login,1,length(trim(ws_netwall.net_address))) then
                            IF (WS_NETWALL.HR_INICIO=0 AND WS_NETWALL.HR_FINAL=24) OR (WS_HORARIO BETWEEN WS_NETWALL.HR_INICIO AND WS_NETWALL.HR_FINAL) OR (WS_NETWALL.HR_INICIO=99) OR (WS_NETWALL.HR_FINAL=99) THEN
                            if  (ws_netwall.dia_semana = 0) or
                                (ws_netwall.dia_semana = ws_dia_semana) or
                                (ws_netwall.dia_semana = '9' and ws_dia_semana in ('7','1')) or
                                (ws_netwall.dia_semana = '8' and ws_dia_semana not in ('7','1')) then
                                ws_check_pass := false;
                            end if;
                        end if;
                    end if;
                end if;
            end if; 

		end loop;
	close crs_netwall;
		
    return (ws_check_pass);
 
exception when others then
    
	ws_check_pass := false;
    return (ws_check_pass);
	
end CHECK_NETWALL;


FUNCTION APPLY_DRE_MASC ( prm_masc varchar default null,
                          prm_string varchar default null ) return varchar2 as

    ws_count      number;
    ws_pstring    number;
    ws_string_tmp varchar2(2000) := '';

begin

    ws_count   := 1;
    ws_pstring := 1;

    loop
        exit when ws_count > length(prm_masc) or
        ws_pstring > length(prm_string) or
        substr(prm_string,ws_pstring,1) = ' ';

        if substr(prm_masc,ws_count,1) = '.' then
            ws_string_tmp := ws_string_tmp||'.';
        else
            ws_string_tmp := ws_string_tmp||substr(prm_string,ws_pstring,1);
            ws_pstring := ws_pstring + 1;
        end if;
		
        ws_count := ws_count + 1;

    end loop;

 return (ws_string_tmp);

exception
    
	when others then
    return ('0');

end APPLY_DRE_MASC;

-----
-- Atenção: essa function foi copiada para a package ETF, a alteração realizada aqui deve ser replicada para a package ETF 
---------------------------------------------------------------------------------------------------------------------------------
PROCEDURE EXECUTE_NOW ( prm_comando  varchar2 default null,
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
        if fun.ret_var('CLIENTE') = '000000116' THEN  -- Quebra galho na Agrosul para compesar hora errada no JOB
            DBMS_JOB.SUBMIT(job => job_id, what => trim(prm_comando)||';', next_date => sysdate+((1/1440)/40)-((1/24)*2), interval => NULL);
        else 
            DBMS_JOB.SUBMIT(job => job_id, what => trim(prm_comando)||';', next_date => sysdate+((1/1440)/40), interval => NULL);
        end if;     
        commit;
    end if;
EXCEPTION WHEN OTHERS THEN
    insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - EXECUTE_NOW', gbl.getUsuario, 'ERRO');
    commit;
end EXECUTE_NOW;


FUNCTION GL_CALCULADA ( prm_texto        varchar2 default null,
                        prm_cd_coluna    varchar2 default null,
                        prm_vl_agrupador varchar2 default null,
						prm_tabela       varchar2 default null ) return varchar2 as
						
    ws_texto varchar2(3000);
    ws_funcao varchar2(3000);
    ws_var  varchar2(1000);
    ws_agrupador varchar2(20);
    ws_tipo  varchar2(1);
    ws_count number;
	ws_formula varchar2(2000);

begin

    ws_count := 0;
    ws_texto := upper(prm_texto)||'#';
    ws_funcao := '';

	loop
		ws_count := ws_count + 1;
		if  substr(ws_texto,ws_count,1)='#' then
			exit;
		end if;

		if  substr(ptg_trans(ws_texto),ws_count,1) in (',','_','Q','W','E','R','T','Y','U','I','O','P','A','S','D','F','G','H','J','K','L','Z','X','C','V','B','N','M') then
			ws_funcao := ws_funcao||substr(ws_texto,ws_count,1);
		end if;

		if  substr(ws_texto,ws_count,1) in ('+','-','/','*','(',')','>','<', chr(39), '|', '=', ':') then
			ws_funcao := ws_funcao||substr(ws_texto,ws_count,1);
		end if;

		if  substr(ws_texto,ws_count,1) in ('.','0','1','2','3','4','5','6','7','8','9') then
			ws_funcao := ws_funcao||substr(ws_texto,ws_count,1);
		end if;

		if  substr(ws_texto,ws_count,1) = '$' then
			ws_tipo := substr(ws_texto,ws_count,1);
			ws_var  := '';
			ws_count := ws_count + 1;
			if  substr(ws_texto,ws_count,1)<>'[' then
				return('ERRO');
			else
				loop
				   ws_count  := ws_count + 1;
				   If  Substr(Ws_Texto,Ws_Count,1)=']' Then
					   begin
							if instr(ws_var, '%') > 0 then
                              ws_funcao := ws_funcao||'(case when '||prm_cd_coluna||' like '||chr(39)||ws_var||chr(39)||' then '||prm_vl_agrupador||' else 0 end)';
                            else
                              ws_funcao := ws_funcao||'(case when '||prm_cd_coluna||' = '||chr(39)||ws_var||chr(39)||' then '||prm_vl_agrupador||' else 0 end)';
                            end if;
                       exception when others then
					   		ws_funcao := ws_funcao||'(case when '||prm_cd_coluna||' = '||chr(39)||ws_var||chr(39)||' then '||prm_vl_agrupador||' else 0 end)';
					   end;
					   exit;
				   end if;
				   ws_var := ws_var||substr(ws_texto,ws_count,1);
				end loop;
			end if;
		end if;

	end loop;

    return(ws_funcao);

end GL_CALCULADA;

Function LIST_POST ( Prm_Objeto     varchar2 default Null,
                     Prm_Parametros varchar2 default Null,
					 prm_group      varchar2 default null ) return TAB_MENSAGENS pipelined As

	Cursor Crs_Mensagens Is
         Select Dt_Post, Cd_Usuario, cd_group, Type_Text, select_line, post_id
         From  Text_Post Post
         Where (OBJECT_ID=prm_objeto) and
                (Trunc(to_date(Sysdate, 'DD-MM-YY'))-Trunc(to_date(Dt_Post, 'DD-MM-YY')) <= Time_Live OR Time_Live = '0') And
                ((user In (Select Cd_Usuario From gusers_itens Git Where Git.Cd_Group=Post.Cd_Group) Or user=Cd_Group) Or (user=Cd_Usuario) Or (cd_group='todos'))
				and (cd_group = nvl(prm_group, cd_group) or cd_usuario = nvl(prm_group, cd_usuario))
				order by dt_post;

    ws_mensagens   crs_mensagens%rowtype;

   	Ws_Count            Number := 1;

begin

        open crs_mensagens;
	      Loop
		        Fetch Crs_Mensagens Into Ws_Mensagens;
		              Exit When Crs_Mensagens%Notfound;

                          Select Count(*) into ws_count From 
                          (
                            Select Cd_Coluna, Max(Ct_Parametro) Ct_Parametro, Max(Ct_Msg) Ct_Msg From (
                                   Select Distinct Cd_Coluna, ' ' Ct_Parametro, Cd_Conteudo Ct_Msg From Table(fun.Vpipe_Par(ws_mensagens.select_line)) 
                                   Union All
                                   Select Distinct Cd_Coluna, Cd_Conteudo, ' ' From Table(fun.Vpipe_Par(prm_parametros))
                          ) Group By Cd_Coluna) Where Ct_Parametro <> Ct_Msg;

                          If  Ws_Count = 0 Then
                              Pipe Row (Ger_mensagens (ws_mensagens.dt_post, ws_mensagens.cd_usuario, ws_mensagens.cd_group, ws_mensagens.type_text, ws_mensagens.post_id));
                          end if;
		    End Loop;
        close crs_mensagens;

end LIST_POST;

Function LIST_ALL_POST ( Prm_Parametros varchar2 default null,
                         prm_group      varchar2 default null ) return TAB_MENSAGENS pipelined As

	Cursor Crs_Mensagens(prm_usuario varchar2) Is
         Select Dt_Post, Cd_Usuario, cd_group, Type_Text, select_line, post_id
         From  Text_Post Post
         Where (Trunc(to_date(Sysdate, 'DD-MM-YY'))-Trunc(to_date(Dt_Post, 'DD-MM-YY')) <= Time_Live OR Time_Live = '0') And
                ((prm_usuario In (Select Cd_Usuario From gusers_itens Git Where Git.Cd_Group=Post.Cd_Group) Or prm_usuario = Cd_Group) Or (prm_usuario = Cd_Usuario) Or (cd_group='todos'))
				and (cd_group = nvl(prm_group, cd_group) or cd_usuario = nvl(prm_group, cd_usuario))
				order by dt_post;

    ws_mensagens   crs_mensagens%rowtype;

   	Ws_Count            Number := 1;

begin

        open crs_mensagens(gbl.getUsuario);
	      Loop
		        Fetch Crs_Mensagens Into Ws_Mensagens;
		              Exit When Crs_Mensagens%Notfound;

                          Select Count(*) into ws_count From 
                          (
                            Select Cd_Coluna, Max(Ct_Parametro) Ct_Parametro, Max(Ct_Msg) Ct_Msg From (
                                   Select Distinct Cd_Coluna, ' ' Ct_Parametro, Cd_Conteudo Ct_Msg From Table(fun.Vpipe_Par(ws_mensagens.select_line)) 
                                   Union All
                                   Select Distinct Cd_Coluna, Cd_Conteudo, ' ' From Table(fun.Vpipe_Par(prm_parametros))
                          ) Group By Cd_Coluna) Where Ct_Parametro <> Ct_Msg;

                          If  Ws_Count = 0 Then
                              Pipe Row (Ger_mensagens (ws_mensagens.dt_post, ws_mensagens.cd_usuario, ws_mensagens.cd_group, ws_mensagens.type_text, ws_mensagens.post_id));
                          end if;
		    End Loop;
        close crs_mensagens;

end LIST_ALL_POST;

Function VERIFICA_POST ( prm_objeto     varchar2 Default Null,
                         prm_parametros varchar2 Default Null ) Return boolean As

 Cursor Crs_Mensagens Is
         Select Dt_Post, Cd_Usuario, Type_Text, select_line, cd_group
         From  Text_Post Post
         Where  OBJECT_ID=prm_objeto and
                Trunc(to_date(Sysdate, 'DD-MM-YY'))-Trunc(to_date(Dt_Post, 'DD-MM-YY')) <= Time_Live And
                ((user in (Select cd_Usuario From gusers_itens Git Where Git.Cd_Group=Post.Cd_Group)) or (Post.Cd_Group=user)  or (user=cd_usuario) Or (cd_group='todos'));

    ws_mensagens   crs_mensagens%rowtype;

    Ws_Count            Number := 1;

begin
        open crs_mensagens;
       Loop
          Fetch Crs_Mensagens Into Ws_Mensagens;
                Exit When Crs_Mensagens%Notfound;

                          Select Count(*) into ws_count From 
                          (
                            Select Cd_Coluna, Max(Ct_Parametro) Ct_Parametro, Max(Ct_Msg) Ct_Msg From (
                                   Select Distinct Cd_Coluna, ' ' Ct_Parametro, Cd_Conteudo Ct_Msg From Table(fun.Vpipe_Par(ws_mensagens.select_line)) 
                                   Union All
                                   Select Distinct Cd_Coluna, Cd_Conteudo, ' ' From Table(fun.Vpipe_Par(prm_parametros))
                          ) Group By Cd_Coluna) Where Ct_Parametro <> Ct_Msg;

                  exit when ws_count = 0;

      End Loop;
        close crs_mensagens;

        If  Ws_Count > 0 Then
            return(false);
        Else
            Return(true);
        End If;

end VERIFICA_POST;

function EXT_MASC ( prm_value varchar2 default null ) return varchar2 as

    ws_value varchar2(30);

begin

    case prm_value
    when ',' then
        ws_value := fun.lang('virgula');
    when '.' then
	    ws_value := fun.lang('ponto');
	when '-' then
	    ws_value := fun.lang('hífen');
	when ':' then
	    ws_value := fun.lang('dois pontos');
	else
	    ws_value := '';
	end case;
	
	return (ws_value);

end EXT_MASC;

function INIT_TEXT_POST return number is

    ws_count          number;

begin
        
    Select Count(*) into ws_count from text_post
    Where (cd_group = user or cd_group = 'todos' or cd_group in (select cd_group from gusers_itens t1 where t1.cd_usuario = user)) And
	cd_usuario <> user and
	cd_usuario <> 'SYS' and
    Post_Id Not In (Select Id_Post From Check_Post Where Cd_Usuario = user) and
	Trunc(to_date(Sysdate, 'DD-MM-YY'))-Trunc(to_date(Dt_Post, 'DD-MM-YY')) <= Time_Live and
	NVL(trim(select_line), '999999999') = '999999999';
    
	return(ws_count);
exception when others then
    return(0);
end INIT_TEXT_POST;

function check_permissao ( prm_objeto varchar2 default null, prm_usuario varchar2 default null) return char as

    ws_restrito    number;
    ws_exclusivo   number;
    ws_liberado    number;
    ws_saida       char(1) := 'N';
    ws_grupo     varchar2(200);

begin
    ws_grupo := nvl(gbl.getNivel,'N');

    begin
        
        -- se o objeto estiver com S é considerado a regra de liberado , se não ele considera a de restrição.
        if ws_grupo <> 'A' then
            IF FUN.GETPROP(PRM_OBJETO,'BLOQ_OBJ')='S' THEN
                
                select count(*) into ws_liberado
                from object_restriction
                where usuario    = nvl(prm_usuario, gbl.getusuario) and 
                    cd_objeto    = prm_objeto and
                    st_restricao = 'S'; 
            ELSE
                
                select count(*) into ws_restrito
                from object_restriction
                where usuario    = nvl(prm_usuario, gbl.getusuario) and
                    cd_objeto    = prm_objeto and
                    st_restricao = 'I';
            END IF;


            if ws_restrito <> 0 or ws_liberado = 0 then
                ws_saida := 'N';
            else
                ws_saida := 'S';
            end if;
        else
            ws_saida := 'S';
        end if;

    exception
        when others then
           ws_saida := 'N';
    end;

    return(ws_saida);

end check_permissao;





FUNCTION C2B ( p_clob IN CLOB ) RETURN BLOB is

  temp_blob   BLOB;
  dest_offset NUMBER  := 1;
  src_offset  NUMBER  := 1;
  amount      INTEGER := dbms_lob.lobmaxsize;
  blob_csid   NUMBER  := dbms_lob.default_csid;
  lang_ctx    INTEGER := dbms_lob.default_lang_ctx;
  warning     INTEGER;
BEGIN
 DBMS_LOB.CREATETEMPORARY(lob_loc=>temp_blob, cache=>TRUE);

  DBMS_LOB.CONVERTTOBLOB(temp_blob, p_clob,amount,dest_offset,src_offset,blob_csid,lang_ctx,warning);
  Return Temp_Blob;
END C2B;


FUNCTION NSLOOKUP ( PRM_ENDERECO varchar default null ) return varchar2 as

   ws_NOME      VARCHAR2(2000);
   ws_erro      exception;

Begin

  Begin
      WS_NOME := Utl_Inaddr.Get_Host_Name(Trim(Prm_Endereco));
  Exception
      When Others Then
           WS_NOME := 'NO_NAME';
  END;

   Return (WS_NOME);

exception
   When Others Then
      return ('ERRO');

end NSLOOKUP;

-----
-- Atenção: essa function foi copiada para a package ETF, a alteração realizada aqui deve ser replicada para a package ETF 
---------------------------------------------------------------------------------------------------------------------------------
FUNCTION LANG ( prm_texto varchar2 default null ) return varchar2 as

    ws_traduzido   varchar2(4000);
    ws_padrao      varchar2(40);
    ws_cont        integer;    
Begin
    
    ws_padrao := gbl.getLang;
    if nvl(fun.ret_var('LANG'), 'N') = 'S' and ws_padrao <> fun.ret_var('LANG_SYS') then
        ws_traduzido := prm_texto;

        select max(decode(ws_padrao,'ENGLISH', traduzido_ingles,
                                    'SPANISH', traduzido_espanhol, 
                                    'ITALIAN', traduzido_italiano,
                                    'GERMAN',  traduzido_alemao, null)
                  )
          into ws_traduzido
          from utl_traducoes_feitas 
         where texto=prm_texto;
        
        -- Não faz insert direto, porque function não permite insert quando usada num select 
        if ws_traduzido is null then 
            ws_traduzido := '*'||prm_texto;
            if nvl(upd.ret_var('TIPO_AMBIENTE'),'PRODUCAO') = 'DESENV' then
                begin
                    fun.EXECUTE_NOW('begin INSERT INTO UTL_TRANSLATIONS VALUES ('''||prm_texto||'''); end ');
                exception when others then
                    null;
                end; 
            end if;    
        end if; 

        /* 
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
        */ 
        
        return ws_traduzido;

    else
        return prm_texto;
    end if;

end LANG;


--------------------------------------------------------------------------------------------------------------------
-- ATENÇÃO, essa função só funciona na base desenv porque precisa de liberação de acesso ao servidor '172.1.1.43'
--------------------------------------------------------------------------------------------------------------------
FUNCTION GET_TRANSLATOR ( prm_texto        varchar2,
                          prm_origem_lang  varchar2,
                          prm_destino_lang varchar2 ) return varchar2 as 
    c  utl_tcp.connection;
    ret_val varchar2(32767);
    conteudo varchar2(32767);
    reading varchar2(32767);
    test    raw(32767);
    len  PLS_INTEGER;
    w_fluxo number  := 1;
    cmd varchar2(4000);
    ws_nmb     number;
BEGIN
    --c := utl_tcp.open_connection(remote_host => '172.1.1.43', remote_port =>  8025, charset => 'UTF-8');
    c := utl_tcp.open_connection(remote_host => '187.108.204.153', remote_port =>  8025, charset => 'UTF-8');
    cmd:=PRM_ORIGEM_LANG||'|'||PRM_DESTINO_LANG||'|'||prm_texto;
    ret_val := utl_tcp.write_line(c, cmd);
    w_fluxo := UTL_TCP.AVAILABLE(C,0);
    len := 1;
    while len > 0 loop
       begin
          reading := utl_tcp.read_line(c,conteudo);
       exception when others then
            null;
       end;
       begin
           ws_nmb := UTL_TCP.AVAILABLE(C,0);
       exception WHEN UTL_TCP.END_OF_INPUT THEN
            len := 0;
       end;
       conteudo := conteudo;
    end loop;

    utl_tcp.close_connection(c);
    RETURN(conteudo);
exception when others then 
    RETURN('[#@ERRO@#]');

/* 
     ws_request varchar2(4000);
BEGIN
    ws_request := UTL_HTTP.REQUEST('http://translate.google.com/translate_a/t?client=j'||chr(38)||'text='||trim(replace(prm_texto, ' ', '+'))||chr(38)||'hl=pt'||chr(38)||'sl='||prm_origem_lang||chr(38)||'tl='||prm_destino_lang);
    ws_request := REGEXP_SUBSTR(ws_request,'trans\":(\".*?\"),\"');
    ws_request := substr(ws_request,9,length(ws_request)-11);
    return(ws_request);
    */ 
END GET_TRANSLATOR;

function ret_par ( prm_sessao varchar2 ) return varchar2 as

    ws_padrao varchar2(80);

begin

    begin
        select CONTEUDO into ws_padrao
        from   PARAMETRO_USUARIO
        where  cd_usuario = (select conteudo from var_conteudo where usuario = prm_sessao and variavel = 'USUARIO') and
               cd_padrao='CD_LINGUAGEM';
    exception
        when others then
            ws_padrao := 'PORTUGUESE';
    end;

    return ws_padrao;

end;

FUNCTION UTRANSLATE ( prm_cd_coluna varchar2,
                      prm_tabela    varchar2,
                      prm_default   varchar2,
                      prm_padrao    varchar2 default 'PORTUGUESE') return varchar2 as
    ws_padrao      varchar2(40);
    ws_texto       varchar2(4000);
begin
    -- Se a tradução foi ativada e o idioma do usuário for diferente do idioma nativo do BI 
    if nvl(fun.ret_var('LANG'), 'N') = 'S' and nvl(fun.ret_var('LANG_SYS'), 'N') <> prm_padrao then
        begin
            select texto into ws_texto
            from   traducao_colunas
            WHERE cd_tabela    = upper(prm_tabela) 
              and cd_coluna    = upper(prm_cd_coluna) 
              and cd_linguagem = prm_padrao 
              and lang_default = prm_default;
            if ws_texto  is null then 
                ws_texto := prm_default;
            end if; 
        exception when others then
            ws_texto := prm_default;
        end;
        return (trim(ws_texto));
    else
        return prm_default;
    end if;
end UTRANSLATE;

FUNCTION LIST_VIEW ( prm_tipo char default null) return varchar2 as

    ws_grupo varchar2(40) := '999999999';
	ws_resultado long;

begin

    ws_resultado := '<option selected disabled hidden value="">'||fun.lang('SELECIONE UMA VIEW')||'</option>';
	
	if prm_tipo = 'T' then
	    ws_resultado := ws_resultado||'<option value="">'||fun.lang('TODAS')||'</option>';
	end if;
	
    for i in (select nm_micro_visao, ds_micro_visao, cd_grupo_funcao from micro_visao order by cd_grupo_funcao, nm_micro_visao) loop
	    if(ws_grupo <> i.cd_grupo_funcao) then
	        ws_resultado := ws_resultado||'<optgroup label="'||fun.utranslate('CD_GRUPO', 'GRUPOS_FUNCAO', i.cd_grupo_funcao)||'"></optgroup>';
		    ws_grupo := i.cd_grupo_funcao;
	    end if;
	    ws_resultado := ws_resultado||'<option value="'||i.nm_micro_visao||'">['||fun.utranslate('NM_MICRO_VISAO', 'MICRO_VISAO', i.nm_micro_visao)||'] '||fun.utranslate('DS_MICRO_VISAO', 'MICRO_VISAO', i.ds_micro_visao)||' </option>';
	end loop;
  
    return ws_resultado;

exception when others then
    return '';
end LIST_VIEW;

/**** Precedure descontinuada 
Procedure Request_Progs As

   Cursor Crs_Seq (prm_dados varchar2 ) Is
           Select Column_Value
           From   table(fun.vpipe(prm_dados));

   Ws_Seq  			Crs_Seq%Rowtype;

   Cursor Crs_Upseq (prm_nova_versao number) is
           Select   Sequencia,
                    Versao_Sistema,
                    Nm_Conteudo,
                    Tipo,
                    Name,
                    Mime_Type,
                    Doc_Size,
                    Dad_Charset,
                    Last_Updated,
                    Content_Type
           From     Update_Sequence
           Where    Versao_Sistema=Prm_Nova_Versao
           order by sequencia;

   Ws_upSeq  			Crs_upSeq%Rowtype;

   ws_pieces        UTL_HTTP.HTML_PIECES;

   WS_DADOS         varchar2(4000);
   ws_variavel      varchar2(8000);
   Ws_Temp          Clob;
   ws_temp_long     long;
   Ws_Nova_Versao   Number       := Null;
   Ws_Ctcol         Number;
   Ws_Lob_Len       Number;
   v_intCur         pls_integer;
   v_intIdx         pls_integer;
   V_Intnumrows     Pls_Integer;
   V_Vcstmt         Dbms_Sql.Varchar2a;
   ws_itens         Dbms_Sql.Varchar2a;
   Len              Pls_Integer;
   Prm_Tipo         Varchar2(30) := 'JAVA_SCRIPT';
   Prm_Conteudo     Varchar2(80) := 'TESTE_JAVA';
   Prm_Versao       Number       := 0;
   WS_URL           VARCHAR2(4000);
   ws_count         number;

Begin

    --Sequência de Colunas
    --01-Sequencia
    --02-Versao_Sistema
    --03-Nm_Conteudo
    --04-Tipo
    --05-Name
    --06-Mime_Type
    --07-Doc_Size
    --08-Dad_Charset
    --09-Last_Updated
    --10-Content_Type


    execute immediate ('truncate table UPDATE_SEQUENCE');

    ws_ctcol := 0;

    Ws_URL   :=  'http://'||upd.ret_var('URL_UPDATE')||'/'||nvl(fun.ret_var('OWNER_BI'),'DWU')||'.GET_PROGS?Prm_Senha=XXXX&Prm_Conteudo=LIST_SCRIPTS&prm_versao='||Prm_Versao||'&prm_tipo=GET_LIST';
    Ws_Dados :=  Utl_Http.Request(WS_URL);

    open crs_seq(ws_dados);
        Loop
            Fetch Crs_Seq Into Ws_Seq;
            Exit When Crs_Seq%Notfound;

            Ws_Ctcol := Ws_Ctcol + 1;
            Ws_Itens(Ws_Ctcol) := trim(Ws_Seq.Column_Value);
            If  Ws_Ctcol = 10 Then
                Ws_Ctcol := 0;
                Insert Into Update_Sequence Values (trim(Ws_Itens(1)),trim(Ws_Itens(2)),trim(Ws_Itens(3)),trim(Ws_Itens(4)),trim(Ws_Itens(5)),trim(Ws_Itens(6)),trim(Ws_Itens(7)),trim(Ws_Itens(8)),to_date(nvl(trim(wS_itens(9)),'010199'),'ddmmyy'),trim(Ws_Itens(10)));
                If  Ws_Nova_Versao Is Null Then
                    ws_nova_versao := ws_itens(2);
                End If;
                commit;
            End If;

        End Loop;   
    Close Crs_Seq;

    Open Crs_Upseq(Ws_Nova_Versao);
    Loop
    Fetch Crs_Upseq Into Ws_upSeq;
          Exit When Crs_upSeq%Notfound;

          WS_URL    := 'http://'||upd.ret_var('URL_UPDATE')||'/'||nvl(fun.ret_var('OWNER_BI'),'DWU')||'.get_progs?Prm_Senha=XXXX&Prm_Conteudo='||trim(ws_upseq.nm_conteudo)||'&prm_versao='||trim(ws_upseq.versao_sistema)||'&prm_tipo='||trim(ws_upseq.tipo);
          Ws_Pieces :=  Utl_Http.Request_Pieces(WS_URL,65535);

          if  ws_upseq.tipo IN ('PROCEDURE','PACKAGE_SPEC','PACKAGE_BODY','FUNCTION') then
              Len := 1;
              V_Vcstmt(Len) := '';

              For I In 1..Ws_Pieces.Count Loop

                      if  instr(ws_pieces(I),chr(10)) = 0 then
                           V_Vcstmt(Len) := V_Vcstmt(Len)||substr(ws_pieces(I),1,length(ws_pieces(I)));
                      else
                           V_Vcstmt(Len) := V_Vcstmt(Len)||substr(ws_pieces(I),1,instr(ws_pieces(I),chr(10)));
                           Len := Len + 1;
                           V_Vcstmt(Len) := '';
                           V_Vcstmt(Len) := V_Vcstmt(Len)||substr(ws_pieces(I),(instr(ws_pieces(I),chr(10))+1),length(ws_pieces(I)));
                      end if;

              End Loop;

              V_Intidx := len;
              V_Intcur := Dbms_Sql.Open_Cursor;
              Dbms_Sql.Parse( C => V_Intcur, Statement => V_Vcstmt, Lb => 1, Ub => V_Intidx, Lfflg => false, Language_Flag => Dbms_Sql.Native);
              V_Intnumrows := Dbms_Sql.Execute(V_Intcur);
              Dbms_Sql.Close_Cursor(V_Intcur);

          End If;


          If  Ws_Upseq.Tipo = 'DOCUMENTO' Then
              Ws_Temp := '';
              Len := 0;
              For I In 1..Ws_Pieces.Count Loop
                  Ws_Temp := Ws_Temp||Ws_Pieces(I);
              End Loop;
              Delete From tab_documentos Where name=ws_upseq.name;
              Commit;
              Insert Into tab_documentos Values (ws_upseq.name,ws_upseq.mime_type,ws_upseq.doc_size,ws_upseq.dad_charset,ws_upseq.last_updated,ws_upseq.content_type,fun.C2B(Ws_Temp), gbl.getUsuario);
              Commit;
          end if;

          If  Ws_Upseq.Tipo = 'SCRIPT' Then
              Ws_Temp_LONG := '';
              Len := 0;
              For I In 1..Ws_Pieces.Count Loop
                  Ws_Temp_LONG := Ws_Temp_LONG||Ws_Pieces(I);
              End Loop;
              EXECUTE IMMEDIATE WS_TEMP_LONG;
              Commit;
          end if;

    End Loop;
    Close Crs_Upseq;

End Request_Progs;
*************************************************************************/


FUNCTION CONVERT_CALENDAR ( prm_valor varchar2 default null,
                            prm_tipo varchar2 default null ) return varchar2 as
			
begin
    if prm_valor <> 'todos' then
		if prm_tipo = 'mes' then
			case to_number(prm_valor)
				when '1' then
					return fun.lang('janeiro');
				when '2' then
					return fun.lang('fevereiro');
				when '3' then
					return fun.lang('mar&ccedil;o');
				when '4' then
					return fun.lang('abril');
				when '5' then
					return fun.lang('maio');
				when '6' then
					return fun.lang('junho');
				when '7' then
					return fun.lang('julho');
				when '8' then
					return fun.lang('agosto');
				when '9' then
					return fun.lang('setembro');
				when '10' then
					return fun.lang('outubro');
				when '11' then
					return fun.lang('novembro');
				else
					return fun.lang('dezembro');
			end case;
		else
			case to_number(prm_valor)
				when '1' then
					return fun.lang('domingo');
				when '2' then
					return fun.lang('segunda-feira');
				when '3' then
					return fun.lang('ter&ccedil;a-feira');
				when '4' then
					return fun.lang('quarta-feira');
				when '5' then
					return fun.lang('quinta-feira');
				when '6' then
					return fun.lang('sexta');
				else
					return fun.lang('sabado');
			end case;
	    end if;
	else
	    return 'todos';
	end if;

end CONVERT_CALENDAR;

FUNCTION XFORMULA ( prm_texto  varchar2 default null, 
                    prm_screen varchar2 default null,
                    prm_space  varchar2 default 'N' ) return varchar2 as

    ws_texto          varchar2(3000);
    ws_funcao         varchar2(3000);
    ws_var            varchar2(1000);
    ws_agrupador      varchar2(20);
    ws_tipo           varchar2(1);
    ws_calculada      varchar2(1);
    ws_formula        varchar2(4000);

    ws_count          number;

begin

    ws_count := 0;
    ws_texto := upper(prm_texto)||'#';
    ws_funcao := '';

loop
    ws_count := ws_count + 1;
    if  substr(ws_texto,ws_count,1)='#' then
        exit;
    end if;

    if  substr(ptg_trans2(ws_texto),ws_count,1) in (',','_','Q','W','E','R','T','Y','U','I','O','P','A','S','D','F','G','H','J','K','L','Z','X','C','V','B','N','M') then
        ws_funcao := ws_funcao||substr(ws_texto,ws_count,1);
    end if;

    if  prm_space = 'S' then
        if  substr(ws_texto,ws_count,1) = ' ' then
            ws_funcao := ws_funcao||substr(ws_texto,ws_count,1);
        end if;
    end if;

    if  substr(ws_texto,ws_count,1) in ('|','+','-','/','*','(',')','>', '<', chr(39), '=', ':') then
        ws_funcao := ws_funcao||substr(ws_texto,ws_count,1);
    end if;

    if  substr(ws_texto,ws_count,1) in ('.','0','1','2','3','4','5','6','7','8','9') then
        ws_funcao := ws_funcao||substr(ws_texto,ws_count,1);
    end if;

    if  substr(ws_texto,ws_count,1) in ('$','@','&') then
        ws_tipo := substr(ws_texto,ws_count,1);
        ws_var  := '';
        ws_count := ws_count + 1;
        if  substr(ws_texto,ws_count,1)<>'[' then
            return('ERRO');
        else
            loop
               ws_count  := ws_count + 1;
               if  substr(ws_texto,ws_count,1)=']' then
                   if  ws_tipo = '$' then
                       ws_funcao := ws_funcao||chr(39)||fun.gparametro('$['||ws_var||']', prm_screen => prm_screen)||chr(39);
                   else
                       if  ws_tipo = '&' then
                           ws_funcao := ws_funcao||chr(39)||fun.gparametro('$['||ws_var||']', prm_screen => prm_screen)||chr(39);
                       else
                           ws_funcao := ws_funcao||fun.gvalor(ws_var);
                       end if;
                  end if;
                  exit;
               end if;
               ws_var := ws_var||substr(ws_texto,ws_count,1);
             end loop;
        end if;
    end if;

end loop;

return(ws_funcao);

end XFORMULA;

FUNCTION URLENCODE ( p_str in varchar2 ) return varchar2 as   
       
    l_tmp   varchar2(6000);  
    l_bad   varchar2(100) default ' >%}\~];?@&<#{|^[`/:=$+''"';  
    l_char  char(1);  
begin  
    for i in 1 .. nvl(length(p_str),0) loop  
        l_char :=  substr(p_str,i,1);  
        if ( instr( l_bad, l_char ) > 0 )  
        then  
            l_tmp := l_tmp || '%' ||  
                            to_char( ascii(l_char), 'fmXX' );  
        else  
            l_tmp := l_tmp || l_char;  
        end if;  
    end loop;  
    
    return l_tmp;  
end URLENCODE;

FUNCTION CHECK_ROTULOC ( prm_coluna varchar2 default null,
                         prm_visao varchar2 default null,
						 prm_screen varchar2 default null,
                         prm_ordem  varchar2 default 'inversa' ) return varchar2 as
										 
	ws_tem varchar2(4000);
	ws_tot varchar2(4000);
    ws_padrao varchar2(80);
										 
begin

    for i in(select column_value from table((fun.vpipe(prm_coluna)))) loop

	    select nvl(trim(rotulo_c), 'N/A') into ws_tem from micro_coluna where cd_coluna = replace(i.column_value, '|', '') and cd_micro_visao = prm_visao;
		
		if ws_tem = 'N/A' then
		    ws_padrao := gbl.getLang;
            select fun.utranslate('NM_ROTULO', prm_visao, nm_rotulo, ws_padrao) into ws_tem from micro_coluna where cd_coluna = replace(i.column_value, '|', '') and cd_micro_visao = prm_visao;
		else
            ws_tem := replace(ws_tem, chr(10), '<BR>');
		    ws_tem := fun.xexec('EXEC='||replace(ws_tem, '$[CONCAT]','||'), prm_screen);
			if nvl(trim(ws_tem), 'N/A') = 'N/A' then
			    select nm_rotulo into ws_tem from micro_coluna where cd_coluna = replace(i.column_value, '|', '') and cd_micro_visao = prm_visao;
			end if;
		end if;

        ws_tem := replace(ws_tem, '<BR>', chr(10));
		if prm_ordem = 'inversa' then 
		   ws_tot := ws_tem||'|'||ws_tot;
        else 
           if nvl(ws_tot,' ') <> ' ' then 
              ws_tot := ws_tot||'|';
            end if;
            ws_tot := ws_tot||ws_tem;  
        end if;    

		
    end loop;
    
    if length(ws_tot) > 0 then
  	    if prm_ordem = 'inversa' then 
		   ws_tot := substr(ws_tot, 0, length(ws_tot)-1);
        end if; 
    end if;
	
    return trim(ws_tot);
exception when others then
    return trim(prm_coluna);
end CHECK_ROTULOC;


FUNCTION CONV_TEMPLATE ( prm_micro_visao varchar2 default null,
                         prm_agrupadores varchar2 default null ) return VARCHAR2 is
	     
		 
    ws_agrupador varchar2(10);
    ws_formula varchar2(3000);
	ws_count number;
    begin

    select count(*) into ws_count from (select nvl(column_value, 'N/A') as valor from table(fun.vpipe((select nvl(propriedade, 'N/A') from object_attrib where cd_prop = 'TPT' and owner = gbl.getUsuario and cd_object = prm_agrupadores and rownum = 1 and screen = prm_micro_visao)))) where valor <> 'N/A';
   
    select st_agrupador, formula 
		into ws_agrupador, ws_formula 
		from micro_coluna 
		where cd_coluna = (select column_value from table(fun.vpipe((prm_agrupadores))) where rownum = 1) and cd_micro_visao = prm_micro_visao;

	if ws_count <> 0 then
		 select propriedade into ws_formula from object_attrib where cd_prop = 'TPT' and owner = gbl.getUsuario and cd_object = prm_agrupadores and rownum = 1 and screen = prm_micro_visao;
		 ws_formula := substr(ws_formula,2,length(ws_formula));
	end if;
	
    if ws_agrupador <> 'TPT' then
	    ws_formula := prm_agrupadores;
	end if;
	
	
	return(ws_formula);
end CONV_TEMPLATE; 

FUNCTION B2C ( p_blob blob ) return clob is
      l_clob         clob;
      l_dest_offsset integer := 1;
      l_src_offsset  integer := 1;
      l_lang_context integer := dbms_lob.default_lang_ctx;
      l_warning      integer;

begin

      if p_blob is null then
         return null;
      end if;

      dbms_lob.createTemporary(lob_loc => l_clob
                              ,cache   => false);

      dbms_lob.converttoclob(dest_lob     => l_clob
                            ,src_blob     => p_blob
                            ,amount       => dbms_lob.lobmaxsize
                            ,dest_offset  => l_dest_offsset
                            ,src_offset   => l_src_offsset
                            ,blob_csid    => dbms_lob.default_csid
                            ,lang_context => l_lang_context
                            ,warning      => l_warning);

      return l_clob;

end B2C;


FUNCTION CLEAR_PARAMETRO ( prm_parametros varchar2 default null ) return clob is
    
	ws_parametros    long;
	ws_parametros_f  long;
	ws_count         number;
	
	begin

		if prm_parametros <> '1|1' and substr(prm_parametros,1,3) = '1|1' then
	        if substr(prm_parametros,1,4)='1|1|' then
		        ws_parametros := substr(prm_parametros,5,length(prm_parametros));
			else
		        ws_parametros := substr(prm_parametros,4,length(prm_parametros));
			end if;
		else
			ws_parametros := prm_parametros;
		end if;

		if prm_parametros <> '1|1' and substr(prm_parametros,1,6) = '1|11|1' then
	        ws_parametros := substr(prm_parametros,8,length(prm_parametros));
		end if;

		ws_parametros := ws_parametros||'|';

		ws_parametros := trim(replace(ws_parametros,'||','|'));

		if nvl(trim(ws_parametros),'%X%')='%X%' then
		    ws_parametros := '1|1';
		end if;
		
		ws_count := 0;
		
		for i in(select distinct cd_coluna, cd_conteudo, cd_condicao from table(fun.vpipe_par(ws_parametros))) loop
		    if ws_count = 0 then
			    ws_parametros_f := i.cd_coluna||'|'||i.cd_condicao||i.cd_conteudo; 
			else
			    ws_parametros_f := ws_parametros_f||'|'||i.cd_coluna||'|'||i.cd_condicao||i.cd_conteudo; 
			end if;
			ws_count := ws_count+1;
		end loop;
	
    return(ws_parametros_f);
end CLEAR_PARAMETRO;


FUNCTION CHECK_SESSION return varchar2 as

      Ws_Local        Owa_Cookie.Cookie;
      Ws_retorno      Varchar2(40);
      Ws_Count        Number;

begin

    begin
        Update Active_Sessions
        Set Status='I'
        Where Status='A' And Dt_Atividade < (Sysdate-((1/1440)*30));
        commit;
    exception
        when others then
            null;
    end;

    begin
        Ws_Local := Owa_Cookie.Get('UPQ_SESSION_CHECK');

        if  Ws_Local.Vals.First Is Null Then
            ws_retorno := 'OK';
        else
            select count(*) into ws_count 
            from   Active_Sessions
            Where  Usuario = gbl.getUsuario And
                Status='A';
            if  ws_count = 0 then
                ws_retorno := 'NO_S';
            else
                ws_retorno := 'OK';
            end if;
        end if;
    exception
        when others then
            ws_retorno := 'NO_S';
    end;

   return(ws_retorno);

End CHECK_SESSION;

-----
-- Atenção: essa function foi copiada para a package ETF, a alteração realizada aqui deve ser replicada para a package ETF 
---------------------------------------------------------------------------------------------------------------------------------
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

-----
-- Atenção: essa function foi copiada para a package ETF, a alteração realizada aqui deve ser replicada para a package ETF 
---------------------------------------------------------------------------------------------------------------------------------
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



function check_token ( prm_chave varchar2 default null, prm_cliente varchar2 default null ) return varchar2 as

	type tp_array is table of varchar2(2000) index by binary_integer;
	ws_array tp_array;
	ws_counter integer;

	ws_indice      number;
	ws_indice_fake number;
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

	ws_indice := (instr(ws_array(5),substr(prm_chave,6,1)))-1;
	ws_indice_fake := (instr(ws_array(4),substr(prm_chave,7,1)))-1;

	ws_session := (instr(ws_array(abs(ws_indice - ws_indice_fake)), substr(prm_chave,4,1))-1) ||
	(instr(ws_array(abs(ws_indice - ws_indice_fake)), substr(prm_chave,5,1))-1);

	ws_check_imei := (instr(ws_array(ws_indice_fake),substr(prm_chave,1,1))-1) ||
	(instr(ws_array(ws_indice_fake),substr(prm_chave,2,1))-1) ||
	(instr(ws_array(ws_indice_fake),substr(prm_chave,3,1))-1);

	return(ws_session||ws_check_imei);

end check_token;


-----
-- Atenção: essa function foi copiada para a package ETF, a alteração realizada aqui deve ser replicada para a package ETF 
---------------------------------------------------------------------------------------------------------------------------------
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
        ws_ant_chave   := fun.send_id;
        ws_chave       := ws_ant_chave||fun.check_id(ws_ant_chave);
        ws_tempo       := to_char(sysdate,'DDMMYYYYHH24MISS');

        dbms_output.put_line('a1');

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


FUNCTION SHOWTAG ( prm_obj varchar2 default null,
                   prm_tag varchar2 default null,
				   prm_outro varchar2 default null ) return varchar2 as
									 
	ws_talk varchar2(40) := 'talk';
	ws_count number;

begin
    case prm_tag
	when 'excel' then
	select count(*) into ws_count from usuarios where usu_nome = gbl.getUsuario and nvl(excel_out, 'S') = 'S';
		if ws_count = 1 or gbl.getNivel = 'A' then
            return '<span class="excel" title="'||FUN.LANG('Exportar para excel')||'"></span>';
		else
		    return '<span class="noexcel" title="'||FUN.LANG('Exportar para excel bloqueado')||'"></span>';
		end if;
	when 'post' then
	    return '<span class="'||ws_talk||'" title="Text-post"></span>';
    when 'atrib' then
	    return '<span class="size" title="'||fun.lang('Atributos')||'" ></span>';	
    when 'remove' then
	    return '<span class="removeobj" title="'||fun.lang('Excluir')||'" ></span>';		
    when 'filter' then
        return '<span class="filter" title="'||fun.lang('Filtros')||'"></span>';    	
	when 'export' then
	    return '<span class="page_'||prm_outro||'" title="'||fun.lang('Exportar em '||prm_outro||'')||'"></span>';									
	when 'exportnew' then
	    return '<span class="page_png" title="'||fun.lang('Exportar em PNG')||'"><a id="'||prm_obj||'link" href="" download="grafico.jpg" style="height: inherit; width: inherit; float: left;"></a></span>';									
	when 'star' then
	    return '<span class="star" title="'||fun.lang('Alterar Destaque')||'"></span>';
	when 'fav' then
        return '<span title="'||fun.lang('Marcar objeto')||'" class="fav" onclick="var ident = document.getElementById('''||prm_obj||''').parentNode.parentNode.parentNode.id; loading(); ajax(''fly'', ''favoritar'', ''prm_objeto='||fun.get_cd_obj(prm_obj)||'&prm_nome=''+document.getElementById(ident+''_ds'').innerHTML+''&prm_url=&prm_screen=''+document.getElementById(''current_screen'').value+''&prm_parametros=''+encodeURIComponent(document.getElementById(''par_''+ident).value)+''&prm_dimensao=''+encodeURIComponent(document.getElementById(''col_''+ident).value)+''&prm_medida=''+encodeURIComponent(document.getElementById(''agp_''+ident).value)+''&prm_pivot=''+encodeURIComponent(document.getElementById(''cup_''+ident).value)+''&prm_acao=incluir'', false); loading(); call(''obj_screen_count'', ''prm_screen=''+tela+''&prm_tipo=FAVORITOS'').then(function(resposta){ if(parseInt(resposta) > 0){ document.getElementById(''favoritos'').classList.remove(''inv''); } else { document.getElementById(''favoritos'').classList.add(''inv''); } });"><svg style="height: 16px; width: 16px;" version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" 	 width="613.408px" height="613.408px" viewBox="0 0 613.408 613.408" style="enable-background:new 0 0 613.408 613.408;" 	 xml:space="preserve"> <g> 	<path d="M605.254,168.94L443.792,7.457c-6.924-6.882-17.102-9.239-26.319-6.069c-9.177,3.128-15.809,11.241-17.019,20.855 		l-9.093,70.512L267.585,216.428h-142.65c-10.344,0-19.625,6.215-23.629,15.746c-3.92,9.573-1.71,20.522,5.589,27.779 		l105.424,105.403L0.699,613.408l246.635-212.869l105.423,105.402c4.881,4.881,11.45,7.467,17.999,7.467 		c3.295,0,6.632-0.709,9.78-2.002c9.573-3.922,15.726-13.244,15.726-23.504V345.168l123.839-123.714l70.429-9.176 		c9.614-1.251,17.727-7.862,20.813-17.039C614.472,186.021,612.136,175.801,605.254,168.94z M504.856,171.985 		c-5.568,0.751-10.762,3.232-14.745,7.237L352.758,316.596c-4.796,4.775-7.466,11.242-7.466,18.041v91.742L186.437,267.481h91.68 		c6.757,0,13.243-2.669,18.04-7.466L433.51,122.766c3.983-3.983,6.569-9.176,7.258-14.786l3.629-27.696l88.155,88.114 		L504.856,171.985z"/> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg></span>';
	when 'clone' then
        return '<span title="'||fun.lang('Duplicar Objeto')||'" class="clone" onclick="clone_object('''||prm_obj||''');">'||
                  '<svg xmlns="http://www.w3.org/2000/svg" width="18" height="24" viewBox="0 0 24 20"><path d="M13.508 11.504l.93-2.494 2.998 6.268-6.31 2.779.894-2.478s-8.271-4.205-7.924-11.58c2.716 5.939 9.412 7.505 9.412 7.505zm7.492-9.504v-2h-21v21h2v-19h19zm-14.633 2c.441.757.958 1.422 1.521 2h14.112v16h-16v-8.548c-.713-.752-1.4-1.615-2-2.576v13.124h20v-20h-17.633z"/></svg></span>';
    else
	    return '';
	end case;

end SHOWTAG;

FUNCTION CHECK_VALUE ( prm_valor varchar2 default null ) return varchar2 is

begin
    if length(trim(prm_valor)) = 0 then 
	    return ''; 
	else 
	    return replace('|'||trim(prm_valor), '||', '|'); 
	end if;
exception when others then
    return '';
end check_value;


FUNCTION PTG_TRANS ( PRM_TEXTO IN VARCHAR2 ) RETURN VARCHAR2 IS

WS_RETORNO VARCHAR2(32000);

BEGIN
  WS_RETORNO := TRANSLATE( PRM_TEXTO,
                    'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜáçéíóúàèìòùâêîôûãõëü',
                    'ACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeu');

  RETURN WS_RETORNO;

END PTG_TRANS;


function html_trans ( prm_texto in clob ) return clob is 

ws_retorno clob;
begin

    ws_retorno := prm_texto; 
    ws_retorno := replace(ws_retorno, '&', '&amp;');    
    ws_retorno := replace(ws_retorno, 'Á', '&Aacute;');
    ws_retorno := replace(ws_retorno, 'É', '&Eacute;');
    ws_retorno := replace(ws_retorno, 'Í', '&Iacute;');
    ws_retorno := replace(ws_retorno, 'Ó', '&Oacute;');
    ws_retorno := replace(ws_retorno, 'Ú', '&Uacute;');
    ws_retorno := replace(ws_retorno, 'á', '&aacute;');
    ws_retorno := replace(ws_retorno, 'é', '&eacute;');
    ws_retorno := replace(ws_retorno, 'í', '&iacute;');
    ws_retorno := replace(ws_retorno, 'ó', '&oacute;');
    ws_retorno := replace(ws_retorno, 'ú', '&uacute;');
    ws_retorno := replace(ws_retorno, 'Â', '&Acirc;');
    ws_retorno := replace(ws_retorno, 'Ê', '&Ecirc;');
    ws_retorno := replace(ws_retorno, 'Ô', '&Ocirc;');
    ws_retorno := replace(ws_retorno, 'â', '&acirc;');
    ws_retorno := replace(ws_retorno, 'ê', '&ecirc;');
    ws_retorno := replace(ws_retorno, 'ô', '&ocirc;');
    ws_retorno := replace(ws_retorno, 'À', '&Agrave;');
    ws_retorno := replace(ws_retorno, 'à', '&agrave;');
    ws_retorno := replace(ws_retorno, 'Ü', '&Uuml;');
    ws_retorno := replace(ws_retorno, 'ü', '&uuml;');
    ws_retorno := replace(ws_retorno, 'Ç', '&Ccedil;');
    ws_retorno := replace(ws_retorno, 'ç', '&ccedil;');
    ws_retorno := replace(ws_retorno, 'Ã', '&Atilde;');
    ws_retorno := replace(ws_retorno, 'Õ', '&Otilde;');
    ws_retorno := replace(ws_retorno, 'ã', '&atilde;');
    ws_retorno := replace(ws_retorno, 'õ', '&otilde;');
    ws_retorno := replace(ws_retorno, 'Ñ', '&Ntilde;');
    ws_retorno := replace(ws_retorno, 'ñ', '&ntilde;');
    ws_retorno := replace(ws_retorno, '“', '&#8223;');
    ws_retorno := replace(ws_retorno, '”', '&#8221;');
    ws_retorno := replace(ws_retorno, '‘', '&#8219;');
    ws_retorno := replace(ws_retorno, '’', '&#8217;');
    ws_retorno := replace(ws_retorno, '"', '&quot;');
    ws_retorno := replace(ws_retorno, '''', '&#8217;');
    ws_retorno := replace(ws_retorno, '<', '&lt;');
    ws_retorno := replace(ws_retorno, '>', '&gt;');

    return ws_retorno;

END HTML_TRANS;



FUNCTION EXCLUIR_DASH ( prm_objeto varchar2 default null ) return varchar2 as

begin

    return('<a class="fechardash" id="'||prm_objeto||'fechar" title="'||fun.lang('Excluir')||'" onclick="" ontouchend="" onmouseup="if(confirm(TR_CE)){ document.getElementById('''||prm_objeto||''').classList.remove(''movingarticle''); remover('''||prm_objeto||''', ''excluir''); }">X</a>');

end excluir_dash;


function check_admin ( prm_permissao varchar2 default null )  return boolean as
    ws_status varchar2(1) := 'N';
	ws_count number;
begin
    if gbl.getNivel = 'A' then
	    return true;
	else
	
		select count(*) into ws_count from admin_options where usuario = gbl.getUsuario and permissao = prm_permissao;

		if ws_count = 0 then
			return false;
		else
			select max(status) into ws_status from admin_options where usuario = gbl.getUsuario and permissao = prm_permissao;
		
			if ws_status = 'S' then
				return true;
			else
				return false;
			end if;
		end if;
	end if;
end check_admin;


FUNCTION GET_SEQUENCE ( PRM_TABELA VARCHAR2 DEFAULT NULL,
                        PRM_COLUNA VARCHAR2 DEFAULT NULL ) RETURN NUMBER AS

    WS_RETORNO  number;
    WS_CURSOR   NUMBER;
    WS_QUANT    NUMBER;
    WS_SQL      VARCHAR2(200);
    WS_SQL_R    NUMBER;
    ws_count    number;
    ws_owner    varchar2(10);
BEGIN
    --pegar o owner dwu onde é criado as tabelas do BI 
    ws_owner := nvl(fun.ret_var('OWNER_TABLE_DATA'),'DWU');

    /*ws_sql := 'select nvl(max(to_number('||PRM_COLUNA||')), 0)+1 from '||PRM_TABELA||'';

    ws_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(ws_cursor, ws_sql, dbms_sql.native);
    dbms_sql.define_column(ws_cursor, 1, ws_retorno);
	ws_sql_r := dbms_sql.execute(ws_cursor);
    ws_sql_r := dbms_sql.fetch_rows(ws_cursor);
    dbms_sql.column_value(ws_cursor, 1, ws_retorno);
    dbms_sql.close_cursor(ws_cursor);

    begin
		ws_sql := 'create sequence seq_'||PRM_TABELA||' start with '||ws_retorno||' increment by 1 minvalue 1 nocache';
		execute immediate ws_sql;
	exception when others then
        ws_sql := '';
	end;

	ws_sql := 'SELECT seq_'||PRM_TABELA||'.nextval FROM dual';

	WS_CURSOR := DBMS_SQL.OPEN_CURSOR;
	DBMS_SQL.PARSE(WS_CURSOR, ws_sql, DBMS_SQL.NATIVE);
	DBMS_SQL.DEFINE_COLUMN(WS_CURSOR, 1, WS_RETORNO);
	WS_SQL_R := DBMS_SQL.EXECUTE(WS_CURSOR);
	WS_SQL_R := DBMS_SQL.FETCH_ROWS(WS_CURSOR);
	DBMS_SQL.COLUMN_VALUE(WS_CURSOR, 1, WS_RETORNO);
	DBMS_SQL.CLOSE_CURSOR(WS_CURSOR);

    RETURN WS_RETORNO;*/

    --verifica se a linha existe
    select count(*) into ws_count from bi_sequence where nm_tabela = prm_tabela and nm_coluna = prm_coluna;

	if ws_count = 0 then

		--se não, pega o max da tabela
		ws_sql := 'select nvl(max(to_number('||PRM_COLUNA||')), 0)+1 from '||ws_owner||'.'||PRM_TABELA||'';
		ws_cursor := dbms_sql.open_cursor;
		dbms_sql.parse(ws_cursor, ws_sql, dbms_sql.native);
		dbms_sql.define_column(ws_cursor, 1, ws_retorno);
		ws_sql_r := dbms_sql.execute(ws_cursor);
		ws_sql_r := dbms_sql.fetch_rows(ws_cursor);
		dbms_sql.column_value(ws_cursor, 1, ws_retorno);
		dbms_sql.close_cursor(ws_cursor);
		--e cria a primeira linha já com o max
		insert into bi_sequence (nm_tabela, nm_coluna, sequencia) values ( prm_tabela, prm_coluna,  ws_retorno);
		commit;
	else

		select sequencia+1 into ws_retorno from bi_sequence 
		where nm_tabela = prm_tabela and nm_coluna = prm_coluna
		for update of sequencia;

	end if;

    RETURN WS_RETORNO;

EXCEPTION WHEN OTHERS THEN
    insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - GET_SEQUENCE', gbl.getUsuario, 'ERRO');
    RETURN 1;
END GET_SEQUENCE;

function get_sequence_max ( PRM_TABELA VARCHAR2 DEFAULT NULL,
                            PRM_COLUNA VARCHAR2 DEFAULT NULL ) RETURN NUMBER AS

    WS_RETORNO  number;
    WS_CURSOR   NUMBER;
    WS_QUANT    NUMBER;
    WS_SQL      VARCHAR2(200);
    WS_SQL_R    NUMBER;
    ws_count    number;
    ws_owner    varchar2(10);
BEGIN
    --pegar o owner dwu onde é criado as tabelas do BI 
    ws_owner := nvl(fun.ret_var('OWNER_TABLE_DATA'),'DWU');

    -- pega o max da tabela indicada no parametro
    ws_sql := 'select nvl(max(to_number('||PRM_COLUNA||')), 0)+1 from '||ws_owner||'.'||PRM_TABELA||'';
    ws_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(ws_cursor, ws_sql, dbms_sql.native);
    dbms_sql.define_column(ws_cursor, 1, ws_retorno);
    ws_sql_r := dbms_sql.execute(ws_cursor);
    ws_sql_r := dbms_sql.fetch_rows(ws_cursor);
    dbms_sql.column_value(ws_cursor, 1, ws_retorno);
    dbms_sql.close_cursor(ws_cursor);

    return ws_retorno;

exception
  when others then
    insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - GET_SEQUENCE_MAX', gbl.getUsuario, 'ERRO');
    RETURN 1;
end get_sequence_max;

function attrib_temporeal ( prm_atrib varchar2 default null, 
	                        prm_obj   varchar2 default null ) return varchar2

as

    ws_scrip_efeito varchar2(2000);
    ws_condicao     varchar2(80);

begin

    case prm_atrib
        when 'DASH_MARGIN' then
            ws_scrip_efeito := 'document.getElementById('''||prm_obj||''').style.setProperty(''margin'', this.value);';
        when 'ALIGN_TIT' then
            ws_scrip_efeito := 'document.getElementById('''||prm_obj||'''+''_ds'').style.setProperty(''text-align'', this.value);';
        /*when 'FONTE_CABECALHO' then
		    ws_scrip_efeito := 'document.getElementById('''||prm_obj||'''+''_ds'').style.setProperty(''color'', this.value);';*/
		when 'FONTE_TIT' then
		    
            /*if trim(fun.getprop(prm_obj,'DEGRADE')) = 'N' then*/
			    ws_scrip_efeito := 'document.getElementById('''||prm_obj||'''+''_ds'').style.setProperty(''color'', this.value);';
			/*end if;*/

		when 'FUNDO_VALOR' then
		    
            if trim(fun.getprop(prm_obj,'DEGRADE')) = 'N' then
                ws_scrip_efeito := 'document.getElementById('''||prm_obj||''').style.setProperty(''background-color'', this.value);';
		    end if;

		when 'FUNDO_TIT' then
		    
            if trim(fun.getprop(prm_obj,'DEGRADE')) = 'N' then
                ws_scrip_efeito := 'document.getElementById('''||prm_obj||'''+''_ds'').style.setProperty(''background-color'', this.value);';
		    end if;

		when 'TIT_BGCOLOR' then
            
            if trim(fun.getprop(prm_obj,'DEGRADE')) = 'S' then
                ws_condicao := fun.getprop(prm_obj,'DEGRADE_TIPO')||'-gradient(''+this.value+'', '||fun.getprop(prm_obj,'BGCOLOR')||')';
                ws_scrip_efeito := 'document.getElementById('''||prm_obj||'''+''_ds'').style.removeProperty(''background-color''); document.getElementById('''||prm_obj||''').style.setProperty(''background'', '''||ws_condicao||''');';

            else
                ws_condicao := 'this.value';
                ws_scrip_efeito := 'document.getElementById('''||prm_obj||'''+''_ds'').style.setProperty(''background-color'', '''||ws_condicao||''');';
            end if;
            
        when 'TIT_COLOR' then
            ws_scrip_efeito := 'document.getElementById('''||prm_obj||'''+''_ds'').style.setProperty(''color'', this.value);';
        when 'BGCOLOR' then
            
            if trim(fun.getprop(prm_obj,'DEGRADE')) = 'S' then
                ws_condicao := fun.getprop(prm_obj,'DEGRADE_TIPO')||'-gradient('||fun.getprop(prm_obj,'TIT_BGCOLOR')||', ''+this.value+'')';
            else
                ws_condicao := 'this.value';
            end if;
     
            ws_scrip_efeito := 'document.getElementById('''||prm_obj||''').style.setProperty(''background'', '''||ws_condicao||''');';
		when 'IMG_BGCOLOR' then
		    ws_scrip_efeito := 'document.getElementById('''||prm_obj||''').querySelector(''.img_container'').children[0].style.setProperty(''background'', this.value);';
        when 'BORDA_COR' then
            ws_scrip_efeito := 'document.getElementById('''||prm_obj||''').style.setProperty(''border'', ''1px solid ''+this.value);';
		when 'IMG_BORDA' then
            ws_scrip_efeito := 'document.getElementById('''||prm_obj||''').querySelector(''.img_container'').children[0].style.setProperty(''border'', ''1px solid ''+this.value);';
        when 'IMG_RADIUS' then
            ws_scrip_efeito := 'document.getElementById('''||prm_obj||''').querySelector(''.img_container'').children[0].style.setProperty(''border-radius'', this.value.replace(''px'', '''')+''px'');';
		when 'IMG_ALTURA' then
            ws_scrip_efeito := 'var valor = this.value; if(valor.indexOf(''%'') == -1 && valor.indexOf(''auto'') == -1){ valor.replace(''px'', '''')+''px''; } document.getElementById('''||prm_obj||''').querySelector(''.img_container'').children[0].style.setProperty(''height'', valor);';
		when 'IMG_LARGURA' then
            ws_scrip_efeito := 'var valor = this.value; if(valor.indexOf(''%'') == -1 && valor.indexOf(''auto'') == -1){ valor.replace(''px'', '''')+''px''; } document.getElementById('''||prm_obj||''').querySelector(''.img_container'').children[0].style.setProperty(''width'', valor);';
		when 'NO_RADIUS' then
            ws_scrip_efeito := 'if(this.classList.contains(''checked'')){ document.getElementById('''||prm_obj||''').style.setProperty(''border-radius'', ''0''); } else { document.getElementById('''||prm_obj||''').style.setProperty(''border-radius'', ''7px 7px 0 0''); }';
        when 'IMG_ESPACAMENTO' then
		    ws_scrip_efeito := 'document.getElementById('''||prm_obj||''').querySelector(''.img_container'').children[0].style.setProperty(''padding'', this.value.replace(''px'', '''')+''px'');';
		when 'DASH_MARGIN' then
            ws_scrip_efeito := 'document.getElementById('''||prm_obj||''').style.setProperty(''margin'', this.value);';
        when 'TIT_COLOR' then
            ws_scrip_efeito := 'document.getElementById('''||prm_obj||'''+''_ds'').style.setProperty(''color'', this.value);';
        when 'COLOR' then
            ws_scrip_efeito := 'if(document.getElementById(''valor_''+'''||prm_obj||''')){ document.getElementById(''valor_''+'''||prm_obj||''').style.setProperty(''color'', this.value); } if(document.getElementById('''||prm_obj||'_vl'')){ document.getElementById('''||prm_obj||'_vl'').style.setProperty(''color'', this.value); } if(document.getElementById('''||prm_obj||'_mt'')){ document.getElementById('''||prm_obj||'_mt'').style.setProperty(''color'', this.value); }';
        when 'TIT_FONT' then
            ws_scrip_efeito := 'document.getElementById('''||prm_obj||'_ds'').style.setProperty(''font-family'', this.value);';
        when 'FONT' then
            ws_scrip_efeito := 'document.getElementById(''valor_'||prm_obj||''').style.setProperty(''font-family'', this.value);';
        when 'TIT_SIZE' then
            ws_scrip_efeito := 'document.getElementById('''||prm_obj||'_ds'').style.setProperty(''font-size'', this.value);';
        when 'SIZE' then
            ws_scrip_efeito := 'if(document.getElementById(''valor_''+'''||prm_obj||''')){ document.getElementById(''valor_'||prm_obj||''').style.setProperty(''font-size'', this.value); } if(document.getElementById('''||prm_obj||'_vl'')){ document.getElementById('''||prm_obj||'_vl'').style.setProperty(''font-size'', this.value); }';
        when 'TIT_BOLD' then
            ws_scrip_efeito := 'document.getElementById('''||prm_obj||'_ds'').style.setProperty(''font-weight'', this.value);';
        when 'BOLD' then
            ws_scrip_efeito := 'document.getElementById(''valor_'||prm_obj||''').style.setProperty(''font-weight'', this.value);';
        when 'IT' then
            ws_scrip_efeito := 'document.getElementById(''valor_'||prm_obj||''').style.setProperty(''font-style'', this.value);';
        when 'TIT_IT' then
            ws_scrip_efeito := 'document.getElementById('''||prm_obj||'_ds'').style.setProperty(''font-style'', this.value);';
        when 'ALTURA' then
            ws_scrip_efeito := 'resizeObj(this, '''||prm_obj||''', ''height'');';
            --ws_scrip_efeito := 'resizeObj(this, '''||prm_obj||''', ''height'');';
        when 'LARGURA' then
            ws_scrip_efeito := 'resizeObj(this, '''||prm_obj||''', ''width'');';
            --ws_scrip_efeito := 'resizeObj(this, '''||prm_obj||''', ''width'');';
        when 'BORDA_COR' then
            ws_scrip_efeito := 'document.getElementById('''||prm_obj||''').style.setProperty(''border'', ''1px solid ''+this.value);';
        when 'DEGRADE_TIPO' then
        
            if trim(fun.getprop(prm_obj,'DEGRADE')) = 'S' then
                ws_condicao := '''+this.value+''-gradient('||fun.getprop(prm_obj,'TIT_BGCOLOR')||', '||fun.getprop(prm_obj,'BGCOLOR')||')';
                ws_scrip_efeito := 'document.getElementById('''||prm_obj||'''+''_ds'').style.removeProperty(''background-color''); document.getElementById('''||prm_obj||''').style.setProperty(''background'', '''||ws_condicao||''');';
            end if;
		when 'TOTAL_GERAL_TEXTO' then
		    ws_scrip_efeito := 'if(this.value.length > 0 ){ document.getElementById('''||prm_obj||'_FIXED-N'').value = 999; document.getElementById('''||prm_obj||'_FIXED-N'').children[0].setAttribute(''readonly'', true); document.getElementById('''||prm_obj||'_FIXED-N'').children[0].classList.add(''readonly''); } else { document.getElementById('''||prm_obj||'_FIXED-N'').children[0].removeAttribute(''readonly''); document.getElementById('''||prm_obj||'_FIXED-N'').children[0].classList.remove(''readonly''); }';

    else
            ws_scrip_efeito := '';
    end case;
    
    return ws_scrip_efeito;
    
end attrib_temporeal;


function error_response ( prm_error varchar2 default null ) return varchar2 as

    ws_retorno varchar2(400);
	ws_count number;

begin

    ws_retorno := prm_error;

    select regexp_count(prm_error, 'ORA-') into ws_count from dual;

    for i in 1..ws_count loop

		if instr(prm_error, 'ORA-00933') <> 0 then
			ws_retorno := ws_retorno||'ORA-00933: COMANDO N&Atilde;O ENCERRADO ADEQUADAMENTE! ';
		end if;
		
		if instr(prm_error, 'ORA-23538') <> 0 then
			ws_retorno := ws_retorno||'ORA-23538: N&Atilde;O PODE USAR REFRESH EM UMA VIEW MATERIALIZADA COM BLOQUEIO DE REFRESH! ';
		end if;
		
		if instr(prm_error, 'ORA-06510') <> 0 then
			ws_retorno := ws_retorno||'ORA-06510: EXCEPTION N&Atilde;O TRATADA! ';
		end if;
		
		if instr(prm_error, 'ORA-00920') <> 0 then
			ws_retorno := ws_retorno||'ORA-00920: OPERADOR INV&Aacute;LIDO! ';
		end if;
		
		if instr(prm_error, 'ORA-01476') <> 0 then
			ws_retorno := ws_retorno||'ORA-01476: DIVISOR COM ZERO! ';
		end if;
		
		if instr(prm_error, 'ORA-06512') <> 0 and instr(prm_error, ''||nvl(fun.ret_var('OWNER_BI'),'DWU')||'.FCL') <> 0 then
			ws_retorno := ws_retorno||'ORA-06512: ERRO DE PROCESSO! ';
		end if;
	
	end loop;
	
	return ws_retorno;

end error_response;

FUNCTION VPIPE_ORDER ( PRM_ENTRADA VARCHAR2,
                       PRM_DIVISAO VARCHAR2 DEFAULT '|' ) RETURN TAB_PIPE PIPELINED AS

   WS_BINDN      NUMBER;
   WS_TEXTO      VARCHAR2(12000);
   WS_NM_VAR      VARCHAR2(12000);
   WS_FLAG         CHAR(1);
   ws_count      number;

BEGIN

   WS_FLAG  := 'N';
   WS_BINDN := 0;
   WS_TEXTO := PRM_ENTRADA;
   ws_count := 0;


   LOOP
       IF  WS_FLAG = 'Y' THEN
           EXIT;
       END IF;
	   ws_count := ws_count+1;

       IF  NVL(INSTR(WS_TEXTO,PRM_DIVISAO),0) = 0 THEN
      WS_FLAG  := 'Y';
      WS_NM_VAR := WS_TEXTO;
       ELSE
      WS_NM_VAR := SUBSTR(WS_TEXTO, 1 ,INSTR(WS_TEXTO,PRM_DIVISAO)-1);
      WS_TEXTO  := SUBSTR(WS_TEXTO, LENGTH(WS_NM_VAR||PRM_DIVISAO)+1, LENGTH(WS_TEXTO));
       END IF;

       WS_BINDN := WS_BINDN + 1;
       PIPE ROW (PIPE_ORDER(WS_NM_VAR, ws_count));

   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      PIPE ROW(PIPE_ORDER(SQLERRM||'=RET_LIST', ws_count));

END VPIPE_ORDER;

function av_columns ( prm_obj        varchar2 default null,
                      prm_screen     varchar2 default null,
					  prm_condicoes  varchar2 default null ) return varchar2 as

   ws_tipo        varchar2(80);
   ws_visao       varchar2(80);
   ws_tabela      varchar2(80);
   ws_dimensao    varchar2(800);
   ws_medida      varchar2(800);
   ws_filtro      varchar2(1600);
   ws_agrup       varchar2(800);
   ws_colup       varchar2(800);
   ws_count       number;
   

begin

    select cd_micro_visao into ws_visao from ponto_avaliacao where cd_ponto = prm_obj;
    select nm_tabela into ws_tabela from micro_visao where nm_micro_visao = ws_visao;

    select count(*) into ws_count from micro_qube where nm_micro_visao = ws_tabela;
	
	select tp_objeto into ws_tipo from objetos where cd_objeto = prm_obj;

    if ws_count <> 0 then

        select nvl(cs_coluna, parametros), cs_agrupador, cs_colup,
        (select listagg(cd_coluna, '|')  within group (order by cd_coluna) from filtros where cd_objeto = prm_obj)||'|'||
        (select listagg(cd_coluna, '|')  within group (order by cd_coluna) from filtros where cd_objeto = prm_screen)||'|'||
        (select listagg(cd_coluna, '|')  within group (order by cd_coluna) from float_filter_item ffi where screen = prm_screen and (ffi.cd_coluna = cs_coluna or ffi.cd_coluna = cs_agrupador or ffi.cd_coluna = cs_colup or ffi.cd_coluna = parametros))
        into ws_dimensao, ws_agrup, ws_colup, ws_filtro
        from ponto_avaliacao t1
        where cd_ponto = prm_obj;
		
		if ws_tipo <> 'VALOR' then
		    ws_medida := fun.CONV_TEMPLATE(ws_visao, ws_agrup)||'|'||ws_colup;
		else
		    ws_medida := ws_agrup||'|'||ws_colup;
		end if;
		
		ws_filtro := replace(ws_filtro||'|'||prm_condicoes, '||', '|');
		
		return fun.GET_QDATA(fun.test_columns(ws_dimensao, ws_tabela, ws_visao), fun.test_columns(ws_medida, ws_tabela, ws_visao), fun.test_columns(ws_filtro, ws_tabela, ws_visao), ws_visao);

    else

        return ws_tabela;

    end if;

end av_columns;

function test_columns ( prm_valor  varchar2 default null,
                        prm_tabela varchar2 default null,
						prm_visao  varchar2 default null ) return varchar2 as

    ws_combinado varchar2(12000);

begin

    select listagg(coluna, '|')  within group (order by coluna) into ws_combinado from (
            select column_name as coluna, 
            (
              select sum(instr(fun.gformula2(upper(prm_visao), column_value), column_name)) 
              from table((fun.vpipe(replace(prm_valor, '||', '|')))) where 
              column_value in (select cd_coluna from micro_coluna where cd_micro_visao = prm_visao) and column_value is not null
			) as disponivel 
            from all_tab_columns 
            where table_name = prm_tabela
        ) where disponivel > 0;
		
	return ws_combinado;
		
end test_columns;

/*

CREATE TABLE "DWU"."MICRO_QUBE" 
   (	"NM_TABELA" VARCHAR2(30 BYTE), 
	"NM_MICRO_VISAO" VARCHAR2(30 BYTE), 
	"DT_CRIACAO" DATE, 
	"DT_REFRESH" DATE,
	"ST_ATIVO" CHAR(1)
   );
   
CREATE TABLE "DWU"."COLUMNS_QDATA" 
   (	"CD_TABELA" VARCHAR2(2000 BYTE), 
	"CD_COLUNA" VARCHAR2(2000 BYTE), 
	"TP_COLUNA" VARCHAR2(3 BYTE)
   );

*/

function get_qdata ( prm_dimensoes       varchar2   default null,
                     prm_medidas         varchar2   default null,
                     prm_filtros         varchar2   default null,
                     prm_micro_visao     varchar2   default null ) return varchar2 as

    ws_retorno         varchar2(8000);
	ws_retorno_ant     varchar2(8000);
    ws_colunas         varchar2(8000);
    ws_dimmed          varchar2(8000);
    ws_condicoes       varchar2(4000);
    ws_tabela_original varchar2(4000);
	ws_query_ant       varchar2(4000);

    ws_tabela          varchar2(4000);
    ws_count           number := 0;
    ws_col_teste       varchar2(2000);
    ws_tp_coluna       varchar2(2000);
    ws_virgula         varchar2(1);
    ws_and             varchar2(5);
    ws_no_exec         exception;
	ws_next            exception;
	
	
	cursor crs_qubos is
	select NM_TABELA from MICRO_QUBE 
	where nm_micro_visao = PRM_MICRO_VISAO;
	ws_qubo crs_qubos%rowtype;

begin

    select NM_TABELA into ws_tabela_original
			  from MICRO_VISAO where nm_micro_visao=PRM_MICRO_VISAO;


    ws_retorno_ant := ws_tabela_original;
	
	ws_colunas := PRM_DIMENSOES||'|'||PRM_MEDIDAS||'|'||PRM_FILTROS;



    open crs_qubos;
        loop
	        fetch crs_qubos into ws_qubo;
		    exit when crs_qubos%notfound;
			
		      
			  ws_count := ws_count+1;
			  
			  ws_tabela := ws_qubo.NM_TABELA;
			  
			  ws_dimmed := '';
			  ws_virgula := '';

			  /*select NM_TABELA into ws_tabela
			  from MICRO_QUBE where nm_micro_visao=PRM_MICRO_VISAO;*/

			  
			  begin
			  
 
				  FOR VRF_COL in (select distinct COLUMN_VALUE as cd_coluna from table(fun.vpipe(ws_colunas)) where column_value is not null) LOOP
						begin
							 select cd_coluna, tp_coluna into ws_col_teste, ws_tp_coluna
							 from   COLUMNS_QDATA
							 where  cd_tabela = ws_tabela and 
								   cd_coluna = VRF_COL.cd_coluna
								   order by tp_coluna;
						exception
							 when others then 
							     ws_col_teste := '%SEM_COLUNA%_UPQUERY';
							     --raise ws_next;
						end;

						if  VRF_COL.cd_coluna = ws_col_teste then
							null;
						--else
						--	raise ws_no_exec;
						end if;

				  END LOOP;
				  
				  
				  FOR VRF_COL in (select distinct COLUMN_VALUE as cd_coluna from table(fun.vpipe(ws_colunas))  where column_value is not null) LOOP
						begin
							 select cd_coluna, tp_coluna into ws_col_teste, ws_tp_coluna
							 from   COLUMNS_QDATA
							 where  cd_tabela = ws_tabela and 
								   cd_coluna = VRF_COL.cd_coluna
								   order by tp_coluna;
						exception
							 when others then raise ws_no_exec;
						end;

						ws_retorno := 'select ';

						if  VRF_COL.cd_coluna = ws_col_teste then
							if  ws_tp_coluna = 'DIM' then
								ws_dimmed := ws_dimmed||ws_virgula||chr(13)||' '||VRF_COL.cd_coluna||' as '||VRF_COL.cd_coluna;
								ws_virgula := ',';
							else
								ws_dimmed := ws_dimmed||ws_virgula||chr(13)||' '||VRF_COL.cd_coluna||' as '||VRF_COL.cd_coluna;
								ws_virgula := ',';
							end if;
						else
							null;
						end if;

				  END LOOP;

				  ws_retorno := ws_retorno||ws_dimmed||' from '||ws_tabela||chr(13);
				  ws_retorno := ws_retorno||' where '||chr(13);

				  FOR VRF_NULL in (
					select 'UGRP_'||cd_coluna as cd_coluna, ' = 0 ' as tipo, tp_coluna from COLUMNS_QDATA where cd_tabela = ws_tabela and cd_coluna    in (select distinct COLUMN_VALUE as cd_coluna from table(fun.vpipe(ws_colunas)) where column_value is not null)
					union all
					select 'UGRP_'||cd_coluna as  cd_coluna, ' = 1' as tipo, tp_coluna from COLUMNS_QDATA where cd_tabela = ws_tabela and cd_coluna not in (select distinct COLUMN_VALUE as cd_coluna from table(fun.vpipe(ws_colunas)) where column_value is not null)
				  )
				  
				  LOOP
					  if VRF_NULL.tp_coluna = 'DIM' then
						  ws_retorno := ws_retorno||ws_and||chr(13)||VRF_NULL.cd_coluna||VRF_NULL.tipo;
						  ws_and := ' and ';
					  end if;
				  END LOOP;

				  ws_retorno := '( '||ws_retorno||' )';

				  ws_retorno_ant := ws_retorno;
				  
				  exit;

		    EXCEPTION
			   
			    when ws_no_exec then
				    ws_retorno := ws_retorno_ant;
				when OTHERS THEN
					ws_retorno := ws_retorno_ant;
		    END;

	    end loop;
    close crs_qubos;


  return(ws_retorno);

EXCEPTION WHEN OTHERS THEN
    return(ws_tabela_original);
end get_qdata;

function create_user ( username         in varchar2, 
					   password         in varchar2,
					   prm_referencia   in varchar2 default null,
					   prm_email        in varchar2,
					   prm_completo     in varchar2  ) return varchar2 as

   ws_no_create    exception;
   ws_erro         exception;
   ws_status       varchar2(50);
   ws_vrf          varchar2(10);
   ws_count_net    number;

begin

    ws_status := 'OK';

    begin

        begin
            insert into USUARIOS (usu_nome, usu_completo, usu_email, status, excel_out,upload,usu_linguagem,show_only, id_expira_senha, dt_validacao_senha)
                          values (username, prm_completo, prm_email, 'A'   , 'S'      ,'N'   ,'PORTUGUESE' , 'N'     , 'S'            , sysdate );
            
            insert into log_eventos values(sysdate, 'CRIACAO USUARIO', username, 'TELA', 'USUARIO', '01');
            
            ws_vrf := digestPassword(username, password);
            insert into ROLES values (username, 'DWU', 'ME');
            insert into ROLES values (username, 'DWU', 'ONLY');
            insert into user_netwall (usuario, nome_regra, tipo_regra, tp_net_address, net_address, hr_inicio, hr_final, dia_semana, dt_regra) values(username, 'LIVRE_01', 'L', 'I', '', 0, 24, 0, sysdate);

            if  prm_referencia is not null then

                insert into user_screens (usuario, screen, status)
                select username, t2.screen, t2.status from user_screens t2 where t2.usuario = prm_referencia;

                for i in(select micro_visao, cd_coluna, condicao, conteudo, ligacao from filtros where cd_usuario = prm_referencia and tp_filtro = 'geral') loop
	                fcl.setfiltro(username, i.micro_visao, i.cd_coluna, i.condicao, i.conteudo, i.ligacao);
                end loop;

                insert into object_restriction (USUARIO, CD_OBJETO, ST_RESTRICAO, DT_LAST)
                select username, t2.cd_objeto, t2.st_restricao, sysdate from object_restriction t2 where t2.usuario = prm_referencia;

                insert into parametro_usuario (CD_USUARIO, CD_PADRAO, CONTEUDO, PRE_LOAD) 
                select username, t2.cd_padrao, t2.conteudo, '' from parametro_usuario t2 where cd_usuario = prm_referencia;

                insert into roles (CD_USUARIO, CD_ROLE, TIPO)
                select username, t2.cd_role, t2.tipo from roles t2 where cd_usuario = prm_referencia;

                insert into column_restriction (USUARIO, CD_MICRO_VISAO, CD_COLUNA, ST_RESTRICAO, DT_LAST)
                select username, t2.cd_micro_visao, t2.cd_coluna, t2.st_restricao, sysdate from column_restriction t2 where t2.usuario = prm_referencia;
                
                begin
                  select count(*) into ws_count_net from user_NETWALL where usuario = username;
                    if ws_count_net > 0 then
                        delete user_netwall where usuario = username;
                        
                    end if;
                        insert into user_netwall (USUARIO, NOME_REGRA, TIPO_REGRA, TP_NET_ADDRESS, NET_ADDRESS, HR_INICIO, HR_FINAL, DIA_SEMANA, DT_REGRA)
                        select username, t2.nome_regra, t2.tipo_regra, t2.tp_net_address, t2.net_address, t2.hr_inicio, t2.hr_final, t2.dia_semana, t2.dt_regra from user_netwall t2 where usuario = prm_referencia;
                exception
                  when others then
                    insert into bi_log_sistema values (sysdate,'ERRO AO COPIAR O NETWALL','DWU','ERRO');    
                    
                end;

                for i in(select cd_objeto, cd_coluna, condicao, conteudo, cor_fundo, cor_fonte, tipo_destaque, prioridade 
                           from destaque 
                          where cd_usuario = prm_referencia
                        ) loop
                    fcl.setdestaque(username, i.cd_objeto, i.cd_coluna, i.condicao, i.conteudo, i.cor_fundo, i.cor_fonte, i.tipo_destaque, i.prioridade);
                end loop;

               /* insert into bi_custom_permissao (NM_USUARIO, NM_VISAO, NM_COLUNA, cd_custom)
                select username, t2.NM_VISAO, t2.NM_COLUNA from bi_custom_permissao t2 where nm_usuario = prm_referencia;*/

            end if;

            commit;

        exception when others then
            rollback;
            ws_status := 'ERRO';
		    raise ws_erro;
        end;

    exception
        when ws_no_create then
            ws_status := 'ERRO';
	
        when others then
            execute immediate 'drop user "'||username||'"';
            ws_status := 'ERRO';
    end;

    return(ws_status);

exception 
    when ws_erro then
        return(ws_status);
    when others then
        return(ws_status);
end;

function remove_user ( prm_usuario varchar2 ) return varchar2 as

    ws_count number;
    ws_user number;
	ws_exception exception;

	ws_cmd varchar2(8000);
  
begin

    ws_count := 0;

    begin
            
        insert into log_eventos values(sysdate, 'EXCLUSAO USUARIO', prm_usuario, 'TELA', 'USUARIO', '01');

        delete from USUARIOS            where trim(usu_nome)    = prm_usuario and rownum = 1;
        delete from FILTROS             where trim(cd_usuario)  = prm_usuario and tp_filtro = 'geral';
        delete from user_SCREENS        where trim(usuario)     = prm_usuario;
        delete from FILTROS             where trim(cd_usuario)  = prm_usuario and tp_filtro = 'objeto';
        delete from DESTAQUE            where trim(cd_usuario)  = prm_usuario;
        delete from OBJECT_RESTRICTION  where trim(usuario)     = prm_usuario;
        delete from user_NETWALL        where trim(usuario)     = prm_usuario;
        delete from COLUMN_RESTRICTION  where trim(usuario)     = prm_usuario;
        delete from ADMIN_OPTIONS       where trim(usuario)     = prm_usuario;
        delete from gusers_itens        where trim(cd_usuario)  = prm_usuario;
        delete from ROLES               where trim(cd_usuario)  = prm_usuario;
        delete from PARAMETRO_USUARIO    where trim(cd_usuario) = prm_usuario;
        delete from OBJECT_ATTRIB       where trim(owner)       = prm_usuario;
        delete from FLOAT_FILTER_ITEM   where trim(cd_usuario)  = prm_usuario;
        delete from BI_INFO_USER        where nm_user           = prm_usuario;

        return 'OK';
 
    exception when others then
        rollback;
        insert into bi_log_sistema values (sysdate, 'N&atilde;o foi poss&iacute;vel excluir o usu&aacute; do sistema.', gbl.getUsuario, 'ERRO');
		commit;	
        raise ws_exception;
    end;
exception 
    when ws_exception then

        return 'ERRO';
    when others then
        return 'ERRO';
end remove_user;

function converte( prm_texto varchar2 default null ) return varchar2 as

    ws_convertido varchar2(4000);
	ws_charset varchar2(200);

begin

    ws_charset := fun.ret_var('CHARSET');

    if nvl(ws_charset, 'AL32UTF8') <> 'AL32UTF8' then
	    
		begin
		    select CONVERT(prm_texto, ws_charset, 'AL32UTF8') into ws_convertido from dual;
			
		exception when others then
			ws_convertido := prm_texto;
		end;

		return ws_convertido;
	else
        return prm_texto;
	end if;

end converte;

function check_screen_access ( prm_screen varchar2 default null, 
                               prm_usuario varchar2 default null, 
                               prm_admin varchar2 default null ) return number as

    ws_count   number;
    ws_usuario varchar2(80);

begin

    --ws_usuario := gbl.getUsuario;
    
    if prm_screen <> 'DEFAULT' and prm_admin <> 'A' then
        -- Separado o select original em dois para o Oracle utilizar os indexes corretamente 
        select count(*) into ws_count 
          from user_screens 
         where usuario = prm_usuario 
           and ( screen = trim(prm_screen) or 
                 screen in (select cd_grupo from grupos_funcao where cd_grupo in(select cd_grupo from objetos where cd_objeto = trim(prm_screen)))   
               ); 
        --   
        if ws_count = 0 then         
            select count(*) into ws_count 
              from user_screens 
             where usuario in (select cd_group from gusers_itens where cd_usuario = prm_usuario) 
               and ( screen = trim(prm_screen) or 
                     screen in (select cd_grupo from grupos_funcao where cd_grupo in(select cd_grupo from objetos where cd_objeto = trim(prm_screen))) 
                   ); 
        end if; 
        --
        /* 
        select count(*) into ws_count from user_screens 
         where ( trim(usuario) = prm_usuario and
                ( trim(screen) = trim(prm_screen) or 
                  trim(screen) in (select cd_grupo from grupos_funcao where cd_grupo in(select cd_grupo from objetos where cd_objeto = trim(prm_screen)))
                )
               ) or 
               ( trim(usuario) in (select cd_group from gusers_itens where cd_usuario = prm_usuario) and
                ( trim(screen) = trim(prm_screen) or
                  trim(screen) in (select cd_grupo from grupos_funcao where cd_grupo in(select cd_grupo from objetos where cd_objeto = trim(prm_screen)))
                )
            ); 
        */     
    else
        ws_count := 1;
    end if;
    return ws_count;

end check_screen_access;



function nomeObjeto( prm_objeto varchar2 default null ) return varchar2 as

    ws_objeto varchar2(120);

begin

    ws_objeto := prm_objeto;

    select nm_objeto into ws_objeto from objetos where cd_objeto = prm_objeto;

    return ws_objeto;
exception when others then
    return prm_objeto;
end nomeObjeto;

function usuario return varchar2 as

begin
    
    return 'DWU';

end;

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

function objCode ( prm_alias varchar2 default null ) return varchar2 as

    ws_codigo varchar2(200);

begin

     Select prm_alias||trim((Select Sid From V$session Where Audsid = Sys_Context('userenv','sessionid'))||
    		(Select Serial# From V$session Where Audsid = Sys_Context('userenv','sessionid'))||
    		to_char(sysdate,'yymmddhhmiss')) into ws_codigo From Dual;

    return ws_codigo;

end objCode;


function objCode2 ( prm_alias varchar2 default null ) return varchar2 as
    ws_codigo varchar2(200);
begin
    select prm_alias||substr(dbms_random.value,-7)||to_char(sysdate,'yymmddhhmiss') into ws_codigo From Dual;
    return ws_codigo;
end objCode2;


/*function pwd_vrf(username in varchar2, password in varchar2 ) return char authid current_user is

	--
	raw_key raw(128):= hextoraw('0123456789ABCDEF');
	--
	raw_ip raw(128);
	pwd_hash varchar2(16);
	--

	cursor c_user (cp_name in varchar2) is
	select 	password
	from sys.user$
	where password is not null
	and name=cp_name;
	--
	procedure unicode_str(userpwd in varchar2, unistr out raw)
	is
		enc_str varchar2(124):='';
		tot_len number;
		curr_char char(1);
		padd_len number;
		ch char(1);
		mod_len number;
		debugp varchar2(256);
	begin
		tot_len:=length(userpwd);
		for i in 1..tot_len loop
			curr_char:=substr(userpwd,i,1);
			enc_str:=enc_str||chr(0)||curr_char;
		end loop;
		mod_len:= mod((tot_len*2),8);
		if (mod_len = 0) then
			padd_len:= 0;
		else
			padd_len:=8 - mod_len;
		end if;
		for i in 1..padd_len loop
			enc_str:=enc_str||chr(0);
		end loop;
		unistr:=utl_raw.cast_to_raw(enc_str);
	end;
	--
	function crack (userpwd in raw) return varchar2 
	is
		enc_raw raw(2048);
		--
		raw_key2 raw(128);
		pwd_hash raw(2048);
		--
		hexstr varchar2(2048);
		len number;
		password_hash varchar2(16);	
	begin
		dbms_obfuscation_toolkit.DESEncrypt(input => userpwd, 
		       key => raw_key, encrypted_data => enc_raw );
		hexstr:=rawtohex(enc_raw);
		len:=length(hexstr);
		raw_key2:=hextoraw(substr(hexstr,(len-16+1),16));
		dbms_obfuscation_toolkit.DESEncrypt(input => userpwd, 
		       key => raw_key2, encrypted_data => pwd_hash );
		hexstr:=hextoraw(pwd_hash);
		len:=length(hexstr);
		password_hash:=substr(hexstr,(len-16+1),16);
		return(password_hash);
	end;
begin
	open c_user(upper(username));
	fetch c_user into pwd_hash;
	close c_user;
	unicode_str(upper(username)||upper(password),raw_ip);
	if( pwd_hash = crack(raw_ip)) then
		return ('Y');
	else
		return ('N');
	end if;
end;*/

function digestPassword( prm_usuario varchar2, prm_password varchar2 ) return varchar2 as
    ws_count number := 0;
begin
    -- Retirado o código do cliente da senha, o código do cliente foi retirado da senha para permitir a alteração do código de cliente sem prejudicar o acesso dos usuários
    update usuarios 
       set password           = ltrim(to_char(dbms_utility.get_hash_value(upper(trim(prm_usuario))||'/'||upper(trim(prm_password)), 1000000000, power(2,30) ), rpad( 'X',29,'X')||'X')),
           dt_validacao_senha = sysdate      
     where upper(trim(usu_nome)) = upper(trim(prm_usuario));
    ws_count := SQL%ROWCOUNT;
    if ws_count = 1 then
        insert into log_eventos values(sysdate, 'ALTERACAO SENHA[digestPassword]', prm_usuario, 'TELA', 'USUARIO', '01');
        commit;
        return 'Y';
    else
        rollback;
        return 'N';
    end if;
exception when others then
    rollback;
    return 'N';
end digestPassword;

function validaPassword( prm_usuario varchar2, prm_password varchar2 ) return varchar2 as
    ws_count number := 0;
begin
    -- Verifica se a nova senha é igual a senha atual 
    select count(*) into ws_count 
      from usuarios 
     where upper(trim(usu_nome)) = upper(trim(prm_usuario))
       and password              = ltrim(to_char(dbms_utility.get_hash_value(upper(trim(prm_usuario))||'/'||upper(trim(prm_password)), 1000000000, power(2,30) ), rpad( 'X',29,'X')||'X'));
    --       
    if ws_count > 0 then 
        Return 'Senha informada deve ser diferente da senha atual'; 
    end if; 

    Return 'OK' ;
exception when others then
    insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values(sysdate, 'Erro validaPassword: '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, prm_usuario, 'ERRO');
    commit; 
    return 'Erro validando senha';
end validaPassword;



function testDigestedPassword( prm_usuario varchar2, prm_password varchar2 ) return varchar2 as

    ws_count number := 0;
    ws_vrf varchar2(10) := 'N';
begin

    -- Valida a senha sem o código do cliente, 
    select count(*) into ws_count 
      from usuarios
     where nvl(password, 'N/A') = ltrim(to_char(dbms_utility.get_hash_value(upper(trim(prm_usuario))||'/'||upper(trim(prm_password)), 1000000000, power(2,30) ), rpad( 'X',29,'X')||'X'))
       and upper(trim(usu_nome)) = upper(trim(prm_usuario));

    -- Valida a senha com o código do cliente (senhas antigas, criadas com o código do cliente)
    if ws_count = 0 then
        select count(*) into ws_count 
          from usuarios
         where nvl(password, 'N/A') = ltrim(to_char(dbms_utility.get_hash_value(upper(trim(prm_usuario))||'/'||upper(trim(prm_password)), 1000000000, power(2,30) ), rpad( 'X',29,'X')||'X'))||ltrim( to_char(dbms_utility.get_hash_value(upper(trim(fun.ret_var('CLIENTE'))), 100000000, power(2,30) ), rpad( 'X',29,'X')||'X' ) )
           and upper(trim(usu_nome)) = upper(trim(prm_usuario));
    end if; 

    if ws_count <> 0 then
        return 'Y';
    else

        select count(*) into ws_count 
         from usuarios
         where password is not null 
           and upper(trim(usu_nome)) = upper(trim(prm_usuario));

        --já possui o digest
        if ws_count <> 0 then
            return 'N';
        end if;

        /***** descontinuado a partir da v1.5.7 - Na versão anterior já não existe mais usuário final no Oracle
        --criando o digest a primeira vez
        ws_vrf := pwd_vrf(prm_usuario, prm_password);

        if ws_vrf = 'Y' then

            ws_vrf := fun.digestPassword(prm_usuario, prm_password);
            commit;
            return ws_vrf;
        end if;
        ***********************************/ 


    end if;

exception when others then
    return 'N';
end testDigestedPassword;


/*** Exclui na próxima versão, não está sendo utilizada  
function ObjCustomUsuario( prm_usuario varchar2) return varchar2 as
   ws_obj     varchar2(50);
   ws_obj_aux varchar2(50);
begin
    ws_obj := translate(upper(prm_usuario),'.#@','___'); 
    if length(ws_obj) > 20 then 
		if Instr(ws_obj,'_') = 0 then 
			ws_obj := substr(ws_obj,1,20);
		else 
            ws_obj_aux := substr(ws_obj, Instr(ws_obj,'_',1),10);
            ws_obj    := substr(ws_obj,1,20-length(ws_obj_aux))||ws_obj_aux;
		end if; 	
	end if;	
	ws_obj := 'COBJ_'||ws_obj;

    return(ws_obj); 
exception when others then
    return '';
end ObjCustomUsuario;
**/ 


function conv_data( prm_data varchar2) return date as
w_data    date := null; 
begin
    -- Se não for possível converter por nenhum dos formatos abaixo, a função deve retorar erro, o erro não deve ser tratado aqui na função 
    begin
        w_data := to_date(prm_data,'DD/MM/YYYY HH24:MI:SS','NLS_DATE_LANGUAGE='||fun.ret_var('LANG_DATE') ); 
    exception when others then 
        begin
            w_data := to_date(prm_data,'DD/MM/YYYY HH24:MI:SS','NLS_DATE_LANGUAGE=AMERICAN');     -- Se não converteu pela linguagem parametrizada, tenta o formato Americano  
        exception when others then
            w_data := to_date(prm_data,'DD/MM/YYYY HH24:MI:SS','NLS_DATE_LANGUAGE=PORTUGUESE');     -- Se não converteu pela linguagem parametrizada, tenta o formato Portugues  
        end;    
    end; 
    w_data := to_date(w_data); 
   
    return(w_data);
end conv_data; 


function vpipe_n (prm_param varchar2,
                  prm_idx   number,
                  prm_pipe  varchar2 default '|' ) return varchar2 as 
ws_idx1   number;
ws_idx2   number;
begin

    if prm_idx <= 0 then 
       return null;
    end if;

    if (prm_idx - 1) <= 0 then 
        ws_idx1 := 0;
    else         
        ws_idx1 := instr(prm_param, prm_pipe ,1, prm_idx-1);
    end if;    
    ws_idx2 := instr(prm_param, prm_pipe,1, prm_idx);

    if ws_idx1 = 0 and ws_idx2 = 0 then 
       return null;
    end if; 
    if ws_idx2 = 0 then 
        ws_idx2 := length(prm_param); 
    else     
        ws_idx2 := ws_idx2 - ws_idx1 - 1; 
    end if;

    return substr(prm_param, ws_idx1 + 1, ws_idx2); 
end vpipe_n; 

-- Monta página html de aviso 
function pagina_html_aviso (prm_texto varchar2,
							prm_tipo  varchar2 default null) return varchar2 is  
ws_html varchar2(2000); 
begin
    ws_html := '<!doctype html public "-//W3C//DTD html 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">'||
		       '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="pt-br" lang="pt-br">'||
		       '  <body>'||
			   '    <div style="font-weight: bold; font-size: 16px; color: #cc0000; font-family: tahoma; position: absolute; top: 45%; left: 40%; id="aviso-tela-principal">'||fun.lang(prm_texto)||'</div>'||
		       '  </body>'||
		       '</html>';
    return ws_html; 
end pagina_html_aviso;

-- Converte/retira caracteres/comandos especiais que geram problema no JSON ou no HTML 
function converte_json( prm_texto varchar2 default null ) return varchar2 as
    ws_convertido varchar2(4000);
begin

    ws_convertido := prm_texto; 

    -- Problema no HTML - Substitui caracteres por espaço 
    ws_convertido := replace(ws_convertido, '&',     ' ');
    ws_convertido := replace(ws_convertido, '<',     ' ');
    ws_convertido := replace(ws_convertido, '>',     ' ');


    -- Problema com JSON - Converte para JSON (Adicionando \ )  
    ws_convertido := replace(ws_convertido, '\', 'SubstituicaoTemporariaDaBarraInvertida');    -- Substitui a barra temporariamente para não gerar problema nos replaces abaixo (caso tenha no texto)
    ws_convertido := replace(ws_convertido, chr(34), '\'||chr(34));   -- Converte "
    ws_convertido := replace(ws_convertido, 'SubstituicaoTemporariaDaBarraInvertida', '\\');   -- Retorna a barra invertida para o texto (caso tenha sido substituida)  
	
    -- Susbtitui os comandos abaixo por Espaço (mais comuns TAB, ENTER, FIM DE LINHA) 
    ws_convertido := replace(ws_convertido, chr(01), ' '); --  Começo de cabeçalho de transmissão
    ws_convertido := replace(ws_convertido, chr(02), ' '); --  Começo de texto
    ws_convertido := replace(ws_convertido, chr(03), ' '); --  Fim de texto
    ws_convertido := replace(ws_convertido, chr(04), ' '); --  Fim de transmissão
    ws_convertido := replace(ws_convertido, chr(05), ' '); --  Interroga
    ws_convertido := replace(ws_convertido, chr(06), ' '); --  Confirmação
    ws_convertido := replace(ws_convertido, chr(07), ' '); --  Sinal sonoro
    ws_convertido := replace(ws_convertido, chr(08), ' '); --  Volta um caracter
    ws_convertido := replace(ws_convertido, chr(09), ' '); --  Tabulação Horizontal
    ws_convertido := replace(ws_convertido, chr(10), ' '); --  Próxima linha
    ws_convertido := replace(ws_convertido, chr(11), ' '); --  Tabulação Vertical
    ws_convertido := replace(ws_convertido, chr(12), ' '); --  Próxima Página
    ws_convertido := replace(ws_convertido, chr(13), ' '); --  Início da Linha
    ws_convertido := replace(ws_convertido, chr(14), ' '); --  Shift-out
    ws_convertido := replace(ws_convertido, chr(15), ' '); --  Shift-in
    ws_convertido := replace(ws_convertido, chr(16), ' '); --  Data link escape
    ws_convertido := replace(ws_convertido, chr(17), ' '); --  Controle de dispositivo
    ws_convertido := replace(ws_convertido, chr(18), ' '); --  Controle de dispositivo
    ws_convertido := replace(ws_convertido, chr(19), ' '); --  Controle de dispositivo
    ws_convertido := replace(ws_convertido, chr(20), ' '); --  Controle de dispositivo
    ws_convertido := replace(ws_convertido, chr(21), ' '); --  Negativa de Confirmação
    ws_convertido := replace(ws_convertido, chr(22), ' '); --  Synchronous idle
    ws_convertido := replace(ws_convertido, chr(23), ' '); --  Fim de transmissão de bloco
    ws_convertido := replace(ws_convertido, chr(24), ' '); --  Cancela
    ws_convertido := replace(ws_convertido, chr(25), ' '); --  Fim de meio de transmissão
    ws_convertido := replace(ws_convertido, chr(26), ' '); --  Substitui
    ws_convertido := replace(ws_convertido, chr(27), ' '); --  Escape
    ws_convertido := replace(ws_convertido, chr(28), ' '); --  Separador de Arquivo
    ws_convertido := replace(ws_convertido, chr(29), ' '); --  Separador de Grupo
    ws_convertido := replace(ws_convertido, chr(30), ' '); --  Separador de registro
    ws_convertido := replace(ws_convertido, chr(31), ' '); --  Separador de Unidade

    return ws_convertido; 
exception when others then 
    return 'Erro convertendo para JSON'; 
end converte_json;


-- Valida endereço de email 
function check_endereco_email ( prm_email varchar2 default null ) return varchar2 as
    ws_retorno varchar2(500);
begin
    ws_retorno := null; 

    if prm_email is null then
		ws_retorno := 'Endere&ccedil;o de e-mail precisa ser preenchido'; 
	elsif (length(prm_email) - length(replace(prm_email,'@'))) <> 1 then
		ws_retorno := 'Endere&ccedil;o de e-mail inv&aacute;lido, n&atilde;o identificado ou identificado mais de um @'; 
    elsif instr(substr(prm_email,instr(prm_email,'@'),2000),'.') = 0 then
		ws_retorno := 'Endere&ccedil;o de e-mail inv&aacute;lido, n&atilde;o identificado o ponto(.) no provedor'; 
    elsif substr(prm_email,length(prm_email),1) in ('.',',','*') then
		ws_retorno := 'Endere&ccedil;o de e-mail inv&aacute;lido, caractere inv&aacute;lido no final do endere&ccedil;o'; 
	end if; 

    return ws_retorno; 
exception when others then 
    return 'Erro validando e-mail'; 
end check_endereco_email;



function replace_binds_clob ( prm_query clob     default null, 
                              prm_binds varchar2 default null ) return clob as
    ws_query   clob;
    ws_count number;
	ws_valor varchar2(800);
	ws_loop  number;

begin
    if prm_query is null then 
        return null;
    end if;     

   	ws_query := prm_query;
    select regexp_count(ws_query, ':b[0-90-9]+') into ws_count from dual;

	ws_loop := 0;
	for i in 1..ws_count loop
	    ws_loop := ws_loop+1;
		begin
		    select column_value into ws_valor 
             from (select column_value, rownum as linha from table(fun.vpipe((prm_binds))) ) 
             where linha = ws_loop;
	    end;
		
	    select regexp_replace(ws_query, ':b[0-90-9]+', chr(39)||ws_valor||chr(39), ws_loop, 1) 
         into ws_query from dual;
	end loop;
    return ws_query; 
exception when others then 
    return 'Erro substituindo BINDs'; 
end replace_binds_clob;



function ret_svg ( prm_nome   varchar2  default null ) return varchar2 as 
    ws_retorno varchar2(32000);
    ws_nome    varchar2(300);
    ws_path    varchar2(32000);
begin 
    ws_retorno := null; 
    ws_path    := null;
    ws_nome    := replace(lower(prm_nome),'[path]','');
    if ws_nome = 'duplicate_icon' then 
        ws_retorno := '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M18 6v-6h-18v18h6v6h18v-18h-6zm-12 10h-4v-14h14v4h-10v10zm16 6h-14v-14h14v14zm-3-8h-3v-3h-2v3h-3v2h3v3h2v-3h3v-2z"/></svg>';         
    elsif ws_nome = 'anotacao_marcacao' then 
        -- 0 - circulo         -- ws_retorno := '<svg version="1.1" id="Camada_1" xmlns:svg="http://www.w3.org/2000/svg" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="15" height="15" viewBox="0 0 12 12" style="enable-background:new 0 0 12 10;" xml:space="preserve"> <style type="text/css"> 	.st0{fill:#BF0000;} </style> <circle class="st0" cx="9.5" cy="2.6" r="2.4"/> </svg>';                
        -- 1 - canto seta      -- ws_retorno := '<svg version="1.1" id="Camada_1" xmlns:svg="http://www.w3.org/2000/svg" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="15" height="15" viewBox="0 0 12 12" style="enable-background:new 0 0 12 10;" xml:space="preserve"> <style type="text/css"> .st0{fill:#BF0000;} </style> <polygon class="st0" points="8.2,2 7.4,2.9 9.1,4.6 10,3.6 12.1,7 12,-0.1 4.6,-0.1 4.7,0 "/> </svg>'; 
        -- 2 - canto triagulo  --ws_retorno := '<svg version="1.1" id="Camada_1" xmlns:svg="http://www.w3.org/2000/svg" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="15" height="15" viewBox="0 0 12 12" style="enable-background:new 0 0 12 10;" xml:space="preserve"> <style type="text/css"> .st0{fill:#BF0000;} </style> <polygon class="st0" points="4.6,-0.1 12.1,7 12,-0.1 "/> </svg>'; 
        -- 3 - canto borda 
         -- ws_retorno := '<svg version="1.1" id="Camada_1" xmlns:svg="http://www.w3.org/2000/svg" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="15" height="15" viewBox="0 0 12 12" style="enable-background:new 0 0 12 10; fill:#BF0000;" xml:space="preserve"> <polygon points="10,1.9 10,5 12.1,7 12,-0.1 4.6,-0.1 6.7,1.9 "/> </svg>'; 
        ws_retorno := '<svg version="1.1" id="Camada_1" xmlns:svg="http://www.w3.org/2000/svg" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="15" height="15" viewBox="4 0 8 8" style="enable-background:new 0 0 10 10; fill:#BF0000;" xml:space="preserve"> <polygon points="10,1.9 10,5 12.1,7 12,-0.1 4.6,-0.1 6.7,1.9 "/> </svg>'; 
    elsif ws_nome = 'etl_tarefa' then 
        ws_path    := '<path d="M17 3v-2c0-.552.447-1 1-1s1 .448 1 1v2c0 .552-.447 1-1 1s-1-.448-1-1zm-12 1c.553 0 1-.448 1-1v-2c0-.552-.447-1-1-1-.553 0-1 .448-1 1v2c0 .552.447 1 1 1zm13 13v-3h-1v4h3v-1h-2zm-5 .5c0 2.481 2.019 4.5 4.5 4.5s4.5-2.019 4.5-4.5-2.019-4.5-4.5-4.5-4.5 2.019-4.5 4.5zm11 0c0 3.59-2.91 6.5-6.5 6.5s-6.5-2.91-6.5-6.5 2.91-6.5 6.5-6.5 6.5 2.91 6.5 6.5zm-14.237 3.5h-7.763v-13h19v1.763c.727.33 1.399.757 2 1.268v-9.031h-3v1c0 1.316-1.278 2.339-2.658 1.894-.831-.268-1.342-1.111-1.342-1.984v-.91h-9v1c0 1.316-1.278 2.339-2.658 1.894-.831-.268-1.342-1.111-1.342-1.984v-.91h-3v21h11.031c-.511-.601-.938-1.273-1.268-2z"/>'; 
        ws_retorno := '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">'||ws_path||'</svg>';
    elsif ws_nome = 'etl_acao' then 
        ws_path    := '<path d="M12 2c5.514 0 10 4.486 10 10s-4.486 10-10 10-10-4.486-10-10 4.486-10 10-10zm0-2c-6.627 0-12 5.373-12 12s5.373 12 12 12 12-5.373 12-12-5.373-12-12-12zm-3 17v-10l9 5.146-9 4.854z"/>'; 
        ws_retorno := '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">'||ws_path||'</svg>';
    elsif ws_nome = 'zoom_column' then 
        ws_path    := '<path d="M13 8h-8v-1h8v1zm0 2h-8v-1h8v1zm-3 2h-5v-1h5v1zm11.172 12l-7.387-7.387c-1.388.874-3.024 1.387-4.785 1.387-4.971 0-9-4.029-9-9s4.029-9 9-9 9 4.029 9 9c0 1.761-.514 3.398-1.387 4.785l7.387 7.387-2.828 2.828zm-12.172-8c3.859 0 7-3.14 7-7s-3.141-7-7-7-7 3.14-7 7 3.141 7 7 7z"/>'; 
        ws_retorno := '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">'||ws_path||'</svg>';         
    elsif ws_nome = 'fila_integrador' then 
        ws_path    := '<g fill="rgb(0,0,0)"><path d="m14 3h-9v1h9z"></path><path d="m14 6h-9v1h9z"></path><path d="m14 9h-6.5v1h6.5z"></path><path d="m14 12h-9v1h9z"></path><path d="m2 7 3.5 2.5-3.5 2.5z"></path></g>'; 
        ws_retorno := '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">'||ws_path||'</svg>';
    elsif ws_nome = 'database_conect' then 
        ws_path    := '<path d="M12.967 21.893c-.703.07-1.377.107-1.959.107-3.412 0-8.008-1.002-8.008-2.614v-2.04c2.117 1.342 5.17 1.78 8.008 1.78.339 0 .681-.007 1.022-.021-.06-.644-.036-1.28.129-2.019-.408.026-.797.04-1.151.04-3.412 0-8.008-1.001-8.008-2.613v-2.364c2.116 1.341 5.17 1.78 8.008 1.78 1.021 0 2.068-.06 3.089-.196 1.91-1.766 4.603-2.193 6.903-1.231v-8.14c0-3.362-5.965-4.362-9.992-4.362-4.225 0-10.008 1.001-10.008 4.361v15.277c0 3.362 6.209 4.362 10.008 4.362 1.081 0 2.359-.086 3.635-.281-.669-.495-1.239-1.115-1.676-1.826zm-1.959-19.893c3.638 0 7.992.909 7.992 2.361 0 1.581-5.104 2.361-7.992 2.361-3.412.001-8.008-.905-8.008-2.361 0-1.584 4.812-2.361 8.008-2.361zm-8.008 4.943c2.117 1.342 5.17 1.78 8.008 1.78 2.829 0 5.876-.438 7.992-1.78v2.372c0 1.753-5.131 2.614-7.992 2.614-3.426-.001-8.008-1.007-8.008-2.615v-2.371zm15.5 7.057c-2.483 0-4.5 2.015-4.5 4.5s2.017 4.5 4.5 4.5 4.5-2.015 4.5-4.5-2.017-4.5-4.5-4.5zm-1.104 7.343l1.177-2.545-1.739.472 1.466-3.034 1.387-.393-.916 1.925 2.063-.557-3.438 4.132z"/>'; 
        ws_retorno := '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 26 26">'||ws_path||'</svg>'; 
    elsif ws_nome = 'data_download' then 
        ws_path    := '<g id="Layer_x0020_1"><g id="_479260776"><g><g><path d="m450 512h-359c-4 0-7-3-7-7v-470c0-4 3-7 7-7h244c4 0 7 3 7 7v95h108c4 0 7 3 7 7v368c0 4-3 7-7 7zm-352-14h345v-354h-108c-4 0-7-3-7-7v-95h-230z"></path></g><g><path d="m450 144h-115c-4 0-7-3-7-7v-102c0-3 2-5 4-6 3-1 6-1 8 1l115 102c2 2 2 5 1 7 0 3-3 5-6 5zm-108-14h90l-90-79z"></path></g><g><g><path d="m407 393h-273c-4 0-7-3-7-7s3-7 7-7h273c4 0 7 3 7 7s-3 7-7 7z"></path></g><g><path d="m407 435h-273c-4 0-7-3-7-7s3-7 7-7h273c4 0 7 3 7 7s-3 7-7 7z"></path></g><g><path d="m407 478h-273c-4 0-7-3-7-7s3-7 7-7h273c4 0 7 3 7 7s-3 7-7 7z"></path></g></g><g><path d="m271 324c-2 0-4-1-5-2l-57-61c-2-2-2-5-1-8 1-2 3-4 6-4h26v-113c0-4 3-7 7-7h47c4 0 7 3 7 7v113h26c3 0 5 2 6 4 1 3 1 6-1 8l-56 61c-1 1-3 2-5 2zm-41-61 41 44 40-44h-17c-4 0-7-3-7-7v-113h-33v113c0 4-3 7-7 7z"></path></g><g><path d="m91 484h-29c-4 0-7-3-7-7v-470c0-4 3-7 7-7h244c4 0 7 3 7 7v28c0 4-3 7-7 7s-7-3-7-7v-21h-230v456h22c4 0 7 3 7 7s-3 7-7 7z"></path></g></g></g></g>'; 
        -- ws_path    := '<path d="m51.09 57.67h-44.51a1 1 0 0 1 -1-1v-43.35a1 1 0 0 1 .29-.71l12.32-12.32a1 1 0 0 1 .71-.29h32.19a1 1 0 0 1 1 1v55.67a1 1 0 0 1 -1 1zm-43.51-2h42.51v-53.67h-30.78l-11.73 11.73z"></path><path d="m57.25 63.83h-44.51a1 1 0 0 1 -1-1v-6.16a1 1 0 0 1 2 0v5.16h42.51v-53.67h-5.16a1 1 0 0 1 0-2h6.16a1 1 0 0 1 1 1v55.67a1 1 0 0 1 -1 1z"></path><path d="m63.42 70h-44.51a1 1 0 0 1 -1-1v-6.17a1 1 0 0 1 2 0v5.17h42.51v-53.67h-5.17a1 1 0 0 1 0-2h6.17a1 1 0 0 1 1 1v55.67a1 1 0 0 1 -1 1z"></path><path d="m18.9 14.32h-12.32a1 1 0 1 1 0-2h11.32v-11.32a1 1 0 0 1 2 0v12.32a1 1 0 0 1 -1 1z"></path><path d="m28.84 39.58a1 1 0 0 1 -1-1v-11.8a1 1 0 0 1 2 0v11.8a1 1 0 0 1 -1 1z"></path><path d="m28.84 39.58a1 1 0 0 1 -.71-.3l-4.37-4.37a1 1 0 0 1 1.41-1.41l3.67 3.66 3.66-3.66a1 1 0 0 1 1.42 0 1 1 0 0 1 0 1.41l-4.38 4.37a1 1 0 0 1 -.7.3z"></path><path d="m36.86 44.21h-16a1 1 0 1 1 0-2h16a1 1 0 0 1 0 2z"></path>'; 
        -- ws_path    := '<g id="g1991"><path id="path1963" d="m255 324c-2.7527 0-5 2.2473-5 5v46c0 2.7527 2.2473 5 5 5h34c2.7527 0 5-2.2473 5-5v-35c0-.91071-.37051-1.76976-.99219-2.40625l-12.29297-12.58594c-.64316-.65849-1.52226-1.00781-2.42187-1.00781zm0 2h23v10c0 2.1987 1.8013 4 4 4h10v35c0 1.6793-1.3207 3-3 3h-34c-1.6793 0-3-1.3207-3-3v-46c0-1.6793 1.3207-3 3-3zm25 1.13867 10.60938 10.86133h-8.60938c-1.1253 0-2-.8747-2-2z" transform="translate(-240 -320)" font-variant-ligatures="normal" font-variant-position="normal" font-variant-caps="normal" font-variant-numeric="normal" font-variant-alternates="normal" font-variant-east-asian="normal" font-feature-settings="normal" font-variation-settings="normal" text-indent="0" text-align="start" text-decoration-line="none" text-decoration-style="solid" text-decoration-color="rgb(0,0,0)" text-transform="none" text-orientation="mixed" white-space="normal" shape-padding="0" shape-margin="0" inline-size="0" isolation="auto" mix-blend-mode="normal" solid-color="rgb(0,0,0)" solid-opacity="1" vector-effect="none"></path><path id="path1980" d="m272 338c-.55228 0-1 .44772-1 1v21.58594l-6.29297-6.29297c-.44271-.44059-.98444-.42198-1.41406 0-.39042.39051-.39042 1.02355 0 1.41406l8 8c.39053.39037 1.02353.39037 1.41406 0l8-8c.39042-.39051.39042-1.02355 0-1.41406-.39051-.39042-1.02355-.39042-1.41406 0l-6.29297 6.29297v-21.58594c0-.55228-.44772-1-1-1z" transform="translate(-240 -320)" font-variant-ligatures="normal" font-variant-position="normal" font-variant-caps="normal" font-variant-numeric="normal" font-variant-alternates="normal" font-variant-east-asian="normal" font-feature-settings="normal" font-variation-settings="normal" text-indent="0" text-align="start" text-decoration-line="none" text-decoration-style="solid" text-decoration-color="rgb(0,0,0)" text-transform="none" text-orientation="mixed" white-space="normal" shape-padding="0" shape-margin="0" inline-size="0" isolation="auto" mix-blend-mode="normal" solid-color="rgb(0,0,0)" solid-opacity="1" vector-effect="none"></path><path id="path1984" d="m23 48a1 1 0 0 0 -1 1 1 1 0 0 0 1 1h18a1 1 0 0 0 1-1 1 1 0 0 0 -1-1z" font-variant-ligatures="normal" font-variant-position="normal" font-variant-caps="normal" font-variant-numeric="normal" font-variant-alternates="normal" font-variant-east-asian="normal" font-feature-settings="normal" font-variation-settings="normal" text-indent="0" text-align="start" text-decoration-line="none" text-decoration-style="solid" text-decoration-color="rgb(0,0,0)" text-transform="none" text-orientation="mixed" white-space="normal" shape-padding="0" shape-margin="0" inline-size="0" isolation="auto" mix-blend-mode="normal" solid-color="rgb(0,0,0)" solid-opacity="1" vector-effect="none"></path></g>'; 
        --ws_path    := '<g id="Layer_9" data-name="Layer 9"><path d="m20.71 17.29a1 1 0 0 1 0 1.42l-4 4a1 1 0 0 1 -1.42 0l-4-4a1 1 0 0 1 1.42-1.42l2.29 2.3v-7.59a1 1 0 0 1 2 0v7.59l2.29-2.3a1 1 0 0 1 1.42 0zm6.29-7.57v17.28a3 3 0 0 1 -3 3h-16a3 3 0 0 1 -3-3v-22a3 3 0 0 1 3-3h12.06a3 3 0 0 1 2.31 1.08l3.93 4.72a3 3 0 0 1 .7 1.92zm-6-5.16v2.44a1 1 0 0 0 1 1h1.86zm4 5.44h-3a3 3 0 0 1 -3-3v-3h-11a1 1 0 0 0 -1 1v22a1 1 0 0 0 1 1h16a1 1 0 0 0 1-1z"></path></g>'; 
        --ws_path    := '<g id="Layer_2"><g><path d="m27.561 10.503-3.824-5.9c-.072-.111-.186-.189-.315-.217l-13.502-2.87c-.13-.028-.265-.002-.376.069-.111.073-.189.186-.217.316l-.789 3.723h-3.68c-.276 0-.5.224-.5.5v23.872c0 .276.224.5.5.5h18.766c.276 0 .5-.224.5-.5v-2.601l3.506-16.514c.028-.131.003-.266-.069-.378zm-22.203 18.992v-22.871h12.796v4.476c0 .276.224.5.5.5h4.47v17.896h-17.766zm17.057-18.895h-3.26v-3.267zm1.71 11.977v-11.473c0-.068-.015-.134-.041-.195-.027-.065-.067-.121-.116-.169l-4.954-4.965c-.091-.095-.217-.155-.359-.155-.004 0-.008.002-.012.002h-9.083l.642-3.025 12.81 2.723 3.598 5.553z"></path><path d="m20.268 13.161h-12.053c-.276 0-.5.224-.5.5v5.304c0 .276.224.5.5.5h12.053c.276 0 .5-.224.5-.5v-5.304c0-.277-.224-.5-.5-.5zm-.5 1v1.652h-11.053v-1.652zm-11.053 4.303v-1.652h11.053v1.652z"></path><path d="m13.168 24.351h-.982v-3.354c0-.276-.224-.5-.5-.5h-2.009c-.276 0-.5.224-.5.5v3.354h-.962c-.193 0-.369.111-.451.285-.083.174-.059.38.063.53l2.477 3.054c.095.117.237.185.388.185s.293-.068.388-.185l2.477-3.054c.122-.15.146-.356.063-.53s-.259-.285-.452-.285zm-2.477 2.76-1.427-1.76h.413c.276 0 .5-.224.5-.5v-3.354h1.009v3.354c0 .276.224.5.5.5h.433z"></path></g></g>'; 
        ws_retorno := '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 520 520">'||ws_path||'</svg>    '; 
    elsif ws_nome = 'exportar' then
        ws_path    := '<g><g><path d="M492.703,0H353.126c-10.658,0-19.296,8.638-19.296,19.297c0,10.658,8.638,19.296,19.296,19.296h120.281v120.281 c0,10.658,8.638,19.296,19.296,19.296c10.658,0,19.297-8.638,19.297-19.296V19.297C512,8.638,503.362,0,492.703,0z"/></g></g><g><g><path d="M506.346,5.654c-7.538-7.539-19.747-7.539-27.285,0L203.764,280.95c-7.539,7.532-7.539,19.753,0,27.285 c3.763,3.769,8.703,5.654,13.643,5.654c4.933,0,9.873-1.885,13.643-5.654L506.346,32.939 C513.885,25.407,513.885,13.186,506.346,5.654z"/></g></g><g><g><path d="M427.096,239.92c-10.658,0-19.297,8.638-19.297,19.296v214.191H38.593V104.201h214.191 c10.658,0,19.296-8.638,19.296-19.296s-8.638-19.297-19.296-19.297H19.297C8.638,65.608,0,74.246,0,84.905v407.799 C0,503.362,8.638,512,19.297,512h407.799c10.664,0,19.296-8.638,19.296-19.297V259.216 C446.392,248.558,437.754,239.92,427.096,239.92z"/></g></g>';
        ws_retorno := '<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 512 512" style="height: 34px; width: 20px; fill: #333; margin-left: 2px; enable-background:new 0 0 512 512;" xml:space="preserve">'||ws_path||'</svg>';
    end if; 

    if lower(prm_nome) like '[path]' then 
        ws_retorno := ws_path;     
    end if; 

    return (ws_retorno);     
end;  


function lista_padrao_ds ( prm_cd_lista varchar2, 
                           prm_cd_item  varchar2 ) return varchar2 as 
    ws_ds_item varchar2(200);
begin 
    select nvl(max(ds_item),prm_cd_item) into ws_ds_item
	  from bi_lista_padrao 
    where cd_lista = prm_cd_lista 
      and cd_item  = prm_cd_item ;

    return ws_ds_item;  

end lista_padrao_ds;


procedure valida_formula (prm_tipo            in varchar2 default 'COLUNA',
	                      prm_formula         in varchar2 default null,
						  prm_screen          in varchar2 default null,
						  prm_objeto          in varchar2 default null,
						  prm_visao           in varchar2 default null,
    	                  prm_coluna          in varchar2 default null,
            	          prm_retorno        out varchar2  )  as 
    ws_cursor       integer;
    ws_agrupador    varchar2(100);
    ws_flex         varchar2(200);
    ws_formula      varchar2(32000); 
    ws_formula_aux  varchar2(32000); 
    ws_sql          varchar2(32000); 
    ws_erro_ora     varchar2(4000); 
    ws_erro         varchar2(4000); 
    ws_erro2        varchar2(4000); 
    ws_carac        varchar2(10);  
    ws_aspas        varchar2(15);
    ws_qt_par_e     integer;
    ws_qt_par_d     integer; 
    ws_qt_coc_e     integer;
    ws_qt_coc_d     integer; 
    ws_qt_agrup     integer; 
    ws_qt_refer     integer; 
    ws_nm_tabela    varchar2(300); 

    erro_geral      exception; 
begin 

    prm_retorno := null;
    ws_formula  := null;
    ws_erro     := null; 
    ws_erro2    := null; 

    ws_formula := prm_formula; 

    if ws_formula is null then 
        ws_erro := 'F&oacute;rmula n&atilde;o identificada para a vis&atilde;o e coluna';
        raise erro_geral; 
    end if; 

    -- Conta a existência de alguns simbolos ou funções
    ----------------------------------------------------------------------------
    ws_formula_aux := upper(replace(ws_formula,' ','')); 
    ws_aspas       := 'FECHADA';
    ws_qt_par_e    := 0;
    ws_qt_par_d    := 0;
    ws_qt_coc_e    := 0;
    ws_qt_coc_d    := 0;
    ws_qt_agrup    := 0;
    for a in 1..length(ws_formula_aux) loop 
        ws_carac := substr(ws_formula_aux,a,1); 
        if ws_carac = chr(39) then 
            if ws_aspas = 'ABERTA' then 
                ws_aspas := 'FECHADA';
            else 
                ws_aspas := 'ABERTA';
            end if; 
        end if; 
        if ws_aspas = 'FECHADA' then 
            if    ws_carac = '(' then  ws_qt_par_e := ws_qt_par_e + 1;        
            elsif ws_carac = ')' then  ws_qt_par_d := ws_qt_par_d + 1;
            elsif ws_carac = '[' then  ws_qt_coc_e := ws_qt_coc_e + 1;
            elsif ws_carac = ']' then  ws_qt_coc_d := ws_qt_coc_d + 1;
            end if; 
            --
            if    substr(ws_formula_aux,a,4) = 'SUM('   then  ws_qt_agrup := ws_qt_agrup + 1; 
            elsif substr(ws_formula_aux,a,4) = 'MAX('   then  ws_qt_agrup := ws_qt_agrup + 1; 
            elsif substr(ws_formula_aux,a,4) = 'MIN('   then  ws_qt_agrup := ws_qt_agrup + 1; 
            elsif substr(ws_formula_aux,a,4) = 'NVL('   then  ws_qt_agrup := ws_qt_agrup + 1; 
            elsif substr(ws_formula_aux,a,6) = 'COUNT(' then  ws_qt_agrup := ws_qt_agrup + 1; 
            end if; 
            if    substr(ws_formula_aux,a,2) = '$['  then  ws_qt_refer := ws_qt_refer + 1; 
            elsif substr(ws_formula_aux,a,2) = '@['  then  ws_qt_refer := ws_qt_refer + 1; 
            elsif substr(ws_formula_aux,a,2) = '#['  then  ws_qt_refer := ws_qt_refer + 1; 
            elsif substr(ws_formula_aux,a,2) = '&['  then  ws_qt_refer := ws_qt_refer + 1; 
            end if; 
        end if; 
    end loop;     

    if ws_qt_par_d < ws_qt_par_e then 
        ws_erro := 'Falta par&ecirc;ntese a direita';
        raise erro_geral; 
    elsif ws_qt_par_d > ws_qt_par_e then 
        ws_erro := 'Falta par&ecirc;ntese a esquerda';
        raise erro_geral; 
    end if;     
    if ws_qt_coc_d < ws_qt_coc_e then 
        ws_erro := 'Falta colchetes a direita';
        raise erro_geral; 
    elsif ws_qt_coc_d > ws_qt_coc_e then 
        ws_erro := 'Falta colchetes a esquerda';
        raise erro_geral; 
    end if;     

    if prm_visao is not null and prm_coluna is not null then 

        if ws_formula is not null then   -- Atualiza o campo fórmula
            update micro_coluna
			   set formula = ws_formula 
			 where cd_micro_visao = prm_visao 
			   and cd_coluna      = prm_coluna;
            commit;    
        end if;        

        begin 
            select formula, st_agrupador, flexcol 
              into ws_formula, ws_agrupador, ws_flex 
              from micro_coluna
             where cd_micro_visao = prm_visao 
               and cd_coluna      = prm_coluna ;
        exception when others then 
            ws_erro := 'Micro vis&atilde;o ou coluna inv&aacute;lida';
            raise erro_geral; 
        end; 
    else 
        ws_agrupador := 'SEM'; 
        ws_flex      := null;
    end if; 

    if prm_visao is not null then 
        select max(nm_tabela) into ws_nm_tabela 
          from micro_visao
         where nm_micro_visao = prm_visao; 
        if ws_nm_tabela is null then 
            ws_erro := 'N&atilde;o foi poss&iacute;vel localizar a tabela ou view referente a micro vis&atilde;o';
        end if; 
    end if; 

    if prm_formula is not null then 
        ws_formula := prm_formula;
    end if;     

    if ws_formula is null then 
        ws_erro := 'N&atilde;o informada a f&oacute;rmula para valida&ccedil;&atilde;o';
        raise erro_geral; 
    end if; 

    --
    if prm_coluna is null  then

        -- Fórmula somente com referência a outros objetos, filtros ou variávies de sistema (não precisa de visão e coluna)
        ws_formula := fun.subpar(ws_formula, prm_screen, prm_valida => 'S');

    else
        --
        if ws_agrupador = 'SEM' and ws_qt_agrup <> 0 then 
            ws_erro := 'Fun&ccedil;&otilde;es agrupadoras (SUM,MAX,MIN,NVL,COUNT) n&atilde;o podem ser utilizadas em colunas com Agrupador igual a SEM';
            raise erro_geral; 
        end if; 

        -- Fórmula com referências também a outras colunas da visão (precisa da visão e da coluna)
        if prm_visao is null or prm_coluna is null then 
            ws_erro := 'Micro vis&atilde;o e coluna devem ser informados para valida&ccedil;&atilde;o da f&oacute;rmula';
            raise erro_geral;
        end if; 

        ws_formula := fun.gformula2(prm_visao, prm_coluna, prm_screen, 'N', prm_objeto, prm_formula => ws_formula, prm_valida => 'S');
    end if;     

    if ws_formula like '%#ERROI#%' then 
       ws_erro  := substr(ws_formula, instr(ws_formula,'#ERROI#')+7, (instr(ws_formula,'#ERROF#')-(instr(ws_formula,'#ERROI#')+7)) ); 
       raise erro_geral; 
    end if; 

    -- Valida SQL no banco de dados (se foi passado a visão)
    if prm_visao is not null then 
        ws_sql     := 'select ('||ws_formula||') from '||nvl(fun.ret_var('OWNER_TABLE_DATA'),'DWU')||'.'||ws_nm_tabela ;  

        ws_cursor := dbms_sql.open_cursor;
        begin 
            dbms_sql.parse( c => ws_cursor, statement => ws_sql, language_flag => dbms_sql.native );
        exception when others then 
            ws_erro_ora := substr(DBMS_UTILITY.FORMAT_ERROR_STACK,1,100); 
            if    ws_erro_ora like '%ORA-00942%' then     ws_erro  := 'tabela ou vis&atilde;o n&atilde;o existe'; 
            elsif ws_erro_ora like '%ORA-00904%' then     ws_erro  := 'identificador ou coluna inv&aacute;lida'; 
            elsif ws_erro_ora like '%ORA-00978%' then     ws_erro  := 'fun&ccedil;&atilde;o de grupo duplicada ou usada de forma errada'; 
            else                                          ws_erro  := 'verifique espa&ccedil;os, comandos ou operadores inv&aacute;lidos';   
                                                          ws_erro2 := '('||ws_sql||') '||substr(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,499);
            end if;     
            
            ws_erro := 'F&oacute;rmula inv&aacute;lida, '||ws_erro;  
            raise erro_geral;  
        end;     
    end if; 

    prm_retorno := 'OK|F&oacute;rmula OK|'; 
    
exception 
    when erro_geral then 
        prm_retorno := 'ERRO|'||ws_erro||'|'; 
        if ws_erro2 is not null then 
           	insert into bi_log_sistema values(sysdate, 'valida_formula:'||ws_erro2, user, 'ERRO');
        	commit;
        end if; 
    when others then
        ws_erro := 'Erro validando f&oacute;rmula, verifique o log do sistema para mais detalhes sobre o erro'; 
        prm_retorno := 'ERRO|'||ws_erro||'|'; 
      	insert into bi_log_sistema values(sysdate, substr('valida_formula:'||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,1,3999), user, 'ERRO');
    	commit;

end valida_formula; 



function user_permissao (prm_usuario         in varchar2,
                         prm_permissao       in varchar2 ) return varchar2 is 
    ws_count integer; 
begin
    select count(*) into ws_count from user_permissao where cd_usuario= prm_usuario and cd_permissao = prm_permissao; 
    if ws_count > 0 then 
        return 'S';
    else 
        return 'N';
    end if;
end;                            

function get_cd_obj (prm_objeto   in varchar2) return varchar2 is 
    ws_objeto  varchar2(100); 
begin
    if instr(prm_objeto,'trl') > 0 then 
        ws_objeto := substr(prm_objeto,1,instr(prm_objeto,'trl',1,1)-1);
    else 
        ws_objeto := prm_objeto;
    end if;	
    return ws_objeto; 
end;                            

procedure modal_txt_sup (prm_txt in varchar2) is 
    ws_id_modal     varchar2(100);
    ws_btn_fechar   varchar2(2000); 
    ws_txt          varchar2(32000);
begin
    ws_id_modal   := 'modal-txt-content';
	ws_btn_fechar := '<a class="addpurple" onclick="document.getElementById('''||ws_id_modal||''').classList.remove(''expanded''); setTimeout(function(){ document.getElementById('''||ws_id_modal||''').remove(); }, 200);">FECHAR</a>'; 

   	htp.p('<div class="modal-txt-content" id="'||ws_id_modal||'">');
		htp.p('<div id="modal-txt-input">'||prm_txt||'</div>'); 
        -- htp.p('<input id="modal-txt-input" value="'||prm_txt||'"/>'); 
        -- htp.p('<input id="modal-txt-input" value="teste" />'); 
		htp.p('<div class="modal-txt-bar-btn">');
			htp.p(ws_btn_fechar);
		htp.p('</div>');			
	htp.p('</div>');

end modal_txt_sup;


procedure log_exec_atu (prm_acao            varchar2 default 'INSERT',
                        prm_log_exec        varchar2 default 'D',
                        prm_id_exec  in out varchar2, 
                        prm_cd_obj          varchar2 default null,
                        prm_usuario         varchar2 default null,
                        prm_tp_exec         varchar2 default null,
                        prm_sq_exec         integer  default null,
                        prm_ds_exec         varchar2 default null,
                        prm_query           clob     default null) is 
begin
    if prm_acao = 'INSERT' or (prm_acao = 'FIM' and prm_log_exec = 'S') then 
        if prm_id_exec is null then 
            prm_id_exec := fun.gen_id||upper(fun.randomCode(4)); 
        end if;     
        begin
            execute immediate 'insert into bi_log_exec (id_exec, cd_objeto, cd_usuario, tp_exec, sq_exec, ds_exec, dh_exec, query_exec) values (:1, :2, :3, :4, :5, :6, :7, :8)' 
                        using in prm_id_exec, prm_cd_obj, prm_usuario, prm_tp_exec, prm_sq_exec, prm_ds_exec, sysdate, prm_query;  
        exception when others then 
            insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values(sysdate, 'Erro insert bi_log_exec:'||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getUsuario, 'ERRO');
        end;     
        commit;
    elsif prm_acao = 'DELETE' or (prm_acao = 'FIM' and prm_log_exec = 'D') then 
        if prm_id_exec is not null then 
            begin
                execute immediate 'delete bi_log_exec where id_exec = :1' using in prm_id_exec;  
            exception when others then 
                insert into bi_log_sistema (dt_log, ds_log, nm_usuario, nm_procedure) values(sysdate, 'Erro delete bi_log_exec:'||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, gbl.getUsuario, 'ERRO');
            end;     
            commit;            
        end if;
    end if;     
end log_exec_atu;                            

function conv_jet_comando (prm_comando  clob) return clob is 
begin 
    return null; 
end conv_jet_comando;

procedure atu_traducao_colunas (prm_tabela          varchar2,
                                prm_coluna          varchar2,
                                prm_tipo            varchar2,
                                prm_linguagem       varchar2,
                                prm_texto           varchar2,
                                prm_lang_default    varchar2 ) is 
    ws_lang_sys   varchar2(100); 
    ws_count      integer;
begin
    ws_lang_sys := fun.ret_var('LANG_SYS'); 

    if prm_linguagem <> ws_lang_sys then    
        -- Atualiza a tradução no idioma do usuário 
        --------------------------------------------
        update traducao_colunas
           set texto = prm_texto
         where cd_tabela    = prm_tabela 
           and cd_coluna    = prm_coluna 
           and tipo         = prm_tipo 
           and cd_linguagem = prm_linguagem 
           and lang_default = prm_lang_default;
        if sql%notfound then 
            insert into traducao_colunas (cd_tabela,  cd_coluna,  cd_linguagem,  texto,     lang_default,     tipo,     fixa)
                                  values (prm_tabela, prm_coluna, prm_linguagem, prm_texto, prm_lang_default, prm_tipo, 'N');
        end if; 
    else 
        -- Atualiza a lang_default de todos os idiomas, inclusive a nativa 
        --------------------------------------------
        update traducao_colunas
           set texto        = decode(cd_linguagem, ws_lang_sys, prm_texto, texto),
               lang_default = prm_lang_default
         where cd_tabela    = prm_tabela 
           and cd_coluna    = prm_coluna 
           and tipo         = prm_tipo
           and lang_default = prm_lang_default;
    end if; 

end atu_traducao_colunas;

function lista_objetos_tela (prm_screen varchar2 ) return varchar2 is 
    ws_lista varchar2(32000) := null;
begin 
    for a in (select object_id from object_location where screen = prm_screen order by object_id) loop 
        ws_lista := ws_lista||'|'||a.object_id; 
        for b in (select object_id from object_location where screen = a.object_id order by object_id) loop 
            ws_lista := ws_lista||'|'||b.object_id;             
            for c in (select object_id from object_location where screen = b.object_id order by object_id) loop 
                ws_lista := ws_lista||'|'||c.object_id;
            end loop;     
        end loop;     
    end loop; 
    ws_lista := substr(ws_lista,2,999999);  -- Retira o | no inicio do texto 

    return ws_lista; 

end lista_objetos_tela;


end FUN;


