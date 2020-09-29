SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_xev_SetupExtendedEventsSessionBO
--
--
-- Calls:		None
--
-- Description:	We’d like to catch all errors higher than a severity of 10. We want to 
--				stream the errors to a file stored on our SQL Server asynchronously.
--				The script defines the Extended Events session and then starts it.
--
-- https://www.brentozar.com/archive/2013/08/what-queries-are-failing-in-my-sql-server/
-- 
-- Date			Modified By			Changes
-- 11/12/2019   Aron E. Tekulsky    Initial Coding.
-- 11/12/2019   Aron E. Tekulsky    Update to Version 150.
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

	--------DECLARE @Drive				nvarchar(128)
	--------DECLARE @FullTargetPath		nvarchar(256)
	--------DECLARE @EventPath			nvarchar(1000)
	--------DECLARE @EventName			nvarchar(128)
	--------DECLARE @MetaDataFileName	nvarchar(256)

	---------- initialize
	--------SET @Drive				= 'S';
	--------SET @EventPath			= 'XEventSessions';
	--------SET @EventName			= 'what_queries_are_failing';
	--------SET @FullTargetPath		= '''' + @Drive + ':\' + @EventPath + '\' + @EventName +  '.xel' + '''';
	--------SET @MetaDataFileName	= '''' + @Drive + ':\' + @EventPath + '\' + @EventName +  '.xem' + '''';

--Create an extended event session
	CREATE EVENT SESSION
	what_queries_are_failing
		ON SERVER
	ADD EVENT sqlserver.error_reported
	(
		ACTION (sqlserver.sql_text, sqlserver.tsql_stack, sqlserver.database_id, sqlserver.username)
			WHERE ([severity]> 10)
	)
	ADD TARGET package0.asynchronous_file_target
		(set filename		= 'S:\XEventSessions\what_queries_are_failing.xel' ,
		metadatafile		= 'S:\XEventSessions\what_queries_are_failing.xem',
		max_file_size		= 5,
		max_rollover_files	= 5)
	WITH (MAX_DISPATCH_LATENCY = 5SECONDS);
----GO

-- Start the session
	ALTER EVENT SESSION what_queries_are_failing
		ON SERVER STATE = START;
----GO
END
GO
