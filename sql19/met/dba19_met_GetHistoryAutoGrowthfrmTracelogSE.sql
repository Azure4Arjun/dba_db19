SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_met_GetHistoryAutoGrowthfrmTracelogSE
--
--
-- Calls:		None
--
-- Description:	the complete history of auto growth and shrink events.
--
-- https://dba.stackexchange.com/questions/129526/sql-server-history-of-growth-and-shrink-events
--
-- Trace events ID
-- Object:Created					46
-- Object:Deleted					47
-- Sort Warnings					69
-- Missing Column Statistics		79
-- Missing Join Predicate			80
-- Data File Growth					92
-- Log File Growth					93
--									95
-- Audit Schema Object GDR Event	103
-- Audit Backup/Restore Event		115
-- 
-- Date			Modified By			Changes
-- 12/20/2018	Aron E. Tekulsky	Initial Coding.
-- 05/14/2019   Aron E. Tekulsky    Update to Version 140.
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

	DECLARE @TraceFilePath NVARCHAR(4000)

	SELECT @TraceFilePath = CONVERT(NVARCHAR(4000), value)
		FROM sys.fn_trace_getinfo(DEFAULT)
	WHERE property = 2;

	PRINT @TraceFilePath;

	SELECT tr.DatabaseName
			,tr.FileName
			,te.name AS event_name
			,tr.IntegerData
			,tr.IntegerData2
			,tr.LoginName
			,tr.StartTime
			,tr.EndTime
			,tr.EventClass
			,te.category_id
		FROM sys.fn_trace_gettable(convert(NVARCHAR(255), @TraceFilePath), DEFAULT) tr --this is working 1 file only
			----------sys.fn_trace_gettable(convert(NVARCHAR(255), 'F:\SYSTEMDB\MSSQL12.PNGDBATOOLS2F\MSSQL\Log\log_242.trc'), DEFAULT) tr
			----------sys.fn_trace_gettable(convert(NVARCHAR(255), (
			----------	SELECT value
			----------		FROM sys.fn_trace_getinfo(0)
			----------	WHERE property = 2	)), 0) tr
			INNER JOIN sys.trace_events te ON tr.EventClass = te.trace_event_id
	--------WHERE tr.EventClass in (92,93, 95) --can't identify any other EventClass TO ADD here
	ORDER BY tr.DatabaseName ASC, tr.StartTime ASC, tr.EndTime ASC,tr.FileName ;

END
GO
