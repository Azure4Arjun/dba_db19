SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba16_exe_AlterCredentials
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Alter a credential.
-- 
-- Date			Modified By			Changes
-- 01/10/2012   Aron E. Tekulsky    Initial Coding.
-- 04/04/2012	Aron E. Tekulsky	Update to v100.
-- 02/11/2018   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba16_exe_AlterCredentials 
	-- Add the parameters for the stored procedure here
	@name					nvarchar(20), 
	@windows_user			nvarchar(20),
	@pw						nvarchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @cmd			nvarchar(2000)
	DECLARE @return_value	int

    -- Insert statements for procedure here
	SET @cmd = 'ALTER CREDENTIAL ' + @name + 'WITH IDENTITY =' + '''' + @windows_user + '''' + ', 
			SECRET = ' + '''' + @pw + '''' + ';';

	--@return_value = 
	EXEC xp_cmdshell @cmd;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba16_exe_AlterCredentials TO [db_proc_exec] AS [dbo]
GO
