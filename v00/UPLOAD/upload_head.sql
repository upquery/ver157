-- >>>>>>>-------------------------------------------------------------
-- >>>>>>> Aplicação: Upload
-- >>>>>>> Por:		Upquery Tec
-- >>>>>>> Data:	18/04/12
-- >>>>>>> Pacote:	Upload
-- >>>>>>>-------------------------------------------------------------

create or replace package upload is

	procedure main (prm_alternativo varchar2 default null);
	
	PROCEDURE upload (arquivo  IN  VARCHAR2, prm_usuario varchar2 default null, prm_nm_arquivo varchar2 default null);

    Procedure Download;

	Procedure Download (arquivo in varchar2);
	
end upload;
