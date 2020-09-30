SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_stt_GetDmvQueryStats
--
--
-- Calls:		None
--
-- Description:	Get query statss for all running queries.
--				On SQL Database Premium Tiers requires the VIEW DATABASE STATE
--				permission in the database.
--
--				Note: Requires VIEW SERVER STATE permission.
-- 
-- Date			Modified By			Changes
-- 08/27/2013   Aron E. Tekulsky    Initial Coding.
-- 12/11/2017   Aron E. Tekulsky    Update to Version 140.
-- 08/13/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
--
--  This code and information are provided "AS IS" without warranty of
--  any kind, either expressed or implied, including but not limited
--  to the implied warranties of merchantability and/or fitness for a
--  particular purpose.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @objtype nvarchar(16)

-- initialize
	SET @objtype = 'Adhoc' -- Adhoc, Prepared, Proc, ReplProc, Trigger, View, Default, UsrTab, SysTab, Check, Rule

	SELECT COALESCE(DB_NAME(t.[dbid]),'Unknown') AS [DB Name],
			ecp.objtype AS [Object Type], t.[text] AS [Adhoc Batch or ObjectCall],
			SUBSTRING(t.[text], (qs.[statement_start_offset]/2) + 1,
			((CASE qs.[statement_end_offset]
				WHEN -1 THEN
					DATALENGTH(t.[text])
				ELSE
					qs.[statement_end_offset]
				END - qs.[statement_start_offset])/2) + 1) AS [Executed Statement]
			, qs.[execution_count] AS [Counts]
			, qs.[total_worker_time] AS [Total Worker Time], (qs.[total_worker_time] / qs.[execution_count])
				AS [Avg Worker Time]
			, qs.[total_physical_reads] AS [Total Physical Reads]
			, (qs.[total_physical_reads] / qs.[execution_count]) AS [Avg PhysicalReads]
			, qs.[total_logical_writes] AS [Total Logical Writes]
			, (qs.[total_logical_writes] / qs.[execution_count]) AS [Avg LogicalWrites]
			, qs.[total_logical_reads] AS [Total Logical Reads]
			,(qs.[total_logical_reads] / qs.[execution_count]) AS [Avg LogicalReads]
			, qs.[total_clr_time] AS [Total CLR Time], (qs.[total_clr_time] / qs.[execution_count]) AS [Avg CLR Time]
			, qs.[total_elapsed_time] AS [Total Elapsed Time], (qs.[total_elapsed_time] / qs.[execution_count])
				AS [Avg Elapsed Time]
			, qs.[last_execution_time] AS [Last Exec Time], qs.[creation_time] AS [Creation Time]
		FROM sys.dm_exec_query_stats AS qs
			JOIN sys.dm_exec_cached_plans ecp ON qs.plan_handle = ecp.plan_handle
			CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS t
	WHERE ecp.objtype = @objtype
--			ORDER BY [Total Worker Time] DESC
--			ORDER BY [Total Physical Reads] DESC
--			ORDER BY [Total Logical Writes] DESC
--			ORDER BY [Total Logical Reads] DESC
--			ORDER BY [Total CLR Time] DESC
--			ORDER BY [Total Elapsed Time] DESC
	ORDER BY [Counts] DESC;

END
GO
