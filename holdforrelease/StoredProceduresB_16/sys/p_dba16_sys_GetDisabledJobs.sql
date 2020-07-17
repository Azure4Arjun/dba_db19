SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba16_sys_GetDisabledJobs
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get the disabled jobs.
-- 
-- Date			Modified By			Changes
-- 07/26/2002   Aron E. Tekulsky	Initial Coding.
-- 04/04/2012	Aron E. Tekulsky	Update to v100.
-- 03/23/2018   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba16_sys_GetDisabledJobs 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT @@SERVERNAME  as originating_server, convert(nvarchar(4000),a.job_id) as job_id, a.name as job_name,
			CASE a.enabled
				WHEN 0 THEN 'Disabled'
				WHEN 1 THEN 'Enabled'
			END as job_enabled,
			a.start_step_id,
--			j.schedule_id, j.next_run_date, j.next_run_time,
			s.name, 
			CASE s.enabled
				WHEN 0 THEN 'Not Scheduled'
				WHEN 1 THEN ' Scheduled'
			END as Schedule_enabled
		FROM msdb..sysjobs a
			left join msdb.dbo.sysjobschedules j on (a.job_id = j.job_id)
			left join msdb.dbo.sysschedules s on (j.schedule_id = s.schedule_id)
--			left join msdb.dbo.systargetservers t on (a.originating_server_id = t.server_id)
--			left join msdb.dbo.sysoriginatingservers t on (a.originating_server_id = t.originating_server_id)
	WHERE a.enabled = 0 or s.enabled = 0
--	WHERE b.step_id > 0
--		AND b.run_date = @run_date
--		AND b.run_status = 0
	ORDER BY job_name asc;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba16_sys_GetDisabledJobs TO [db_proc_exec] AS [dbo]
GO
