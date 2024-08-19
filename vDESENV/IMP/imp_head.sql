create or replace package IMP IS
	
	 PROCEDURE IMPORT_TEST ( PRM_ARQUIVO     VARCHAR2 DEFAULT NULL,
	                         PRM_TABELA      VARCHAR2 DEFAULT NULL,
	                        -- PRM_USUARIO     VARCHAR2 DEFAULT 'DWU',
	                         --PRM_COMMA       VARCHAR2 DEFAULT NULL,
	                         --PRM_DECIMAL     VARCHAR2 DEFAULT NULL,
	                         PRM_CABECALHO   VARCHAR2 DEFAULT '0',
	                         PRM_ACAO        VARCHAR2 DEFAULT NULL );

     PROCEDURE IMPORT_XLS ( PRM_ARQUIVO    VARCHAR2 DEFAULT NULL,
	                       PRM_TABELA      VARCHAR2 DEFAULT NULL,
	                       PRM_USUARIO     VARCHAR2 DEFAULT 'DWU',
	                       PRM_COMMA       VARCHAR2 DEFAULT NULL,
	                       PRM_DECIMAL     VARCHAR2 DEFAULT NULL,
                           PRM_CABECALHO   VARCHAR2 DEFAULT '0' );
    
    PROCEDURE MAIN ( PRM_MODELO VARCHAR2 DEFAULT NULL,
                     PRM_TABELA VARCHAR2 DEFAULT NULL);
    
    PROCEDURE IMPORT_CABECALHO ( prm_modelo varchar2 default null,
								 PRM_ARQUIVO   VARCHAR2 DEFAULT NULL, 
		                         PRM_TABELA    VARCHAR2 DEFAULT NULL, 
		                         PRM_CABECALHO VARCHAR2 DEFAULT NULL, 
		                         PRM_ACAO      VARCHAR2 DEFAULT NULL,
		                         PRM_EVENTO    VARCHAR2 DEFAULT NULL,
                                 PRM_ROTINA    VARCHAR2 DEFAULT NULL );
    
    PROCEDURE IMPORT_CHANGE ( prm_modelo  VARCHAR2 DEFAULT NULL,
							  PRM_NUMERO  NUMBER   DEFAULT NULL,
							  PRM_NOME    VARCHAR2 DEFAULT NULL,
							  PRM_DESTINO VARCHAR2 DEFAULT NULL,
							  PRM_TIPO    VARCHAR2 DEFAULT 'varchar2',
							  PRM_TRFS    VARCHAR2 DEFAULT NULL,
							  PRM_replacein    VARCHAR2 DEFAULT NULL,
							  PRM_replaceout    VARCHAR2 DEFAULT NULL,
							  PRM_mascara    VARCHAR2 DEFAULT NULL,
							  PRM_OP      VARCHAR2 DEFAULT NULL );
							  --PRM_ID      NUMBER   DEFAULT NULL );

	procedure importDelete ( prm_modelo varchar2 default null );
    
    PROCEDURE EXECUTENOW ( PRM_COMANDO  VARCHAR2 DEFAULT NULL );

END IMP;
