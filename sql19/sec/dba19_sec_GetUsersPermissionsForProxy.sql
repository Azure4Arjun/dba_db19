SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sec_GetUsersPermissionsForProxy
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 05/05/2016   Aron E. Tekulsky    Initial Coding.
-- 03/04/2018   Aron E. Tekulsky    Update to Version 140.
-- 08/25/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyrightę2001 - 2025 Aron Tekulsky.  World wide rights reserved.
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

	DECLARE @cmd	nvarchar(4000)

	SET @cmd = 'SELECT m.[state_desc] + ' + ''''  + ' ' + '''' + ' + m.[permission_name], ' + '''' + ' ON ' + '''' + ' + ' +
		'(CASE m.[class_desc]
			WHEN ' + '''' + 'SCHEMA' + '''' + 'THEN ' + '''' + 
					'schema' + '''' + ' ELSE ' + '''' + 'object' + '''' + 	' END) + ' 
					+  '''' +  '::' + '''' + ' + ' + '''' + ' [' + '''' + ' + ' +  'o.name' +  ' +  ' + '''' + '] ' +  '''' + 
					'+ ' + '''' + ' TO ' + '''' + ' + ' + '''' + '[' + '''' + 
					' + ' +   'p.name ' + ' + ' + '''' +  '] '  + '''' +  
	     --+  ' FROM [dba_db08].[sys].[database_permissions] m
				 +  ' FROM [sys].[database_permissions] m
						JOIN sys.database_principals p ON (m.grantee_principal_id = p.principal_id )
						JOIN sys.sysusers u ON (u.sid  = p.sid )
						JOIN sys.objects o ON (o.object_id = m.major_id )
				WHERE p.type IN (' + '''' + 'G' + '''' + ',' + '''' + 'R' + '''' + ',' + '''' + 'S' + '''' + ',' + '''' + 'U' + '''' + ') AND
						p.name <> ' + '''' + 'public' + '''' 

	  --				,o.type  
	  --				,m.[class]
   --					,m.[major_id]
   --					,m.[minor_id]
   --					,m.[grantee_principal_id]
   --					,m.[grantor_principal_id]
      --				,m.[type]
      --				,convert(varchar(300),p.name ) as pname
      --				,m.[state]
	  --				,p.sid 
	  --				,u.name  as uname
	  --				,o.type 
 --					FROM [dba_db08].[sys].[database_permissions] m
	--					JOIN sys.database_principals p ON (m.grantee_principal_id = p.principal_id )
	--					JOIN sys.sysusers u ON (u.sid  = p.sid )
	--					JOIN sys.objects o ON (o.object_id = m.major_id )
	--					WHERE p.type IN ('G','R','S','U') AND
	--					p.name <> 'public''

	PRINT @cmd;

	EXEC(@cmd);

--	SELECT m.[state_desc] +  ' ' + m.[permission_name] ,' ON ' + (CASE m.[class_desc]
--		WHEN 'SCHEMA'THEN 'schema' ELSE 'object' END) +  '::' + '[' +  o.name  + ']' + ' TO ' + '[' + p.name + ']'
--				 FROM [dba_db08].[sys].[database_permissions] m
--			JOIN sys.database_principals p ON (m.grantee_principal_id = p.principal_id )
--			JOIN sys.sysusers u ON (u.sid  = p.sid )
--			JOIN sys.objects o ON (o.object_id = m.major_id )
--	WHERE p.type IN ('G','R','S','U') AND
--		p.name <> 'public'

END
GO
