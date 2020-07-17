SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_GetBlocksandExecutionSql
--
--
-- Calls:		None
--
-- Description:	Get a listing of blocks and executing SQL.
-- 
-- Date			Modified By			Changes
-- 08/27/2013   Aron E. Tekulsky    Initial Coding.
-- 12/11/2017   Aron E. Tekulsky    Update to Version 140.
-- 10/04/2019	Aron E. Tekulsky	Add query plan.
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

	SELECT	SPID = er.session_id
			,BlkBy = er.blocking_session_id
			,ElapsedMS = er.total_elapsed_time
			,CPU = er.cpu_time
			,IOReads = er.logical_reads + er.reads
			,IOWrites = er.writes
			,Executions = ec.execution_count
			,CommandType = er.command
			,ObjectName = OBJECT_SCHEMA_NAME(qt.objectid,qt.dbid) + '.' + OBJECT_NAME(qt.objectid, qt.dbid)
			,SQLStatement =
			SUBSTRING(qt.text, er.statement_start_offset/2, (
			CASE 
				WHEN er.statement_end_offset = -1 THEN 
					LEN(CONVERT(nvarchar(MAX),qt.text)) * 2
				ELSE
					er.statement_end_offset
				END - er.statement_start_offset)/2)
			,STATUS = ses.STATUS
			,[Login] = ses.login_name
			,Host = ses.host_name
			,DBName = DB_Name(er.database_id)
			,LastWaitType = er.last_wait_type
			,StartTime = er.start_time
			,Protocol = con.net_transport
			,transaction_isolation =
			CASE ses.transaction_isolation_level
				WHEN 0 THEN 'Unspecified'
				WHEN 1 THEN 'Read Uncommitted'
				WHEN 2 THEN 'Read Committed'
				WHEN 3 THEN 'Repeatable'
				WHEN 4 THEN 'Serializable'
				WHEN 5 THEN 'Snapshot'
			END
			,ConnectionWrites = con.num_writes
			,ConnectionReads = con.num_reads
			,ClientAddress = con.client_net_address
			,Authentication = con.auth_scheme
			,qp.query_plan 
				FROM sys.dm_exec_requests er
					LEFT JOIN sys.dm_exec_sessions ses ON ses.session_id = er.session_id
					LEFT JOIN sys.dm_exec_connections con ON con.session_id = ses.session_id
					CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) AS qt
					OUTER APPLY (SELECT execution_count = MAX(cp.usecounts)
									FROM sys.dm_exec_cached_plans cp
								WHERE cp.plan_handle = er.plan_handle) ec
					CROSS APPLY sys.dm_exec_query_plan (er.plan_handle) as qp
			WHERE er.blocking_session_id <> 0
			ORDER BY er.blocking_session_id DESC, er.logical_reads + er.reads DESC, er.session_id
END
GO
