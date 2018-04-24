Clear Screen

Accept Owner_ Char Prompt "Infórme o proprietário: "

Set Pages     0
Set Lines     100
Set Verify    Off
Set Feed      Off
Set termOut   Off

Break On C1 Skip 1

Col c1 Format a30        Heading "Proprietário | Tabela"
Col c2 Format a30        Heading "Nome da Tabela"
Col c3 Format 9999999    Heading "Tamanho Kb"
Col c4 Format 990        heading "Qtd"

Spool &&Owner_

Select
         a.table_name      		c1,
         b.segment_name    		c2,
         sum(trunc(b.bytes/1024)) 	c3,
	 Count(*)          		c4
from 
         dba_extents      b,  
         dba_tables       a
Where
         a.owner          = Upper('&&Owner_')
and      a.table_name     = b.segment_name
group by a.table_name     ,
         b.segment_name   
Union
Select
         a.table_name      		c1,
         b.segment_name    		c2,
         sum(trunc(b.bytes/1024)) 	c3,
	 Count(*)          		c4      
from 
         dba_extents      b,  
         dba_indexes      a
Where	 a.owner          = Upper('&&Owner_')
and      a.index_name     = b.segment_name
group by a.table_name     ,
         b.segment_name   
order by 1,2
/
 
Spool Off

Set Pages     60
Set Lines     100
Set Verify    On
Set Feed      On
Set termOut   On