USE [dba_db19]
GO

/****** Object:  UserDefinedFunction [dbo].[f_dba08_get_semicolon]    Script Date: 06/21/2011 09:28:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================================
-- f_dba19_utl_GetSemicolon
--
-- Arguments:		@stringtocheck nvarchar(1000)
--					None
--
-- Called BY:		None
--
-- Description:	look for semi colon in string.
-- 
-- Date				Modified By			Changes
-- 07/16/2009   Aron E. Tekulsky    Initial Coding.
-- 04/18/2012	Aron E. Tekulsky	Update to v100.
-- 12/26/2017   Aron E. Tekulsky    Update to Version 140.
-- 05/19/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================

CREATE FUNCTION [dbo].[f_dba19_utl_GetSemicolon] 
(
	-- Add the parameters for the function here
	@stringtocheck nvarchar(1000)
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @location	int,
			@Result		int
			

	-- Add the T-SQL statements to compute the return value here
	--SELECT @location = charindex(';', @stringtocheck)
	SELECT @Result = charindex(';', @stringtocheck)

	-- Return the result of the function
	RETURN @Result

END

GO

GRANT EXECUTE ON [dbo].[f_dba19_utl_GetSemicolon] TO [db_proc_exec] AS [dbo]
GO

GRANT REFERENCES ON [dbo].[f_dba19_utl_GetSemicolon] TO [db_proc_exec] AS [dbo]
GO


