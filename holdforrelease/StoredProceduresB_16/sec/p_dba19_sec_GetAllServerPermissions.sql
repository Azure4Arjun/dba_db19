SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_sec_GetAllServerPermissions
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	p_dba19_Exec_GetAllServerPermissions
--
-- Description:	Get all Server level permissions.
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
CREATE PROCEDURE p_dba19_sec_GetAllServerPermissions 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @cmd	nvarchar(4000)

	SET @cmd = 'SELECT mb.name AS MemberName,  
		ISNULL(rl.name,' + '''' + '''' + ') AS RoleName
		,s.state_desc + ' + '''' +  + ' ' + '''' + ' + s.permission_name AS ServerPermission
		,mb.default_database_name 
		,ISNULL(cr.name,' + '''' + '''' + ') AS ProxyNames
		,mb.create_date,mb.modify_date  ,mb.default_language_name 
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

	EXEC (@cmd);

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_sec_GetAllServerPermissions TO [db_proc_exec] AS [dbo]
GO
