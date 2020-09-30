SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_xe_SetBlockedProcessBO
--
--
-- Calls:		None
--
-- Description:	When you want to find blocking, you probably turn to the blocked process
--				report. You mess around with profiler on your SQL Server 2012 box. You 
--				probably feel a little bit dirty for clunking around in that old 
--				interface, but it gets the job done.
-- 
-- https://www.brentozar.com/archive/2014/03/extended-events-doesnt-hard/
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

	CREATE EVENT SESSION [blocked_process] ON SERVER
	ADD EVENT sqlserver.blocked_process_report(
		ACTION(sqlserver.client_app_name,
			   sqlserver.client_hostname,
			   sqlserver.database_name)) ,
	ADD EVENT sqlserver.xml_deadlock_report (
		ACTION(sqlserver.client_app_name,
			   sqlserver.client_hostname,
			   sqlserver.database_name))
	ADD TARGET package0.asynchronous_file_target
	(SET filename = N'L:\ExtendedEvents\Blocked\blocked-process.xel',
		 metadatafile = N'L:\ExtendedEvents\Blocked\blocked-process.xem',
		 max_file_size=(65536),
		 max_rollover_files=5)
	WITH (MAX_DISPATCH_LATENCY = 5SECONDS)
	----GO

/* Make sure this path exists before you start the trace! */
END
GO
