SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_utl_BuildSQLAgentJob
--
--
-- Calls:		None
--
-- Description:	Build a SQL Agent job to load.
-- 
-- Date			Modified By			Changes
-- 09/24/2019   Aron E. Tekulsky    Initial Coding.
-- 09/24/2019   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @Cmd				nvarchar(4000)
	DECLARE @Command			nvarchar(max)
	DECLARE @database_name		nvarchar(128)
	DECLARE @description		nvarchar(512)
	DECLARE @DropJob			int
	DECLARE @enabled			tinyint
	DECLARE @IsScheduled		tinyint
	DECLARE @JobCategory		nvarchar(128)
	DECLARE @job_id				nvarchar(50)
	DECLARE @JobName			nvarchar(128)
	DECLARE @JobScheduleName	nvarchar(512)
	DECLARE @JobScheduleEnabled	tinyint
	DECLARE @owner_login_name	nvarchar(128)
	DECLARE @schedule_uid		nvarchar(128)
	DECLARE @StepId				int
	DECLARE @StepName			nvarchar(128)
	DECLARE @Today				varchar(22)

	-- initialize
	SET @description = 'Loads perfomance counter values from Production database to DBA database';
	SET @DropJob = 0; -- 0 do NOT drop job, 1 drop job.
	SET @enabled = 0; -- 0 disabled, 1 enabled.
	SET @JobCategory = 'Data Collector';
	SET @job_id = 'a7220f15-9e17-4400-837a-807a1493de65';
	SET @JobName = 'DBA Load Perfomance Counters';
	SET @owner_login_name = 'mydomain\myid';
	SET @Today = '8/31/2016 11:31:45 PM';
	SET @database_name = 'DBA';
	
	SET @IsScheduled = 1; -- 1 yes other values no
	SET @JobScheduleName = 'DBA Load Perfomance Counters Schedule';
	SET @JobScheduleEnabled = 1;
	SET @schedule_uid = 'f050d150-2b28-4f4e-a31c-663dadc7b75e';

	SET @StepName = 'Load Perfomance counter';
	SET @StepId = 1;
	SET @Command = 'EXECUTE  [DBA].[dbo].[StorePerformaceCounterValues]';


	-- code
	SET @Cmd = 'USE [msdb] ' + CHAR(13) + CHAR(10) + -- 10 Line Feed, 13 - CR, 9 - Tab
	' GO ' + CHAR(13) + CHAR(10);
	
	PRINT @Cmd;

	SET @Cmd = '/****** Object:  Job [' + @JobName + ']    Script Date: ' + @Today + ' ******/';

	PRINT @Cmd;

	-- drop the existing job
	IF @DropJob <> 0 
		BEGIN
			SET @Cmd = 'EXEC msdb.dbo.sp_delete_job @job_id=N' + '''' + 
				@job_id + ', @delete_unused_schedule=1' + CHAR(13) + CHAR(10) + 
				' GO';

			PRINT @Cmd;
		END

	SET @Cmd = '/****** Object:  Job [' + @JobName + ']    Script Date: ' + @Today + ' ******/';

	PRINT @Cmd;

	SET @Cmd = '
BEGIN TRANSACTION6 ' + CHAR(13) + CHAR(10) + 
			'DECLARE @ReturnCode INT ' + CHAR(13) + CHAR(10) +
			'SELECT @ReturnCode = 0 ' + CHAR(13) + CHAR(10);


	PRINT @Cmd;

	-- set up the job info.
	SET @Cmd = 
	'/****** Object:  JobCategory [' + @JobCategory + ']    Script Date: ' + @Today + ' ******/';

	PRINT @Cmd;

	SET @Cmd = 
	'IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N' + '''' + @JobCategory + '''' + ' AND category_class=1)'
	+ CHAR(13) + CHAR(10) +
'BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N' + '''' + 'JOB'+ '''' + ', @type=N' + '''' + 'LOCAL' + '''' + ', @name=N'+ @JobCategory + CHAR(13) + CHAR(10) + 
'IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END' + CHAR(13) + CHAR(10);

	PRINT @Cmd;

	SET @Cmd = 

 CHAR(13) + CHAR(10) + 'DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N' + '''' + @JobName + '''' + ', 
		@enabled=' + CONVERT(char(1),@enabled) + ', 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'+ '''' + @description + '''' + ', 
		@category_name=N' + '''' + @JobCategory + '''' + ', 
		@owner_login_name=N' + '''' + @owner_login_name + '''' + ', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback'

	PRINT @Cmd;

	-- set up the step info for all steps.

	SET @Cmd = 
	  '/****** Object:  Step [' + @StepName + ']    Script Date: ' + @Today + ' ******/ ' + CHAR(13) + CHAR(10);

	PRINT @Cmd;

	SET @Cmd = 
	'EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N' + '''' + @StepName + '''' + ', 
		@step_id=' + CONVERT(varchar(8), @StepId) + ', 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=2, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N' + '''' + 'TSQL' + '''' + ', 
		@command=N' + '''' + @Command + '''' + '
GO' + '''' + ', 
		@database_name=N' + '''' + @database_name + '''' + ', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback'

	PRINT @Cmd;

	SET @Cmd = 
	'EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback';

	PRINT @Cmd;

	IF @IsScheduled = 1 
	BEGIN
		SET @Cmd =
'EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N' + '''' + @JobScheduleName + '''' + ', 
		@enabled=' + CONVERT(varchar(8),@JobScheduleEnabled) + ', 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=10, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20150211, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N' + '''' + @schedule_uid + '''' + '
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

	END
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N' + '''' + '(local)' + '''' + '
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:';

	PRINT @Cmd;
	END
END
GO
