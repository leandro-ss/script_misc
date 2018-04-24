set serveroutput on size 999999
spool c:\create_tables.sql
declare 
    v_tname  varchar2(30);
    v_cname  char(32);
    v_type     char(20);
    v_null   varchar2(10);
    v_maxcol number;
    v_virg     varchar2(1);
begin
dbms_output.put_line('--');
dbms_output.put_line('-- CREATE TABLES --');
dbms_output.put_line('--');
    for rt in (select distinct table_name from user_tab_columns where data_type like '%LOB%' order by 1) loop
        v_tname:=rt.table_name;
        v_virg:=',';
        dbms_output.put_line('CREATE TABLE '||user||'.'||v_tname||' (');
        for rc in (select table_name,column_name,data_type,data_length,
                            data_precision,data_scale,nullable,column_id
                from user_tab_columns tc
                where tc.table_name=rt.table_name
                order by table_name,column_id) loop
                    v_cname:=rc.column_name;
                    if rc.data_type='VARCHAR2' then
                        v_type:='VARCHAR2('||rc.data_length||')';
                    elsif rc.data_type='NUMBER' and rc.data_precision is null and
                                         rc.data_scale=0 then
                        v_type:='INTEGER';
                    elsif rc.data_type='NUMBER' and rc.data_precision is null and
                                     rc.data_scale is null then
                        v_type:='NUMBER';
                    elsif rc.data_type='NUMBER' and rc.data_scale='0' then
                        v_type:='NUMBER('||rc.data_precision||')';
                    elsif rc.data_type='NUMBER' and rc.data_scale<>'0' then                        
			v_type:='NUMBER('||rc.data_precision||','||rc.data_scale||')';
                    elsif rc.data_type='CHAR' then
                         v_type:='CHAR('||rc.data_length||')';
                    else v_type:=rc.data_type;
                    end if;
                    
                    if rc.nullable='Y' then
                        v_null:='NULL';
                    else
                        v_null:='NOT NULL';
                    end if;
                    select max(column_id)
                        into v_maxcol
                        from user_tab_columns c
                        where c.table_name=rt.table_name;
                    if rc.column_id=v_maxcol then
                        v_virg:='';
                    end if;
                    dbms_output.put_line (v_cname||v_type||v_null||v_virg);
        end loop;
        dbms_output.put_line(');');
    end loop;
end;  
/
spool off