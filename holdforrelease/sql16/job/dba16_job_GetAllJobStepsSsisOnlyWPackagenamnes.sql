SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_job_GetAllJobStepsSsisOnlyWPackagenamnes
--
--
-- Calls:		None
--
-- Description:	Get all of the job steps and their packages
-- 
-- Date			Modified By			Changes
-- 01/26/2016   Aron E. Tekulsky    Initial Coding.
-- 02/07/2020	Aron E. Tekulsky	Add command information and where clause to 
--									limit to isserver and files.
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

	SELECT
		[sJOB].[job_id] AS [JobID]
	    , [sJOB].[name] AS [JobName]
	    , [sJSTP].[step_uid] AS [StepID]
	    , [sJSTP].[step_id] AS [StepNo]
	    , [sJSTP].[step_name] AS [StepName]
	    , CASE [sJSTP].[subsystem]
	        WHEN 'ActiveScripting' THEN 'ActiveX Script'
	        WHEN 'CmdExec' THEN 'Operating system (CmdExec)'
	        WHEN 'PowerShell' THEN 'PowerShell'
	        WHEN 'Distribution' THEN 'Replication Distributor'
	        WHEN 'Merge' THEN 'Replication Merge'
	        WHEN 'QueueReader' THEN 'Replication Queue Reader'
	        WHEN 'Snapshot' THEN 'Replication Snapshot'
	        WHEN 'LogReader' THEN 'Replication Transaction-Log Reader'
	        WHEN 'ANALYSISCOMMAND' THEN 'SQL Server Analysis Services Command'
	        WHEN 'ANALYSISQUERY' THEN 'SQL Server Analysis Services Query'
	        WHEN 'SSIS' THEN 'SQL Server Integration Services Package'
	        WHEN 'TSQL' THEN 'Transact-SQL script (T-SQL)'
	     ELSE sJSTP.subsystem
	  END AS [StepType]
		, [sPROX].[name] AS [RunAs]
		, [sJSTP].[database_name] AS [Database]
	    , [sJSTP].[command] AS [ExecutableCommand]
	    ,CASE [sJSTP].[on_success_action]
	        WHEN 1 THEN 'Quit the job reporting success'
	        WHEN 2 THEN 'Quit the job reporting failure'
	        WHEN 3 THEN 'Go to the next step'
	        WHEN 4 THEN 'Go to Step: ' 
	                    + QUOTENAME(CAST([sJSTP].[on_success_step_id] AS VARCHAR(3))) 
		                + ' ' 
			            + [sOSSTP].[step_name]
		 END AS [OnSuccessAction]
		, [sJSTP].[retry_attempts] AS [RetryAttempts]
		, [sJSTP].[retry_interval] AS [RetryInterval (Minutes)]
		, CASE [sJSTP].[on_fail_action]
		    WHEN 1 THEN 'Quit the job reporting success'
		    WHEN 2 THEN 'Quit the job reporting failure'
		    WHEN 3 THEN 'Go to the next step'
		    WHEN 4 THEN 'Go to Step: ' 
		                + QUOTENAME(CAST([sJSTP].[on_fail_step_id] AS VARCHAR(3))) 
		                + ' ' 
		                + [sOFSTP].[step_name]
		  END AS [OnFailureAction]
		  ,SUBSTRING ([sjstp].command,CHARINDEX('\SSISDB', [sjstp].command ), CHARINDEX('.dtsx', [sjstp].command) - CHARINDEX('\SSISDB', [sjstp].command) + 5) AS packages
		FROM [msdb].[dbo].[sysjobsteps] AS [sJSTP]
			 INNER JOIN [msdb].[dbo].[sysjobs] AS [sJOB] ON [sJSTP].[job_id] = [sJOB].[job_id]
			 LEFT JOIN [msdb].[dbo].[sysjobsteps] AS [sOSSTP] ON [sJSTP].[job_id] = [sOSSTP].[job_id]
															AND [sJSTP].[on_success_step_id] = [sOSSTP].[step_id]
			 LEFT JOIN [msdb].[dbo].[sysjobsteps] AS [sOFSTP] ON [sJSTP].[job_id] = [sOFSTP].[job_id]
															AND [sJSTP].[on_fail_step_id] = [sOFSTP].[step_id]
			LEFT JOIN [msdb].[dbo].[sysproxies] AS [sPROX] ON [sJSTP].[proxy_id] = [sPROX].[proxy_id]
	WHERE [sjstp].subsystem = 'SSIS' AND
		([sjstp].command LIKE ('/ISSERVER%') OR [sjstp].command LIKE ('/FILES%'))
	ORDER BY [JobName] ASC, [StepNo] ASC;


END
GO
