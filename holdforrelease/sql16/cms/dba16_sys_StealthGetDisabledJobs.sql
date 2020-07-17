SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_StealthGetDisabledJobs
--
--
-- Calls:		None
--
-- Description:	Get disabled jobs using stealth.
-- 
-- Date			Modified By			Changes
-- 10/16/2009   Aron E. Tekulsky    Initial Coding.
-- 04/19/2012	Aron E. Tekulsky	Update to v100.
-- 01/03/2016   Aron E. Tekulsky    Update to V140.
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

     DECLARE @cmd				nvarchar(2000),
             @productversion	nvarchar(1),
             @cmd2				nvarchar(2000),
             @sql_version		int

             
     DECLARE @testtable TABLE (
		sql_version int)           

     SET @cmd2 = ' select compatibility_level from ' + 'master.sys.databases where name = ''master''';
     
     print @cmd2;
     
     INSERT INTO @testtable
          EXEC  (@cmd2);
     
     select @sql_version = sql_version from @testtable;
     
     print @sql_version;

     
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
				 'SELECT convert(nvarchar(4000),a.job_id) AS job_id,
					 a.name as job_name, 
					CASE a.enabled
					   WHEN 0 THEN ''Disabled''
					   WHEN 1 THEN ''Enabled''
					END AS job_enabled,
                a.start_step_id,
				s.name AS schedule_name, 
		        CASE s.enabled
					WHEN 0 THEN ''Not Scheduled''
		            WHEN 1 THEN '' Scheduled''
				END AS Schedule_enabled
				FROM ' +  'msdb.dbo.sysjobs a
					 LEFT JOIN ' + 'msdb.dbo.sysjobschedules j ON (a.job_id = j.job_id) 
					LEFT JOIN ' +  'msdb.dbo.sysschedules s ON (j.schedule_id = s.schedule_id)
				WHERE a.enabled = 0 OR s.enabled = 0
				ORDER BY job_name ASC'
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
				 'SELECT convert(nvarchar(4000),a.job_id) AS job_id,
					 a.name AS job_name, 
					CASE a.enabled
					   WHEN 0 THEN ''Disabled''
					   WHEN 1 THEN ''Enabled''
					END AS job_enabled,
                 a.start_step_id,
                 ''N/A'' AS schedule_name,
                 ''N/A'' AS Schedule_enabled
				FROM '  + 'msdb.dbo.sysjobs a
				LEFT JOIN '  + 'msdb.dbo.sysjobschedules j ON (a.job_id = j.job_id)
				WHERE a.enabled = 0  
				ORDER BY job_name ASC'
		END



	print @cmd;

	EXEC (@cmd);


END
GO
