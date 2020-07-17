SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_sec_GetDBUserSecurables
--
-- Arguments:	@dbname nvarchar(128)
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get a list of the DB users and their securables.
-- 
-- Date			Modified By			Changes
-- 01/30/2013   Aron E. Tekulsky    Initial Coding.
-- 1012/2016	Aron E. Tekulsky	update to include schemas and objects for
--									more granularity.
-- 02/27/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_sec_GetDBUserSecurables 
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
	'SELECT ' + '''' + @dbname + '''' + ' as dbname,p.name, p.principal_id,p.type_desc, p.default_schema_name, p.create_date, p.modify_date,
			d.class_desc, d.permission_name, d.state_desc--,
		FROM [' + @dbname + '].sys.database_principals p
			JOIN [' + @dbname + '].sys.database_permissions d ON (d.grantee_principal_id = p.principal_id)
			LEFT JOIN [' + @dbname + '].[sys].[objects] o ON (o.object_id = d.major_id )
			LEFT JOIN [sys].[schemas] s ON (s.schema_id = o.schema_id )
	 WHERE p.type in (' + '''' + 'U' + '''' + ',' + '''' + 'S' + '''' + ') AND
		(p.principal_id = 1 OR p.principal_id > 4)
		ORDER BY p.type_desc DESC, p.name ASC;'
		
	EXEC (@cmd)
	
	PRINT @cmd

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_sec_GetDBUserSecurables TO [db_proc_exec] AS [dbo]
GO
