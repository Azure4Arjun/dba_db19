SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_sec_CreateCredentials
--
-- Arguments:	@name					nvarchar(20) 
--				@windows_user			nvarchar(20)
--				@pw						nvarchar(20)
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Create a proxy acct or other credential.
-- 
-- Date			Modified By			Changes
-- 01/10/2012	Aron E. Tekulsky	Initial Coding.
-- 04/04/2012	Aron E. Tekulsky	Update to v100.
-- 02/27/2018   Aron E. Tekulsky    Update to Version 140.
-- 02/27/2018   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyrightę2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_sec_CreateCredentials 
	-- Add the parameters for the stored procedure here
	@name					nvarchar(20), 
	@windows_user			nvarchar(20),
	@pw						nvarchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	DECLARE @cmd			nvarchar(2000)
	DECLARE @return_value	int

	SET @cmd = 'CREATE CREDENTIAL ' + @name + 'WITH IDENTITY =' + '''' + @windows_user + '''' + ', 
			SECRET = ' + '''' + @pw + '''' + ';';

	EXEC  @return_value = @cmd;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_sec_CreateCredentials TO [db_proc_exec] AS [dbo]
GO
