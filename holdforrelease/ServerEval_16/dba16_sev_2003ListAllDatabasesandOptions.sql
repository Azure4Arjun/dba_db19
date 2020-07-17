SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_dev_2003ListAllDatabasesandOptions
--
--
-- Calls:		None
--
-- Description:	2003 - List configuration setting for all databases
--
-- From Edward Roepe - Perimeter DBA, LLC.  - www.perimeterdba.com
-- 
-- Date			Modified By			Changes
-- 09/08/2018   Aron E. Tekulsky    Initial Coding.
-- 06/10/2019   Aron E. Tekulsky    Update to Version 140.
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
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

-- 2003 - List configuration setting for all databases
-- 06-06-2913 - Ed Roepe - Original program
-- 09-08-2013 - Ed Roepe - Update compatibility level for SQL Server 2012
-- 10-03-2013 - Ed Roepe - Added Snapshot Isolation Level field
-- 03-31-2018 - Ed Roepe - Update compatibility level for SQL Server 2016

	SELECT SERVERPROPERTY('ServerName') AS 'InstanceName', 
			SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS 'ComputerName', 
			a.name AS 'DatabaseName', 
			a.database_id AS 'DatabaseId', 
			SUSER_SNAME(a.owner_sid) AS 'DatabaseOwner', 
			b.DataSize AS 'DataSize(MB)', 
			c.LogSize AS 'LogSize(MB)', 
			b.DataSize + c.LogSize AS 'TotalSize(MB)',
			CASE recovery_model
				WHEN 1
				THEN 'Full'
				WHEN 2
				THEN 'Bulk_Logged'
				WHEN 3
				THEN 'Simple'
				ELSE 'Error'
			END AS 'Recovery_Model',
			CASE state
				WHEN 0
				THEN 'Online'
				WHEN 1
				THEN 'Restoring'
				WHEN 2
				THEN 'Recovering'
				WHEN 3
				THEN 'Recovery_Pending'
				WHEN 4
				THEN 'Suspect'
				WHEN 5
				THEN 'Emergency'
				WHEN 6
				THEN 'Offline'
				ELSE 'Error'
			END AS 'State',
			CASE is_read_only
				WHEN 1
				THEN 'Read_Only'
				WHEN 0
				THEN 'Read_Write'
				ELSE 'Error'
			END AS 'Is_Read_Only',
			CASE is_auto_shrink_on
				WHEN 1
				THEN 'On'
				WHEN 0
				THEN 'Off'
				ELSE 'Error'
			END AS 'Is_Auto_Shrink_On',
			CASE is_auto_create_stats_on
				WHEN 1
				THEN 'On'
				WHEN 0
				THEN 'Off'
				ELSE 'Error'
			END AS 'Is_Auto_Create_Stats_On',
			CASE is_auto_update_stats_on
				WHEN 1
				THEN 'On'
				WHEN 0
				THEN 'Off'
				ELSE 'Error'
			END AS 'Is_Auto_Update_Stats_On',
			CASE is_auto_update_stats_async_on
				WHEN 1
				THEN	'On'
				WHEN 0
				THEN 'Off'
				ELSE 'Error'
			END AS 'Is_Auto_Update_Stats_Async_On',
			CASE is_auto_close_on
				WHEN 1
				THEN 'On'
				WHEN 0
				THEN 'Off'
				ELSE 'Error'
			END AS 'Is_Auto_Close_On',
			CASE compatibility_level
				WHEN 70
				THEN '70'
				WHEN 80
				THEN '80'
				WHEN 90
				THEN '90'
				WHEN 100
				THEN '100'
				WHEN 110
				THEN '110'
				WHEN 120
				THEN '120'
				WHEN 130
				THEN '130'
				WHEN 140
				THEN '140'
				WHEN NULL
				THEN 'Offline'
				ELSE 'Error'
			END AS 'Compatibility_Level', 
			a.collation_name AS 'CollationName',
			CASE user_access
				WHEN 0
				THEN 'Multi_User'
				WHEN 1
				THEN 'Single_User'
				WHEN 2
				THEN 'Restricted'
				ELSE 'Error'
			END AS 'User_Access',
			CASE page_verify_option
				WHEN 0
				THEN 'None'
				WHEN 1
				THEN 'Torn_Page_Detection'
				WHEN 2
				THEN 'Checksum'
				ELSE 'Error'
			END AS 'Page_Verify_Option',
			CASE is_published
				WHEN 1
				THEN 'Yes'
				WHEN 0
				THEN 'No'
				ELSE 'Error'
			END AS 'Is_Published',
			CASE is_subscribed
				WHEN 1
				THEN 'Yes'
				WHEN 0
				THEN 'No'
				ELSE 'Error'
			END AS 'Is_Subscribed',
			CASE is_merge_published
				WHEN 1
				THEN 'Yes'
				WHEN 0
				THEN 'No'
				ELSE	'Error'
			END AS 'Is_Merge_Published',
			CASE is_distributor
				WHEN 1
				THEN 'Yes'
				WHEN 0
				THEN 'No'
				ELSE 'Error'
			END AS 'Is_Distributor',
			CASE is_broker_enabled
				WHEN 1
				THEN 'Yes'
				WHEN 0
				THEN 'No'
				ELSE 'Error'
			END AS 'Is_Broker_Enabled',
			CASE log_reuse_wait
				WHEN 0
				THEN 'Nothing'
				WHEN 1
				THEN 'Checkpoint'
				WHEN 2
				THEN 'Log Backup'
		        WHEN 3
				THEN 'Active backup or restore'
				WHEN 4
				THEN 'Active transaction'
				WHEN 5
				THEN 'Database mirroring'
				WHEN 6
				THEN 'Replication'
				WHEN 7
				THEN 'Database snapshot creation'
				WHEN 8
				THEN 'Log scan'
				WHEN 9
				THEN 'Other'
				ELSE 'Error'
			END AS 'Log_Reuse_Wait',
			CASE a.snapshot_isolation_state_desc
				WHEN 'off'
				THEN 'Off'
				WHEN 'ON'
				THEN 'On'
				ELSE 'Error'
			END AS 'SnapshotIsolationState',
			CASE a.is_read_committed_snapshot_on
				WHEN 0
				THEN 'Off'
				WHEN 1
				THEN 'On'
				ELSE 'Error'
			END AS 'IsReadCommittedSnapshotOn', 
       a.create_date AS 'Create_Date',
			CASE d.mirroring_role
				WHEN 1
				THEN 'Principal'
				WHEN 2
				THEN 'Mirror'
				ELSE 'None'
			END AS 'MirroringRole',
			CASE d.mirroring_safety_level
				WHEN 0
				THEN 'Unknown'
				WHEN 1
				THEN 'Async'
				WHEN 2
				THEN 'Sync'
				ELSE 'None'
			END AS 'MirroringSafety'
		FROM sys.databases AS a
			LEFT OUTER JOIN sys.database_mirroring AS d ON (a.database_id = d.database_id)
			LEFT JOIN
				(
				SELECT database_id, 
						CONVERT(BIGINT, SUM(size * 8.0 / 1024)) AS 'DataSize'
					FROM sys.master_files
				WHERE type_desc = 'rows'
				GROUP BY database_id) AS b ON b.database_id = a.database_id
			LEFT JOIN
				(
				SELECT database_id, 
						CONVERT(BIGINT, SUM(size * 8.0 / 1024)) AS 'LogSize'
					FROM sys.master_files
				WHERE type_desc = 'log'
				GROUP BY database_id) AS c ON c.database_id = a.database_id
				ORDER BY a.name;


END
GO
