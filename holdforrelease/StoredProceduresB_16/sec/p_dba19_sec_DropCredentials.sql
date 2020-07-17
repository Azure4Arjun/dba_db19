SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_sec_DropCredentials
--
-- Arguments:	@name					nvarchar(20)
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Drop a credential.
-- 
-- Date			Modified By			Changes
-- 01/30/2012   Aron E. Tekulsky	Initial Coding.
-- 04/04/2012	Aron E. Tekulsky	Update to v100.
-- 03/18/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_sec_DropCredentials 
	-- Add the parameters for the stored procedure here
	@name					nvarchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
 	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @cmd			nvarchar(4000)
	DECLARE @return_value	int

	SET @cmd = 'DROP CREDENTIAL ' + @name + ';'

	EXEC @return_value = @cmd;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_sec_DropCredentials TO [db_proc_exec] AS [dbo]
GO
