SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_blk_DMGetViewWaitingTasksforAllProcessesMS
--
--
-- Calls:		None
--
-- Description:	View waiting tasks for all user processes with additional information.
-- 
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-os-waiting-tasks-transact-sql?view=sql-server-ver15
--
-- Date			Modified By			Changes
-- 09/09/2020   Aron E. Tekulsky    Initial Coding.
-- 09/09/2020   Aron E. Tekulsky    Update to Version 150.
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

	SELECT 'Waiting_tasks' AS [Information], owt.session_id,
		owt.wait_duration_ms, owt.wait_type, owt.blocking_session_id,
		owt.resource_description, es.program_name, est.text,
		est.dbid, eqp.query_plan, er.database_id, es.cpu_time,
		es.memory_usage*8 AS memory_usage_KB
	FROM sys.dm_os_waiting_tasks owt
	INNER JOIN sys.dm_exec_sessions es ON owt.session_id = es.session_id
	INNER JOIN sys.dm_exec_requests er ON es.session_id = er.session_id
	OUTER APPLY sys.dm_exec_sql_text (er.sql_handle) est
	OUTER APPLY sys.dm_exec_query_plan (er.plan_handle) eqp
	WHERE es.is_user_process = 1
	ORDER BY owt.session_id;
	
END
GO
