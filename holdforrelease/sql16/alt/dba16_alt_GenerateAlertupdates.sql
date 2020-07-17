SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_alt_GenerateAlertupdates
--
--
-- Calls:		None
--
-- Description:	Generate updates to alerts.
-- 
-- Date			Modified By			Changes
-- 08/22/2016   Aron E. Tekulsky    Initial Coding.
-- 11/22/2017   Aron E. Tekulsky    Update to Version 140.
-- 05/01/2020	Aron E. Tekulsky	Add code to do operator add or update.
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
	
	DECLARE @cmd						nvarchar(4000)
	DECLARE @delay_between_responses	int
	DECLARE @id							int
	DECLARE @message_id					int
	DECLARE @name						sysname
	DECLARE @include_event_description	tinyint
	DECLARE @has_notification			int
	DECLARE @Operator					sysname

	DECLARE @AddUpdate					int

	-- initialize
	SET @AddUpdate = 1; -- 0 Add, 1 Update

	DECLARE alert_cur CURSOR FOR
		SELECT a.name, a.id, a.message_id, a.delay_between_responses,
				a.include_event_description, a.has_notification,
				o.name
			FROM [msdb].[dbo].[sysalerts] a
				JOIN [msdb].[dbo].[sysnotifications] n ON (n.alert_id = a.id)
				JOIN [msdb].[dbo].[sysoperators] o  ON (o.[id] = n.operator_id );

	OPEN alert_cur;

	FETCH NEXT FROM alert_cur
		INTO 
			@name, @id, @message_id, @delay_between_responses,
			@include_event_description, @has_notification,
				@Operator;

	WHILE (@@FETCH_STATUS <> -1)
		BEGIN
			SET @cmd = 'USE [msdb]
				GO
				EXEC msdb.dbo.sp_update_alert @name=N' + '''' + @name + '''' + ', ' + 
				' @message_id= ' + CONVERT(varchar(25),@message_id) + ', ' + 
				' @delay_between_responses=900, ' + 
				' @include_event_description_in = ' + CONVERT(varchar(20), @include_event_description) + ';' + CHAR(13);

			IF @has_notification = 1
				BEGIN
					IF @AddUpdate = 0 
						BEGIN
							SET @Cmd = @Cmd + ' ' + 
								' EXEC msdb.dbo.sp_add_notification @alert_name=N' + '''' + @name + '''' + 
								', @operator_name=N' + '''' + @Operator + '''' + ', @notification_method = 1';

						END
					ELSE
											BEGIN
						SET @Cmd = @Cmd + ' ' + 
								' EXEC msdb.dbo.sp_update_notification @alert_name=N' + '''' + @name + '''' + 
								', @operator_name=N' + '''' + @Operator + '''' + ', @notification_method = 1';

						END

				END

			SET @Cmd = @Cmd + CHAR(13);

			PRINT @cmd;

			FETCH NEXT FROM alert_cur
				INTO 
					@name, @id, @message_id, @delay_between_responses,
					@include_event_description, @has_notification,
					@Operator;
					
		END

	CLOSE alert_cur;

	DEALLOCATE alert_cur;



END
GO
