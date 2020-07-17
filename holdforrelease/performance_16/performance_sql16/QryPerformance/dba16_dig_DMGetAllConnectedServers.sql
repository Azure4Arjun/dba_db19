SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_dig_DMGetAllConnectedServers
--
--
-- Calls:		None
--
-- Description:	Get a list of all connections on the server.
-- 
-- Date			Modified By			Changes
-- 02/27/2018   Aron E. Tekulsky    Initial Coding.
-- 03/01/2018   Aron E. Tekulsky    Update to V140.
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

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	/****** Script for SelectTopNRows command from SSMS ******/
	SELECT TOP (1000) ses.[session_id]
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
			,ses.[client_version]
			----------,ses.[security_id]
			----------,ses.[nt_domain]
			----------,ses.[nt_user_name]
			,ses.[status]
			----------,ses.[context_info]
			,ses.[cpu_time]
			,ses.[memory_usage]
			,ses.[total_scheduled_time]
			,ses.[total_elapsed_time]
			----------,ses.[endpoint_id]
			,ses.[last_request_start_time]
			,ses.[last_request_end_time]
			,ses.[reads]
			,ses.[writes]
			,ses.[logical_reads]
			------------,ses.[is_user_process]
			------------,ses.[text_size]
			------------,ses.[language]
			------------,ses.[date_format]
			------------,ses.[date_first]
			------------,ses.[quoted_identifier]
			------------,ses.[arithabort]
			------------,ses.[ansi_null_dflt_on]
			------------,ses.[ansi_defaults]
			----------,ses.[ansi_warnings]
			----------,ses.[ansi_padding]
			----------,ses.[ansi_nulls]
			----------,ses.[concat_null_yields_null]
			,ses.[transaction_isolation_level]
			----------,ses.[lock_timeout]
			,ses.[deadlock_priority]
			,ses.[row_count]
			,ses.[prev_error]
-			---------,ses.[original_security_id]
			,ses.[original_login_name]
			----------,ses.[last_successful_logon]
			----------,ses.[last_unsuccessful_logon]
			----------,ses.[unsuccessful_logons]
			----------,ses.[group_id]
			----------,ses.[database_id]
			----------,ses.[authenticating_database_id]
			----------,ses.[open_transaction_count]
		FROM [master].[sys].[dm_exec_sessions] ses
			JOIN [master].[sys].[dm_exec_connections] con ON (con.session_id = ses.session_id )
			CROSS APPLY sys.dm_exec_sql_text(con.most_recent_sql_handle ) AS qt
	WHERE host_name IS NOT NULL
		--AND DB_Name(ses.database_id ) IN ('CTX40','CTX40RM','PNGXENAPP','PNGXENDSK','PNGXENRES','XenAppDS')
	ORDER BY DB_Name(ses.database_id ) ASC, ses.host_name ASC, ses.[program_name] ASC;
END
GO
