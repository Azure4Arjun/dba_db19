USE [DBA_DB19]
GO

/****** Object:  StoredProcedure [dbo].[p_dba19_sec_GetDBUserDBRolesByDB]    Script Date: 3/22/2018 6:39:55 PM ******/
DROP PROCEDURE [dbo].[p_dba19_sec_GetDBUserDBRolesByDB]
GO

/****** Object:  StoredProcedure [dbo].[p_dba19_sec_GetDBUserDBRolesByDB]    Script Date: 3/22/2018 6:39:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ======================================================================================
-- p_dba19_sec_GetDBUserDBRolesByDB
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	p_dba19_met_GetCompleteSystemDBSpecs
--
-- Description:	Get a list of all of the DB users and their DB roles.
-- 
-- Date			Modified By			Changes
-- 01/30/2012   Aron E. Tekulsky    Initial Coding.
-- 03/22/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE [dbo].[p_dba19_sec_GetDBUserDBRolesByDB] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
 	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    DECLARE @cmd				nvarchar(4000)
    DECLARE @dbname				nvarchar(128)

	DECLARE @userdbroles TABLE (
			dbname				nvarchar(128),
			name				nvarchar(128),
			principal_id		int,
			type_desc			nvarchar(60),
			default_schema_name	nvarchar(128),
			create_date			datetime,
			modify_date			datetime,
			role_name			nvarchar(128))

	DECLARE db_cur2 CURSOR FOR
		SELECT d.name
			FROM sys.databases d
		WHERE database_id > 4  AND
			state = 0;
		
	OPEN db_cur2;

	FETCH NEXT FROM db_cur2
		INTO @dbname;
	
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
    
			SET @cmd = 
				'SELECT ' + '''' + @dbname + '''' + ' as dbname, p.name, p.principal_id,p.type_desc, p.default_schema_name, p.create_date, p.modify_date,' + 
						'a.name
					FROM [' + @dbname + '].sys.database_principals p ' +
						'JOIN [' + @dbname + '].sys.database_role_members r ON ( p.principal_id = r.member_principal_id)
						JOIN [' + @dbname + '].sys.database_principals a ON (r.role_principal_id = a.principal_id)
				WHERE p.type in (' + '''' + 'U' + '''' + ',' + '''' + 'S' + '''' + ') AND
						(p.principal_id = 1 OR p.principal_id > 4) AND
						a.type = ' + '''' + 'R' + '''' + 
				'ORDER BY dbname ASC, p.name ASC, a.name ASC;';
			
			PRINT @cmd;
			
			INSERT INTO @userdbroles
				EXEC (@cmd);


			FETCH NEXT FROM db_cur2
				INTO @dbname;

		END
		
		CLOSE db_cur2;
		DEALLOCATE db_cur2;
		
		
		SELECT '*** DB User Roles ***', *
			FROM @userdbroles
		ORDER BY dbname ASC, name ASC, role_name ASC;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO

GRANT EXECUTE ON [dbo].[p_dba19_sec_GetDBUserDBRolesByDB] TO [db_proc_exec] AS [dbo]
GO


