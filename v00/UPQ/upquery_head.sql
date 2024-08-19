-- >>>>>>>-------------------------------------------------------------
-- >>>>>>> Aplicação:	Kernel Package
-- >>>>>>> Por:		Luiz Fabiano Santos
-- >>>>>>> Data:	06/09/2009
-- >>>>>>> Pacote:	UpQuery
-- >>>>>>>-------------------------------------------------------------
-- >>>>>>>-------------------------------------------------------------
-- >>>>>>> Pacote Central
-- >>>>>>>-------------------------------------------------------------
create or replace package UpQuery is

procedure main (    prm_parametros varchar2 default null,
					prm_micro_visao  	char default null,
					prm_coluna	 	char default null,
					prm_agrupador	 	char default null,
					prm_rp		 	char default 'ROLL',
					prm_colup	 	char default null,
					prm_comando      	char default 'MOUNT',
					prm_mode	 	char default 'NO',
					prm_objid	 	char default null,
					prm_screen		char default 'DEFAULT',
					prm_posx		char default null,
					prm_posy		char default null,
					prm_ccount		char default '0',
					prm_drill		char default 'N',
					prm_ordem		char default '0',
					prm_zindex		char default 'auto',
					prm_track       varchar2 default null,
					prm_objeton  varchar2 default null,
					prm_self     varchar2 default null,
					prm_dashboard varchar2 default 'false' );

procedure direct (  prm_usuario  varchar2 default null,
					prm_password varchar2 default null );

procedure subquery ( prm_objid 	varchar2 default null,
            prm_parametros 		varchar2 default '1|1',
			prm_micro_visao  	varchar2 default null,
			prm_coluna	 		varchar2 default null,
			prm_agrupador	 	varchar2 default null,
			prm_rp		 		varchar2 default 'GROUP',
			prm_colup	 		varchar2 default null,
			prm_screen			varchar2 default 'DEFAULT',
			prm_ccount			char default '0',
			prm_drill			char default 'N',
			prm_ordem			number default 1,
			prm_self     		varchar2 default null,
			prm_usuario			varchar2 default null );
			

end UpQuery;
