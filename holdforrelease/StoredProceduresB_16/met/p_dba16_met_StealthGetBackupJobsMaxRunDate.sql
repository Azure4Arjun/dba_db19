USE [dba_db16]
GO

/****** Object:  StoredProcedure [dbo].[p_dba16_met_StealthGetBackupJobsMaxRunDate]    Script Date: 8/17/2016 8:12:11 AM ******/
DROP PROCEDURE [dbo].[p_dba16_met_StealthGetBackupJobsMaxRunDate]
GO

/****** Object:  StoredProcedure [dbo].[p_dba16_met_StealthGetBackupJobsMaxRunDate]    Script Date: 8/17/2016 8:12:11 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ==============================================================================
-- p_dba16_met_StealthGetBackupJobsMaxRunDate
--
-- Arguments:	None
--				None
--
-- Called BY:	None
--
-- Description:	Get the backup jobs by maxrundate in stealth mode.
-- 
-- Date				Modified By			Changes
-- 10/23/2008   Aron E. Tekulsky	Initial Coding.
-- 04/04/2012	Aron E. Tekulsky	Update to v100.
-- 11/19/2015	Aron E. Tekulsky	add summary/detail flag.
-- 05/10/2019	Aron E. Tekulsky    Update to Version 140.
-- ===============================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================

CREATE procedure [dbo].[p_dba16_met_StealthGetBackupJobsMaxRunDate] 
	@server_name	nvarchar(126),
	@summary		int
AS

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @cmd nvarchar(4000)

	--DECLARE @dbresults TABLE (
	--	instance_id		int, 
	--	job_id			uniqueidentifier, 
	--	step_id			int, 
	--	step_name		sysname,
	--	message			nvarchar(4000), 
	--	run_status		int,
	--	run_date		varchar(10),
	--	run_time		varchar(10),
	--	server			sysname,
	--	jobname			sysname, 
	--	description		nvarchar(512), 
	--	category_id		int, 
	--	enabled			tinyint,
	--	name			sysname)

			SET @cmd = 'SELECT ' + '''' + @server_name + '''' + ',h.instance_id, h.job_id, h.step_id, h.step_name,
				h.message, h.run_status, 
				dba_db08.dbo.f_dba08_convertintdatetostring(h.run_date) as run_date, 
				dba_db08.dbo.f_dba08_convertinttimetostring(h.run_time) as run_time, h.server,
				j.name as jobname, j.description, j.category_id, j.enabled,
				c.name
			FROM [' + @server_name + '].msdb.dbo.sysjobhistory h
				JOIN [' + @server_name + '].msdb.dbo.sysjobs j ON (h.job_id = j.job_id)
				JOIN [' + @server_name + '].msdb.dbo.syscategories c ON (j.category_id = c.category_id)
				JOIN [' + @server_name + '].dba_db08.dbo.v_max_backup_job_date m ON (h.job_id = m.job_id)
		WHERE h.step_id = 0 and
		--datediff(d,CONVERT(datetime,convert(char(8),h.run_date)),GETDATE()) >= 0 and
			datediff(d,CONVERT(datetime,convert(char(8),h.run_date)),convert(char(8),maxrundate)) = 0 and
			c.name = ' + '''' + 'Database Maintenance' + '''' + '
			and (j.name like (' + '''' + '%User Maint%' + '''' + ') or j.name like (' + '''' + '%System Maint%' + '''' + '))
		ORDER BY h.run_date DESC, h.run_time DESC'

		PRINT @cmd

			INSERT dba_db16.dbo.dba_dbbackups (servern, instance_id, job_id, step_id, step_name,
				message, run_status, run_date, run_time, server,jobname, description, category_id, enabled,
				name
				)
				exec (@CMD);

		--PRINT @cmd
		
		IF @summary = 1 
		BEGIN
			--SELECT	@server_name as servername,
			SELECT	servern as servername,
					instance_id,
					job_id,
					step_id,
					step_name,
					message,
					run_status,
					run_date,
					run_time,
					server,
					jobname,
					description,
					category_id,
					enabled,
					name
			FROM dba_db16.dbo.dba_dbbackups
		WHERE servern = @server_name;
		END








GO


