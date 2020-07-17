SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_met_DMGetActiveBlockingConnectio
--
--
-- Calls:		None
--
-- Description:	Get a list of active blocking connections.
-- 
-- Date			Modified By			Changes
-- 02/19/2014   Aron E. Tekulsky    Initial Coding.
-- 02/13/2018   Aron E. Tekulsky    Update to V140.
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

	SELECT	
			----------, BS.login_name
			----------, BS.login_time
			R.session_id
			, R.blocking_session_id
			, R.start_time -- when teh request arrived.
			, R.status
			, CASE s.transaction_isolation_level
				WHEN 0 THEN 'Unspecified'
				WHEN 1 THEN 'Read Uncommitted'
				WHEN 2 THEN 'Read Committed'
				WHEN 3 THEN 'Repeatable'
				WHEN 4 THEN 'Serializable'
				WHEN 5 THEN 'Snapshot'
			END AS transaction_isolation
			, r.last_wait_type
			, r.wait_time AS WaitTimeMs
			------, r.last_wait_type AS LastWaitType
			, r.cpu_time AS CPU
			, IOReads = r.logical_reads + r.reads
			, r.writes AS IOWrite
			------------, p.execution_count AS Executions
			, r.open_transaction_count AS OpenTranCount
			, R.command AS CommandType
			--------, R.cpu_time
			--------, R.reads
			--------, R.writes
			--------, R.logical_reads
			--------, R.database_id
			, DB_NAME(R.database_id) as database_name
			, C.connect_time
			, C.net_transport
			, C.protocol_type
			, C.client_net_address
			,q.text AS SQLStmt
			,p.query_plan 
			,S.login_name
			, S.login_time
			, s.host_name AS Host
			, c.net_transport AS Protocol
			, c.num_writes AS ConnectionWrites
			, c.num_reads AS ConnectionReads
			, c.client_net_address AS ClientAddress
			, c.auth_scheme AS Authentication
		FROM sys.dm_exec_requests R
			INNER JOIN sys.dm_exec_sessions S on R.session_id = S.session_id
			INNER JOIN sys.dm_exec_connections C on R.connection_id = C.connection_id
			LEFT JOIN sys.dm_exec_sessions BS on R.blocking_session_id = BS.session_id
			CROSS APPLY sys.dm_exec_sql_text(R.sql_handle) as q
			CROSS APPLY sys.dm_exec_query_plan(R.plan_handle) p
WHERE R.status = 'suspended';

END
GO
