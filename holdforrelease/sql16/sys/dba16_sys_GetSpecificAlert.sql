SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_GetSpecificAlert
--
--
-- Calls:		None
--
-- Description:	Geta a specific job id.
-- 
-- Date			Modified By			Changes
-- 11/02/2016   Aron E. Tekulsky    Initial Coding.
-- 11/22/2017   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyrightę2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	DECLARE @JobId		uniqueidentifier
	DECLARE @JobName	nvarchar(128)


	SET @JobName = 'SQLAlertErrorHandler';

	SELECT [id] 
	  ,[name]
	  ,[event_source]
      --,[event_category_id]
      --,[event_id]
      ,[message_id]
	  ,[severity]
      ,[enabled]
      ,[delay_between_responses]
      --,[last_occurrence_date]
      --,[last_occurrence_time]
      --,[last_response_date]
      --,[last_response_time]
      --,[notification_message]
      --,[include_event_description]
      ,[database_name]
      --,[event_description_keyword]
      --,[occurrence_count]
      --,[count_reset_date]
      --,[count_reset_time]
      ,[job_id]
      --,[has_notification]
      --,[flags]
      --,[performance_condition]
      ,[category_id]
		FROM [msdb].[dbo].[sysalerts]
	WHERE job_id =  [dbo].[f_dba16_GetJobId](@JobName)
	--WHERE convert(varchar(36),job_id) <> @JobName


	-- 1 get the job id of the job called sql alert
	-- 2 get the list of alerts from an alert table in dba_db
	-- 3 build sql to create an alert in msdb that has a response.

END
GO
