SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- f_dba19_utl_ConvertIntTimeToString
--
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get the time as an integer and convert to hh:mm:ss.
--
-- Date			Modified By			Changes
-- 11/28/2006   Aron E. Tekulsky    Initial Coding.
-- 03/20/2018   Aron E. Tekulsky    Update to V140.
-- 05/19/2020   Aron E. Tekulsky    Update to V150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE FUNCTION f_dba19_utl_ConvertIntTimeToString 
(
	-- Add the parameters for the function here
	@inttime int
)
RETURNS varchar(10)
AS
BEGIN
	-- Declare the return variable here
	-- Declare the return variable here
	DECLARE @stringtime varchar(10)
	DECLARE @stringhh   varchar(2)
	DECLARE @stringmm   varchar(2)
	DECLARE @stringss   varchar(2)
    DECLARE @newinttime int

-- 103106
    SELECT @newinttime = @inttime;

	-- Add the T-SQL statements to compute the return value here

    SELECT @stringss = 
        CASE len(@newinttime)
            WHEN 6 THEN 
                    substring(convert(char,@newinttime),len(@newinttime)-1, 2)
            WHEN 5 THEN 
                    substring(convert(char,@newinttime),len(@newinttime)-1, 2)
            WHEN 4 THEN 
                    substring(convert(char,@newinttime),len(@newinttime)-1, 2)
            WHEN 3 THEN
                    substring(convert(char,@newinttime),len(@newinttime)-1, 2)
            WHEN 2 THEN
                    substring(convert(char,@newinttime),len(@newinttime)-1, 2)
            WHEN 1 THEN
                    '0'+ substring(convert(char,@newinttime),len(@newinttime), 1)
         END

---- 1031
    SELECT @newinttime = (@newinttime - convert(int, @stringss))/100;

    SELECT @stringmm = 
        CASE len(@newinttime)
            WHEN 4 THEN 
                    substring(convert(char,@newinttime),len(@newinttime)-1, 2)
            WHEN 3 THEN
                    substring(convert(char,@newinttime),len(@newinttime)-1, 2)
            WHEN 2 THEN
                    substring(convert(char,@newinttime),len(@newinttime)-1, 2)
            WHEN 1 THEN
                    '0'+ substring(convert(char,@newinttime),len(@newinttime), 1)
         END

    SELECT @newinttime = (@newinttime - convert(int, @stringmm))/100;

    SELECT @stringhh = 
        CASE len(@newinttime)
            WHEN 2 THEN
                    substring(convert(char,@newinttime),len(@newinttime)-1, 2)
            WHEN 1 THEN
                    '0'+ substring(convert(char,@newinttime),len(@newinttime), 1)
            ELSE '00'
        END

SELECT @stringtime = @stringhh + ':' + @stringmm + ':' + @stringss;

	-- Return the result of the function
	RETURN @stringtime

END
GO

