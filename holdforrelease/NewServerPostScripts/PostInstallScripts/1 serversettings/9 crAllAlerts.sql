USE [msdb]
GO

/****** Object:  Alert [Deadlock - Page]    Script Date: 06/13/2013 15:14:01 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Deadlock - Page', 
		@message_id=0, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=0, 
		@category_name=N'[Uncategorized]', 
		@performance_condition=N'SQLServer:Locks|Number of Deadlocks/sec|Page|>|0', 
		@job_id=N'00000000-0000-0000-0000-000000000000'

/****** Object:  Alert [Object Deadlock]    Script Date: 6/24/2013 9:31:18 AM ******/
EXEC msdb.dbo.sp_add_alert @name=N'Object Deadlock', 
		@message_id=0, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@performance_condition=N'SQLServer:Locks|Number of Deadlocks/sec|Object|>|0', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Deadlock - Keys]    Script Date: 06/13/2013 15:15:04 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Deadlock - Keys', 
		@message_id=0, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=0, 
		@category_name=N'[Uncategorized]', 
		@performance_condition=N'SQLServer:Locks|Number of Deadlocks/sec|Key|>|0', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Deadlock - Database]    Script Date: 06/13/2013 15:12:15 ******/
EXEC msdb.dbo.sp_add_alert @name=N'Deadlock - Database', 
		@message_id=0, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=0, 
		@category_name=N'[Uncategorized]', 
		@performance_condition=N'SQLServer:Locks|Number of Deadlocks/sec|Database|>|0', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [A/c locked out]    Script Date: 4/17/2012 9:52:59 AM ******/
EXEC msdb.dbo.sp_add_alert @name=N'18486 Acct locked out', 
		@message_id=18486, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Restore_Success_08]    Script Date: 04/02/2012 15:21:02 ******/
EXEC msdb.dbo.sp_add_alert @name=N'18265 Restore Success', 
		@message_id=18265, 
		@severity=0, 
		@enabled=0, 
		@delay_between_responses=0, 
		@include_event_description_in=5, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


/****** Object:  Alert [Backup_Success_01]    Script Date: 04/02/2012 15:04:25 ******/
EXEC msdb.dbo.sp_add_alert @name=N'18264 Database Backed Up', 
		@message_id=18264, 
		@severity=0, 
		@enabled=0, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [18210 Write Failure on Backup Device]    Script Date: 07/10/2013 10:46:40 ******/
EXEC msdb.dbo.sp_add_alert @name=N'18210 Write Failure on Backup Device', 
		@message_id=18210, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


/****** Object:  Alert [18204 Backup Device Failure]    Script Date: 3/25/2016 8:18:12 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'18204 Backup Device Failure - Access is Denied')
EXEC msdb.dbo.sp_add_alert @name=N'18204 Backup Device Failure - Access is Denied', 
		@message_id=18204, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Full log usnyqdba01]    Script Date: 04/02/2012 15:09:54 ******/
EXEC msdb.dbo.sp_add_alert @name=N'9002Transaction Log Full', 
		@message_id=9002, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Minimum Query Memory]    Script Date: 04/02/2012 15:12:56 ******/
EXEC msdb.dbo.sp_add_alert @name=N'8651 Minimum Query Memory', 
		@message_id=8651, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Timeout Memory Resources]    Script Date: 04/02/2012 15:22:35 ******/
EXEC msdb.dbo.sp_add_alert @name=N'8645 Timeout Memory Resources', 
		@message_id=8645, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Internal Stack Limit]    Script Date: 04/02/2012 15:10:36 ******/
EXEC msdb.dbo.sp_add_alert @name=N'8631 Internal Stack Limit', 
		@message_id=8631, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [3025 Restore Failure]    Script Date: 3/25/2016 8:42:31 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'3025 Restore Failure')
EXEC msdb.dbo.sp_add_alert @name=N'3025 Restore Failure - Missing database name. Reissue the statement specifying a valid database name.', 
		@message_id=3025, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=5, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [3024 Restore Failure]    Script Date: 3/25/2016 8:40:38 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'3024 Restore Failure')
EXEC msdb.dbo.sp_add_alert @name=N'3024 Backup Failure - You can only perform a full backup of the master database. Use BACKUP DATABASE to back up the entire master database', 
		@message_id=3024, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [3023 Restore Failure]    Script Date: 3/25/2016 8:38:59 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'3023 Restore Failure')
EXEC msdb.dbo.sp_add_alert @name=N'3023 Restore Failure Backup and file manipulation operations (such as ALTER DATABASE ADD FILE) on a database must be serialized. Reissue the statement after the current backup or file manipulation operation is completed', 
		@message_id=3023, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=5, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [3021 Restore_Failure]    Script Date: 3/25/2016 8:37:11 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'3021 Restore_Failure')
EXEC msdb.dbo.sp_add_alert @name=N'3021 Restore_Failure - Cannot perform a backup or restore operation within a transaction.', 
		@message_id=3021, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
/****** Object:  Alert [Backup_Failure_07]    Script Date: 04/02/2012 15:02:40 ******/
EXEC msdb.dbo.sp_add_alert @name=N'3019 Restart Checkpoint File previous Restore', 
		@message_id=3019, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Backup_Failure_06]    Script Date: 04/02/2012 15:00:25 ******/
EXEC msdb.dbo.sp_add_alert @name=N'3018 Restart Checkpoint File Not Found', 
		@message_id=3018, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Backup_Failure_05]    Script Date: 04/02/2012 14:58:47 ******/
EXEC msdb.dbo.sp_add_alert @name=N'3017 Restart Checkpoint File', 
		@message_id=3017, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Backup_Failure_04]    Script Date: 04/02/2012 14:57:07 ******/
EXEC msdb.dbo.sp_add_alert @name=N'3016 Backup Not Permitted', 
		@message_id=3016, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Restore_Failure_12]    Script Date: 04/02/2012 15:14:02 ******/
EXEC msdb.dbo.sp_add_alert @name=N'3012 Restore Failure', 
		@message_id=3012, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Failover Alert]    Script Date: 08/25/2009 12:00:04 ******/
EXEC msdb.dbo.sp_add_alert @name=N'1480 Failover Alert', 
		@message_id=1480, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


/****** Object:  Alert [1418 Server Network Address Cannot be Reached or Does Not Exist]    Script Date: 06/25/2012 16:19:36 ******/
EXEC msdb.dbo.sp_add_alert @name=N'1418 Server Network Address Cannot be Reached or Does Not Exist', 
		@message_id=1418, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Failover Alert]    Script Date: 08/25/2009 12:00:04 ******/
EXEC msdb.dbo.sp_add_alert @name=N'1408 Failover Alert', 
		@message_id=1408, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [1205]    Script Date: 04/02/2012 15:23:47 ******/
EXEC msdb.dbo.sp_add_alert @name=N'1205 Transaction Process Deadlock', 
		@message_id=1205, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=5, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


/****** Object:  Alert [could not allocate space for object]    Script Date: 04/02/2012 15:07:48 ******/
EXEC msdb.dbo.sp_add_alert @name=N'1105 Object Space Allocation Failure', 
		@message_id=1105, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [Could not allocate a new page for database]    Script Date: 04/02/2012 15:06:09 ******/
EXEC msdb.dbo.sp_add_alert @name=N'1101 New Page Allocation Failure for database', 
		@message_id=1101, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [833 Chk Avg Disk Counters With Perf Mon]    Script Date: 10/25/2013 3:11:02 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'833 Chk Avg Disk Counters With Perf Mon', 
		@message_id=833, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=0, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [825 major problem with the disk hardware]    Script Date: 10/25/2013 2:13:14 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'825 Major Problem With the Disk Hardware', 
		@message_id=825, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=0, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [824 I/O Subsystem Error]    Script Date: 10/25/2013 2:06:01 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'824 I/O Subsystem Error', 
		@message_id=824, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=0, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [823 - Windows read or write request has failed]    Script Date: 10/25/2013 2:10:26 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'823  Windows read or write request has failed', 
		@message_id=823, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=0, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [025 - Fatal Error]    Script Date: 3/5/2013 3:09:27 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'025 - Fatal Error', 
		@message_id=0, 
		@severity=25, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=0, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [024 - Fatal Error: Hardware Error]    Script Date: 3/5/2013 3:08:58 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'024 - Fatal Error: Hardware Error', 
		@message_id=0, 
		@severity=24, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [023 - Fatal Error: Database Integrity Suspect]    Script Date: 3/5/2013 3:08:29 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'023 - Fatal Error: Database Integrity Suspect', 
		@message_id=0, 
		@severity=23, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [022 - Fatal Error: Table Integrity Suspect]    Script Date: 3/5/2013 3:07:30 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'022 - Fatal Error: Table Integrity Suspect', 
		@message_id=0, 
		@severity=22, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [021 - Fatal Error in Database Processes]    Script Date: 3/5/2013 3:07:02 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'021 - Fatal Error in Database Processes', 
		@message_id=0, 
		@severity=21, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
/****** Object:  Alert [020 - Fatal Error in Current Process]    Script Date: 3/5/2013 3:06:29 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'020 - Fatal Error in Current Process', 
		@message_id=0, 
		@severity=20, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [019 - Fatal Error in Resource]    Script Date: 3/5/2013 3:05:28 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'019 - Fatal Error in Resource', 
		@message_id=0, 
		@severity=19, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [018 - NonFatal Internal Error]    Script Date: 5/6/2013 12:36:19 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'018 - NonFatal Internal Error', 
		@message_id=0, 
		@severity=18, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=0, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [017 - Insufficient Resources]    Script Date: 5/6/2013 12:36:48 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'017 - Insufficient Resources', 
		@message_id=0, 
		@severity=17, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=0, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

/****** Object:  Alert [016 - Miscellaneous User Error]    Script Date: 5/6/2013 12:37:07 PM ******/
EXEC msdb.dbo.sp_add_alert @name=N'016 - Miscellaneous User Error', 
		@message_id=0, 
		@severity=16, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=0, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO


