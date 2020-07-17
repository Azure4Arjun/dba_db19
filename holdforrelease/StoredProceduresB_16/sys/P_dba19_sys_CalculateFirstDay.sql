SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- P_dba19_sys_CalculateFirstDay
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get the first day of the month.
-- 
-- Date			Modified By			Changes
-- 03/02/2009   Aron E. Tekulsky    Initial Coding.
-- 07/27/2019   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE P_dba19_sys_CalculateFirstDay 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE
	@start_day		int,
	@start_month	int,
	@start_year		int,
	@firstday		varchar(8)
	--@end_date		varchar(8)--,
	--@end_month	int,
	--@end_day		int,
	--@end_year		int

	-- Add the T-SQL statements to compute the return value here
	
	--SET @start_date = convert(datetime, @firstday)
	SET @start_day = 1;
	SET @start_month = datepart(month,getdate());
	
	PRINT 'startmonth=' + convert(varchar(10),@start_month);
	
	SET @start_year = datepart(year,getdate());

	IF @start_month < 10 
		BEGIN
			SET @firstday = convert(varchar(4),@start_year) + '0' + convert(varchar(2),@start_month) +
					'0' + convert(varchar(2),@start_day);
		END
	
	IF @start_month >= 10 
		BEGIN
			SET @firstday = convert(varchar(4),@start_year)  + convert(varchar(2),@start_month) + '0' +
			 convert(varchar(2),@start_day);
		END

	-- Return the result of the function
	SELECT @firstday as firstday;



	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO

GRANT EXECUTE ON P_dba19_sys_CalculateFirstDay TO [db_proc_exec] AS [dbo]
GO
