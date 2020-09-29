SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_alt_GetAlertsWOperators
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

	  SELECT TOP (1000) a.[id]
		  ,a.[name]
		  ------,a.[event_source]
		  ------,a.[event_category_id]
		  ------,a.[event_id]
		  ,a.[message_id]
		  ,a.[severity]
		  ,a.[enabled]
		  ----,a.[delay_between_responses]
		  ,CASE a.[last_occurrence_date]
				WHEN 0 THEN ''
				ELSE dba_db16.[dbo].[f_dba16_utl_ConvertIntDateToString](a.[last_occurrence_date])
			END AS last_occurrence_date
		  ,CASE a.[last_occurrence_time]
				WHEN 0 THEN ''
				ELSE dba_db16.[dbo].[f_dba16_utl_ConvertIntTimeToString](a.[last_occurrence_time])
			END AS last_occurrence_time
		  ,CASE a.[last_response_date]
				WHEN 0 THEN ''
				ELSE dba_db16.[dbo].[f_dba16_utl_ConvertIntDateToString](a.[last_response_date])
			END AS last_response_date
		  ,CASE a.[last_response_time]
				WHEN 0 THEN ''
				ELSE dba_db16.[dbo].[f_dba16_utl_ConvertIntTimeToString](a.[last_response_time])
			END AS last_response_time
		  ----,a.[last_response_date]
		  ----,a.[last_response_time]
		  ,a.[notification_message]
		  ,a.[include_event_description]
		  ,a.[database_name]
		  ,a.[event_description_keyword]
		  ,a.[occurrence_count]
		  ,CASE a.[count_reset_date]
				WHEN 0 THEN ''
				ELSE dba_db16.[dbo].[f_dba16_utl_ConvertIntDateToString](a.[count_reset_date])
			END AS count_reset_date
		  ,CASE a.[count_reset_time]
				WHEN 0 THEN ''
				ELSE dba_db16.[dbo].[f_dba16_utl_ConvertIntTimeToString](a.[count_reset_time])
			END AS count_reset_time
		  ,a.[job_id]
		  ,a.[has_notification]
		  ----,a.[flags]
		  ,a.[performance_condition]
		  ,a.[category_id]
		  ----,n.[alert_id]
		  ----,n.[operator_id]
		  ,n.[notification_method]
		  ----,o.[id]
		  ,o.[name]
		  ,o.[enabled]
		  ,o.[email_address]
		  ,CASE o.[last_email_date]
				WHEN 0 THEN ''
				ELSE dba_db16.[dbo].[f_dba16_utl_ConvertIntDateToString](o.[last_email_date])
			END AS last_email_date
		  ,CASE o.[last_email_time]
				WHEN 0 THEN ''
				ELSE dba_db16.[dbo].[f_dba16_utl_ConvertIntTimeToString](o.[last_email_time])
			END AS last_email_time
		  ,o.[pager_address]
		  ,CASE o.[last_pager_date]
				WHEN 0 THEN ''
				ELSE dba_db16.[dbo].[f_dba16_utl_ConvertIntDateToString](o.[last_pager_date])
			END AS last_pager_date
		  ,CASE o.[weekday_pager_start_time]
				WHEN 0 THEN ''
				ELSE dba_db16.[dbo].[f_dba16_utl_ConvertIntTimeToString](o.[weekday_pager_start_time])
			END AS weekday_pager_start_time
		  ,CASE o.[weekday_pager_end_time]
				WHEN 0 THEN ''
				ELSE dba_db16.[dbo].[f_dba16_utl_ConvertIntTimeToString](o.[weekday_pager_end_time])
			END AS weekday_pager_end_time
		  ,CASE o.[saturday_pager_start_time]
				WHEN 0 THEN ''
				ELSE dba_db16.[dbo].[f_dba16_utl_ConvertIntTimeToString](o.[saturday_pager_start_time])
			END AS saturday_pager_start_time
		  ,CASE o.[saturday_pager_end_time]
				WHEN 0 THEN ''
				ELSE dba_db16.[dbo].[f_dba16_utl_ConvertIntTimeToString](o.[saturday_pager_end_time])
			END AS saturday_pager_end_time
		  ,CASE o.[sunday_pager_start_time]
				WHEN 0 THEN ''
				ELSE dba_db16.[dbo].[f_dba16_utl_ConvertIntTimeToString](o.[sunday_pager_start_time])
			END AS sunday_pager_start_time
		  ,CASE o.[sunday_pager_end_time]
				WHEN 0 THEN ''
				ELSE dba_db16.[dbo].[f_dba16_utl_ConvertIntTimeToString](o.[sunday_pager_end_time])
			END AS sunday_pager_end_time
		  ----,o.[weekday_pager_start_time]
		  ----,o.[weekday_pager_end_time]
		  ----,o.[saturday_pager_start_time]
		  ----,o.[saturday_pager_end_time]
		  ----,o.[sunday_pager_start_time]
		  ----,o.[sunday_pager_end_time]
		  ,o.[pager_days]
		  ,o.[netsend_address]
		  ,CASE o.[last_netsend_date]
				WHEN 0 THEN ''
				ELSE dba_db16.[dbo].[f_dba16_utl_ConvertIntDateToString](o.[last_netsend_date])
			END AS last_netsend_date
		  ,CASE o.[last_netsend_time]
				WHEN 0 THEN ''
				ELSE dba_db16.[dbo].[f_dba16_utl_ConvertIntTimeToString](o.[last_netsend_time])
			END AS last_netsend_time
		  ,o.[category_id]
		  FROM [msdb].[dbo].[sysalerts] a
			JOIN [msdb].[dbo].[sysnotifications] n ON (n.alert_id = a.id)
			JOIN [msdb].[dbo].[sysoperators] o  ON (o.[id] = n.operator_id )

	  ORDER BY a.[name] ASC, a.[last_occurrence_date] DESC, a.[last_occurrence_time] DESC;

END
GO
