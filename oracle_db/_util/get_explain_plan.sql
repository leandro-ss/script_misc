
-- Gera plano de execu��o para uma query
EXPLAIN PLAN FOR
SELECT ...

-- Obtem o plano de execu��o gerado
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
