SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba16_utl_GetSystemConfigMoneyOutput
--
-- Arguments:	@system_config_name char(30)
--				@return_value real OUTPUT
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get the values in the config file for money.
-- 
-- Date			Modified By			Changes
-- 12/14/2007   Aron E. Tekulsky	Initial Coding.
-- 04/04/2012	Aron E. Tekulsky	Update to v100.
-- 03/04/2018   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba16_utl_GetSystemConfigMoneyOutput 
	-- Add the parameters for the stored procedure here
	@system_config_name char(30),
    @return_value real OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @return_value = (SELECT money_value
        FROM dbo.system_config_values
    WHERE system_config_name = @system_config_name);

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba16_utl_GetSystemConfigMoneyOutput TO [db_proc_exec] AS [dbo]
GO
