--------------------------------------------------------------------------
--------------------------------------------------------------------------
--
-- Script		: ddl_tablespaces.sql
-- Data de criacao	: 19/11/2007
-- Autor		: Cleber R. Marques
-- Funcao		: Gera o comando DDL para criacao dos tablespaces
--		  	  de uma base de dados Oracle
-- Versoes 		: 9.2.XX
--
--------------------------------------------------------------------------
--------------------------------------------------------------------------
set echo off
set timing off
set lines 99
set pages 999
set feed off
set termout off
set serveroutput on size 999999
spool c:\tablespaces.txt
declare
	--
	-- Variaveis
	--
	v_tablespace_name	sys.dba_tablespaces.tablespace_name%type;
	v_qtd_datafiles		pls_integer;
	v_datafile_atual	pls_integer;
	--
	-- Cursores
	--
	cursor c_tablespaces is
	select
		contents,
		tablespace_name,
		block_size,
		initial_extent/1024 initial_extent_kb,
		next_extent/1024 next_extent_kb,
		extent_management,
		allocation_type,
		segment_space_management,
		logging
	from
		dba_tablespaces;
	--
	cursor c_datafiles is
	select
		file_name,
		bytes/1024 					kbytes,
		decode(autoextensible,'YES','ON','NO','OFF') 	autoextend,
		increment_by,
		maxbytes/1024					maxbytes_kb
	from
		dba_data_files
	where
		tablespace_name = v_tablespace_name
	order by 
		file_id;
	--
	cursor c_tempfiles is
	select
		file_name,
		bytes/1024 					kbytes,
		decode(autoextensible,'YES','ON','NO','OFF') 	autoextend,
		increment_by,
		maxbytes/1024					maxbytes_kb
	from
		dba_temp_files
	where
		tablespace_name = v_tablespace_name
	order by 
		file_id;
begin
	-- 
	-- Abre o cursor principal, trazendo cada tablespace
	--
	for r_tablespaces in c_tablespaces loop
		--
		v_tablespace_name := r_tablespaces.tablespace_name;
		--
		-- Verifica a quantidade de datafiles do tablespace
		--
		select 
			count(*) 
		into
			v_qtd_datafiles
		from 
			dba_data_files
		where
			tablespace_name = v_tablespace_name;
		--
		v_datafile_atual := 1;
		--
		dbms_output.put_line('-----------------------------------------');
		dbms_output.put_line('-- TABLESPACE: '||v_tablespace_name);
		dbms_output.put_line('-----------------------------------------');
		--
		-- Se for um tablespace de undo, coloca a palavra UNDO no comando
		-- Se for um tablespace temporario, coloca a palavra TEMPORARY no comando
		--
		if r_tablespaces.contents = 'UNDO' then
			--
			dbms_output.put_line('create undo tablespace '||v_tablespace_name);
			--
		elsif r_tablespaces.contents = 'TEMPORARY' then
			--
			dbms_output.put_line('create temporary tablespace '||v_tablespace_name);
			--
		else
			--
			dbms_output.put_line('create tablespace '||v_tablespace_name);
			--
		end if;
		--
		dbms_output.put_line('blocksize '||r_tablespaces.block_size);
		--
		-- verifica se o tablespace nao eh temporario e para cada tablespace pega seus datafiles
		--
		if r_tablespaces.contents <> 'TEMPORARY' then
			for r_datafiles in c_datafiles loop
				-- 
				-- Se for o primeiro datafile imprime a palavra "datafile"
				-- 
				if v_datafile_atual = 1 then
					dbms_output.put_line('datafile');
				end if;
				--
				dbms_output.put_line(''''||r_datafiles.file_name||'''');
				dbms_output.put_line(' size '||r_datafiles.kbytes||'k');
				dbms_output.put_line('autoextend '||r_datafiles.autoextend);
				--
				-- Se o datafile estiver com autoextend on imprime parametros de next e maxsize
				--
				if r_datafiles.autoextend = 'ON' then
					dbms_output.put_line('next '||(r_datafiles.increment_by*r_tablespaces.block_size)/1024||'k');
					dbms_output.put_line('maxsize '||r_datafiles.maxbytes_kb||'k');
				end if;
				--
				-- Se nao for o ultimo datafile, imprime uma virgula
				--
				if v_qtd_datafiles <> v_datafile_atual	then
					dbms_output.put_line(',');
				end if;
				--
				v_datafile_atual := v_datafile_atual + 1;
				--		
			end loop;
			--
		else
			--
			-- Verifica a quantidade de tempfiles do tablespace
			--
			select 
				count(*) 
			into
				v_qtd_datafiles
			from 
				dba_temp_files
			where
				tablespace_name = v_tablespace_name;
			--
			v_datafile_atual := 1;
			--
			for r_tempfiles in c_tempfiles loop
				-- 
				-- Se for o primeiro tempfile imprime a palavra "tempfile"
				-- 
				if v_datafile_atual = 1 then
					dbms_output.put_line('tempfile');
				end if;
				--
				dbms_output.put_line(''''||r_tempfiles.file_name||'''');
				dbms_output.put_line(' size '||r_tempfiles.kbytes||'k');
				dbms_output.put_line('autoextend '||r_tempfiles.autoextend);
				--
				-- Se o tempfile estiver com autoextend on imprime parametros de next e maxsize
				--
				if r_tempfiles.autoextend = 'ON' then
					dbms_output.put_line('next '||(r_tempfiles.increment_by*r_tablespaces.block_size)/1024||'k');
					dbms_output.put_line('maxsize '||r_tempfiles.maxbytes_kb||'k');
				end if;
				--
				-- Se nao for o ultimo tempfile, imprime uma virgula
				--
				if v_qtd_datafiles <> v_datafile_atual	then
					dbms_output.put_line(',');
				end if;
				--
				v_datafile_atual := v_datafile_atual + 1;
				--
			end loop;
			--			
		end if;
		--
		-- Se o tablespace for comum e tiver uniform size, imprime informacoes
		-- senao imprime informacoes sobre default storage
		--	
		if r_tablespaces.contents not in ('UNDO','TEMPORARY') then
			--
			if r_tablespaces.allocation_type = 'UNIFORM' then
				dbms_output.put_line('uniform size '||r_tablespaces.initial_extent_kb||'k');
			else
				dbms_output.put_line('default storage');
				dbms_output.put_line('(');
				dbms_output.put_line('initial '||r_tablespaces.initial_extent_kb||'k');
				--
				-- Se houver valor para next extent, imprime
				--
				if r_tablespaces.next_extent_kb is not null then
					dbms_output.put_line('next    extent '||r_tablespaces.next_extent_kb||'k');
				end if;
				dbms_output.put_line(')');
				--
			end if;
			--
			-- 
			-- Imprime informacoes sobre gerenciamento automatico de segmentos, logging, etc
			-- 
			dbms_output.put_line('segment space management '||r_tablespaces.segment_space_management);
			dbms_output.put_line(r_tablespaces.logging);
			--
		end if;
		--
		dbms_output.put_line(';');
		--
	end loop;
	--
end;
/
spool off