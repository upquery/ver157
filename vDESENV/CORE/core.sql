create or replace package body  CORE  is

         ---------------------------------------------------------------------------------------------------------------   
         -- Quando esse cursor for alterado tem que altar o mesmo cursor no BIND_DIRECT também 
         -- 
         -- Float Filter (filtro float por tela)     - FLOAT_FILTER_ITEM   
         -- Filtros passados para DRILL e subquery   - prm_condicoes 
         -- Filtro de objetos e filtros de tela tela - FILTROS
         -- e Filtro de DRE                          - DEFF_LINE_FILTRO
         ---------------------------------------------------------------------------------------------------------------
         cursor crs_filtrog (  prm_condicoes    varchar2,    
                               prm_micro_visao  varchar2,
                               prm_screen       varchar2,
                               prm_objeto       varchar2,
                               prm_usuario      varchar2, 
                               prm_vpar         varchar2,
                               prm_cd_mapa      varchar2,
                               prm_nr_item      varchar2,
                               prm_cd_padrao    varchar2 ) is

            select distinct *
             from ( -- Float FILTER - filtra valores IGUAIS ou DEFERENTES do informado no filtro 
                    select 'C'                                   as indice,
                           'DWU'                                 as cd_usuario,
                           trim(prm_micro_visao)                 as micro_visao,
                           trim(cd_coluna)                       as cd_coluna,
                           decode(instr(trim(conteudo),'$[NOT]'),0,'IGUAL', 'DIFERENTE')  as condicao,
                           replace(trim(CONTEUDO), '$[NOT]', '') as conteudo,
                           'and'                                 as ligacao,
                           'float_filter_item'                   as tipo
                      from FLOAT_FILTER_ITEM
                     where cd_usuario = prm_usuario 
                       and screen     = trim(prm_screen) 
                       and fun.getprop(prm_objeto,'FILTRO_FLOAT') = 'N'   -- Atributo: BLOQUEAR FILTRO DO FLOAT (ignorar todos os float_filter do objeto) 
                       -- card 833s - and cd_coluna not in (select cd_coluna from filtros where condicao = 'NOFLOAT' and micro_visao = trim(prm_micro_visao) and cd_objeto = trim(prm_objeto) and tp_filtro = 'objeto') -- Ignora o filtro se ele estiver cadastrado no objeto como NOFLOAT
                       and cd_coluna not in (select cd_coluna from filtros where micro_visao = trim(prm_micro_visao) and cd_objeto = trim(prm_objeto) and tp_filtro = 'objeto') -- card 833s - Ignora o filtro se ele estiver cadastrado no objeto como NOFLOAT
                       and cd_coluna in ( select trim(cd_coluna) from micro_coluna mc where mc.cd_micro_visao = trim(prm_micro_visao) ) 
                    --	
                    union all
                    --
                    -- Filtros passados por parametro se for consulta CUSTOMIZADA (p_codicoes)
                    select 'A'                   as indice,
                           'DWU'                 as cd_usuario,
                           trim(prm_micro_visao) as micro_visao,
                           trim(cd_coluna)       as cd_coluna,
                           cd_condicao           as condicao,
                           trim(CD_CONTEUDO)     as conteudo,
                           'and'                 as ligacao,
                           'condicoes'           as tipo
                      from table(fun.vpipe_par(prm_condicoes)) pc
                     where cd_coluna <> '1' 
                       and prm_objeto like 'COBJ%'
                    -- 
                    union all
                    --
                    -- Filtros passados por parametro para uma Drill ou subquery (p_codicoes)
                    select 'A'                   as indice,
                           'DWU'                 as cd_usuario,
                           trim(prm_micro_visao) as micro_visao,
                           trim(cd_coluna)       as cd_coluna,
                           cd_condicao           as condicao,
                           trim(CD_CONTEUDO)     as conteudo,
                           'and'                 as ligacao,
                           'condicoes'           as tipo
                      from table(fun.vpipe_par(prm_condicoes)) pc
                     where cd_coluna <> '1' 
                       and prm_objeto not like 'COBJ%'
                       and fun.getprop(prm_objeto,'FILTRO_DRILL') = 'N'  -- Atributo: BLOQUEAR FILTRO DA DRILL (ignorar todos os filtros repassados por parametro (DRILL))                        
                       and cd_coluna in ( select trim(cd_coluna) from micro_coluna     where cd_micro_visao = trim(prm_micro_visao) union all
                                          select trim(cd_coluna) from micro_visao_fpar where cd_micro_visao = trim(prm_micro_visao) )
                       and trim(cd_coluna)||trim(cd_conteudo) not in ( select nof.cd_coluna||nof.CONTEUDO  -- Ignora filtro se estiver cadastrados no objeto como IGNORAR FILTRO
                                                                         from filtros nof
                                                                        where nof.micro_visao = trim(prm_micro_visao) 
                                                                          and nof.condicao    = 'NOFILTER' 
                                                                          and nof.conteudo    = trim(pc.cd_conteudo) 
                                                                          and nof.cd_objeto   = trim(prm_objeto)
                                                                      )
                    --
                    union all
                    --
                    select 'X'                     as indice,
                           'DWU'                   as cd_usuario,
                           rtrim(prm_micro_visao)  as micro_visao,
                           rtrim(cd_coluna)        as cd_coluna,
                           rtrim(condicao)         as condicao,
                           rtrim(conteudo)         as conteudo,
                           rtrim(ligacao)          as ligacao,
                           'deff_line_filtro'      as tipo
                      from DEFF_LINE_FILTRO
                     where cd_mapa   = prm_cd_mapa 
                       and nr_item   = prm_nr_item 
                       and cd_padrao = prm_cd_padrao
                    --
                    union all
                    --
                    -- Filtros de objeto ou tela  (que não seja NOFLOAT e NOFILTER)
                    select decode(cd_objeto, trim(prm_objeto), 'B', 'C') as indice,
                           rtrim(cd_usuario)  as cd_usuario,
                           rtrim(micro_visao) as micro_visao,
                           rtrim(cd_coluna)   as cd_coluna,
                           rtrim(condicao)    as condicao,
                           rtrim(conteudo)    as conteudo,
                           rtrim(ligacao)     as ligacao,
                           'filtros_objeto'   as tipo
                      from FILTROS
                     where micro_visao = trim(prm_micro_visao) 
                       and CONDICAO not in ('NOFLOAT', 'NOFILTER')   -- Não pegar filtros cadastrados somente para ignorar filtros de tela
                       and st_agrupado      = 'N' 
                       and tp_filtro        = 'objeto' 
                       and cd_usuario       = 'DWU'
                       and ( (cd_objeto = trim(prm_objeto) ) or   -- Filtro de objeto 
                             (cd_objeto = trim(prm_screen)   -- Filtro de tela  
                              and nvl(fun.GETPROP(trim(prm_objeto),'FILTRO'), 'N/A') not in ('ISOLADO', 'COM CORTE')  
                              and fun.getprop(prm_objeto,'FILTRO_TELA') <> 'S'     -- atributo BLOQUEAR FILTRO DE TELA diferente de S   
                              and cd_coluna not in (select t2.cd_coluna 
                                                      from filtros t2 
                                                     where t2.condicao    = 'NOFLOAT' 
                                                       and t2.micro_visao = trim(prm_micro_visao) 
                                                       and t2.cd_objeto   = trim(prm_objeto) 
                                                       and t2.tp_filtro   = 'objeto'
                                                   ) -- Ignora o filtro se ele estiver cadastrado no objeto como NOFLOAT
                             ) 
                           ) 
                )
            where not ( trim(condicao)='IGUAL' and trim(cd_coluna) in (select trim(cd_coluna) from table(fun.vpipe_par(prm_vpar))))
            --order by tipo, cd_usuario, micro_visao, cd_coluna, condicao, conteudo;
            order by indice, cd_coluna, condicao, tipo, cd_usuario, micro_visao, conteudo;

    -- Filtro DE USUÁRIO 
    cursor crs_filtro_usuario (prm_micro_visao  varchar2,
                               prm_coluna       varchar2,  
                               prm_usuario      varchar2) is 
        select distinct cd_coluna,
               decode(trim(condicao), 'IGUAL', '=', 'DIFERENTE', '<>', 'MAIOR', '>', 'MENOR', '<', 'MAIOROUIGUAL', '>=', 'MENOROUIGUAL', '<=', 'LIKE', 'like', 'NOTLIKE', 'not like')    as condicao,
               trim(conteudo)    as conteudo,
               ligacao           as ligacao
          from FILTROS t1
         where micro_visao    = nvl(prm_micro_visao, micro_visao) 
           and cd_coluna      = nvl(prm_coluna, cd_coluna)
           and tp_filtro      = 'geral' 
           and st_agrupado    = 'N' 
           and ( cd_usuario in (prm_usuario, 'DWU') or cd_usuario in (select cd_group from gusers_itens where cd_usuario = prm_usuario)) 
         order by cd_coluna, condicao, conteudo;

    -- Filtros cadastrados direto na visão (descontinuado) 
    cursor crs_fpar (prm_micro_visao  varchar2) is
            Select Cd_Coluna, Cd_parametro
              from MICRO_VISAO_FPAR
             where cd_micro_visao = prm_micro_visao
             order by cd_coluna;
    

    FUNCTION MONTA_QUERY_DIRECT ( prm_micro_visao		    in  long	default null,
							      prm_coluna		        in  long	default null,
							      prm_condicoes             in  long	default null,
							      prm_rp                    in  long	default null,
							      prm_colup                 in  long	default null,
							      prm_query_pivot           out long,
							      prm_query_padrao          out DBMS_SQL.VARCHAR2a,
							      prm_linhas                out number,
							      prm_ncolumns              out DBMS_SQL.VARCHAR2_TABLE,
							      prm_pvpull                out DBMS_SQL.VARCHAR2_TABLE,
							      prm_agrupador             in  long,
							      prm_mfiltro               out DBMS_SQL.VARCHAR2_TABLE,
							      prm_objeto		        in  varchar2    default null,
							      prm_ordem		            in  varchar2	default '1',
							      prm_screen                in  long        default null,
							      prm_cross                 in  varchar2 default null,
							      prm_cab_cross             out varchar2,
							      prm_self                  in varchar2 default null,
                                  prm_usuario               in varchar2 default null,
                                  prm_popup_drill           in varchar2 default 'false'  ) return varchar2 as

         ---------------------------------------------------------------------------------------------------------------   
         -- Quando esse cursor for alterado tem que altar o mesmo cursor no BIND_DIRECT também 
         -- 
         -- Float Filter (filtro float por tela)     - FLOAT_FILTER_ITEM   
         -- Filtros passados para DRILL e subquery   - prm_condicoes 
         -- Filtro de objetos e filtros de tela tela - FILTROS
         -- e Filtro de DRE                          - DEFF_LINE_FILTRO
         ---------------------------------------------------------------------------------------------------------------
         cursor crs_filtrog (  prm_condicoes    varchar2,    
                               prm_micro_visao  varchar2,
                               prm_screen       varchar2,
                               prm_objeto       varchar2,
                               prm_usuario      varchar2, 
                               prm_vpar         varchar2,
                               prm_cd_mapa      varchar2,
                               prm_nr_item      varchar2,
                               prm_cd_padrao    varchar2 ) is

            select distinct *
             from ( -- Float FILTER - filtra valores IGUAIS ou DEFERENTES do informado no filtro 
                    select 'C'                                   as indice,
                           'DWU'                                 as cd_usuario,
                           trim(prm_micro_visao)                 as micro_visao,
                           trim(cd_coluna)                       as cd_coluna,
                           decode(instr(trim(conteudo),'$[NOT]'),0,'IGUAL', 'DIFERENTE')  as condicao,
                           replace(trim(CONTEUDO), '$[NOT]', '') as conteudo,
                           'and'                                 as ligacao,
                           'float_filter_item'                   as tipo
                      from FLOAT_FILTER_ITEM
                     where cd_usuario  = prm_usuario 
                       and screen      = trim(prm_screen) 
                       and fun.getprop(prm_objeto,'FILTRO_FLOAT') = 'N'   -- Atributo: BLOQUEAR FILTRO DO FLOAT (ignorar todos os float_filter do objeto) 
                       -- card 833s - and cd_coluna not in (select cd_coluna from filtros where condicao = 'NOFLOAT' and micro_visao = trim(prm_micro_visao) and cd_objeto = trim(prm_objeto) and tp_filtro = 'objeto') -- Ignora o filtro se ele estiver cadastrado no objeto como NOFLOAT
                        and cd_coluna not in (select cd_coluna from filtros where micro_visao = trim(prm_micro_visao) and cd_objeto = trim(prm_objeto) and tp_filtro = 'objeto') -- card 833s - Ignora o filtro se ele estiver cadastrado como filtro no objeto 
                        and cd_coluna in ( select trim(cd_coluna) from micro_coluna mc where mc.cd_micro_visao = trim(prm_micro_visao) ) 
                    --
                    union all
                    --
                    -- Filtros passados por parametro se for consulta CUSTOMIZADA (p_codicoes)
                    select 'A'                   as indice,
                           'DWU'                 as cd_usuario,
                           trim(prm_micro_visao) as micro_visao,
                           trim(cd_coluna)       as cd_coluna,
                           cd_condicao           as condicao,
                           trim(CD_CONTEUDO)     as conteudo,
                           'and'                 as ligacao,
                           'condicoes'           as tipo
                      from table(fun.vpipe_par(prm_condicoes)) pc
                     where cd_coluna <> '1' 
                       and prm_objeto like 'COBJ%'
                    -- 
                    union all
                    --
                    -- Filtros passados por parametro para uma Drill ou subquery (p_codicoes)
                    select 'A'                   as indice,
                           'DWU'                 as cd_usuario,
                           trim(prm_micro_visao) as micro_visao,
                           trim(cd_coluna)       as cd_coluna,
                           cd_condicao           as condicao,
                           trim(CD_CONTEUDO)     as conteudo,
                           'and'                 as ligacao,
                           'condicoes'           as tipo
                      from table(fun.vpipe_par(prm_condicoes)) pc
                     where cd_coluna <> '1' 
                       and prm_objeto not like 'COBJ%'
                       and fun.getprop(prm_objeto,'FILTRO_DRILL') = 'N'  -- Atributo: BLOQUEAR FILTRO DA DRILL (ignorar todos os filtros repassados por parametro (DRILL))                        
                       and cd_coluna in ( select trim(cd_coluna) from micro_coluna     where cd_micro_visao = trim(prm_micro_visao) union all
                                          select trim(cd_coluna) from micro_visao_fpar where cd_micro_visao = trim(prm_micro_visao)
                                        )
                       and trim(cd_coluna)||trim(cd_conteudo) not in ( select nof.cd_coluna||nof.CONTEUDO  -- Ignora filtro se estiver cadastrados no objeto como IGNORAR FILTRO
                                                                         from filtros nof
                                                                        where nof.micro_visao = trim(prm_micro_visao) 
                                                                          and nof.condicao    = 'NOFILTER' 
                                                                          and nof.conteudo    = trim(pc.cd_conteudo) 
                                                                          and nof.cd_objeto   = trim(prm_objeto)
                                                                      )
                    --
                    union all
                    --
                    select 'X'                     as indice,
                           'DWU'                   as cd_usuario,
                           rtrim(prm_micro_visao)  as micro_visao,
                           rtrim(cd_coluna)        as cd_coluna,
                           rtrim(condicao)         as condicao,
                           rtrim(conteudo)         as conteudo,
                           rtrim(ligacao)          as ligacao,
                           'deff_line_filtro'      as tipo
                      from DEFF_LINE_FILTRO
                     where cd_mapa   = prm_cd_mapa 
                       and nr_item   = prm_nr_item 
                       and cd_padrao = prm_cd_padrao
                    --
                    union all
                    --
                    -- Filtros de objeto (que não seja NOFLOAT e NOFILTER)
                    select decode(cd_objeto, trim(prm_objeto), 'B', 'C')  as indice,
                           rtrim(cd_usuario)  as cd_usuario,
                           rtrim(micro_visao) as micro_visao,
                           rtrim(cd_coluna)   as cd_coluna,
                           rtrim(condicao)    as condicao,
                           rtrim(conteudo)    as conteudo,
                           rtrim(ligacao)     as ligacao,
                           'filtros_objeto'   as tipo
                      from FILTROS
                     where micro_visao  = trim(prm_micro_visao) 
                       and CONDICAO not in ('NOFLOAT', 'NOFILTER')   -- Não pegar filtros cadastrados somente para ignorar filtros de tela
                       and st_agrupado      = 'N' 
                       and tp_filtro        = 'objeto' 
                       and cd_usuario       = 'DWU'
                       and ( (cd_objeto = trim(prm_objeto) ) or   -- Filtro de objeto 
                             (cd_objeto = trim(prm_screen)   -- Filtro de tela  
                              and nvl(fun.GETPROP(trim(prm_objeto),'FILTRO'), 'N/A') not in ('ISOLADO', 'COM CORTE')  
                              and fun.getprop(prm_objeto,'FILTRO_TELA') <> 'S'     -- atributo BLOQUEAR FILTRO DE TELA diferente de S   
                              and cd_coluna not in (select t2.cd_coluna 
                                                      from filtros t2 
                                                     where t2.condicao    = 'NOFLOAT' 
                                                       and t2.micro_visao = trim(prm_micro_visao) 
                                                       and t2.cd_objeto   = trim(prm_objeto) 
                                                       and t2.tp_filtro   = 'objeto'
                                                   ) -- Ignora o filtro se ele estiver cadastrado no objeto como NOFLOAT
                             ) 
                           ) 
                )
            where not ( trim(condicao)='IGUAL' and trim(cd_coluna) in (select trim(cd_coluna) from table(fun.vpipe_par(prm_vpar))))
            --order by tipo, cd_usuario, micro_visao, cd_coluna, condicao, conteudo;
            order by indice, cd_coluna, condicao, tipo, cd_usuario, micro_visao, conteudo;

         
         -- Filtro por visão e usuário (indiferente da tela)
		 cursor crs_filtro_user(prm_usuario varchar2) is 
            select trim(cd_coluna)   as cd_coluna,
                   decode(trim(condicao), 'IGUAL', '=', 'DIFERENTE', '<>', 'MAIOR', '>', 'MENOR', '<', 'MAIOROUIGUAL', '>=', 'MENOROUIGUAL', '<=', 'LIKE', 'like', 'NOTLIKE', 'not like')    as condicao,
                   trim(conteudo)    as conteudo,
                   ligacao     as ligacao
              from FILTROS t1
             where trim(micro_visao) = trim(prm_micro_visao) 
               and tp_filtro         = 'geral' 
               and (trim(cd_usuario) in (prm_usuario, 'DWU') or trim(cd_usuario) in (select cd_group from gusers_itens where cd_usuario = prm_usuario)) 
               and st_agrupado = 'N' 
            order by cd_coluna, condicao, conteudo;



         -- Filtros agrupados de Usuário, Objetos e Telas 
         cursor crs_filtro_a ( p_condicoes    varchar2,
                               p_micro_visao  varchar2,
                               p_cd_mapa      varchar2,
                               p_nr_item      varchar2,
                               p_cd_padrao    varchar2,
                               p_vpar         varchar2,
                               prm_usuario    varchar2 ) is
            select distinct *
            from ( select 'C'                     as indice,
                          rtrim(cd_usuario)       as cd_usuario,
                          rtrim(micro_visao)      as micro_visao,
                          rtrim(cd_coluna)        as cd_coluna,
                          rtrim(condicao)         as condicao,
                          rtrim(conteudo)         as conteudo,
                          rtrim(ligacao)          as ligacao
                     from FILTROS t1
                    where micro_visao  = trim(prm_micro_visao) 
                      and tp_filtro    = 'geral' 
                      and (cd_usuario in (prm_usuario, 'DWU') or cd_usuario in (select cd_group from gusers_itens where cd_usuario = prm_usuario) ) 
                      and st_agrupado  = 'S'
                   -- 
                   union all
                   -- 
                   select 'C'  as indice,
                          rtrim(cd_usuario)       as cd_usuario,
                          rtrim(micro_visao)      as micro_visao,
                          rtrim(cd_coluna)        as cd_coluna,
                          rtrim(condicao)         as condicao,
                          rtrim(conteudo)         as conteudo,
                          rtrim(ligacao)          as ligacao
                     from FILTROS
                    where micro_visao  = trim(prm_micro_visao) 
                      and condicao    <> 'NOFLOAT' 
                      and tp_filtro    = 'objeto' 
                      and (  (cd_objeto = trim(prm_objeto) ) or
                             (cd_objeto = trim(prm_screen) and fun.GETPROP(trim(prm_objeto),'FILTRO') <> 'ISOLADO')
                          ) 
                      and rtrim(cd_usuario)  = 'DWU'
                      and st_agrupado  = 'S'                       
                 )
            where not ( trim(condicao)='IGUAL' and trim(cd_coluna) in (select trim(cd_coluna) from table(fun.vpipe_par(p_vpar))))
            order by cd_usuario, micro_visao, cd_coluna, condicao, conteudo;


	     cursor crs_colunas ( nm_agrupador VARCHAR2 ) is
            select rtrim(cd_coluna) 	  as cd_coluna,
                   decode(rtrim(st_agrupador),'MED','MEDIAN','MOD','STATS_MODE',rtrim(st_agrupador))
                                         as st_agrupador,
                   rtrim(cd_ligacao)    as cd_ligacao,
                   rtrim(st_com_codigo)	as st_com_codigo,
                   rtrim(tipo)		      as tipo,
                   rtrim(formula)		    as formula
              from MICRO_COLUNA
             where rtrim(cd_micro_visao) = rtrim(prm_micro_visao) 
               and rtrim(cd_coluna)      = rtrim(nm_agrupador);

         cursor crs_eixo ( nm_var VARCHAR2 ) is
            select	rtrim(cd_coluna)        as dt_cd_coluna,
                    decode(rtrim(st_agrupador),'MED','MEDIAN','MOD','STATS_MODE',rtrim(st_agrupador)) as dt_st_agrupador,
                    rtrim(cd_ligacao)       as dt_cd_ligacao,
                    rtrim(st_com_codigo)    as dt_com_codigo,
                    rtrim(tipo)             as tipo,
                    rtrim(formula)          as formula
               from	MICRO_COLUNA
              where	rtrim(cd_micro_visao) = prm_micro_visao 
                and rtrim(cd_coluna)      = rtrim(nm_var);

         cursor crs_tabela is
            select nm_tabela
              from MICRO_VISAO
             where nm_micro_visao = prm_micro_visao;

         cursor crs_lcalc is
            Select Cd_Objeto,
                   Cd_Micro_Visao,
                   Cd_Coluna,
                   Cd_Coluna_Show||'[LC]' as Cd_Coluna_Show,
                   Ds_Coluna_Show,
                   Ds_Formula
              from LINHA_CALCULADA
             where cd_objeto      = prm_objeto 
               and cd_micro_visao = prm_micro_visao;

    ws_filtrog	    crs_filtrog%rowtype;
    ws_filtro_user  crs_filtro_user%rowtype;
    ws_filtro_a     crs_filtro_a%rowtype;
    
    ws_colunas     crs_colunas%rowtype;
    ws_eixo		   crs_eixo%rowtype;
    ws_lcalc       crs_lcalc%rowtype;
    ws_fpar        crs_fpar%rowtype;

    ws_filtro_geral varchar2(2000);
    ws_fg_condicao   varchar2(200);
    ws_fg_coluna     varchar2(200);
    ws_fg_condicao_r varchar2(200);
    ws_fg_coluna_r   varchar2(200);
    ws_fg_conteudo_r varchar2(200);

    type ws_tmcolunas is table of	MICRO_COLUNA%ROWTYPE
                    index by pls_integer;

    ws_tabela      crs_tabela%rowtype;


    type          generic_cursor is   ref cursor;
    crs_saida     generic_cursor;

    type               coltp_array is table of varchar2(4000) index by varchar2(4000);
    ws_col_having      coltp_array;

	ws_pvcolumns                 DBMS_SQL.VARCHAR2_TABLE;
	ws_agrupadores               DBMS_SQL.VARCHAR2_TABLE;

    ws_nm_label                  DBMS_SQL.VARCHAR2_TABLE;
    ws_nm_original               DBMS_SQL.VARCHAR2_TABLE;
    ws_tp_label                  DBMS_SQL.VARCHAR2_TABLE;
    ws_prm_query_padrao          DBMS_SQL.VARCHAR2a;


    ret_mcol                     ws_tmcolunas;

    
    ret_colup                    long;
    ret_lcross                   varchar2(4000);
    ws_versao_oracle             number;
	ws_calculadas                number := 0;
    ws_ct_label                  number := 0;
	ws_counter                   number := 1;
	ws_ctcolumn                  number := 1;
	ws_contador                  numeric(3);
	ws_nlabel                    varchar2(8000);
	ws_pipe                      char(1);
	ws_virgula                   char(1);
	ws_endgrp                    char(3);
	ws_bindn                     number;
	ws_bindns                     number;
	ws_lquery                    number := 1;
	ws_vcols                     number := 0;
	ws_ccoluna                   number;
	ws_linhas                    number;
	ws_ctlist                    number;
	ws_vcount                    number;
	ws_ctfix                     number;
	ws_pcursor                   integer;
	ws_xoperador                 varchar2(10);
	ws_cd_coluna_ant             varchar2(8000);
	ws_noloop                    varchar2(10);
    ws_unionall                  varchar2(8000);
	ws_condicao_ant              varchar2(8000);
	ws_ligacao_ant               varchar2(8000);
	ws_identificador             varchar2(8000);
	ws_conteudo_ant              varchar2(8000);
    ws_tipo_ant                  varchar2(8000);
	ws_indice_ant                varchar2(20);
	ws_initin                    varchar2(20);
	ws_tmp_condicao              varchar2(32000);
	ws_tmp_col                   varchar2(32000);
	ws_tcondicao                 varchar2(32000);
	ws_ligwhere                  varchar2(10);
	ws_par_function              varchar2(8000);
    ws_coluna_principal          varchar2(8000)       :=  null;

	ws_dc_inicio                 long;
	ws_dc_final                  long;
	ws_cursor                    long;
	ws_coluna                    long;
	ws_distintos                 long;
	ws_ordem                     long;
    ws_limited_query             varchar2(80);
	ws_grupo                     long;
	ws_grouping                  long;
	ws_agrupador                 long;
	ws_gorder                    long;
	ws_gord_r                    long;
	ws_aux                       long := 'OK';

	crlf                         VARCHAR2( 2 ):= CHR( 13 ) || CHR( 10 );

	ws_nulo                      long;
	ws_dcoluna                   long;
	ws_texto                     long;
	ws_textot                    long;
	ws_cm_var                    long;
	ws_nm_var                    long;
	ws_ct_var                    long;
	ws_condicoes                 long;
	ws_condicoes_self            long;
    ws_condicoes_prin            long;
	ws_having                    long;
	ws_desc_grp                  long;
	ws_mfiltro                   long;
	ws_conteudo_comp             long;
	ws_p_micro_visao             long   := '';
	ws_p_cd_mapa                 long   := '';
	ws_p_nr_item                 long   := '';
	ws_p_cd_padrao               long   := '';
    ws_check_columns             varchar2(32000);
    ws_opttable                  varchar2(8000);
    -- ws_sub                       varchar2(80);
    ws_self                      varchar2(1000);
    ws_filtro_sub                varchar2(32000);
    ws_coluna_formula            varchar2(8000);
    ws_coluna_dim                varchar2(80);
    ws_usuario                   varchar2(80);
    ws_ordem_user                varchar2(80);
    ws_qt_filtro                 integer; 
    ws_fun_cdesc                 varchar2(1000);     
    ws_sql_cdesc                 varchar2(2000);   
    ws_cond_aux                  varchar2(32000);
    ws_cond_par                  varchar2(32000); 
    ws_eh_subquery               varchar2(1); 
    ws_qt_loop_filtro            number;
    ws_hint_select               varchar2(4000);  
    ws_tp_objeto                 varchar2(50);
    ws_nlin_pivot                  number;

	ws_vazio                     boolean := True;
	ws_nodata                    exception;
    ws_nouser                    exception;
    ws_excesso_filtro            exception; 

    ws_zebra number;
    ws_top_n number := 0;
    ws_count_coluna number;
    ws_count_valor  number;
    ws_count        number;
    ws_first_valor varchar2(400);


begin

    ws_usuario := prm_usuario; 
    if ws_usuario is null then 
        ws_usuario := gbl.getUsuario;
    end if; 

    if nvl(ws_usuario, 'NOUSER') = 'NOUSER' then
		raise ws_nouser;
	end if;

    ws_self := replace(prm_self, 'SUBQUERY_', '');
    
    ws_eh_subquery := 'N'; 
    if nvl(prm_self,'N/A') like 'SUBQUERY_%' then 
        ws_eh_subquery := 'S'; 
    end if;     

    prm_cab_cross := '';

   
	select count(*) into ws_calculadas
	  from LINHA_CALCULADA
	 where cd_objeto      = prm_objeto 
       and cd_micro_visao = prm_micro_visao;

	if ws_eh_subquery = 'S' then
	    ws_calculadas := 0;
	end if;

	--if length(ws_self) > 0 then
	--    ws_calculadas := 0;
	--end if;

    select nvl(max(tp_objeto),'NA') into ws_tp_objeto from objetos where cd_objeto = prm_objeto;

    ws_par_function := '';
    ws_pipe := '';

    open crs_fpar (prm_micro_visao);
    loop
            fetch crs_fpar into ws_fpar;
            exit when crs_fpar%notfound;
            ws_par_function := ws_par_function||ws_pipe||ws_fpar.cd_coluna||'|'||ws_fpar.cd_parametro;
            ws_pipe         := '|';
    end loop;
    close crs_fpar;

    if  prm_rp = 'SUMARY' then
        ws_agrupadores(1) := substr(prm_condicoes||'|'||ws_self, 1 ,instr(prm_condicoes||'|'||ws_self,'|')-1);
    else
        ws_distintos      := fun.ret_list(prm_agrupador, ws_agrupadores);
    end if;

    ws_distintos := ' ';
    ws_gorder    := ' ';
    ws_gord_r    := ' ';

    ws_grouping  := '';
	ws_agrupador := prm_agrupador;
	ws_dcoluna   := prm_coluna;


    --if length(ws_self) > 0 then
    --    ws_sub := substr(ws_self, 0, instr(ws_self, '|')-1);
    --end if;

    if  prm_rp = 'CUBE' then
        ws_grupo := 'group by cube(';
	    ws_ordem := 'order by ';
    end if;

    if  prm_rp = 'ROLL' then
        ws_grupo := 'group by rollup(';
    end if;

    if  prm_rp = 'GROUP' then
        ws_grupo := 'group by (';
    end if;

    if  prm_rp = 'SUMARY' then
        ws_dcoluna := 'NO';
    end if;

    open  crs_tabela;
    fetch crs_tabela into ws_tabela;
    close crs_tabela;

    ws_opttable := fun.GETPROP (prm_objeto, 'TABELA_FISICA_OBJETO', null, 'DWU', prm_objeto);  -- Busca tabela física do objeto (se foi cadastrado)
    if nvl(ws_opttable,'NA') = 'NA' then 
        ws_opttable := ws_tabela.nm_tabela;
    end if;
    ws_opttable := nvl(fun.ret_var('OWNER_TABLE_DATA'),'DWU')||'.'||ws_opttable||' T01';  -- Coloca um Alias na tabela

    ws_distintos     := '';
    ws_pipe          := '';
    ws_texto         := ws_dcoluna;
    ws_textot        := ws_texto;
    ws_check_columns := '';


	loop
        if  ws_textot = '%END%' or ws_textot = 'NO'  then
            exit;
        end if;

        if  instr(ws_textot,'|') = 0 then
            ws_nm_var := ws_textot;
            ws_textot := '%END%';
        else
            ws_texto  := ws_textot;
            ws_nm_var := '##'||substr(ws_textot, 1 ,instr(ws_texto,'|')-1);
            --bug do clone aqui, ## pra não dar replace em colunas parecidas
            ws_textot := replace('##'||ws_texto, ws_nm_var||'|', '');
            ws_nm_var := replace(ws_nm_var, '##', '');
        end if;

        case substr(ws_nm_var,1,2)
            when '&[' then
                             ws_cm_var := replace(substr(ws_nm_var,1,instr(ws_nm_var,'][')-1),'&[','');
                             ws_nm_var := substr(ws_nm_var,instr(ws_nm_var,'][')+2,((length(ws_nm_var))-(instr(ws_nm_var,'][')+2)));
                             
                             if  substr(ws_cm_var,1,5)='EXEC=' then
                                 ws_cm_var := substr(ws_cm_var,6,length(substr(ws_cm_var,6,length(ws_cm_var))));
                             else
                                 ws_cm_var := ' '||fun.subvar(ws_cm_var)||' ';
                             end if;

              when '#[' then
                             ws_cm_var := replace(substr(ws_nm_var,1,instr(ws_nm_var,'][')-1),'#[','');
                             ws_nm_var := substr(ws_nm_var,instr(ws_nm_var,'][')+2,((length(ws_nm_var))-(instr(ws_nm_var,'][')+2)));
              else
                             ws_cm_var := 'NO_HINT';
        end case;


        if  ws_cm_var = 'NO_HINT' then
            open  crs_eixo(ws_nm_var);
            fetch crs_eixo into ws_eixo;
            close crs_eixo;
        else
            ws_eixo.dt_cd_coluna    := ws_nm_var;
            ws_eixo.dt_st_agrupador := 'SEM';
            ws_eixo.dt_cd_ligacao   := 'SEM';
            ws_eixo.dt_com_codigo   := 'N';
            ws_eixo.tipo            := 'C';
            ws_eixo.formula         := '';
        end if;

        if  ws_cm_var <> 'NO_HINT' then
            ws_eixo.formula := ws_cm_var;
        end if;

        if  trim(ws_eixo.dt_st_agrupador) = 'SEM' or trim(ws_eixo.dt_st_agrupador) = 'EXT' then
                if trim(ws_eixo.dt_st_agrupador) = 'EXT' then
                    ws_coluna_dim := REPLACE(replace(fun.gformula2(prm_micro_visao, ws_eixo.dt_cd_coluna, prm_screen, '', prm_objeto), 'SEM(', ''), ')', '');
                    ws_eixo.formula := ws_coluna_dim;
                else
                    ws_coluna_dim := ws_eixo.dt_cd_coluna;
                end if;
                prm_ncolumns(ws_ctcolumn) := ws_coluna_dim;
                ws_ctcolumn  := ws_ctcolumn + 1;
                if  ws_eixo.tipo = 'C' or ws_cm_var <> 'NO_HINT' then

                    if  ws_calculadas > 0 then
                        ws_ct_label                 := ws_ct_label + 1;
                        ws_nm_label(ws_ct_label)    := 'r_'||ws_coluna_dim||'_'||ws_ct_label;
                        ws_nm_original(ws_ct_label) := ws_coluna_dim;
                        ws_tp_label(ws_ct_label)    := '1';
                        ws_nlabel                   := '_'||ws_ct_label;
                    end if;

                    /*if  substr(prm_ordem,1,4) = 'DRE=' then
                        ws_nlabel := '';
                    end if;*/
                    ws_distintos  := ws_distintos||ws_eixo.formula||' as r_'||ws_coluna_dim||ws_nlabel||','||crlf;

                    ws_grupo      := ws_grupo||ws_eixo.formula||',';
                    ws_grouping   := ws_grouping||ws_eixo.formula||',';
                    if  nvl(trim(ws_gorder),'SEM') = 'SEM' then
                        ws_gorder := ' grouping('||ws_eixo.formula||'),';
                    else
                        --begin
                        --    ws_gord_r := ws_gord_r||' grouping('||ws_eixo.formula||'),'||nvl(prm_ordem, 1)||',';
                        --exception when others then
                            ws_gord_r := ws_gord_r||' grouping('||ws_eixo.formula||'),';
                        --end;
                    end if;
                    ws_ordem      := ws_ordem||ws_eixo.formula||',';

                    if  ws_coluna_principal is null then
                        ws_coluna_principal := ws_eixo.formula;
                    end if;


                else

                    if  ws_calculadas > 0 then
                        ws_ct_label                 := ws_ct_label + 1;
                        ws_nm_label(ws_ct_label)    := 'r_'||ws_coluna_dim||'_'||ws_ct_label;
                        ws_nm_original(ws_ct_label) := ws_coluna_dim;
                        ws_tp_label(ws_ct_label)    := '1';
                        ws_nlabel                   := '_'||ws_ct_label;
                    end if;

                    
					/*
					descrição junto com o código
                    if  trim(ws_eixo.dt_cd_ligacao)<>'SEM' then
                        ws_distintos  := ws_distintos||ws_eixo.dt_cd_coluna||'||'' - ''||fun.cdesc('||ws_eixo.dt_cd_coluna||','''||ws_eixo.dt_cd_ligacao||''') as ret_'||ws_eixo.dt_cd_coluna||ws_nlabel||','||crlf;
					else
					*/

					ws_distintos  := ws_distintos||ws_coluna_dim||' as r_'||ws_coluna_dim||ws_nlabel||','||crlf;
					
                    /*
					end if;
					ws_distintos  := ws_distintos||' - fun.cdesc('||ws_eixo.dt_cd_coluna||','''||ws_eixo.dt_cd_ligacao||''') as ret_nm_'||ws_eixo.dt_cd_coluna||ws_nlabel||'_desc,'||crlf;
                    */
					
                    ws_check_columns := ws_check_columns||ws_pipe||ws_coluna_dim;
                    ws_pipe          := '|';

                    ws_grupo      := ws_grupo||ws_coluna_dim||',';
                    ws_grouping   := ws_grouping||ws_coluna_dim||',';
                    if  nvl(trim(ws_gorder),'SEM') = 'SEM' then
                        ws_gorder := ' grouping('||ws_coluna_dim||'),';
                    else
                        --begin
                        --    ws_gord_r := ws_gord_r||' grouping('||ws_coluna_dim||'),'||nvl(prm_ordem, 1)||',';
                        --exception when others then
                            ws_gord_r := ws_gord_r||' grouping('||ws_coluna_dim||'),';
                        --end;
                    end if;
                    ws_ordem      := ws_ordem||ws_coluna_dim||',';

                    if  ws_coluna_principal is null then
                        ws_coluna_principal := ws_coluna_dim;
                    end if;

		         end if; 

            if  trim(ws_eixo.dt_cd_ligacao) <> 'SEM' then
                prm_ncolumns(ws_ctcolumn) := ws_eixo.dt_cd_coluna;
                ws_ctcolumn               := ws_ctcolumn + 1;

                if  ws_calculadas > 0 then -- nas linhas calculadas não deve ser usado a core.cdesc_sql
                    ws_ct_label                 := ws_ct_label + 1;
                    --ws_fun_cdesc                := 'fun.cdesc('||' r_'||ws_eixo.dt_cd_coluna||ws_nlabel ||','''||ws_eixo.dt_cd_ligacao||''')'; 
                    --ws_sql_cdesc                := core.cdesc_sql(ws_eixo.dt_cd_ligacao, ws_opttable, 'T01.'||ws_eixo.dt_cd_coluna, ws_fun_cdesc) ;    -- teste alternativa a FUN.CDESC 
                    --ws_nm_label(ws_ct_label)    :=  ws_fun_cdesc;                 
                    --ws_nm_label(ws_ct_label)    := ws_sql_cdesc;
                    ws_nm_label(ws_ct_label)    := 'fun.cdesc('||' r_'||ws_eixo.dt_cd_coluna||ws_nlabel ||','''||ws_eixo.dt_cd_ligacao||''')'; 
                    ws_nm_original(ws_ct_label) := ws_eixo.dt_cd_coluna;
                    ws_tp_label(ws_ct_label)    := '2';
                    ws_nlabel                   := '_'||ws_ct_label;
                end if;

                if  ws_cm_var = 'NO_HINT' then
                    ws_fun_cdesc  := 'fun.cdesc('||ws_eixo.dt_cd_coluna||','''||ws_eixo.dt_cd_ligacao||''')';
                    if ws_calculadas > 0 then -- nas linhas calculadas não deve ser usado a core.cdesc_sql
                        ws_sql_cdesc  := ws_fun_cdesc;
                    else     
                        ws_sql_cdesc  := core.cdesc_sql(ws_eixo.dt_cd_ligacao, ws_opttable, 'T01.'||ws_eixo.dt_cd_coluna, ws_fun_cdesc);   -- teste alternativa a FUN.CDESC
                    end if;     
                    ws_distintos     := ws_distintos||' '||ws_sql_cdesc||' as r_nm_'||ws_eixo.dt_cd_coluna||ws_nlabel||'_d,'||crlf;  
                else
                    ws_distintos  := ws_distintos||'('''||ws_cm_var||''') as r_nm_'||ws_eixo.dt_cd_coluna||ws_nlabel||'_d,'||crlf;
                end if;
            end if;
        end if;
    end loop;

    ws_bindn  := 1;
	ws_bindns := 1;


    ws_texto     := prm_condicoes;

    if  prm_rp = 'SUMARY' then
        ws_agrupador := substr(ws_texto, 1 ,instr(ws_texto,'|')-1);
        ws_texto := replace(ws_texto, ws_agrupador||'|', '');
    end if;

    if  length(trim(prm_self)) > 9 then      -- se tem condição self informada 
        ws_filtro_sub := ws_texto||'|'||ws_self;
    else
        ws_filtro_sub := ws_texto;
    end if;

    -------------------------------------------------------------------------------------------
    -- monta FILTROS / CONDIÇÕES DO WHERE 
    -------------------------------------------------------------------------------------------
    ws_qt_loop_filtro := 1;
    if ws_eh_subquery = 'S' then 
        ws_qt_loop_filtro := 2;
    end if; 
    --    
    for a in 1..ws_qt_loop_filtro  loop  

        if    a = 1 then     ws_cond_par := ws_texto||'|'||ws_self;   -- Todas as condições (menos de usuário)  
        elsif a = 2 then
            if prm_popup_drill = 'true' then     
                ws_cond_par := ws_texto; -- se for uma consulta destacada usar os filtros vindos da consulta mãe
            elsif length(prm_popup_drill) > 0 and prm_popup_drill <> 'false' then     
                ws_cond_par := prm_popup_drill; -- se tiver os parametros do anterior usar para puxar as colunas corretas na drill
            else    
                ws_cond_par := '' ;                      -- Condições principais do objeto sem parâmentros 
            end if;
        elsif a = 3 then     ws_cond_par := ws_filtro_sub;            -- Condições da subquery (não utilizada)
        end if; 

        ws_cd_coluna_ant  := 'NOCHANGE_ID';
        ws_ligacao_ant    := 'NOCHANGE_ID';
        ws_condicao_ant   := 'NOCHANGE_ID';
        ws_tipo_ant       := 'NOCHANGE_ID';
        ws_indice_ant     := 'NOCHANGE_ID';
        ws_initin         := 'NOINIT';
        ws_tmp_condicao   := '';
        ws_bindn          := 1;
        ws_noloop         := 'NOLOOP';
        ws_cond_aux       := 'where ( ( ';

        ws_qt_filtro := 0;
        /* 
        open crs_filtrog( ws_cond_par,
                          ws_p_micro_visao,
                          ws_p_cd_mapa,
                          ws_p_nr_item,
                          ws_p_cd_padrao,
                          ws_par_function, 
                          ws_usuario ); */ 
        open crs_filtrog( ws_cond_par,
                          prm_micro_visao,
                          prm_screen,
                          prm_objeto,
                          ws_usuario,
                          ws_par_function,
                          ws_p_cd_mapa,
                          ws_p_nr_item,
                          ws_p_cd_padrao); 
        loop
            fetch crs_filtrog into ws_filtrog;
            exit when crs_filtrog%notfound ;

            -- Retorna substituição do | do texto do parametro, caso exista e tenha sido substituido por #[PIPE]
            if ws_filtrog.conteudo like '%@PIPE@%' then 
                ws_filtrog.conteudo := replace(ws_filtrog.conteudo,'@PIPE@','|');
            end if; 

            ws_qt_filtro := ws_qt_filtro + 1 ;
            if  fun.vcalc(ws_filtrog.cd_coluna, prm_micro_visao) then
                ws_filtrog.cd_coluna := fun.xcalc(ws_filtrog.cd_coluna, ws_filtrog.micro_visao, prm_screen);
            end if;

            ws_noloop := 'LOOP';

            if  prm_objeto = '%NO_BIND%' then
                ws_conteudo_comp := chr(39)||ws_conteudo_ant||chr(39);
            else
                ws_conteudo_comp := ' :b'||trim(to_char(ws_bindn,'0000'));
            end if;

            if  ws_condicao_ant <> 'NOCHANGE_ID' then
                --if  (ws_filtrog.cd_coluna=ws_cd_coluna_ant and ws_filtrog.condicao=ws_condicao_ant) and ws_condicao_ant in ('IGUAL','DIFERENTE') then      card 833s 
                if  ws_filtrog.cd_coluna=ws_cd_coluna_ant and ws_filtrog.condicao=ws_condicao_ant and ws_filtrog.indice=ws_indice_ant and ws_condicao_ant in ('IGUAL','DIFERENTE') then -- card 833s
                    if  ws_initin <> 'BEGIN' then
                        ws_cond_aux     := ws_cond_aux||ws_tmp_condicao;
                        ws_tmp_condicao := '';
                    end if;
                    ws_initin := 'BEGIN';
                    ws_tmp_condicao := ws_tmp_condicao||ws_conteudo_comp||',';
                    ws_bindn := ws_bindn + 1;
                else
                    if  ws_initin = 'BEGIN' then
                        ws_tmp_condicao := ws_tmp_condicao||ws_conteudo_comp||',';
                        ws_tmp_condicao := substr(ws_tmp_condicao,1,length(ws_tmp_condicao)-1);
                        ws_cond_aux     := ws_cond_aux||ws_cd_coluna_ant||fcl.fpdata(ws_condicao_ant,'IGUAL',' IN ',' NOT IN ')||'('||ws_tmp_condicao||') '||ws_ligacao_ant||crlf;
                        ws_tmp_condicao := '';
                        ws_initin := 'NOINIT';
                    else
                        ws_cond_aux     := ws_cond_aux||ws_tmp_condicao;
                        ws_tmp_condicao := '';
                        --if  ws_filtrog.tipo <> ws_tipo_ant then  card 833s 
                        if  ws_filtrog.indice <> ws_indice_ant then  -- card 833s 
                            ws_tmp_condicao := ws_tmp_condicao||ws_cd_coluna_ant||ws_tcondicao||ws_conteudo_comp||' ) and ( '||crlf;                          
                        else
                            ws_tmp_condicao := ws_tmp_condicao||ws_cd_coluna_ant||ws_tcondicao||ws_conteudo_comp||' '||ws_ligacao_ant||' '||crlf;
                        end if;
                    end if;
                    ws_bindn      := ws_bindn + 1;
                end if;
            end if;

            if length(ws_check_columns||ws_pipe||ws_filtrog.cd_coluna) > 32000 then 
                raise ws_excesso_filtro ;  
            else  
                ws_check_columns := ws_check_columns||ws_pipe||ws_filtrog.cd_coluna;
            end if;     
            ws_cd_coluna_ant := ws_filtrog.cd_coluna;
            ws_condicao_ant  := ws_filtrog.condicao;
            ws_indice_ant    := ws_filtrog.indice;
            ws_ligacao_ant   := ws_filtrog.ligacao;
            ws_conteudo_ant  := ws_filtrog.conteudo;
            ws_tipo_ant      := ws_filtrog.tipo;

            case ws_condicao_ant
                                when 'IGUAL'        then ws_tcondicao := '=';
                                when 'DIFERENTE'    then ws_tcondicao := '<>';
                                when 'MAIOR'        then ws_tcondicao := '>';
                                when 'MENOR'        then ws_tcondicao := '<';
                                when 'MAIOROUIGUAL' then ws_tcondicao := '>=';
                                when 'MENOROUIGUAL' then ws_tcondicao := '<=';
                                when 'LIKE'         then ws_tcondicao := ' like ';
                                when 'NOTLIKE'      then ws_tcondicao := ' not like ';
                                else                     ws_tcondicao := '***';
            end case;
        end loop;
        close crs_filtrog;

        if  prm_objeto = '%NO_BIND%' then
            ws_conteudo_comp := chr(39)||ws_conteudo_ant||chr(39);
        else
            ws_conteudo_comp := ' :b'||trim(to_char(ws_bindn,'0000'));
        end if;

        if  ws_noloop <> 'NOLOOP' then
            if  ws_initin = 'BEGIN' then
                ws_tmp_condicao := ws_tmp_condicao||ws_conteudo_comp||',';
                ws_tmp_condicao := substr(ws_tmp_condicao,1,length(ws_tmp_condicao)-1);
                ws_cond_aux     := ws_cond_aux||ws_cd_coluna_ant||fcl.fpdata(ws_condicao_ant,'IGUAL',' IN ',' NOT IN ')||'('||ws_tmp_condicao||')'||crlf;
                ws_bindn := ws_bindn + 1;
            else
                ws_tmp_condicao := ws_tmp_condicao||ws_cd_coluna_ant||ws_tcondicao||ws_conteudo_comp||crlf;   
                ws_cond_aux     := ws_cond_aux||ws_tmp_condicao;
                ws_bindn := ws_bindn + 1;
            end if;
        end if;

        if  substr(ws_cond_aux,length(ws_cond_aux)-3, 3) ='( (' then
            ws_cond_aux := substr(ws_cond_aux,1,length(ws_cond_aux)-10)||' '; --removido crlf pois atrapalhava verificação do ws_condicoes_prin mais abaixo
        else
            ws_cond_aux := ws_cond_aux||' ) ) ';
        end if;
        -- 
        if    a = 1 then       ws_condicoes      := ws_cond_aux;   -- Todas as condições (menos de usuário)  
        elsif a = 2 then       ws_condicoes_prin := ws_cond_aux;   -- Condições principais do objeto sem parâmentros de subquery 
        elsif a = 3 then       ws_condicoes_self := ws_cond_aux;   -- Condições da subquery (não utilizada)
        end if; 

    end loop; 
    ---------------------------------------------------------
    -- FIM - monta filtros 


    for a in 1..ws_qt_loop_filtro  loop  

        if    a = 1 then     ws_cond_par := ws_texto||'|'||ws_self;   -- Todas as condições (menos de usuário)  
        elsif a = 2 then
            if prm_popup_drill = 'true' then     
                ws_cond_par := ws_texto; -- se for uma consulta destacada usar os filtros vindos da consulta mãe
            elsif length(prm_popup_drill) > 0 and prm_popup_drill <> 'false' then     
                ws_cond_par := prm_popup_drill; -- se tiver os parametros do anterior usar para puxar as colunas corretas na drill
            else    
                ws_cond_par := '' ;                      -- Condições principais do objeto sem parâmentros 
            end if;
        elsif a = 3 then     ws_cond_par := ws_filtro_sub;            -- Condições da subquery (não utilizada)
        end if; 
        -- 
        MONTA_FILTRO2 ('SQL', prm_objeto, prm_screen, prm_micro_visao, ws_cond_par, ws_usuario, ws_cond_aux); 

        --if    a = 1 then       ws_condicoes      := ws_cond_aux;   -- Todas as condições (menos de usuário)  
        --elsif a = 2 then       ws_condicoes_prin := ws_cond_aux;   -- Condições principais do objeto sem parâmentros de subquery 
        --elsif a = 3 then       ws_condicoes_self := ws_cond_aux;   -- Condições da subquery (não utilizada)
        --end if; 

    end loop; 





    ws_par_function := '';
    ws_pipe         := '';
    open crs_fpar (prm_micro_visao);
    loop
        fetch crs_fpar into ws_fpar;
        exit when crs_fpar%notfound;
        ws_par_function := ws_par_function||ws_pipe||ws_fpar.cd_parametro||'=> :b'||trim(to_char(ws_bindn,'0000'));
        ws_bindn        := ws_bindn + 1;
        ws_pipe         := ',';
    end loop;
    close crs_fpar;


    ws_grouping := substr(ws_grouping,1,length(ws_grouping)-1);
	    
    -- Monta filtro de GERAL e de USUÁRIO  
    ----------------------------------------------------------------------------------
    ws_fg_condicao := 'N/A';
    ws_fg_coluna   := 'N/A';
    open crs_filtro_user(ws_usuario);
    loop
            fetch crs_filtro_user into ws_filtro_user;
            exit when crs_filtro_user%notfound;

            ws_coluna_formula := trim(fun.gformula2(prm_micro_visao, ws_filtro_user.cd_coluna, prm_screen, '', ''));
            
            if (ws_fg_condicao_r = ws_filtro_user.condicao) and (ws_fg_coluna_r = ws_coluna_formula) and (ws_fg_conteudo_r = ws_filtro_user.conteudo) then
                ws_filtro_geral := '';
            else
            
                if (ws_fg_condicao <> ws_filtro_user.condicao) or (ws_fg_coluna <> ws_coluna_formula) then
                    
                    
                    if ws_fg_condicao = '=' then
                        ws_filtro_geral := ws_filtro_geral||') '||ws_filtro_user.ligacao;
                    end if;
                    
                    ws_fg_condicao  := trim(ws_filtro_user.condicao);
                    ws_fg_coluna    := ws_coluna_formula;


                    if ws_fg_condicao = '=' then
                        ws_filtro_geral := ws_filtro_geral||' '||ws_coluna_formula||' in (';
                    end if;
                    
                end if;
                
                if ws_filtro_user.condicao = '=' then
                    ws_filtro_geral := ws_filtro_geral||''''||ws_filtro_user.conteudo||''',';
                else 
                    ws_filtro_geral := ws_filtro_geral||' '||ws_coluna_formula||' '||ws_filtro_user.condicao||' '''||ws_filtro_user.conteudo||''' '||ws_filtro_user.ligacao;
                end if;

            end if;
            
            ws_fg_condicao_r := ws_filtro_user.condicao;
            ws_fg_coluna_r   := ws_coluna_formula;
            ws_filtro_geral  := replace(ws_filtro_geral, ',)', ')');
				
	end loop;
	close CRS_FILTRO_user;
		
    if ws_fg_condicao = '=' then
        ws_filtro_geral := ws_filtro_geral||')';
    end if;

    if ws_fg_condicao <> '=' then
        ws_filtro_geral := substr(ws_filtro_geral, 0, length(ws_filtro_geral)-4);
    else
        ws_filtro_geral := replace(ws_filtro_geral, ',)', ')');
    end if;
    ----------------------------------------------------------------------------------
    -- FIM - Monta filtro GERAL e de USUÁRIO  

	-- Quando NÃO tem PIVOT 
    if  nvl(prm_colup,'%*') = '%*' then
			ws_vcount := 0;
			loop
				ws_vcount := ws_vcount + 1;
				if  ws_vcount > ws_agrupadores.COUNT then
					exit;
				end if;

			    if  ws_agrupadores(ws_vcount) <> 'PERC_FUNCTION' then
				   open crs_colunas(ws_agrupadores(ws_vcount));
				   fetch crs_colunas into ws_colunas;
				   close crs_colunas;

				   ws_lquery := ws_lquery + 1;
				   ws_tmp_col := ws_colunas.cd_coluna;
				   if  ws_colunas.tipo='C' then
					   ws_tmp_col := fun.gformula2(prm_micro_visao, ws_colunas.cd_coluna, prm_screen, '', prm_objeto);
				   end if;

				   if  ws_calculadas > 0 then
					   ws_ct_label                 := ws_ct_label + 1;
                       ws_nlabel                   := 'r_'||ws_colunas.cd_coluna||'_'||ws_ct_label;
					   ws_nm_label(ws_ct_label)    := ws_nlabel; 
					   ws_nm_original(ws_ct_label) := ws_colunas.cd_coluna;
					   ws_tp_label(ws_ct_label)    := '3';
                   else 
                       ws_nlabel                   := 'r_'||ws_colunas.cd_coluna; 
				   end if;

				   if  rtrim(ws_colunas.st_agrupador) in ('PSM','PCT','CNT') then
					   if  rtrim(ws_colunas.st_agrupador)='PSM' then
						   ws_col_having(ws_colunas.cd_coluna)     := '(RATIO_TO_REPORT(SUM  ('||ws_tmp_col||')) OVER (PARTITION BY grouping_id('||ws_grouping||'))*100) ';
						   prm_query_padrao(ws_lquery)             := '(RATIO_TO_REPORT(SUM  ('||ws_tmp_col||')) OVER (PARTITION BY grouping_id('||ws_grouping||'))*100) as '||ws_nlabel||','||crlf;
					   else
						   if  rtrim(ws_colunas.st_agrupador)='CNT' then
							   ws_col_having(ws_colunas.cd_coluna) :=  'COUNT(DISTINCT '||ws_tmp_col||') ';
							   prm_query_padrao(ws_lquery)         := 'COUNT(DISTINCT '||ws_tmp_col||') as '||ws_nlabel||','||crlf;
						   else
							   ws_col_having(ws_colunas.cd_coluna) := '(RATIO_TO_REPORT(COUNT(DISTINCT '||ws_tmp_col||')) OVER (PARTITION BY grouping_id('||ws_grouping||'))*100) ';
							   prm_query_padrao(ws_lquery)         := '(RATIO_TO_REPORT(COUNT(DISTINCT '||ws_tmp_col||')) OVER (PARTITION BY grouping_id('||ws_grouping||'))*100) as '||ws_nlabel||','||crlf;
						   end if;
					   end if;
				   elsif trim(ws_colunas.st_agrupador) = 'IMG' THEN
					   ws_col_having(ws_colunas.cd_coluna)     := 'MAX('||ws_tmp_coL||') ';
					   prm_query_padrao(ws_lquery)             := 'MAX('||ws_tmp_col||') as '||ws_nlabel||','||crlf;
				   else
					   ws_col_having(ws_colunas.cd_coluna)     := fcl.fpdata(rtrim(ws_colunas.st_agrupador),'EXT','',rtrim(ws_colunas.st_agrupador))||'('||ws_tmp_col||') ';
					   prm_query_padrao(ws_lquery)             := fcl.fpdata(rtrim(ws_colunas.st_agrupador),'EXT','',rtrim(ws_colunas.st_agrupador))||'('||ws_tmp_col||') as '||ws_nlabel||','||crlf;
				   end if;

				   prm_ncolumns(ws_ctcolumn) := ws_colunas.cd_coluna;
				   ws_ctcolumn := ws_ctcolumn + 1;
			   end if;
			end loop;

			if  prm_rp = 'PIZZA' then
				ws_lquery   := ws_lquery + 1;
				prm_query_padrao(ws_lquery) := 'trunc((RATIO_TO_REPORT(SUM('||ws_tmp_col||')) OVER (partition by grouping_id('||prm_coluna||')))*100) as perc ';
				prm_ncolumns(ws_ctcolumn) := 'PERC';
				ws_ctcolumn := ws_ctcolumn + 1;
			end if;

		   if  nvl(trim(ws_grupo),'%NO_UNDER_GRP%') <> '%NO_UNDER_GRP%' then

				ws_lquery   := ws_lquery + 1;
				prm_query_padrao(ws_lquery) := 'grouping_id('||replace(replace(replace(substr(ws_grupo,1,length(ws_grupo)-1),'group by cube(',''),'group by rollup(',''),'group by (','')||')'||' as UP_GRP_ID';
				prm_ncolumns(ws_ctcolumn)   := 'UP_GRP_MODEL';
				ws_ctcolumn := ws_ctcolumn + 1;
				if trim(ws_coluna_principal) is not null then
					prm_query_padrao(ws_lquery) := prm_query_padrao(ws_lquery)||', grouping_id('||ws_coluna_principal||') as UP_PRINCIPAL';
					prm_ncolumns(ws_ctcolumn)   := 'UP_PRINCIPAL';
					ws_ctcolumn := ws_ctcolumn + 1;
				end if;
		   end if;

	else  -- TEM pivot 

        -- Monta o select das colunas do pivot 
        ws_bindn  := 0;
        ws_texto  := prm_colup;
        ws_textot := ' ';

        loop
            ws_bindn  := ws_bindn + 1;
            if  instr(ws_texto,'|') > 0 then
                ws_nm_var            := substr(ws_texto, 1 ,instr(ws_texto,'|')-1);
                if  fun.VCALC(ws_nm_var,prm_micro_visao) then
                    ws_nm_var :=  fun.xcalc(ws_nm_var,	prm_micro_visao, prm_screen );
                end if;
                prm_pvpull(ws_bindn) := ws_nm_var;
                commit;
                ws_texto             := replace (ws_texto, ws_nm_var||'|', '');
                ws_textot            := ws_textot||ws_nm_var||',';
            else

                if  fun.VCALC(ws_texto,prm_micro_visao) then
                    ws_texto :=  fun.xcalc(ws_texto,	prm_micro_visao, prm_screen );
                end if;
                prm_pvpull(ws_bindn) := ws_texto;
                commit;
                ws_textot            := ws_textot||ws_texto||',';
                exit;
            end if;
        end loop;

		ws_textot := substr(ws_textot,1,length(ws_textot)-1);

		if  ws_par_function <> '' then
		    ws_cursor := 'select distinct '||ws_textot||' from table('||ws_opttable||'('||ws_par_function||')) '||ws_condicoes;
		else
            if  ws_eh_subquery = 'S' then 
                if length(ws_filtro_geral) > 2 and  length(trim(ws_condicoes_prin)) > 1  then
                    ws_cursor := 'select distinct '||ws_textot||' frOm '||ws_opttable||' '||ws_condicoes_prin||' and ('||ws_filtro_geral||')';
                elsif length(trim(ws_condicoes_prin)) > 1 then
                    ws_cursor := 'select distinct '||ws_textot||' frOm '||ws_opttable||' '||ws_condicoes_prin;
                elsif length(ws_filtro_geral) > 2 then
                    ws_cursor := 'select distinct '||ws_textot||' frOm '||ws_opttable||' where ('||ws_filtro_geral||')';
                else
                    ws_cursor := 'select distinct '||ws_textot||' frOm '||ws_opttable;
                end if;
            else
                if length(ws_filtro_geral) > 2 then -- ws_filtro_geral = Filtros de usuário
                    if length(trim(ws_condicoes)) > 2 then
                        ws_cursor := 'select distinct '||ws_textot||' From '||ws_opttable||' '||ws_condicoes||' and ('||ws_filtro_geral||')';
                    else
                        ws_cursor := 'select distinct '||ws_textot||' fRom '||ws_opttable||' where ('||ws_filtro_geral||')';
                    end if;
                else
                    ws_cursor := 'select distinct '||ws_textot||' froM '||ws_opttable||' '||ws_condicoes;
                end if;
            end if;
		end if;
        -- Coloca o order by conforme o número de colunas do select do pivot 
        for a in 1..ws_bindn loop 
            if a = 1 then      ws_cursor := ws_cursor||' order by 1';
            else               ws_cursor := ws_cursor||','||a;
            end if;     
        end loop; 

        ws_pcursor := dbms_sql.open_cursor;
        prm_query_pivot := ws_cursor;
        
        dbms_sql.parse(ws_pcursor, ws_cursor, dbms_sql.native);

        ws_bindn := 0;
        loop
            ws_bindn := ws_bindn + 1;
            if  ws_bindn > prm_pvpull.COUNT then
                exit;
            end if;
            dbms_sql.define_column(ws_pcursor, ws_bindn, ret_colup, 40);
            commit;
        end loop;

        begin 
            if  length(trim(ws_condicoes_prin)) > 1 and prm_popup_drill <> 'false' and ws_eh_subquery = 'S' then
                ws_nulo := core.bind_direct(ws_cond_par, ws_pcursor, '', prm_objeto, prm_micro_visao, prm_screen,prm_usuario => ws_usuario);
            elsif  ws_eh_subquery = 'S' then 
                ws_nulo := core.bind_direct('', ws_pcursor, '', prm_objeto, prm_micro_visao, prm_screen,prm_usuario => ws_usuario);
            else 
                ws_nulo := core.bind_direct(prm_condicoes||'|'||ws_self, ws_pcursor, '', prm_objeto, prm_micro_visao, prm_screen,prm_usuario => ws_usuario);
            end if;
        exception when others then
            insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - MONTA_QUERY', ws_usuario, 'ERRO');
            commit;
        end;

        ws_linhas := dbms_sql.execute(ws_pcursor);

        ws_counter := 0;
        ws_ccoluna := 0;
        ws_ctlist  := 0;
        ws_nlin_pivot := 0;

        -- Percorre o select das colunas de PIVOT para montar as colunas do select principal 
        loop
            ws_linhas := dbms_sql.fetch_rows(ws_pcursor);
            if  ws_linhas = 1 then
                ws_vazio := False;
            else
                if  ws_vazio = True then
                    dbms_sql.close_cursor(ws_pcursor);
                    raise ws_nodata;
                end if;
                exit;
            end if;
            
            ws_nlin_pivot := ws_nlin_pivot + 1;
            ws_mfiltro   := '';
            ws_bindn     := 0;
            ws_dc_inicio := ' ';
            ws_dc_final  := ' ';
            ws_desc_grp  := '';
            ws_pipe	     := '';
            
            -- prm_pvpull = Colunas do Pivot 
            loop
                ws_bindn := ws_bindn + 1;
                if  ws_bindn > prm_pvpull.COUNT then
                    exit;
                end if;

                ws_mfiltro   := ws_mfiltro||ws_pipe;
                dbms_sql.column_value(ws_pcursor, ws_bindn, ret_colup);
                ws_dc_inicio := ws_dc_inicio||'decode('||prm_pvpull(ws_bindn)||','''||ret_colup||''',';
                ws_dc_final  := ws_dc_final||',null)';
                ws_desc_grp  := ws_desc_grp||'_'||ret_colup;
                ws_ctlist    := ws_ctlist + 1;
                ws_mfiltro   := trim(ws_mfiltro||prm_pvpull(ws_bindn)||'|'||ret_colup);
                ws_pipe      := '|';

            end loop;
            
            ws_vcount := 0;
            loop
                ws_vcount := ws_vcount + 1;
                if  ws_vcount > ws_agrupadores.COUNT then
                    exit;
                end if;

                if  ws_agrupadores(ws_vcount) <> 'PERC_FUNCTION'  then

                    open crs_colunas(ws_agrupadores(ws_vcount));
                    fetch crs_colunas into ws_colunas;
                    close crs_colunas;

                    ws_lquery := ws_lquery + 1;
                    ws_tmp_col := ws_colunas.cd_coluna;
                    if  ws_colunas.tipo='C' then
                        if  rtrim(ws_colunas.st_agrupador) <> 'EXT' then
                            ws_tmp_col := ws_dc_inicio||fun.gformula2(prm_micro_visao, ws_colunas.cd_coluna, prm_screen, '', prm_objeto)||ws_dc_final;
                        else

                            ws_tmp_col := fun.gformula2(prm_micro_visao, ws_colunas.cd_coluna, prm_screen, '', prm_objeto, ws_dc_inicio, ws_dc_final);
                        end if;
                    else
                        ws_tmp_col := ws_dc_inicio||ws_tmp_col||ws_dc_final;
                    end if;
                    
                end if;

                ws_nlabel := 'r_'||ws_colunas.cd_coluna||ws_nlabel||ws_lquery; 
                --
                if  ws_calculadas > 0 then
                    ws_ct_label                 := ws_ct_label + 1;
                    --ws_nlabel := 'r_'||ws_colunas.cd_coluna||'_'||ws_ct_label||ws_lquery; 
                    ws_nlabel := 'r_'||ws_colunas.cd_coluna||'_'||ws_ct_label||ws_nlin_pivot; 
                    ws_nm_label(ws_ct_label)    := ws_nlabel;
                    ws_nm_original(ws_ct_label) := ws_colunas.cd_coluna;
                    ws_tp_label(ws_ct_label)    := '3';
                else 
                    --ws_nlabel := 'r_'||ws_colunas.cd_coluna||ws_lquery; 
                    ws_nlabel := 'r_'||ws_colunas.cd_coluna||ws_nlin_pivot; 
                end if;

                if  rtrim(ws_colunas.st_agrupador) in ('PSM','PCT','CNT') then
                    if  rtrim(ws_colunas.st_agrupador)='PSM' then
                        prm_query_padrao(ws_lquery)     := 'trunc((RATIO_TO_REPORT(SUM('||ws_tmp_col||')) OVER ()*100)) as '||ws_nlabel||','||crlf;
                    else
                        if  rtrim(ws_colunas.st_agrupador)='CNT' then
                            prm_query_padrao(ws_lquery) := 'COUNT(DISTINCT '||ws_tmp_col||') as '||ws_nlabel||','||crlf;
                        else
                            prm_query_padrao(ws_lquery) := 'trunc((RATIO_TO_REPORT(COUNT(DISTINCT '||ws_tmp_col||')) OVER ()*100)) as '||ws_nlabel||','||crlf;
                        end if;
                    end if;
                else
                    prm_query_padrao(ws_lquery)         := fcl.fpdata(rtrim(ws_colunas.st_agrupador),'EXT','',trim(ws_colunas.st_agrupador))||'('||ws_tmp_col||') aS '||ws_nlabel||','||crlf;
                end if;
                /*
                if  ws_calculadas > 0 then
                    ws_ct_label                 := ws_ct_label + 1;
                    ws_nm_label(ws_ct_label)    := 'r_'||ws_colunas.cd_coluna||'_'||ws_ct_label||ws_lquery;
                    ws_nm_original(ws_ct_label) := ws_colunas.cd_coluna;
                    ws_tp_label(ws_ct_label)    := '3';
                    ws_nlabel                   := '_'||ws_ct_label;
                end if;
                ***/ 


                /***** 
                if  rtrim(ws_colunas.st_agrupador) in ('PSM','PCT','CNT') then
                    if  rtrim(ws_colunas.st_agrupador)='PSM' then
                        prm_query_padrao(ws_lquery)     := 'trunc((RATIO_TO_REPORT(SUM('||ws_tmp_col||')) OVER ()*100)) as r_'||ws_colunas.cd_coluna||ws_nlabel||ws_lquery||','||crlf;
                    else
                        if  rtrim(ws_colunas.st_agrupador)='CNT' then
                            prm_query_padrao(ws_lquery) := 'COUNT(DISTINCT '||ws_tmp_col||') as r_'||ws_colunas.cd_coluna||ws_nlabel||ws_lquery||','||crlf;
                        else
                            prm_query_padrao(ws_lquery) := 'trunc((RATIO_TO_REPORT(COUNT(DISTINCT '||ws_tmp_col||')) OVER ()*100)) as r_'||ws_colunas.cd_coluna||ws_nlabel||ws_lquery||','||crlf;
                        end if;
                    end if;
                else
                    prm_query_padrao(ws_lquery)         := fcl.fpdata(rtrim(ws_colunas.st_agrupador),'EXT','',trim(ws_colunas.st_agrupador))||'('||ws_tmp_col||') aS r_'||ws_colunas.cd_coluna||ws_nlabel||ws_lquery||','||crlf;
                end if;
                */ 
              prm_ncolumns(ws_ctcolumn) := ws_colunas.cd_coluna;
              ws_ctcolumn               := ws_ctcolumn + 1;
              prm_mfiltro(ws_ctcolumn)  := ws_mfiltro;
              ws_vcols                  := ws_vcols    + 1;

		    end loop;
        end loop;

        --linha que afeta o total up da consulta customizada
        if  prm_pvpull.COUNT > 0 and fun.getprop(prm_objeto,'NO_TUP') <> 'S' then
            ws_vcount := 0;
            loop
                ws_vcount := ws_vcount + 1;
                if  ws_vcount > ws_agrupadores.COUNT then
                    exit;
                end if;
                if  ws_agrupadores(ws_vcount) <> 'PERC_FUNCTION'  then
                    open crs_colunas(ws_agrupadores(ws_vcount));
                    fetch crs_colunas into ws_colunas;
                    close crs_colunas;

                    ws_lquery := ws_lquery + 1;
                    ws_tmp_col := ws_colunas.cd_coluna;
                    if  ws_colunas.tipo='C' then
                        ws_tmp_col := fun.gformula2(prm_micro_visao, ws_colunas.cd_coluna, prm_screen, '', prm_objeto);
                    else
                        ws_tmp_col := '('||ws_tmp_col||')';
                    end if;
                end if;

                if  ws_calculadas > 0 then
                    ws_ct_label                 := ws_ct_label + 1;
                    ws_nlabel                   := 'r_'||ws_colunas.cd_coluna||'_'||ws_ct_label||'T';
                    ws_nm_label(ws_ct_label)    := ws_nlabel; 
                    ws_nm_original(ws_ct_label) := ws_colunas.cd_coluna;
                    ws_tp_label(ws_ct_label)    := '3';
                else 
                    ws_nlabel                   := 'r_'||ws_colunas.cd_coluna||'T'; 
                end if;


                if  rtrim(ws_colunas.st_agrupador) in ('PSM','PCT','CNT') then
                    if  rtrim(ws_colunas.st_agrupador)='PSM' then
                        prm_query_padrao(ws_lquery)     := 'trunc((RATIO_TO_REPORT(SUM('||ws_tmp_col||')) OVER ()*100)) as '||ws_nlabel||','||crlf;
                    else
                        if  rtrim(ws_colunas.st_agrupador)='CNT' then
                            prm_query_padrao(ws_lquery) := 'COUNT(DISTINCT '||ws_tmp_col||') as '||ws_nlabel||','||crlf;
                        else
                            prm_query_padrao(ws_lquery) := 'trunc((RATIO_TO_REPORT(COUNT(DISTINCT '||ws_tmp_col||')) OVER ()*100)) as '||ws_nlabel||','||crlf;
                        end if;
                    end if;
                else
                    prm_query_padrao(ws_lquery) := fcl.fpdata(rtrim(ws_colunas.st_agrupador),'EXT','',rtrim(ws_colunas.st_agrupador))||'('||ws_tmp_col||') As '||ws_nlabel||','||crlf;
                end if;

                prm_ncolumns(ws_ctcolumn) := ws_colunas.cd_coluna;
                prm_mfiltro(ws_ctcolumn)  := ws_mfiltro;
                ws_ctcolumn := ws_ctcolumn + 1;
                ws_vcols    := ws_vcols    + 1;

            end loop;

        end if;

	    if  nvl(trim(ws_grupo),'%NO_UNDER_GRP%') <> '%NO_UNDER_GRP%' then
            ws_lquery   := ws_lquery + 1;
            prm_query_padrao(ws_lquery) := 'grouping_id('||replace(replace(replace(substr(ws_grupo,1,length(ws_grupo)-1),'group by cube(',''),'group by rollup(',''),'group by (','')||')'||' as UP_GRP_ID';
			prm_ncolumns(ws_ctcolumn)   := 'UP_GRP_MODEL';
            ws_ctcolumn := ws_ctcolumn + 1;


            if  trim(ws_coluna_principal) is not null then
                prm_query_padrao(ws_lquery) := prm_query_padrao(ws_lquery)||', grouping_id('||ws_coluna_principal||') as UP_PRINCIPAL';
                prm_ncolumns(ws_ctcolumn)   := 'UP_PRINCIPAL';
                ws_ctcolumn := ws_ctcolumn + 1;
            end if;

        end if;

        dbms_sql.close_cursor(ws_pcursor);
    end if;

    -- Monta filtro A 
    ---------------------------------------------------------------------
    ws_cd_coluna_ant  := 'NOCHANGE_ID';
    ws_ligacao_ant    := 'NOCHANGE_ID';
    ws_condicao_ant   := 'NOCHANGE_ID';
    ws_indice_ant     := 0;
    ws_initin         := 'NOINIT';
    ws_tmp_condicao   := '';
    ws_noloop         := 'NOLOOP';
    ws_having         := 'having ( ( ';

    open crs_filtro_a( ws_texto,
                       ws_p_micro_visao,
                       ws_p_cd_mapa,
                       ws_p_nr_item,
                       ws_p_cd_padrao,
                       ws_par_function,
                       ws_usuario );
    loop
        fetch crs_filtro_a into ws_filtro_a;
              exit when crs_filtro_a%notfound;

              ws_filtro_a.cd_coluna := ws_col_having(ws_filtro_a.cd_coluna);
              ws_noloop := 'LOOP';
              if  prm_objeto = '%NO_BIND%' then
                  ws_conteudo_comp := chr(39)||ws_conteudo_ant||chr(39);
              else
                  ws_conteudo_comp := ' :b'||trim(to_char(ws_bindn,'0000'));
              end if;

              if  ws_condicao_ant <> 'NOCHANGE_ID' then
                  if  (ws_filtro_a.cd_coluna=ws_cd_coluna_ant and ws_filtro_a.condicao=ws_condicao_ant) and ws_condicao_ant in ('IGUAL','DIFERENTE') then
                      if  ws_initin <> 'BEGIN' then
                          ws_having := ws_having||ws_tmp_condicao;
                          ws_tmp_condicao := '';
                      end if;
                      ws_initin := 'BEGIN';
                      ws_tmp_condicao := ws_tmp_condicao||ws_conteudo_comp||',';
                      ws_bindn := ws_bindn + 1;
                  else
                      if  ws_initin = 'BEGIN' then
                          ws_tmp_condicao := ws_tmp_condicao||ws_conteudo_comp||',';
                          ws_tmp_condicao := substr(ws_tmp_condicao,1,length(ws_tmp_condicao)-1);
                          ws_having := ws_having||ws_cd_coluna_ant||fcl.fpdata(ws_condicao_ant,'IGUAL',' IN ',' NOT IN ')||'('||ws_tmp_condicao||') '||ws_ligacao_ant||crlf;
                          ws_tmp_condicao := '';
                          ws_initin := 'NOINIT';
                      else
                          ws_having := ws_having||ws_tmp_condicao;
                          ws_tmp_condicao := '';
                          if  ws_filtro_a.ligacao <> ws_ligacao_ant then
                              ws_tmp_condicao := ws_tmp_condicao||ws_cd_coluna_ant||ws_tcondicao||ws_conteudo_comp||' ) '||ws_ligacao_ant||' ( '||crlf;
                          else
                              ws_tmp_condicao := ws_tmp_condicao||ws_cd_coluna_ant||ws_tcondicao||ws_conteudo_comp||' '||ws_ligacao_ant||' '||crlf;
                          end if;
                      end if;
                      ws_bindn := ws_bindn + 1;
                  end if;
              end if;

              ws_cd_coluna_ant := ws_filtro_a.cd_coluna;
              ws_condicao_ant  := ws_filtro_a.condicao;
              ws_indice_ant    := ws_filtro_a.indice;
              ws_ligacao_ant   := ws_filtro_a.ligacao;
              ws_conteudo_ant  := ws_filtro_a.conteudo;

              case ws_condicao_ant
                  when 'IGUAL'        then ws_tcondicao := '=';
                  when 'DIFERENTE'    then ws_tcondicao := '<>';
                  when 'MAIOR'        then ws_tcondicao := '>';
                  when 'MENOR'        then ws_tcondicao := '<';
                  when 'MAIOROUIGUAL' then ws_tcondicao := '>=';
                  when 'MENOROUIGUAL' then ws_tcondicao := '<=';
                  when 'LIKE'         then ws_tcondicao := ' like ';
                  when 'NOTLIKE'      then ws_tcondicao := ' not like ';
                  else                ws_tcondicao      := '***';
              end case;
    end loop;
    close crs_filtro_a;

    if  prm_objeto = '%NO_BIND%' then
        ws_conteudo_comp := chr(39)||ws_conteudo_ant||chr(39);
    else
        ws_conteudo_comp := ' :b'||trim(to_char(ws_bindn,'0000'));
    end if;

    if  ws_noloop <> 'NOLOOP' then
        if  ws_initin = 'BEGIN' then
            ws_tmp_condicao := ws_tmp_condicao||ws_conteudo_comp||',';
            ws_tmp_condicao := substr(ws_tmp_condicao,1,length(ws_tmp_condicao)-1);
            ws_having := ws_having||ws_cd_coluna_ant||fcl.fpdata(ws_condicao_ant,'IGUAL',' IN ',' NOT IN ')||'('||ws_tmp_condicao||')'||crlf;
            ws_bindn := ws_bindn + 1;
        else
            ws_tmp_condicao := ws_tmp_condicao||ws_cd_coluna_ant||ws_tcondicao||ws_conteudo_comp||crlf;
            ws_having := ws_having||ws_tmp_condicao;
            ws_bindn := ws_bindn + 1;
        end if;
    end if;
    ---------------------------------------------------------------------




    if  substr(ws_having,length(ws_having)-3, 3) ='( (' then
        ws_having := substr(ws_having,1,length(ws_having)-10)||crlf;
    else
        ws_having := ws_having||' ) ) ';
    end if;

    ws_grupo := substr(ws_grupo,1,length(ws_grupo)-1);

    if  prm_rp in ('ROLL','GROUP') /*and prm_ordem <> 'X' and substr(prm_ordem,1,4) <> 'DRE='*/ then
        begin 
            if  prm_rp = 'ROLL' then
                if  nvl(trim(ws_gord_r),'SEM') = 'SEM' then
                    ws_ordem := 'order by '||ws_gorder||nvl(prm_ordem, '1');
                else
                    ws_ordem := 'order by '||ws_gorder||nvl(prm_ordem, '1')||', '||ws_gord_r||nvl(prm_ordem, '1');
                end if;
            else
                ws_ordem := 'order by '||nvl(prm_ordem, '1');
            end if;
        exception when others then
            ws_ordem := 'order by 1';
        end;
    else
        ws_ordem := '';
    end if;


    if  prm_rp = 'SUMARY' then
        ws_grupo  := '';
        ws_endgrp := '';
    else
        ws_endgrp := ') ';
    end if;

    if  prm_rp = 'PIZZA' then
        ws_endgrp := '';
        ws_ordem  := 'order by '||prm_coluna;
        ws_grupo  := 'group by '||prm_coluna;
    end if;

    ws_top_n := to_number(nvl(fun.getprop(prm_objeto,'AMOSTRA'), 0));

    -- Alterado para retirar o ) que inicia o order by - 11/05/2022  
    if  prm_ordem = 'Y' then
        ws_endgrp := '';
        begin
            begin
                --select propriedade into ws_ordem_user from object_attrib where cd_object = prm_objeto and cd_prop = 'ORDEM' and owner = ws_usuario;
                ws_ordem_user := fun.getprop(prm_objeto, 'ORDEM', prm_screen, ws_usuario); -- Pegar a ordem da tela e do usuário se existir 
                if nvl(trim(ws_ordem_user),' ') = ' ' then
                   ws_ordem_user := ' 1 ';
                end if;

                ws_ordem  := ' order by '||ws_ordem_user;

                -- se for gráfico com 2 colunas agrupadoras e uma coluna de valor (gráfico PIVOTADO), a ordem precisa iniciar com 1  
                if ws_tp_objeto in ('LINHAS','BARRAS','COLUNAS')  then
                    select count(*) into ws_count_coluna from TABLE(fun.vpipe(prm_coluna))   where column_value is not null;
                    select count(*) into ws_count_valor  from TABLE(fun.vpipe(prm_agrupador)) where column_value is not null;                    
                    if ws_count_coluna = 2 and ws_count_valor = 1 then
                        select regexp_substr(ws_ordem_user, '[^[:space:],]+') into ws_first_valor from dual;
                        select count(*) into ws_count from micro_coluna
                            where cd_micro_visao      = prm_micro_visao 
                            and cd_coluna             = upper(ws_coluna_principal)
                            and nvl(cd_ligacao,'SEM') <> 'SEM' ;
                        if upper(ws_first_valor) <> upper(ws_coluna_principal) and ws_first_valor <> '1' and (ws_count > 0 and ws_first_valor <> '2') then
                            ws_ordem  := ' order by 1,'||ws_ordem_user;
                        end if;
                    end if;

                end if;

                
            exception when others then
	            ws_ordem  := ' order by '||fun.getprop(prm_objeto,'ORDEM', prm_usuario => 'DWU');
            end;
        exception when others then
            ws_ordem  := ' order by 1';
        end;
        if ws_tp_objeto in ('LINHAS','BARRAS','COLUNAS','SANKEY','SCATTER','RADAR') then 
            ws_grupo  := 'group by '||ws_grupo;
            if ws_tp_objeto in ('SCATTER','RADAR') then 
                ws_ordem  := ' order by 1';
            end if; 
        else 
            ws_grupo  := 'group by '||ws_coluna_principal;
        end if;     
    else
        if prm_rp = 'GRUPO' and (prm_ordem = '1' or length(prm_ordem) > 1) then -- chamado pelo CHAROUT com order by definido no parametro prm_ordem  - 31/01/2022 
            ws_ordem  := ' order by '||prm_ordem;
            ws_grupo  := 'group by '||ws_coluna_principal;
            ws_endgrp := '';
        else  
            ws_ordem  := ws_ordem||' ';  -- Alterado para retirar o ) que finaliza o order by - 11/05/2022  
        end if;   
    end if;

    if  substr(ws_having,1,1) ='h' and substr(ws_having,1,6) <> 'having' then
        ws_having := '';
    end if;

    if  ws_having='having ( ( ' then
        ws_having := '';
    end if;

    begin 
        ws_versao_oracle := fun.ret_var('ORACLE_VERSION');
    exception when others then   
        ws_versao_oracle := 9999;
    end; 

    ws_hint_select := fun.getprop(prm_objeto,'HINT_SELECT'); 
    if nvl(ws_hint_select,'NA') <> 'NA' then 
        ws_hint_select := '/*+ '||ws_hint_select||' */ '; 
    end if;     

    PRM_QUERY_PADRAO(1) := 'select '||ws_hint_select||WS_DISTINTOS||CRLF;  -- Retirado "select * from (" e o Hint: + FIRST_ROWS('||fun.getprop(prm_objeto, 'AMOSTRA')||') 

    if nvl(fun.getprop(prm_objeto, 'AMOSTRA'), 0) <> 0 and ws_versao_oracle >= 12 and nvl(length(fun.getprop(prm_objeto, 'TEXTO_ACUMULADO')),0) = 0 then
        ws_limited_query := ' fetch first '||fun.getprop(prm_objeto, 'AMOSTRA')||' rows only  ';
    else
        ws_limited_query := '';
    end if;

    prm_query_padrao(ws_lquery) := substr(prm_query_padrao(ws_lquery),1,length(prm_query_padrao(ws_lquery))-3)||crlf;

    ws_lquery := ws_lquery + 1;

    if  nvl(trim(ws_par_function),'no_par') <> 'no_par' then
        prm_query_padrao(ws_lquery) := 'from table('||ws_opttable||'('||ws_par_function||')) T01 '||crlf||ws_condicoes||ws_grupo||ws_endgrp||ws_ordem||ws_limited_query||crlf;
    else
        if length(ws_filtro_geral) > 0 then
		    prm_query_padrao(ws_lquery) := 'from (select * from '||ws_opttable||' where '||ws_filtro_geral||') T01 '||crlf||ws_condicoes||ws_grupo||ws_endgrp||ws_having||ws_ordem||ws_limited_query||crlf;
        else
		    prm_query_padrao(ws_lquery) := 'from '||ws_opttable||' '||crlf||ws_condicoes||ws_grupo||ws_endgrp||ws_having||ws_ordem||ws_limited_query||crlf;
		end if;
	end if;

    prm_linhas := ws_lquery;

    if  ws_calculadas > 0 then
        ws_lquery := 0;
        begin
            ws_counter := 1;
            loop
                if  ws_counter > prm_query_padrao.COUNT then
                    exit;
                end if;
                ws_prm_query_padrao(ws_counter) := prm_query_padrao(ws_counter);
                ws_counter := ws_counter + 1;

            end loop;
        end;

        ws_lquery := ws_lquery + 1;
        prm_query_padrao(ws_lquery) :='with TABELA_X as (';

        begin
            ws_counter := 1;
            loop
                if  ws_counter > ws_prm_query_padrao.COUNT then
                    exit;
                end if;

                ws_lquery := ws_lquery + 1;
                prm_query_padrao(ws_lquery) := ws_prm_query_padrao(ws_counter);
                ws_counter := ws_counter + 1;
            end loop;
        end;

        ws_lquery := ws_lquery + 1;
        prm_query_padrao(ws_lquery) := ') select * from ( select ';

        ws_virgula := '';
        begin
            ws_counter := 0;
            loop
                if  ws_counter > (ws_nm_label.COUNT-1) then
                    exit;
                end if;

                ws_counter := ws_counter + 1;
                ws_lquery  := ws_lquery  + 1;

                if ws_tp_label(ws_counter) = '1' then  -- Coluna do código que pode ser varchar ou number                
                    prm_query_padrao(ws_lquery) := ws_virgula||' TO_CHAR('||ws_nm_label(ws_counter)||')';    -- Adicionado to_char para não gerar erro no Union se for campo numérico 
                else 
                    prm_query_padrao(ws_lquery) := ws_virgula||' '||ws_nm_label(ws_counter) ; 
                end if;    

                ws_virgula := ',';
            end loop;

            ws_counter := ws_counter + 1;
            ws_lquery  := ws_lquery  + 1;
            prm_query_padrao(ws_lquery) := ws_virgula||' UP_GRP_ID';
            ws_counter := ws_counter + 1;
            ws_lquery  := ws_lquery  + 1;
            prm_query_padrao(ws_lquery) := ws_virgula||' UP_PRINCI';

        end;

        ws_lquery := ws_lquery + 1;
        prm_query_padrao(ws_lquery) := ' from TABELA_X ';

        ws_virgula := '';
        open crs_lcalc;
        loop
            fetch crs_lcalc into ws_lcalc;
                  exit when crs_lcalc%notfound;

                  ws_lquery := ws_lquery + 1;
                  prm_query_padrao(ws_lquery) := ' union all SELECT ';

                  ws_counter := 0;
                  ws_identificador := ' ';
                  loop
                      if  ws_counter > (ws_nm_label.COUNT-1) then
                          exit;
                      end if;

                      ws_counter := ws_counter + 1;
                      if  ws_tp_label(ws_counter)='1' and ws_nm_original(ws_counter) = ws_lcalc.cd_coluna then
                          ws_identificador := ws_nm_label(ws_counter);
                      end if;
                  end loop;

                  ws_counter := 0;
                  ws_virgula := ' ';
                  loop
                      if  ws_counter > (ws_nm_label.COUNT-1) then
                          exit;
                      end if;

                      ws_counter := ws_counter + 1;
                      ws_lquery  := ws_lquery  + 1;

    	              case ws_tp_label(ws_counter)
                        when '1' then
                            if  ws_nm_original(ws_counter) = ws_lcalc.cd_coluna then
                                if ws_nm_label.COUNT > 1 then
                                    prm_query_padrao(ws_lquery) :=  ws_virgula||chr(39)||ws_lcalc.cd_coluna_show||chr(39);
                                else
                                    prm_query_padrao(ws_lquery) :=  ws_virgula||chr(39)||ws_lcalc.ds_coluna_show||chr(39);
                                end if;
                            else
                                prm_query_padrao(ws_lquery) := ws_virgula||chr(39)||'['||ws_nm_original(ws_ct_label)||']=['||ws_lcalc.cd_coluna||']'||chr(39);
                            end if;
                        when '2' then
                            if  ws_nm_original(ws_counter) = ws_lcalc.cd_coluna then
                                prm_query_padrao(ws_lquery) := ws_virgula||chr(39)||ws_lcalc.ds_coluna_show||chr(39);
                            else
                                prm_query_padrao(ws_lquery) := ws_virgula||chr(39)||'['||ws_nm_original(ws_ct_label)||']=['||ws_lcalc.cd_coluna||']'||chr(39);
                            end if;
                        when '3' then
                            prm_query_padrao(ws_lquery) := ws_virgula||'('||fun.GL_CALCULADA(ws_lcalc.ds_formula,ws_identificador,ws_nm_label(ws_counter), prm_micro_visao)||')';                            
                            -- prm_query_padrao(ws_lquery) := ws_virgula||'sum('||fun.GL_CALCULADA(ws_lcalc.ds_formula,ws_identificador,ws_nm_label(ws_counter), prm_micro_visao)||')';
                            -- Retirado o SUM( para que o usuário/analista consiga colocar outros tipos de agrupadores sum, nvl, etc.
                        else
                            prm_query_padrao(ws_lquery) := ws_virgula||chr(39)||'.'||chr(39);
                    end case;
                    ws_virgula := ',';
                  end loop;

                  ws_counter := ws_counter + 1;
                  ws_lquery  := ws_lquery  + 1;
                  prm_query_padrao(ws_lquery) := ws_virgula||' 0 as UP_GRP_ID';
                  ws_counter := ws_counter + 1;
                  ws_lquery  := ws_lquery  + 1;
                  prm_query_padrao(ws_lquery) := ws_virgula||' 0 as UP_PRINCI';

                  ws_lquery := ws_lquery + 1;
                  prm_query_padrao(ws_lquery) := ' from TABELA_X';
	    end loop;
        close crs_lcalc;
        
        prm_query_padrao(ws_lquery) := prm_query_padrao(ws_lquery)||' ) order by 1';

    end if;

    prm_linhas := ws_lquery;

    
    if  prm_cross = 'S' then
        ws_lquery := 0;
        begin
             ws_counter := 1;
             loop
                 if  ws_counter > prm_query_padrao.COUNT then
                     exit;
                 end if;
                 ws_prm_query_padrao(ws_counter) := prm_query_padrao(ws_counter);
                 ws_counter := ws_counter + 1;

             end loop;
        end;


        ws_lquery := ws_lquery + 1;
        prm_query_padrao(ws_lquery) :='select * from ( WITH TABELA_BASE AS ( ';

        begin
             ws_counter := 1;
             loop
                 if  ws_counter > ws_prm_query_padrao.COUNT then
                     exit;
                 end if;

                 ws_lquery := ws_lquery + 1;
                 prm_query_padrao(ws_lquery) := ws_prm_query_padrao(ws_counter);

                 

                 ws_counter := ws_counter + 1;
             end loop;
        end;

        
        ws_lquery := ws_lquery + 1;
        prm_query_padrao(ws_lquery) := ' )  select * from ( ';

        ws_unionall := '';
        ws_vcount := 0;
        loop
            ws_vcount := ws_vcount + 1;
            if  ws_vcount > ws_agrupadores.COUNT then
                exit;
            end if;

            ws_lquery := ws_lquery + 1;

            prm_query_padrao(ws_lquery) := ws_unionall||'SELECT R_'||prm_coluna||' AS R_'||prm_coluna||', '||chr(39)||to_char(ws_vcount,'000')||'-'||ws_agrupadores(ws_vcount)||chr(39)||' AS '||prm_coluna||', R_'||ws_agrupadores(ws_vcount)||'     AS R_VALOR FROM TABELA_BASE ';

            ws_unionall := ' UNION ALL ';
        end loop;
        ws_cursor := 'select distinct '||prm_coluna||' from '||ws_opttable||' '||ws_condicoes||' order by '||prm_coluna;

        
        
        ws_pcursor := dbms_sql.open_cursor;



        dbms_sql.parse(ws_pcursor, ws_cursor, dbms_sql.native);
        dbms_sql.define_column(ws_pcursor, 1, ret_lcross, 400);
        ws_nulo := core.bind_direct(prm_condicoes, ws_pcursor, '', prm_objeto, prm_micro_visao, prm_screen,prm_usuario => ws_usuario);
        ws_linhas := dbms_sql.execute(ws_pcursor);
        ws_lquery := ws_lquery + 1;
        prm_query_padrao(ws_lquery) := ' )) pivot ( sum(R_VALOR) for R_'||prm_coluna||' in ( ';

        prm_cab_cross := prm_coluna;
        prm_ncolumns(1) := prm_coluna;
        ws_vcount       := 1;
        ws_virgula := '';
        
    

        loop
            ws_linhas := dbms_sql.fetch_rows(ws_pcursor);
            if  ws_linhas = 1 then
                ws_vazio := False;
            else
                if  ws_vazio = True then
                    dbms_sql.close_cursor(ws_pcursor);
                    raise ws_nodata;
                end if;
                exit;
            end if;

            dbms_sql.column_value(ws_pcursor, 1, ret_lcross);
            ws_lquery                   := ws_lquery + 1;
            ws_vcount                   := ws_vcount + 1;
            prm_query_padrao(ws_lquery) := ws_virgula||chr(39)||ret_lcross||chr(39);
            begin
                prm_cab_cross               := prm_cab_cross||'|'||ret_lcross;
            exception when others then
                insert into bi_log_sistema values(sysdate, 'Erro de cross', ws_usuario, 'ERRO');
                commit;
                exit;
            end;
            prm_ncolumns(ws_vcount)     := ret_lcross;

            ws_virgula := ',';
        end loop;
        ws_lquery := ws_lquery + 1;
        prm_query_padrao(ws_lquery) := ')) order by 1';
        prm_linhas := ws_lquery;
        dbms_sql.close_cursor(ws_pcursor);
    end if;
   
    return ('X');
    
exception 
    when ws_nodata then
        insert into bi_log_sistema values(sysdate, 'Sem dados! - MONTA - '||prm_objeto, ws_usuario, 'ERRO');
        commit;
        return 'Sem Dados';
    when ws_excesso_filtro then
        insert into bi_log_sistema values(sysdate, 'MONTA_QUERY_DIRECT - Excesso de filtros, selecione no maximo '||(ws_qt_filtro-1)||' itens nos filtros.', ws_usuario, 'ERRO');
        commit;
        return 'Excesso de filtros, selecione no m&aacute;ximo '||ws_qt_filtro||' itens nos filtros.';
    when ws_nouser then
        insert into bi_log_sistema values(sysdate, 'Sem permiss&atilde;o! - MONTA - '||prm_objeto, ws_usuario, 'ERRO');
        commit;
        return 'Sem usuario conectado'; 
    when others then
        insert into bi_log_sistema values(sysdate, 'MONTA - '||prm_objeto||' - '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, ws_usuario, 'ERRO');
        commit;
        return 'Erro (outros) montando query, verifique o log dos sistema';         
end MONTA_QUERY_DIRECT;

FUNCTION BIND_DIRECT (	prm_condicoes	 varchar2	default null,
						prm_cursor  	 number     default 0,
						prm_tipo		 varchar2	default null,
						prm_objeto		 varchar2	default null,
						prm_micro_visao	 varchar2	default null,
						prm_screen       varchar2   default null,
                        prm_no_having    varchar2   default 'S',
                        prm_usuario      varchar2   default null ) return varchar2 as

         -------------------------------------------------------------------------------------
         -- Esse cursor precisa ser só da BIND_DIRECT para não dar erro quando um objeto chama o objeto valor, 
         -- se for o mesmo cursor do objeto principal dá erro de cursor já aberto 
         ------------------------------------------------------------------------------------    
         cursor crs_filtrog (  prm_condicoes    varchar2,    
                               prm_micro_visao  varchar2,
                               prm_screen       varchar2,
                               prm_objeto       varchar2,
                               prm_usuario      varchar2, 
                               prm_vpar         varchar2,
                               prm_cd_mapa      varchar2,
                               prm_nr_item      varchar2,
                               prm_cd_padrao    varchar2 ) is

            select distinct *
             from ( -- Float FILTER - filtra valores IGUAIS ou DEFERENTES do informado no filtro 
                    select 'C'                                   as indice,
                           'DWU'                                 as cd_usuario,
                           trim(prm_micro_visao)                 as micro_visao,
                           trim(cd_coluna)                       as cd_coluna,
                           decode(instr(trim(conteudo),'$[NOT]'),0,'IGUAL', 'DIFERENTE')  as condicao,
                           replace(trim(CONTEUDO), '$[NOT]', '') as conteudo,
                           'and'                                 as ligacao,
                           'float_filter_item'                   as tipo
                      from FLOAT_FILTER_ITEM
                     where trim(cd_usuario) = prm_usuario 
                       and trim(screen)     = trim(prm_screen) 
                       and fun.getprop(prm_objeto,'FILTRO_FLOAT') = 'N'   -- Atributo: BLOQUEAR FILTRO DO FLOAT (ignorar todos os float_filter do objeto) 
                       -- cdr 833s - and cd_coluna not in (select cd_coluna from filtros where condicao = 'NOFLOAT' and micro_visao = trim(prm_micro_visao) and cd_objeto = trim(prm_objeto) and tp_filtro = 'objeto') -- Ignora o filtro se ele estiver cadastrado no objeto como NOFLOAT
                       and cd_coluna not in (select cd_coluna from filtros where micro_visao = trim(prm_micro_visao) and cd_objeto = trim(prm_objeto) and tp_filtro = 'objeto') -- card 833s - Ignora o filtro se ele estiver cadastrado no objeto como NOFLOAT
                       and cd_coluna in ( select trim(cd_coluna) from micro_coluna mc where mc.cd_micro_visao = trim(prm_micro_visao)  ) 
                    --	
                    union all
                    --
                    -- Filtros passados por parametro se for consulta CUSTOMIZADA (p_codicoes)
                    select 'A'                   as indice,
                           'DWU'                 as cd_usuario,
                           trim(prm_micro_visao) as micro_visao,
                           trim(cd_coluna)       as cd_coluna,
                           cd_condicao           as condicao,
                           trim(CD_CONTEUDO)     as conteudo,
                           'and'                 as ligacao,
                           'condicoes'           as tipo
                      from table(fun.vpipe_par(prm_condicoes)) pc
                     where cd_coluna <> '1' 
                       and prm_objeto like 'COBJ%'
                    -- 
                    union all
                    --
                    -- Filtros passados por parametro para uma Drill ou subquery (p_codicoes)
                    select 'A'                   as indice,
                           'DWU'                 as cd_usuario,
                           trim(prm_micro_visao) as micro_visao,
                           trim(cd_coluna)       as cd_coluna,
                           cd_condicao           as condicao,
                           trim(CD_CONTEUDO)     as conteudo,
                           'and'                 as ligacao,
                           'condicoes'           as tipo
                      from table(fun.vpipe_par(prm_condicoes)) pc
                     where cd_coluna <> '1' 
                       and prm_objeto not like 'COBJ%'
                       and fun.getprop(prm_objeto,'FILTRO_DRILL') = 'N'  -- Atributo: BLOQUEAR FILTRO DA DRILL (ignorar todos os filtros repassados por parametro (DRILL))                        
                       and cd_coluna in ( select trim(cd_coluna) from micro_coluna     where cd_micro_visao = trim(prm_micro_visao) union all
                                          select trim(cd_coluna) from micro_visao_fpar where cd_micro_visao = trim(prm_micro_visao)
                                        )
                       and trim(cd_coluna)||trim(cd_conteudo) not in ( select nof.cd_coluna||nof.CONTEUDO  -- Ignora filtro se estiver cadastrados no objeto como IGNORAR FILTRO
                                                                         from filtros nof
                                                                        where nof.micro_visao = trim(prm_micro_visao) 
                                                                          and nof.condicao    = 'NOFILTER' 
                                                                          and nof.conteudo    = trim(pc.cd_conteudo) 
                                                                          and nof.cd_objeto   = trim(prm_objeto)
                                                                      )
                    --
                    union all
                    --
                    select 'X'                     as indice,
                           'DWU'                   as cd_usuario,
                           rtrim(prm_micro_visao)  as micro_visao,
                           rtrim(cd_coluna)        as cd_coluna,
                           rtrim(condicao)         as condicao,
                           rtrim(conteudo)         as conteudo,
                           rtrim(ligacao)          as ligacao,
                           'deff_line_filtro'      as tipo
                      from DEFF_LINE_FILTRO
                     where trim(cd_mapa)   = prm_cd_mapa 
                       and trim(nr_item)   = prm_nr_item 
                       and trim(cd_padrao) = prm_cd_padrao
                    --
                    union all
                    --
                    -- Filtros de objeto e de tela (que não seja NOFLOAT e NOFILTER)
                    select decode(cd_objeto, trim(prm_objeto), 'B', 'C') as indice,
                           rtrim(cd_usuario)  as cd_usuario,
                           rtrim(micro_visao) as micro_visao,
                           rtrim(cd_coluna)   as cd_coluna,
                           rtrim(condicao)    as condicao,
                           rtrim(conteudo)    as conteudo,
                           rtrim(ligacao)     as ligacao,
                           'filtros_objeto'   as tipo
                      from FILTROS
                     where micro_visao  = trim(prm_micro_visao) 
                       and CONDICAO not in ('NOFLOAT', 'NOFILTER')   -- Não pegar filtros cadastrados somente para ignorar filtros de tela
                       and st_agrupado      = 'N' 
                       and tp_filtro        = 'objeto' 
                       and trim(cd_usuario) = 'DWU'
                       and ( (cd_objeto = trim(prm_objeto) ) or   -- Filtro de objeto 
                             (cd_objeto = trim(prm_screen)   -- Filtro de tela  
                              and nvl(fun.GETPROP(trim(prm_objeto),'FILTRO'), 'N/A') not in ('ISOLADO', 'COM CORTE')  
                              and fun.getprop(prm_objeto,'FILTRO_TELA') <> 'S'     -- atributo BLOQUEAR FILTRO DE TELA diferente de S   
                              and cd_coluna not in (select t2.cd_coluna 
                                                      from filtros t2 
                                                     where t2.condicao    = 'NOFLOAT' 
                                                       and t2.micro_visao = trim(prm_micro_visao) 
                                                       and t2.cd_objeto   = trim(prm_objeto) 
                                                       and t2.tp_filtro   = 'objeto'
                                                   ) -- Ignora o filtro se ele estiver cadastrado no objeto como NOFLOAT
                             ) 
                           ) 
                )
            where not ( trim(condicao)='IGUAL' and trim(cd_coluna) in (select trim(cd_coluna) from table(fun.vpipe_par(prm_vpar))))
            --order by tipo, cd_usuario, micro_visao, cd_coluna, condicao, conteudo;
            order by indice, cd_coluna, condicao, tipo, cd_usuario, micro_visao, conteudo;

    /******* COMENTADO para pegar o cursor geral da package, que é o mesmo utilizado para montar a query 
	cursor crs_filtrog ( p_condicoes varchar2,
	                     p_vpar      varchar2,
                         prm_usuario varchar2 ) is

        select distinct * 
        from    ( select
                         'DWU' as cd_usuario,
                         trim(prm_micro_visao)                 as micro_visao,
                         trim(cd_coluna)                       as cd_coluna,
                         'DIFERENTE'                           as condicao,
                         replace(trim(CONTEUDO), '$[NOT]', '') as conteudo,
                         'and'                                 as ligacao,
                         'float_filter_item'                   as tipo
                   from FLOAT_FILTER_ITEM
                  where
                        trim(cd_usuario) = prm_usuario and
                        trim(screen) = trim(prm_screen) and
                        instr(trim(conteudo), '$[NOT]') <> 0 and
                        trim(cd_coluna) not in (select cd_coluna from filtros where condicao = 'NOFLOAT' and trim(micro_visao) = trim(prm_micro_visao) and trim(cd_objeto) = trim(prm_objeto) and tp_filtro = 'objeto') and
                        trim(cd_coluna) in ( select trim(CD_COLUNA)
                                                from   MICRO_COLUNA mc
                                                where  trim(mc.CD_MICRO_VISAO)=trim(prm_micro_visao) and
                                                trim(mc.cd_coluna) not in (select distinct nvl(trim(cd_coluna), 'N/A') from table(fun.vpipe_par(p_condicoes)))
                                                ) and fun.getprop(prm_objeto,'FILTRO_FLOAT') = 'N'
                    --  
                    union all
                    --
                    select
                            'DWU' as cd_usuario,
                            trim(prm_micro_visao) as micro_visao,
                            trim(cd_coluna)       as cd_coluna,
                            'IGUAL'               as condicao,
                            trim(CONTEUDO)     as conteudo,
                            'and'                 as ligacao,
                            'float_filter_item'   as tipo
                    from   FLOAT_FILTER_ITEM
                    where
                        trim(cd_usuario) = prm_usuario and
                        trim(screen) = trim(prm_screen) and
                        instr(trim(conteudo), '$[NOT]') = 0 and
                        trim(cd_coluna) not in (select cd_coluna from filtros where condicao = 'NOFLOAT' and trim(micro_visao) = trim(prm_micro_visao) and trim(cd_objeto) = trim(prm_objeto) and tp_filtro = 'objeto') and
                        trim(cd_coluna) in ( select trim(CD_COLUNA)
                                                from   MICRO_COLUNA mc
                                                where  trim(mc.CD_MICRO_VISAO)=trim(prm_micro_visao) and
                                                trim(mc.cd_coluna) not in (select distinct nvl(trim(cd_coluna), 'N/A') from table(fun.vpipe_par(p_condicoes)))
                                                ) and fun.getprop(prm_objeto,'FILTRO_FLOAT') = 'N'
                    --                             
                    union all
                    -- 
                    select 'DWU'                 as cd_usuario,  --- falta verificar bloqueio de Drill 
                            trim(prm_micro_visao) as micro_visao,
                            trim(cd_coluna)       as cd_coluna,
                            cd_condicao               as condicao,
                            trim(CD_CONTEUDO)     as conteudo,
                            'and'                 as ligacao,
                            'condicoes'           as tipo
                        from table(fun.vpipe_par(p_condicoes)) pc 
                        where cd_coluna <> '1' 
                        and  (  (trim(cd_coluna) in ( select trim(CD_COLUNA) from MICRO_COLUNA where trim(CD_MICRO_VISAO)=trim(prm_micro_visao) 
                                                    union all
                                                    select trim(CD_COLUNA) from MICRO_VISAO_FPAR where trim(CD_MICRO_VISAO)=trim(prm_micro_visao)
                                                    )
                                 and trim(cd_coluna)||trim(cd_conteudo) not in ( select nof.cd_coluna||nof.conteudo from  filtros nof
                                                                         where  trim(nof.micro_visao) = trim(prm_micro_visao) and 
                                                                                trim(nof.condicao) = 'NOFILTER' and 
                                                                                trim(nof.conteudo) = trim(pc.cd_conteudo) and 
                                                                                trim(nof.cd_objeto) = trim(prm_objeto)
                                                                              )
                                 and fun.getprop(prm_objeto,'FILTRO_DRILL') = 'N'
                               ) or prm_objeto like ('COBJ%') 
                             ) 
                        and trim(cd_coluna)||trim(cd_conteudo) not in ( select nof.cd_coluna||nof.conteudo from  filtros nof
                                                                         where  trim(nof.micro_visao) = trim(prm_micro_visao) and 
                                                                                trim(nof.condicao) = 'NOFILTER' and 
                                                                                trim(nof.conteudo) = trim(pc.cd_conteudo) and 
                                                                                trim(nof.cd_objeto) = trim(prm_objeto)
                                                                      )
                    --   
                    union all
                    --
                    select	trim(cd_usuario)	as cd_usuario,
                        rtrim(micro_visao)	as micro_visao,
                        rtrim(cd_coluna)	as cd_coluna,
                        rtrim(condicao)		as condicao,
                        rtrim(conteudo)		as conteudo,
                        rtrim(ligacao)		as ligacao,
                        'filtros_objeto'    as tipo
                    from 	FILTROS
                    where	trim(micro_visao) = trim(prm_micro_visao) and 
                    st_agrupado='N' and 
                    condicao <> 'NOFLOAT' and
                    condicao <> 'NOFILTER' AND
                    (
                        rtrim(cd_objeto) = trim(prm_objeto) or
                        (
                            rtrim(cd_objeto) = trim(prm_screen) and 
                            nvl(fun.getprop(trim(prm_objeto),'FILTRO'), 'N/A') <> 'ISOLADO' and 
                            nvl(fun.getprop(trim(prm_objeto),'FILTRO'), 'N/A') <> 'COM CORTE' and 
                            fun.getprop(prm_objeto,'FILTRO_TELA') <> 'S' and 
                            cd_coluna not in (select t2.cd_coluna from filtros t2 where t2.condicao = 'NOFLOAT' and t2.micro_visao = trim(prm_micro_visao) and t2.cd_objeto = trim(prm_objeto) and tp_filtro = 'objeto') -- Ignora o filtro se ele estiver cadastrado no objeto como NOFLOAT
                        )
                    )
                    and tp_filtro = 'objeto'
                    and trim(cd_usuario)  = 'DWU'
                )
            where not (trim(condicao)='IGUAL' and trim(cd_coluna) in (select trim(cd_coluna) from table(fun.vpipe_par(p_vpar))))
            order   by tipo, cd_usuario, micro_visao, cd_coluna, condicao, conteudo;
    *****************/ 

	ws_filtrog	crs_filtrog%rowtype;

	cursor crs_filtrogf ( p_condicoes varchar2,
	                      p_vpar      varchar2,
                          prm_usuario varchar2 ) is
                    select * from ( select distinct  *
   	                                from (
                                            select 'DWU'                 as cd_usuario,
                                                trim(prm_micro_visao) as micro_visao,
                                                trim(cd_coluna)       as cd_coluna,
                                                cd_condicao               as condicao,
                                                trim(CD_CONTEUDO)     as conteudo,
                                                'and'                 as ligacao
                                                from table(fun.vpipe_par(p_condicoes)) where cd_coluna <> '1' and trim(cd_coluna) in (select trim(CD_COLUNA) from MICRO_COLUNA     where trim(CD_MICRO_VISAO)=trim(prm_micro_visao) union all
                                                                                                                                    select trim(CD_COLUNA) from MICRO_VISAO_FPAR where  trim(CD_MICRO_VISAO)=trim(prm_micro_visao))
                                                --
                                                union all
                                                --
                                                select	trim(cd_usuario)	as cd_usuario,
                                                    rtrim(micro_visao)	as micro_visao,
                                                    rtrim(cd_coluna)	as cd_coluna,
                                                    rtrim(condicao)		as condicao,
                                                    rtrim(conteudo)		as conteudo,
                                                    rtrim(ligacao)		as ligacao
                                                from 	FILTROS t1
                                                where	rtrim(micro_visao) = rtrim(prm_micro_visao) and
                                                    tp_filtro = 'geral' and
                                                    (rtrim(cd_usuario)  in (prm_usuario, 'DWU') or trim(cd_usuario) in (select cd_group from gusers_itens where cd_usuario = prm_usuario))
                                                --    
                                                union
                                                --
                                                select	trim(cd_usuario)	as cd_usuario,
                                                    rtrim(micro_visao)	as micro_visao,
                                                    rtrim(cd_coluna)	as cd_coluna,
                                                    rtrim(condicao)		as condicao,
                                                    rtrim(conteudo)		as conteudo,
                                                    rtrim(ligacao)		as ligacao
                                                from 	FILTROS
                                                where	trim(micro_visao) = trim(prm_micro_visao) and 
                                                tp_filtro = 'objeto' and 
                                                condicao <> 'NOFLOAT' and
                                                (
                                                trim(cd_objeto) = trim(prm_objeto) or
                                                (trim(cd_objeto) = trim(prm_screen) and fun.GETPROP(trim(prm_objeto),'FILTRO')<>'ISOLADO')
                                                ) and
                                                    trim(cd_usuario)  = 'DWU'
                                         )
                                    where   (trim(condicao)='IGUAL' and trim(cd_coluna) in (select trim(cd_coluna) from table(fun.vpipe_par(p_vpar))))
                                ) 
                    where not (trim(cd_coluna) not in (Select distinct Cd_Coluna from MICRO_VISAO_FPAR where cd_micro_visao = prm_micro_visao) and fun.getprop(prm_objeto,'FILTRO')='ISOLADO')
	 			    order   by cd_coluna;

	ws_filtrogf	crs_filtrogf%rowtype;

cursor crs_filtro_a ( p_condicoes    varchar2,
                      p_vpar         varchar2,
                      prm_usuario    varchar2 ) is
                    select distinct * 
                        from (
                                select 'C'                     as indice,
                                         rtrim(cd_usuario)       as cd_usuario,
                                         rtrim(micro_visao)      as micro_visao,
                                         rtrim(cd_coluna)        as cd_coluna,
                                         rtrim(condicao)         as condicao,
                                         rtrim(conteudo)         as conteudo,
                                         rtrim(ligacao)          as ligacao
                                  from   FILTROS t1
                                  where  rtrim(micro_visao) = rtrim(prm_micro_visao) and
                                         tp_filtro = 'geral' and
                                         (rtrim(cd_usuario) in (prm_usuario, 'DWU') or trim(cd_usuario) in (select cd_group from gusers_itens where cd_usuario = prm_usuario)) and
                                         st_agrupado='S'
                                --
                                union all
                                --
                                  select 'C'                     as indice,
                                         rtrim(cd_usuario)       as cd_usuario,
                                         rtrim(micro_visao)      as micro_visao,
                                         rtrim(cd_coluna)        as cd_coluna,
                                         rtrim(condicao)         as condicao,
                                         rtrim(conteudo)         as conteudo,
                                         rtrim(ligacao)          as ligacao
                                  from   FILTROS
                                  where  trim(micro_visao) = trim(prm_micro_visao) and st_agrupado='S' and
                                         tp_filtro = 'objeto' and
                                         trim(cd_objeto)   in (trim(prm_objeto), trim(prm_screen)) and
                                         condicao <> 'NOFLOAT' and
                                         trim(cd_usuario)  = 'DWU'
                             )
                        where not ( trim(condicao)='IGUAL' and trim(cd_coluna) in (select trim(cd_coluna) from table(fun.vpipe_par(p_vpar))))
                        order by cd_usuario, micro_visao, cd_coluna, condicao, conteudo;

   ws_filtro_a	crs_filtro_a%rowtype;

    /***** passado para o inicio da package 
	cursor crs_fpar is
                        Select
                        Cd_Micro_Visao,
                        Cd_Coluna,
                        Cd_parametro
                        from   MICRO_VISAO_FPAR
                        where
	                       cd_micro_visao = prm_micro_visao
	                order by cd_coluna;
    *****************************/                      

	ws_fpar		crs_fpar%rowtype;

	ws_par_function  varchar2(32000);
    ws_pipe                 char(1);
	ws_bindn		number;
	ws_distintos	varchar2(32000);
	ws_texto		varchar2(32000);
	ws_textot		varchar2(32000);
	ws_nm_var		varchar2(8000);
	ws_ct_var		varchar2(8000);
	ws_null			varchar2(8000);
	ws_tcont		varchar2(32000);

	ws_cursor	integer;
	ws_linhas	integer;

	ws_calculado	varchar2(32000);
	ws_sql		    varchar2(32000);

	crlf VARCHAR2( 2 ):= CHR( 13 ) || CHR( 10 );

    ws_nulo varchar2(1) := null;
	
	ws_binds varchar2(3000);

    ws_usuario varchar2(80);
    ws_owner_table  varchar2(40); 
    ws_nm_tabela    varchar2(300); 
    ws_data_type    varchar2(100); 
    ws_dt_aux       date; 

begin

    ws_usuario := prm_usuario; 
    if ws_usuario is null then 
        ws_usuario := gbl.getUsuario;
    end if;

    ws_owner_table := nvl(fun.ret_var('OWNER_TABLE_DATA'),'DWU');
    ws_nm_tabela   := fun.GETPROP (prm_objeto, 'TABELA_FISICA_OBJETO');	   
	if ws_nm_tabela is null then 
        select max(nm_tabela) into ws_nm_tabela
        from micro_visao
        where nm_micro_visao = prm_micro_visao; 
	end if; 
	ws_bindn := 1;

	ws_texto := replace(prm_condicoes, '||', '|');

    if instr(ws_texto, '|', -1) = length(ws_texto) then
      ws_texto := substr(ws_texto, 0, instr(ws_texto, '|', -1)-1);
    end if;

	if  prm_tipo = 'SUMARY' then
	    ws_null  := substr(ws_texto, 1 ,instr(ws_texto,'|')-1);
	    ws_texto := replace(ws_texto, ws_null||'|', '');
	end if;

        ws_par_function := '';
        ws_pipe := '';

    open crs_fpar (prm_micro_visao);
    loop
        fetch crs_fpar into ws_fpar;
        exit when crs_fpar%notfound;

        ws_par_function := ws_par_function||ws_pipe||ws_fpar.cd_coluna||'|'||ws_fpar.cd_parametro;
        ws_pipe         := '|';
    end loop;
    close crs_fpar;


	/* open crs_filtrog(ws_texto, ws_par_function, ws_usuario);*/ 
    open crs_filtrog(ws_texto, 
                     prm_micro_visao,
                     prm_screen,
                     prm_objeto,
                     ws_usuario,
                     ws_par_function,
                     null,
                     null,
                     null);
    loop
            fetch crs_filtrog into ws_filtrog;
            exit when crs_filtrog%notfound;

            -- Retorna substituição do | do texto do parametro, caso exista e tenha sido substituido por #[PIPE]
            if ws_filtrog.conteudo like '%@PIPE@%' then 
                ws_filtrog.conteudo := replace(ws_filtrog.conteudo,'@PIPE@','|');
            end if; 


            ws_tcont := ws_filtrog.conteudo;

            if  UPPER(substr(ws_tcont,1,5)) = 'EXEC=' then
                ws_tcont := fun.xexec(ws_tcont, prm_screen);
            end if;

            if  UPPER(substr(ws_tcont,1,8)) = 'SUBEXEC=' then
                ws_tcont := fun.xexec(fun.subpar(ws_tcont, prm_screen, 'N'), prm_screen);
            end if;

            if  substr(ws_tcont,1,2) = '$[' then
                ws_tcont := fun.gparametro(ws_tcont, prm_usuario => ws_usuario);         
            end if;

            if  substr(ws_tcont,1,2) = '#[' then
                ws_tcont := fun.ret_var(ws_tcont, ws_usuario);
            end if;

            if  substr(ws_tcont,1,2) = '@[' then
                ws_tcont := fun.gvalor(ws_tcont, prm_screen);
            end if;

            -- Tratamento no caso de conteúdo de filtro que seja data no formato que não seja dd-mon-rr  ( card: 536a)
            select nvl(max(data_type),'N/A') into ws_data_type
       		  from all_tab_columns
	 	     where owner       = ws_owner_table
               and table_name  = ws_nm_tabela 
               and column_name = ws_filtrog.cd_coluna; 
            ws_dt_aux := null;    
            if ws_data_type = 'DATE' then 
               begin
                    ws_dt_aux := to_date(ws_tcont,'dd/mm/rr hh24:mi:ss');
                    ws_tcont  := to_char(ws_dt_aux,'dd/mm/rrrr hh24:mi:ss');
                exception when others then
                    null;
                end;
            end if; 
            ws_binds := ws_binds||'|'||ws_tcont;

            if prm_cursor is not null then 
                if ws_dt_aux is not null then 
                    DBMS_SQL.BIND_VARIABLE(prm_cursor, ':b'||ltrim(to_char(ws_bindn,'0000')), ws_dt_aux);
                else 
                    DBMS_SQL.BIND_VARIABLE(prm_cursor, ':b'||ltrim(to_char(ws_bindn,'0000')), ws_tcont);
                end if;     
            end if;    

            ws_bindn := ws_bindn + 1;

    end loop;
	close crs_filtrog;


	open crs_filtrogf(ws_texto, ws_par_function, ws_usuario);
	loop
	    fetch crs_filtrogf into ws_filtrogf;
	    exit when crs_filtrogf%notfound;

            ws_tcont := ws_filtrogf.conteudo;

            if UPPER(substr(ws_tcont,1,5)) = 'EXEC=' then
                ws_tcont := fun.xexec(ws_tcont, prm_screen);
            end if;

            if UPPER(substr(ws_tcont,1,8)) = 'SUBEXEC=' then
                ws_tcont := fun.xexec(fun.subpar(ws_tcont, prm_screen, 'N'), prm_screen);
            end if;
            
            if  substr(ws_tcont,1,2) = '$[' then
                ws_tcont := fun.gparametro(ws_tcont, prm_usuario => ws_usuario);
            end if;

            if substr(ws_tcont,1,2) = '#[' then
                ws_tcont := fun.ret_var(ws_tcont, ws_usuario);
            end if;

                        -- Tratamento no caso de conteúdo de filtro que seja data no formato que não seja dd-mon-rr  ( card: 536a)
            select nvl(max(data_type),'N/A') into ws_data_type
       		  from all_tab_columns
	 	     where owner       = ws_owner_table
               and table_name  = ws_nm_tabela 
               and column_name = ws_filtrog.cd_coluna; 
            ws_dt_aux := null;    
            if ws_data_type = 'DATE' then 
               begin
                    ws_dt_aux := to_date(ws_tcont,'dd/mm/rr hh24:mi:ss');
                    ws_tcont  := to_char(ws_dt_aux,'dd/mm/rrrr hh24:mi:ss');
                exception when others then
                    null;
                end;
            end if; 
            ws_binds := ws_binds||'|'||ws_tcont;

            if prm_cursor is not null then 
                if ws_dt_aux is not null then 
                    DBMS_SQL.BIND_VARIABLE(prm_cursor, ':b'||ltrim(to_char(ws_bindn,'0000')), ws_dt_aux);
                else 
                    DBMS_SQL.BIND_VARIABLE(prm_cursor, ':b'||ltrim(to_char(ws_bindn,'0000')), ws_tcont);
                end if;     
            end if;    

            -- ws_binds := ws_binds||'|'||ws_tcont;
            -- 
            -- if prm_cursor is not null then 
            --     DBMS_SQL.BIND_VARIABLE(prm_cursor, ':b'||ltrim(to_char(ws_bindn,'0000')), ws_tcont);
            -- end if;     
            
            ws_bindn := ws_bindn + 1;

    end loop;
    close crs_filtrogf;

	open crs_filtro_a(ws_texto, ws_par_function, ws_usuario);
	loop
            fetch crs_filtro_a into ws_filtro_a;
            exit when crs_filtro_a%notfound;

            ws_tcont := ws_filtro_a.conteudo;

            if  substr(ws_tcont,1,2) = '$[' then
                ws_tcont := fun.gparametro(ws_tcont, prm_usuario => ws_usuario);
            end if;

            if  substr(ws_tcont,1,2) = '#[' then
                ws_tcont := fun.ret_var(ws_tcont, ws_usuario);
            end if;

            if  UPPER(substr(ws_tcont,1,5)) = 'EXEC=' then
                ws_tcont := fun.xexec(ws_tcont, prm_screen);
            end if;

            if  UPPER(substr(ws_tcont,1,5)) = 'SUBEXEC=' then
                ws_tcont := fun.xexec(fun.subpar(ws_tcont, prm_screen, 'N'), prm_screen);
            end if;
            
            ws_binds := ws_binds||'|'||ws_tcont;
            if prm_cursor is not null then 
                DBMS_SQL.BIND_VARIABLE(prm_cursor, ':b'||ltrim(to_char(ws_bindn,'0000')), ws_tcont);
            end if;     
            
            ws_bindn := ws_bindn + 1;

	end loop;
	close crs_filtro_a;
		
  return ('Binds Carregadas='||ws_binds);
  
exception
	when others then
        insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - BIND_DIRECT '||prm_cursor, ws_usuario, 'ERRO');
        commit;
end BIND_DIRECT;

FUNCTION DATA_DIRECT ( prm_micro_data    in  long	     default null,
			    	   prm_coluna		 in  long	     default null,
		    		   prm_query_padrao  out DBMS_SQL.VARCHAR2a,
			    	   prm_linhas		 out number,
			    	   prm_ncolumns	     out DBMS_SQL.VARCHAR2_TABLE,
			    	   prm_objeto		 in  varchar2    default null,
                       prm_chave		 in  varchar2    default null,
		    		   prm_ordem		 in  varchar2    default null,
		    		   prm_screen        in  varchar2    default null,
			    	   prm_limite        in  number      default null,
		    		   prm_referencia    in  number      default 0,
		    		   prm_direcao       in  varchar2    default '>',
                       prm_limite_final  out number,
					   prm_condicao      in varchar2   default 'semelhante',
					   prm_busca         in varchar2   default null,
                       prm_count         in boolean    default false,
					   prm_acumulado     in varchar2 default null,
                       prm_usuario       in varchar2 default null ) return varchar2 as

	cursor crs_colunas is
		select trim(cd_coluna) 	as cd_coluna,
               nm_rotulo	    as nm_rotulo,
               trim(cd_ligacao)	as cd_ligacao,
               trim(tipo)    	as tipo,
			   trim(formula)	as formula,
               trim(tipo_input) as input,
			   nvl(data_type,'NAO_EXISTE') as tipo_column
		  from DATA_COLUNA, all_tab_columns
	 	 where column_name(+) = cd_coluna 
           and table_name(+)  = trim(prm_micro_data)
           and cd_micro_data  = trim(prm_objeto)
         order by ordem, cd_coluna; -- alterado para não prioriar colunas chave 

	ws_colunas	crs_colunas%rowtype;

	cursor crs_tabela is
			select	nm_tabela
			from 	MICRO_DATA
			where	nm_micro_DATA = prm_objeto;

	ws_tabela	crs_tabela%rowtype;

	type generic_cursor is 		ref cursor;

	crs_saida			generic_cursor;

    cursor crs_filtrog(prm_usuario varchar2, prm_tipo varchar2)  is
        select 'FILTROS'            as tp_filtro, 
               rtrim(cd_usuario)	as cd_usuario,
               rtrim(cd_coluna)	    as cd_coluna,
               rtrim(condicao)		as condicao,
               rtrim(conteudo)		as conteudo,
               rtrim(ligacao)		as ligacao
          from FILTROS
         where (cd_usuario in (prm_usuario, 'DWU') or cd_usuario in (select cd_group from gusers_itens where cd_usuario = prm_usuario)) 
           and cd_objeto         = trim(prm_objeto) 
           and st_agrupado       = 'N' 
           and tp_filtro         = 'objeto' 
           and condicao         <> 'NOFLOAT'
           and ( (prm_tipo = 'SOMENTE IN' and condicao = 'IGUAL') or 
                 (prm_tipo = 'SEM IN'     and condicao <> 'IGUAL') 
               ) 
        union all 
        select 'FLOAT FILTER'                        as tp_filtro, 
               trim(cd_usuario)                      as cd_usuario,  
               trim(cd_coluna)                       as cd_coluna,
               decode(instr(trim(conteudo),'$[NOT]'),0,'IGUAL', 'DIFERENTE')  as condicao,
               replace(trim(CONTEUDO), '$[NOT]', '') as conteudo,
               'and'                                 as ligacao
          from FLOAT_FILTER_ITEM
         where (cd_usuario in (prm_usuario, 'DWU') or cd_usuario in (select cd_group from gusers_itens where cd_usuario = prm_usuario))
           and screen      = trim(prm_screen) 
           and cd_coluna in ( select trim(cd_coluna) from data_coluna where cd_micro_data = prm_objeto and nvl(tipo,'.') <> 'VIRTUAL' ) 
           and prm_tipo    = 'SOMENTE IN'
        order by cd_usuario, cd_coluna, condicao, conteudo;

	ws_filtrog	crs_filtrog%rowtype;

	ws_counter       number := 1;
    ws_final         number := 0;
    ws_limite        number := 0;
    ws_coluna        number := 0;
	ws_virgula       char(1);

    ws_linha_inicio  number;
    ws_linha_final   number;

	ws_cursor	     integer;
	ws_linhas	     integer;
    ws_retorno       varchar2(400);
	ws_sql		     varchar2(2000);

	ws_distintos     long;
    ws_distintos_ord long;    
	crlf             VARCHAR2( 2 ):= CHR( 13 ) || CHR( 10 );
	ws_queryoc       VARCHAR2(4000);

    ws_nulo          varchar2(1) := null;

    ws_colunasf      long;
    ws_tcont		 varchar2(500);
    ws_bindn         number;
    ws_conteudo_comp varchar2(1400);
    ws_conteudo_ant  varchar2(800);
    ws_condicao      varchar2(800);
    ws_coluna_ant    varchar2(800);
    ws_condicao_ant  varchar2(80);
    ws_countin       number;
    ws_count         number;
    WS_conteudo      varchar2(1000);
	ws_tipo          varchar2(200);
	ws_chave         varchar2(32000);
	ws_acumulado     varchar2(1400);
    ws_ligacao       varchar2(200);
    ws_busca_dt      date;
    ws_busca         varchar2(200);
    ws_usuario       varchar2(80);
    ws_opttable      varchar2(100);
    ws_formula       varchar2(32000);
    ws_tipo_input    varchar2(200); 
    ws_cd_coluna     varchar2(32000); 
    ws_tp_filtro_ant varchar2(50); 
    ws_direction     varchar2(2000);
    ws_ordem         varchar2(200);
    ws_conta_loop    number := 0;

begin

    ws_usuario := prm_usuario; 
    if ws_usuario is null then 
        ws_usuario := gbl.getUsuario;
    end if;   

    htp.p(ws_nulo);

	ws_distintos	   := ' ';

	open crs_tabela;
	fetch crs_tabela into ws_tabela;
	close crs_tabela;

    ws_opttable := fun.GETPROP (prm_objeto, 'TABELA_FISICA_OBJETO', null, 'DWU', prm_objeto);  -- Busca tabela física do objeto (se foi cadastrado)
    if nvl(ws_opttable,'NA') = 'NA' then 
        ws_opttable := ws_tabela.nm_tabela;
    end if;
    
    ws_opttable := ws_opttable; 

    /*Montagem de colunas*/

	ws_distintos     := '';
    ws_virgula       := '';
    ws_distintos_ord := null;

   
    open crs_colunas;
	loop

        fetch crs_colunas into ws_colunas;
        exit when crs_colunas%notfound;

        -- Tem que existir na tabela ou ser uma coluna cadastrada como VIRTUAL 
        if ws_colunas.tipo_column <> 'NAO_EXISTE' or (ws_colunas.tipo_column = 'NAO_EXISTE' and nvl(ws_colunas.tipo,'NA') = 'VIRTUAL') then  
            ws_coluna   := ws_coluna + 1;
            if ws_colunas.input = 'file' then
                ws_distintos := ws_distintos||ws_virgula||' '''||ws_colunas.nm_rotulo||''' as '||ws_colunas.cd_coluna;
            elsif (ws_colunas.input = 'data' or ws_colunas.input = 'datatime') and ws_colunas.tipo_column = 'DATE' then
                begin
                    ws_distintos := ws_distintos||ws_virgula||' trim(to_char('||ws_colunas.cd_coluna||', ''DD/MM/YYYY HH24:MI'')) as '||ws_colunas.cd_coluna||'';
                exception when others then
                    ws_distintos := ws_distintos||ws_virgula||' '||ws_colunas.cd_coluna||'';
                end;
            elsif ws_colunas.input in ('botao','calculada') then 
                if ws_colunas.formula is null then 
                    ws_distintos := ws_distintos||ws_virgula||' '''||ws_colunas.nm_rotulo||''' as '||ws_colunas.cd_coluna; -- Se não tem fórmula retorna o rótulo/label 
                else 
                    ws_formula := fun.gformula_browser(prm_objeto, ws_colunas.cd_coluna); 
                    ws_distintos := ws_distintos||ws_virgula||' '||ws_formula||' as '||ws_colunas.cd_coluna;
                end if;     
            else
                ws_distintos := ws_distintos||ws_virgula||' '||ws_colunas.cd_coluna||'';
            end if;
            prm_ncolumns(ws_coluna) := ws_colunas.cd_coluna;
            ws_virgula   := ',';
        end if; 
	end loop;
	close crs_colunas;

    -- Inclui algumas colunas para uso na ordenação por descricao, para as colunas com input ligação 
    for a in crs_colunas loop 
        if a.input  in ('ligacao','listboxtd') then
            ws_distintos := ws_distintos||', fun.cdesc('||a.cd_coluna||', '''||a.cd_ligacao||''') as '||a.cd_coluna||'_lig_dsc';
            ws_coluna := ws_coluna+1;
            --prm_ncolumns(ws_coluna) := ws_colunas.cd_coluna||'lig_dsc';
            prm_ncolumns(ws_coluna) := a.cd_coluna||'lig_dsc';
        end if; 
    end loop;     

    -- Filtro de objeto <> igual ( que pode usar um Float Par) 
    -------------------------------------------------------------------------------
    for ws_filtrog in crs_filtrog(ws_usuario,'SEM IN') loop

            -- Retorna substituição do | do texto do parametro, caso exista e tenha sido substituido por #[PIPE]
            if ws_filtrog.conteudo like '%@PIPE@%' then 
                ws_filtrog.conteudo := replace(ws_filtrog.conteudo,'@PIPE@','|');
            end if; 

        ws_tcont := ws_filtrog.conteudo;
        
        if  UPPER(substr(ws_tcont,1,5)) = 'EXEC=' then
            ws_tcont := fun.xexec(ws_tcont, prm_screen);
        end if;
        if  UPPER(substr(ws_tcont,1,8)) = 'SUBEXEC=' then
            ws_tcont := fun.xexec(fun.subpar(ws_tcont, prm_screen, 'N'), prm_screen);
        end if;
        if  substr(ws_tcont,1,2) = '$[' then
            ws_tcont := fun.gparametro(ws_tcont, prm_usuario => ws_usuario);
        end if;
        if  substr(ws_tcont,1,2) = '#[' then
            ws_tcont := fun.ret_var(ws_tcont, ws_usuario);
        end if;

        case ws_filtrog.condicao
            when 'IGUAL'        then ws_condicao := '=';
            when 'DIFERENTE'    then ws_condicao := '<>';
            when 'MAIOR'        then ws_condicao := '>';
            when 'MENOR'        then ws_condicao := '<';
            when 'MAIOROUIGUAL' then ws_condicao := '>=';
            when 'MENOROUIGUAL' then ws_condicao := '<=';
            when 'LIKE'         then ws_condicao := ' like ';
            when 'NOTLIKE'      then ws_condicao := ' not like ';
            else                     ws_condicao := '=';
        end case;
            
            
            
        /*if ws_filtrog.condicao in('LIKE', 'NOTLIKE') then
            ws_conteudo_comp := ws_conteudo_comp||' '||ws_filtrog.cd_coluna||' '||ws_condicao||' ''%'||WS_conteudo||'%'' AND'; 
        else
            ws_conteudo_comp := ws_conteudo_comp||' nvl('||ws_filtrog.cd_coluna||', ''N/A'') '||ws_condicao||' nvl('||WS_conteudo||', ''N/A'') AND';
        end if;*/
            
        if WS_FILTROG.CONDICAO IN('LIKE', 'NOTLIKE') THEN
            WS_CONTEUDO_COMP := WS_CONTEUDO_COMP||' '||WS_FILTROG.CD_COLUNA||' '||WS_CONDICAO||' ''%'||ws_tcont||'%'' AND'; 
        else
            WS_CONTEUDO_COMP := WS_CONTEUDO_COMP||' '||WS_FILTROG.CD_COLUNA||' '||WS_CONDICAO||'  '''||ws_tcont||''' AND';
        end if;

	end loop;
		
	ws_conteudo_comp := substr(ws_conteudo_comp, 1, length(ws_conteudo_comp)-3);

    ws_conteudo_ant := '';
    ws_countin := 0;

    -- Filtro de objeto - somente igual = com clausula IN ( que pode usar um Float Par) 
    -------------------------------------------------------------------------------
    for ws_filtrogin in crs_filtrog(ws_usuario,'SOMENTE IN') loop

        ws_tcont := ws_filtrogin.conteudo;

        if  UPPER(substr(ws_tcont,1,5)) = 'EXEC=' then
            ws_tcont := fun.xexec(ws_tcont, prm_screen);
        end if;
        if  UPPER(substr(ws_tcont,1,8)) = 'SUBEXEC=' then
            ws_tcont := fun.xexec(fun.subpar(ws_tcont, prm_screen, 'N'), prm_screen);
        end if;
        if  substr(ws_tcont,1,2) = '$[' then
            ws_tcont := fun.gparametro(ws_tcont, prm_usuario => ws_usuario);
        end if;
        if  substr(ws_tcont,1,2) = '#[' then
            ws_tcont := fun.ret_var(ws_tcont, ws_usuario);
        end if;        

        if ws_filtrogin.condicao = 'IGUAL' then         
            ws_condicao := 'in';
        else 
            ws_condicao := 'not in';    
        end if;     
        if ws_countin = 0 then
            ws_conteudo_ant  := ' '||ws_filtrogin.cd_coluna||' '||ws_condicao||' ('''||ws_tcont||''' ';
            ws_coluna_ant    := ws_filtrogin.cd_coluna;
            ws_tp_filtro_ant := ws_filtrogin.tp_filtro;
        elsif ws_filtrogin.cd_coluna = ws_coluna_ant and ws_filtrogin.tp_filtro = ws_tp_filtro_ant then
            ws_conteudo_ant := ws_conteudo_ant||', '''||ws_tcont||''' ';
        else
            ws_conteudo_ant  := ws_conteudo_ant||') and '||ws_filtrogin.cd_coluna||' '||ws_condicao||' ('''||ws_tcont||''' ';
            ws_coluna_ant    := ws_filtrogin.cd_coluna;
            ws_tp_filtro_ant := ws_filtrogin.tp_filtro;
        end if;

        ws_countin := ws_countin+1;

	end loop;

    if length(ws_conteudo_ant) > 3 then
        if length(ws_conteudo_comp) > 3 then
            ws_conteudo_comp := ws_conteudo_comp||' and '||ws_conteudo_ant||')';
        else
            ws_conteudo_comp := ws_conteudo_ant||')';
        end if;
    end if;


	-- Busca filtros do BROWSER  	
    --ws_conteudo_comp := NULL;	
	--core.MONTA_FILTRO ( 'SQL_BIND', prm_objeto, prm_screen, prm_micro_data, null, ws_usuario, ws_conteudo_comp) ;  -- Busca os filtros do objeto aplicados ao objeto 
    --ws_conteudo_comp := replace(ws_conteudo_comp,'where','');

    ws_colunasf := ws_distintos||', DWU_ROWID, DWU_ROWNUM ';
    ws_distintos := ws_distintos||', ROWID AS DWU_ROWID ';

    ws_coluna   := ws_coluna + 1;
    prm_ncolumns(ws_coluna) := 'DWU_ROWID';
    ws_coluna   := ws_coluna + 1;
    prm_ncolumns(ws_coluna) := 'DWU_ROWNUM';

    if prm_count = true then
        prm_query_padrao(1) := 'select count(*) as contador '||crlf;
    else
	    prm_query_padrao(1) := 'select * from (select a.*, ROWNUM AS DWU_ROWNUM from ( select /*+ FIRST_ROWS('||nvl(prm_limite, fun.getprop(prm_objeto, 'LINHAS', 'DEFAULT', ws_usuario))||') */ '||ws_distintos||crlf;
	end if;

    prm_query_padrao(2) := 'FROM '||nvl(fun.ret_var('OWNER_TABLE_DATA'),'DWU')||'.'||ws_opttable||' T1 '||crlf||' WHERE ';

    ws_coluna_ant   := 'N/A';
    ws_condicao_ant := 'N/A';

	/* teste de filtro acumulado */
	for i in(select cd_coluna, cd_conteudo, cd_condicao from table((fun.vpipe_par(prm_acumulado))) order by cd_coluna, cd_condicao ) loop

        select cd_ligacao, nvl(tipo,'NORMAL') into ws_ligacao, ws_tipo
          from data_coluna where cd_coluna = i.cd_coluna and cd_micro_data = trim(prm_objeto);

        ws_cd_coluna := i.cd_coluna; 
        if ws_tipo = 'VIRTUAL' then 
            ws_cd_coluna := nvl(fun.gformula_browser(prm_objeto, ws_cd_coluna),ws_cd_coluna); 
        end if; 

        if ((ws_cd_coluna <> ws_coluna_ant or i.cd_condicao <> ws_condicao_ant) and ws_coluna_ant <> 'N/A') or (i.cd_condicao <> 'IGUAL' and ws_coluna_ant <> 'N/A') then
            ws_acumulado := ws_acumulado||') and ';
        end if;

		if ws_cd_coluna = ws_coluna_ant and i.cd_condicao = ws_condicao_ant and i.cd_condicao = 'IGUAL' then
            ws_acumulado := ws_acumulado||','''||UPPER(trim(i.cd_conteudo))||''''||crlf;
        elsif i.cd_condicao = 'IGUAL' then
		    ws_acumulado := ws_acumulado||' upper('||trim(ws_cd_coluna)||') in ('''||UPPER(trim(i.cd_conteudo))||''''||crlf;
        elsif i.cd_condicao = 'MAIOR' then 
            ws_acumulado := ws_acumulado||' (('||trim(ws_cd_coluna)||') >= '||(trim(i.cd_conteudo))||' '||crlf;
        elsif i.cd_condicao = 'NULO' then
            ws_acumulado := ws_acumulado||' '||trim(ws_cd_coluna)||' is null and '||crlf;
        elsif i.cd_condicao = 'NNULO' then
            ws_acumulado := ws_acumulado||' '||trim(ws_cd_coluna)||' is not null and '||crlf;
		elsif i.cd_condicao = 'LIKE' then
            ws_acumulado := ws_acumulado||' (upper('||trim(ws_cd_coluna)||') LIKE (''%'||UPPER(trim(i.cd_conteudo))||'%'') or upper('||trim(ws_cd_coluna)||') LIKE (''%'||fun.cdesc(UPPER(trim(i.cd_conteudo)), ws_ligacao, true)||'%'') '||crlf;
        else
	        ws_acumulado := ws_acumulado||' (upper('||trim(ws_cd_coluna)||') NOT LIKE (''%'||UPPER(trim(i.cd_conteudo))||'%'') and upper('||trim(ws_cd_coluna)||') NOT LIKE (''%'||fun.cdesc(UPPER(trim(i.cd_conteudo)), ws_ligacao, true)||'%'') '||crlf;
		end if;

        ws_coluna_ant   := ws_cd_coluna;
        ws_condicao_ant := i.cd_condicao;

	end loop;

    ws_acumulado := ws_acumulado||')';

	if nvl(ws_acumulado, ')') <> ')' then

        if nvl(ws_conteudo_comp,'N/A') <> 'N/A' then
            prm_query_padrao(3) := substr(trim(ws_acumulado), 0, length(trim(ws_acumulado)))||'aNd'||ws_conteudo_comp;
        else
            prm_query_padrao(3) := substr(trim(ws_acumulado), 0, length(trim(ws_acumulado)));
        end if;

    else

        if length(prm_busca) > 0 then
            if length(ws_conteudo_comp) > 3 then
                ws_conteudo_comp := 'and '||ws_conteudo_comp;
            end if;

            select cd_ligacao, nvl(tipo,'NORMAL'), trim(tipo_input), formula 
              into ws_ligacao, ws_tipo, ws_tipo_input, ws_formula 
              from data_coluna 
             where cd_micro_data = trim(prm_objeto)
               and cd_coluna     = prm_chave; 
            
            if ws_tipo <> 'VIRTUAL'then 
                select min(data_type) into ws_tipo from ALL_TAB_COLUMNS where  TABLE_NAME = ws_opttable and column_name = prm_chave;
            end if;     

            if ws_tipo = 'DATE' then
                begin
                    ws_chave := prm_chave;
                    ws_busca_dt := to_date(prm_busca, 'DD/MM/YYYY');
                exception when others then
                    ws_chave := '(upper('||trim(prm_chave)||'))';
                    ws_busca := UPPER(trim(prm_busca));
                end;

                if prm_condicao = 'igual' then
                    prm_query_padrao(3) := '('||ws_chave||' = '''||ws_busca_dt||''' or '||ws_chave||' = '''||fun.cdesc(ws_busca_dt, ws_ligacao, true)||''') '||ws_conteudo_comp||' '||crlf;
                elsif prm_condicao = 'maior' then 
                    prm_query_padrao(3) := '('||ws_chave||' >= '''||ws_busca_dt||''' or '||ws_chave||' >= '''||fun.cdesc(ws_busca_dt, ws_ligacao, true)||''') '||ws_conteudo_comp||' '||crlf;
                elsif prm_condicao = 'nulo' then
                    prm_query_padrao(3) := ws_chave||' is null '||ws_conteudo_comp||' '||crlf;
                elsif prm_condicao = 'nnulo' then
                    prm_query_padrao(3) := ws_chave||' is not null '||ws_conteudo_comp||' '||crlf;
                elsif prm_condicao = 'semelhante' then
                    prm_query_padrao(3) := '('||ws_chave||' LIKE (''%'||ws_busca_dt||'%'') or '||ws_chave||' LIKE (''%'||fun.cdesc(ws_busca_dt, ws_ligacao, true)||'%'')) '||ws_conteudo_comp||' '||crlf;
                else
                    prm_query_padrao(3) := '('||ws_chave||' NOT LIKE (''%'||ws_busca_dt||'%'') and '||ws_chave||' NOT LIKE (''%'||fun.cdesc(ws_busca_dt, ws_ligacao, true)||'%'')) '||ws_conteudo_comp||' '||crlf;
                end if;

            elsif ws_tipo = 'NUMBER' then

                begin
                    ws_chave := prm_chave;
                    ws_busca := to_number(prm_busca);
                exception when others then
                    ws_chave := prm_chave;
                    ws_busca := prm_busca;
                end;

                if prm_condicao = 'igual' then
                    prm_query_padrao(3) := '('||ws_chave||' = '||ws_busca||' or '||ws_chave||' = '''||fun.cdesc(ws_busca, ws_ligacao, true)||''') '||ws_conteudo_comp||' '||crlf;
                elsif prm_condicao = 'maior' then 
                    prm_query_padrao(3) := '('||ws_chave||' >= '||ws_busca||' or '||ws_chave||' >= '''||fun.cdesc(ws_busca, ws_ligacao, true)||''') '||ws_conteudo_comp||' '||crlf;
                elsif prm_condicao = 'nulo' then
                    prm_query_padrao(3) := ws_chave||' is null '||ws_conteudo_comp||' '||crlf;
                elsif prm_condicao = 'nnulo' then
                    prm_query_padrao(3) := ws_chave||' is not null '||ws_conteudo_comp||' '||crlf;
                elsif prm_condicao = 'semelhante' then
                    prm_query_padrao(3) := '('||ws_chave||' LIKE (''%'||ws_busca||'%'') or '||ws_chave||' LIKE (''%'||fun.cdesc(ws_busca, ws_ligacao, true)||'%'')) '||ws_conteudo_comp||' '||crlf;
                else
                    prm_query_padrao(3) := '('||ws_chave||' NOT LIKE (''%'||ws_busca||'%'') and '||ws_chave||' NOT LIKE (''%'||fun.cdesc(ws_busca, ws_ligacao, true)||'%'')) '||ws_conteudo_comp||' '||crlf;
                end if;

            else

                if ws_tipo = 'VIRTUAL' then
                    ws_chave := nvl(fun.gformula_browser(prm_objeto, prm_chave),''''''); 
                else 
                    ws_chave := prm_chave; 
                end if; 

                ws_chave := '(upper('||trim(ws_chave)||'))';
                ws_busca := UPPER(trim(prm_busca));

                if prm_condicao = 'igual' then
                    prm_query_padrao(3) := '('||ws_chave||' = '''||ws_busca||''' or '||ws_chave||' = '''||fun.cdesc(ws_busca, ws_ligacao, true)||''') '||ws_conteudo_comp||' '||crlf;
                elsif prm_condicao = 'maior' then 
                    prm_query_padrao(3) := '('||ws_chave||' >= '''||ws_busca||''' or '||ws_chave||' >= '''||fun.cdesc(ws_busca, ws_ligacao, true)||''') '||ws_conteudo_comp||' '||crlf;
                elsif prm_condicao = 'nulo' then
                    prm_query_padrao(3) := ws_chave||' is null '||ws_conteudo_comp||' '||crlf;
                elsif prm_condicao = 'nnulo' then
                    prm_query_padrao(3) := ws_chave||' is not null '||ws_conteudo_comp||' '||crlf;
                elsif prm_condicao = 'semelhante' then
                    prm_query_padrao(3) := '('||ws_chave||' LIKE (''%'||ws_busca||'%'') or '||ws_chave||' LIKE (''%'||fun.cdesc(ws_busca, ws_ligacao, true)||'%'')) '||ws_conteudo_comp||' '||crlf;
                else
                    prm_query_padrao(3) := '('||ws_chave||' NOT LIKE (''%'||ws_busca||'%'') and '||ws_chave||' NOT LIKE (''%'||fun.cdesc(ws_busca, ws_ligacao, true)||'%'')) '||ws_conteudo_comp||' '||crlf;
                end if;

            end if;

        else
            if length(ws_conteudo_comp) > 3 then
                prm_query_padrao(3) := ws_conteudo_comp;
            else
                prm_query_padrao(3) := '1=1 ';
            end if;
        end if;

    end if;

    if prm_count = true then
        prm_query_padrao(4) := ''||crlf;
    elsif instr(ws_distintos, '_lig_dsc') > 0 then
        ws_direction := nvl(fun.getprop(prm_objeto, 'DIRECTION', 'DEFAULT', ws_usuario), 1);
        for ws_col in (select column_value as ordem from table(fun.vpipe(ws_direction, ',')))
        loop
            ws_ordem := trim(ws_col.ordem);
            if instr(ws_ordem, ' DESC') > 0 then
                ws_ordem := trim(substr(ws_ordem, 1, instr(ws_ordem, ' ')));
            end if;
            if ws_distintos like '%'||ws_ordem||'_lig_dsc%' then
                if length(ws_ordem) >= 3 then -- se for menor que 3, provavelmente é o número coluna e não o nome, então não considera a coluna de descrição 
                    ws_direction := replace(ws_direction, ws_ordem, ws_ordem||'_lig_dsc');
                end if;     
            end if;
        end loop;
        if ws_direction like '%_lig_dsc%' then
            prm_query_padrao(4) := ' ORDER BY '||ws_direction||crlf;
        else
            prm_query_padrao(4) := ' ORDER BY '||nvl(fun.getprop(prm_objeto, 'DIRECTION', 'DEFAULT', ws_usuario), 1)||crlf;
        end if;
    else
        prm_query_padrao(4) := ' ORDER BY '||nvl(fun.getprop(prm_objeto, 'DIRECTION', 'DEFAULT', ws_usuario), 1)||crlf;
    end if;	

    /************** 
      Era utilizado somente para a direção >>, alterado para utilizar a quantidade de registros passada pelo Backend (Javascript) - 07/02/2022 
    begin
        ws_sql := 'select count(*) from '||ws_tabela.nm_tabela;
 	    ws_cursor := dbms_sql.open_cursor;
	    dbms_sql.parse(ws_cursor, ws_sql, DBMS_SQL.NATIVE);
	    dbms_sql.define_column(ws_cursor, 1, ws_retorno, 200);
	    ws_linhas := dbms_sql.execute(ws_cursor);
	    ws_linhas := dbms_sql.fetch_rows(ws_cursor);
	    dbms_sql.column_value(ws_cursor, 1, ws_retorno);
	    dbms_sql.close_cursor(ws_cursor);
        ws_final         := to_number(ws_retorno);
        prm_limite_final := to_number(ws_retorno);
    exception
        when others then 
            ws_final         := 0;
            prm_limite_final := 0;
    end;
    ********************/ 

 	case
		when PRM_direcao = '>'  then 
            ws_linha_inicio := (prm_referencia+1);
            ws_linha_final  := (prm_referencia+prm_limite);
	 	when prm_direcao = '>>' then 
            -- Aterado para usar os limites passados por parâmetro pelo Frontend - 07/02/2022 
            --ws_linha_inicio := abs((ws_final-(prm_limite-1)));
            --ws_linha_final  := ws_final;
            ws_linha_inicio := (prm_referencia+1);
            ws_linha_final  := (prm_referencia+prm_limite);
		when PRM_direcao = '<'  then
            if  (prm_referencia-prm_limite) < 1 then
                ws_linha_inicio := 1;
                ws_linha_final  := (prm_referencia-1);
            else
                ws_linha_inicio := abs((prm_referencia-prm_limite));
                ws_linha_final  := (prm_referencia-1);
            end if;
		when prm_direcao = '<<' then 
            ws_linha_inicio := 1;
            ws_linha_final  := prm_limite;						   
	else 
		ws_linha_inicio := 1;
        ws_linha_final  := prm_limite;
	end case;

    if prm_count = true then
        prm_query_padrao(5) := '';
    elsif ws_direction is not null and ws_direction like '%_lig_dsc%' then
        prm_query_padrao(5) := ' ) a where rownum <= '||ws_linha_final||' ) where DWU_ROWNUM >= '||ws_linha_inicio||' order by '||ws_direction;
    else
	    prm_query_padrao(5) := ' ) a where rownum <= '||ws_linha_final||' ) where DWU_ROWNUM >= '||ws_linha_inicio||' order by '||nvl(fun.getprop(prm_objeto, 'DIRECTION', 'DEFAULT', ws_usuario), 1);
	end if;
    
    prm_linhas := 5;
    ws_count := 0;

	return ('X');

exception
	when others then
        insert into bi_log_sistema values(sysdate, DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - BIND_DIRECT ', ws_usuario, 'ERRO');
        commit;
	    return ('['||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||']');
end DATA_DIRECT;




FUNCTION CDESC_SQL ( prm_tabela_taux    varchar2 default null,
                     prm_tabela         varchar2 default null,
                     prm_coluna         varchar2 default null,
                     prm_fun_cdesc      varchar2 default null,
                     prm_reverse         boolean default false ) return varchar2 as
    cursor crs_cdesc is
        select nds_tfisica, nds_cd_codigo, nds_cd_empresa, nds_cd_descricao
          from CODIGO_DESCRICAO
         where nds_tabela = upper(prm_tabela_taux);
    --
    cursor crs_tab_columns (p_table_name varchar2, p_column_name varchar2) is 
    select data_type  
      from all_tab_columns
     where owner       = nvl(fun.ret_var('OWNER_TABLE_DATA'),'DWU')
       and table_name  = p_table_name
       and column_name = p_column_name ;
    -- 
    ws_count  number;         
    ws_cdesc        crs_cdesc%rowtype;
    ws_sql          varchar2(2000);
    ws_type_taux    varchar2(100); 
    ws_type_dados   varchar2(100); 
begin

    ws_cdesc.nds_tfisica := null;
    Open  crs_cdesc;
    Fetch crs_cdesc into ws_cdesc;
    close crs_cdesc;

    if ws_cdesc.nds_tfisica is null then 
        ws_sql := 'SEM TAUX';
    else 
        select count(*) into ws_count 
          from all_objects
         where owner       = nvl(fun.ret_var('OWNER_TABLE_DATA'),'DWU')
           and object_name = ws_cdesc.nds_tfisica 
           and object_type in ('TABLE', 'VIEW'); 
        if ws_count = 0 then 
            ws_sql := prm_coluna; 
        else 
            ws_type_taux  := null; 
            ws_type_dados := null; 
            open  crs_tab_columns (ws_cdesc.nds_tfisica, ws_cdesc.nds_cd_codigo) ;
            fetch crs_tab_columns into ws_type_taux; 
            close crs_tab_columns;  
            open  crs_tab_columns (trim(replace(prm_tabela,' T01')),  trim(replace(prm_coluna,'T01.')) ) ;
            fetch crs_tab_columns into ws_type_dados; 
            close crs_tab_columns;  

            if nvl(ws_type_taux,'NA') = nvl(ws_type_dados,'NA') then 

                if prm_reverse = false then
                    ws_sql := '(NVL((select max('||rtrim(ws_cdesc.nds_cd_descricao)||') from '||nvl(fun.ret_var('OWNER_TABLE_DATA'),'DWU')||'.'||ws_cdesc.nds_tfisica||' where '||ws_cdesc.nds_tfisica||'.'||ws_cdesc.nds_cd_codigo||' = '||prm_coluna||'), '||prm_coluna||'))';
                else
                    ws_sql := '(NVL((select max('||rtrim(ws_cdesc.nds_cd_codigo)   ||') from '||nvl(fun.ret_var('OWNER_TABLE_DATA'),'DWU')||'.'||ws_cdesc.nds_tfisica||' where '||ws_cdesc.nds_tfisica||'.'||ws_cdesc.nds_cd_descricao||' = '||prm_coluna||'), '||prm_coluna||'))';
                end if;
            else 
                ws_sql := prm_fun_cdesc; 
            end if;     
        end if;    
    end if;    

    return(ws_sql);

exception when others then
       return('ERRO TAUX');
end CDESC_SQL;


PROCEDURE MONTA_FILTRO ( prm_tipo		    varchar2 default 'SQL',
                         prm_objeto		    varchar2 default null,
                         prm_screen         varchar2 default null,
                         prm_micro_visao    varchar2 default null,
                         prm_condicoes	    varchar2 default null,
                         prm_usuario        varchar2 default null,
                         prm_retorno    out varchar2  ) is 

    type type_filtro is table of crs_filtrog%rowtype  index by pls_integer; 

	reg_filtro                   type_filtro;
    ws_param_visao               varchar2(8000);
    ws_pipe                      varchar2(1); 
	crlf                         varchar2(2) := chr(13) || chr(10);
	ws_cd_coluna_ant             varchar2(8000);
	ws_ligacao_ant               varchar2(8000);
	ws_condicao_ant              varchar2(8000);
    ws_conteudo_ant              varchar2(8000);    
    ws_conteudo_comp             varchar2(32000);
    ws_tipo_ant                  varchar2(8000);
	ws_indice_ant                varchar2(20);
	ws_initin                    varchar2(20);
    ws_cond_param                varchar2(32000);
	ws_tmp_condicao              varchar2(32000);
    ws_cond_aux                  varchar2(32000);
	ws_tcondicao                 varchar2(32000);  
    ws_condicoes                 varchar2(32000);
    ws_binds                     varchar2(32000);
    ws_check_columns             varchar2(32000);
    ws_bindn                     number;    
	ws_noloop                    varchar2(10);
    ws_qt_filtro                 integer; 

    ws_micro_visao               varchar2(200); 
    ws_usuario                   varchar2(100);

    ws_excesso_filtro            exception; 

begin 

    ws_usuario := prm_usuario;
	if ws_usuario is null then 
		ws_usuario :=  gbl.getUsuario;
	end if; 

    ws_micro_visao := prm_micro_visao;
    if ws_micro_visao is null then 
        select max(cd_micro_visao) into ws_micro_visao from ponto_avaliacao where cd_ponto = prm_objeto;  
    end if; 

    -- Parametros/filtro cadastrados direto na visão ( analisar se ainda é utilizado)
    ws_param_visao := null;
    ws_pipe        := null;
    for a in crs_fpar (ws_micro_visao) loop 
        ws_param_visao := ws_param_visao||ws_pipe||a.cd_coluna||'|'||a.cd_parametro;
        ws_pipe        := '|';
    end loop;

    -- Carrega os registro em um array para não deixar o cursor aberto
    open crs_filtrog( prm_condicoes, ws_micro_visao, prm_screen, prm_objeto, ws_usuario, ws_param_visao, null, null, null); 
    loop
        fetch crs_filtrog bulk collect into reg_filtro limit 4000;
        exit when crs_filtrog%NOTFOUND;
    end loop;
    close crs_filtrog;

    ws_cd_coluna_ant  := 'NOCHANGE_ID';
    ws_ligacao_ant    := 'NOCHANGE_ID';
    ws_condicao_ant   := 'NOCHANGE_ID';
    ws_tipo_ant       := 'NOCHANGE_ID';
    ws_indice_ant     := 'NOCHANGE_ID';
    ws_initin         := 'NOINIT';
    ws_tmp_condicao   := '';
    ws_bindn          := 1;
    ws_noloop         := 'NOLOOP';
    ws_cond_aux       := 'where ( ( ';

    FOR a IN 1 .. reg_filtro.COUNT loop

        -- Retorna substituição do | do texto do parametro, caso exista e tenha sido substituido por #[PIPE]
        if reg_filtro(a).conteudo like '%@PIPE@%' then 
            reg_filtro(a).conteudo := replace(reg_filtro(a).conteudo,'@PIPE@','|');
        end if; 

        ws_qt_filtro := ws_qt_filtro + 1 ;
        if  fun.vcalc(reg_filtro(a).cd_coluna, reg_filtro(a).micro_visao) then
            reg_filtro(a).cd_coluna := fun.xcalc(reg_filtro(a).cd_coluna, reg_filtro(a).micro_visao, prm_screen);
        end if;

        ws_noloop := 'LOOP';

        if  prm_objeto = '%NO_BIND%' then
            ws_conteudo_comp := chr(39)||ws_conteudo_ant||chr(39);
        else
            ws_conteudo_comp := ' :b'||trim(to_char(ws_bindn,'0000'));
        end if;

        if  ws_condicao_ant <> 'NOCHANGE_ID' then
            if  (reg_filtro(a).cd_coluna=ws_cd_coluna_ant and reg_filtro(a).condicao=ws_condicao_ant and reg_filtro(a).indice=ws_indice_ant) and ws_condicao_ant in ('IGUAL','DIFERENTE') then -- card 833s 
                if  ws_initin <> 'BEGIN' then
                    ws_cond_aux     := ws_cond_aux||ws_tmp_condicao;
                    ws_tmp_condicao := '';
                end if;
                ws_initin := 'BEGIN';
                ws_tmp_condicao := ws_tmp_condicao||ws_conteudo_comp||',';
                ws_bindn := ws_bindn + 1;
            else
                if  ws_initin = 'BEGIN' then
                    ws_tmp_condicao := ws_tmp_condicao||ws_conteudo_comp||',';
                    ws_tmp_condicao := substr(ws_tmp_condicao,1,length(ws_tmp_condicao)-1);
                    ws_cond_aux     := ws_cond_aux||ws_cd_coluna_ant||fcl.fpdata(ws_condicao_ant,'IGUAL',' IN ',' NOT IN ')||'('||ws_tmp_condicao||') '||ws_ligacao_ant||crlf;
                    ws_tmp_condicao := '';
                    ws_initin := 'NOINIT';
                else
                    ws_cond_aux     := ws_cond_aux||ws_tmp_condicao;
                    ws_tmp_condicao := '';
                    -- if  reg_filtro(a).tipo <> ws_tipo_ant then  -- card 833s 
                    if  reg_filtro(a).indice <> ws_indice_ant then  -- card 833s                   
                        ws_tmp_condicao := ws_tmp_condicao||ws_cd_coluna_ant||ws_tcondicao||ws_conteudo_comp||' ) and ( '||crlf;
                    else
                        ws_tmp_condicao := ws_tmp_condicao||ws_cd_coluna_ant||ws_tcondicao||ws_conteudo_comp||' '||ws_ligacao_ant||' '||crlf;
                    end if;
                end if;
                ws_bindn := ws_bindn + 1;
            end if;
        end if;

        if length(ws_check_columns||ws_pipe||reg_filtro(a).cd_coluna) > 32000 then 
            raise ws_excesso_filtro ;  
        else  
            ws_check_columns := ws_check_columns||ws_pipe||reg_filtro(a).cd_coluna;
        end if;     
        ws_cd_coluna_ant := reg_filtro(a).cd_coluna;
        ws_condicao_ant  := reg_filtro(a).condicao;
        ws_indice_ant    := reg_filtro(a).indice;
        ws_ligacao_ant   := reg_filtro(a).ligacao;
        ws_conteudo_ant  := reg_filtro(a).conteudo;
        ws_tipo_ant      := reg_filtro(a).tipo;

        case ws_condicao_ant
                            when 'IGUAL'        then ws_tcondicao := '=';
                            when 'DIFERENTE'    then ws_tcondicao := '<>';
                            when 'MAIOR'        then ws_tcondicao := '>';
                            when 'MENOR'        then ws_tcondicao := '<';
                            when 'MAIOROUIGUAL' then ws_tcondicao := '>=';
                            when 'MENOROUIGUAL' then ws_tcondicao := '<=';
                            when 'LIKE'         then ws_tcondicao := ' like ';
                            when 'NOTLIKE'      then ws_tcondicao := ' not like ';
                            else                     ws_tcondicao := '***';
        end case;
    end loop;

    -- Ultima linha do loop 
    if  prm_objeto = '%NO_BIND%' then
        ws_conteudo_comp := chr(39)||ws_conteudo_ant||chr(39);
    else
        ws_conteudo_comp := ' :b'||trim(to_char(ws_bindn,'0000'));
    end if;

    if  ws_noloop <> 'NOLOOP' then
        if  ws_initin = 'BEGIN' then
            ws_tmp_condicao := ws_tmp_condicao||ws_conteudo_comp||',';
            ws_tmp_condicao := substr(ws_tmp_condicao,1,length(ws_tmp_condicao)-1);
            ws_cond_aux     := ws_cond_aux||' '||ws_cd_coluna_ant||fcl.fpdata(ws_condicao_ant,'IGUAL',' IN ',' NOT IN ')||'('||ws_tmp_condicao||')'||crlf;
            ws_bindn := ws_bindn + 1;
        else
            ws_tmp_condicao := ws_tmp_condicao||ws_cd_coluna_ant||ws_tcondicao||ws_conteudo_comp||crlf;   
            ws_cond_aux     := ws_cond_aux||' '||ws_tmp_condicao;
            ws_bindn := ws_bindn + 1;
        end if;
    end if;

    if  substr(ws_cond_aux,length(ws_cond_aux)-3, 3) ='( (' then
        ws_cond_aux := substr(ws_cond_aux,1,length(ws_cond_aux)-10)||crlf;
    else
        ws_cond_aux := ws_cond_aux||' ) ) ';
    end if;
    ---------------------------------------------------------
    ws_condicoes := ws_cond_aux; 
    if prm_tipo like '%BIND' then 
        ws_binds     := core.bind_direct(prm_condicoes, null, '', prm_objeto, ws_micro_visao, prm_screen, prm_usuario => ws_usuario ) ;
        ws_binds     := replace(ws_binds,'Binds Carregadas=|','');
        ws_condicoes := fun.replace_binds_clob ( ws_condicoes, ws_binds); 
    end if; 

    if prm_tipo like 'TEXTO%' then 
        ws_condicoes := trim(replace ( ws_condicoes, 'where')); 
    end if; 

    prm_retorno :=  ws_condicoes; 

exception 
    when ws_excesso_filtro then
        insert into bi_log_sistema values(sysdate, 'MONTA_FILTRO - Excesso de filtros, selecione no maximo '||(ws_qt_filtro-1)||' itens nos filtros.', ws_usuario, 'ERRO');
        commit;
        prm_retorno := 'ERRO|Excesso de filtros, selecione no m&aacute;ximo '||ws_qt_filtro||' itens nos filtros.';

end MONTA_FILTRO; 


PROCEDURE MONTA_FILTRO2 ( prm_tipo		    varchar2 default 'SQL',
                          prm_objeto	     varchar2 default null,
                          prm_screen         varchar2 default null,
                          prm_micro_visao    varchar2 default null,
                          prm_condicoes	     varchar2 default null,
                          prm_usuario        varchar2 default null,
                          prm_retorno        out varchar2  ) is 

    type type_filtro is table of crs_filtrog%rowtype  index by pls_integer; 

	reg_filtro                   type_filtro;
    ws_param_visao               varchar2(8000);
    ws_pipe                      varchar2(1); 
	crlf                         varchar2(2) := chr(13) || chr(10);

    ws_filtro                    varchar2(32000);
    ws_cd_coluna                 varchar2(32000); 
    ws_conteudo                  varchar2(32000);
	ws_condicao                  varchar2(32000);  
    ws_binds                     varchar2(32000);
    ws_bindn                     number;    
    ws_igual_ant                 varchar2(1);
    ws_igual_pos                 varchar2(1);
    ws_or_ant                    varchar2(1);
    ws_or_pos                    varchar2(1);
    ws_micro_visao               varchar2(200); 
    ws_usuario                   varchar2(100);

    ws_excesso_filtro            exception; 

begin 

    ws_usuario := prm_usuario;
	if ws_usuario is null then 
		ws_usuario :=  gbl.getUsuario;
	end if; 

    ws_micro_visao := prm_micro_visao;
    if ws_micro_visao is null then 
        select max(cd_micro_visao) into ws_micro_visao 
          from ponto_avaliacao 
         where cd_ponto = prm_objeto;  
    end if; 

    -- Parametros/filtro cadastrados direto na visão ( analisar se ainda é utilizado)
    ws_param_visao := null;
    ws_pipe        := null;
    for a in crs_fpar (ws_micro_visao) loop 
        ws_param_visao := ws_param_visao||ws_pipe||a.cd_coluna||'|'||a.cd_parametro;
        ws_pipe        := '|';
    end loop;

    -- Carrega os registro em um array para não deixar o cursor aberto
    open crs_filtrog( prm_condicoes, ws_micro_visao, prm_screen, prm_objeto, ws_usuario, ws_param_visao, null, null, null); 
    loop
        fetch crs_filtrog bulk collect into reg_filtro limit 4000;
        exit when crs_filtrog%NOTFOUND;
    end loop;
    close crs_filtrog;

    ws_bindn          := 0;
    ws_filtro    := 'where ( ( ';

    FOR a IN 1 .. reg_filtro.COUNT loop

        ws_bindn := ws_bindn + 1;

        -- Retorna substituição do | do texto do parametro, caso exista e tenha sido substituido por #[PIPE]
        if reg_filtro(a).conteudo like '%@PIPE@%' then 
            reg_filtro(a).conteudo := replace(reg_filtro(a).conteudo,'@PIPE@','|');
        end if; 

        ws_cd_coluna := reg_filtro(a).cd_coluna;
        if  fun.vcalc(reg_filtro(a).cd_coluna, reg_filtro(a).micro_visao) then
            ws_cd_coluna := fun.xcalc(reg_filtro(a).cd_coluna, reg_filtro(a).micro_visao, prm_screen);
        end if;

        if  prm_objeto = '%NO_BIND%' then
            ws_conteudo := chr(39)||reg_filtro(a).conteudo||chr(39);
        else
            ws_conteudo := ' :b'||trim(to_char(ws_bindn,'0000'));
        end if;

        case reg_filtro(a).condicao 
            when 'IGUAL'        then ws_condicao := '=';
            when 'DIFERENTE'    then ws_condicao := '<>';
            when 'MAIOR'        then ws_condicao := '>';
            when 'MENOR'        then ws_condicao := '<';
            when 'MAIOROUIGUAL' then ws_condicao := '>=';
            when 'MENOROUIGUAL' then ws_condicao := '<=';
            when 'LIKE'         then ws_condicao := ' like ';
            when 'NOTLIKE'      then ws_condicao := ' not like ';
            else                     ws_condicao := '***';
        end case;

        ws_igual_ant := 'N';
        ws_igual_pos := 'N';
        ws_or_ant    := 'N';
        ws_or_pos    := 'N';

        if reg_filtro(a).condicao in ('IGUAL','DIFERENTE') then 
            if a > 1 and reg_filtro(a).cd_coluna = reg_filtro(a-1).cd_coluna  and 
                         reg_filtro(a).condicao  = reg_filtro(a-1).condicao   and 
                         reg_filtro(a).indice    = reg_filtro(a-1).indice     then 
                ws_igual_ant := 'S';
            end if; 

            if a < reg_filtro.COUNT and reg_filtro(a).cd_coluna = reg_filtro(a+1).cd_coluna  and 
                                        reg_filtro(a).condicao  = reg_filtro(a+1).condicao   and 
                                        reg_filtro(a).indice    = reg_filtro(a+1).indice     then 
                ws_igual_pos := 'S';
            end if; 
        elsif upper(reg_filtro(a).ligacao) = 'OR' then 
            if a > 1 and reg_filtro(a).ligacao = reg_filtro(a-1).ligacao then 
                ws_or_ant := 'S';
            end if ;
            if a < reg_filtro.COUNT  and reg_filtro(a).ligacao = reg_filtro(a+1).ligacao then 
                ws_or_pos := 'S';
            end if ;
        end if; 

        if (ws_igual_ant = 'S' or ws_igual_pos = 'S') then          -- Para condições em forma de IN e NOT IN 
            if ws_igual_ant = 'S'  then 
                ws_filtro := ws_filtro||ws_conteudo;
            else 
                ws_filtro := ws_filtro||ws_cd_coluna||fcl.fpdata(reg_filtro(a).condicao,'IGUAL',' IN ',' NOT IN ')||'('||ws_conteudo;
            end if;     
            
            if ws_igual_pos = 'S' then 
                ws_filtro := ws_filtro||',';
            else 
                ws_filtro := ws_filtro||') '; 
            end if;     
        else 
            if upper(reg_filtro(a).ligacao) = 'OR' and ws_or_ant = 'N' then
                ws_filtro := ws_filtro || ' ( '; 
            end if;    

            ws_filtro := ws_filtro || ws_cd_coluna || ws_condicao || ws_conteudo; 

            if upper(reg_filtro(a).ligacao) = 'OR' and ws_or_pos = 'N' then
                ws_filtro := ws_filtro || ' ) '; 
            end if;    

        end if;     

        -- Coloca a ligação no final da condição 
        if ws_igual_pos <> 'S' then 
            if a = reg_filtro.COUNT then 
                ws_filtro := ws_filtro || ' ) ) '; 
            else 
                if reg_filtro(a).indice <> reg_filtro(a+1).indice then 
                    ws_filtro := ws_filtro || ' ) and ( '||crlf;
                else     
                    ws_filtro := ws_filtro ||' '||reg_filtro(a).ligacao||' ' ;
                end if;     
            end if; 
        end if; 

        if length(ws_filtro) > 32000 then 
            raise ws_excesso_filtro ;  
        end if;     
    end loop;

    ---------------------------------------------------------
    if prm_tipo like '%BIND' then 
        ws_binds     := core.bind_direct(prm_condicoes, null, '', prm_objeto, ws_micro_visao, prm_screen, prm_usuario => ws_usuario ) ;
        ws_binds     := replace(ws_binds,'Binds Carregadas=|','');
        ws_filtro    := fun.replace_binds_clob ( ws_filtro, ws_binds); 
    end if; 

    if prm_tipo like 'TEXTO%' then 
        ws_filtro := trim(replace ( ws_filtro, 'where')); 
    end if; 

    prm_retorno :=  ws_filtro; 

exception 
    when ws_excesso_filtro then
        insert into bi_log_sistema values(sysdate, 'MONTA_FILTRO2 - Excesso de filtros, selecione no maximo '||(ws_bindn-1)||' itens nos filtros.', ws_usuario, 'ERRO');
        commit;
        prm_retorno := 'ERRO|Excesso de filtros, selecione no m&aacute;ximo '||ws_bindn||' itens nos filtros.';

end MONTA_FILTRO2; 


PROCEDURE MONTA_FILTRO_USUARIO ( prm_screen           varchar2 default null,
                                 prm_micro_visao      varchar2 default null,
                                 prm_coluna           varchar2 default null,
                                 prm_coluna_troca     varchar2 default null,
                                 prm_usuario          varchar2 default null,
                                 prm_retorno      out varchar2  ) is 

    type type_filtro is table of crs_filtro_usuario%rowtype  index by pls_integer; 
   	reg_filtro                   type_filtro;

    ws_filtro           varchar2(1000);    
    ws_coluna_formula   varchar2(1000);
    ws_filtro_geral     varchar2(32000);
    ws_condicao         varchar2(30);          
    ws_coluna           varchar2(1000);
    ws_conteudo         varchar2(1000);          
    ws_condicao_ante    varchar2(30);      
    ws_coluna_ante      varchar2(1000);    
    ws_ligacao_ante     varchar2(10);   
    ws_condicao_prox    varchar2(30);   
    ws_coluna_prox      varchar2(1000);   
    ws_usuario          varchar2(100);    
begin

    ws_usuario       := prm_usuario;
	if ws_usuario is null then 
		ws_usuario :=  gbl.getUsuario;
	end if; 

    -- Carrega os registro em um array para não deixar o cursor aberto
    open crs_filtro_usuario( prm_micro_visao, prm_coluna, ws_usuario); 
    loop
        fetch crs_filtro_usuario bulk collect into reg_filtro limit 4000;
        exit when crs_filtro_usuario%NOTFOUND;
    end loop;
    close crs_filtro_usuario;

    for a IN 1 .. reg_filtro.COUNT loop
        if prm_coluna_troca is not null then 
            reg_filtro(a).cd_coluna := prm_coluna_troca;
        else     
            reg_filtro(a).cd_coluna := trim(fun.gformula2(prm_micro_visao, reg_filtro(a).cd_coluna, prm_screen, '', ''));
        end if;     
    end loop;     

    ws_filtro_geral  := null; 
    ws_ligacao_ante  := ''; 
    ws_condicao_ante := 'N/A';
    ws_coluna_ante   := 'N/A';
    ws_condicao_prox := 'N/A';
    ws_coluna_prox   := 'N/A';

    for a IN 1 .. reg_filtro.COUNT loop
        
        ws_filtro         := null;
        ws_condicao_prox  := 'N/A';
        ws_coluna_prox    := 'N/A';
        
        if a < reg_filtro.COUNT then 
            ws_condicao_prox := reg_filtro(a+1).condicao;
            ws_coluna_prox   := reg_filtro(a+1).cd_coluna;
        end if;

        -- Monta condição de IN 
        if reg_filtro(a).condicao = '=' then 
            if ws_condicao_ante = '=' and reg_filtro(a).cd_coluna = ws_coluna_ante then 
                ws_filtro  := ','''||reg_filtro(a).conteudo||''''; -- acrescenta no in 
                if ws_coluna_prox <> reg_filtro(a).cd_coluna or ws_condicao_prox <> '=' then  
                    ws_filtro := ws_filtro ||')'; -- fecha o in 
                end if;     
            elsif ws_condicao_prox = '=' and reg_filtro(a).cd_coluna = ws_coluna_prox then 
                ws_filtro := ' '||ws_ligacao_ante||' '||reg_filtro(a).cd_coluna||' in ('''||reg_filtro(a).conteudo||''''; -- abre o in 
            end if; 
        end if;  

        if ws_filtro is null then 
            ws_filtro := ' '||ws_ligacao_ante||' '||reg_filtro(a).cd_coluna||' '||reg_filtro(a).condicao||' '''||reg_filtro(a).conteudo||'''';        
        end if;     

        ws_filtro_geral := ws_filtro_geral||ws_filtro;        
        ws_ligacao_ante  := reg_filtro(a).ligacao; 
        ws_condicao_ante := reg_filtro(a).condicao;
        ws_coluna_ante   := reg_filtro(a).cd_coluna;
    end loop; 

    if ws_filtro_geral is not null then 
        ws_filtro_geral := '( '||trim(ws_filtro_geral)||' ) '; 
    end if; 
    prm_retorno := ws_filtro_geral; 

end MONTA_FILTRO_USUARIO;


end CORE;
