SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sec_GetLoginsWithDates
--
--
-- Calls:		None
--
-- Description:	Get a listing of logins with all dates.
-- 
-- Date			Modified By			Changes
-- 10/26/2010   Aron E. Tekulsky    Initial Coding.
-- 11/07/2017   Aron E. Tekulsky    Update to Version 140.
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

	SELECT s.loginname, createdate, updatedate, accdate,
			CASE sysadmin
				WHEN 1 THEN 'SysAdmin'
			ELSE ''
			END AS SysAdmin, 
			CASE securityadmin
				WHEN 1 THEN 'SecurityAdmin'
			ELSE ''
			END AS SecurityAdmin,
			CASE serveradmin
				WHEN 1 THEN 'ServerAdmin'
			ELSE ''
			END AS ServerAdmin,
			CASE setupadmin
				WHEN 1 THEN 'SetupAdmin'
			ELSE ''
			END AS SetupAdmin,
			CASE processadmin
				WHEN 1 THEN 'ProcessAdmin'
			ELSE ''
			END AS ProcessAdmin,
			CASE diskadmin
				WHEN 1 THEN 'DiskAdmin'
			ELSE ''
			END AS DiskAdmin,
			CASE dbcreator
				WHEN 1 THEN 'DBCreator'
			ELSE ''
			END AS DBCreator,
			CASE bulkadmin
				WHEN 1 THEN 'BulkAdmin'
			ELSE ''
			END AS BulkAdmin
		FROM sys.syslogins s
	WHERE status = 9
	ORDER BY s.loginname ;


--select *
--from syslogins

END
GO
