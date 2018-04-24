REM	Autor 	: JOAO HENRIQUE FERREIRA BARBOSA
REM	Empresa : ÂNCORA CONSULTORES
REM 	Data 	: 05/03
REM	Versao 	: 9.2
REM	==================================================================
REM 	
REM	Tabela 		:  V$PROCESS	
REM 	Estatisticas 	:  Do momento da execucao
REM
REM	Coluna			Significado
REM
REM	pga_used_mem	    	Memoria PGA correntemente usada pelo processo
REM	pga_alloc_mem	    	Memoria PGA correntemente alocada pelo processo
REM				Alocacao inclu memoria PGA sem uso que nao foi ainda liberada pelo processo server	
REM	pga_max_mem	    	Memoria PGA maxima alocada pelo processo
REM
REM		
REM	Tabela 		:  V$SYSSTAT
REM	Coluna 		:  name
REM 	Estatisticas 	:  Desde o ultimo Startup
REM
REM	Nome da Estatistica		Significado
REM
REM	workarea memory allocated	Total de PGA em Kb alocada para a sessao
REM	workarea executions optimal	Nro de vezes que operacoes na work area 
REM					foram executadas na memoria
REM	workarea executions onepass	Indica uso de disco em um passo
REM	workarea executions multipass	Indica nro de vezes que uma unica operacao e gravada para disco

set feed off
set heading off
set lines 100
set pages 24
set space 1

PROMPT
PROMPT
PROMPT ====
PROMPT PGA
PROMPT ====

select 	
	rpad(name,40,' ')||' = '||rpad(to_char(value,'999,999,990'),12,' ')||' '||unit	
from 
	v$pgastat
;

set heading on

PROMPT
PROMPT
PROMPT ======================================
PROMPT Memoria na Execucao de SQL - Processos
PROMPT ======================================

column "c1"  format 999,999,990  heading "PGA Usada Correntemente"
column "c2"  format 999,999,990  heading "PGA Alocada Correntemente"
column "c3"  format 999,999,990  heading "PGA Maxima Alocada"

select 	
	sum (pga_used_mem)	"c1",
	sum (pga_alloc_mem)	"c2",
	sum (pga_max_mem)	"c3"
from 
	v$process
;

PROMPT
PROMPT
PROMPT =========================================
PROMPT Memoria na Execucao de SQL - Estatisticas
PROMPT =========================================

column "c1"  format a35  	heading "Estatistica"
column "c2"  format 999,999,990 heading "Valor"

select 	
	name 	"c1", 
	value	"c2"
from 		
	v$sysstat
where
	name LIKE '%workarea%'
;

PROMPT
PROMPT
PROMPT ======================================
PROMPT Workareas com maior consumo de memoria
PROMPT ======================================

column "c1"  format 999999999  	heading "Workarea"
column "c2"  format a18		heading "Operacao"
column "c3"  format a6		heading "Polit."
column "c4"  format 999,999,999	heading "Tamanho em KB|para execucao|em memoria"
column "c5"  format 99,999	heading "Nro de|vezes|ficou|Ativa"
column "c6"  format 99,999	heading "Nro de|vezes|rodou|Optimal"
column "c7"  format 99,999	heading "Nro de|vezes|rodou|One-pass"
column "c8"  format 99,999	heading "Nro de|vezes|rodou|Multi-pass"
column "c9"  format 999,999,999	heading "Media|tempo|Ativa|cent/segs"

select 	*
from 	(select	workarea_address 	"c1",
		operation_type		"c2",
		policy			"c3",
		estimated_optimal_size	"c4",
		total_executions	"c5",
		optimal_executions	"c6",
		onepass_executions	"c7",
		multipasses_executions	"c8",
		active_time		"c9"
	 from 	v$sql_workarea
	 order by estimated_optimal_size desc)
where	rownum <= 10 ;
