SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_agt_GetSQLAgentJobErrors
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 03/20/2020   Aron E. Tekulsky    Initial Coding.
-- 03/20/2020   Aron E. Tekulsky    Update to Version 150.
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

	SELECT j.[job_id]
		  ,j.[originating_server_id]
		  ,j.[name]
		  ,j.[enabled]
		  ,j.[description]
		  ,j.[start_step_id]
		  ,j.[category_id]
		  ,j.[owner_sid]
		  ----,[notify_level_eventlog]
		  ----,[notify_level_email]
		  ----,[notify_level_netsend]
		  ----,[notify_level_page]
		  ----,[notify_email_operator_id]
		  ----,[notify_netsend_operator_id]
		  ----,[notify_page_operator_id]
		  ----,[delete_level]
		  ,j.[date_created]
		  ,j.[date_modified]
		  ----,j.[version_number]
		  ----,[instance_id]
      ,h.[sql_message_id]
      ----,h.[sql_severity]
      ,CASE h.[run_status]
		WHEN 0 THEN 'Failed'
		WHEN 1 THEN 'Succeeded'
		WHEN 2 THEN 'Retry'
		WHEN 3 THEN 'Cancelled'
		WHEN 4 THEN 'InProgress'
		END AS run_status
      ,h.[message]
      ,h.[run_date]
      ,h.[run_time]
      ,h.[run_duration]
      ,h.[run_status]
      ,CASE h.[sql_severity]
			WHEN 10 THEN 'Informational messages that return status information or report errors that are not severe. For compatibility reasons, the Database Engine converts severity 10 to severity 0 before returning the error information to the calling application.'
			WHEN 11 THEN 'Indicates that the given object or entity does not exist.'
			WHEN 12	THEN 'A special severity for queries that do not use locking because of special query hints. In some cases, read operations performed by these statements could result in inconsistent data, since locks are not taken to guarantee consistency.'
			WHEN 13	THEN 'Indicates transaction deadlock errors.'
			WHEN 14	THEN 'Indicates security-related errors, such as permission denied.'
			WHEN 15	THEN 'Indicates syntax errors in the Transact-SQL command.'
			WHEN 16	THEN 'Indicates general errors that can be corrected by the user.'
			WHEN 17	THEN 'Indicates that the statement caused SQL Server to run out of resources (such as memory, locks, or disk space for the database) or to exceed some limit set by the system administrator.'
			WHEN 18	THEN 'Indicates a problem in the Database Engine software, but the statement completes execution, and the connection to the instance of the Database Engine is maintained. The system administrator should be informed every time a message with a severity level of 18 occurs.'
			WHEN 19	THEN 'Indicates that a nonconfigurable Database Engine limit has been exceeded and the current batch process has been terminated. Error messages with a severity level of 19 or higher stop the execution of the current batch. Severity level 19 errors are rare and must be corrected by the system administrator or your primary support provider. Contact your system administrator when a message with a severity level 19 is raised.'
			WHEN 20	THEN 'Indicates that a statement has encountered a problem. Because the problem has affected only the current task, it is unlikely that the database itself has been damaged.'
			WHEN 21	THEN 'Indicates that a problem has been encountered that affects all tasks in the current database, but it is unlikely that the database itself has been damaged.'
			WHEN 22	THEN 'Indicates that the table or index specified in the message has been damaged by a software or hardware problem.'
			WHEN 23	THEN 'Indicates that the integrity of the entire database is in question because of a hardware or software problem.'
			WHEN 24	THEN 'Indicates a media failure. The system administrator may have to restore the database. You may also have to call your hardware vendor.'
		ELSE CONVERT(varchar(5), h.[sql_severity])
		END AS sql_severity
      ----,h.[job_id]
      ----,h.[step_id]
      ,h.[step_name]
      ----,h.[operator_id_emailed]
      ----,h.[operator_id_netsent]
      ----,h.[operator_id_paged]
      ----,h.[retries_attempted]
      ----,h.[server]
----[step_id]
----      ,[step_name]
      ,s.[subsystem]
      ,s.[command]
      ,s.[on_success_action]
      ,s.[on_fail_action]
      ,s.[server]
      ,s.[database_name]
      ,s.[database_user_name]
      ,s.[last_run_date]
      ,s.[last_run_duration]
      ,s.[last_run_outcome]
      ,s.[last_run_time]
      ,s.[output_file_name]
      ------,s.[last_run_retries]
      ------,s.[flags]
      ------,s.[additional_parameters]
      ------,s.[cmdexec_success_code]
      ------,s.[on_success_step_id]
      ------,s.[on_fail_step_id]
      ------,s.[retry_attempts]
      ------,s.[retry_interval]
      ------,s.[os_run_priority]
      ------,s.[proxy_id]
      ------,s.[step_uid]	  
	  FROM [msdb].[dbo].[sysjobs] j
		JOIN [msdb].[dbo].[sysjobhistory] h ON (h.job_id = j.job_id )
		LEFT JOIN [msdb].[dbo].[sysjobsteps] s ON (s.job_id = h.job_id )
												AND (s.step_id = h.step_id )
	WHERE j.enabled = 1
		AND h.run_status <> 1
		AND s.last_run_outcome <> 1
	ORDER BY j.name ASC, s.last_run_date DESC, h.step_id ASC, s.last_run_time  DESC;
END
GO
