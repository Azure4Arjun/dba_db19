USE [DBA_DB19]
GO

/****** Object:  StoredProcedure [dbo].[p_dba19_sec_GetDBUserSecurablesByDB]    Script Date: 3/22/2018 6:40:36 PM ******/
DROP PROCEDURE [dbo].[p_dba19_sec_GetDBUserSecurablesByDB]
GO

/****** Object:  StoredProcedure [dbo].[p_dba19_sec_GetDBUserSecurablesByDB]    Script Date: 3/22/2018 6:40:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ======================================================================================
-- p_dba19_sec_GetDBUserSecurablesByDB
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	p_dba19_met_GetCompleteSystemDBSpecs
--
-- Description:	Get a list of the DB users and their securables.
-- 
-- Date			Modified By			Changes
-- 01/30/2013   Aron E. Tekulsky    Initial Coding.
-- 03/22/2016   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE [dbo].[p_dba19_sec_GetDBUserSecurablesByDB] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    DECLARE @cmd	nvarchar(4000)
    DECLARE @dbname nvarchar(128)
    
    DECLARE @securables TABLE (
			dbname				nvarchar(128),
			name				nvarchar(128),
			principal_id		int,
			type_desc			nvarchar(60),
			default_schema_name	nvarchar(128),
			create_date			datetime,
			modify_date			datetime,
			class_desc			nvarchar(60),
			permission_name		nvarchar(128),
			state_desc			nvarchar(60))
    
    DECLARE db_cur3 CURSOR FOR
		SELECT d.name
			FROM sys.databases d
		WHERE database_id > 4  AND
			state = 0;
		
	OPEN db_cur3;

	FETCH NEXT FROM db_cur3
		INTO @dbname;
	
	WHILE (@@FETCH_STATUS = 0)
		BEGIN

			SET @cmd = 
			'SELECT ' + '''' + @dbname + '''' + ' as dbname,p.name, p.principal_id,p.type_desc, p.default_schema_name, p.create_date, p.modify_date,
					s.class_desc, s.permission_name, s.state_desc--,
				FROM [' + @dbname + '].sys.database_principals p
					JOIN [' + @dbname + '].sys.database_permissions s ON (s.grantee_principal_id = p.principal_id)
			WHERE p.type in (' + '''' + 'U' + '''' + ',' + '''' + 'S' + '''' + ') AND
				(p.principal_id = 1 OR p.principal_id > 4)
			ORDER BY p.type_desc DESC, p.name ASC;'
		
		
			INSERT INTO @securables
				EXEC (@cmd);
				
			FETCH NEXT FROM db_cur3
				INTO @dbname;

		END
		
	CLOSE db_cur3;
	DEALLOCATE db_cur3;
	
	SELECT '*** DB Securables ***', *
		FROM @securables
	ORDER BY dbname ASC, type_desc ASC, name ASC;
	
	PRINT @cmd

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO

GRANT EXECUTE ON [dbo].[p_dba19_sec_GetDBUserSecurablesByDB] TO [db_proc_exec] AS [dbo]
GO


