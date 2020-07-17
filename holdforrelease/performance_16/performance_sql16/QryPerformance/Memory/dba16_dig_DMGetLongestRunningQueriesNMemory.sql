SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_dig_DMGetLongestRunningQueriesNMemory
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 02/08/2018   Aron E. Tekulsky    Initial Coding.
-- 02/08/2018   Aron E. Tekulsky    Update to V140.
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

	SELECT r.session_id, r.start_time, TotalElapsedTime_ms = r.total_elapsed_time, r.[status]
			,r.command, DatabaseName = DB_Name(r.database_id), r.wait_type, r.last_wait_type
			,r.wait_resource, r.cpu_time, r.reads, r.writes, r.logical_reads, t.[text] AS [executing batch]
			,SUBSTRING(t.[text], r.statement_start_offset / 2, 
				 (CASE WHEN r.statement_end_offset = -1 THEN DATALENGTH (t.[text]) 
						 ELSE r.statement_end_offset 
					END - r.statement_start_offset ) / 2) AS [executing statement] 
			, p.query_plan
		FROM sys.dm_exec_requests r
			CROSS APPLY	sys.dm_exec_sql_text(r.sql_handle) AS t
			CROSS APPLY	sys.dm_exec_query_plan(r.plan_handle) AS p
	ORDER BY r.total_elapsed_time DESC;
END
GO
