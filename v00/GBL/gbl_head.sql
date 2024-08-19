create or replace package gbl as

    /***** 
    * package de variaveis globais 
    * 20/04/2020
    **********/

    function getUsuario return varchar2;

    procedure setUsuario ( prm_usuario varchar2 default null,
                           prm_mimic   varchar2 default null );

    function getNivel ( prm_usuario varchar2 default null ) return varchar2;
    
    function getNivelUpquery ( prm_usuario varchar2 default null ) return varchar2 ;

    --function setNivel ( prm_usuario varchar2 ) return varchar2;

    procedure getToken ( prm_usuario varchar2, prm_screen varchar2 default null );

    function retToken ( prm_usuario varchar2, prm_screen varchar2 default null ) return varchar2;

    function getVersion return varchar2;

    function getSistema return varchar2;

    function getLang return varchar2;

end gbl;
/
