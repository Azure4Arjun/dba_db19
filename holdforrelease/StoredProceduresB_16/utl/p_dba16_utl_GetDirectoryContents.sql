SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba16_utl_GetDirectoryContents
--
-- Arguments:	@foldername nvarchar(1000) = 0, 
--				@dirflag char(1) = 'N'
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get directory names and detail.
-- 
-- Date			Modified By			Changes
-- 08/13/2010   Aron E. Tekulsky    Initial Coding.
-- 04/19/2012	Aron E. Tekulsky	Update to v100.
-- 03/23/2018   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba16_utl_GetDirectoryContents 
	-- Add the parameters for the stored procedure here
	@foldername nvarchar(1000) = 0, 
	@dirflag char(1) = 'N'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @cmd			nvarchar(4000),
			@directory_only nvarchar(100)
			    
    -- check for null folder name
	IF @foldername IS NULL OR @foldername = ''
		BEGIN
			PRINT 'you must enter at least a folder';
			RETURN -1
		END
		
	-- check fo rdirectory name listing only
	IF UPPER(@dirflag) = 'Y'
		BEGIN
			SET @directory_only = '/a:d';
		END
	ELSE
		BEGIN
			SET @directory_only = '';
		END
--print @directory_only
		
	-- build the command
	SET @cmd = 'DIR \\' + @foldername + '/b' + @directory_only;

--print @cmd
	-- execute the command
	EXEC [dbo].[p_dba16_exe_ExecuteSQLCmdShell] @cmd;


	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba16_utl_GetDirectoryContents TO [db_proc_exec] AS [dbo]
GO
