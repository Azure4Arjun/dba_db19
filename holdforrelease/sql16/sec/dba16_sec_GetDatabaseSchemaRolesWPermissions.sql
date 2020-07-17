SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================================
-- dba16_sec_GetDatabaseSchemaRolesWPermissions
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 02/14/2017   Aron E. Tekulsky    Initial Coding.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

/****** Script for SelectTopNRows command from SSMS  ******/
	DECLARE @Cmd				nvarchar(4000)
	DECLARE @DbName				nvarchar(128)
	
	DECLARE @dbperms TABLE  (
	DBUserName					nvarchar(128),
	PrincipalId					int,
	type_desc					nvarchar(128),
	DBName						nvarchar(128),
	DefSchema					nvarchar(128),
	DbRoleName					nvarchar(128),
	Permissions					nvarchar(128),
	ObjectName					nvarchar(128))--,
	--authentication_type_desc	nvarchar(128),
	--SpName					nvarchar(128))

	DECLARE db_cur CURSOR FOR
		SELECT Name --,state_desc Status
			FROM sys.databases
		WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb','SISDB', 'ReportServer','ReportServerTempDB','dba_db08', 'SSISDB')
			AND state_desc = 'ONLINE'
			AND is_read_only <> 1 --means database=in read only mode
			AND CHARINDEX('-',name) = 0 -- no dashes in dbname
		ORDER BY NAME ASC;


	OPEN db_cur;

	FETCH NEXT FROM db_cur
		INTO 
			@dbname;

	WHILE(@@FETCH_STATUS <> -1)
		BEGIN
			SET @Cmd = 'USE [' + @DbName + ']' + 
			' ' + 
			'SELECT DISTINCT p.[name]
					,p.[principal_id]
					,p.[type_desc]
					,DB_NAME() as dbname
					,p.[default_schema_name]
					,s.name AS DBRole
  					,ISNULL(pe.[state_desc] + ' + '''' + ' ' + '''' +  ' + pe.permission_name + ' + '''' + ' ON ' + '''' + ',' + '''' + '''' + ' ) AS Permissions 
					,ISNULL(s.name + ' + '''' + '.' + '''' +  '+ o.name,' + '''' + '' + '''' + ') AS ObjectName
				FROM [sys].[database_principals] p
					LEFT JOIN [sys].[database_role_members] r ON (r.member_principal_id= p.principal_id)
					LEFT JOIN [sys].[schemas] s ON (s.principal_id = r.role_principal_id )
					LEFT JOIN sys.database_permissions AS pe  ON (pe.grantee_principal_id = p.principal_id)  
					LEFT JOIN sys.objects AS o  ON (pe.major_id = o.object_id)
			WHERE (p.principal_id = 1 OR p.principal_id > 4) AND p.principal_id < 16000
			ORDER BY p.principal_id ASC;'

			PRINT @Cmd

			INSERT @dbperms
				EXEC (@Cmd);
	
			FETCH NEXT FROM db_cur
				INTO 
					@dbname;

		END

	CLOSE db_cur;

	DEALLOCATE db_cur;

	SELECT DBName, DBUserName, type_desc,
		DefSchema, --authentication_type_desc, 
		--IF type_desc = 'DATABASE_ROLE'
		--	BEGIN
		--			DBUserName
		--	END
		--ELSE 
				DbRoleName ,
			 --AS DbRoleName, 
		Permissions, ObjectName--, SpName
		FROM @dbperms
	ORDER BY DBName, DBUserName ASC;

END
GO
