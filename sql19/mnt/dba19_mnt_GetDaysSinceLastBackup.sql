SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_mnt_GetDaysSinceLastBackup
--
--
-- Calls:		None
--
-- Description:	Get the number of days since the last backup.
-- 
-- Date			Modified By			Changes
-- 05/16/2013   Aron E. Tekulsky    Initial Coding.
-- 10/07/2017   Aron E. Tekulsky    Update to Version 140.
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

	SELECT d.name as 'DBName', MAX(ISNULL(DATEDIFF(dd,ISNULL(b.backup_start_date, '01/01/1900'),GETDATE()),0)) AS 'NumDays'
		FROM master..sysdatabases d 
			LEFT JOIN msdb..backupset b ON d.name = b.database_name AND
				 b.backup_start_date = (SELECT MAX(backup_start_date)
											FROM msdb..backupset b2
										WHERE b.database_name = b2.database_name AND b2.type IN ('D','I'))
	WHERE d.name != 'tempdb' AND
		 DATABASEPROPERTYEX(d.name, 'Status') = 'ONLINE'
	GROUP BY d.name, b.type, b.backup_size
	HAVING MAX(ISNULL(DATEDIFF(dd,ISNULL(b.backup_start_date, '01/01/1900'),GETDATE()),0)) > 1
	ORDER BY NumDays ASC;

END
GO
