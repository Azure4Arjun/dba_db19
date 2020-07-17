SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- f_dba19_sys_GetFiscalMonth
--
--  Scalar_Function template
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Calculate the fiscal month.
--
-- Date			Modified By			Changes
-- 02/28/2007   Aron E. Tekulsky    Initial Coding.
-- 02/24/2018   Aron E. Tekulsky    Update to V140.
-- 05/19/2018   Aron E. Tekulsky    Update to V150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE FUNCTION f_dba19_sys_GetFiscalMonth 
(
	-- Add the parameters for the function here
	@mo int
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @fm int

	-- Add the T-SQL statements to compute the return value here
	IF @mo >= 1 and @mo <= 9
        SET @fm = @mo;
    ELSE
        SET @fm = @mo + 3 - 12;

	-- Return the result of the function
	RETURN @fm

END
GO

