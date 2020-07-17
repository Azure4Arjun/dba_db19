SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba16_utl_GetConfigHistoryValuesByDatenName
--
-- Arguments:	@system_config_name nvarchar(4000), 
--				@last_modified_date datetime
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get the rows in conjfig history for a particular date and item.
-- 
-- Date			Modified By			Changes
-- 06/16/2008   Aron E. Tekulsky	Initial Coding.
-- 04/04/2012	Aron E. Tekulsky	Update to v100.
-- 03/23/2018   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba16_utl_GetConfigHistoryValuesByDatenName 
	-- Add the parameters for the stored procedure here
	@system_config_name nvarchar(4000), 
	@last_modified_date datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT system_config_name, text_value, date_value, int_value, real_value,
			money_value, prev_date_value, last_modified_date
		FROM dbo.system_config_values_history
	WHERE rtrim(system_config_name) = @system_config_name AND
			last_modified_date = @last_modified_date;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba16_utl_GetConfigHistoryValuesByDatenName TO [db_proc_exec] AS [dbo]
GO
