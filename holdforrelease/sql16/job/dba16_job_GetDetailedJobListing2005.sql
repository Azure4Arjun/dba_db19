SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_job_GetDetailedJobListing2005
--
--
-- Calls:		None
--
-- Description:	Get a detailed job listing sql 2005 version.
-- 
-- Date			Modified By			Changes
-- 11/02/2014   Aron E. Tekulsky    Initial Coding.
-- 10/16/2017   Aron E. Tekulsky    Update to Version 140.
-- 04/28/2020	Aron E. Tekulsky	Add code to trap for s.freq_interval null.  
--									Set to '0' instad of 0.
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

	SELECT j.job_id as 'Job Id', v.originating_server AS 'Orig Server', j.name AS 'Job Name',
		CASE j.enabled
			WHEN 0 THEN 'No'
			 WHEN 1 THEN 'Yes'
		END AS 'Job Enabled',
--	ISNULL(j.description,'***') as Description, a.name as Category, 
		CASE j.description
			WHEN ' ' THEN '***'
			WHEN '' THEN '?'
			ELSE j.description
		END AS Description,
		a.name AS Category, 
		--------e.next_run_date AS 'Next Run Date',
		------e.next_run_time AS 'Next Run Time' ,
		dba_db16.dbo.f_dba16_utl_convertintdatetostring(e.next_run_date) AS 'Next Run Date', 
		dba_db16.dbo.f_dba16_utl_convertinttimetostring(e.next_run_time) as 'Next Run Time',
		s.name AS 'Schedule Name',
		CASE s.enabled
		   WHEN 0 THEN 'No'
		  WHEN 1 THEN 'Yes'
		END AS 'Step Enabled',
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
		dba_db16.dbo.f_dba16_utl_convertintdatetostring(s.active_start_date) AS 'Duration Start Date', 
		----s.active_start_date as 'Duration Start Date',
		CASE s.freq_subday_type
		  WHEN 1 THEN 0
    --		WHEN 1 THEN 'No End Date'
			ELSE
				dba_db16.dbo.f_dba16_utl_convertintdatetostring(s.active_end_date)
		End As 'Duration End Dat',
		CASE s.freq_subday_type
		 WHEN 1 THEN
				------dba_db16.dbo.f_dba16_utl_convertintdatetostring(s.active_start_time) 
				dba_db16.dbo.f_dba16_utl_convertinttimetostring(s.active_start_time) 
    --WHEN 4 THEN 'No End Time'
		END AS 'Starting At',
		CASE s.freq_subday_type
    --WHEN 1 THEN 'No End Time'
			WHEN 1 THEN 0
			WHEN 4 THEN
				dba_db16.dbo.f_dba16_utl_convertinttimetostring(s.active_end_time)
		END AS 'End At'
		FROM msdb..sysjobs j
			LEFT join msdb.dbo.sysjobschedules e on (e.job_id = j.job_id)
			left join msdb.dbo.sysoriginatingservers v on (j.originating_server_id = v.originating_server_id)
			LEFT join msdb.dbo.sysschedules s on (e.schedule_id = s.schedule_id)
			LEFT join msdb.dbo.syscategories a on (a.category_id = j.category_id)
------	WHERE j.enabled = 1 --and
------        --s.enabled = 1
--------	and j.name like ('%gms%')
------		AND j.name LIKE ('SQLAlertErrorHandler')
	ORDER BY a.name asc

END
GO
