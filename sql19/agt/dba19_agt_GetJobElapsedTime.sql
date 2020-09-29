SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_agt_GetJobElapsedTime
--
--
-- Calls:		None
--
-- Description:	List currently executing jobs and elapsed time.
-- 
-- https://stackoverflow.com/questions/10726585/sql-agent-job-determine-how-long-it-has-been-running
-- Date			Modified By			Changes
-- 11/08/2019   Aron E. Tekulsky    Initial Coding.
-- 11/08/2019   Aron E. Tekulsky    Update to Version 150.
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

	DECLARE @JobTimeTable AS TABLE (
		JobName					nvarchar(128),
		StepId					bigint,
		StartExecutionDate		datetime,
		StopExecutionDate		datetime,
		LastExecutedStepDate	datetime,
		Hours					bigint,
		Minutes					bigint,
		Seconds					bigint)

	-- Process
	INSERT INTO @JobTimeTable
		(JobName, StepId, StartExecutionDate, StopExecutionDate, 
			LastExecutedStepDate, Hours, Minutes, Seconds)
	SELECT sj.name, aj.last_executed_step_id, aj.start_execution_date, aj.stop_execution_date, aj.last_executed_step_date, 
			(DATEDIFF(SECOND,aj.start_execution_date,GetDate())) / 3600 AS Hours,
			(DATEDIFF(SECOND,aj.start_execution_date,GetDate())) / 60 AS Minutes,
			(DATEDIFF(SECOND,aj.start_execution_date,GetDate()))  AS Seconds
		FROM msdb..sysjobactivity aj
			JOIN msdb..sysjobs sj on sj.job_id = aj.job_id
	WHERE aj.stop_execution_date IS NULL -- job hasn't stopped running
		AND aj.start_execution_date IS NOT NULL -- job is currently running
		------AND sj.name = 'JobX'
		AND NOT EXISTS( -- make sure this is the most recent run
			SELECT 1
				FROM msdb..sysjobactivity new
			WHERE new.job_id = aj.job_id
				AND new.start_execution_date > aj.start_execution_date);

	SELECT JobName, StepId AS LastStepId, StartExecutionDate, StopExecutionDate,
			LastExecutedStepDate, (CONVERT(nvarchar(10),Hours) + ':' + 
			CONVERT(nvarchar(2),(Minutes - (Hours * 60))) + ':' + 
			CONVERT(nvarchar(4),(Seconds - (Minutes * 60)))) AS [Total Elapsed Time]
		FROM @JobTimeTable;
END
GO
