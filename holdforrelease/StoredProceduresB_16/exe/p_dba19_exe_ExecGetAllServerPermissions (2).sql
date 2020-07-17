SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_exe_ExecGetAllServerPermissions
--
-- Arguments:	None
--				None
--
-- CallS:		p_dba19_Get_AllServerPermissions
--				p_dba19_exe_ExecGetAllDBPermissions
--
-- Called BY:	None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 11/07/2016   Aron E. Tekulsky    Initial Coding.
-- 02/19/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_exe_ExecGetAllServerPermissions 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	PRINT 'Running p_dba19_Get_AllServerPermissions '

	EXEC p_dba19_sec_GetAllServerPermissions

	PRINT 'Running p_dba19_Exec_GetAllDBPermissions '

	EXEC p_dba19_exe_ExecGetAllDBPermissions

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_exe_ExecGetAllServerPermissions TO [db_proc_exec] AS [dbo]
GO
