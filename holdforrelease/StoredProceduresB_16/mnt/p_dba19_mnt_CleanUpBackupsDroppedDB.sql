SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_mnt_CleanUpBackupsDroppedDB
--
-- Arguments:	@DatabaseName			nvarchar(128),
--				@DbBackupLocation		nvarchar(2000)
--
-- CallS:		p_dba19_exe_ExecuteSQLCmdShell
--
-- Called BY:	p_dba19_mnt_del_expired_db
--
-- Description:	Clean up the backups for a database that was dropped.
-- 
-- Date			Modified By			Changes
-- 08/23/2016   Aron E. Tekulsky    Initial Coding.
-- 02/19/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_mnt_CleanUpBackupsDroppedDB 
	-- Add the parameters for the stored procedure here
	@DatabaseName			nvarchar(128),
	@DbBackupLocation		nvarchar(2000)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @Cmd			nvarchar(4000)

	IF @DatabaseName IS NULL OR @DatabaseName = '' OR CHARINDEX ('\',@DatabaseName) <> 0
		GOTO ErrorHandler;

	IF @DbBackupLocation IS NULL OR @DbBackupLocation = '' OR SUBSTRING(@DbBackupLocation,LEN (@DbBackupLocation),1) = '\'
		GOTO ErrorHandler;


	SET @Cmd = 'RMDIR ' + @DbBackupLocation + '\' + @DatabaseName + ' /S/Q'

	PRINT 'Deleting the folder ' + @DbBackupLocation + '\' + @DatabaseName + ' including all backup files under that folder on Server ' + @@SERVERNAME

	PRINT  @Cmd

	EXEC p_dba19_exe_ExecuteSQLCmdShell @Cmd;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_mnt_CleanUpBackupsDroppedDB TO [db_proc_exec] AS [dbo]
GO
