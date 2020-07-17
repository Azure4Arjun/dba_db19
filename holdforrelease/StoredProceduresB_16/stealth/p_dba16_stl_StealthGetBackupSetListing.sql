USE [dba_db16]
GO

/****** Object:  StoredProcedure [dbo].[p_dba16_stl_StealthGetBackupSetListing]    Script Date: 7/27/2019 8:51:48 AM ******/
DROP PROCEDURE [dbo].[p_dba16_stl_StealthGetBackupSetListing]
GO

/****** Object:  StoredProcedure [dbo].[p_dba16_stl_StealthGetBackupSetListing]    Script Date: 7/27/2019 8:51:48 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ==============================================================================
-- p_dba16_stl_StealthGetBackupSetListing
--
-- Arguments:		@backup_type	char(1),
--					@server_name	nvarchar(126)
--
-- Called BY:		None
-- Calls:			None
--
-- Description:	Stealth Edition. Get a listing of backups made for each database.
-- 
-- Date			Modified By			Changes
-- 10/07/2009   Aron E. Tekulsky    Initial Coding.
-- 11/04/2009	Aron E. Tekulsky	Add zip file  name and destination.
-- 12/02/2009	Aron E. Tekulsky	eliminate connection to disaster_dblist table.
--									also make sure only active rows for serves are used.
-- 04/19/2012	Aron E. Tekulsky	Update to v100.
-- 07/27/2019	Aron E. Tekulsky	Update to v140.
-- ===============================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================

CREATE PROCEDURE [dbo].[p_dba16_stl_StealthGetBackupSetListing] 
	-- Add the parameters for the stored procedure here
	@backup_type	char(1),
	@server_name	nvarchar(126)
	--@sort_item		char(1)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statementb.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
/****** Script for SelectTopNRows command from SSMS  ******/
		DECLARE @cmd				nvarchar(2000),
				@mindate			datetime,
				@mindatestring		varchar(20),
				@validserver		varchar(50),
				@dbadb_exists		smallint

		DECLARE @backupsets TABLE (
		server_name					nvarchar(128),
		machine_name				nvarchar(128),
		database_name				nvarchar(128),
	    name						nvarchar(128),
		backup_start_date			datetime,
		backup_finish_date			datetime,
		type						char(1),
	    backup_size					numeric(20,0),
		backup_set_id				int,
		backup_set_uuid				uniqueidentifier,
		media_set_id				int,
		software_major_version		tinyint,
		software_minor_version		tinyint,
		software_build_version		smallint,
		first_lsn					numeric(25,0),
		last_lsn					numeric(25,0),
		checkpoint_lsn				numeric(25,0),
		database_backup_lsn			numeric(25,0),
		database_creation_date		datetime,
		collation_name				nvarchar(128),
		physical_device_name		nvarchar(250),
		family_sequence_number		tinyint)

		SET @mindate = dateadd(month, -3,getdate())
		SET @mindatestring = convert(varchar(20),@mindate)

--print @mindate

--SET @sort_item = isnull(@sort_item,b.'database_name asc,b. backup_start_date desc')
--SET @backup_type = isnull(@backup_type,b.'D')

	IF @backup_type IS NUll OR @backup_type = ''
		SET @backup_type = 'D'
	
	IF @server_name IS NULL OR @server_name = ''
		SET @server_name = @@servername 
		--,b.recovery_model
		--,b.database_guid
		--,b.family_guid
	
-- check to see if sever has dbadb
	SELECT @dbadb_exists = s.dbadb_exists
		FROM dba_db16.dbo.dba_database_servers s
		WHERE s.server_name = @server_name and
			row_status = 'A'


	SET @cmd = 'SELECT 
		b.server_name
		,b.machine_name
		,b.database_name
	    ,b.name
		,b.backup_start_date
		,b.backup_finish_date
		,b.type
	    ,b.backup_size
		,b.backup_set_id
		,b.backup_set_uuid
		,b.media_set_id
		,b.software_major_version
		,b.software_minor_version
		,b.software_build_version
		,b.first_lsn
		,b.last_lsn
		,b.checkpoint_lsn
		,b.database_backup_lsn
		,b.database_creation_date
		,b.collation_name
		,f.physical_device_name
		,f.family_sequence_number'

 
	--IF @dbadb_exists IS NOT NULL AND @dbadb_exists = 1
	--	BEGIN
	--		SET @cmd = @cmd + 
	--				',d.destination_server
	--				,d.source_path '
	--	END
	--ELSE
	--	BEGIN
	--		SET @cmd = @cmd + 
	--				','' '' as destination_server
	--				,'' '' as source_path'
	--	END

	SET @cmd = @cmd + 
		' FROM [' + @server_name +'].msdb.dbo.backupset b
		JOIN [' + @server_name +'].msdb.dbo.backupmediafamily f ON (b.media_set_id = f.media_set_id)'


	--IF @dbadb_exists IS NOT NULL AND @dbadb_exists = 1
	--	BEGIN
	--		SET @cmd = @cmd + 
	--	    ' JOIN ' + @server_name +'.dba_db.dbo.dba_disaster_dblist  d ON (b.database_name = d.name) ' +
	--		' JOIN dba_db.dbo.dba_database_servers s ON (b.server_name = s.server_name)' 
	--	END
--
--	IF @validserver IS NULL
--		BEGIN
--			SET @cmd = @cmd +
--				' FROM ' + @server_name +'.msdb.dbo.backupset b
--				JOIN ' + @server_name +'.msdb.dbo.backupmediafamily f ON (b.media_set_id = f.media_set_id)'
--		END

	SET @cmd = @cmd +
				' WHERE type = ''' + upper(@backup_type) + 
					''' AND datediff(dd, b.backup_start_date,convert(datetime,''' + @mindatestring + 
					''')) <= 31 order by database_name asc, b.backup_start_date desc'

 print @cmd
--print '@@servername = ' + @@servername

INSERT INTO @backupsets
	EXEC (@CMD);
	

SELECT server_name,	machine_name,database_name, name, backup_start_date, backup_finish_date, type,
	    backup_size, backup_set_id, backup_set_uuid, media_set_id, software_major_version,
		software_minor_version, software_build_version, first_lsn, last_lsn, checkpoint_lsn,
		database_backup_lsn, database_creation_date, collation_name, physical_device_name,
		family_sequence_number
	FROM @backupsets;
	
	
END














GO

GRANT EXECUTE ON [dbo].[p_dba16_stl_StealthGetBackupSetListing] TO [db_proc_exec] AS [dbo]
GO


