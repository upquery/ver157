import cx_Oracle, sys

ws_user        = sys.argv[1]
ws_password    = sys.argv[2]
ws_dns         = sys.argv[3]
ws_pasta       = 'web/'

#  sql_update     = "begin update dwup.tab_documentos set blob_content = :1, last_updated = sysdate where usuario = 'DWU' and name = :2; commit; end;" 

sql_update     = "update tab_documentos set blob_content = :0, doc_size = :2, last_updated = sysdate where usuario = 'DWU' and name = :3 " 

print(' ')
print('Uploading arquivos MIN para base <'+ ws_user + '.' + ws_dns + '> ... ')
print('   default-min.js   ')
print('   default-min.css  ')
print('   bro.css          ')

with open (ws_pasta + 'default-min.js',  'rb') as file: blob_file_js  = file.read()
with open (ws_pasta + 'default-min.css', 'rb') as file: blob_file_css = file.read()
with open (ws_pasta + 'bro.css',         'rb') as file: blob_file_bro = file.read()

con = cx_Oracle.connect(user=ws_user,password=ws_password, dsn=ws_dns,encoding="UTF-8")
cur = con.cursor()
cur.execute(sql_update, (blob_file_js,  len(blob_file_js),  'default-min.js'))
cur.execute(sql_update, (blob_file_css, len(blob_file_css), 'default-min.css'))
cur.execute(sql_update, (blob_file_bro, len(blob_file_bro), 'bro.css'))

cur.close()

con.commit()
con.close()
