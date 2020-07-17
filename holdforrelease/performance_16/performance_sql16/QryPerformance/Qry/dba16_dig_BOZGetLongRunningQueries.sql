SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_dig_BOZGetLongRunningQueries
--
--
-- Calls:		None
--
-- Description:	identify the individual queries that are taking a long time to run.
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

	SELECT  st.text, qp.query_plan, qs.*
		FROM    (
			SELECT  TOP 50 *
				FROM    sys.dm_exec_query_stats
			ORDER BY total_worker_time DESC
			) AS qs
			CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
			CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
	WHERE qs.max_worker_time > 300
		OR qs.max_elapsed_time > 300
END
GO
