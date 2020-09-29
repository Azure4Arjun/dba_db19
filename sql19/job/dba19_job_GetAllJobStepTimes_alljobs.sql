SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_job_GetAllJobStepTimes_alljobs
--
--
-- Calls:		None
--
-- Description:	Get a listing of all job step times.
-- 
-- Date			Modified By			Changes
-- 08/30/2007   Aron E. Tekulsky    Initial Coding.
-- 11/22/2017   Aron E. Tekulsky    Update to Version 140.
-- 08/25/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
--
--  This code and information are provided "AS IS" without warranty of
--  any kind, either expressed or implied, including but not limited
--  to the implied warranties of merchantability and/or fitness for a
--  particular purpose.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

--use msdb
--go
	SELECT j.name, j.job_id, j.description,h.step_id, h.step_name,
			dba_db19.dbo.f_dba19_utl_convertintdatetostring(h.run_date) AS run_date, 
			dba_db19.dbo.f_dba19_utl_convertinttimetostring(h.run_time) as run_time,
			dba_db19.dbo.f_dba19_utl_convertinttimetostring(h.run_duration) as run_duration,-- h.step_id, h.step_name
			----h.run_date as rundate, h.run_time as runtime, h.run_duration as runduration,
			dba_db19.dbo.f_dba19_utl_convertinttimetostring(h.run_time + h.run_duration) as runend
		FROM msdb.dbo.sysjobs j
			JOIN msdb.dbo.sysjobhistory h ON (h.job_id = j.job_id)
	WHERE h.step_id = 0 AND
		j.enabled = 1
	ORDER BY  h.run_date ASC, j.name ASC,h.run_time ASC, j.job_id ASC, h.step_id ASC;

END
GO
