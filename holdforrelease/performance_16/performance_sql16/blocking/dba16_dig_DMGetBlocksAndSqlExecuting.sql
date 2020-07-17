SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_dig_DMGetBlocksAndSqlExecuting
--
--
-- Calls:		None
--
-- Description:	Get a list of blocks and sql executing on the db server.
-- 
-- Date			Modified By			Changes
-- 11/09/2016   Aron E. Tekulsky    Initial Coding.
-- 08/07/2018	Aron E. Tekulsky	add query plan.
-- 05/08/2019   Aron E. Tekulsky    Update to Version 140.
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

	SELECT SPID = er.session_id
			,BlkBy = er.blocking_session_id
			,TotalElapsedTimeMs = er.total_elapsed_time
			,StartTime = er.start_time
			,STATUS = er.STATUS
			,transaction_isolation = CASE ses.transaction_isolation_level
				WHEN 0
					THEN 'Unspecified'
				WHEN 1
					THEN 'Read Uncommitted'
				WHEN 2
					THEN 'Read Committed'
				WHEN 3
					THEN 'Repeatable'
				WHEN 4
					THEN 'Serializable'
				WHEN 5
					THEN 'Snapshot'
				END
			,WaitType = er.last_wait_type
			,WaitTimeMs = er.wait_time
			,LastWaitType = er.last_wait_type
			,CPU = er.cpu_time
			,IOReads = er.logical_reads + er.reads
			,IOWrites = er.writes
			,Executions = ec.execution_count
			,OpenTranCount = er.open_transaction_count
			,CommandType = er.command
			,ObjectName = OBJECT_SCHEMA_NAME(qt.objectid, qt.dbid) + '.' + OBJECT_NAME(qt.objectid, qt.dbid)
			,SQLStatement = qt.TEXT
		----------SUBSTRING
		---------- (
		---------- qt.text, er.statement_start_offset/2, (CASE WHEN
		------------er.statement_end_offset = - 1 THEN LEN(CONVERT(NVARCHAR(MAX), qt.TEXT)) * 2
		---------- ELSE
		------------er.statement_end_offset
		---------- END -
		------------er.statement_start_offset ) / 2
		---------- )
			,SessSTATUS = ses.STATUS
			,[Login] = ses.login_name
			,Host = ses.host_name
			,DBName = DB_Name(er.database_id)
			,Protocol = con.net_transport
			,ConnectionWrites = con.num_writes
			,ConnectionReads = con.num_reads
			,ClientAddress = con.client_net_address
			,Authentication = con.auth_scheme
			,ProgramName = ses.program_name
			,NTUserName = ses.nt_user_name
			,OrigLoginName = ses.original_login_name
			,RowCounts = ses.row_count
			,DeadLockPriority = ses.DEADLOCK_PRIORITY
			,LockTimeOut = ses.LOCK_TIMEOUT
			,SesLReads = ses.logical_reads
			,SesWrts = ses.writes
			,SesReads = ses.reads
			,Mem8KbP = ses.memory_usage
			,CpuTimMs = ses.cpu_time
			,LoginTime = con.connect_time
			,NetPacketSize = con.net_packet_size
			,ClntInterfaceName = ses.client_interface_name
			,ConnectTime = con.connect_time
			,ProtocolType = con.protocol_type
		------,l.request_lifetime
			,l.request_mode
			,l.request_status
			,l.request_type
			,l.resource_type
			,l.request_owner_type
	------,l.resource_description
	------,l.resource_lock_partition
			,p.query_plan
		FROM sys.dm_exec_requests er
			LEFT JOIN sys.dm_exec_sessions ses ON ses.session_id = er.session_id
			LEFT JOIN sys.dm_exec_connections con ON con.session_id = ses.session_id
	-- aet
			LEFT JOIN sys.dm_tran_locks l ON (l.request_session_id = er.session_id)
	-- aet
			CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) AS qt
			OUTER APPLY (
				SELECT execution_count = MAX(cp.usecounts)
					FROM sys.dm_exec_cached_plans cp
				WHERE cp.plan_handle = er.plan_handle
				) ec
			CROSS APPLY sys.dm_exec_query_plan(er.plan_handle) p
	------WHERE er.blocking_session_id > 0 OR ses.open_transaction_count > 0
	WHERE er.blocking_session_id <> 0 OR ses.open_transaction_count > 0
	----WHERE er.blocking_session_id <> 0
	ORDER BY er.blocking_session_id ASC, er.session_id ASC, er.logical_reads + er.reads DESC;

END
GO
