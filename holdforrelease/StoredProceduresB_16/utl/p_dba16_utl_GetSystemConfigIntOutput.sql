SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba16_utl_GetSystemConfigIntOutput
--
-- Arguments:	@system_config_name char(50)
--				@return_value		int output
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	set the values in the config file for int.
-- 
-- Date			Modified By			Changes
-- 10/10/2006   Aron E. Tekulsky	Initial Coding.
-- 07/25/2007   Aron E. Tekulsky	Modified version to send results back as output variable.
-- 04/04/2012	Aron E. Tekulsky	Update to v100.
-- 04/08/2013	Aron E. Tekulsky	Update to have parameter passed be 50 chars for name.
-- 06/17/2019   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba16_utl_GetSystemConfigIntOutput 
	-- Add the parameters for the stored procedure here
	@system_config_name char(50),
	@return_value int output 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @return_value = (SELECT int_value
        FROM dbo.system_config_values
    WHERE system_config_name = @system_config_name)

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba16_utl_GetSystemConfigIntOutput TO [db_proc_exec] AS [dbo]
GO
