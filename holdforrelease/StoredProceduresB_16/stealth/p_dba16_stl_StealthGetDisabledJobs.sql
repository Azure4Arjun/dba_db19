USE [dba_db16]
GO

/****** Object:  StoredProcedure [dbo].[p_dba16_stl_StealthGetDisabledJobs]    Script Date: 7/27/2019 8:25:53 AM ******/
DROP PROCEDURE [dbo].[p_dba16_stl_StealthGetDisabledJobs]
GO

/****** Object:  StoredProcedure [dbo].[p_dba16_stl_StealthGetDisabledJobs]    Script Date: 7/27/2019 8:25:53 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ==============================================================================
-- p_dba16_stl_StealthGetDisabledJobs
--
-- Arguments:		@server_name nvarchar(126)
--					None
--
-- Called BY:		None
-- Calls:			None
--
-- Description:	Get disabled jobs using stealth.
-- 
-- Date			Modified By			Changes
-- 10/16/2009   Aron E. Tekulsky    Initial Coding.
-- 04/19/2012	Aron E. Tekulsky	Update to v100.
-- 07/27/2019	Aron E. Tekulsky	Update to v140.
-- ===============================================================================
--	Copyright©2009 - 2012 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================

CREATE PROCEDURE [dbo].[p_dba16_stl_StealthGetDisabledJobs] 
	-- Add the parameters for the stored procedure here
	@server_name nvarchar(126)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
     DECLARE @cmd			 nvarchar(2000),
             @productversion nvarchar(1),
             @cmd2           nvarchar(2000),
             @sql_version int

             
     DECLARE @testtable TABLE (
		sql_version int)           
     
     DECLARE @dba_disabled_jobs TABLE (
		originating_server nvarchar(128),
		job_id nvarchar(4000),
		job_name nvarchar(128),
		job_enabled varchar(8),
		start_step_id int,
		schedule_name nvarchar(128),
		schedule_enabled varchar(13))
		
 	 IF @server_name IS NULL OR @server_name = ''
		SET @server_name = @@servername 

     --SET @cmd2 = ' select cmptlevel from ' + @server_name + '.master.dbo.sys.sysdatabases where name = ''master'''
     SET @cmd2 = ' select compatibility_level from [' + @server_name + '].master.sys.databases where name = ''master'''
     
     print @cmd2
     
     INSERT INTO @testtable
     
     EXEC  (@cmd2)
     
     select @sql_version = sql_version from @testtable
     
     print @sql_version

     
    IF @sql_version >= 90
        BEGIN
			SET @cmd = 
				 --'INSERT dbo.dba_disabled_jobs
					--([originating_server],
					--[job_id],
					--[job_name] ,
					--[job_enabled] ,
					--[start_step_id],
					--[schedule_name] ,
					--[schedule_enabled])' +
				 'select ''' + @server_name + ''' as originating_server, convert(nvarchar(4000),a.job_id) as job_id,
					 a.name as job_name, 
					CASE a.enabled
					   WHEN 0 THEN ''Disabled''
					   WHEN 1 THEN ''Enabled''
					END as job_enabled,
                a.start_step_id,
				s.name as schedule_name, 
		        CASE s.enabled
					WHEN 0 THEN ''Not Scheduled''
		            WHEN 1 THEN '' Scheduled''
				END as Schedule_enabled
				from [' + @server_name + '].msdb.dbo.sysjobs a
					 left join [' + @server_name + '].msdb.dbo.sysjobschedules j on (a.job_id = j.job_id) 
					left join [' + @server_name + '].msdb.dbo.sysschedules s on (j.schedule_id = s.schedule_id)
				WHERE a.enabled = 0 or s.enabled = 0
				order by job_name asc'
		END
    ELSE
        BEGIN
 			SET @cmd = 
 				-- 'INSERT dbo.dba_disabled_jobs
					--([originating_server],
					--[job_id],
					--[job_name] ,
					--[job_enabled] ,
					--[start_step_id],
					--[schedule_name] ,
					--[schedule_enabled])' +
				 'select ''' + @server_name + ''' as originating_server, convert(nvarchar(4000),a.job_id) as job_id,
					 a.name as job_name, 
					CASE a.enabled
					   WHEN 0 THEN ''Disabled''
					   WHEN 1 THEN ''Enabled''
					END as job_enabled,
                 a.start_step_id,
                 ''N/A'' as schedule_name,
                 ''N/A'' as Schedule_enabled
				from [' + @server_name + '].msdb.dbo.sysjobs a
				left join [' + @server_name + '].msdb.dbo.sysjobschedules j on (a.job_id = j.job_id)
				WHERE a.enabled = 0  
				order by job_name asc'
		END


     --SET @cmd = 
     --   'select ''' + @server_name + ''' as originating_server, convert(nvarchar(4000),a.job_id) as job_id,
     --    a.name as job_name, 
     --   CASE a.enabled
     --       WHEN 0 THEN ''Disabled''
     --       WHEN 1 THEN ''Enabled''
     --   END as job_enabled,'
     
    --IF @sql_version = 90
    --    BEGIN
    --        SET @cmd = @cmd +
    --            'a.start_step_id,
				--s.name, 
		  --      CASE s.enabled
				--	WHEN 0 THEN ''Not Scheduled''
		  --          WHEN 1 THEN '' Scheduled''
				--END as Schedule_enabled
				--from ' + @server_name + '.msdb.dbo.sysjobs a
				--	 left join ' + @server_name + '.msdb.dbo.sysjobschedules j on (a.job_id = j.job_id)' + 
				--	'left join ' + @server_name + '.msdb.dbo.sysschedules s on (j.schedule_id = s.schedule_id)
				--WHERE a.enabled = 0 or s.enabled = 0' 
    --    END
    --ELSE
    --    BEGIN
    --        SET @cmd = @cmd +
    --            'a.start_step_id
				--from ' + @server_name + '.msdb.dbo.sysjobs a
				--left join ' + @server_name + '.msdb.dbo.sysjobschedules j on (a.job_id = j.job_id)
				--WHERE a.enabled = 0  ' 
    --    END
    
    --  SET @cmd = @cmd +
    --  'order by job_name asc'

print @cmd

INSERT INTO @dba_disabled_jobs
	EXEC (@cmd);

SELECT [originating_server]
      ,[job_id]
      ,[job_name]
      ,[job_enabled]
      ,[start_step_id]
      ,[schedule_name]
      ,[schedule_enabled]
  FROM @dba_disabled_jobs



END








GO

GRANT EXECUTE ON [dbo].[p_dba16_stl_StealthGetDisabledJobs] TO [db_proc_exec] AS [dbo]
GO

GRANT VIEW DEFINITION ON [dbo].[p_dba16_stl_StealthGetDisabledJobs] TO [db_proc_exec] AS [dbo]
GO


