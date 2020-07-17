SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba16_met_DMGetActiveBlockingConnection
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get a list of active blocking connections.
-- 
-- Date			Modified By			Changes
-- 02/19/2014   Aron E. Tekulsky    Initial Coding.
-- 02/13/2018   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba16_met_DMGetActiveBlockingConnection 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	SELECT	S.login_name
			, S.login_time
			, BS.login_name
			, BS.login_time
			, R.session_id
			, R.start_time
			, R.command
			, R.status
			, R.cpu_time
			, R.reads
			, R.writes
			, R.logical_reads
			, R.blocking_session_id
			, R.database_id
			, DB_NAME(R.database_id) as database_name
			, C.connect_time
			, C.net_transport
			, C.protocol_type
			, C.client_net_address
			,q.text
		FROM sys.dm_exec_requests R
			INNER JOIN sys.dm_exec_sessions S on R.session_id = S.session_id
			INNER JOIN sys.dm_exec_connections C on R.connection_id = C.connection_id
			LEFT JOIN sys.dm_exec_sessions BS on R.blocking_session_id = BS.session_id
			CROSS APPLY sys.dm_exec_sql_text(R.sql_handle) as q
	WHERE R.status = 'suspended';

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba16_met_DMGetActiveBlockingConnection TO [db_proc_exec] AS [dbo]
GO
