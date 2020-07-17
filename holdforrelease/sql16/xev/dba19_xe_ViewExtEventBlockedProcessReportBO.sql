SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_xe_ViewExtEventBlockedProcessReportBO
--
--
-- Calls:		None
--
-- Description:	
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

		CREATE TABLE #bpr (
			EndTime DATETIME,
			TextData XML,
			EventClass INT DEFAULT(137)
		);
		----GO

		WITH events_cte AS (
			SELECT
					DATEADD(mi,
					DATEDIFF(mi, GETUTCDATE(), CURRENT_TIMESTAMP),
					xevents.event_data.value('(event/@timestamp)[1]',
					   'datetime2')) AS [event_time] ,
					xevents.event_data.query('(event[@name="blocked_process_report"]/data[@name="blocked_process"]/value/blocked-process-report)[1]')
						AS blocked_process_report
				FROM    sys.fn_xe_file_target_read_file
					('L:\ExtendedEvents\Blocked\blocked-process*.xel',
					 'L:\ExtendedEvents\Blocked\blocked-process*.xem',
					 null, null)
					CROSS APPLY (SELECT CAST(event_data AS XML) AS event_data) as xevents
		)
		INSERT INTO #bpr (EndTime, TextData)
		SELECT
				[event_time],
				blocked_process_report
			FROM events_cte
		WHERE blocked_process_report.value('(blocked-process-report[@monitorLoop])[1]', 'nvarchar(max)') IS NOT NULL
		ORDER BY [event_time] DESC ;

		--------EXEC sp_blocked_process_report_viewer @Trace='bpr', @Type='TABLE'; -- original code by BO.
		EXEC p_dba19_xev_BlockedProcessReportViewerMJ @Trace='#bpr', @Type='TABLE'

		DROP TABLE #bpr;
END
GO
