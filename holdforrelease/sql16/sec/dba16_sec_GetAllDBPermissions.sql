SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sec_GetAllDBPermissions
--
--
-- Calls:		None
--
-- Description:	Get all Databse permissions for each DB user including proxies.
-- 
-- Date			Modified By			Changes
-- 11/05/2016   Aron E. Tekulsky    Initial Coding.
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

	SELECT DB_NAME() AS DBName
		  ,pr.[name] AS DBUserName
		 --,pr.[principal_id]
		 --,pr.[type]
		  ,pr.[type_desc]
		  ,ISNULL(pr.[default_schema_name],'') AS DefSchema
		 --,pr.[create_date]
		  --,pr.[modify_date]
		 --,pr.[owning_principal_id]
		  --,pr.[sid]
		  --,pr.[is_fixed_role]
		  --,pr.[authentication_type]
		 ,pr.[authentication_type_desc]
		 --,pr.[default_language_name]
		 --,pr.[default_language_lcid]
		,r.name AS DbRoleName
		  --,pe.[state] AS PermState
		  --,pe.[state_desc] AS PermDesc 
		  --,pe.permission_name AS PermissionName
		  ,ISNULL(pe.[state_desc] + ' ' +  pe.permission_name + ' ON ','') AS Permissions --+ s.name + '.' + o.name 
		  ,ISNULL(s.name + '.' + o.name,'') AS ObjectName
	FROM [sys].[database_principals] pr
			JOIN sys.database_role_members m ON (m.member_principal_id = pr.principal_id )
			JOIN [sys].[database_principals] r ON (r.principal_id = m.role_principal_id)
			LEFT JOIN sys.database_permissions AS pe  ON (pe.grantee_principal_id = r.principal_id)  
			LEFT JOIN sys.objects AS o  ON (pe.major_id = o.object_id)
			LEFT JOIN sys.schemas AS s  ON (o.schema_id = s.schema_id)
	ORDER BY pr.[name] ASC, r.principal_id DESC

END
GO
