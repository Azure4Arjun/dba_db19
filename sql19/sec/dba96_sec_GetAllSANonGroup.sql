SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba96_sec_GetAllSANonGroup
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 11/15/2016   Aron E. Tekulsky    Initial Coding.
-- 02/05/2018   Aron E. Tekulsky    Update to Version 140.
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
	WHERE p.type IN ('S','U','C') AND
		p.name NOT LIKE ('##%') AND
		l.sysadmin = 1 AND 
		p.is_disabled = 0 AND
	--	p.name NOT IN ('NT SERVICE\SQLWriter','NT SERVICE\MSSQLSERVER','NT SERVICE\SQLSERVERAGENT','NT AUTHORITY\SYSTEM','NT SERVICE\Winmgmt') AND
	--	p.name NOT IN ('NT SERVICE\ClusSvc', 'NT SERVICE\MSSQLServerOLAPService','NT SERVICE\ReportServer','NT SERVICE\MSSQL$CONSQLDEVF') AND
		p.name NOT IN ('NT SERVICE\SQLAgent$CONSQLDEVF','PIEDMONT\BI-ETL-DEV01$','PIEDMONT\BI-ETL-SIT01$','PIEDMONT\BI-ETL-UAT01$') AND
	--	p.name NOT IN ('NT AUTHORITY\LOCAL SERVICE','NT AUTHORITY\NETWORK SERVICE','NT SERVICE\MSSQL$CONSQLDEVJ','NT SERVICE\SQLAgent$CONSQLDEVJ') AND
	--	p.name NOT IN ('NT SERVICE\MSSQL$CONSQLUATJ','NT SERVICE\SQLAgent$CONSQLUATJ','NT SERVICE\MSSQL$CONSQLUATF','NT SERVICE\SQLAgent$CONSQLUATF') AND
	--	p.name NOT IN ('NT SERVICE\MSSQL$CONSQLPRDF','NT SERVICE\SQLAgent$CONSQLPRDF','NT SERVICE\MSSQL$SIT','NT SERVICE\SQLAgent$SIT') AND
	--	p.name NOT IN ('NT SERVICE\MSSQL$CONSQLSITJ', 'NT SERVICE\SQLAgent$CONSQLSITJ') AND
		p.name NOT LIKE ('NT SERVICE\%') AND
		p.name NOT LIKE ('NT AUTHORITY\%')
	--	p.name NOT IN ('NT SERVICE\SQLWriter','NT SERVICE\MSSQLSERVER','NT SERVICE\SQLSERVERAGENT','sa','NT AUTHORITY\SYSTEM')
	ORDER BY name ASC;


END
GO
