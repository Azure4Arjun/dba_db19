SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba16_sys_GetDiskDriveSpace
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get the disk Drive space.
--				Note: must either seed the dba_diskdrives table or set up as truncate 
--				table prior to filling table.
-- 
-- Date			Modified By			Changes
-- 05/25/2012   Aron E. Tekulsky    Initial Coding.
-- 06/04/2012	Aron E. Tekulsky	Update to v100.
-- 03/31/2018   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba16_sys_GetDiskDriveSpace 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [dbo].[dba_diskdrives]
		EXEC XP_FIXEDDRIVES;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba16_sys_GetDiskDriveSpace TO [db_proc_exec] AS [dbo]
GO
