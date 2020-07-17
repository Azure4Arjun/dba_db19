SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ======================================================================================
-- f_dba19_utl_ConvertIntDateToString
--
-- Arguments:		@intdate int
--					None
--
-- Calls:			None
--
-- Called BY:		None
--
-- Description:	Get the date as an integer and convert to mm/dd/yyyy.
-- 
-- Date				Modified By			Changes
-- 11/28/2006   Aron E. Tekulsky	Initial Coding.
-- 04/18/2012	Aron E. Tekulsky	Update to v100.
-- 12/16/2017	Aron E. Tekulsky	Update to v140.
-- 05/19/2020	Aron E. Tekulsky	Update to v150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================

CREATE FUNCTION f_dba19_utl_ConvertIntDateToString 
(
	-- Add the parameters for the function here
	@intdate int
)
RETURNS varchar(10)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @stringdate varchar(10)

	-- Add the T-SQL statements to compute the return value here
	SELECT @stringdate = substring(convert(char,@intdate),5,2)+'/'+
                         substring(convert(char,@intdate),7,2)+'/'+
                         substring(convert(char,@intdate),1,4)
	-- Return the result of the function
	RETURN @stringdate

END
GO

GRANT EXECUTE ON [dbo].[f_dba19_utl_ConvertIntDateToString] TO [db_proc_exec]
GO
