SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_dig_DMGetTasksWOSWaitingTasks
--
--
-- Calls:		None
--
-- Description:	This query returns one row for every worker thread currently
--				assigned to this query.
--
-- https://sqlity.net/en/708/why-cxpacket-waits-are-not-your-performance-problem/
--
-- Date			Modified By			Changes
-- 12/18/2018	Aron E. Tekulsky	Initial Coding.
-- 05/13/2019   Aron E. Tekulsky    Update to Version 140.
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

	SELECT t.task_address ,
			t.task_state ,
			t.session_id ,
			t.exec_context_id ,
			wt.wait_duration_ms ,
			wt.wait_type ,
			wt.blocking_session_id ,
			wt.blocking_exec_context_id ,
			wt.resource_description ,
			t.scheduler_id
		FROM sys.dm_os_tasks t
			LEFT JOIN sys.dm_os_waiting_tasks wt ON t.task_address = wt.waiting_task_address
	WHERE wt.wait_type IN ('CXPACKET')
	ORDER BY t.exec_context_id,wt.blocking_exec_context_id;

END
GO
