-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- p_dba_do_newdb_backup
--
-- Arguments:	@dbname
--					None
--
-- Called BY:	ddlsvrtrg_CREATE_DATABASE_LOG
--
-- Description:	Create the initial full backup of a brand new db so that teh hourly transaction log can run.
-- 
-- Date			Modified By			Changes
-- 05/30/2012   Aron E. Tekulsky    Initial Coding.
-- =============================================
CREATE PROCEDURE p_dba_do_newdb_backup 
	-- Add the parameters for the stored procedure here
	@dbname					nvarchar(128),
	@backup_location	nvarchar(1000)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @query_cmd					nvarchar(1000)
	DECLARE @backup_type2			nvarchar(10)
	--DECLARE @backup_location	nvarchar(1000)
	DECLARE @database_name			nvarchar(1000)
	DECLARE @backup_date_text		nvarchar(8)
	DECLARE @backup_time_text		nvarchar(8)
	DECLARE @filetype						char(3)
	DECLARE @backupdate				datetime
	DECLARE @compatability_level	tinyint -- 80 sql 2000, 90 sql 2005, 100 sql 2008
	DECLARE @servername				nvarchar(100)

	
	SELECT @compatability_level = d.compatibility_level
		FROM master.sys.databases d
	WHERE d.name = @dbname AND 
				d.recovery_model = 1 AND -- 1 full 2 bulk logged 3 simple
				d.state = 0 AND  -- 0 online 6 offline 1 restoring
				d.snapshot_isolation_state = 0 -- 0 off 1 on

	-- get the backup location
	IF @backup_location is null or @backup_location = ''
		-- backup location not specified so use standard locations
		BEGIN
			IF  @compatability_level = 80
				BEGIN
					SET @backup_location = 'F:\Program Files\Microsoft SQL Server\MSSQL\BACKUP\'
				END
			
			ELSE IF  @compatability_level = 90
					BEGIN
						SET @backup_location = 'F:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\BACKUP\'
					END
			ELSE IF  @compatability_level = 100
					BEGIN
						SET @backup_location = 'F:\Program Files\Microsoft SQL Server\MSSQL10.' +  @servername + '\mssql\MSSQL\BACKUP\'
					--SET @backup_location = 'F:\Program Files\Microsoft SQL Server\MSSQL10.' +  QUOTENAME (@servername,'''') + '\mssql\MSSQL\BACKUP\'
				END
		END

	-- get the backup date and time
	SET @backupdate = getdate()

	SET @backup_date_text = convert(varchar(8),@backupdate,112)
	SET @backup_time_text = convert(varchar(8),@backupdate,108)
	SET @backup_time_text = substring(@backup_time_text,1,2) + SUBSTRING (@backup_time_text,4,2) + SUBSTRING (@backup_time_text,7,2)

	SET @backup_type2 = 'DATABASE'
	SET @database_name = @dbname
	--SET @backup_location = 
	--SET @backup_date_text = 
	--SET @backup_time_text = 
	SET @filetype = '.bak'

	SET @query_cmd = 'BACKUP ' + @backup_type2 + ' [' + @database_name + '] TO  DISK = N' + '''' + 
			@backup_location + @database_name + '_backup_' + 
	 +		@backup_date_text + @backup_time_text + '.' + @filetype + '''' +
			' WITH NOFORMAT, NOINIT,  NAME = N' + '''' +@database_name+ '_backup_'

	SET @query_cmd = @query_cmd + ' ' + @backup_date_text + @backup_time_text  + '''' + ', SKIP, REWIND, NOUNLOAD,  STATS = 10, CHECKSUM, CONTINUE_AFTER_ERROR'


	print @query_cmd

   --EXEC (@query_cmd);

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba_do_newdb_backup TO [db_proc_exec] AS [dbo]
GO
