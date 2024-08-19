DECLARE 
 ws_passo varchar2(20); 
BEGIN
    --
    ws_passo := '1'; 
    merge into bi_lista_padrao t1 using 
        (select 'MES' cd_lista, '1'  cd_item, 'Janeiro'   ds_item, 'Jan' ds_abrev, 1  nr_ordem from dual union all 
         select 'MES' cd_lista, '2'  cd_item, 'Fevereiro' ds_item, 'Fev' ds_abrev, 2  nr_ordem from dual union all 
         select 'MES' cd_lista, '3'  cd_item, 'Março'     ds_item, 'Mar' ds_abrev, 3  nr_ordem from dual union all 
         select 'MES' cd_lista, '4'  cd_item, 'Abril'     ds_item, 'Abr' ds_abrev, 4  nr_ordem from dual union all 
         select 'MES' cd_lista, '5'  cd_item, 'Maio'      ds_item, 'Mai' ds_abrev, 5  nr_ordem from dual union all 
         select 'MES' cd_lista, '6'  cd_item, 'Junho'     ds_item, 'Jun' ds_abrev, 6  nr_ordem from dual union all 
         select 'MES' cd_lista, '7'  cd_item, 'Julho'     ds_item, 'Jul' ds_abrev, 7  nr_ordem from dual union all 
         select 'MES' cd_lista, '8'  cd_item, 'Agosto'    ds_item, 'Ago' ds_abrev, 8  nr_ordem from dual union all 
         select 'MES' cd_lista, '9'  cd_item, 'Setembro'  ds_item, 'Set' ds_abrev, 9  nr_ordem from dual union all 
         select 'MES' cd_lista, '10' cd_item, 'Outubro'   ds_item, 'Out' ds_abrev, 10 nr_ordem from dual union all 
         select 'MES' cd_lista, '11' cd_item, 'Novembro'  ds_item, 'Nov' ds_abrev, 11 nr_ordem from dual union all 
         select 'MES' cd_lista, '12' cd_item, 'Dezembro'  ds_item, 'Dez' ds_abrev, 12 nr_ordem from dual union all 
         --
         select 'DIA_MES' cd_lista, '1'  cd_item, '1'   ds_item, '1'  ds_abrev, 1  nr_ordem from dual union all
         select 'DIA_MES' cd_lista, '2'  cd_item, '2'   ds_item, '2'  ds_abrev, 2  nr_ordem from dual union all
         select 'DIA_MES' cd_lista, '3'  cd_item, '3'   ds_item, '3'  ds_abrev, 3  nr_ordem from dual union all
         select 'DIA_MES' cd_lista, '4'  cd_item, '4'   ds_item, '4'  ds_abrev, 4  nr_ordem from dual union all
         select 'DIA_MES' cd_lista, '5'  cd_item, '5'   ds_item, '5'  ds_abrev, 5  nr_ordem from dual union all
         select 'DIA_MES' cd_lista, '6'  cd_item, '6'   ds_item, '6'  ds_abrev, 6  nr_ordem from dual union all
         select 'DIA_MES' cd_lista, '7'  cd_item, '7'   ds_item, '7'  ds_abrev, 7  nr_ordem from dual union all
         select 'DIA_MES' cd_lista, '8'  cd_item, '8'   ds_item, '8'  ds_abrev, 8  nr_ordem from dual union all
         select 'DIA_MES' cd_lista, '9'  cd_item, '9'   ds_item, '9'  ds_abrev, 9  nr_ordem from dual union all
         select 'DIA_MES' cd_lista, '10' cd_item, '10'  ds_item, '10' ds_abrev, 10 nr_ordem from dual union all
         select 'DIA_MES' cd_lista, '11' cd_item, '11'  ds_item, '11' ds_abrev, 11 nr_ordem from dual union all
         select 'DIA_MES' cd_lista, '12' cd_item, '12'  ds_item, '12' ds_abrev, 12 nr_ordem from dual union all
         select 'DIA_MES' cd_lista, '13' cd_item, '13'  ds_item, '13' ds_abrev, 13 nr_ordem from dual union all
         select 'DIA_MES' cd_lista, '14' cd_item, '14'  ds_item, '14' ds_abrev, 14 nr_ordem from dual union all
         select 'DIA_MES' cd_lista, '15' cd_item, '15'  ds_item, '15' ds_abrev, 15 nr_ordem from dual union all
         select 'DIA_MES' cd_lista, '16' cd_item, '16'  ds_item, '16' ds_abrev, 16 nr_ordem from dual union all
         select 'DIA_MES' cd_lista, '17' cd_item, '17'  ds_item, '17' ds_abrev, 17 nr_ordem from dual union all
         select 'DIA_MES' cd_lista, '18' cd_item, '18'  ds_item, '18' ds_abrev, 18 nr_ordem from dual union all
         select 'DIA_MES' cd_lista, '19' cd_item, '19'  ds_item, '19' ds_abrev, 19 nr_ordem from dual union all
         select 'DIA_MES' cd_lista, '20' cd_item, '20'  ds_item, '20' ds_abrev, 20 nr_ordem from dual union all
         select 'DIA_MES' cd_lista, '21' cd_item, '21'  ds_item, '21' ds_abrev, 21 nr_ordem from dual union all
         select 'DIA_MES' cd_lista, '22' cd_item, '22'  ds_item, '22' ds_abrev, 22 nr_ordem from dual union all
         select 'DIA_MES' cd_lista, '23' cd_item, '23'  ds_item, '23' ds_abrev, 23 nr_ordem from dual union all
         select 'DIA_MES' cd_lista, '24' cd_item, '24'  ds_item, '24' ds_abrev, 24 nr_ordem from dual union all
         select 'DIA_MES' cd_lista, '25' cd_item, '25'  ds_item, '25' ds_abrev, 25 nr_ordem from dual union all
         select 'DIA_MES' cd_lista, '26' cd_item, '26'  ds_item, '26' ds_abrev, 26 nr_ordem from dual union all
         select 'DIA_MES' cd_lista, '27' cd_item, '27'  ds_item, '27' ds_abrev, 27 nr_ordem from dual union all
         select 'DIA_MES' cd_lista, '28' cd_item, '28'  ds_item, '28' ds_abrev, 28 nr_ordem from dual union all
         select 'DIA_MES' cd_lista, '29' cd_item, '29'  ds_item, '29' ds_abrev, 29 nr_ordem from dual union all
         select 'DIA_MES' cd_lista, '30' cd_item, '30'  ds_item, '30' ds_abrev, 30 nr_ordem from dual union all
         select 'DIA_MES' cd_lista, '31' cd_item, '31'  ds_item, '31' ds_abrev, 31 nr_ordem from dual union all
         --
         select 'DIA_SEMANA' cd_lista, '1'  cd_item, 'Domingo' ds_item, 'Dom' ds_abrev, 7  nr_ordem from dual union all 
         select 'DIA_SEMANA' cd_lista, '2'  cd_item, 'Segunda' ds_item, 'Seg' ds_abrev, 1  nr_ordem from dual union all 
         select 'DIA_SEMANA' cd_lista, '3'  cd_item, 'Terça'   ds_item, 'Ter' ds_abrev, 2  nr_ordem from dual union all 
         select 'DIA_SEMANA' cd_lista, '4'  cd_item, 'Quarta'  ds_item, 'Qua' ds_abrev, 3  nr_ordem from dual union all 
         select 'DIA_SEMANA' cd_lista, '5'  cd_item, 'Quinta'  ds_item, 'Qui' ds_abrev, 4  nr_ordem from dual union all 
         select 'DIA_SEMANA' cd_lista, '6'  cd_item, 'Sexta'   ds_item, 'Sex' ds_abrev, 5  nr_ordem from dual union all 
         select 'DIA_SEMANA' cd_lista, '7'  cd_item, 'Sábado'  ds_item, 'Sab' ds_abrev, 6  nr_ordem from dual union all 
		 --
         select 'HORA' cd_lista, '0'  cd_item, '00:00h' ds_item, '00:00h' ds_abrev, 0   nr_ordem from dual union all 
         select 'HORA' cd_lista, '1'  cd_item, '01:00h' ds_item, '01:00h' ds_abrev, 1   nr_ordem from dual union all 
         select 'HORA' cd_lista, '2'  cd_item, '02:00h' ds_item, '02:00h' ds_abrev, 2   nr_ordem from dual union all 
         select 'HORA' cd_lista, '3'  cd_item, '03:00h' ds_item, '03:00h' ds_abrev, 3   nr_ordem from dual union all 
         select 'HORA' cd_lista, '4'  cd_item, '04:00h' ds_item, '04:00h' ds_abrev, 4   nr_ordem from dual union all 
         select 'HORA' cd_lista, '5'  cd_item, '05:00h' ds_item, '05:00h' ds_abrev, 5   nr_ordem from dual union all 
         select 'HORA' cd_lista, '6'  cd_item, '06:00h' ds_item, '06:00h' ds_abrev, 6   nr_ordem from dual union all 
         select 'HORA' cd_lista, '7'  cd_item, '07:00h' ds_item, '07:00h' ds_abrev, 7   nr_ordem from dual union all 
         select 'HORA' cd_lista, '8'  cd_item, '08:00h' ds_item, '08:00h' ds_abrev, 8   nr_ordem from dual union all 
         select 'HORA' cd_lista, '9'  cd_item, '09:00h' ds_item, '09:00h' ds_abrev, 9   nr_ordem from dual union all 
         select 'HORA' cd_lista, '10' cd_item, '10:00h' ds_item, '10:00h' ds_abrev, 10  nr_ordem from dual union all 
         select 'HORA' cd_lista, '11' cd_item, '11:00h' ds_item, '11:00h' ds_abrev, 11  nr_ordem from dual union all 
         select 'HORA' cd_lista, '12' cd_item, '12:00h' ds_item, '12:00h' ds_abrev, 12  nr_ordem from dual union all 
         select 'HORA' cd_lista, '13' cd_item, '13:00h' ds_item, '13:00h' ds_abrev, 13  nr_ordem from dual union all 
         select 'HORA' cd_lista, '14' cd_item, '14:00h' ds_item, '14:00h' ds_abrev, 14  nr_ordem from dual union all 
         select 'HORA' cd_lista, '15' cd_item, '15:00h' ds_item, '15:00h' ds_abrev, 15  nr_ordem from dual union all 
         select 'HORA' cd_lista, '16' cd_item, '16:00h' ds_item, '16:00h' ds_abrev, 16  nr_ordem from dual union all 
         select 'HORA' cd_lista, '17' cd_item, '17:00h' ds_item, '17:00h' ds_abrev, 17  nr_ordem from dual union all 
         select 'HORA' cd_lista, '18' cd_item, '18:00h' ds_item, '18:00h' ds_abrev, 18  nr_ordem from dual union all 
         select 'HORA' cd_lista, '19' cd_item, '19:00h' ds_item, '19:00h' ds_abrev, 19  nr_ordem from dual union all 
         select 'HORA' cd_lista, '20' cd_item, '20:00h' ds_item, '20:00h' ds_abrev, 20  nr_ordem from dual union all 
         select 'HORA' cd_lista, '21' cd_item, '21:00h' ds_item, '21:00h' ds_abrev, 21  nr_ordem from dual union all 
         select 'HORA' cd_lista, '22' cd_item, '22:00h' ds_item, '22:00h' ds_abrev, 22  nr_ordem from dual union all 
         select 'HORA' cd_lista, '23' cd_item, '23:00h' ds_item, '23:00h' ds_abrev, 23  nr_ordem from dual union all 
		 --
         select 'MINUTO' cd_lista, '0'  cd_item, '0 Min'  ds_item, '0m'  ds_abrev, 0   nr_ordem from dual union all 		 
         select 'MINUTO' cd_lista, '1'  cd_item, '1 Min'  ds_item, '1m'  ds_abrev, 1   nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '2'  cd_item, '2 Min'  ds_item, '2m'  ds_abrev, 2   nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '3'  cd_item, '3 Min'  ds_item, '3m'  ds_abrev, 3   nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '4'  cd_item, '4 Min'  ds_item, '4m'  ds_abrev, 4   nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '5'  cd_item, '5 Min'  ds_item, '5m'  ds_abrev, 5   nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '6'  cd_item, '6 Min'  ds_item, '6m'  ds_abrev, 6   nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '7'  cd_item, '7 Min'  ds_item, '7m'  ds_abrev, 7   nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '8'  cd_item, '8 Min'  ds_item, '8m'  ds_abrev, 8   nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '9'  cd_item, '9 Min'  ds_item, '9m'  ds_abrev, 9   nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '10' cd_item, '10 Min' ds_item, '10m' ds_abrev, 10  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '11' cd_item, '11 Min' ds_item, '11m' ds_abrev, 11  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '12' cd_item, '12 Min' ds_item, '12m' ds_abrev, 12  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '13' cd_item, '13 Min' ds_item, '13m' ds_abrev, 13  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '14' cd_item, '14 Min' ds_item, '14m' ds_abrev, 14  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '15' cd_item, '15 Min' ds_item, '15m' ds_abrev, 15  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '16' cd_item, '16 Min' ds_item, '16m' ds_abrev, 16  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '17' cd_item, '17 Min' ds_item, '17m' ds_abrev, 17  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '18' cd_item, '18 Min' ds_item, '18m' ds_abrev, 18  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '19' cd_item, '19 Min' ds_item, '19m' ds_abrev, 19  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '20' cd_item, '20 Min' ds_item, '20m' ds_abrev, 20  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '21' cd_item, '21 Min' ds_item, '21m' ds_abrev, 21  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '22' cd_item, '22 Min' ds_item, '22m' ds_abrev, 22  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '23' cd_item, '23 Min' ds_item, '23m' ds_abrev, 23  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '24' cd_item, '24 Min' ds_item, '24m' ds_abrev, 24  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '25' cd_item, '25 Min' ds_item, '25m' ds_abrev, 25  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '26' cd_item, '26 Min' ds_item, '26m' ds_abrev, 26  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '27' cd_item, '27 Min' ds_item, '27m' ds_abrev, 27  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '28' cd_item, '28 Min' ds_item, '28m' ds_abrev, 28  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '29' cd_item, '29 Min' ds_item, '29m' ds_abrev, 29  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '30' cd_item, '30 Min' ds_item, '30m' ds_abrev, 30  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '31' cd_item, '31 Min' ds_item, '31m' ds_abrev, 31  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '32' cd_item, '32 Min' ds_item, '32m' ds_abrev, 32  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '33' cd_item, '33 Min' ds_item, '33m' ds_abrev, 33  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '34' cd_item, '34 Min' ds_item, '34m' ds_abrev, 34  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '35' cd_item, '35 Min' ds_item, '35m' ds_abrev, 35  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '36' cd_item, '36 Min' ds_item, '36m' ds_abrev, 36  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '37' cd_item, '37 Min' ds_item, '37m' ds_abrev, 37  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '38' cd_item, '38 Min' ds_item, '38m' ds_abrev, 38  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '39' cd_item, '39 Min' ds_item, '39m' ds_abrev, 39  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '40' cd_item, '40 Min' ds_item, '40m' ds_abrev, 40  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '41' cd_item, '41 Min' ds_item, '41m' ds_abrev, 41  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '42' cd_item, '42 Min' ds_item, '42m' ds_abrev, 42  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '43' cd_item, '43 Min' ds_item, '43m' ds_abrev, 43  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '44' cd_item, '44 Min' ds_item, '44m' ds_abrev, 44  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '45' cd_item, '45 Min' ds_item, '45m' ds_abrev, 45  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '46' cd_item, '46 Min' ds_item, '46m' ds_abrev, 46  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '47' cd_item, '47 Min' ds_item, '47m' ds_abrev, 47  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '48' cd_item, '48 Min' ds_item, '48m' ds_abrev, 48  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '49' cd_item, '49 Min' ds_item, '49m' ds_abrev, 49  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '50' cd_item, '50 Min' ds_item, '50m' ds_abrev, 50  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '51' cd_item, '51 Min' ds_item, '51m' ds_abrev, 51  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '52' cd_item, '52 Min' ds_item, '52m' ds_abrev, 52  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '53' cd_item, '53 Min' ds_item, '53m' ds_abrev, 53  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '54' cd_item, '54 Min' ds_item, '54m' ds_abrev, 54  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '55' cd_item, '55 Min' ds_item, '55m' ds_abrev, 55  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '56' cd_item, '56 Min' ds_item, '56m' ds_abrev, 56  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '57' cd_item, '57 Min' ds_item, '57m' ds_abrev, 57  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '58' cd_item, '58 Min' ds_item, '58m' ds_abrev, 58  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '59' cd_item, '59 Min' ds_item, '59m' ds_abrev, 59  nr_ordem from dual union all 
         select 'MINUTO' cd_lista, '60' cd_item, '60 Min' ds_item, '60m' ds_abrev, 59  nr_ordem from dual          
         --   
        ) t2 
    on (t1.cd_lista = t2.cd_lista and t1.cd_item = t2.cd_item )  
    when matched then update set t1.ds_item = t2.ds_item, t1.ds_abrev = t2.ds_abrev, t1.nr_ordem = t2.nr_ordem  
    when not matched then insert (cd_lista, cd_item, ds_item, ds_abrev, nr_ordem) values (t2.cd_lista, t2.cd_item, t2.ds_item, t2.ds_abrev, t2.nr_ordem);    
    delete bi_lista_padrao where cd_lista = 'HORA' and cd_item = '24'; 
    commit; 
    --
    ws_passo := '1.1'; 
    merge into bi_lista_padrao t1 using 
        (select 'REPORT_STATUS' cd_lista, 'P'   cd_item, 'Gerando objeto...'         ds_item, 'Gerando objeto'         ds_abrev, 1  nr_ordem from dual union all         
         select 'REPORT_STATUS' cd_lista, 'A'   cd_item, 'Aguardando envio...'       ds_item, 'Aguardando envio'       ds_abrev, 2  nr_ordem from dual union all         
         select 'REPORT_STATUS' cd_lista, 'F'   cd_item, 'Enviado'                   ds_item, 'Enviado'                ds_abrev, 3  nr_ordem from dual union all 
         select 'REPORT_STATUS' cd_lista, 'E'   cd_item, 'Erro enviando'             ds_item, 'Erro envio'             ds_abrev, 4  nr_ordem from dual union all         
         select 'REPORT_STATUS' cd_lista, 'R'   cd_item, 'Enviando...'               ds_item, 'Enviando...'            ds_abrev, 5  nr_ordem from dual union all         
         select 'REPORT_STATUS' cd_lista, 'EF'  cd_item, 'Erro inserindo na fila'    ds_item, 'Erro fila'              ds_abrev, 6  nr_ordem from dual union all
         select 'REPORT_STATUS' cd_lista, 'C'  cd_item,  'Erro enviando (reenviado)' ds_item, 'Erro (reenviado)'       ds_abrev, 7  nr_ordem from dual          
         --   
        ) t2 
    on (t1.cd_lista = t2.cd_lista and t1.cd_item = t2.cd_item )  
    when matched then update set t1.ds_item = t2.ds_item, t1.ds_abrev = t2.ds_abrev, t1.nr_ordem = t2.nr_ordem  
    when not matched then insert (cd_lista, cd_item, ds_item, ds_abrev, nr_ordem) values (t2.cd_lista, t2.cd_item, t2.ds_item, t2.ds_abrev, t2.nr_ordem);    
    commit; 
    --
    ws_passo := '1.2'; 
    merge into bi_lista_padrao t1 using 
        (select 'REPORT_TP_CONTEUDO' cd_lista, 'SCREEN'     cd_item, 'Tela (PDF)'         ds_item, 'Tela (PDF)'          ds_abrev, 1  nr_ordem from dual union all         
         select 'REPORT_TP_CONTEUDO' cd_lista, 'RELATORIO'  cd_item, 'Relatório (EXCEL)'  ds_item, 'Relatório (EXCEL)'   ds_abrev, 2  nr_ordem from dual union all         
         select 'REPORT_TP_CONTEUDO' cd_lista, 'CONSULTA'   cd_item, 'Consulta (PDF)'     ds_item, 'Consulta (PDF)'      ds_abrev, 3  nr_ordem from dual 
        ) t2 
    on (t1.cd_lista = t2.cd_lista and t1.cd_item = t2.cd_item )  
    when matched then update set t1.ds_item = t2.ds_item, t1.ds_abrev = t2.ds_abrev, t1.nr_ordem = t2.nr_ordem  
    when not matched then insert (cd_lista, cd_item, ds_item, ds_abrev, nr_ordem) values (t2.cd_lista, t2.cd_item, t2.ds_item, t2.ds_abrev, t2.nr_ordem);    
    commit; 
    --
    ws_passo := '1.2'; 
    delete bi_lista_padrao where cd_lista = 'ETL_TIPO_EXECUCAO'; 
    merge into bi_lista_padrao t1 using 
        (select 'ETL_TIPO_EXECUCAO' cd_lista, 'INTEGRADOR'     cd_item, 'INTEGRADOR'         ds_item, null ds_abrev, 1  nr_ordem from dual union all
         select 'ETL_TIPO_EXECUCAO' cd_lista, 'INTEGRADOR_FTP' cd_item, 'IMPORTA (ARQUIVO)'  ds_item, null ds_abrev, 2  nr_ordem from dual union all
         select 'ETL_TIPO_EXECUCAO' cd_lista, 'ARQUIVO_SSW'    cd_item, 'IMPORTA (SSW)'      ds_item, null ds_abrev, 3  nr_ordem from dual union all
         select 'ETL_TIPO_EXECUCAO' cd_lista, 'PL/SQL'         cd_item, 'PL/SQL'             ds_item, null ds_abrev, 4  nr_ordem from dual
        ) t2 
    on (t1.cd_lista = t2.cd_lista and t1.cd_item = t2.cd_item )  
    when matched then update set t1.ds_item = t2.ds_item, t1.ds_abrev = t2.ds_abrev, t1.nr_ordem = t2.nr_ordem  
    when not matched then insert (cd_lista, cd_item, ds_item, ds_abrev, nr_ordem) values (t2.cd_lista, t2.cd_item, t2.ds_item, t2.ds_abrev, t2.nr_ordem);    
    commit; 
    delete bi_lista_padrao where cd_lista = 'ETL_TIPO_COMANDO'; 
    merge into bi_lista_padrao t1 using 
        (select 'ETL_TIPO_COMANDO' cd_lista, 'FULL'      cd_item, 'FULL'       ds_item, null ds_abrev, 1  nr_ordem from dual union all
         select 'ETL_TIPO_COMANDO' cd_lista, 'SCHEDULER' cd_item, 'SCHEDULER'  ds_item, null ds_abrev, 2  nr_ordem from dual 
        ) t2 
    on (t1.cd_lista = t2.cd_lista and t1.cd_item = t2.cd_item )  
    when matched then update set t1.ds_item = t2.ds_item, t1.ds_abrev = t2.ds_abrev, t1.nr_ordem = t2.nr_ordem  
    when not matched then insert (cd_lista, cd_item, ds_item, ds_abrev, nr_ordem) values (t2.cd_lista, t2.cd_item, t2.ds_item, t2.ds_abrev, t2.nr_ordem);    
    commit; 

    --
    ws_passo := '1.3'; 
    merge into bi_lista_padrao t1 using 
        (select 'USER_PERMISSAO' cd_lista, 'TELAS_ETL'       cd_item, 'Telas do processo de ETL'     ds_item, null ds_abrev, 1  nr_ordem from dual 
        ) t2 
    on (t1.cd_lista = t2.cd_lista and t1.cd_item = t2.cd_item )  
    when matched then update set t1.ds_item = t2.ds_item, t1.ds_abrev = t2.ds_abrev, t1.nr_ordem = t2.nr_ordem  
    when not matched then insert (cd_lista, cd_item, ds_item, ds_abrev, nr_ordem) values (t2.cd_lista, t2.cd_item, t2.ds_item, t2.ds_abrev, t2.nr_ordem);    
    commit; 
    --
    ws_passo := '1.4'; 
    merge into bi_lista_padrao t1 using 
        (select 'USER_PERMISSAO' cd_lista, 'TELAS_USUARIOS'       cd_item, 'Manutenção de usuários'     ds_item, null ds_abrev, 1  nr_ordem from dual 
        ) t2 
    on (t1.cd_lista = t2.cd_lista and t1.cd_item = t2.cd_item )  
    when matched then update set t1.ds_item = t2.ds_item, t1.ds_abrev = t2.ds_abrev, t1.nr_ordem = t2.nr_ordem  
    when not matched then insert (cd_lista, cd_item, ds_item, ds_abrev, nr_ordem) values (t2.cd_lista, t2.cd_item, t2.ds_item, t2.ds_abrev, t2.nr_ordem);    
    commit; 
    --
    ws_passo := '2'; 
    --
    begin
        DELETE BI_TABELA_SISTEMA;
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('ACTIVE_SESSIONS','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('ADMIN_OPTIONS','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('ALL_SCREENS','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_AUTO_UPDATE','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_AUTO_UPDATE_LOG','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_AUTO_UPDATE_TEMP','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_CIDADES','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_CIDADES_BRASIL','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_CONSTANTES','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_CONSTANTES_BKP','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_CUSTOM_PERMISSAO','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_ESTADOS','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_ESTADOS_BRASIL','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_ESTRUTURA_BANCO','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_INFO_USER','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_LISTA_PADRAO','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_LOG_QUERY','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_LOG_SISTEMA','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_OBJECT_PADRAO','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_OBJECT_PADRAO_BKP','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_OBJECT_QUERY','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_REPORT_FILTER','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_REPORT_LIST','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_REPORT_SCHEDULE','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_SEQUENCE','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_SESSAO','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_TEMA','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_TOKEN','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BLINK_COLUMN','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('CALL_LIST','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('CALL_NAME','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('CHECK_POST','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('CLASSES_FUNCAO','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('CODIGO_DESCRICAO','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('COLUMN_RESTRICTION','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('COLUMNS_QDATA','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('DATA_COLUNA','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('DEFF_LINE','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('DEFF_LINE_FILTRO','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('DEFF_PADRAO','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('DEFINE_MAP','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('DESTAQUE','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('ERR_TXT','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('FAVORITOS','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('FILTROS','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('FILTROS_GERAL','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('FILTROS_NOTIFY','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('FILTROS_OBJETO','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('FLOAT_FILTER_ITEM','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('FONTS','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('GOTO_OBJETO','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('GRUPO','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('GRUPOS_FUNCAO','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('GUSERS','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('GUSERS_ITENS','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('LANGUAGE','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('LINHA_CALCULADA','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('LOG_EVENTOS','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('MASCARAS','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('MICRO_COLUNA','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('MICRO_DATA','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('MICRO_QUBE','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('MICRO_VISAO','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('MICRO_VISAO_FPAR','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('MODELO_CABECALHO','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('MODELO_COLUNA','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('NOTIFY_ME','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('OBJECT_ATTRIB','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('OBJECT_LOCATION','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('OBJECT_PADRAO','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('OBJECT_RESTRICTION','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('OBJETOS','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('PARAMETRO_PADRAO','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('PARAMETRO_USUARIO','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('PENDING_REGS','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('PONTO_AVALIACAO','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('PREFERENCIAS','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('PREFIXO_PADRAO','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('QUERY_STAT','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('ROLES','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('RUNNING_PROCESS','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('RUNNING_SCRIPTS','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('SCRIPT_TO_HTML','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('SENT_SMS','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('SINAIS','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('SINAL_COLUNA','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('TEXT_POST','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('TRADUCAO_COLUNAS','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('TRADUCOES_PASSIVAS','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('USER_NETWALL','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('USER_SCREENS','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('USER_SEQUENCE','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('USUARIOS','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('UTL_TRADUCOES_FEITAS','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('VAR_CONTEUDO','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('VM_DETALHES','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('JAVA_SCRIPTS','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('TAB_DOCUMENTOS','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_AVISOS','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_AVISO_USUARIO','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_BKP_COLUNA_CALCULADA','BKP');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_BKP_ESTRUTURA_BANCO','BKP');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_BKP_FILTROS','BKP');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_CUSTOM_FAV','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_MAPA_MARCADOR','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_PERMISSAO_CUSTOM','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_CUSTOM_FAV_BKP_155','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_OBJECT_PADRAO_BKP_155','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('CSS_STYLE','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('ERR_TXT_CLOB','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('ETL_CARDS','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('ETL_CONEXOES','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('ETL_STEP','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('ETL_STATUS','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('ETL_SCHEDULE','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('UPDATE_AVISOS','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('UPDATE_CLIENTES','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('BI_TABELA_SISTEMA','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('ETL_FILA','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('UPDATE_SEQUENCE','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('UPDATE_SISTEMAS','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('UPDATE_SISTEMAS_CLIENTE','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('UPDATE_SISTEMAS_TEMP','SISTEMA');
        Insert into BI_TABELA_SISTEMA (NM_TABELA,TP_TABELA) values ('UTL_TRANSLATIONS','SISTEMA');
        COMMIT;
    exception
      when others then
        ROLLBACK;  
        INSERT INTO BI_LOG_SISTEMA VALUES (sysdate, 'Erro ao atualizar BI_TABELA_SISTEMA. '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 'DWU', 'ERRO');
        COMMIT;
    end;
exception when others then
    ROLLBACK;  
    INSERT INTO BI_LOG_SISTEMA VALUES (sysdate, 'Erro PASSO ('||ws_passo||'): '||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 'DWU', 'ERRO');
    COMMIT;
END;
