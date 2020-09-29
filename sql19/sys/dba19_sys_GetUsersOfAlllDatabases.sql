SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sys_GetUsersOfAlllDatabases
--
--
-- Calls:		None
--
-- Description:	Get alisting of all user ids in all db.
-- 
-- Date			Modified By			Changes
-- 10/25/2016   Aron E. Tekulsky    Initial Coding.
-- 11/05/2017   Aron E. Tekulsky    Update to Version 140.
-- 08/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
--
--  This code and information are provided "AS IS" without warranty of
--  any kind, either expressed or implied, including but not limited
--  to the implied warranties of merchantability and/or fitness for a
--  particular purpose.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @cmd			nvarchar(4000),
			@dbid			int,
			@dbinstandby	bit,
			@dbname			nvarchar(128),
			@dbosid			varbinary(85),
			@dbstate		tinyint,
			@dbstatedesc	nvarchar(60),
			@lname			nvarchar(128),
			@lsid			varbinary(85),
			@ldefaultdb		nvarchar(128),		
			@return_status	int--,
		--@uname			nvarchar(128), 
		--@rolenam		nvarchar(128)

	CREATE TABLE #temp_userroles
		(uname				nvarchar(128)	null,
		rolenam				nvarchar(128)	null,
		dbnam				nvarchar(128)	null,
		usid				varbinary(85)	null,
		lsid				varbinary(85)	null,
		lname				nvarchar(128)	null)
 
-- get enabled logins --
--l.is_disabled,

	DECLARE login_cur CURSOR FOR
		SELECT l.name, l.sid,  l.default_database_name
		--FROM sys.sql_logins l
			FROM sys.server_principals l
		WHERE l.is_disabled = 0
			AND TYPE IN ('U','S');

	OPEN login_cur;

	FETCH NEXT FROM login_cur
		INTO @lname, @lsid, @ldefaultdb;

	WHILE (@@fetch_status = 0)
		BEGIN
--get databases --

			DECLARE db_cur CURSOR FOR
				SELECT d.name, d.database_id, d.owner_sid, d.state, d.state_desc,
					d.is_in_standby
					FROM master.sys.databases d
				WHERE d.state = 0 AND
						d.is_in_standby = 0 AND
						d.database_id not in (2,3);
				
			OPEN db_cur;

			FETCH NEXT FROM db_cur
				INTO @dbname, @dbid, @dbosid, @dbstate, @dbstatedesc, @dbinstandby;
	
			WHILE (@@fetch_status <> -1)
				BEGIN
			-- get the user's roles
				--SET @cmd = 'SELECT  u.name, g.name,u.sid
				--FROM ' + @dbname + '.sys.database_role_members m
				--	JOIN ' + @dbname + '.sys.database_principals u ON (u.principal_id = m.member_principal_id)
				--	JOIN ' + @dbname + '.sys.database_principals g ON (g.principal_id = m.role_principal_id)			 
				--WHERE u.name = ' + '''' + @lname + '''' + ';'
				
				--SET @cmd = '
				--INSERT INTO #temp_userroles
				--	(uname,
				--	 rolenam,
				--	 dbnam,
				--	 usid)
				--SELECT  u.name as usrnam, g.name as usrrole, ' + '''' + @dbname + '''' + ', u.sid,' +
				--		   @lsid  + ',' + 
				--		'''' + @lname + '''' + '
				--FROM ' + @dbname + '.sys.database_role_members m
				--	JOIN ' + @dbname + '.sys.database_principals u ON (u.principal_id = m.member_principal_id)
				--	JOIN ' + @dbname + '.sys.database_principals g ON (g.principal_id = m.role_principal_id)			 
				--WHERE u.name = ' + '''' + @lname + '''' + ';'
				
					SET @cmd = '
					INSERT INTO #temp_userroles
						(uname,
						 rolenam,
						 dbnam,
						 usid,
						 lname)
					SELECT  u.name as usrnam, g.name as usrrole, ' + '''' + @dbname + '''' + ', u.sid,' +
							'''' + @lname + '''' + '
						FROM [' + @dbname + '].sys.database_role_members m
							JOIN [' + @dbname + '].sys.database_principals u ON (u.principal_id = m.member_principal_id)
							JOIN [' + @dbname + '].sys.database_principals g ON (g.principal_id = m.role_principal_id)			 
					WHERE u.name = ' + '''' + @lname + '''' + ';'
				
					PRINT @cmd
				
					EXEC (@cmd)
				
				-- update with lsid
					UPDATE #temp_userroles
						SET lsid = @lsid
						WHERE dbnam = @dbname AND
							lname = @lname
				
				--ORDER BY 1, 2
			-- end get users roles
				
					FETCH NEXT FROM db_cur
						INTO @dbname, @dbid, @dbosid, @dbstate, @dbstatedesc, @dbinstandby;
				END

			CLOSE db_cur;
			DEALLOCATE db_cur;

-- end get database
			FETCH NEXT FROM login_cur
				INTO @lname, @lsid, @ldefaultdb;
		END

	CLOSE login_cur;
	DEALLOCATE login_cur;

	SELECT uname, rolenam, dbnam, --usid,lsid,
		lname
		FROM #temp_userroles
	ORDER BY dbnam, uname ASC

	DROP TABLE #temp_userroles

-- 



--SELECT u.name, u.status, u.sid, u.uid
--FROM master.sys.sysusers u

-- get protections --

--SELECT u.name, u.status, u.sid, u.uid, 
--		p.id, p.uid, p.action, p.protecttype, p.columns, p.grantor
--FROM dba_db.sys.sysusers u
--	JOIN dba_db.sys.sysprotects p ON (p.uid = u.uid)
	

--SELECT p.name, p.principal_id, p.type, p.type_desc, p.sid,
--	m.class, m.class_desc, m.major_id, m.minor_id, m.grantee_principal_id, m.grantor_principal_id,
--		m.type, m.permission_name, m.state, m.state_desc
--FROM sys.database_principals p
--	JOIN sys.database_permissions m ON (m.grantee_principal_id = p.sid)
--WHERE p.type = 'S'
--
---- testing *************
--select *
--from test.sys.database_permissions
--where type in ('DL','IN','UP','SL')
--and grantee_principal_id = 6


--SELECT *
--FROM test.sys.database_principals
--
--SELECt *
--FROM sys.database_role_members


--SELECT p.*, 
--	m.*
--FROM test.sys.database_principals p
--	JOIN test.sys.database_role_members m on (m.member_principal_id = p.principal_id)
--WHERE p.name = 'ssis_replication'


--SELECT *
--FROM sys.database_principal_aliases

--select * 
--FROM sys.server_permissions

-- get role members --

--		SELECT DbRole = g.name, MemberName = u.name, MemberSID = u.sid
--			FROM sys.database_principals u,
--				 sys.database_principals g,
--				 sys.database_role_members m
--			WHERE g.principal_id = m.role_principal_id and
--				  u.principal_id = m.member_principal_id
--			ORDER BY 1, 2

END
GO
