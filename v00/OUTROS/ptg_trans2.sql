create or replace function ptg_trans2 ( prm_texto in varchar2 ) return varchar2 is
ws_retorno nclob;
begin
    ws_retorno := translate( prm_texto, 'ÁÇÉÍÓÚÂÊÎÔÛÀÈÌÒÙÃÕËÜáçéíóúâêîôûàèìòùãõëü', 'ACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeu');
    return ws_retorno;
exception when others then
    return prm_texto;
end ptg_trans2;