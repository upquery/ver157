------------------------------------------------------------------------------------------------------
-- Utulizado na package  AUX no BI
------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION c2b( P_CLOB IN CLOB )
      RETURN BLOB
IS
  TEMP_BLOB   BLOB;
  DEST_OFFSET NUMBER  := 1;
  SRC_OFFSET  NUMBER  := 1;
  AMOUNT      INTEGER := DBMS_LOB.LOBMAXSIZE;
  BLOB_CSID   NUMBER  := DBMS_LOB.DEFAULT_CSID;
  LANG_CTX    INTEGER := DBMS_LOB.DEFAULT_LANG_CTX;
  WARNING     INTEGER;
BEGIN
 DBMS_LOB.CREATETEMPORARY(LOB_LOC=>TEMP_BLOB, CACHE=>TRUE);

  DBMS_LOB.CONVERTTOBLOB(TEMP_BLOB, P_CLOB, AMOUNT,DEST_OFFSET,SRC_OFFSET,BLOB_CSID,LANG_CTX,WARNING);
  RETURN TEMP_BLOB;
END C2B;