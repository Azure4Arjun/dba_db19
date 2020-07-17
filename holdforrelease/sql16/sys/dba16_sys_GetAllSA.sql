SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_GetAllSA
--
--
-- Calls:		None
--
-- Description:	Get a list of all Id's with SA level privs.
-- 
-- Date			Modified By			Changes
-- 10/28/2016   Aron E. Tekulsky    Initial Coding.
-- 10/07/2017   Aron E. Tekulsky    Update to Version 140.
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

	SELECT p.name, p.principal_id, p.sid, p.type, p.type_desc, p.is_disabled, p.create_date, p.modify_date, 
			p.default_database_name, p.default_language_name, p.credential_id,
			CASE l.bulkadmin
				WHEN 1 THEN	
						'Bulkadmin'
					ELSE '' 
					END AS bulkadmin, 
			CASE l.dbcreator
				WHEN 1 THEN	
						'DBCreator'
					ELSE '' 
					END AS dbcreator, 
			CASE l.diskadmin
				WHEN 1 THEN	
						'DiskAdmin'
					ELSE '' 
					END AS diskadmin, 
			CASE l.processadmin
				WHEN 1 THEN	
						'ProcessAdmin'
					ELSE '' 
					END AS processadmin, 
			CASE l.securityadmin
				WHEN 1 THEN	
						'SecurityAdmin'
					ELSE '' 
					END AS securityadmin, 
			CASE l.serveradmin
				WHEN 1 THEN	
						'ServerAdmin'
					ELSE '' 
					END AS serveradmin, 
			CASE l.setupadmin
				WHEN 1 THEN	
						'SetupAdmin'
					ELSE '' 
					END AS setupadmin, 
			CASE l.sysadmin
				WHEN 1 THEN	
						'SysAdmin'
					ELSE '' 
					END AS sysadmin, 
				l.denylogin, l.hasaccess, l.updatedate
		FROM master.sys.server_principals p
			JOIN [master].[sys].[syslogins] l ON (p.sid = l.sid)
	  WHERE p.type IN ('S','U','C','G') AND
			p.name NOT LIKE ('##%') AND
			l.sysadmin = 1 AND 
			p.is_disabled = 0 AND
			p.name NOT IN ('NT SERVICE\SQLWriter','NT SERVICE\MSSQLSERVER','NT SERVICE\SQLSERVERAGENT','NT AUTHORITY\SYSTEM','NT SERVICE\Winmgmt') AND
			p.name NOT LIKE ('NT SERVICE\%')
	--p.name NOT IN ('NT SERVICE\SQLWriter','NT SERVICE\MSSQLSERVER','NT SERVICE\SQLSERVERAGENT','sa','NT AUTHORITY\SYSTEM')
	ORDER BY name ASC

	
	
END
GO
