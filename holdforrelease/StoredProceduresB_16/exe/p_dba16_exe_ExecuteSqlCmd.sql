SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba16_exe_ExecuteSqlCmd
--
-- Arguments:	@sqlcmd nvarchar(1000)
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	execute the script.
-- 
-- Date			Modified By			Changes
-- 11/18/2008   Aron E. Tekulsky    Initial Coding.
-- 04/19/2012	Aron E. Tekulsky	Update to v100.
-- 03/18/2018   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba16_exe_ExecuteSqlCmd 
	-- Add the parameters for the stored procedure here
	@sqlcmd nvarchar(1000)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @Result int
	
	SET @sqlcmd = '\\localhost\sql_binn\SQLCMD.EXE -E -S' + @@servername + ' -Q"' + @sqlcmd + ' "';

	PRINT @sqlcmd;

	EXEC @Result = xp_cmdshell @sqlcmd ;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN @Result

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba16_exe_ExecuteSqlCmd TO [db_proc_exec] AS [dbo]
GO
