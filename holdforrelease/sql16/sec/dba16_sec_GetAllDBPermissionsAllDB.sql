SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sec_GetAllDBPermissionsAllDB
--
--
-- Calls:		None
--
-- Description:	Get all Database permissions for each DB user including proxies
--				on all db's combined.
-- 
-- Date			Modified By			Changes
-- 11/05/2016   Aron E. Tekulsky    Initial Coding.
-- 02/15/2017	Aron E. Tekulsky	Add @WinUsrFlg to allow filtering.
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
	DECLARE @DbName				nvarchar(128)
	DECLARE @Cmd				nvarchar(4000)
	DECLARE @WinUsrFlg			char(1)

	DECLARE @dbperms TABLE  (
	DBName						nvarchar(128),
	DBUserName					nvarchar(128),
	type_desc					nvarchar(128),
	DefSchema					nvarchar(128),
	authentication_type_desc	nvarchar(128),
	DbRoleName					nvarchar(128),
	Permissions					nvarchar(128),
	ObjectName					nvarchar(128),
	SpName						nvarchar(128))


	SET @WinUsrFlg = 'W';


	DECLARE db_cur CURSOR FOR
		SELECT Name --,state_desc Status
			FROM sys.databases
		WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb','SISDB', 'ReportServer','ReportServerTempDB','dba_db08', 'SSISDB', 'BI UAT ReportServer','BI UAT ReportServerTempDB','ReportServer','ReportServerTempDB')
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
	------SET @DbName = 'dba_db08';

	SET @Cmd = 'USE [' + @DbName + ']' + 
	' ' + 
	'SELECT DB_NAME() AS DBName
		  ,pr.[name] AS DBUserName
		  ,pr.[type_desc]
		  ,ISNULL(pr.[default_schema_name],' + '''' + '' + '''' + ') AS DefSchema
		 ,pr.[authentication_type_desc]
		,r.name AS DbRoleName
		  ,ISNULL(pe.[state_desc] + ' + '''' + ' ' + '''' +  ' + pe.permission_name + ' + '''' + ' ON ' + '''' + ',' + '''' + '''' + ' ) AS Permissions 
		  ,ISNULL(s.name + ' + '''' + '.' + '''' +  '+ o.name,' + '''' + '' + '''' + ') AS ObjectName
		  ,sp.[name]
	FROM [sys].[database_principals] pr
			JOIN sys.database_role_members m ON (m.member_principal_id = pr.principal_id )
			JOIN [sys].[database_principals] r ON (r.principal_id = m.role_principal_id)
			LEFT JOIN sys.database_permissions AS pe  ON (pe.grantee_principal_id = r.principal_id)  
			LEFT JOIN sys.objects AS o  ON (pe.major_id = o.object_id)
			LEFT JOIN sys.schemas AS s  ON (o.schema_id = s.schema_id)
			LEFT JOIN sys.server_principals sp ON (sp.name = pr.[name])
	WHERE sp.is_disabled <> 1
	ORDER BY pr.[name] ASC, r.principal_id DESC'

	PRINT @Cmd

	INSERT @dbperms
		EXEC (@Cmd);
	
	FETCH NEXT FROM db_cur
		INTO 
			@dbname;

	END

	CLOSE db_cur;

	DEALLOCATE db_cur;

	IF @WinUsrFlg = 'W'
		SELECT DBName, DBUserName, type_desc, DefSchema, authentication_type_desc, DbRoleName, Permissions, ObjectName, SpName
			FROM @dbperms
		WHERE type_desc like ('WINDOWS%')
		ORDER BY DBName, DBUserName ASC;
	
	ELSE IF @WinUsrFlg = 'S'
			SELECT DBName, DBUserName, type_desc, DefSchema, authentication_type_desc, DbRoleName, Permissions, ObjectName, SpName
				FROM @dbperms
			WHERE type_desc NOT like ('WINDOWS%')
			ORDER BY DBName, DBUserName ASC;
		ELSE 
			SELECT DBName, DBUserName, type_desc, DefSchema, authentication_type_desc, DbRoleName, Permissions, ObjectName, SpName
				FROM @dbperms
			--WHERE type_desc like ('WINDOWS%')
			ORDER BY DBName, DBUserName ASC;


END
GO
