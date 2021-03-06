USE [dba_db19]
GO
/****** Object:  UserDefinedFunction [dbo].[f_dba08_get_job_numberofruns_byname]    Script Date: 01/13/2009 13:44:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==============================================================================
-- f_dba19_utl_GetJobNumberOfRunsByName
--
-- Arguments:		@jobname	nvarchar(128)
--					@numdays	int
--					@thedate	int
--					None
--
-- Called BY:		None
--
-- Description:	Get the number of runs.
-- 
-- Date				Modified By			Changes
-- 01/12/2009   Aron E. Tekulsky    Initial Coding.
-- 04/18/2012	Aron E. Tekulsky	Update to v100.
-- 12/26/2017   Aron E. Tekulsky    Update to Version 140.
-- 05/19/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================

CREATE FUNCTION [dbo].[f_dba19_utl_GetJobNumberOfRunsByName] 
(
	-- Add the parameters for the function here
	@jobname nvarchar(128),
	@numdays int,
	@thedate int
)
RETURNS int
AS
BEGIN

	DECLARE @current_date	int,
			@day			char(2),
			@enddate		int,
			@month			char(2),
			@startdate		int,
			@year			char(4)
	
	-- Declare the return variable here
	DECLARE @Result int

	-- Add the T-SQL statements to compute the return value here
	
	IF @numdays = 1 
		BEGIN
		-- find month start and end
			SET @month = substring(convert(char(8),@thedate),5,2)
			SET @year = substring(convert(char(8),@thedate),1,4)
		--SET @startdate = convert(int,(@year + @month + '01'))
			SET @startdate = @year + @month + '01'
		
		-- get last day of month
			SELECT  @day = CASE 
				WHEN @month in(9,4,6,11)
					THEN '30'
				WHEN @month in (1,3,5,7,8,10,12)
					THEN '31'
				ELSE '28'
			END 
			SET @enddate = @year + @month + @day
		END
	ELSE
		BEGIN
		-- use same date for start and end
			SET @startdate = @thedate
			SET @enddate = @startdate
		END
	-- get the date as int

	SELECT @Result = count(*) 
		FROM msdb.dbo.sysjobs j
			JOIN msdb.dbo.sysjobhistory h ON (h.job_id = j.job_id)
	WHERE j.name = @jobname AND
		h.step_id = 0 AND
		--h.run_date >= 20090111 AND
		--h.run_date <= 20090111
		h.run_date >= @startdate AND
		h.run_date <= @enddate
	GROUP BY j.name

--PRInt 'testign :' + convert(varchar(100),@Result)

	-- Return the result of the function
	RETURN @Result

END
GO
GRANT EXECUTE ON [dbo].[f_dba19_utl_GetJobNumberOfRunsByName] TO [db_proc_exec]
GO
