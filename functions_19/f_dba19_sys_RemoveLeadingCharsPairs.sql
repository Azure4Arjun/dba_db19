USE [dba_db19]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ==============================================================================
-- f_dba19_sys_RemoveLeadingCharsPairs
--
-- Arguments:		@text_value			nvarchar(2000)
--					@search_string		nvarchar(10)
--					@replacement_string nvarchar(10)
--
-- Called BY:		None
--
-- Description:	Strip out leading characters and replace with replacement items.
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
CREATE FUNCTION [dbo].[f_dba19_sys_RemoveLeadingCharsPairs] 
(	
	-- Add the parameters for the function here
	@text_value			nvarchar(2000),
	@search_string		nvarchar(10),
	@replacement_string nvarchar(10)	
)
RETURNS nvarchar(2000) 
AS
BEGIN
    DECLARE @clean_text nvarchar(2000),
            @char_location int

	---- Add the SELECT statement with parameter references here
 --   SET @char_location = CHARINDEX('\\',@text_value, @startpos)
 --   SET @clean_text = @text_value
    
    
 --   WHILE (@char_location > 0)
	--    BEGIN
	--		IF @char_location > 0
	--		BEGIN
	--			--SET @clean_text = substring(@text_value, @char_location + 1,LEN(@text_value) -1)
	--			SET @clean_text = substring(@clean_text, @char_location+1,LEN(@clean_text) -1)
	--			SET @startpos = @char_location + 1
	--		END
			
	--		--ELSE 
	--		--	BEGIN
	--		--	SET @clean_text = @text_value
	--		--	END

	--	    SET @char_location = CHARINDEX('\\',@clean_text, @startpos)

	--	END
	--			--SET @clean_text = @text_value
	
	SET @clean_text = REPLACE (@text_value, @search_string,@replacement_string)

RETURN @clean_text

END

GO



GRANT EXECUTE ON [dbo].[f_dba19_sys_RemoveLeadingCharsPairs] TO [db_proc_exec] AS [dbo]
GO
