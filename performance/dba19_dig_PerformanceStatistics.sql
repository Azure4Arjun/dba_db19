SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_dig_PerformanceStatistics
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 01/18/2019   Aron E. Tekulsky    Initial Coding.
-- 05/09/2019   Aron E. Tekulsky    Update to Version 140.
--  09/26/2019	Aron E. Tekulsky	Add DMV to display the query Plan.
-- 08/11/2020   Aron E. Tekulsky    Update to Version 150.
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
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT COALESCE(DB_NAME(t.[dbid]), 'Unknown') AS [DB Name]
		,ecp.objtype AS [Object Type]
		,t.[text] AS [Adhoc Batch or Object Call]
		,SUBSTRING(t.[text], (qs.[statement_start_offset] / 2) + 1, (
				(
					CASE qs.[statement_end_offset]
						WHEN - 1
							THEN DATALENGTH(t.[text])
						ELSE qs.[statement_end_offset]
						END - qs.[statement_start_offset]
					) / 2
				) + 1) AS [Executed Statement]
		,qs.[execution_count] AS [Counts]
		,qs.[total_worker_time] AS [Total Worker Time]
		,(qs.[total_worker_time] / qs.[execution_count]) AS [Avg Worker Time]
		,qs.[total_physical_reads] AS [Total Physical Reads]
		,(qs.[total_physical_reads] / qs.[execution_count]) AS [Avg Physical Reads]
		,qs.[total_logical_writes] AS [Total Logical Writes]
		,(qs.[total_logical_writes] / qs.[execution_count]) AS [Avg Logical Writes]
		,qs.[total_logical_reads] AS [Total Logical Reads]
		,(qs.[total_logical_reads] / qs.[execution_count]) AS [Avg Logical Reads]
		,qs.[total_clr_time] AS [Total CLR Time]
		,(qs.[total_clr_time] / qs.[execution_count]) AS [Avg CLR Time]
		,qs.[total_elapsed_time] AS [Total Elapsed Time]
		,(qs.[total_elapsed_time] / qs.[execution_count]) AS [Avg Elapsed Time]
		,qs.[last_execution_time] AS [Last Exec Time]
		,qs.[creation_time] AS [Creation Time]
		,p.query_plan
	FROM sys.dm_exec_query_stats AS qs
		JOIN sys.dm_exec_cached_plans ecp ON qs.plan_handle = ecp.plan_handle
		CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS t
		CROSS APPLY sys.dm_exec_query_plan(ecp.plan_handle) p
	-- ORDER BY [Total Worker Time] DESC
	-- ORDER BY [Total Physical Reads] DESC
	-- ORDER BY [Total Logical Writes] DESC
	-- ORDER BY [Total Logical Reads] DESC
	-- ORDER BY [Total CLR Time] DESC
	-- ORDER BY [Total Elapsed Time] DESC
	ORDER BY [Counts] DESC

END
GO
