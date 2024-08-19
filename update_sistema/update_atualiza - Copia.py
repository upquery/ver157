import cx_Oracle, sys

ws_sistema     = 'BI'
ws_versao      = '1.5.7'
ws_pasta_fonte = '..\\v00' 
ws_pasta_plb   = '..\\..\\PLB\\v00' 
ws_user        = 'dwu'
ws_password    = '2iGh952aSUL1'
ws_dsn         = 'UPQ_DOC'

ws_tp_atualiza = sys.argv[1]

if sys.argv[1] == 'SISTEMA' or sys.argv[1] == 'SISTEMA_CHECK': 
    ws_arquivos = [ ['PKG',  'etl'                   , ws_pasta_plb + '\\etl\\'                      ,'N'],
                    ['PKG',  'bro'                   , ws_pasta_plb + '\\bro\\'                      ,'N'],
                    ['PKG',  'com'                   , ws_pasta_plb + '\\com\\'                      ,'N'],
                    ['PKG',  'fcl'                   , ws_pasta_plb + '\\fcl\\'                      ,'N'],
                    ['PKG',  'fun'                   , ws_pasta_plb + '\\fun\\'                      ,'N'],
                    ['PKG',  'gbl'                   , ws_pasta_plb + '\\gbl\\'                      ,'N'],
                    ['PKG',  'imp'                   , ws_pasta_plb + '\\imp\\'                      ,'N'],
                    ['PKG',  'obj'                   , ws_pasta_plb + '\\obj\\'                      ,'N'],
                    ['PKG',  'sch'                   , ws_pasta_plb + '\\sch\\'                      ,'N'],
                    ['PKG',  'upquery'               , ws_pasta_plb + '\\upq\\'                      ,'N'],
                    ['PKG',  'upd'                   , ws_pasta_plb + '\\upd\\'                      ,'N'],
                    ['PKG',  'core'                  , ws_pasta_plb + '\\core\\'                     ,'N'], 
                    ['PKG',  'upload'                , ws_pasta_plb + '\\upload\\'                   ,'N'],
                    ['PKG',  'as_read'               , ws_pasta_plb + '\\as_read\\'                  ,'N'],                                        
				    ['PKG',  'up_rel'                , '..\\..\\..\\up_rel\\up_rel\\1.3.10\\'        ,'N'], 
				    ['PKG',  'aux'                   , '..\\..\\..\\auxi\\auxi\\ver1.5\\'            ,'N'],

				    ['ARQ',  'default-min.js'        , ws_pasta_plb + '\\web\\'                             ,'N'],
                    ['ARQ',  'calendar.js'           , ws_pasta_fonte + '\\web\\'                           ,'N'],
                    ['ARQ',  'vanilla-masker.js'     , '..\\..\\..\\plugins\\'                              ,'N'],                
				    ['ARQ',  'xlsx.mini.min.js'      , '..\\..\\..\\plugins\\'                              ,'N'],
                    ['ARQ',  'echarts.5.1.js'        , '..\\..\\..\\plugins\\echarts\\'                     ,'N'],
                    ['ARQ',  'pell.min.js'           , '..\\..\\..\\plugins\\pell\\dist\\'                  ,'N'],
                    ['ARQ',  'qrcode.min.js'         , '..\\..\\..\\plugins\\qrcodejs\\'                    ,'N'],

                    ['ARQ',  'default-min.css'       , ws_pasta_plb   + '\\web\\'                           ,'N'],
                    ['ARQ',  'bro.css'               , ws_pasta_fonte + '\\web\\'                           ,'N'],                
                    ['ARQ',  'dark.css'              , ws_pasta_fonte + '\\web\\temas\\'                    ,'N'],                
                    ['ARQ',  'evergreen.css'         , ws_pasta_fonte + '\\web\\temas\\'                    ,'N'],
                    ['ARQ',  'florest.css'           , ws_pasta_fonte + '\\web\\temas\\'                    ,'N'],
                    ['ARQ',  'ideativo.css'          , ws_pasta_fonte + '\\web\\temas\\'                    ,'N'],
                    ['ARQ',  'pell.min.css'          , '..\\..\\..\\plugins\\pell\\dist\\'                  ,'N'],                                

    				['ARQ',  'padroes_todos.sql'     , '..\\update_scripts\\'                               ,'N'],
	    			['ARQ',  'constantes_todos.sql'  , '..\\update_scripts\\'                               ,'N'],
                    ['ARQ',  'var_conteudo.sql'      , '..\\update_scripts\\'                               ,'N'],                    
                    ['ARQ',  'lista_padrao.sql'      , '..\\update_scripts\\'                               ,'N'],

                    ['ARQ',  'plsql_versao1.sql'     , '..\\update_scripts\\'                               ,'N'],
                    ['ARQ',  'plsql_versao2.sql'     , '..\\update_scripts\\'                               ,'N'],

                    ['ARQ',  'manut_select.sql'      , '..\\update_scripts\\manut\\'                        ,'N'],
                    ['ARQ',  'manut_atu.sql'         , '..\\update_scripts\\manut\\'                        ,'N'],                    
                    ['ARQ',  'manut_update_upd.sql'  , '..\\update_scripts\\manut\\'                        ,'N'],
                    ['ARQ',  'manut_update_sis.sql'  , '..\\update_scripts\\manut\\'                        ,'N'],
                    ['ARQ',  'manut_update_cid.sql'  , '..\\update_scripts\\manut\\'                        ,'N'],
                    
                    ['ARQ',  'ptg_trans2.sql'        , ws_pasta_fonte + '\\outros\\'                        ,'N'],
                    ['ARQ',  'send_report.sql'       , ws_pasta_fonte + '\\outros\\'                        ,'N']

                  ] 

if sys.argv[1] == 'IMAGENS' or sys.argv[1] == 'IMAGENS_CHECK': 
    ws_arquivos = [ ['ARQ', 'logo_upquery.webp'       , '..\\imagens\\'                    ,'N'],
                    ['ARQ', 'logo_upquery.jpg'        , '..\\imagens\\'                    ,'N'],
                    ['ARQ', 'bg.webp'                 , '..\\imagens\\'                    ,'N'],
                    ['ARQ', 'bg.jpg'                  , '..\\imagens\\'                    ,'N'],
                    ['ARQ', 'folder.png'              , '..\\imagens\\'                    ,'N'],
                    ['ARQ', 'fundo_login.webp'        , '..\\imagens\\'                    ,'N'],
                    ['ARQ', 'ipad.png'                , '..\\imagens\\'                    ,'N'],
                    ['ARQ', 'link.svg'                , '..\\imagens\\'                    ,'N'],
                    ['ARQ', 'lupe.png'                , '..\\imagens\\'                    ,'N'],
                    ['ARQ', 'sinchronize.png'         , '..\\imagens\\'                    ,'N'],
                    ['ARQ', 'unlock.svg'              , '..\\imagens\\'                    ,'N'],
                    ['ARQ', 'alteracao_lapis.svg'     , '..\\imagens\\'                    ,'N'],
                    ['ARQ', 'arrow_new.svg'           , '..\\imagens\\'                    ,'N'],
                    ['ARQ', 'upload.png'              , '..\\imagens\\'                    ,'N'],
                    ['ARQ', 'filter_donut.png'        , '..\\imagens\\'                    ,'N'],
                    ['ARQ', 'frame.png'               , '..\\imagens\\'                    ,'N'],
                    ['ARQ', 'ind1_1.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind1_2.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind1_3.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind1_4.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind1_5.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind2_1.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind2_2.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind2_3.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind2_4.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind2_5.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind3_1.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind3_2.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind3_3.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind3_4.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind3_5.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind4_1.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind4_2.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind4_3.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind4_4.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind4_5.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind5_1.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind5_2.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind5_3.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind5_4.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind5_5.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind6_1.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind6_2.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind6_3.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind6_4.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind6_5.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind7_1.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind7_2.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind7_3.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind7_4.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind7_5.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind8_1.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind8_2.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind8_3.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind8_4.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind8_5.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind9_1.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind9_2.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind9_3.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind9_4.png'              , '..\\imagens\\marcadores\\'        ,'N'],
                    ['ARQ', 'ind9_5.png'              , '..\\imagens\\marcadores\\'        ,'N']
                  ]    				



con = cx_Oracle.connect(user=ws_user,password=ws_password, dsn=ws_dsn,encoding="UTF-8")
cur = con.cursor()

print(' ')
if sys.argv[1] == 'SISTEMA_CHECK' or sys.argv[1] == 'IMAGENS_CHECK': 
    print('--- CHECK alterações <' + sys.argv[1] + '> - Versao ' + ws_versao + ' ---')
else: 
    print('--- Atualizando <' + sys.argv[1] + '> - Versao ' + ws_versao + ' ---')        
print(' ')


print('    - Carregando arquivos para o Oracle ...', end='')
cur.execute('BEGIN delete update_sistemas_temp; commit; END;')
inst_blob = 'insert into update_sistemas_temp (cd_sistema, cd_versao, nm_arquivo, conteudo_blob, id_forca_atualizacao) values (:1, :2, upper(:3), :4, :5)'

ws_qt_obj = 0 
ws_ext = ''
for ws_arq in ws_arquivos:
    if ws_arq[0] == 'PKG':
        ws_qt_obj = ws_qt_obj + 2
        ws_nm_arq = ws_arq[1]; 
        if ws_arq[1] == 'aux':
            ws_nm_arq = 'auxi'
        ws_ext = '.plb'
        # head 
        with open (ws_arq[2] + ws_nm_arq + '_head' + ws_ext,  'rb') as file: blob_file = file.read()
        cur.execute(inst_blob, (ws_sistema, ws_versao, ws_arq[1] + '_head' + ws_ext, blob_file, ws_arq[3]))
        # Body 
        with open (ws_arq[2] + ws_nm_arq + ws_ext, 'rb') as file: blob_file = file.read()
        cur.execute(inst_blob, (ws_sistema, ws_versao, ws_arq[1] + ws_ext, blob_file, ws_arq[3]))
    else:
        ws_qt_obj = ws_qt_obj + 1
        with open (ws_arq[2] + ws_arq[1], 'rb') as file: blob_file = file.read()
        cur.execute(inst_blob, (ws_sistema, ws_versao, ws_arq[1], blob_file, ws_arq[3]))

print('   Objetos carregados : ' + str(ws_qt_obj))



# Executa a procedure que importa para a tabela de auto update (update_sistemas)

if sys.argv[1] == 'SISTEMA_CHECK' or sys.argv[1] == 'IMAGENS_CHECK': 
    print('    - Verificando Alterações ...     ', end='')    
else:     
    print('    - Atualizando UPDATE_SISTEMAS ...', end='')

cur.execute('begin ADM_UPD.atualiza_objetos(:1, :2, :3); end;', (ws_sistema, ws_versao, ws_tp_atualiza))
cur.execute("select count(*) from update_sistemas_temp where nvl(id_atualizado,'E') ='E' ") 
res = cur.fetchone()
ws_qt_erro = res[0]

cur.execute("select nvl(tp_objeto,'N/A'), nvl(nm_objeto,'N/A'), nm_arquivo, nvl(ds_erro,'N/A') from update_sistemas_temp where nvl(id_atualizado,'E') in ('S','E') order by substr(tp_objeto,1,7), 2 ") 
res = cur.fetchall()
print('         Objetos alterados  : ' + str(cur.rowcount-ws_qt_erro) )
print('                                              Objetos com erro   : ' + str(ws_qt_erro))
print(' ')

for a in res:
    print('             ' + a[0] +  ' - ' + a[1] + ' - ' + a[2])
    if a[3] != 'N/A':  
        print('             Erro: ' + a[3] )


print(' ')

if sys.argv[1] == 'SISTEMA_CHECK' or sys.argv[1] == 'IMAGENS_CHECK': 
    print('--- FIM --- ATENÇÃO! Os objetos não foram atualizados, somente checados. ---')
else: 
    print('--- FIM ---')

cur.close()
con.commit()
con.close()