USE [dba_db19]
GO
/****** Object:  UserDefinedFunction [dbo].[f_dba08_get_sqlversion_platform]    Script Date: 07/25/2008 15:01:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==============================================================================
-- f_dba19_sys_GetSqlVersionPlatform
--
-- Arguments:		None
--					None
--
-- Called BY:		None
--
-- Description:	Get SQl version platform.
-- 
-- Date				Modified By			Changes
-- 07/25/2008   Aron E. Tekulsky    Initial Coding.
-- 04/18/2012	Aron E. Tekulsky	Update to v100.
-- 12/26/2017   Aron E. Tekulsky    Update to Version 140.
-- 05/19/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================

CREATE FUNCTION [dbo].[f_dba19_sys_GetSqlVersionPlatform]
(
	-- Add the parameters for the function here
)
RETURNS nvarchar(4)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result nvarchar(4)

	-- Add the T-SQL statements to compute the return value here
    SET @Result = substring(@@VERSION,patindex('%(%',@@VERSION), 5 )

	-- Return the result of the function
	RETURN @Result

END

GO
GRANT EXECUTE ON [dbo].[f_dba19_sys_GetSqlVersionPlatform] TO [db_proc_exec]