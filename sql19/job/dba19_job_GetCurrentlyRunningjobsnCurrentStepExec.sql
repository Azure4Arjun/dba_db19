SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_job_GetCurrentlyRunningjobsnCurrentStepExec
--
--
-- Calls:		None
--
-- Description:	This script will show the jobs currently running, as well as 
--				the step currently being executed.
--
-- https://dba.stackexchange.com/questions/58859/script-to-see-running-jobs-in-sql-server-with-job-start-time/64091#64091
-- Todd McDermid
-- 
-- Note: Requires Agent xp's to be enabled
--
-- Date			Modified By			Changes
-- 07/15/2020   Aron E. Tekulsky    Initial Coding.
-- 07/15/2020   Aron E. Tekulsky    Update to Version 150.
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

-- From http://www.databasejournal.com/features/mssql/article.php/10894_3491201_2/Detecting-The-State-of-a-SQL-Server-Agent-Job.htm
    CREATE TABLE #ENUM_JOB 
    ( 
        Job_ID					UNIQUEIDENTIFIER, 
        Last_Run_Date			INT, 
        Last_Run_Time			INT, 
        Next_Run_Date			INT, 
        Next_Run_Time			INT, 
        Next_Run_Schedule_ID	INT, 
        Requested_To_Run		INT, 
        Request_Source			INT, 
        Request_Source_ID		VARCHAR(100), 
        Running					INT, 
        Current_Step			INT, 
        Current_Retry_Attempt	INT, 
        State					INT -- 0 - Returns only those jobs that are not idle or suspended.
									-- 1 - Executing.
									-- 2 - Waiting for thread.
									-- 3 - Between retries.
									-- 4 - Idle.
									-- 5 - Suspended.
									-- 7 - Performing completion actions.
    )

    INSERT INTO #ENUM_JOB 
         EXEC master.dbo.xp_sqlagent_enum_jobs 1,garbage;

    SELECT SJ.name AS job_name, SJS.step_name,
			--e.Job_ID, 
			dba_db16.[dbo].[f_dba16_utl_ConvertIntDateToString] (e.Last_Run_Date) AS Last_Run_Date,
			dba_db16.[dbo].[f_dba16_utl_ConvertIntTimeToString] (e.Last_Run_Time) AS Last_Run_Time,
			dba_db16.[dbo].[f_dba16_utl_ConvertIntDateToString] (e.Next_Run_Date) AS Next_Run_Date,
			dba_db16.[dbo].[f_dba16_utl_ConvertIntTimeToString] (e.Next_Run_Time) AS Next_Run_Time, 
			e.Next_Run_Schedule_ID, e.Requested_To_Run,
			e.Request_Source, e.Request_Source_ID, e.Running, e.Current_Step, 
			e.Current_Retry_Attempt, 
			CASE e.State
				WHEN 0 THEN
					'Returns only those jobs that are not idle or suspended.'
				WHEN 1 THEN
					'Executing.'
				WHEN 2 THEN 
					'Waiting for thread.'
				WHEN 3 THEN 
					'Between retries.'
				WHEN 4 THEN 
					'Idle.'
				WHEN 5 THEN 
					'Suspended.'
				WHEN 7 THEN 
					'Performing completion actions'
			END AS state
			
        FROM #ENUM_JOB AS E
			JOIN msdb.dbo.sysjobs AS SJ
				ON SJ.job_id = E.Job_ID
			JOIN msdb.dbo.sysjobsteps AS SJS
				ON SJS.job_id = SJ.job_id
				AND SJS.step_id = E.Current_Step;

    DROP TABLE #ENUM_JOB;

END
GO
