
-- Gera plano de execução para uma query
EXPLAIN PLAN FOR
SELECT ...

-- Obtem o plano de execução gerado
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
