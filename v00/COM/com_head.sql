create or replace package COM as

    procedure modal ( prm_id number );

	procedure report;

	procedure addreport ( prm_usuario  varchar2 default null,
					      prm_assunto  varchar2 default null,
						  prm_msg      varchar2 default null,
						  prm_objeto   varchar2 default null,
						  prm_email    varchar2 default null,
						  prm_id_anterior varchar2 default null);

	procedure deletereport ( prm_id number );

	procedure updatereport ( prm_id number,
							 prm_coluna varchar2 default null,
							 prm_valor  clob );

	procedure reportschedule (  prm_id varchar2 default null );

	procedure addreportschedule ( prm_id number, 
								  prm_semana varchar2, 
								  prm_dia_mes varchar2,
								  prm_mes varchar2, 
								  prm_hora varchar2, 
								  prm_quarter varchar2 );

	procedure deletereportschedule ( prm_id number );

	procedure updatereportschedule ( prm_id     number,
                         		 	 prm_coluna varchar2 default null,
						 		     prm_valor  varchar2 default null );

	procedure reportfilter ( prm_report varchar2 default null );

	procedure addreportfilter ( prm_report   varchar2, 
								prm_usuario  varchar2,
								prm_visao    varchar2,
								prm_coluna   varchar2,
								prm_condicao varchar2,
								prm_conteudo varchar2 );

	procedure updatereportfilter ( prm_filter number, 
								   prm_campo  varchar2 default null,
								   prm_valor  varchar2 default null );

	procedure deletereportfilter ( prm_filter number );

	procedure reportLog (  prm_id varchar2 default null );	

	procedure reportexec;

	procedure checkFila; 

	procedure sendReport( prm_chamada    varchar2 default 'BI', 
						  prm_id_report  varchar2); 
	
	procedure geraRelatorio( prm_id_report       number, 
						 	 prm_id_report_fila  varchar2,
						 	 prm_usuario         varchar2 ) ;

	procedure geraConsulta ( prm_id_report       number, 
							 prm_id_report_fila  varchar2,
							 prm_usuario         varchar2 ) ; 


end COM;
