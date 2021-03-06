SELECT A.OWNER, A.CONSTRAINT_NAME, A.CONSTRAINT_TYPE, A.TABLE_NAME, A.R_CONSTRAINT_NAME, B.TABLE_NAME
FROM   DBA_CONSTRAINTS A, DBA_CONSTRAINTS B
WHERE  A.CONSTRAINT_TYPE = 'R'
AND    A.R_CONSTRAINT_NAME = B.CONSTRAINT_NAME
AND    A.TABLE_NAME IN (SELECT ONAME FROM DBA_REPOBJECT WHERE TYPE = 'TABLE')
/
