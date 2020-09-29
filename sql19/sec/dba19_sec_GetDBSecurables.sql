SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sec_GetDBSecurables
--
--
-- Calls:		None
--
-- Description:	Get a listing of the securables.
-- 
-- Date			Modified By			Changes
-- 10/25/2016   Aron E. Tekulsky    Initial Coding.
-- 11/22/2017   Aron E. Tekulsky    Update to Version 140.
-- 08/25/2020   Aron E. Tekulsky    Update to Version 150.
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

-- dba14_getdbsecurables

--SELECT  p.principal_id,p.type_desc, p.default_schema_name, p.create_date, p.modify_date,
	SELECT  ISNULL(l.name,'Orphan') AS ServerLogin  ,
			CASE l.is_disabled
				WHEN 1 THEN 'Disabled'
				WHEN 0 THEN 'Enabled'
				ELSE ''
			END AS IsDisabled
			,p.name as UserName, --p.principal_id, 
			 p.default_schema_name,
			m.class_desc, m.state_desc, m.permission_name,o.type_desc,DB_NAME() as dbname,s.name AS SchemaName, o.name AS ObjectName --, ' TO ', p.name
			, p.create_date, p.modify_date
		--, p.sid 
		FROM sys.database_principals p -- old sysusers
			LEFT JOIN sys.database_permissions m ON (m.grantee_principal_id = p.principal_id)
			LEFT JOIN [sys].[objects] o ON (o.object_id = m.major_id )
			LEFT JOIN [sys].[schemas] s ON (s.schema_id = o.schema_id )
			LEFT JOIN sys.server_principals l ON (l.sid = p.sid ) -- old syslogins
	WHERE p.type in ('U','S') AND
		(p.principal_id = 1 OR p.principal_id > 4)-- AND
			--(l.is_disabled = 0)
	ORDER BY p.type_desc DESC, p.name ASC;

END
GO
