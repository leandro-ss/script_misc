PROMPT
PROMPT ==> FUNÇÃO: MOSTRA A SITUAÇÃO ATUAL DOS TABLESPACES (ESPAÇO LIVRE E OCUPADO)
PROMPT ==> DESENVOLVIDO POR CLEBER R. MARQUES
PROMPT ==> MSN: cleber_rmarques@hotmail.com
PROMPT
col tablespace_name format a25
col total_livre     format 999,999,990.00
col maior_livre     format 999,999,990.00
col tb_size         format 999,999,990.00
col total_usado     format 999,999,990.00
col "%"             format         990.00
compute sum of tb_size     on report
compute sum of total_usado on report
break on report
select
	*
from
	(
	select
		b.tablespace_name,
		b.mb                        as tb_size,
		nvl(max(a.bytes)/1024/1024,0)      as maior_livre,
		nvl(sum(a.bytes)/1024/1024,0)      as total_livre,
		nvl((sum(a.bytes)/1024/1024)/(b.mb)*100,0) as "%",
		nvl(b.mb-sum(a.bytes)/1024/1024,b.mb) as total_usado,
		count(b.tablespace_name)    as qtd
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
	union all
	select
		tablespace_name,
		tb_size,
		maior_livre,
		total_livre,
	        decode(total_livre,0,1,total_livre)/(total_usado*100) as "%",
		total_usado,
		qtd
	from
		(
		select
			tf.tablespace_name,
			sum(tf.bytes_used)/1024/1024 as tb_size,
			0			       as maior_livre,
			sum(tf.bytes_free)/1024/1024 as total_livre,
			sum(tf.bytes_used)/1024/1024 as total_usado,
			count(tf.tablespace_name)    as qtd
		from
			v$temp_space_header tf
		group by
			tf.tablespace_name
		)
	)
order by
	tb_size desc
/