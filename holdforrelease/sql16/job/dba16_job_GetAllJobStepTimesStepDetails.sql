SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_job_GetAllJobStepTimesStepDetails
--
--
-- Calls:		None
--
-- Description:	Get all job step details.
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

	SELECT DISTINCT j.name, j.job_id, j.description,h.step_id, h.step_name,
		------h.run_date AS rundate, h.run_time AS runtime, h.run_duration AS runduration
			dba_db16.dbo.f_dba16_utl_convertintdatetostring(h.run_date) AS run_date, 
			dba_db16.dbo.f_dba16_utl_convertinttimetostring(h.run_time) as run_time,
			dba_db16.dbo.f_dba16_utl_convertinttimetostring(h.run_duration) as run_duration--, h.step_id, h.step_name
		FROM msdb.dbo.sysjobs j
			JOIN msdb.dbo.sysjobhistory h ON (h.job_id = j.job_id)
			JOIN msdb.dbo.sysjobsteps s ON (s.job_id = h.job_id)
	WHERE h.step_id >= 0 AND
		j.enabled = 1 --AND
---j.name = 'LOAD_DAILY_CDR_DatabASe (SAP to CDR)'
	ORDER BY  run_date ASC,run_time ASC, j.name ASC, h.step_id ASC, j.job_id ASC

END
GO
