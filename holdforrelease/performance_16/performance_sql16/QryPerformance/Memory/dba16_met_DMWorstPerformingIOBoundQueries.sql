SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_met_DMWorstPerformingIOBoundQueries
--
--
-- Calls:		None
--
-- Description:	Worst performing I/O bound queries.
--
-- note: Requires View Server State permissions.
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

-- Worst performing I/O bound queries
	SELECT TOP 5
			st.text,
			qp.query_plan,
			qs.*
		FROM sys.dm_exec_query_stats qs
			CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) st
			CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
	ORDER BY total_logical_reads DESC;

END
GO
