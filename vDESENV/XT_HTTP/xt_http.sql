create or replace package XT_HTTP is
/**
 * Get page as CLOB
 */
  function get_page(pURL varchar2)
    return clob
    IS LANGUAGE JAVA
    name 'org.orasql.xt_http.XT_HTTP.getPage(java.lang.String) return oracle.sql.CLOB';

/**
 * SendMail API
 */
  function doApiPost(urlStr varchar2, apiKey varchar2, usuario varchar2, senha varchar2, corpo varchar2)
    return varchar2
    IS LANGUAGE JAVA
    name 'org.orasql.xt_http.XT_HTTP.doApiPost(java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String) return java.lang.String';

/**
 * SendMail API EnCrypted
 */
  function doApiPostCrypted(urlStr varchar2, secret varchar2, apiKey varchar2, usuario varchar2, senha varchar2, corpo varchar2)
    return varchar2
    IS LANGUAGE JAVA
    name 'org.orasql.xt_http.XT_HTTP.doApiPostCrypted(java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String) return java.lang.String';


/**
 * Get page as varchar2(max=4000 chars)
 */
  function get_string(pURL varchar2)
    return varchar2
    IS LANGUAGE JAVA
    name 'org.orasql.xt_http.XT_HTTP.getString(java.lang.String) return java.lang.String';

end XT_HTTP;