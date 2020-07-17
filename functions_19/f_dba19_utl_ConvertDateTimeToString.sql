SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- f_dba19_utl_ConvertDateTimeToString
--
--  Scalar_Function template
--
-- Arguments:	@datetim datetime
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	
--
-- Date			Modified By			Changes
-- 07/24/2007   Aron E. Tekulsky    Initial Coding.
-- 04/18/2012	Aron E. Tekulsky	Update to v100.
-- 10/12/2012   Aron E. Tekulsky    Update to Version 140.
-- 05/19/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE FUNCTION f_dba19_utl_ConvertDateTimeToString 
(
	-- Add the parameters for the function here
	@datetim datetime
)
RETURNS varchar(10)
AS
BEGIN
	-- Add the T-SQL statements to compute the return value here
	DECLARE @day		char(2)
	DECLARE	@month		char(2)
	DECLARE @stringdate varchar(10)

	-- Add the T-SQL statements to compute the return value here
	SET @stringdate = datepart(yyyy,@datetim)

    SET @month = datepart(mm,@datetim)
    IF @month < 10
        BEGIN
            SET @month = '0' + @month
        END
        
    SET @stringdate = @stringdate + @month
    
    SET @day = datepart(dd,@datetim)
    IF @day < 10
        BEGIN
            SET @day = '0' + @day
        END
        
    SET @stringdate = @stringdate + @day
                         
	-- Return the result of the function
	RETURN @stringdate

END
GO

