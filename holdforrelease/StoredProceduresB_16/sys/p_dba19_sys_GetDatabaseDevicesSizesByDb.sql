SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_sys_GetDatabaseDevicesSizesByDb
--
-- Arguments:	@dbname nvarchar(128)
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get the device and sizes for a specific database.
-- 
-- Date			Modified By			Changes
-- 01/16/2013   Aron E. Tekulsky    Initial Coding.
-- 03/24/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_sys_GetDatabaseDevicesSizesByDb 
	-- Add the parameters for the stored procedure here
	@dbname nvarchar(128)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    -- first we get the device information.
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    SELECT @@servername as servername, dbname = db_name(dbid), devicename=name, filename, 
        sizemb=round((convert(float, size) * (SELECT low FROM master.dbo.spt_values
			WHERE type = 'E' and number = 1)
			 / 1048576), 1), fileid, dbid
		FROM sys.sysaltfiles
    WHERE db_name(dbid) = @dbname
    ORDER BY dbid, fileid ASC;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_sys_GetDatabaseDevicesSizesByDb TO [db_proc_exec] AS [dbo]
GO
