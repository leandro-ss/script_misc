declare
  x number := 0;
begin
  delete from temp_var;
  commit;
  loop
    x := x + 1;
    insert into temp_var 
    SELECT 
      a.sql_id,
      a.sql_text, 
      b.name, 
      b.position, 
      b.datatype_string, 
      b.value_string,
      x
    FROM
      v$sql_bind_capture b,
      v$sqlarea          a
    WHERE b.sql_id in (select sql_id from v$sqltext
                        where sql_text like '%SELECT TO_NUMBER(TO_CHAR(COD_SOLICT%'
                           or sql_text like '%UPDATE B_PEDIDO_MANUAL SET%'
                           or sql_text like '%INSERT INTO B_PEDIDO_MANUAL%')
      AND b.sql_id = a.sql_id;
    commit;
    exit when x = 60;
    dbms_lock.sleep(1);
  end loop;
end;

select distinct sql_id, sql_text, name, datatype_string, value_string
select distinct *
from temp_var
--where value_string is not null
where seq = 58
and sql_id = 'dnxfuhtgpwkhp'
order by sql_id, to_number(substr(name,3,2))