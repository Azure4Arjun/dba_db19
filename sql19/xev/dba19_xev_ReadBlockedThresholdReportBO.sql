SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_xev_ReadBlockedThresholdReportBO
--
--
-- Calls:		None
--
-- Description:	We need to get that blocked process data out of the Extended Events 
--				files and somewhere that we can better analyze it.
-- 
-- https://www.brentozar.com/archive/2014/03/extended-events-doesnt-hard/
--
-- Note replace "L:\temp\XEventSessions\blocked_process*.xel" with the correct location 
-- you choose that matches the event set up.
--
-- Date			Modified By			Changes
-- 03/04/2020   Aron E. Tekulsky    Initial Coding.
-- 03/04/2020   Aron E. Tekulsky    Update to Version 150.
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
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

		WITH events_cte AS (
		  SELECT
			xevents.event_data,
			DATEADD(mi,
			DATEDIFF(mi, GETUTCDATE(), CURRENT_TIMESTAMP),
			xevents.event_data.value(
			  '(event/@timestamp)[1]', 'datetime2')) AS [event_time] ,
			xevents.event_data.value(
			  '(event/action[@name="client_app_name"]/value)[1]', 'nvarchar(128)')
			  AS [client app name],
			xevents.event_data.value(
			  '(event/action[@name="client_hostname"]/value)[1]', 'nvarchar(max)')
			  AS [client host name],
			xevents.event_data.value(
			  '(event[@name="blocked_process_report"]/data[@name="database_name"]/value)[1]', 'nvarchar(max)')
			  AS [database name],
			xevents.event_data.value(
			  '(event[@name="blocked_process_report"]/data[@name="database_id"]/value)[1]', 'int')
			  AS [database_id],
			xevents.event_data.value(
			  '(event[@name="blocked_process_report"]/data[@name="object_id"]/value)[1]', 'int')
			  AS [object_id],
			xevents.event_data.value(
			  '(event[@name="blocked_process_report"]/data[@name="index_id"]/value)[1]', 'int')
			  AS [index_id],
			xevents.event_data.value(
			  '(event[@name="blocked_process_report"]/data[@name="duration"]/value)[1]', 'bigint') / 1000
			  AS [duration (ms)],
			xevents.event_data.value(
			  '(event[@name="blocked_process_report"]/data[@name="lock_mode"]/text)[1]', 'varchar')
			  AS [lock_mode],
			xevents.event_data.value(
			  '(event[@name="blocked_process_report"]/data[@name="login_sid"]/value)[1]', 'int')
			  AS [login_sid],
			xevents.event_data.query(
			  '(event[@name="blocked_process_report"]/data[@name="blocked_process"]/value/blocked-process-report)[1]')
			  AS blocked_process_report,
			xevents.event_data.query(
			  '(event/data[@name="xml_report"]/value/deadlock)[1]')
			  AS deadlock_graph
		  FROM    sys.fn_xe_file_target_read_file
			------('L:\temp\XEventSessions\blocked_process*.xel',
			------ 'L:\temp\XEventSessions\blocked_process*.xem',
			------ null, null)
			('L:\ExtendedEvents\Blocked\*.xel',
			 'L:\ExtendedEvents\Blocked\*.xem',
			 null, null)
			CROSS APPLY (SELECT CAST(event_data AS XML) AS event_data) as xevents
		)
		SELECT
			  CASE WHEN blocked_process_report.value('(blocked-process-report[@monitorLoop])[1]', 'nvarchar(max)') IS NULL
				   THEN 'Deadlock'
				   ELSE 'Blocked Process'
				   END AS ReportType,
			  [event_time],
			  CASE [client app name] WHEN '' THEN ' -- N/A -- '
									 ELSE [client app name]
									 END AS [client app _name],
			  CASE [client host name] WHEN '' THEN ' -- N/A -- '
									  ELSE [client host name]
									  END AS [client host name],
			  [database name],
			  COALESCE(OBJECT_SCHEMA_NAME(object_id, database_id), ' -- N/A -- ') AS [schema],
			  COALESCE(OBJECT_NAME(object_id, database_id), ' -- N/A -- ') AS [table],
			  index_id,
			  [duration (ms)],
			  lock_mode,
			  COALESCE(SUSER_NAME(login_sid), ' -- N/A -- ') AS username,
			  CASE WHEN blocked_process_report.value('(blocked-process-report[@monitorLoop])[1]', 'nvarchar(max)') IS NULL
				   THEN deadlock_graph
				   ELSE blocked_process_report
				   END AS [Report Blocked/Deadlocked]
			FROM events_cte
		ORDER BY [event_time] DESC ;
END
GO
