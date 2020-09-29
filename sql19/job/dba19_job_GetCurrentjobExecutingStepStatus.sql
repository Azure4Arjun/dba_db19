SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_job_GetCurrentjobExecutingStepStatus
--
--
-- Calls:		None
--
-- Description:	Get the status of any currently executing job step.
--
-- https://stackoverflow.com/questions/18445825/how-to-know-status-of-currently-running-jobs
-- Kenneth Fisher
--
-- Date			Modified By			Changes
-- 07/15/2020   Aron E. Tekulsky    Initial Coding.
-- 07/15/2020   Aron E. Tekulsky    Update to Version 150.
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

	SELECT
		ja.job_id,
		j.name AS job_name,
		ja.start_execution_date,      
		ISNULL(last_executed_step_id,0)+1 AS current_executed_step_id,
		Js.step_name
	FROM msdb.dbo.sysjobactivity ja 
		LEFT JOIN msdb.dbo.sysjobhistory jh ON (ja.job_history_id = jh.instance_id)
		JOIN msdb.dbo.sysjobs j ON (ja.job_id = j.job_id)
		JOIN msdb.dbo.sysjobsteps js
			ON (ja.job_id = js.job_id)
			AND ISNULL(ja.last_executed_step_id,0)+1 = js.step_id
	WHERE
	  ja.session_id = (
		SELECT TOP 1 session_id FROM msdb.dbo.syssessions ORDER BY agent_start_date DESC
		  )
		AND start_execution_date is not null
		AND stop_execution_date is null;
END
GO
