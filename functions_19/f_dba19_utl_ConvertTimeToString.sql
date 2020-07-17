SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- f_dba19_utl_ConvertTimeToString
--
--  Scalar_Function template
--
-- Arguments:	@datetoconvert datetime
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	convert time to string.
--
-- Date			Modified By			Changes
-- 11/18/2008   Aron E. Tekulsky    Initial Coding.
-- 04/18/2012	Aron E. Tekulsky	Update to v100.
-- 10/25/2017   Aron E. Tekulsky    Update to Version 140.
-- 05/19/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE FUNCTION f_dba19_utl_ConvertTimeToString 
(
	-- Add the parameters for the function here
	@datetoconvert datetime
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result varchar(32)

	-- Add the T-SQL statements to compute the return value here
--	SELECT @Result = @datetoconvert

	DECLARE @ziptime varchar(32)
	DECLARE @timelen int, @timeleft varchar(32), @delimpos int, @startpos int
	DECLARE @stringtime varchar(32)

	SET @ziptime = convert(varchar(32), @datetoconvert -1, 114)

-- get the length
	SET @timelen = len(@ziptime)

-- save the value
	SET @timeleft = @ziptime

-- set initial value
	SET @startpos = 1
	SET @stringtime = ''

	-- get posiotn of delimeter
	SET @delimpos = charindex(':',@timeleft)

-- begin loop
	WHILE @delimpos > 0
		BEGIN

	-- extract time part
			SET @stringtime = @stringtime + substring(@timeleft, @startpos, @delimpos-1)

			SET @timeleft = substring(@timeleft,@delimpos +1,@timelen )
	
	-- get posiotn of delimeter
			SET @delimpos = charindex(':',@timeleft)

		END

	SET @Result = @stringtime

	-- Return the result of the function
	RETURN @Result

END
GO
GRANT EXECUTE ON [dbo].[f_dba19_utl_ConvertTimeToString] TO [db_proc_exec] AS [dbo]
GO

GRANT REFERENCES ON [dbo].[f_dba19_utl_ConvertTimeToString] TO [db_proc_exec] AS [dbo]
GO
