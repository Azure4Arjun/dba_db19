SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sev_2011ListLoginsWithSystemLevelPermissions
--
--
-- Calls:		None
--
-- Description:	2011 - List logins and system level permissions.
--
-- From Edward Roepe - Perimeter DBA, LLC.  - www.perimeterdba.com
-- 
-- Date			Modified By			Changes
-- 09/08/2018   Aron E. Tekulsky    Initial Coding.
-- 06/10/2019   Aron E. Tekulsky    Update to Version 140.
-- 08/14/2020   Aron E. Tekulsky    Update to Version 150.
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

-- 2011 - List logins and system level permissions
-- Ed Roepe - 03-10-2014

	SELECT SERVERPROPERTY('ServerName') AS 'InstanceName', 
			a.name AS 'ServerLogin', 
			a.createdate AS 'CreateDate', 
			a.updatedate AS 'UpdateDate', 
			a.dbname AS 'DefaultDatabase', 
			a.language AS 'Language', 
			a.denylogin AS 'DenyLogin', 
			a.hasaccess AS 'HasAcces', 
			a.isntname AS 'WindowsLogin', 
			a.isntgroup AS 'WindowsGroup', 
			a.isntuser AS 'WindowsUser', 
			a.sysadmin AS 'SysAdminRole', 
			a.securityadmin AS 'SecurityAdminRole', 
			a.serveradmin AS 'ServerAdminRole', 
			a.setupadmin AS 'SetupAdminRole', 
			a.processadmin AS 'ProcessAdminRole', 
			a.diskadmin AS 'DiskAdminRole', 
			a.dbcreator AS 'DBCreatorRole', 
			a.bulkadmin AS 'BulkAdminRole'
		FROM master.dbo.syslogins AS a
	WHERE a.hasaccess = 1
			AND a.name NOT LIKE '##%'
			AND (a.sysadmin = 1
			OR a.securityadmin = 1
			OR a.serveradmin = 1
			OR a.setupadmin = 1
			OR a.processadmin = 1
	        OR a.diskadmin = 1
			OR a.dbcreator = 1
			OR a.bulkadmin = 1)
	ORDER BY a.name;
END
GO
