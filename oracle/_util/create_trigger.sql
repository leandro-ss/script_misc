CREATE OR REPLACE TRIGGER inm_10046_trace_trigger 
  after logon on database 
    -- 10046 TRACELEVELS 
    -- 0  - Turn off tracing. 
    -- 1  - Basic SQL_TRACE. 
    -- 4  - Level 1 plus Bind Variables. 
    -- 8  - Level 1 plus wait events. 
    -- 12 - Level 1 plus Bind Variables and Wait event information. 
begin 
  if user = 'EXPACCT' then 
    execute immediate 'alter session set timed_statistics = true'; 
    execute immediate 'alter session set max_dump_file_size = unlimited'; 
    execute immediate 'alter session set tracefile_identifier = ''inm_session_trace'''; 
    execute immediate 'alter session set events ''10046 trace name context forever, level 8''';
  end if; 
end;
/
