USE [DBA_DB19]
GO

/****** Object:  StoredProcedure [dbo].[p_dba19_sec_GetLoginsWServerRoles]    Script Date: 3/22/2018 6:37:29 PM ******/
DROP PROCEDURE [dbo].[p_dba19_sec_GetLoginsWServerRoles]
GO

/****** Object:  StoredProcedure [dbo].[p_dba19_sec_GetLoginsWServerRoles]    Script Date: 3/22/2018 6:37:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ======================================================================================
-- p_dba19_sec_GetLoginsWServerRoles
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	p_dba19_met_GetCompleteSystemDBSpecs
--
-- Description:	Get a list of the logins on ther server and their server roles.
-- 
-- Date			Modified By			Changes
-- 01/30/2013   Aron E. Tekulsky    Initial Coding.
-- 03/22/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE [dbo].[p_dba19_sec_GetLoginsWServerRoles] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT '*** DBs ***', p.name, --p.principal_id, p.sid, p.type, 
			p.type_desc, p.is_disabled, p.create_date, p.modify_date, 
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
			p.name NOT LIKE ('##%')
			ORDER BY p.type ASC, p.name ASC;
	

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO

GRANT EXECUTE ON [dbo].[p_dba19_sec_GetLoginsWServerRoles] TO [db_proc_exec] AS [dbo]
GO


