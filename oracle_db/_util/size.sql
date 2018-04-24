set lines 300 pages 600
col segment_name format a50
col owner format a15
select segment_name, segment_type, owner, round(bytes/1024/1024,2) as tamanho_mb from dba_segments where segment_name='&segment_name';