SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_GetDisabledJobsSchedule
--
--
-- Calls:		None
--
-- Description:	Getr a list of jobs that are disabled and are scheduled.
-- 
-- Date			Modified By			Changes
-- 09/08/2010   Aron E. Tekulsky    Initial Coding.
-- 10/22/2017   Aron E. Tekulsky    Update to Version 140.
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

	 SELECT  @@servername as originating_server, convert(nvarchar(4000),a.job_id) as job_id,
			 a.name as job_name, 
			CASE a.enabled
				WHEN 0 THEN 'Disabled'
				WHEN 1 THEN 'Enabled'
			END as job_enabled,
            a.start_step_id, s.name as schedule_name, 
	        CASE s.enabled
				WHEN 0 THEN 'Not Scheduled'
		        WHEN 1 THEN ' Scheduled'
			END as Schedule_enabled
		FROM msdb.dbo.sysjobs a
			 LEFT JOIN msdb.dbo.sysjobschedules j ON (a.job_id = j.job_id) 
			LEFT JOIN msdb.dbo.sysschedules s ON (j.schedule_id = s.schedule_id)
	WHERE a.enabled = 0 OR s.enabled = 0
	ORDER BY job_name ASC;

END
GO
