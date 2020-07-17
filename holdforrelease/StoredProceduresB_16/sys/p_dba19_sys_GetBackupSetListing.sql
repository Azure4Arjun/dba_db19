SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_sys_GetBackupSetListing
--
-- Arguments:	@backup_type	char(1)
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get a listing of backups made for each database.
-- 
-- Date			Modified By			Changes
-- 10/07/2009   Aron E. Tekulsky    Initial Coding.
-- 04/19/2012	Aron E. Tekulsky	Update to v100.
-- 03/20/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_sys_GetBackupSetListing 
	-- Add the parameters for the stored procedure here
	@backup_type	char(1)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @cmd nvarchar(2000)

--SET @sort_item = isnull(@sort_item,'database_name asc, backup_start_date desc')
--SET @backup_type = isnull(@backup_type,'D')

	IF @backup_type IS NUll OR @backup_type = ''
		SET @backup_type = 'D';
	
	SET @cmd = 'SELECT 
		server_name
		,machine_name
		,database_name
	    ,name
		,backup_start_date
		,backup_finish_date
		,type
	    ,backup_size
		,backup_set_id
		,backup_set_uuid
		,media_set_id
		,software_major_version
		,software_minor_version
		,software_build_version
		,first_lsn
		,last_lsn
		,checkpoint_lsn
		,database_backup_lsn
		,database_creation_date
		,collation_name
		,recovery_model
		,database_guid
		,family_guid
	FROM msdb.dbo.backupset
	WHERE type = ''' + upper(@backup_type) +
	''' order by database_name asc, backup_start_date desc';
	
	EXEC (@CMD);

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_sys_GetBackupSetListing TO [db_proc_exec] AS [dbo]
GO
