SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==============================================================================
-- f_dba19_sys_GetFiscalYear
--
-- Arguments:		@yr int
--					@mo int
--
-- Called BY:		None
--
-- Description:	Calculate the fiscal year.
-- 
-- Date				Modified By			Changes
-- 02/28/2007   Aron E. Tekulsky    Initial Coding.
-- 04/18/2012	Aron E. Tekulsky	Update to v100.
-- 12/26/2017   Aron E. Tekulsky    Update to Version 140.
-- 05/19/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================

CREATE FUNCTION f_dba19_sys_GetFiscalYear 
(
	-- Add the parameters for the function here
	@yr int, @mo int
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @fy int

	-- Add the T-SQL statements to compute the return value here
	IF @mo >= 1 and @mo <= 9
        SET @fy = @yr
    ELSE
        SET @fy = @yr + 1

	-- Return the result of the function
	RETURN @fy

END
GO

GRANT EXECUTE ON [dbo].[f_dba19_sys_GetFiscalYear] TO [db_proc_exec]
GO
