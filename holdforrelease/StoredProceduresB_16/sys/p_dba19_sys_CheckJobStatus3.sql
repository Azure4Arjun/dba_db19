SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_sys_CheckJobStatus3
--
-- Arguments:	@passed_date datetime
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get check job status3.
-- 
-- Date			Modified By			Changes
-- 05/05/2008   Aron E. Tekulsky	Initial Coding.
-- 04/04/2012	Aron E. Tekulsky	Update to v100.
-- 02/11/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_sys_CheckJobStatus3 
	-- Add the parameters for the stored procedure here
	@passed_date datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @endruntime		int
	DECLARE @job_name		nvarchar(128)
	DECLARE @rundate		int
	DECLARE @runtime		int
	DECLARE @run_duratiON	int
	DECLARE @run_status		int
--	DECLARE @run_status		nvarchar(4000)
	DECLARE @step_id		int
	DECLARE @step_name		nvarchar(128)


	SET @passed_date = isnull(@passed_date, getdate())
--	SET @passed_jobname = lower('pkg_dba_zip_backups')

	SET @rundate = (datepart(year,@passed_date)*10000) + (datepart(mONth,@passed_date)*100)
 				+ datepart(day,@passed_date)

	SET @runtime = (datepart(hour, @passed_date)*10000) + (datepart(minute, @passed_date)*100) + (datepart(secONd, @passed_date))

--	print @rundate
--	print @runtime

/*
	SELECT @job_name = j.name,--h.run_date, --h.run_time,
--			@run_status = h.run_status, 
			@run_status = CASE h.run_status
            WHEN 0
                THEN 'error'
            ELSE 'SUCCESS'
			END, 
			@step_id = h.step_id,
			@step_name = h.step_name,
			@run_duratiON = h.run_duratiON
*/

	SELECT  j.name as job_name,--h.run_date, --h.run_time,
			h.run_status as run_status, 
--			CASE h.run_status 
--				WHEN 0
--					  THEN 'error'
--				ELSE 'SUCCESS'
--			END as run_status,
			dba_db16.dbo.f_dba19_utl_ConvertIntDateToString(h.run_date) as run_date, 
			dba_db16.dbo.f_dba46_cONvertinttimetostring(h.run_time) as run_time,
			j.job_id as job_id,
			h.step_name as step_name,
			h.run_duratiON as run_duratiON,
			c.step_count as step_count,
			h.run_date as run_date_int,
			h.run_time as run_time_int
		FROM msdb..sysjobs j
			JOIN msdb..sysjobhistory h ON (h.job_id = j.job_id)
			JOIN dba_db16.dbo.v_dba19_sys_JobStepCounts c ON (c.job_id = j.job_id)
	WHERE h.step_id = 0 and
		h.run_date = @rundate --and
	--	h.run_time = @runtime --and
	--	j.name = @passed_jobname
    ORDER BY j.name ASC;

--SET @endruntime = @runtime + @run_duratiON

--SET @enddate = @rundate + @endruntime

--print @job_name
--print @run_status
--print @step_id
--print @step_name
--print @run_duratiON

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_sys_CheckJobStatus3 TO [db_proc_exec] AS [dbo]
GO
