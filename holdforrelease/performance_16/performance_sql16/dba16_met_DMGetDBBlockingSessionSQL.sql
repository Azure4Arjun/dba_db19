SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_met_DMGetDBBlockingSessionSQL
--
--
-- Calls:		None
--
-- Description:	Get a listing of the blocking sessions with SQL causing the blocking.
-- 
-- Date			Modified By			Changes
-- 08/01/2018   Aron E. Tekulsky    Initial Coding.
-- 08/01/2018   Aron E. Tekulsky    Update to Version 140.
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

	SELECT r.session_id as Session_id
			,r.blocking_session_id
			,r.command,
			r.start_time
			,r.status
			,r.database_id
			,r.user_id
			,r.wait_type
			,r.wait_time
			,r.last_wait_type
			,r.wait_resource
			,r.open_transaction_count
			,r.transaction_id
			,r.reads
			,r.writes
			,r.logical_reads
			,CASE r.transaction_isolation_level
				WHEN 0 THEN 'Unspecified'
				WHEN 1 THEN 'ReadCommitted'
				WHEN 2 THEN 'ReadCimmitted'
				WHEN 3 THEN 'Repeatable'
				WHEN 4 THEN 'Serializable'
				WHEN 5 THEN 'Snapshot'
				END AS TransactionIsolation
				,r.lock_timeout
				,r.deadlock_priority,
				( SELECT SUBSTRING(TEXT, r.statement_start_offset / 2,
						CASE
							WHEN r.statement_end_offset = -1 THEN 1000
								ELSE (r.statement_end_offset - r.statement_start_offset) / 2
								END) 'Statement text'
					FROM sys.dm_exec_sql_text(sql_handle)
				)
			,query_plan 
		FROM sys.dm_exec_requests r
			CROSS APPLY sys.dm_exec_query_plan (r.plan_handle)
	WHERE (r.blocking_session_id > 0) OR ((r.blocking_session_id = 0 AND r.command IN ('INSERT','UPDATE','DELETE','SELECT','BACKUP','RESTORE')))
	ORDER BY r.blocking_session_id ASC;

END
--GO
