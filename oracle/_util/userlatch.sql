SET SERVEROUTPUT ON
DECLARE
	V_USERNAME V$SESSION.USERNAME%TYPE;
	V_SID      V$SESSION.SID%TYPE;
	V_SERIAL#  V$SESSION.SERIAL#%TYPE;
	V_KSMLRHON X$KSMLRU.KSMLRHON%TYPE;

CURSOR C1 IS
	SELECT 
		A.USERNAME USERNAME,
		A.SID      SID,
		A.SERIAL#  SERIAL#,
		B.KSMLRHON KSMLRHON
	FROM
		V$SESSION A,
		X$KSMLRU  B
	WHERE
		A.STATUS 	= 'ACTIVE'
		AND A.TYPE     != 'BACKGROUND'
		AND B.KSMLRSIZ  > 1000
		AND A.SADDR 	= B.KSMLRSES;

BEGIN
	DBMS_OUTPUT.PUT_LINE('========================================================================================');
	DBMS_OUTPUT.PUT_LINE('== Sessões para alocações de Pool Compartilhado causando disputas (Latches)           ==');
	DBMS_OUTPUT.PUT_LINE('========================================================================================');		
	
	FOR REC1 IN C1 LOOP
		V_USERNAME := REC1.USERNAME;
		V_SID      := REC1.SID;
		V_SERIAL#  := REC1.SERIAL#;
		V_KSMLRHON := REC1.KSMLRHON;
		DBMS_OUTPUT.PUT_LINE('========================================================================================');
		DBMS_OUTPUT.PUT_LINE('========================================================================================');
		DBMS_OUTPUT.PUT_LINE('== USERNAME: '||V_USERNAME);
		DBMS_OUTPUT.PUT_LINE('========================================================================================');
		DBMS_OUTPUT.PUT_LINE('== SID: '||V_SID||' SERIAL#: '||V_SERIAL#);
		DBMS_OUTPUT.PUT_LINE('========================================================================================');
		DBMS_OUTPUT.PUT_LINE('========================================================================================');
		DBMS_OUTPUT.PUT_LINE('== KSMLRU: ');
		DBMS_OUTPUT.PUT_LINE(V_KSMLRHON);
	END LOOP;
END;
/