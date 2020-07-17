SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_sys_GetBackupJobsMaxRunDate
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get the backup jobs maxrundate.
-- 
-- Date			Modified By			Changes
-- 10/23/2008   Aron E. Tekulsky  Initial Coding.
-- 04/04/2012	Aron E. Tekulsky	Update to v100.
-- 03/20/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_sys_GetBackupJobsMaxRunDate 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT h.instance_id, h.job_id, h.step_id, h.step_name,
			h.message, h.run_status, 
			[dbo].[f_dba19_utl_ConvertIntDateToString](h.run_date) as run_date, 
			[dbo].[f_dba19_utl_ConvertIntTimeToString](h.run_time) as run_time, h.server,
			j.name as jobname, j.description, j.category_id, j.enabled,
			c.name
		FROM msdb.dbo.sysjobhistory h
			JOIN msdb.dbo.sysjobs j ON (h.job_id = j.job_id)
			JOIN msdb.dbo.syscategories c ON (j.category_id = c.category_id)
			JOIN [dbo].[v_dba19_sys_MaxBackupJobDate] m ON (h.job_id = m.job_id)
	WHERE h.step_id = 0 AND
--		datediff(d,CONVERT(datetime,convert(char(8),h.run_date)),GETDATE()) >= 0 AND
		datediff(d,CONVERT(datetime,convert(char(8),h.run_date)),convert(char(8),maxrundate)) = 0 AND
		c.name = 'Database Maintenance'
		AND (j.name LIKE ('%User Maint%') OR j.name LIKE ('%System Maint%'))
	ORDER BY h.run_date DESC, h.run_time DESC;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_sys_GetBackupJobsMaxRunDate TO [db_proc_exec] AS [dbo]
GO
