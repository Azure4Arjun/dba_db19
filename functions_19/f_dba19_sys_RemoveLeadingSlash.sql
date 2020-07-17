SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==============================================================================
-- f_dba19_sys_RemoveLeadingSlash
--
-- Arguments:		@text_value nvarchar(2000)
--					None
--
-- Called BY:		None
--
-- Description:	Strip out leading /.
-- 
-- Date				Modified By			Changes
-- 07/27/2007   Aron E. Tekulsky    Initial Coding.
-- 04/18/2012	Aron E. Tekulsky	Update to v100.
-- 12/26/2017   Aron E. Tekulsky    Update to Version 140.
-- 05/19/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================

CREATE FUNCTION f_dba19_sys_RemoveLeadingSlash 
(	
	-- Add the parameters for the function here
	@text_value nvarchar(2000)
)
RETURNS nvarchar(2000) 
AS
BEGIN
    DECLARE @clean_text nvarchar(2000),
            @char_location int

	-- Add the SELECT statement with parameter references here
    SET @char_location = CHARINDEX('//',@text_value)
    
    IF @char_location > 0
	    SET @clean_text = substring(@text_value, 2,LEN(@text_value) -1)
    ELSE 
        SET @clean_text = @text_value

RETURN @clean_text

END
GO
GRANT EXECUTE ON [dbo].[f_dba19_sys_RemoveLeadingSlash] TO [db_proc_exec]
GO
