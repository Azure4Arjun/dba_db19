USE [dba_db19]
GO

/****** Object:  UserDefinedFunction [dbo].[f_dba08_convertdatetimetostringyear]    Script Date: 12/04/2008 15:45:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- f_dba19_utl_ConvertDateTimeToStringYear
--
-- Arguments:		@datetim datetime
--					None
--
-- Calls:			None
--
-- Called BY:		None
--
-- Description:	Get the date's year as a datetime and convert to yyyy.
-- 
-- Date				Modified By			Changes
-- 07/24/2007   Aron E. Tekulsky    Initial Coding.
-- 04/18/2012	Aron E. Tekulsky	Update to v100.
-- 12/16/2017	Aron E. Tekulsky	Update to v140.
-- 05/19/2020	Aron E. Tekulsky	Update to v150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================

CREATE FUNCTION [dbo].[f_dba19_utl_ConvertDateTimeToStringYear] 
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
	SET @stringdate = datepart(yyyy,@datetim)

    --SET @month = datepart(mm,@datetim)
    --IF @month < 10
    --    BEGIN
    --        SET @month = '0' + @month
    --    END
        
    --SET @stringdate = @stringdate + @month
    
    --SET @day = datepart(dd,@datetim)
    --IF @day < 10
    --    BEGIN
    --        SET @day = '0' + @day
    --    END
        
    --SET @stringdate = @stringdate + @day
                         
	-- Return the result of the function
	RETURN @stringdate

END

GO

GRANT EXECUTE ON [dbo].[f_dba19_utl_ConvertDateTimeToStringYear] TO [db_proc_exec] AS [dbo]
GO

GRANT REFERENCES ON [dbo].[f_dba19_utl_ConvertDateTimeToStringYear] TO [db_proc_exec] AS [dbo]
GO


