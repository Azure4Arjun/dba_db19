-- ======================================================================================
-- dba16_sys_GetAllDBBackupSizesOneDay
--
-- Arguments:	@servername	nvarchar(128)
--				None
--
-- Called BY:	None
--
-- Description:	Get all database sizes to look for size changes one day only.
-- 
-- Date				Modified By			Changes
-- 09/26/2011   Aron E. Tekulsky	Initial Coding.
-- 04/04/2012	Aron E. Tekulsky	Update to v100.
-- 05/23/2013	Aron E. Tekulsky	Added backukset size col.
-- 01/09/2018   Aron E. Tekulsky    Update to V140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--@servername = @@ServerName;@servername AS Server_name,

	SELECT  b.database_name,  
			b.backup_start_date, a.backup_set_id, convert(numeric(20,2),a.file_size /1048576) as file_sizeMB,
			a.logical_name, a.[filegroup_name], a.physical_name, b.type,
			convert(numeric(20,2),b.backup_size/1048576) AS backupset_sizeMB 
		FROM msdb.dbo.backupfile a 
			JOIN msdb.dbo.backupset b ON a.backup_set_id = b.backup_set_id
	WHERE a.file_type = 'D' AND
			b.type = 'D' AND
			DATEDIFF( dy, b.backup_start_date,getdate()) = 0 
	ORDER BY b.database_name ASC, a.logical_name ASC, b.backup_start_date ASC

END

