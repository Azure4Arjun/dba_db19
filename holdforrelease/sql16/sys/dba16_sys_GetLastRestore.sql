SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_GetLastRestore
--
--
-- Calls:		None
--
-- Description:	Get the last restore dat for each db.
-- 
-- Date			Modified By			Changes
-- 05/08/2013   Aron E. Tekulsky    Initial Coding.
-- 10/22/2017   Aron E. Tekulsky    Update to Version 140.
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

	SELECT h.destination_database_name, MAX(h.restore_date) AS max_restore_date
		FROM msdb.dbo.restorehistory AS h 
			LEFT OUTER JOIN sys.databases AS e ON h.destination_database_name = e.name
	WHERE (h.restore_type = 'D')
	GROUP BY h.destination_database_name;
END
GO
