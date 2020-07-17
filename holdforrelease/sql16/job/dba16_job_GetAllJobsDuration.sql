SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_job_GetAllJobsDuration
--
--
-- Calls:		None
--
-- Description:	Get the duration of all jobs
-- 
-- Date			Modified By			Changes
-- 08/15/2012   Aron E. Tekulsky    Initial Coding.
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

	SELECT --j.job_id, 
		j.name, j.enabled, j.description, 
		CASE h.run_status
			WHEN 0 THEN 'Failed'
			WHEN 1 THEN 'Succeeded'
			WHEN 2 THEN 'Retry'
			WHEN 3 THEN ' Cancelled' 
			END AS run_status,
		dba_db16.dbo.f_dba16_utl_convertintdatetostring(h.run_date) AS run_date, 
		 dba_db16.dbo.f_dba16_utl_convertinttimetostring(h.run_time) as run_time,
		dba_db16.dbo.f_dba16_utl_convertinttimetostring(h.run_duration) as run_duration--, h.step_id, h.step_name
		FROM msdb..sysjobs j
			 JOIN msdb..sysjobhistory h ON (j.job_id = h.job_id)
			--LEFT JOIN msdb..sysjobhistory h ON (h.job_id = j.job_id)
	WHERE --j.name like ('dba_ftp%') AND
		h.step_id = 0
		--and name like ('dba_ftp_usnypdba04%')
	ORDER BY j.name ASC, h.run_date DESC, h.run_time DESC--, h.step_id ASC

END
GO
