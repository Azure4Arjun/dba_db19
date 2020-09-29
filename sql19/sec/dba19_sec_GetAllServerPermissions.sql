SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sec_GetAllServerPermissions
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 11/05/2016   Aron E. Tekulsky    Initial Coding.
-- 11/22/2017   Aron E. Tekulsky    Update to Version 140.
-- 08/24/2020   Aron E. Tekulsky    Update to Version 150.
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

	SELECT mb.name AS MemberName,  
		ISNULL(rl.name,'') AS RoleName
		--,rl.principal_id
		--,mb.principal_id AS mbprincipl
		--rm.member_principal_id ,rl.principal_id
		--,mb.type 
		, mb.type_desc
		--,mb.is_disabled , mb.is_fixed_role 
		,s.state_desc + ' ' + s.permission_name AS ServerPermission
		,mb.default_database_name 
		,ISNULL(cr.name,'') AS ProxyNames
		,mb.create_date,mb.modify_date  ,mb.default_language_name 
		--,mb.*
		--,rl.*
		--,s.class , s.class_desc 
		--,s.major_id 
		--,cr.credential_id 
		FROM sys.server_principals AS mb
			LEFT JOIN sys.server_role_members  rm ON (rm.member_principal_id = mb.principal_id )
			LEFT JOIN sys.server_principals AS rl  ON (rm.role_principal_id = rl.principal_id  )
			JOIN sys.server_permissions AS s  ON (s.grantee_principal_id = mb.principal_id)
			LEFT JOIN sys.credentials cr ON (cr.credential_identity = mb.name)
	 --WHERE  mb.[type] IN ('S','U','G') AND
	 WHERE  mb.[type] IN ('S','U') AND
			mb.is_disabled = 0 AND
			mb.name NOT LIKE ('NT SERVICE\%')
			AND mb.name NOT LIKE ('NT AUTHORITY\%')
			AND mb.name NOT LIKE ('##%##')		
	ORDER BY mb.name ASC, rl.principal_id DESC

END
GO
