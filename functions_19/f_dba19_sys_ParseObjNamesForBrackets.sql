SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==============================================================================
-- f_dba19_sys_ParseObjNamesForBrackets
--
-- Arguments:		@p1 int
--					None
--
-- Called BY:		None
--
-- Description:	Parse a string to remove brackets and send back the individual names only.
-- 
-- Date				Modified By			Changes
-- 03/02/2012   Aron E. Tekulsky    Initial Coding.
-- 04/18/2012	Aron E. Tekulsky	Update to v100.
-- 12/26/2017   Aron E. Tekulsky    Update to Version 140.
-- 05/19/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================

CREATE FUNCTION f_dba19_sys_ParseObjNamesForBrackets 
(
	-- Add the parameters for the function here
	@p1 int
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result int
    DECLARE @clean_text			nvarchar(2000),
            @char_location		int,
            @start_pos			int


	-- Add the T-SQL statements to compute the return value here
	
	SET @char_location = CHARINDEX('[',@p1,@start_pos)
	SELECT @Result = @p1

	-- Return the result of the function
	RETURN @Result

END
GO

GRANT EXECUTE ON [dbo].[f_dba19_sys_ParseObjNamesForBrackets] TO [db_proc_exec]
GO
