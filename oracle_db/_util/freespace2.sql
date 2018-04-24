PROMPT
PROMPT ==> FUNÇÃO: MOSTRA A SITUAÇÃO ATUAL DOS TABLESPACES (ESPAÇO LIVRE E OCUPADO)
PROMPT ==> DESENVOLVIDO POR CLEBER R. MARQUES
PROMPT ==> MSN: cleber_rmarques@hotmail.com
PROMPT
col tablespace_name format a25
col total_free      format 999,999,990.00
col max_free        format 999,999,990.00
col mb_size         format 999,999,990.00
col Total_used      format 999,999,990.00
col "%"             format         990.00
compute sum of mb_size     on report
compute sum of total_used on report
break on report
   select
           b.tablespace_name,
           b.mb                        										MB_Size,
           nvl(max(a.bytes)/1024/1024,0)      									Max_Free,
           nvl(sum(a.bytes)/1024/1024,0)      									Total_Free,
           round(nvl((sum(a.bytes)/1024/1024)/(b.mb)*100,0),2) 							as "% Free",
           100-(round(nvl((sum(a.bytes)/1024/1024)/(b.mb)*100,0),2)) 						as "% Used",
	   decode(round((round(100-nvl((sum(a.bytes)/1024/1024)/(b.mb)*100,0)))/10),0,'xxxxxxxxxx',
	   rpad(lpad(chr(127),round((round(100-nvl((sum(a.bytes)/1024/1024)/(b.mb)*100,0)))/10),chr(127)),10,'x')) 	as Graphic,
           nvl(b.mb-sum(a.bytes)/1024/1024,b.mb) 								as Total_Used,
           count(b.tablespace_name)    										as Fragments
   from
           (
           select
                   tablespace_name,
                   sum(bytes)/1024/1024 mb
           from
                   dba_data_files
           group by
                   tablespace_name
           ) b,
           dba_free_space a
   where
           b.tablespace_name  = a.tablespace_name (+)
   group by
           b.tablespace_name,
           b.mb
   order by
           5
/
