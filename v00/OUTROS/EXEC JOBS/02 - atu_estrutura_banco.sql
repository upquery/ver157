create or replace PROCEDURE ATU_ESTRUTURA_BANCO AS 

    DATA_ATUAL DATE := SYSDATE;
    CAMPO CLOB;

    CURSOR PROCEDURE_FUNCTION_TRIGGER IS 
        SELECT  NAME        AS NOME,
                TYPE        AS TIPO
          FROM  ALL_SOURCE
         WHERE  OWNER = 'DWU'
           AND  TYPE IN ('PROCEDURE','TRIGGER','FUNCTION')
      GROUP BY  NAME,
                TYPE;

    CURSOR VIEW_SISTEMA IS 
        SELECT  VIEW_NAME   AS NOME,
                TEXT        AS TEXTO 
          FROM  ALL_VIEWS 
         WHERE  OWNER = 'DWU'
           AND  TEXT_LENGTH <= 31500
         ORDER BY VIEW_NAME  
         ;

    CURSOR VIEW_MATERIALIZADA IS
        SELECT  MVIEW_NAME  AS NOME,
                QUERY       AS TEXTO
          FROM  ALL_MVIEWS
         WHERE  OWNER = 'DWU';

VL_ID          NUMBER;
id_loop number := 0;
DT_HR_INICIO DATE;
WS_ID_ALERT   NUMBER;
WS_TABELAS VARCHAR2(100);
err varchar(500);

BEGIN

DT_HR_INICIO := SYSDATE;
WS_ID_ALERT  := NULL; 
WS_TABELAS   := 'BI_BKP_ESTRUTURA_BANCO|BI_BKP_COLUNA_CALCULADA|BI_BKP_FILTROS';   

     DWU.SCH.ALERT_ONLINE(WS_ID_ALERT, 'ATU_ESTRUTURA_BANCO', DT_HR_INICIO, NULL,NULL,'ATUALIZANDO','', 'REGISTRO', 'N', WS_TABELAS); 


    FOR OBJETO IN PROCEDURE_FUNCTION_TRIGGER
        LOOP

            FOR TES IN (SELECT * FROM ALL_SOURCE WHERE NAME = OBJETO.NOME AND OWNER = 'DWU' ORDER BY LINE ASC)
                LOOP

                    CAMPO := CAMPO || TES.TEXT;

                END LOOP;
            err :=  OBJETO.TIPO||' '||OBJETO.NOME ;  
            INSERT /*+ APPEND_VALUES */ INTO BI_BKP_ESTRUTURA_BANCO VALUES (SYSDATE,OBJETO.TIPO,OBJETO.NOME,CAMPO);
            COMMIT;
            CAMPO := '';

        END LOOP;

    FOR TES IN VIEW_SISTEMA
        LOOP

            err :=  'VIEW'||' '||tes.NOME ; 
            CAMPO := CAMPO || TES.TEXTO;
            INSERT /*+ APPEND_VALUES */ INTO BI_BKP_ESTRUTURA_BANCO VALUES (DATA_ATUAL,'VIEW',TES.NOME,CAMPO);
            COMMIT;
            CAMPO := '';
        END LOOP;

    -- VIEWS MATERIALIZADAS
    FOR TES IN VIEW_MATERIALIZADA
        LOOP

            CAMPO := CAMPO || TES.TEXTO;
            err :=  'VIEW MATERIALIZADA'||' '||tes.NOME ;  

            INSERT /*+ APPEND_VALUES */ INTO BI_BKP_ESTRUTURA_BANCO VALUES (DATA_ATUAL,'VIEW MATERIALIZADA',TES.NOME,CAMPO);
            COMMIT;
            CAMPO := '';

        END LOOP;

    -- SALVA AS COLUNAS CALCULADAS
    INSERT /*+ APPEND_VALUES */ INTO BI_BKP_COLUNA_CALCULADA
        SELECT  DATA_ATUAL AS DATA,
                CD_MICRO_VISAO,
                CD_COLUNA,
                NM_ROTULO,
                ST_AGRUPADOR,
                NM_MASCARA,
                CD_LIGACAO,
                NM_UNIDADE,
                FORMULA,
                HINT,
                FLEXCOL
          FROM  MICRO_COLUNA
         WHERE  TIPO = 'C' ;
    COMMIT;

    -- SALVA TODOS OS FILTROS DE USUÁRIOS, TELAS E OBJETOS.
    INSERT /*+ APPEND_VALUES */ INTO BI_BKP_FILTROS
        SELECT  DATA_ATUAL          AS DATA,
                CD_USUARIO,
                CD_OBJETO,
                MICRO_VISAO,
                CD_COLUNA,
                CONDICAO,
                CONTEUDO,
                LIGACAO,
                ST_AGRUPADO,
                'FILTROS_OBJETO'    AS TIPO
          FROM  FILTROS_OBJETO

        UNION ALL

        SELECT  DATA_ATUAL      AS DATA,
                CD_USUARIO,
                NULL            AS CD_OBJETO,
                MICRO_VISAO,
                CD_COLUNA,
                CONDICAO,
                CONTEUDO,
                LIGACAO,
                ST_AGRUPADO,
                'FILTROS_GERAL' AS TIPO
           FROM  FILTROS_GERAL;
    COMMIT;   

  DWU.SCH.ALERT_ONLINE(WS_ID_ALERT, 'ATU_ESTRUTURA_BANCO', DT_HR_INICIO, SYSDATE,NULL,'FINALIZADO','', 'REGISTRO', 'N', WS_TABELAS); 


    exception when others then
    DWU.SCH.ALERT_ONLINE(WS_ID_ALERT, 'ATU_ESTRUTURA_BANCO', DT_HR_INICIO, SYSDATE,NULL,'ERRO', DBMS_UTILITY.FORMAT_ERROR_STACK||'-'||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 'ENVIO', 'N', WS_TABELAS); 
    insert into err_txt values (SYSDATE||' - '||TO_CHAR('HH24:MI:SS')|| ' - ' || err||' - '|| DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||' - ATU_ESTRUTURA_BANCO');
    commit;
END;