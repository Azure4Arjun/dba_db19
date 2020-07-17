USE [dba_db19]
GO

/****** Object:  View [dbo].[v_dba19_xev_ViewFailedQueries]    Script Date: 3/5/2020 6:07:43 PM ******/
DROP VIEW [dbo].[v_dba19_xev_ViewFailedQueries]
GO

/****** Object:  View [dbo].[v_dba19_xev_ViewFailedQueries]    Script Date: 3/5/2020 6:07:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ======================================================================================
-- v_dba19_xev_ViewFailedQueries
--
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 11/12/2019   Aron E. Tekulsky    Initial Coding.
-- 11/12/2019   Aron E. Tekulsky    Update to Version 150.
-- 05/19/2020   Aron E. Tekulsky    Update to sql2019.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================

CREATE VIEW [dbo].[v_dba19_xev_ViewFailedQueries]
AS
SELECT 
	[XML Data],
	[XML Data].value('(/event[@name=''error_reported'']/@timestamp)[1]','DATETIME')	AS [Timestamp],
	[XML Data].value('(/event/action[@name=''database_name'']/value)[1]','varchar(max)')	AS [Database],
	[XML Data].value('(/event/data[@name=''message'']/value)[1]','varchar(max)')	AS [message],
	[XML Data].value('(/event/action[@name=''sql_text'']/value)[1]','varchar(max)')	AS [Statement],
	[XML Data].value('(/event/action[@name=''username'']/value)[1]','varchar(max)')	AS [Username],
	[XML Data].value('(/event/action[@name=''client_hostname'']/value)[1]','varchar(max)')	AS [ClientHost],
	[XML Data].value('(/event/action[@name=''client_app_name'']/value)[1]','varchar(max)')	AS [ClientAppName],
	[XML Data].value('(/event/action[@name=''session_id'']/value)[1]','int')	AS [SPID]
FROM
	(SELECT 
		OBJECT_NAME					AS [Event],
		CONVERT(XML, event_data)	AS [XML Data]
	FROM
		sys.fn_xe_file_target_read_file 
	('L:\ExtendedEvents\FailedQueries*.xel',NULL,NULL,NULL)) AS FailedQueries;



----	;with events_cte as(
----select
----DATEADD(mi,
----DATEDIFF(mi, GETUTCDATE(), CURRENT_TIMESTAMP),
----xevents.event_data.value('(event/@timestamp)[1]', 'datetime2')) AS [err_timestamp],
----xevents.event_data.value('(event/data[@name="severity"]/value)[1]', 'bigint') AS [err_severity],
----xevents.event_data.value('(event/data[@name="error_number"]/value)[1]', 'bigint') AS [err_number],
----xevents.event_data.value('(event/data[@name="message"]/value)[1]', 'nvarchar(512)') AS [err_message],
----xevents.event_data.value('(event/action[@name="sql_text"]/value)[1]', 'nvarchar(max)') AS [sql_text],
----xevents.event_data
----from sys.fn_xe_file_target_read_file
----('S:\XEventSessions\what_queries_are_failing*.xel',
----'S:\XEventSessions\what_queries_are_failing*.xem',
----null, null)
----cross apply (select CAST(event_data as XML) as event_data) as xevents
----)
----SELECT *
----from events_cte
----order by err_timestamp;
GO


