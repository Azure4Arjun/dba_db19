SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_GetDBMissingInitialBackup
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 05/08/2013   Aron E. Tekulsky    Initial Coding.
-- 10/07/2017   Aron E. Tekulsky    Update to Version 140.
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

	SELECT d.name, d.database_id, d.create_date, d.state_desc, d.recovery_model_desc, d.compatibility_level
		FROM sys.databases d
	WHERE d.database_id > 4 AND
			d.name NOT IN 
			(SELECT b.database_name
				FROM msdb.dbo.backupset b)
	ORDER BY d.database_id asc, d.name ASC

END
GO
