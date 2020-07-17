SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_job_GetDetailedJobListingwDuration
--
--
-- Calls:		None
--
-- Description:	Get a detailed job listing sql 2005 version and
-- 
-- Date			Modified By			Changes
-- 04/28/2020   Aron E. Tekulsky    Initial Coding.
-- 04/28/2020   Aron E. Tekulsky    Update to Version 150.
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

	SELECT --j.job_id, 
		j.name, j.enabled, j.description, 
		CASE h.run_status
			WHEN 0 THEN 'Failed'
			WHEN 1 THEN 'Succeeded'
			WHEN 2 THEN 'Retry'
			WHEN 3 THEN 'Cancelled' 
		END AS run_status,
		dba_db16.dbo.f_dba16_utl_convertintdatetostring(h.run_date) AS run_date, 
		dba_db16.dbo.f_dba16_utl_convertinttimetostring(h.run_time) as run_time,
		dba_db16.dbo.f_dba16_utl_convertinttimetostring(h.run_duration) as run_duration,
		CASE s.freq_type
			WHEN 4 THEN 'Daily'
			WHEN 8 THEN 'Weekly on'
			WHEN 16 THEN 'Monthly'
		END AS 'Occurs',
		CASE s.freq_type
			WHEN 8 THEN [dba_db16].[dbo].[f_dba16_utl_GetFrequencyInDays] (s.freq_interval)
			ELSE '0'
    --ELSE 'NONE'
		END AS 'Freq Intrvl',
		CASE s.freq_subday_type
			WHEN 1 THEN 'Once At'
			WHEN 8 THEn 'Every'
		END AS 'Daily Frequency',
		s.freq_subday_interval AS 'Freq SubDay Intrvl(min)',
		s.freq_relative_interval,
		CASE s.freq_recurrence_factor
			WHEN 0 THEN 'Hour(s)'
			WHEN 1 THEN 'Minute(s)'
		END AS 'freq_recurrence_factor',
		CASE s.freq_subday_type
			WHEN 1 THEN
				dba_db16.dbo.f_dba16_utl_convertinttimetostring(s.active_start_time) 
    --WHEN 4 THEN 'No End Time'
		END AS 'Starting At',
		CASE s.freq_subday_type
    --WHEN 1 THEN 'No End Time'
			WHEN 1 THEN 0
			WHEN 4 THEN
				dba_db16.dbo.f_dba16_utl_convertinttimetostring(s.active_end_time)
		END AS 'End At'

		FROM msdb.dbo.sysjobs j
			JOIN msdb..sysjobhistory h ON (j.job_id = h.job_id)
			LEFT join msdb.dbo.sysjobschedules e on (e.job_id = j.job_id)
			LEFT join msdb.dbo.sysschedules s on (e.schedule_id = s.schedule_id)
	WHERE h.step_id = 0
	ORDER BY j.name ASC, h.run_date DESC, h.run_time DESC--, h.step_id ASC

END
GO
