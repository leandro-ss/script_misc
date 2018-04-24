UNDEFINE SID;
SET SERVEROUTPUT ON SIZE 1000000
DECLARE
	
	USERNAME_ 	V$SESSION.USERNAME%TYPE;
	OSUSER_   	V$SESSION.OSUSER%TYPE;
	EXECUTIONS_ 	V$SQL.EXECUTIONS%TYPE;
	MACHINE_	V$SESSION.MACHINE%TYPE;
	TERMINAL_	V$SESSION.TERMINAL%TYPE;
	OPERATION_	V$SQL_PLAN.OPERATION%TYPE;
	OBJECT_OWNER_	V$SQL_PLAN.OBJECT_OWNER%TYPE;
	OBJECT_NAME_	V$SQL_PLAN.OBJECT_NAME%TYPE;
	OPTIONS_	V$SQL_PLAN.OPTIONS%TYPE;
	POSITION_	V$SQL_PLAN.POSITION%TYPE;
	COST_		V$SQL_PLAN.COST%TYPE;
	POSICAO_	VARCHAR2(1000);
	I_		NUMBER(4);
	PTO_		VARCHAR2(1);
	SQL_TEXT_	V$SQLTEXT.SQL_TEXT%TYPE;
	
	CURSOR GET_SESSIONS_DETAILS IS
	SELECT
		A.USERNAME USERNAME,
		A.OSUSER   OSUSER,
		C.EXECUTIONS EXECUTIONS,
		A.MACHINE  MACHINE,
		A.TERMINAL TERMINAL
	FROM
		V$SESSION A,
		V$SQL     C
	WHERE
		A.SQL_HASH_VALUE = C.HASH_VALUE
		AND C.EXECUTIONS > 0
		AND A.SID = &&SID;

	CURSOR GET_SQL_TEXT IS
	SELECT 
		A.SQL_TEXT
	FROM
		V$SQLTEXT A,
		V$SESSION B
	WHERE
		B.SQL_HASH_VALUE = A.HASH_VALUE
		AND B.SID 	 = &&SID
	ORDER BY
		A.PIECE;

	CURSOR GET_SQL_PLAN IS
	SELECT
		B.OPERATION,
		B.OBJECT_OWNER,
		B.OBJECT_NAME,
		B.OPTIONS,
		B.POSITION,
		B.COST
	FROM
		V$SESSION  A,
		V$SQL_PLAN B,
		V$SQL      C
	WHERE
		A.SQL_HASH_VALUE     = B.HASH_VALUE
		AND A.SQL_HASH_VALUE = C.HASH_VALUE
		AND A.SID = &&SID;

BEGIN
	DBMS_OUTPUT.PUT_LINE('===============================================================================================================================');
	DBMS_OUTPUT.PUT_LINE('===============================================================================================================================');
	DBMS_OUTPUT.PUT_LINE('===============================================================================================================================');
	OPEN GET_SESSIONS_DETAILS;
	LOOP
		FETCH GET_SESSIONS_DETAILS INTO USERNAME_, OSUSER_, EXECUTIONS_, MACHINE_, TERMINAL_;
			EXIT WHEN GET_SESSIONS_DETAILS%NOTFOUND;
			DBMS_OUTPUT.PUT_LINE('===> USUÁRIO:   '||USERNAME_);
			DBMS_OUTPUT.PUT_LINE('===> OS_USER:   '||OSUSER_);
			DBMS_OUTPUT.PUT_LINE('===> EXECUÇÕES: '||EXECUTIONS_);
			DBMS_OUTPUT.PUT_LINE('===> MÁQUINA:   '||MACHINE_);
			DBMS_OUTPUT.PUT_LINE('===> TERMINAL:  '||TERMINAL_);
	END LOOP;
	CLOSE GET_SESSIONS_DETAILS;
	DBMS_OUTPUT.PUT_LINE('===============================================================================================================================');
	DBMS_OUTPUT.PUT_LINE('===============================================================================================================================');

	DBMS_OUTPUT.PUT_LINE('===> COMANDO SQL:');
	OPEN GET_SQL_TEXT;
	LOOP
		FETCH GET_SQL_TEXT INTO SQL_TEXT_;
			EXIT WHEN GET_SQL_TEXT%NOTFOUND;
			DBMS_OUTPUT.PUT_LINE('===> '||SQL_TEXT_);
	END LOOP;
	CLOSE GET_SQL_TEXT;

	DBMS_OUTPUT.PUT_LINE('===============================================================================================================================');
	DBMS_OUTPUT.PUT_LINE('===============================================================================================================================');

	OPEN GET_SQL_PLAN;
	LOOP
		FETCH GET_SQL_PLAN INTO OPERATION_, OBJECT_OWNER_, OBJECT_NAME_, OPTIONS_, POSITION_, COST_;
		EXIT WHEN GET_SQL_PLAN%NOTFOUND;
		POSICAO_ := '';
		FOR I_ IN 1..POSITION_ LOOP
			POSICAO_ := POSICAO_||'   ';
		END LOOP;
		IF OBJECT_OWNER_ IS NOT NULL THEN
			PTO_ := '.';
		ELSE
			PTO_ := ' ';
		END IF;
		DBMS_OUTPUT.PUT_LINE('===> '||POSICAO_||OPERATION_||' '||OBJECT_OWNER_||PTO_||OBJECT_NAME_||' '||
			OPTIONS_||' -------> COST: '||COST_);
	END LOOP;
	CLOSE GET_SQL_PLAN;
	DBMS_OUTPUT.PUT_LINE('===============================================================================================================================');
	DBMS_OUTPUT.PUT_LINE('===============================================================================================================================');	
END;
/
UNDEFINE SID;

