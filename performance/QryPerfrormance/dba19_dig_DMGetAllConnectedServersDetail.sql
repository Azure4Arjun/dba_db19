SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_dig_DMGetAllConnectedServersDetail
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 05/17/2019   Aron E. Tekulsky    Initial Coding.
-- 05/17/2019   Aron E. Tekulsky    Update to Version 140.
-- 10/07/2019	Aron E. Tekulsky	Add command.
-- 08/12/2020   Aron E. Tekulsky    Update to Version 150.
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

--WARNING! ERRORS ENCOUNTERED DURING SQL PARSING!
	DECLARE @Cmd NVARCHAR(4000)

	DECLARE @connections AS TABLE (
		session_id						SMALLINT
		,login_time						DATETIME
		,host_name						NVARCHAR(128)
		,program_name					NVARCHAR(128)
		,DBName							NVARCHAR(128)
		,client_interface_name			NVARCHAR(32)
		,login_name						NVARCHAR(128)
		,client_net_address				VARCHAR(48)
		,client_tcp_port				INT
		,TEXT							NVARCHAR(max)
		,host_process_id				INT
		,command						nvarchar(32)
		,client_version					INT
		,STATUS							NVARCHAR(30)
		,cpu_time						INT
		,memory_usage					INT
		,total_scheduled_time			INT
		,total_elapsed_time				INT
		,last_request_start_time		DATETIME
		,last_request_end_time			DATETIME
		,reads							BIGINT
		,writes							BIGINT
		,logical_reads					BIGINT
		,transaction_isolation_level	SMALLINT
		,DEADLOCK_PRIORITY				INT
		,row_count						BIGINT
		,prev_error						INT
		,original_login_name			NVARCHAR(128)
		,plan_handle					VARBINARY(64)
		,query_plan						XML
		)
	----SELECT TOP (1000) ses.[session_id]
	---- ,ses.[login_time]
	---- ,ses.[host_name]
	---- ,ses.[program_name]
	---- ,DB_Name(ses.database_id ) AS DBName
	---- ,ses.[client_interface_name]
	---- ,ses.[login_name]
	---- ,con.client_net_address
	---- ,con.client_tcp_port
	---- ,qt.text
	---- ,ses.[host_process_id]
	---- ,ses.[client_version]
	---- ----------,ses.[security_id]
	---- ----------,ses.[nt_domain]
	---- ----------,ses.[nt_user_name]
	---- ,ses.[status]
	---- ----------,ses.[context_info]
	---- ,ses.[cpu_time]
	---- ,ses.[memory_usage]
	---- ,ses.[total_scheduled_time]
	---- ,ses.[total_elapsed_time]
	---- ----------,ses.[endpoint_id]
	---- ,ses.[last_request_start_time]
	---- ,ses.[last_request_end_time]
	---- ,ses.[reads]
	---- ,ses.[writes]
	---- ,ses.[logical_reads]
	---- ------------,ses.[is_user_process]
	---- ------------,ses.[text_size]
	---- ------------,ses.[language]
	---- ------------,ses.[date_format]
	---- ------------,ses.[date_first]
	---- ------------,ses.[quoted_identifier]
	---- ------------,ses.[arithabort]
	---- ------------,ses.[ansi_null_dflt_on]
	---- ------------,ses.[ansi_defaults]
	---- ----------,ses.[ansi_warnings]
	---- ----------,ses.[ansi_padding]
	---- ----------,ses.[ansi_nulls]
	---- ----------,ses.[concat_null_yields_null]
	---- ,ses.[transaction_isolation_level]
	---- ----------,ses.[lock_timeout]
	---- ,ses.[deadlock_priority]
	---- ,ses.[row_count]
	---- ,ses.[prev_error]
	---- ----------,ses.[original_security_id]
	---- ,ses.[original_login_name]
	---- ----------,ses.[last_successful_logon]
	---- ----------,ses.[last_unsuccessful_logon]
	---- ----------,ses.[unsuccessful_logons]
	---- ----------,ses.[group_id]
	---- ----------,ses.[database_id]
	---- ----------,ses.[authenticating_database_id]
	---- ----------,ses.[open_transaction_count]
	---- FROM [master].[sys].[dm_exec_sessions] ses
	---- JOIN [master].[sys].[dm_exec_connections] con ON
	--(con.session_id = ses.session_id)
	---- LEFT JOIN master.sys.dm_exec_requests r ON (r.session_id =
	--con.session_id )
	---- CROSS APPLY sys.dm_exec_sql_text(con.most_recent_sql_handle
	--) AS qt
	---- ------CROSS APPLY sys.dm_exec_query_plan(r.plan_handle ) AS
	--qp
	----WHERE host_name IS NOT NULL
	----ORDER BY DB_Name(ses.database_id ) ASC, ses.host_name ASC,
	--ses.[program_name] ASC;

	SET @Cmd = 
		'SELECT TOP (1000) ses.[session_id]
				,ses.[login_time]
				,ses.[host_name]
				,ses.[program_name]
				,DB_Name(ses.database_id ) AS DBName
				,ses.[client_interface_name]
				,ses.[login_name]
				,con.client_net_address
				,con.client_tcp_port
				,qt.text
				,ses.[host_process_id]
				,r.[command]
				,ses.[client_version]
				,ses.[status]
				,ses.[cpu_time]
				,ses.[memory_usage]
				,ses.[total_scheduled_time]
				,ses.[total_elapsed_time]
				,ses.[last_request_start_time]
				,ses.[last_request_end_time]
				,ses.[reads]
				,ses.[writes]
				,ses.[logical_reads]
				,ses.[transaction_isolation_level]
				,ses.[deadlock_priority]
				,ses.[row_count]
				,ses.[prev_error]
				,ses.[original_login_name]
				,r.plan_handle
			FROM [master].[sys].[dm_exec_sessions] ses
				JOIN [master].[sys].[dm_exec_connections] con ON (con.session_id = ses.session_id )
				LEFT JOIN master.sys.dm_exec_requests r ON (r.session_id = con.session_id )
				CROSS APPLY sys.dm_exec_sql_text(con.most_recent_sql_handle	) AS qt
		WHERE host_name IS NOT NULL
		ORDER BY DB_Name(ses.database_id ) ASC, ses.host_name ASC, ses.[program_name] ASC;'

	INSERT INTO @connections (
		session_id
		,login_time
		,host_name
		,program_name
		,DBName
		,client_interface_name
		,login_name
		,client_net_address
		,client_tcp_port
		,TEXT
		,host_process_id
		,command
		,client_version
		,STATUS
		,cpu_time
		,memory_usage
		,total_scheduled_time
		,total_elapsed_time
		,last_request_start_time
		,last_request_end_time
		,reads
		,writes
		,logical_reads
		,transaction_isolation_level
		,DEADLOCK_PRIORITY
		,row_count
		,prev_error
		,original_login_name
		,plan_handle
		)
	EXEC (@Cmd);

	UPDATE @connections
		SET query_plan = (
			SELECT query_plan
				FROM sys.dm_exec_query_plan(c.plan_handle)
			)
		FROM @connections c;

	SELECT session_id
			,login_time
			,host_name
			,program_name
			,DBName
			,client_interface_name
			,login_name
			,client_net_address
			,client_tcp_port
			,TEXT
			,host_process_id
			,command
			,client_version
			,STATUS
			,cpu_time
			,memory_usage
			,total_scheduled_time
			,total_elapsed_time
			,last_request_start_time
			,last_request_end_time
			,reads
			,writes
			,logical_reads
			,transaction_isolation_level
			,DEADLOCK_PRIORITY
			,row_count
			,prev_error
			,original_login_name
			,query_plan
		FROM @connections;

END
GO
