declare

--script to extract tables definitions based a query cursor c_table
--marcio
--08/04/2005

--before execute these uncomment and using a following DDL to creates a table with a long type
--like a output it's very large, it's impracticable use a dbms_output.put_line because an line length overflow,
--existis some fixes about this, but tables works well too.

--CREATE TABLE system.create_table
-- (
--  statement                  LONG
--) ;
 

cursor c_table is
                select  distinct owner, table_name
                from    all_tab_columns
                where   owner       like    '%BIS_PRO%'   and
                        data_type   =       'BLOB'
                order by owner, table_name;
                   
                        
            
cursor c_column(cp_owner all_tab_columns.owner%type,
                cp_table all_tab_columns.table_name%type
               ) is
                select  
                        owner,
                        table_name,
                        column_name,
                        data_type,
                        data_type_mod,
                        data_type_owner,
                        data_length,
                        decode(data_precision,null,decode(data_type,'NUMBER',22), data_precision)data_precision,
                        decode(data_scale,null,decode(data_type,'NUMBER',0),data_scale)data_scale,                        
                        decode(nullable,'N','NOT NULL') nullable,
                        column_id,
                        default_length,
                        data_default,
                        num_distinct,
                        low_value,
                        high_value,
                        density,
                        num_nulls,
                        num_buckets,
                        last_analyzed,
                        sample_size,
                        character_set_name,
                        char_col_decl_length,
                        global_stats,
                        user_stats,
                        avg_col_len,
                        char_length,
                        char_used,
                        v80_fmt_image,
                        data_upgraded
                from    all_tab_columns
                where   owner       = cp_owner    and
                        table_name  = cp_table
                order by column_id;
                
                
                
                
v_table     c_table%rowtype;                
v_column    c_column%rowtype;
command     varchar2(30000);
first_col   boolean;


Begin

delete from create_table;
commit;

open c_table;

loop

 fetch c_table into v_table;
 exit when c_table%notfound;




--for x in (select owner, table_name
--          from   all_tab_columns
--          where  owner like   'BIS%'   and
--                 data_type   ='BLOB'
--          order by owner, table_name
--         ) loop
         
--            dbms_output.put_line(x.owner||'.'||x.table_name);
            
--           end loop;
 
 
 
 command:=command||'create table '||v_table.owner||'.'||v_table.table_name||' ('||chr(10);
 
 first_col:=true;

     
    open c_column(v_table.owner, v_table.table_name);
    loop
     fetch c_column into v_column;
     exit when c_column%notfound;
     
     if first_col and v_column.data_type in ('VARCHAR2','RAW') then
      command:=command||' '||v_column.column_name||' '||v_column.data_type||' ('||v_column.data_length||') '||v_column.nullable||chr(10);

      elsif not first_col and v_column.data_type in ('VARCHAR2','RAW') then
       command:=command||','||v_column.column_name||' '||v_column.data_type||' ('||v_column.data_length||') '||v_column.nullable||chr(10);
       
       elsif first_col and v_column.data_type='NUMBER' then
        command:=command||' '||v_column.column_name||' NUMBER ('||v_column.data_precision||','||v_column.data_scale||') '||v_column.nullable||chr(10);

         elsif not first_col and v_column.data_type='NUMBER' then
          command:=command||','||v_column.column_name||' NUMBER ('||v_column.data_precision||','||v_column.data_scale||') '||v_column.nullable||chr(10);
          
          elsif first_col and v_column.data_type in ('BLOB','DATE') then
           command:=command||' '||v_column.column_name||' '||v_column.data_type||' '||v_column.nullable||chr(10);

           elsif not first_col and v_column.data_type in ('BLOB','DATE') then
            command:=command||','||v_column.column_name||' '||v_column.data_type||' '||v_column.nullable||chr(10);
     end if;
     first_col:=false;
    end loop;
    close c_column; 
 
 command:=command||');'||chr(10)||chr(10);

end loop;
close c_table;

insert /*+ APPEND */ into create_table values (command);
commit;

End;
