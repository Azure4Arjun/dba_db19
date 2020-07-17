SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_mnt_GetListofRestoredFilesonDB
--
--
-- Calls:		None
--
-- Description:	list to provide some proof that you did the restore from the
-- correct backup file.
--
-- https://www.mssqltips.com/sqlservertip/1860/identify-when-a-sql-server-databasewas-restored-the-source-and-backup-date/
--
-- 
-- Date			Modified By			Changes
-- 01/04/2019	Aron E. Tekulsky	Initial Coding.
-- 06/03/2019   Aron E. Tekulsky    Update to Version 140.
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
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @DBName NVARCHAR(128)

	SET @DBName = 'dba_db16';

	SELECT [rs].[destination_database_name]
			,[rs].[restore_date]
			,[bs].[backup_start_date]
			,[bs].[backup_finish_date]
			,[bs].[database_name] AS [source_database_name]
			,[bmf].[physical_device_name] AS [backup_file_used_for_restore]
		FROM msdb..restorehistory rs
			INNER JOIN msdb..backupset bs ON ([rs].[backup_set_id] = [bs].[backup_set_id])
			INNER JOIN msdb..backupmediafamily bmf ON ([bs].[media_set_id] = [bmf].[media_set_id])
	WHERE [rs].[destination_database_name] = @DBName
	ORDER BY [rs].[restore_date] DESC;
END
GO
