SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_dig_DMGetQryPlans
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 04/26/2019   Aron E. Tekulsky    Initial Coding.
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

	SELECT TOP 10 databases.name
			,st.TEXT AS TSQL_Text
			,qs.creation_time
			,qs.execution_count
			,qs.total_worker_time AS total_cpu_time
			,qs.total_elapsed_time
			,qs.total_logical_reads
			,qs.total_physical_reads
			,qp.query_plan
		FROM sys.dm_exec_query_stats qs
			CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) AS st
			CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
			INNER JOIN sys.databases ON (st.dbid = databases.database_id)
	WHERE st.TEXT LIKE '%SELECT max(ep.pp_end) FROM asgnmt_master
			am, asgnmt a, employee e, employee_periods ep, employee_period_versions epv,
			time_sheet ts, policy_profile_master ppm%';
	--where databases.database_id = db_id() ;

END
GO
