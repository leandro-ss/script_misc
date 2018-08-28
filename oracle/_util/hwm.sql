accept table prompt "Informe o nome da tabela: " 
col Segmento 	format a30
col Tabela 	format a30
SELECT 
	table_name 		"Tabela",
	blocks 			"Blocos já Utilizados", 
	empty_blocks 		"Blocos Vazios - Acima da HWM", 
	blocks+empty_blocks 	"Total de Blocos",
	num_rows 		"Linhas"
FROM   
	dba_tables 
WHERE 
	table_name = upper('&&table')
/
SELECT 
	segment_name 	"Segmento",
	segment_type 	"Tipo",
	blocks		"Quantidade de blocos",
	round(bytes/1024/1024,2) "Mega Bytes"
FROM 
	dba_segments   
WHERE 
	segment_name = upper('&&table')
/
undefine table