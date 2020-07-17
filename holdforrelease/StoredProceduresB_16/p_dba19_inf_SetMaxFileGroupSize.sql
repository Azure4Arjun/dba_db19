SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_inf_SetMaxFileGroupSize
--
-- Arguments:	@DBName				nvarchar(128), 
--				@LogicalFileName	sysname,  --
--				@NewMaxSize			int
--
-- CallS:		None
--
-- Called BY:	p_dba19_sys_GetDBFileSizes
--
-- Description:	Modify the Maxsize of the file group to accomodate growth.
-- 
-- Date			Modified By			Changes
-- 09/01/2016   Aron E. Tekulsky    Initial Coding.
-- 02/17/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_inf_SetMaxFileGroupSize 
	-- Add the parameters for the stored procedure here
	@DBName				nvarchar(128), 
	@LogicalFileName	sysname,  
	@NewMaxSize			int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @Cmd	nvarchar(4000)
	DECLARE @Result	int

	--ALTER DATABASE test9 MODIFY FILE (NAME=test9c, MAXSIZE = 2000 );

	SET @Cmd = 'ALTER DATABASE ' + @DBName + ' MODIFY FILE (' + 
			' NAME = ' + @LogicalFileName + 
			', MAXSIZE = ' + convert(nvarchar(100),@NewMaxSize) + ') ;';

	Print @Cmd

	EXEC (@Cmd);

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_inf_SetMaxFileGroupSize TO [db_proc_exec] AS [dbo]
GO
