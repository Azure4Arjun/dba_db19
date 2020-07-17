-- ==============================================================================
--dba16_sec_GetAllDBPermissionsfordbroles
--
--
-- Calls:		None
--
-- Description:	Get all Database permissions for each DB Role.
-- 
-- Date			Modified By			Changes
-- 11/5/2016   Aron E. Tekulsky    Initial Coding.
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

-- run for each db on server

	SELECT pr.principal_id, pr.name, pr.type_desc,   
			pr.authentication_type_desc, pe.state_desc,   
			pe.permission_name, s.name + '.' + o.name AS ObjectName  
			--,u.*
			,pr.owning_principal_id
			--,pr.sid
			,pr.type
			--,pr.type_desc 
			--,l.name 
		FROM sys.database_principals AS pr  -- was sysusers
			LEFT JOIN sys.database_permissions AS pe  ON pe.grantee_principal_id = pr.principal_id  
			JOIN sys.objects AS o  ON pe.major_id = o.object_id  
			JOIN sys.schemas AS s  ON o.schema_id = s.schema_id
		--JOIN sys.syslogins l ON (l.sid = pr.sid )
		--LEFT JOIN sys.server_principals l ON (l.sid = pr.sid )
	WHERE pr.principal_id = 1 OR pr.principal_id > 4  
	ORDER BY pr.principal_id ASC

END

