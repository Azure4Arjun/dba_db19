SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_GetDatabaseDevicesSizes
--
--
-- Calls:		None
--
-- Description:	Get all databse devices and their sizes.
-- 
-- Date			Modified By			Changes
-- 04/17/2017   Aron E. Tekulsky    Initial Coding.
-- 11/07/2017   Aron E. Tekulsky    Update to Version 140.
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

    SELECT @@servername as servername, dbname = db_name(dbid), devicename=name, filename, 
        sizemb=round((convert(float, size) * (select low from master.dbo.spt_values
			where type = 'E' and number = 1)
			 / 1048576), 1), fileid, dbid
		FROM sys.sysaltfiles
    ORDER BY dbid, fileid;

END
GO
