SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_met_GetAllServerEnvironment
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 02/18/2019   Aron E. Tekulsky    Initial Coding.
-- 02/18/2019   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	SELECT '1. Hardware Information' as [Report];

	SELECT cpu_count AS [Logical CPU Count]
			,hyperthread_ratio AS [Hyperthread Ratio]
			,cpu_count/hyperthread_ratio AS [Physical CPU Count]
			,[physical_memory_kb]/1024 AS [Physical Memory (MB)]
			----,[physical_memory_kb]/1048576 AS [Physical Memory (MB)]
			,sqlserver_start_time
		FROM sys.dm_os_sys_info OPTION (RECOMPILE);

	SELECT '2. Configuration values' as [Report];

	SELECT name as [Configuration Option]
			,value
			,value_in_use
			,[description]
		FROM sys.configurations
	ORDER BY name OPTION (RECOMPILE);


	SELECT '3. Filenames' as [Report];

	SELECT DB_NAME([database_id])AS [Database Name]
			,[file_id]
			,name as [Logical File Name]
			,physical_name as [Physical File name]
			,type_desc as [File Type]
			,state_desc as [File State]
			,CONVERT( bigint, size/128.0) AS [Total Size in MB]
		FROM sys.master_files
	WHERE [database_id] > 4
		AND [database_id] <> 32767
		OR [database_id] = 2
	ORDER BY DB_NAME([database_id]) OPTION (RECOMPILE);

	SELECT '4. DB log config info' as [Report];

	SELECT db.[name] AS [Database Name]
			,db.recovery_model_desc AS [Recovery Model]
			,db.log_reuse_wait_desc AS [Log Reuse Wait Description]
			,ls.cntr_value AS [Log Size (KB)]
			,lu.cntr_value AS [Log Used (KB)]
			,CAST(CAST(lu.cntr_value AS FLOAT) / CAST(ls.cntr_value AS FLOAT) AS DECIMAL(18,2)) * 100 AS [Log Used %]
			,db.[compatibility_level] AS [DB Compatibility Level]
			,db.page_verify_option_desc AS [Page Verify Option]
			,db.is_auto_create_stats_on
			,db.is_auto_update_stats_on
			,db.is_auto_update_stats_async_on
			,db.is_parameterization_forced
			,db.snapshot_isolation_state_desc
			,db.is_read_committed_snapshot_on
		FROM sys.databases AS db
			INNER JOIN sys.dm_os_performance_counters AS lu ON db.name = lu.instance_name
			INNER JOIN sys.dm_os_performance_counters AS ls ON db.name = ls.instance_name
	WHERE lu.counter_name LIKE N'Log File(s) Used Size (KB)%'
		AND ls.counter_name LIKE N'Log File(s) Size (KB)%'
		AND ls.cntr_value > 0 OPTION (RECOMPILE);

	IF exists (SELECT 1 FROM [master].[sys].[dm_fts_active_catalogs])
		BEGIN
			SELECT '5. Full text search usage' AS [Report]

			SELECT DB_NAME([database_id]) AS [Database]
					,[database_id]
					,[catalog_id]
					,[memory_address]
					,[name]
					,[is_paused]
					,[status]
					,[status_description]
					,[previous_status]
					,[previous_status_description]
					,[worker_count]
					,[active_fts_index_count]
					,[auto_population_count]
					,[manual_population_count]
					,[full_incremental_population_count]
					,[row_count_in_thousands]
					,[is_importing]
				FROM [master].[sys].[dm_fts_active_catalogs]
			ORDER BY DB_NAME([database_id])
		END
	ELSE
		SELECT '5. Full text search usage - Full Text Indexing is not used on this server' AS [Report];

		SELECT '6. Top waits' as [Report] ;
			WITH Waits AS
				(SELECT wait_type,wait_time_ms / 1000. AS wait_time_s,100. *
						wait_time_ms / SUM(wait_time_ms) OVER() AS pct,ROW_NUMBER()
						OVER(ORDER BY wait_time_ms DESC) AS rn
					FROM sys.dm_os_wait_stats
				WHERE wait_type NOT IN
					('CLR_SEMAPHORE','LAZYWRITER_SLEEP','RESOURCE_QUEUE','SLEEP_TASK' ,'SLEEP_SYSTEMTASK','SQLTRACE_BUFFER_FLUSH','WAITFOR',
						'LOGMGR_QUEUE','CHECKPOINT_QUEUE','REQUEST_FOR_DEADLOCK_SEARCH'
						,'XE_TIMER_EVENT','BROKER_TO_FLUSH','BROKER_TASK_STOP','CLR_MANUAL_EVENT','CLR_AUTO_EVENT','DISPATCHER_QUEUE_SEMAPHORE',
						'FT_IFTS_SCHEDULER_IDLE_WAIT', 'XE_DISPATCHER_WAIT',
						'XE_DISPATCHER_JOIN', 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP'))
				SELECT W1.wait_type,CAST(W1.wait_time_s AS DECIMAL(12, 2)) AS wait_time_s
						,CAST(W1.pct AS DECIMAL(12, 2)) AS pct,CAST(SUM(W2.pct) AS DECIMAL(12, 2)) AS running_pct
					FROM Waits AS W1
						INNER JOIN Waits AS W2 ON W2.rn <= W1.rn
				GROUP BY W1.rn, W1.wait_type, W1.wait_time_s, W1.pct
				HAVING SUM(W2.pct) - W1.pct < 99 OPTION (RECOMPILE);

	SELECT '7. Signal Waits' as [Report];

	SELECT CAST(100.0 * SUM(signal_wait_time_ms) / SUM (wait_time_ms) AS NUMERIC(20,2)) AS [%signal (cpu) waits],CAST(100.0 *
			SUM(wait_time_ms - signal_wait_time_ms) / SUM (wait_time_ms) AS NUMERIC(20,2)) AS [%resource waits]
		FROM sys.dm_os_wait_stats OPTION (RECOMPILE);

	SELECT '8. CPU Utilization' as [Report];

	DECLARE @ts_now bigint = 
		(SELECT cpu_ticks/(cpu_ticks/ms_ticks)
			FROM sys.dm_os_sys_info);
	
	SELECT TOP(144) SQLProcessUtilization AS [SQL Server Process CPU Utilization], SystemIdle AS [System Idle Process],
			100 - SystemIdle - SQLProcessUtilization AS [Other Process CPU Utilization]
			,DATEADD(ms, -1 * (@ts_now - [timestamp]),
			GETDATE()) AS [Event Time]
		FROM
			( SELECT record.value('(./Record/@id)[1]', 'int') AS record_id,
					record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS [SystemIdle]
					,record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]','int') AS [SQLProcessUtilization],
					[timestamp]
				FROM
					(SELECT [timestamp],CONVERT(xml, record) AS [record]
						FROM sys.dm_os_ring_buffers
					WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
						AND record LIKE N'%<SystemHealth>%') AS x) AS y
					ORDER BY record_id DESC OPTION (RECOMPILE);


	SELECT '9. CPU Utilization 2005 Only' as [Report];

	------DECLARE @ts_now bigint;
	
	SET @ts_now = 
		------(SELECT cpu_ticks / CONVERT(float, cpu_ticks_in_ms)
		(SELECT cpu_ticks / CONVERT(float, cpu_ticks)
			FROM sys.dm_os_sys_info);

	SELECT TOP(144) SQLProcessUtilization AS [SQL Server Process CPU Utilization],SystemIdle AS [System Idle Process],100 - SystemIdle - SQLProcessUtilization AS [Other Process CPU Utilization],
			DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) AS [Event Time]
		FROM
			(SELECT record.value('(./Record/@id)[1]', 'int') AS record_id,
					record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS [SystemIdle],
					record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]','int') AS [SQLProcessUtilization],
					[timestamp]
				FROM (SELECT [timestamp],CONVERT(xml, record) AS [record]
						FROM sys.dm_os_ring_buffers
			WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
				AND record LIKE '%<SystemHealth>%') AS x) AS y
		ORDER BY record_id DESC OPTION (RECOMPILE);

	SELECT '10. Avg Task Counts' as [Report];

	SELECT AVG(current_tasks_count) AS [Avg Task Count]
			,AVG(runnable_tasks_count) AS [Avg Runnable Task Count]
			,AVG(pending_disk_io_count) AS [AvgPendingDiskIOCount]
		FROM sys.dm_os_schedulers WITH (NOLOCK)
	WHERE scheduler_id < 255 OPTION (RECOMPILE);


	SELECT '11. IO Stalls' as [Report];

	SELECT DB_NAME(fs.database_id) AS [Database Name]
			,mf.physical_name
			,io_stall_read_ms
			,num_of_reads
			,CAST(io_stall_read_ms/(1.0 + num_of_reads) AS NUMERIC(10,1)) AS [avg_read_stall_ms]
			,io_stall_write_ms
			,num_of_writes
			,CAST(io_stall_write_ms/(1.0+num_of_writes) AS NUMERIC(10,1)) AS [avg_write_stall_ms]
			,io_stall_read_ms + io_stall_write_ms AS [io_stalls]
			,num_of_reads + num_of_writes AS [total_io]
			,CAST((io_stall_read_ms + io_stall_write_ms)/(1.0 +
			num_of_reads + num_of_writes) AS NUMERIC(10,1)) AS [avg_io_stall_ms]
		FROM sys.dm_io_virtual_file_stats(null,null) AS fs
			INNER JOIN sys.master_files AS mf ON fs.database_id = mf.database_id
											AND fs.[file_id] = mf.[file_id]
	ORDER BY avg_io_stall_ms DESC OPTION (RECOMPILE);

	SELECT '12. Pending Disk IO Counts' as [Report];

	SELECT cpu_id, pending_disk_io_count
		FROM sys.dm_os_schedulers
	WHERE [status] = 'VISIBLE ONLINE'
	ORDER BY cpu_id;
	
	SELECT '13. Average Pending Disk IO Counts' as [Report];

	SELECT AVG(pending_disk_io_count) AS [AvgPendingDiskIOCount]
		FROM sys.dm_os_schedulers
	WHERE [status] = 'VISIBLE ONLINE';

	SELECT '14. Waits' as [Report];

	SELECT wait_type, waiting_tasks_count, wait_time_ms,
			signal_wait_time_ms,
			wait_time_ms - signal_wait_time_ms AS [io_wait_time_ms]
		FROM sys.dm_os_wait_stats
	WHERE wait_type IN('PAGEIOLATCH_EX', 'PAGEIOLATCH_SH','PAGEIOLATCH_UP')
	ORDER BY wait_type;

	WITH DBIO AS
		(SELECT DB_NAME(IVFS.database_id) AS db,
				CASE WHEN MF.type = 1 THEN 'log' ELSE 'data' END AS file_type,
				SUM(IVFS.num_of_bytes_read + IVFS.num_of_bytes_written) AS io,
				SUM(IVFS.io_stall) AS io_stall
			FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS IVFS
				INNER JOIN sys.master_files AS MF ON IVFS.database_id = MF.database_id
					AND IVFS.file_id = MF.file_id
		GROUP BY DB_NAME(IVFS.database_id), MF.[type])

	SELECT db, file_type,
			CAST(1. * io / (1024 * 1024) AS DECIMAL(12, 2)) AS io_mb,
			CAST(io_stall / 1000. AS DECIMAL(12, 2)) AS io_stall_s,
			CAST(100. * io_stall / SUM(io_stall) OVER() AS DECIMAL(10, 2)) AS io_stall_pct,
			ROW_NUMBER() OVER(ORDER BY io_stall DESC) AS rn
		FROM DBIO
	ORDER BY io_stall DESC;

----------	USE DB_NAME(DB_ID);
----------GO

	SELECT '15. Top Cached SPs & Physical reads relate to disk I/O pressure' as [Report];

-- Top Cached SPs By Total Physical Reads (SQL 2008).
-- Physical reads relate to disk I/O pressure
	SELECT TOP(25) p.name AS [SP Name],qs.total_physical_reads AS [TotalPhysicalReads],
			qs.total_physical_reads/qs.execution_count AS [AvgPhysicalReads],
			qs.execution_count,
			ISNULL(qs.execution_count/DATEDIFF(Second, qs.cached_time,
			GETDATE()), 0) AS [Calls/Second],
			qs.total_elapsed_time, qs.total_elapsed_time/qs.execution_count AS [avg_elapsed_time],
			qs.cached_time
		FROM sys.procedures AS p
			INNER JOIN sys.dm_exec_procedure_stats AS qs ON (p.[object_id] = qs.[object_id])
	WHERE qs.database_id = DB_ID()
	ORDER BY qs.total_physical_reads DESC;

	SELECT '16. Top Cached SPs & Logical writes relate to disk I/O pressure' as [Report];

-- Top Cached SPs By Total Logical Writes (SQL 2008).
-- Logical writes relate to both memory and disk I/O pressure
	SELECT TOP(25) p.name AS [SP Name], qs.total_logical_writes AS
			[TotalLogicalWrites],
			qs.total_logical_writes/qs.execution_count AS [AvgLogicalWrites],
			qs.execution_count,
			ISNULL(qs.execution_count/DATEDIFF(Second, qs.cached_time,
			GETDATE()), 0) AS [Calls/Second],
			qs.total_elapsed_time, qs.total_elapsed_time/qs.execution_count AS
			[avg_elapsed_time],
			qs.cached_time
		FROM sys.procedures AS p
			INNER JOIN sys.dm_exec_procedure_stats AS qs ON (p.[object_id] = qs.[object_id])
	WHERE qs.database_id = DB_ID()
	ORDER BY qs.total_logical_writes DESC;

	SELECT '17. top statements by average input/output usage for the current database' as [Report];

-- Lists the top statements by average input/output usage for the current database
	SELECT TOP(50) OBJECT_NAME(qt.objectid) AS [SP Name],
			(qs.total_logical_reads + qs.total_logical_writes)/qs.execution_count AS [Avg IO],
			SUBSTRING(qt.[text],qs.statement_start_offset/2,
			(CASE
				WHEN qs.statement_end_offset = -1
				THEN LEN(CONVERT(nvarchar(max), qt.[text])) * 2
				ELSE qs.statement_end_offset
			END - qs.statement_start_offset)/2) AS [Query Text]
		FROM sys.dm_exec_query_stats AS qs
			CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
	WHERE qt.[dbid] = DB_ID()
	ORDER BY [Avg IO] DESC;

	SELECT '18. Memory Status' as [Report];

	SELECT total_physical_memory_kb
			, available_physical_memory_kb
			,total_page_file_kb
			,available_page_file_kb
			,system_memory_state_desc
		FROM sys.dm_os_sys_memory OPTION (RECOMPILE);

	SELECT '19. SQLServer Process Address Space' as [Report];

	SELECT physical_memory_in_use_kb
			,locked_page_allocations_kb
			,page_fault_count
			,memory_utilization_percentage
			,available_commit_limit_kb
			,process_physical_memory_low
			,process_virtual_memory_low
		FROM sys.dm_os_process_memory OPTION (RECOMPILE);

	SELECT '20. Tot Buffer by DB' as [Report];

	SELECT DB_NAME(database_id) AS [Database Name]
			,COUNT(*) * 8/1024.0 AS [Cached Size (MB)]
		FROM sys.dm_os_buffer_descriptors
	WHERE database_id > 4 -- system databases
		AND database_id <> 32767 -- ResourceDB
	GROUP BY DB_NAME(database_id)
	ORDER BY [Cached Size (MB)] DESC;

	SELECT '21. Page Life Expectancy' as [Report];

	DECLARE @PerfCounterObjectName nchar(128);

	IF @@SERVICENAME = 'MSSQLSERVER'
		Select @PerfCounterObjectName = N'SQLServer:Buffer Manager'
	ELSE
		Select @PerfCounterObjectName = N'MSSQL$' + @@SERVICENAME + N':Buffer Manager';

	SELECT cntr_value AS [Page Life Expectancy]
		FROM sys.dm_os_performance_counters
	WHERE [object_name] = @PerfCounterObjectName
		AND counter_name = N'Page life expectancy' OPTION (RECOMPILE);

	SELECT '22. Memory Clerk Usage' as [Report];

	SELECT TOP(10) [type] AS [Memory Clerk Type]
			------,SUM(single_pages_kb) AS [SPA Mem, Kb]
			,SUM(pages_kb) AS [SPA Mem, Kb]
		FROM sys.dm_os_memory_clerks
	GROUP BY [type]
	ORDER BY SUM(pages_kb) DESC OPTION (RECOMPILE);
	----ORDER BY SUM(single_pages_kb) DESC OPTION (RECOMPILE);

	SELECT '23. Plan Cache Summary' as [Report];

	SELECT objtype AS [CacheType]
			, count_big(*) AS [Total Plans]
			, sum(cast(size_in_bytes as decimal(18,2)))/1024/1024 AS [Total MBs]
			, avg(usecounts) AS [Avg Use Count]
			, sum(cast(
				(CASE
					WHEN usecounts = 1 THEN size_in_bytes
					ELSE 0
				END) as decimal(18,2)))/1024/1024 AS [Total MBs - USE Count 1]
			, sum
				(CASE
					WHEN usecounts = 1 THEN 1
					ELSE 0
				END) AS [Total Plans – USE Count 1]
		FROM sys.dm_exec_cached_plans
	GROUP BY objtype
	ORDER BY [Total MBs - USE Count 1] DESC;

	SELECT '24. Plan Cache Summary' as [Report];

	SELECT objtype AS [CacheType]
			, count_big(*) AS [Total Plans]
			, sum(cast(size_in_bytes as decimal(18,2)))/1024/1024 AS [Total MBs]
			, avg(usecounts) AS [Avg Use Count]
			, sum(cast((CASE 
							WHEN usecounts = 1 THEN size_in_bytes 
							ELSE 0
						END) as decimal(18,2)))/1024/1024 AS [Total MBs - USE Count 1]
			, sum(CASE WHEN usecounts = 1 THEN 1 ELSE 0 END) AS [Total Plans - USE Count 1]
		FROM sys.dm_exec_cached_plans
	GROUP BY objtype
	ORDER BY [Total MBs - USE Count 1] DESC;

	SELECT '25. Ad-hoc Query Bloat' as [Report];

	SELECT TOP(20) [text] AS [QueryText]
			,cp.size_in_bytes
		FROM sys.dm_exec_cached_plans AS cp
			CROSS APPLY sys.dm_exec_sql_text(plan_handle)
	WHERE cp.cacheobjtype = N'Compiled Plan'
		AND cp.objtype = N'Adhoc'
		AND cp.usecounts = 1
	ORDER BY cp.size_in_bytes DESC OPTION (RECOMPILE);

END


GO
