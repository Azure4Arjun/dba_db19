SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_met_DMWorstPerformingCPUBoundQueriesSP
--
--
-- Calls:		None
--
-- Description:	Worst performing CPU bound queries.
--
-- note: Requires View Server State permissions.
--
-- Note: Requires View Server State permissions.
-- https://www.sqlpassion.at/archive/2015/04/20/how-to-find-your-worst-performing-sql-server-queries/
--
-- Date			Modified By			Changes
-- 01/26/2018   Aron E. Tekulsky    Initial Coding.
-- 01/26/2018   Aron E. Tekulsky    Update to V140.
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

-- Worst performing CPU bound queries
	SELECT TOP 5
			st.text,
			qp.query_plan,
			qs.statement_start_offset ,
			qs.statement_end_offset ,
			qs.plan_generation_num ,
			qs.creation_time,
			qs.last_execution_time,
			qs.execution_count,
			qs.total_worker_time,
			qs.last_worker_time,
			qs.min_worker_time,
			qs.max_worker_time,
			qs.total_physical_reads,
			qs.last_physical_reads,
			qs.min_physical_reads,
			qs.max_physical_reads,
			qs.total_logical_writes,
			qs.last_logical_writes,
			qs.min_logical_writes,
			qs.min_logical_writes,
			qs.total_logical_reads,
			qs.last_logical_reads,
			qs.min_logical_reads,
			qs.max_logical_reads,
			qs.total_clr_time,
			qs.last_clr_time,
			qs.min_clr_time,
			qs.max_clr_time,
			qs.total_elapsed_time,
			qs.last_elapsed_time,
			qs.total_rows,
			qs.last_rows,
			qs.min_rows,
			qs.max_rows,
			qs.total_dop,
			qs.last_dop,
			qs.min_dop,
			qs.max_dop,
			qs.total_grant_kb,
			qs.last_grant_kb,
			qs.min_grant_kb,
			qs.max_grant_kb,
			qs.total_used_grant_kb,
			qs.last_used_grant_kb,
			qs.min_used_grant_kb,
			qs.max_used_grant_kb,
			qs.total_ideal_grant_kb,
			qs.last_ideal_grant_kb,
			qs.min_ideal_grant_kb,
			qs.max_ideal_grant_kb,
			qs.total_reserved_threads,
			qs.last_reserved_threads,
			qs.min_reserved_threads,
			qs.max_reserved_threads,
			qs.total_used_threads,
			qs.last_used_threads,
			qs.min_used_threads,
			qs.max_used_threads
		FROM sys.dm_exec_query_stats qs
			CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) st
			CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
	ORDER BY total_worker_time DESC;

END
GO
