SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- P_dba19_sys_CalculateLastDay
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	get the last day of the month.
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
CREATE PROCEDURE P_dba19_sys_CalculateLastDay 
	-- Add the parameters for the stored procedure here
	@firstday varchar(8)--,
	--@end_date varchar(8) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	-- Declare the return variable here
	DECLARE @Result		varchar(8),
	--@start_date datetime--,
	--@start_month int,
	--@start_year int,
	@end_date			varchar(8)--,
	--@end_month int,
	--@end_day int,
	--@end_year int

	-- Add the T-SQL statements to compute the return value here
	
	--SET @start_date = convert(datetime, @firstday)
	SET @end_date = dbo.f_dba19_utl_ConvertDateTimeToString(dateadd(day,-1,(dateadd(month,1,@firstday))))
	--SELECT @Result = @firstday

	-- Return the result of the function
	SELECT @end_date as end_date



	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON P_dba19_sys_CalculateLastDay TO [db_proc_exec] AS [dbo]
GO
