USE dba_db16
GO

IF object_id(N'dbo.v_dba16_xev_ViewFailedQueriesErrorsBO', 'V') IS NOT NULL
	DROP VIEW dbo.v_dba16_xev_ViewFailedQueriesErrorsBO
GO

-- ======================================================================================
-- v_dba16_xev_ViewFailedQueriesErrorsBO
--
--
-- Description:	To make sure your trace is working, you may query from the files that 
--				are collecting data.
-- 
-- https://www.brentozar.com/archive/2013/08/what-queries-are-failing-in-my-sql-server/
--
-- Date			Modified By			Changes
-- 11/19/2019   Aron E. Tekulsky    Initial Coding.
-- 11/19/2019   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================

CREATE VIEW dbo.v_dba16_xev_ViewFailedQueriesErrorsBO
AS
	WITH events_cte AS(
SELECT
		DATEADD(mi,
		DATEDIFF(mi, GETUTCDATE(), CURRENT_TIMESTAMP),
		XEVENTS.EVENT_DATA.value('(event/@timestamp)[1]', 'datetime2')) AS [err_timestamp],
		XEVENTS.EVENT_DATA.value('(event/data[@name="severity"]/value)[1]', 'bigint') AS [err_severity],
		XEVENTS.EVENT_DATA.value('(event/data[@name="error_number"]/value)[1]', 'bigint') AS [err_number],
		XEVENTS.EVENT_DATA.value('(event/data[@name="message"]/value)[1]', 'nvarchar(512)') AS [err_message],
		XEVENTS.EVENT_DATA.value('(event/action[@name="sql_text"]/value)[1]', 'nvarchar(max)') AS [sql_text],
		XEVENTS.EVENT_DATA
	FROM sys.fn_xe_file_target_read_file
			('L:\ExtendedEvents\FailedQueries*.xel',
			'L:\ExtendedEvents\FailedQueries*.xem',
			null, null)
		CROSS APPLY (SELECT CAST(event_data AS XML) AS event_data) AS xevents
		)

	SELECT *
		FROM events_cte
	----ORDER BY err_timestamp;