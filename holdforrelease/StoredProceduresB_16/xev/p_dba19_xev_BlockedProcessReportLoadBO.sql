SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_xev_BlockedProcessReportLoadBO
--
-- Arguments:	@Source
--				@StartDate
--				@EndDate
--
-- CallS:		p_dba19_xev_BlockedProcessReportLoad
--
-- Called BY:	None
--
-- Description:	
--
-- https://www.brentozar.com/archive/2014/03/extended-events-doesnt-hard/
-- 
-- Date			Modified By			Changes
-- 01/01/2020   Aron E. Tekulsky    Initial Coding.
-- 01/01/2020   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_xev_BlockedProcessReportLoadBO 
	-- Add the parameters for the stored procedure here
	@Source		nvarchar(max) , 
	@StartDate	datetime2,
	@EndDate	datetime2
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	CREATE TABLE #bpr (
		EndTime		datetime,
		TextDate	xml,
		EventClass	int DEFAULT(137))

	;WITH event_cte AS (
		SELECT 
				DATEADD(mi,
				DATEDIFF(mi,GETUTCDATE(), CURRENT_TIMESTAMP),
				xevents.event_data.value('(event/@timestamp)[1]',
				'datetime2')) AS [event_time] ,
				xevents.event_data.query('(event[@name="blocked_process_report"]/data[@name="blocked_process"]/value/blocked-process-report)[1]')
					AS blocked_process_report
			FROM sys.fn_xe_file_target_read_file 
				(@Source,
				null,
				null, null)
				CROSS APPLY (SELECT CAST(event_data AS xml) AS event_data) as xevents
		)

		INSERT INTO #bpr (EndTime, TextData)
		SELECT
				[event_time],
				blocked_process_report
			FROM events_cte
		WHERE blocked_process_report.value('(blocked-process-report[@monitorLoop])[1]', 'nvarchar(max)') IS NOT NULL
			AND event_time BETWEEN @StartDate and @EndDate
		ORDER BY [event_time] DESC;

		EXEC dba_db16.dbo.p_dba19_xev_BlockedProcessReportViewerMJ @Source='#bpr', @Type='TABLE';


	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_xev_BlockedProcessReportLoad TO [db_proc_exec] AS [dbo]
GO
