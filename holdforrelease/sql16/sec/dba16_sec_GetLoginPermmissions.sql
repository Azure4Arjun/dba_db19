SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sec_GetLoginPermmissions
--
--
-- Calls:		None
--
-- Description:	Get a listing of Login permissions.
-- 
-- Date			Modified By			Changes
-- 01/30/2013   Aron E. Tekulsky    Initial Coding.
-- 10/17/2017   Aron E. Tekulsky    Update to Version 140.
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
	WHERE p.type IN ('S','U') AND
		p.name NOT LIKE ('##%');
	

END
GO
