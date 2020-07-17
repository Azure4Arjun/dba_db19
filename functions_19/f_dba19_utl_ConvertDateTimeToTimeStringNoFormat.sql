USE [dba_db19]
GO

/****** Object:  UserDefinedFunction [dbo].[f_dba08_convertdatetimetotimestringnoformat]    Script Date: 09/22/2009 14:50:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ======================================================================================
-- f_dba19_utl_ConvertDateTimeToTimeStringNoFormat
--
-- Arguments:		@datetim datetime
--					None
--
-- Calls:			None
--
-- Called BY:		None
--
-- Description:	Get the date as a datetime and convert to hh:mm:ss.
-- 
-- Date				Modified By			Changes
-- 01/21/2009	Aron E. Tekulsky    Initial Coding.
-- 04/18/2012	Aron E. Tekulsky	Update to v100.
-- 12/16/2017	Aron E. Tekulsky	Update to v140.
-- 05/19/2020	Aron E. Tekulsky	Update to v150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================

CREATE FUNCTION [dbo].[f_dba19_utl_ConvertDateTimeToTimeStringNoFormat] 
(
	-- Add the parameters for the function here
	@datetim datetime
)
RETURNS varchar(10)
--RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @day		char(2),
	        @month		char(2),
			@stringdate varchar(10)
	        

	-- Add the T-SQL statements to compute the return value here
	SET @stringdate = datepart(hh,@datetim)
    IF @stringdate < 10
        BEGIN
            SET @stringdate = '0' + @stringdate
        END

    SET @month = datepart(mi,@datetim)
    IF @month < 10
        BEGIN
            SET @month = '0' + @month
        END
        
    SET @stringdate = @stringdate + @month
    
    SET @day = datepart(ss,@datetim)
    IF @day < 10
        BEGIN
            SET @day = '0' + @day
        END
        
    SET @stringdate = @stringdate + @day
                         
	-- Return the result of the function
	RETURN @stringdate

END


GO

GRANT EXECUTE ON [dbo].[f_dba19_utl_ConvertDateTimeToTimeStringNoFormat] TO [db_proc_exec]
GO

