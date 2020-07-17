SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_sys_CheckJobStatus
--
-- Arguments:	@passed_date		datetime,
--				@passed_jobname		varchar(200),  
--				@passed_runstatus	int output
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Check the job status.
-- 
-- Date			Modified By			Changes
-- 03/16/2006   Aron E. Tekulsky	Initial Coding.
-- 04/04/2012	Aron E. Tekulsky	Update to v100.
-- 02/11/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_sys_CheckJobStatus 
	-- Add the parameters for the stored procedure here
	@passed_date		datetime,
	@passed_jobname		varchar(200),  
	@passed_runstatus	int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @rundate		int
	DECLARE @runtime		int
	--declare @passed_date		datetime
	--declare @passed_jobname	varchar(200)
	--declare @passed_jobid		int
	--declare @passed_runstatus	int

	--set @passed_date = getdate()
	SET @passed_date = isnull(@passed_date, getdate());
	--set @passed_jobname = lower('pkg_dba_zip_backups')

	SET @rundate = (datepart(year,@passed_date)*10000) + (datepart(month,@passed_date)*100)
	 	+ datepart(day,@passed_date);

	SET @runtime = (datepart(hour, @passed_date)*10000) + (datepart(minute, @passed_date)*100) + (datepart(second, @passed_date));


	SELECT s.last_run_outcome
	--v.name, s.last_run_outcome, s.last_run_date, s.last_run_time, v.*
		FROM msdb..sysjobs j--,
			JOIN msdb..sysjobsteps s ON (s.job_id = j.job_id)--,
			JOIN dba_db16..v_dba19_sys_MaxMinJobStatus v ON (j.name = v.name)
	WHERE --s.job_id = j.job_id and
		--j.name = v.name and
		s.last_run_date = v.maxrundate and
		s.last_run_time = v.maxruntime and
		v.name = @passed_jobname and
		@rundate = v.maxrundate ;--and
		--@runtime = v.maxruntime


	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_sys_CheckJobStatus TO [db_proc_exec] AS [dbo]
GO
