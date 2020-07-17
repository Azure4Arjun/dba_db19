SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba16_utl_BuildSqlAgenJjob
--
-- Arguments:	@CategoryName	varchar(128) = '', 
--				@OwnerLogin		varchar(128) = '',
--				@ServerNam		varchar(128) = ''
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Create a sql agent job.
-- 
-- Date			Modified By			Changes
-- 10/09/2015   Aron E. Tekulsky    Initial Coding.
-- 02/24/2018   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba16_utl_BuildSqlAgenJjob 
	-- Add the parameters for the stored procedure here
	@CategoryName	varchar(128) = '', 
	@OwnerLogin		varchar(128) = '',
	@ServerNam		varchar(128) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @Part1		nvarchar(4000)
	DECLARE @Part2		nvarchar(4000)
	DECLARE @Part3		nvarchar(4000)
	DECLARE @Part4		nvarchar(4000)
	DECLARE @Part5		nvarchar(4000)
	DECLARE @rundat		varchar(20)
	DECLARE @runtim		varchar(12)

	DECLARE @PkgName	varchar(128)
	DECLARE @CountNum	integer

	--DECLARE @pkgtable TABLE  (
	--	SsisPkgName	varchar(128)
	--	)

	DECLARE pkg_cur CURSOR FOR 
		SELECT SsisPkgName
			FROM PkgTable;

	--SET @CategoryName = 'REFRESH';
	--SET @OwnerLogin = 'ALLVACNC\sqlservice' ;
	--SET @ServerNam = 'local';

	--SET @PkgName = 'testing123';

	-- get date and time
	SET @rundat =  convert(varchar(20),getdate() );
	
	SET @Part1 = '
		USE [msdb]
		GO';

	PRINT @Part1 ;

	SET @Part2 = '
				/****** Object:  Job [Refresh databases for test]    Script Date: ' + '''' + @rundat + '''' + ' ******/
				BEGIN TRANSACTION
				DECLARE @ReturnCode INT
				SELECT @ReturnCode = 0
				/****** Object:  JobCategory [' + @CategoryName + ']    Script Date: ' + '''' + @rundat + '''' + ' ******/
				IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N' + '''' + @CategoryName + '''' + ' AND category_class=1)
				BEGIN
					EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N' + '''' + 'JOB' + '''' + ', @type=N' + '''' + 'LOCAL' + '''' + ', @name=N' + '''' + @CategoryName + '''' + '
					IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

				END';

	SET @Part3 = '

				DECLARE @jobId BINARY(16)
				EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N' + '''' + @CategoryName   + ' databases for test  ' + '''' + ', 
				@enabled=1, 
				@notify_level_eventlog=0, 
				@notify_level_email=0, 
				@notify_level_netsend=0, 
				@notify_level_page=0, 
				@delete_level=0, 
				@description=N' + '''' + 'No description available.' + '''' + ', 
				@category_name=N' + '''' + @CategoryName + '''' + ', 
				@owner_login_name=N' + '''' + @OwnerLogin + '''' + ', @job_id = @jobId OUTPUT
				IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback' ;

	PRINT @Part2 + ' ' + @Part3 ;

	OPEN pkg_cur;

	FETCH NEXT FROM pkg_cur
		INTO @PkgName;


	SET @CountNum = 0;

	WHILE (@@FETCH_STATUS = 0)
		BEGIN 
			SET @CountNum = @CountNum + 1;

			--action 1 = succes quit, 2 = fail quit, 3 = go to next step

			SET @Part4 = '
				/****** Object:  Step [' + '''' + @PkgName + '''' + ']    Script Date: ' + '''' + @rundat + '''' + ' ******/
				EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N' + '''' + @PkgName + '''' + ' , 
						@step_id=' + convert(varchar(10),@CountNum) + ', 
						@cmdexec_success_code=0, 
						@on_success_action=3, 
						@on_success_step_id=0, 
						@on_fail_action=3, 
						@on_fail_step_id=0, 
						@retry_attempts=0, 
						@retry_interval=0, 
						@os_run_priority=0, @subsystem=N' + '''' + 'SSIS' + '''' + ', 
						@command=N' + '''' + '/FILE "\"C:\Program Files (x86)\Microsoft SQL Server\120\DTS\Packages\' + @PkgName + '.dtsx\"" /X86  /CHECKPOINTING OFF /REPORTING E' + '''' + ', 
						@database_name=N' + '''' + 'master' + '''' + ', 
						@flags=32
				IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
				EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = ' + convert(varchar(10),@CountNum) + '
				IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback'

			PRINT @Part4;


			FETCH NEXT FROM pkg_cur
				INTO @PkgName;
		END

		CLOSE pkg_cur;

		DEALLOCATE pkg_cur;

		SET @Part5 = '
				EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N' + '''' + '(' + @ServerNam + ') ' + '''' +
				'IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
				COMMIT TRANSACTION
				GOTO EndSave
				QuitWithRollback:
					IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
				EndSave:

				GO'

		PRINT @Part5;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba16_utl_BuildSqlAgenJjob TO [db_proc_exec] AS [dbo]
GO
