USE [dba_db19]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ==============================================================================
-- f_dba19_utl_ConvertDateTimeToTimeStringMS
--
-- Arguments:		@datetim datetime
--					None
--
-- Called BY:		None
--
-- Description:	Get the date as a datetime and convert to hh:mm:ss MS.
-- 
-- Date				Modified By			Changes
-- 01/21/2009   Aron E. Tekulsky    Initial Coding.
-- 04/18/2012	Aron E. Tekulsky	Update to v100.
-- 08/12/2016	Aron E. Tekulsky	Add Miliseconds.
-- 08/12/2016	Aron E. Tekulsky	Update to v120.
-- 12/26/2017   Aron E. Tekulsky    Update to V140.
-- 05/19/2020   Aron E. Tekulsky    Update to V150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================

CREATE FUNCTION [dbo].[f_dba19_utl_ConvertDateTimeToTimeStringMS] 
(
	-- Add the parameters for the function here
	@datetim datetime
)
RETURNS varchar(15)
--RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @stringdate varchar(15),
	        @month		char(2),
	        @day		char(2),
			@ms			char(10)--,
			--@mcs		char(10),
			--@ns			char(10)

	-- Add the T-SQL statements to compute the return value here
	SET @stringdate = datepart(hh,@datetim)
    IF @stringdate < 10
        BEGIN
            SET @stringdate = '0' + @stringdate;
        END

    SET @month = datepart(mi,@datetim)
    IF @month < 10
        BEGIN
            SET @month = '0' + @month;
        END
        
    SET @stringdate = @stringdate + ':' + @month
    
    SET @day = datepart(ss,@datetim)
    IF @day < 10
        BEGIN
            SET @day = '0' + @day;
        END
        
    SET @stringdate = @stringdate + ':' + @day

    SET @ms = datepart(ms,@datetim)
    IF @ms < 10
        BEGIN
            SET @ms = '0' + @ms;
        END
        
    SET @stringdate = @stringdate + '.' + @ms;

    --SET @mcs = datepart(mcs,@datetim)
    --IF @mcs < 10
    --    BEGIN
    --        SET @mcs = '0' + @mcs
    --    END
        
    --SET @stringdate = @stringdate + '' + @mcs

    --SET @ns = datepart(ns,@datetim)
    --IF @ns < 10
    --    BEGIN
    --        SET @ns = '0' + @ns
    --    END
        
    --SET @stringdate = @stringdate + ':' + @ns
                         
	-- Return the result of the function
	RETURN @stringdate

END


GO

GRANT EXECUTE ON [dbo].[f_dba19_utl_ConvertDateTimeToTimeStringMS] TO [db_proc_exec] AS [dbo]
GO

GRANT VIEW DEFINITION ON [dbo].[f_dba19_utl_ConvertDateTimeToTimeStringMS] TO [db_proc_exec] AS [dbo]
GO


