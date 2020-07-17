SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_job_GetAllSqlAgentScheduledJobs
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 08/01/2016   Aron E. Tekulsky    Initial Coding.
-- 08/01/2016   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT j.job_id , j.originating_server_id , j.name , j.enabled , j.description , j.start_step_id , j.category_id ,
		j.owner_sid , j.date_created , j.date_modified
		,s.schedule_id , s.next_run_date , s.next_run_time 
		, v.last_outcome_message , v.last_run_date , v.last_run_time , v.last_run_duration , v.last_run_outcome , v.server_id 
	FROM msdb.dbo.sysjobs j
		JOIN msdb.dbo.sysjobschedules s ON (s.job_id = j.job_id )
		JOIN [msdb].[dbo].[sysjobservers] v ON (v.job_id = j.job_id )
END
GO
