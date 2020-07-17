SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_job_GetAllJobStepTimesAlJjobsWSortByEndTime
--
--
-- Calls:		None
--
-- Description:	Get a detilaed job listing sorted by end times.
-- 
-- Date			Modified By			Changes
-- 08/30/2007   Aron E. Tekulsky    Initial Coding.
-- 11/22/2017   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets FROM
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	SELECT j.name, j.job_id, j.description,h.step_id, h.step_name,
			dba_db16.dbo.f_dba16_utl_convertintdatetostring(h.run_date) AS run_date, 
			 [dba_db16].[dbo].[f_dba16_utl_ConvertIntTimeToString](h.run_duration) AS runduration,
			 [dba_db16].[dbo].[f_dba16_utl_ConvertIntTimeToString](h.run_time + h.run_duration) AS runend
			------h.run_date AS rundate, h.run_time AS runtime, h.run_duration AS runduration, (h.run_time + h.run_duration) AS runend
		FROM msdb.dbo.sysjobs j
			join msdb.dbo.sysjobhistory h on (h.job_id = j.job_id)
	WHERE h.step_id = 0 AND
		j.enabled = 1 AND
--name like ('DBA_FTP%') --AND 
		[dba_db16].[dbo].[f_dba16_utl_ConvertIntDateToString](h.run_date) >= '04/01/2016'
		--h.run_date >= '04/01/2016'
	ORDER BY  h.run_date desc--, runend desc, j.name ASC,h.run_time ASC, j.job_id ASC, h.step_id ASC;

END
GO
