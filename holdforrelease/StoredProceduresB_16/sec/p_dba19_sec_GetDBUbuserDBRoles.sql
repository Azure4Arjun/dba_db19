SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_sec_GetDBUbuserDBRoles
--
-- Arguments:	@dbname nvarchar(128)
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get a list of the DB users and their DB roles.
-- 
-- Date			Modified By			Changes
-- 01/30/2012   Aron E. Tekulsky    Initial Coding.
-- 03/23/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_sec_GetDBUbuserDBRoles 
	-- Add the parameters for the stored procedure here
	@dbname nvarchar(128)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
 	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

   DECLARE @cmd	nvarchar(4000)
    
    SET @cmd = 
	'SELECT ' + '''' + @dbname + '''' + ' as dbname, p.name, p.principal_id,p.type_desc, p.default_schema_name, p.create_date, p.modify_date,' + 
			--s.class_desc, s.permission_name, s.state_desc,
			'a.name
		FROM [' + @dbname + '].sys.database_principals p ' +
			--JOIN [' + @dbname + '].sys.database_permissions s ON (s.grantee_principal_id = p.principal_id)
			'JOIN [' + @dbname + '].sys.database_role_members r ON ( p.principal_id = r.member_principal_id)
			JOIN [' + @dbname + '].sys.database_principals a ON (r.role_principal_id = a.principal_id)
	WHERE p.type in (' + '''' + 'U' + '''' + ',' + '''' + 'S' + '''' + ') AND
		(p.principal_id = 1 OR p.principal_id > 4) AND
		a.type = ' + '''' + 'R' + '''' + 
	'ORDER BY p.name ASC, a.name ASC;';

	EXEC (@cmd);

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_sec_GetDBUbuserDBRoles TO [db_proc_exec] AS [dbo]
GO
