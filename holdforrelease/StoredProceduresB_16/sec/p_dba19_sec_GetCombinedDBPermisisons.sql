USE [DBA_DB16]
GO

/****** Object:  StoredProcedure [dbo].[p_dba19_sec_GetCombinedDBPermisisons]    Script Date: 2/19/2018 6:23:27 PM ******/
DROP PROCEDURE [dbo].[p_dba19_sec_GetCombinedDBPermisisons]
GO

/****** Object:  StoredProcedure [dbo].[p_dba19_sec_GetCombinedDBPermisisons]    Script Date: 2/19/2018 6:23:27 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ======================================================================================
-- p_dba19_sec_GetCombinedDBPermisisons
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	
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
CREATE PROCEDURE [dbo].[p_dba19_sec_GetCombinedDBPermisisons] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @cmd						nvarchar(4000)
	DECLARE @CompatibilityLevel			tinyint
	DECLARE @dbname						nvarchar(128)

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
			ModifyDate					datetime
							)

	/*
	------------MemberName			nvarchar(128),  -- DBUserName
	------------RoleName			nvarchar(128),	-- DbRoleName
	------------ServerPermission	nvarchar(200),	-- Perms
	------------default_database_name	nvarchar(128),	-- DBNam
	------------ProxyNames				nvarchar(128),  -- ObjectName
	create_date			datetime,
	modify_date			datetime
	*/

	-- Server Permissions

	SET @cmd = 'SELECT ' +  '''' + 'A' + '''' + 
					',mb.default_database_name AS DBNam
					, mb.name AS MemberName 
					, '  + '''' + 'ServerPermission' + '''' + ' AS TypeDesc' +
					', ' + '''' + 'dbo' + '''' + ' AS DefSchema' +
					', ' + '''' + '''' + ' AS AuthenticationTypeDesc' + 
					',ISNULL(rl.name,' + '''' + '''' + ') AS DbRoleName
					,s.state_desc + ' + '''' +  + ' ' + '''' + ' + s.permission_name AS Perms
					,ISNULL(cr.name,' + '''' + '''' + ') AS ObjectName
					,mb.create_date AS CreateDate
					,mb.modify_date AS ModifyDate
				FROM sys.server_principals AS mb
					LEFT JOIN sys.server_role_members  rm ON (rm.member_principal_id = mb.principal_id )
					LEFT JOIN sys.server_principals AS rl  ON (rm.role_principal_id = rl.principal_id  )
					JOIN sys.server_permissions AS s  ON (s.grantee_principal_id = mb.principal_id)
					LEFT JOIN sys.credentials cr ON (cr.credential_identity = mb.name)
			 WHERE  mb.[type] IN (' + '''' + 'S' + '''' + ',' + '''' + 'U' + '''' + ',' + '''' + 'G' + '''' + ') AND
					mb.is_disabled = 0 AND
					mb.name NOT LIKE (' + '''' + 'NT SERVICE\%' + '''' + ')
					AND mb.name NOT LIKE (' + '''' + 'NT AUTHORITY\%' + '''' + ')
					AND mb.name NOT LIKE (' + '''' + '##%##' + '''' + ')		
			 ORDER BY mb.name ASC, rl.principal_id DESC';

	PRINT @cmd;

	INSERT INTO @AllDBTable
		EXEC (@cmd);


	-- setup to get the dbnames
	DECLARE db_cur CURSOR FOR
		SELECT Name, compatibility_level --,state_desc Status
			FROM sys.databases
		WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb','SSISDB', 'ADVENTUREWORKS2014')
			AND state_desc = 'ONLINE'
			AND is_read_only <> 1 --means database=in read only mode
			AND CHARINDEX('-',name) = 0 -- no dashes in dbname
		order by name asc;


	OPEN db_cur;

	FETCH NEXT FROM db_cur
		INTO 
			@dbname, @CompatibilityLevel;

	WHILE(@@FETCH_STATUS <> -1)
		BEGIN

		-- DB Permissions

			SET @cmd = 'USE [' + @dbname + '] ; ' +
					'	SELECT ' + '''' + 'B' + '''' + ', DB_NAME() AS DBName
						  ,pr.[name] AS DBUserName
						  ,pr.[type_desc]
						  ,ISNULL(pr.[default_schema_name],' + '''' + '''' + ') AS DefSchema'  ;


			IF @CompatibilityLevel >= 110
				BEGIN

					SET @cmd = @cmd + 
						  ',pr.[authentication_type_desc]' ;
				END
			ELSE
				BEGIN
					SET @cmd = @cmd + 
						  ', ' + '''' +  '''' +  ' AS authentication_type_desc';
				END
					
			SET @cmd = @cmd	 + ',r.name AS DbRoleName
						  ,ISNULL(pe.[state_desc] + ' + '''' +  ' ' + '''' +  ' +  pe.permission_name + ' + '''' + ' ON ' + '''' + ',' + '''' + '''' + 
						  ') AS Permissions  
						  ,ISNULL(s.name + ' + '''' + '.' + '''' + ' + o.name,' + '''' + '''' + ') AS ObjectName
						  , NULL AS CreateDate, NULL AS ModifyDate
						FROM [sys].[database_principals] pr
							JOIN sys.database_role_members m ON (m.member_principal_id = pr.principal_id )
							JOIN [sys].[database_principals] r ON (r.principal_id = m.role_principal_id)
							LEFT JOIN sys.database_permissions AS pe  ON (pe.grantee_principal_id = r.principal_id)  
							LEFT JOIN sys.objects AS o  ON (pe.major_id = o.object_id)
							LEFT JOIN sys.schemas AS s  ON (o.schema_id = s.schema_id)
					WHERE pr.[type] IN (' + '''' + 'U' + '''' + ',' + '''' + 'S' + '''' + ',' + '''' + 'G' + '''' + ') AND
							pr.[name] NOT LIKE (' + '''' + 'NT AUTHORITY\%' + '''' + ')
					ORDER BY pr.[name] ASC, r.principal_id DESC';
				

			PRINT @cmd;

			INSERT INTO @AllDBTable
				EXEC(@cmd);

			FETCH NEXT FROM db_cur
				INTO 
					@dbname, @CompatibilityLevel;

		END

	IF @@ERROR <> 0 GOTO ErrorHandler

	CLOSE db_cur;

	DEALLOCATE db_cur;

	--SELECT DBNam, DBUserName, TypeDesc, DefSchema, AuthenticationTypeDesc, DbRoleName, Perms, ObjectName
	SELECT DBNam, DBUserName, TypeDesc, DefSchema, AuthenticationTypeDesc, DbRoleName, Perms + ' ' + ObjectName AS Perms, CreateDate,ModifyDate
		FROM @AllDBTable
	ORDER BY Purpose, DBNam, DBUserName, DbRoleName ASC;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO

GRANT EXECUTE ON [dbo].[p_dba19_sec_GetCombinedDBPermisisons] TO [db_proc_exec] AS [dbo]
GO


