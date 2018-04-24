Segue abaixo um exemplo de trigger de logon. Ao definir o módulo usando a package DBMS_APPLICATION_INFO, é possivel agrupar todos os traces gerados a partir desse modulo. Para isso, utiliza-se o trcsess.

CREATE OR REPLACE TRIGGER owner.trigger_name
AFTER LOGON ON DATABASE
DECLARE V_OSUSER VARCHAR2(64);
BEGIN
  SELECT SYS_CONTEXT('USERENV','OS_USER') INTO V_OSUSER FROM DUAL;
  IF USER='usuário no banco de dados' AND V_OSUSER = 'Usuário no servidor cliente' THEN
    DBMS_APPLICATION_INFO.SET_MODULE('nome do módulo',NULL);
    EXECUTE IMMEDIATE 'ALTER SESSION SET TRACEFILE_IDENTIFIER = ''nome do trace''';
    EXECUTE IMMEDIATE 'ALTER SESSION SET EVENTS ''10046 TRACE NAME CONTEXT FOREVER, LEVEL 8''';
  END IF;

END;
/

trcsess output=traces_concat.txt module=PERF_TESTE *.trc

tkprof traces_concat.txt traces_parsed.txt