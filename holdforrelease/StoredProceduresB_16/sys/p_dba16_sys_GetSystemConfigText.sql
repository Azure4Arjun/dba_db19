USE [dba_db16]
GO

/****** Object:  StoredProcedure [dbo].[p_dba16_sys_GetSystemConfigText]    Script Date: 4/8/2013 2:06:48 PM ******/
DROP PROCEDURE [dbo].[p_dba16_sys_GetSystemConfigText]
GO

/****** Object:  StoredProcedure [dbo].[p_dba16_sys_GetSystemConfigText]    Script Date: 4/8/2013 2:06:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ==============================================================================
-- p_dba16_sys_GetSystemConfigText
--
-- Arguments:	@system_config_name char(50)
--				None
--
-- Called BY:	None
--
-- Description:	get the values in the config file for text.
-- 
-- Date				Modified By			Changes
-- 10/10/2006   Aron E. Tekulsky	Initial Coding.
-- 04/04/2012	Aron E. Tekulsky	Update to v100.
-- 04/08/2013	Aron E. Tekulsky	Update to have parameter passed be 50 chars for name.
-- 05/10/2019	Aron E. Tekulsky    Update to Version 140.
-- ===============================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================


CREATE PROCEDURE [dbo].[p_dba16_sys_GetSystemConfigText]
	-- Add the parameters for the stored procedure here
	@system_config_name char(50)
AS
--BEGIN TRAN set_system_config_text


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
--	SELECT dbo.f_dba_removeleadingslash(text_value) as text_value
    SELECT  text_value
        FROM dbo.system_config_values
    WHERE system_config_name = @system_config_name

	IF @@ERROR <> 0 GOTO ErrorHandler
END

--    COMMIT TRAN set_system_config_text

RETURN 1

ErrorHandler:
--    ROLLBACK TRANSACTION set_system_config_text
    RETURN -1


GO

GRANT EXECUTE ON [dbo].[p_dba16_sys_GetSystemConfigText] TO [db_proc_exec] AS [dbo]
GO


