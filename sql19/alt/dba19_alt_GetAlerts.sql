SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_alt_GetAlerts
--
--
-- Calls:		None
--
-- Description:	Get a listing of all alerts from MSDB.
-- 
-- Date			Modified By			Changes
-- 11/02/2016   Aron E. Tekulsky    Initial Coding.
-- 11/22/2017   Aron E. Tekulsky    Update to Version 140.
-- 08/25/2020   Aron E. Tekulsky    Update to Version 150.
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
		--,[job_id]
		 --,[has_notification]
		--,[flags]
		 --,[performance_condition]
		 ,[category_id]
	FROM [msdb].[dbo].[sysalerts];

END
GO
