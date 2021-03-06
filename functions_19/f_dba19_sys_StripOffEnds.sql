USE [dba_db19]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==============================================================================
-- f_dba19_sys_StripOffEnds
--
-- Arguments:		@string_to_parse nvarchar(1000) 
--					@leftend		 char(1)
--					@rightend		 char(1)
--
-- Called BY:		None
--
-- Description:	Strip off ends of string.
-- 
-- Date				Modified By			Changes
-- 07/21/2008   Aron E. Tekulsky    Initial Coding.
-- 04/18/2012	Aron E. Tekulsky	Update to v100.
-- 12/26/2017   Aron E. Tekulsky    Update to Version 140.
-- 05/19/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================

CREATE FUNCTION [dbo].[f_dba19_sys_StripOffEnds] 
(	
	-- Add the parameters for the function here
	@string_to_parse	nvarchar(1000), 
	@leftend			char(1),
    @rightend			char(1)
)
RETURNS nvarchar(1000) 
AS
BEGIN
--
    SET @string_to_parse = substring(@string_to_parse, charindex(@leftend, @string_to_parse)+2,len(@string_to_parse));

    SET @string_to_parse = substring(@string_to_parse, 1,charindex(@rightend, @string_to_parse)-1);

    return @string_to_parse
END


GO
GRANT EXECUTE ON [dbo].[f_dba19_sys_StripOffEnds] TO [db_proc_exec]