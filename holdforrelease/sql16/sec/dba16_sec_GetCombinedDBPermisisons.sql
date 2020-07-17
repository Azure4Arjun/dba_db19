SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sec_GetCombinedDBPermisisons
--
--
-- Calls:		None
--
-- Description:	Get alisting of the combuined permisisons for each object in the databse.
-- 
-- Date			Modified By			Changes
-- 11/23/2016   Aron E. Tekulsky    Initial Coding.
-- 11/22/2017   Aron E. Tekulsky    Update to Version 140.
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


	DECLARE @cmd						nvarchar(4000)
	DECLARE @CompatibilityLevel			tinyint
	DECLARE @dbname						nvarchar(128)
	DECLARE @DbRolestoShow				char(1)
	DECLARE @Include					char(1)

	DECLARE @AllDBTable TABLE (
			Purpose						char(1),
			DBNam						nvarchar(128),
		    DBUserName					nvarchar(128),
			TypeDesc					nvarchar(60),
			DefSchema					nvarchar(128),
			AuthenticationTypeDesc		nvarchar(60),
			DbRoleName					nvarchar(128),
			Perms						nvarchar(256),
			ObjectName					nvarchar(256),
			CreateDate					datetime,
			ModifyDate					datetime,
			IsDisabled					bit)






	------------SET @Include = 'S'; -- S SQL only, U Windows only, B SQL and Windows only, G Windows groups only, A All
	------------SET @Include = 'U'; -- S SQL only, U Windows only, B SQL and Windows only, G Windows groups only, A All
	------------SET @Include = 'B'; -- S SQL only, U Windows only, B SQL and Windows only, G Windows groups only, A All
	------------SET @Include = 'G'; -- S SQL only, U Windows only, B SQL and Windows only, G Windows groups only, A All
	SET @Include = 'B'; -- S SQL only, U Windows only, B SQL and Windows only, G Windows groups only, A All


	------------SET @DbRolestoShow = 'A'; -- Application Roles only and Server Roles. Includes db_owner and RSExecRole
	------------SET @DbRolestoShow = 'S'; -- Server Database Roles only
	SET @DbRolestoShow = 'S';  -- All Roles.

/* *************	-- Server Permissions **************** */

	SET @cmd = 'SELECT ' +  '''' + 'A' + '''' + 
					',mb.default_database_name AS DBNam
					, mb.name AS MemberName 
					, '  + '''' + 'SERVER_PERMISSION' + '''' + ' AS TypeDesc' +
					', ' + '''' + 'dbo' + '''' + ' AS DefSchema' +
					', ' + '''' + 'SERVER' +'''' + ' AS AuthenticationTypeDesc' + 
					',ISNULL(rl.name,' + '''' + '''' + ') AS DbRoleName
					,s.state_desc + ' + '''' +  + ' ' + '''' + ' + s.permission_name AS Perms
					,ISNULL(cr.name,' + '''' + '''' + ') AS ObjectName
					,mb.create_date AS CreateDate
					,mb.modify_date AS ModifyDate
					, mb.is_disabled AS IsDisabled
				FROM sys.server_principals AS mb
					LEFT JOIN sys.server_role_members  rm ON (rm.member_principal_id = mb.principal_id )
					LEFT JOIN sys.server_principals AS rl  ON (rm.role_principal_id = rl.principal_id  )
					JOIN sys.server_permissions AS s  ON (s.grantee_principal_id = mb.principal_id)
					LEFT JOIN sys.credentials cr ON (cr.credential_identity = mb.name)'

	IF @Include = 'S'
		BEGIN
			 SET @cmd = @cmd + 'WHERE  mb.[type] IN (' + '''' + 'S' + '''' + ') AND '
		END
	ELSE IF @Include = 'U'
			BEGIN
				SET @cmd = @cmd + 'WHERE  mb.[type] IN (' + '''' + 'U' + '''' + ') AND '
			END
	ELSE IF @Include = 'B'
			BEGIN
				SET @cmd = @cmd + 'WHERE  mb.[type] IN (' + '''' + 'S' + '''' + ',' + '''' + 'U' + ''''  + ') AND '
			END
	ELSE IF @Include = 'G'
			BEGIN
				SET @cmd = @cmd + 'WHERE  mb.[type] IN (' +  '''' + 'G' + '''' + ') AND '
			END
	ELSE 
			BEGIN
				SET @cmd = @cmd + 'WHERE  mb.[type] IN (' + '''' + 'S' + '''' + ',' + '''' + 'U' + '''' + ',' + '''' + 'G' + '''' + ') AND '
			END
				
	--SET @cmd = @cmd +	' mb.is_disabled = 0 AND
	SET @cmd = @cmd +	' 
					mb.name NOT LIKE (' + '''' + 'NT SERVICE\%' + '''' + ')
					AND mb.name NOT LIKE (' + '''' + 'NT AUTHORITY\%' + '''' + ')
					AND mb.name NOT LIKE (' + '''' + '##%##' + '''' + ')		
			 ORDER BY mb.name ASC, rl.principal_id DESC'

	PRINT @cmd

	INSERT INTO @AllDBTable
		EXEC (@cmd);

/* *******************    DB Security ******************* */

	-- setup to get the dbnames
	DECLARE db_cur CURSOR FOR
		SELECT Name, compatibility_level --,state_desc Status
			FROM sys.databases
		WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb','SSISDB', 'ADVENTUREWORKS2014', 'dba_db08', 'ReportServer', 'ReportServerTempDB','MSXDBCDC')
		--WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb','SSISDB', 'ADVENTUREWORKS2014')
			AND state_desc = 'ONLINE'
			AND is_read_only <> 1 --means database=in read only mode
			--AND CHARINDEX('-',name) = 0 -- no dashes in dbname
		ORDER BY name ASC;


	OPEN db_cur;

	FETCH NEXT FROM db_cur
		INTO 
			@dbname, @CompatibilityLevel;

	WHILE(@@FETCH_STATUS <> -1)
		BEGIN

		-- DB Permissions

			SET @cmd = 'USE [' + @dbname + '] ; ' + CHAR(13) + 
					'	SELECT ' + '''' + 'B' + '''' + ', DB_NAME() AS DBName
						  ,pr.[name] AS DBUserName
						  ,pr.[type_desc]
						  ,ISNULL(pr.[default_schema_name],' + '''' + '''' + ') AS DefSchema'  


			IF @CompatibilityLevel >= 110
				BEGIN

					SET @cmd = @cmd + 
						  ',pr.[authentication_type_desc]' 
				END
			ELSE
				BEGIN
					SET @cmd = @cmd + 
						  ', ' + '''' +  '''' +  ' AS authentication_type_desc'
				END
					
			SET @cmd = @cmd	 + ',r.name AS DbRoleName
						  ,ISNULL(pe.[state_desc] + ' + '''' +  ' ' + '''' +  ' +  pe.permission_name + ' + '''' + ' ON ' + '''' + ',' + '''' + '''' + 
						  ') AS Permissions  
						  ,ISNULL(s.name + ' + '''' + '.' + '''' + ' + o.name,' + '''' + '''' + ') AS ObjectName
						  , NULL AS CreateDate, NULL AS ModifyDate
						  , NULL AS IsDisabled
						FROM [sys].[database_principals] pr
							JOIN sys.database_role_members m ON (m.member_principal_id = pr.principal_id )
							JOIN [sys].[database_principals] r ON (r.principal_id = m.role_principal_id)
							LEFT JOIN sys.database_permissions AS pe  ON (pe.grantee_principal_id = r.principal_id)  
							LEFT JOIN sys.objects AS o  ON (pe.major_id = o.object_id)
							LEFT JOIN sys.schemas AS s  ON (o.schema_id = s.schema_id)'


			IF @Include = 'S'
				BEGIN
					 SET @cmd = @cmd + 'WHERE pr.[type] IN (' + '''' + 'S' + '''' + ') AND'
				END
			ELSE IF @Include = 'U'
					BEGIN
						SET @cmd = @cmd + 'WHERE pr.[type] IN (' + '''' + 'U' + '''' + ') AND'
					END
			ELSE IF @Include = 'B'
					BEGIN
						SET @cmd = @cmd + 'WHERE pr.[type] IN (' + '''' + 'U' + '''' + ',' + '''' + 'S' + '''' + ') AND'
					END
			ELSE IF @Include = 'G'
					BEGIN
						SET @cmd = @cmd + 'WHERE pr.[type] IN (' + '''' + 'G' + '''' + ') AND'
					END
			ELSE 
				BEGIN
					SET @cmd = @cmd + 'WHERE pr.[type] IN (' + '''' + 'U' + '''' + ',' + '''' + 'S' + '''' + ',' + '''' + 'G' + '''' + ') AND'
				END

					--------'WHERE pr.[type] IN (' + '''' + 'U' + '''' + ',' + '''' + 'S' + '''' + ',' + '''' + 'G' + '''' + ') AND
			SET @cmd = @cmd	 + ' pr.[name] NOT LIKE (' + '''' + 'NT AUTHORITY\%' + '''' + ') 
					ORDER BY pr.[name] ASC, r.principal_id DESC'
				
			PRINT @cmd

			INSERT INTO @AllDBTable
				EXEC(@cmd);

			FETCH NEXT FROM db_cur
				INTO 
					@dbname, @CompatibilityLevel;

		END


	CLOSE db_cur;

	DEALLOCATE db_cur;


	IF @DbRolestoShow = 'A'
		BEGIN
			SELECT DBNam, DBUserName, TypeDesc, DefSchema, AuthenticationTypeDesc, DbRoleName, Perms + ' ' + ObjectName AS Perms, CreateDate,ModifyDate, IsDisabled
				FROM @AllDBTable
			WHERE DbRoleName NOT IN ('db_datareader', 'db_datawriter', 'db_accessadmin','db_backupoperator','db_ddladmin','db_denydatareader','db_denydatawriter','db_securityadmin') AND
					DBUserName NOT IN 
						(SELECT DBUserName FROM @AllDBTable WHERE IsDisabled = 1)
			ORDER BY DBNam, Purpose, DBUserName, DbRoleName ASC;

		END
	ELSE IF @DbRolestoShow = 'S'
			BEGIN
				SELECT DBNam, DBUserName, TypeDesc, DefSchema, AuthenticationTypeDesc, DbRoleName, Perms + ' ' + ObjectName AS Perms, CreateDate,ModifyDate, IsDisabled
					FROM @AllDBTable
				WHERE DbRoleName IN ('db_datareader', 'db_datawriter', 'db_accessadmin','db_backupoperator','db_ddladmin','db_denydatareader','db_denydatawriter','db_securityadmin') AND
						DBUserName NOT IN 
							(SELECT DBUserName FROM @AllDBTable WHERE IsDisabled = 1)
				ORDER BY DBNam, Purpose, DBUserName, DbRoleName ASC;

			END
	ELSE
		BEGIN
			SELECT DBNam, DBUserName, TypeDesc, DefSchema, AuthenticationTypeDesc, DbRoleName, Perms + ' ' + ObjectName AS Perms, CreateDate,ModifyDate, IsDisabled
				FROM @AllDBTable
			WHERE DBUserName NOT IN 
				(SELECT DBUserName FROM @AllDBTable WHERE IsDisabled = 1)
			ORDER BY DBNam, Purpose, DBUserName, DbRoleName ASC;

		END

	------------SELECT DBNam, DBUserName, TypeDesc, DefSchema, AuthenticationTypeDesc, DbRoleName, Perms + ' ' + ObjectName AS Perms, CreateDate,ModifyDate, IsDisabled
	------------	FROM @AllDBTable
	------------WHERE DBUserName NOT IN 
	------------	(SELECT DBUserName FROM @AllDBTable WHERE IsDisabled = 1)

	--WHERE DBUserName = 'PIEDMONT\PremKaX'
	------------ORDER BY DBNam, Purpose, DBUserName, DbRoleName ASC;
	--ORDER BY Purpose, DBNam, DBUserName, DbRoleName ASC;

END
GO
