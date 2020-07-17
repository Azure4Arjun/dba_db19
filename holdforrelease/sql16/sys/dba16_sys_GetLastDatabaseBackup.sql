SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_GetLastDatabaseBackup
--
--
-- Calls:		None
--
-- Description:	Get a lilsting of the last datanbase backup fo reach db.
-- 
-- Date			Modified By			Changes
-- 05/08/2013   Aron E. Tekulsky    Initial Coding.
-- 10/17/2017   Aron E. Tekulsky    Update to Version 140.
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

	SELECT s.database_name, MAX(s.backup_start_date) AS max_backup_start_date, s.type
		FROM msdb.dbo.backupset AS s 
			LEFT OUTER JOIN sys.databases AS e ON s.database_name = e.name
	GROUP BY s.database_name, s.type;
END
GO
