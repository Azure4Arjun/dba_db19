SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_dig_DMGetSQLPlan
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 05/06/2019   Aron E. Tekulsky    Initial Coding.
-- 05/06/2019   Aron E. Tekulsky    Update to Version 140.
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

--WARNING! ERRORS ENCOUNTERED DURING SQL PARSING!
	SELECT SUBSTRING(dest.TEXT, (der.statement_start_offset / 2) + 1, (
			CASE der.statement_end_offset
				WHEN - 1
					THEN DATALENGTH(dest.TEXT)
				ELSE der.statement_end_offset - der.statement_start_offset
				END
			) / 2 + 1) AS querystatement
			,deqp.query_plan
			,der.session_id
			,der.start_time
			,der.STATUS
			,DB_NAME(der.database_id) AS DBName
			,USER_NAME(der.user_id) AS UserName
			,der.blocking_session_id
			,der.wait_type
			,der.wait_time
			,der.wait_resource
			,der.last_wait_type
			,der.cpu_time
			,der.total_elapsed_time
			,der.reads
			,der.writes
	FROM sys.dm_exec_requests AS der
		CROSS APPLY sys.dm_exec_sql_text(der.sql_handle) AS dest
		CROSS APPLY sys.dm_exec_query_plan(der.plan_handle) AS deqp;
END
GO
