SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba16_met_GetCompleteSystemDBSpecs
--
-- Arguments:	None
--				None
--
-- CallS:		p_dba16_sec_GetLoginsWServerRoles
--				p_dba16_sec_GetAllUsersByDB
--				p_dba16_sec_GetDBUserDBRolesByDB
--				p_dba16_sec_GetDBUserSecurablesByD
--
-- Called BY:	None
--
-- Description:	Get the complete information about a database including device 
--				space and rowcounts for system db's.
-- 
-- Date			Modified By			Changes
-- 01/16/2013   Aron E. Tekulsky    Initial Coding.
-- 03/22/2018   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba16_met_GetCompleteSystemDBSpecs 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE	@cmd					nvarchar(4000),
			@cmd2					nvarchar(4000),
			@cmd3					nvarchar(4000),
			@dbname					nvarchar(128),
			@database_id			int,
			@compatibility_level	tinyint

-- create the master table
	DECLARE @database_master TABLE (
		name						nvarchar(128),
		database_id					int,
		create_date					datetime,
		compatibility_level			tinyint,
		collation_name				nvarchar(128),
		state_desc					nvarchar(60),
		is_in_standby				bit,
		recovery_model_desc			nvarchar(60),
		page_verify_option_desc		nvarchar(60),
		dbowner						nvarchar(128))
	
-- create database files table
	DECLARE @database_devices TABLE (
		name						nvarchar(128),
		type						tinyint,
		type_desc					nvarchar(60),
		physical_name				nvarchar(260),
		state						tinyint,
		state_desc					nvarchar(60),
		size						int,
		spaceused					int,
		freespace					int)
	
-- create indexes table
	DECLARE @database_indexes TABLE (
		dbname						nvarchar(128),
		obj_name					nvarchar(128),
		type_desc					nvarchar(60),
		is_primary_key				bit,
		index_id					int,
		--id					int,
		--indid				smallint,
		--keycnt				smallint,
		rowcnt						bigint,
		name						nvarchar(128),
		rows						int,
		rowlength					int,
		rowmax						int)

-- create linked serve specs
	DECLARE @linked_servers TABLE (
		server_id					int,
		name						nvarchar(128),
		catalog						nvarchar(128),
		provider					nvarchar(128),
		data_source					nvarchar(4000),
		is_data_access_enabled		bit,
		is_remote_login_enabled		bit,
		is_rpc_out_enabled			bit,
		local_principal_id			int,
		remote_name					nvarchar(128),
		uses_self_credential		bit)
			

-- first we get the basic database information - non system db only

	INSERT INTO @database_master
		SELECT d.name, d.database_id, d.create_date, d.compatibility_level, d.collation_name, --d.owner_sid,
			d.state_desc, d.is_in_standby, d.recovery_model_desc, d.page_verify_option_desc,
			l.name
		FROM sys.databases d
			JOIN sys.syslogins l ON (d.owner_sid = l.sid)
		WHERE database_id <= 4  AND
			state = 0;
		

		SELECT *
		FROM @database_master
		ORDER BY name ASC;
	

	DECLARE db_cur CURSOR FOR
		SELECT name, database_id, compatibility_level
			FROM @database_master;
		
	OPEN db_cur;

	FETCH NEXT FROM db_cur
		INTO @dbname, @database_id, @compatibility_level;
	
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
			SET @cmd =  
			'SELECT f.name,f.type, f.type_desc, f.physical_name, f.state, f.state_desc, f.size*8/1024 as size, 
				 fileproperty(name, ''SpaceUsed'')*8/1024 as SpaceUsed,
			CAST(f.size/128.0 - CAST(FILEPROPERTY(f.name, ''SpaceUsed'') AS int)/128.0 AS int) AS FreeSpaceMB
				FROM [' + @dbname + '].sys.database_files f;'
			
				PRINT @cmd
			
			INSERT INTO  @database_devices
				EXEC (@cmd);
			
			-- get index information
			--SET @cmd2 = 'SELECT ' + '''' +  @dbname + '''' + 'AS dbname,object_name(id) AS tname ,rowcnt, name, rows,0,0 
			--	FROM [' + @dbname + '].sys.sysindexes 
			--WHERE indid IN (1,0) AND OBJECTPROPERTY(id,' +  '''' + 'IsUserTable' +'''' + ') = 1 ' --+ 
			
			IF @compatibility_level < 100
				BEGIN
					SET @cmd2 = 'SELECT ' + '''' +  @dbname + '''' + 'AS dbname,OBJECT_NAME(i.object_id) '  + '  AS tname,
									i.type_desc, i.is_primary_key, i.index_id,
									s.rowcnt, i.name, s.rows,0,0 
						FROM [' + @dbname + '].sys.indexes i
								JOIN sys.sysindexes s ON (i.object_id = s.id)
					WHERE s.indid IN (1,0) AND OBJECTPROPERTY(s.id,' +  '''' + 'IsUserTable' +'''' + ') = 1 ' --+ 
				END
				
			ELSE
				BEGIN
					SET @cmd2 = 'SELECT ' + '''' +  @dbname + '''' + 'AS dbname,OBJECT_NAME(i.object_id, ' + convert(varchar(4),@database_id)  + '  ) AS tname,
											i.type_desc, i.is_primary_key, i.index_id,
											s.rowcnt, i.name, s.rows,0,0 
						FROM [' + @dbname + '].sys.indexes i
									JOIN sys.sysindexes s ON (i.object_id = s.id)
					WHERE s.indid IN (1,0) AND OBJECTPROPERTY(s.id,' +  '''' + 'IsUserTable' +'''' + ') = 1 ' --+ 
				END
				
			PRINT @cmd2
				
			INSERT INTO @database_indexes
				EXEC (@cmd2);

				
			-- update the row lengths	
			UPDATE @database_indexes
				SET rowlength = (SELECT TOP 100 PERCENT SUM(b.length) AS rowlength
									FROM sys.sysobjects a INNER JOIN
											sys.syscolumns b ON a.id = b.id
									WHERE     (a.xtype = 'U') AND
									obj_name = a.name
								GROUP BY a.name
								ORDER BY a.name);
	
	-- update the max row length
			UPDATE @database_indexes
				SET rowmax = (SELECT TOP 100 PERCENT 8060 - SUM(b.length) AS max8060
									FROM sys.sysobjects a INNER JOIN
											sys.syscolumns b ON a.id = b.id
									WHERE     (a.xtype = 'U') AND
									obj_name = a.name
								GROUP BY a.name
								ORDER BY a.name);
								



			FETCH NEXT FROM db_cur
				INTO @dbname, @database_id, @compatibility_level;
		END
	--f.max_size, f.growth, f.is_percent_growth,
	CLOSE db_cur;
	DEALLOCATE db_cur;
	

	-- linked servers
	SET @cmd3 = 'SELECT s.server_id, s.name, s.catalog, s.provider, s.data_source, 
						s.is_data_access_enabled, s.is_remote_login_enabled, s.is_rpc_out_enabled,
						l.local_principal_id, l.remote_name, l.uses_self_credential
					FROM sys.servers s
						LEFT JOIN sys.linked_logins l ON (l.server_id = s.server_id)
				WHERE s.server_id > 0'
	
	
	INSERT @linked_servers 
		EXEC (@cmd3);

	PRINT '*** DBs ***'
	
	PRINT '*** DB Devices ***'

		
	SELECT *
		FROM @database_devices
		ORDER BY name ASC;

	 PRINT '*** DB Indexes ***'
	

	SELECT *
		FROM @database_indexes
		ORDER BY dbname ASC,
				obj_name ASC;

		PRINT '*** Linked Servers ***';
		
	
	SELECT *
		FROM @linked_servers;
		
	PRINT '*** DB SSIS Packages ***';

	-- get all packages on the serve in the SSIS server
	IF (@@version LIKE ('%SQL Server 2005%'))
		BEGIN
			SELECT f.foldername, p.name, p.description, p.createdate, l.loginname, p.packagetype, p.vermajor, p.verminor, p.verbuild
				FROM msdb.dbo.sysdtspackagefolders90 f
					JOIN msdb.dbo.sysdtspackages90 p ON (p.folderid = f.folderid)
					JOIN sys.syslogins l ON (p.ownersid = l.sid)
			ORDER BY f.foldername ASC, p.name ASC;
		END
	ELSE
		BEGIN
			SELECT f.foldername, p.name, p.description, p.createdate, l.loginname, p.packagetype, p.vermajor, p.verminor, p.verbuild
				FROM msdb.dbo.sysssispackagefolders f
					JOIN msdb.dbo.sysssispackages p ON (p.folderid = f.folderid)
					JOIN sys.syslogins l ON (p.ownersid = l.sid)
			ORDER BY f.foldername ASC, p.name ASC;
		END
		;
		PRINT '*** Server Logins with Roles ***'

	-- get server logins
	EXEC [dbo].[p_dba16_sec_GetLoginsWServerRoles];
		
		PRINT '*** DB Users ***';

	-- get all users of the database
	EXEC [dbo].[p_dba16_sec_GetAllUsersByDB];
			
			PRINT '*** DB User Roles ***';

	--Get all roles for each user in each db
	EXEC [dbo].[p_dba16_sec_GetDBUserDBRolesByDB];
			
			PRINT '*** DB Securables ***';

	-- get all securabels for each user in each db
	EXEC [dbo].[p_dba16_sec_GetDBUserSecurablesByDB];

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba16_met_GetCompleteSystemDBSpecs TO [db_proc_exec] AS [dbo]
GO
