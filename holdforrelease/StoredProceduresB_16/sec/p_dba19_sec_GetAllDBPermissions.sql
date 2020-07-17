SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_sec_GetAllDBPermissions
--
-- Arguments:	@dbname	nvarchar(128)
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get all Databse permissions for each DB user including proxies.
-- 
-- Date			Modified By			Changes
-- 11/07/2016   Aron E. Tekulsky    Initial Coding.
-- 02/19/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_sec_GetAllDBPermissions 
	-- Add the parameters for the stored procedure here
	@dbname	nvarchar(128)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @cmd	nvarchar(4000)

	SET @cmd = 'USE [' + @dbname + '] ; ' +
	
	'
	SELECT DB_NAME() AS DBName
		  ,pr.[name] AS DBUserName
		  ,pr.[type_desc]
		  ,ISNULL(pr.[default_schema_name],' + '''' + '''' + ') AS DefSchema
		  ,pr.[authentication_type_desc]
		  ,r.name AS DbRoleName
		  ,ISNULL(pe.[state_desc] + ' + '''' +  '''' + ' +  pe.permission_name + ' + '''' + ' ON ' + '''' + ',' + '''' + '''' + 
		  ') AS Permissions  
		  ,ISNULL(s.name + ' + '''' + '.' + '''' + ' + o.name,' + '''' + '''' + ') AS ObjectName
	FROM [sys].[database_principals] pr
			JOIN sys.database_role_members m ON (m.member_principal_id = pr.principal_id )
			JOIN [sys].[database_principals] r ON (r.principal_id = m.role_principal_id)
			LEFT JOIN sys.database_permissions AS pe  ON (pe.grantee_principal_id = r.principal_id)  
			LEFT JOIN sys.objects AS o  ON (pe.major_id = o.object_id)
			LEFT JOIN sys.schemas AS s  ON (o.schema_id = s.schema_id)
	ORDER BY pr.[name] ASC, r.principal_id DESC'

	PRINT @cmd

	EXEC (@cmd)


	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_sec_GetAllDBPermissions TO [db_proc_exec] AS [dbo]
GO
