Stored Outlines and Plan Stability
A stored outline is a collection of hints associated with a specific SQL statement that allows a standard execution plan to be maintained, regardless of changes in the system environment or associated statistics. Plan stability is based on the preservation of execution plans at a point in time where the performance of a statement is considered acceptable. The outlines are stored in the OL$, OL$HINTS, and OL$NODES tables, but the [USER|ALL|DBA]_OUTLINES and [USER|ALL|DBA]_OUTLINE_HINTS views should be used to display information about existing outlines.

All of the caveats associated with optimizer hints apply equally to stored outlines. Under normal running the optimizer chooses the most suitable execution plan for the current circumstances. By using a stored outline you may be forcing the optimizer to choose a substandard execution plan, so you should monitor the affects of your stored outlines over time to make sure this isn't happening. Remember, what works well today may not tomorrow. 
Creating Outlines 
Using Outlines 
Dropping Outlines 
Creating Outlines
Outlines can be created automatically by Oracle or manually for specific statements. The automatic creation of outlines is controlled using the create_stored_outlines parameter than can be set at session or instance level using the following commands.

-- Switch on automatic creation of stored outlines.
ALTER SYSTEM SET create_stored_outlines=TRUE;
ALTER SESSION SET create_stored_outlines=TRUE;

-- Switch on automatic creation of stored outlines.
ALTER SYSTEM SET create_stored_outlines=FALSE;
ALTER SESSION SET create_stored_outlines=FALSE;Once this parameter is set at session or instance level outlines are produced for all statements executed by the session or instance respectively.

Outlines can be generated for specific statements using the CREATE OUTLINE statement or the DBMS_OUTLN.CREATE_OUTLINE procedure. Before we can look at some examples we need to grant the correct privileges to the SCOTT user.

-- Grant the necessary privileges.
CONN sys/password AS SYSDBA
GRANT CREATE ANY OUTLINE TO SCOTT;
GRANT EXECUTE_CATALOG_ROLE TO SCOTT;The following example uses the CREATE OUTLINE statement to create an outline for a specified SQL statement. The statement is assigned to an outline category called SCOTT_OUTLINES to ease administration. If the category is not specified the outline is assigned to the default category.

CONN scott/tiger

-- Create an outline for a specific SQL statement.
CREATE OUTLINE emp_dept FOR CATEGORY scott_outlines
ON SELECT e.empno, e.ename, d.dname FROM emp e, dept d WHERE e.deptno = d.deptno;

-- Check the outline as been created correctly.
COLUMN name FORMAT A30
SELECT name, category, sql_text FROM user_outlines WHERE category = 'SCOTT_OUTLINES';

NAME                           CATEGORY
------------------------------ ------------------------------
SQL_TEXT
--------------------------------------------------------------------------------
EMP_DEPT                       SCOTT_OUTLINES
SELECT e.empno, e.ename, d.dname FROM emp e, dept d WHERE e.deptno = d.deptno


1 row selected.

-- List the hints associated with the outline.
COLUMN hint FORMAT A50
SELECT node, stage, join_pos, hint FROM user_outline_hints WHERE name = 'EMP_DEPT';

      NODE      STAGE   JOIN_POS HINT
---------- ---------- ---------- --------------------------------------------------
         1          1          0 NO_EXPAND(@"SEL$1" )
         1          1          0 PQ_DISTRIBUTE(@"SEL$1" "E"@"SEL$1" NONE NONE)
         1          1          0 USE_MERGE(@"SEL$1" "E"@"SEL$1")
         1          1          0 LEADING(@"SEL$1"  "D"@"SEL$1" "E"@"SEL$1")
         1          1          0 NO_STAR_TRANSFORMATION(@"SEL$1" )
         1          1          0 NO_FACT(@"SEL$1" "E"@"SEL$1")
         1          1          0 NO_FACT(@"SEL$1" "D"@"SEL$1")
         1          1          2 FULL(@"SEL$1" "E"@"SEL$1")
         1          1          1 INDEX(@"SEL$1" "D"@"SEL$1" ("DEPT"."DEPTNO"))
         1          1          0 NO_REWRITE(@"SEL$1" )
         1          1          0 NO_REWRITE(@"SEL$1" )

11 rows selected.The following example uses the DBMS_OUTLN.CREATE_OUTLINE procedure to create an outline for a specified SQL statement already present in the V$SQL view. Once again, the statement is assigned to an outline category called SCOTT_OUTLINES.

-- Run an SQL statement to get it into the shared pool.
SELECT e.empno, e.ename, d.dname, e.job FROM emp e, dept d WHERE e.deptno = d.deptno AND d.dname = 'SALES';

     EMPNO ENAME      DNAME          JOB
---------- ---------- -------------- ---------
      7499 ALLEN      SALES          SALESMAN
      7698 BLAKE      SALES          MANAGER
      7654 MARTIN     SALES          SALESMAN
      7900 JAMES      SALES          CLERK
      7844 TURNER     SALES          SALESMAN
      7521 WARD       SALES          SALESMAN

6 rows selected.

-- Identify the SQL statement in the V$SQL view.
SELECT hash_value, child_number, sql_text FROM v$sql WHERE sql_text LIKE 'SELECT e.empno, e.ename, d.dname, e.job%';

HASH_VALUE CHILD_NUMBER
---------- ------------
SQL_TEXT
----------------------------------------------------------------------------------------------------
3909283366            0
SELECT e.empno, e.ename, d.dname, e.job FROM emp e, dept d WHERE e.deptno = d.deptno AND d.dname = '
SALES'


1 row selected.

-- Create an outline for the statement.
BEGIN
  DBMS_OUTLN.create_outline(
    hash_value    => 3909283366,
    child_number  => 0,
    category      => 'SCOTT_OUTLINES');
END;
/

-- Check the outline as been created correctly.
COLUMN name FORMAT A30
SELECT name, category, sql_text FROM user_outlines WHERE category = 'SCOTT_OUTLINES';

NAME                           CATEGORY
------------------------------ ------------------------------
SQL_TEXT
--------------------------------------------------------------------------------
SYS_OUTLINE_05092314510581419  SCOTT_OUTLINES
SELECT e.empno, e.ename, d.dname, e.job FROM emp e, dept d WHERE e.deptno = d.de

EMP_DEPT                       SCOTT_OUTLINES
SELECT e.empno, e.ename, d.dname FROM emp e, dept d WHERE e.deptno = d.deptno


2 rows selected.

-- List the hints associated with the outline.
COLUMN hint FORMAT A50
SELECT node, stage, join_pos, hint  FROM user_outline_hints WHERE name = 'SYS_OUTLINE_05092314510581419';


      NODE      STAGE   JOIN_POS HINT
---------- ---------- ---------- --------------------------------------------------
         1          1          0 NO_EXPAND(@"SEL$1" )
         1          1          0 PQ_DISTRIBUTE(@"SEL$1" "E"@"SEL$1" NONE NONE)
         1          1          0 USE_MERGE(@"SEL$1" "E"@"SEL$1")
         1          1          0 LEADING(@"SEL$1"  "D"@"SEL$1" "E"@"SEL$1")
         1          1          0 NO_STAR_TRANSFORMATION(@"SEL$1" )
         1          1          0 NO_FACT(@"SEL$1" "E"@"SEL$1")
         1          1          0 NO_FACT(@"SEL$1" "D"@"SEL$1")
         1          1          2 FULL(@"SEL$1" "E"@"SEL$1")
         1          1          1 INDEX(@"SEL$1" "D"@"SEL$1" ("DEPT"."DEPTNO"))
         1          1          0 NO_REWRITE(@"SEL$1" )

10 rows selected.Using Outlines
We now have our outlines, but the following queries show that they are not currently being used.

-- Check if the outlines have been used.
SELECT name, category, used FROM user_outlines;

NAME                           CATEGORY                       USED
------------------------------ ------------------------------ ------
SYS_OUTLINE_05092314510581419  SCOTT_OUTLINES                 UNUSED
EMP_DEPT                       SCOTT_OUTLINES                 UNUSED

2 rows selected.

-- Issue both statements again.
SELECT e.empno, e.ename, d.dname FROM emp e, dept d WHERE e.deptno = d.deptno;
SELECT e.empno, e.ename, d.dname, e.job FROM emp e, dept d WHERE e.deptno = d.deptno AND d.dname = 'SALES';

-- Check if the outlines have been used.
SELECT name, category, used FROM user_outlines;

NAME                           CATEGORY                       USED
------------------------------ ------------------------------ ------
SYS_OUTLINE_05092314510581419  SCOTT_OUTLINES                 UNUSED
EMP_DEPT                       SCOTT_OUTLINES                 UNUSED

2 rows selected.To enable the outlines we need to enable query rewrites and indicate which outline category the instance or session should use. This is done using the ALTER SYSTEM and ALTER SESSION commands. In the following example we will enable stored outlines for the current session.

-- Enable stored outlines.
ALTER SESSION SET query_rewrite_enabled=TRUE;
ALTER SESSION SET use_stored_outlines=SCOTT_OUTLINES;

-- Issue both statements again.
SELECT e.empno, e.ename, d.dname FROM emp e, dept d WHERE e.deptno = d.deptno;
SELECT e.empno, e.ename, d.dname, e.job FROM emp e, dept d WHERE e.deptno = d.deptno AND d.dname = 'SALES';

-- Check if the outlines have been used.
SELECT name, category, used FROM user_outlines;

NAME                           CATEGORY                       USED
------------------------------ ------------------------------ ------
SYS_OUTLINE_05092314510581419  SCOTT_OUTLINES                 USED
EMP_DEPT                       SCOTT_OUTLINES                 USED

2 rows selected.The use_stored_outlines parameter has valid values including TRUE, FALSE and any valid category name. The value of TRUE indicates that the default outline category should be used. 
Dropping Outlines
The DBMS_OUTLN package can be used to stored outlines as follows.

BEGIN
  DBMS_OUTLN.drop_by_cat (cat => 'SCOTT_OUTLINES');
END;
/For more information see:

Using Plan Stability 
CREATE OUTLINE 
DBMS_OUTLN 
DBMS_OUTLN_EDIT 
Hope this helps. Regards Tim...