SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_exe_ExecGetAllDBPermissions
--
-- Arguments:	None
--				None
--
-- CallS:		p_dba19_Get_AllDBPermissions
--
-- Called BY:	p_dba19_Exec_GetAllServerPermissions
--
-- Description:	Build a list of all user db and call routine to list out all 
--				permissions on that database.
-- 
-- Date			Modified By			Changes
-- 11/07/2016   Aron E. Tekulsky    Initial Coding.
-- 02/18/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_exe_ExecGetAllDBPermissions 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @dbname					nvarchar(128)
	--DECLARE @UserDB					nvarchar(128)

	-- setup to get the dbnames
	DECLARE db_cur CURSOR FOR
		SELECT Name --,state_desc Status
			FROM sys.databases
		WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb')
			AND state_desc = 'ONLINE'
			AND is_read_only <> 1 --means database=in read only mode
			AND CHARINDEX('-',name) = 0 -- no dashes in dbname
		order by name asc;


	OPEN db_cur;

	FETCH NEXT FROM db_cur
		INTO 
			@dbname;

	WHILE(@@FETCH_STATUS <> -1)
		BEGIN
			EXEC p_dba19_sec_GetAllDBPermissions @dbname

			FETCH NEXT FROM db_cur
				INTO 
					@dbname;

		END

	IF @@ERROR <> 0 GOTO ErrorHandler

	CLOSE db_cur;

	DEALLOCATE db_cur;


	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_exe_ExecGetAllDBPermissions TO [db_proc_exec] AS [dbo]
GO
