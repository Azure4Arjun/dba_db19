USE [dba_db19]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==============================================================================
-- f_dba19_sys_RunDuration
--
-- Arguments:		@thedate	int
--					@jobname	nvarchar(128)
--					@numdays	int
--
-- Called BY:		None
--
-- Description:	Run durations.
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

create FUNCTION [dbo].[f_dba19_sys_RunDuration] 
(
	-- Add the parameters for the function here
	@thedate	int,
	@jobname	nvarchar(128),
	@numdays	int--,
	--@run_item int 	-- 0 average
					-- 1 min
					-- 2 max
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result			int,
	--		@avg			int,
	--		@max			int,
	--		@min			int,
			@startdate		int,
			@enddate		int,
			@month			char(2),
			@day			char(2),
			@year			char(4)


	-- Add the T-SQL statements to compute the return value here
	IF @numdays = 1 
		BEGIN
		-- find month start and end
			SET @month = substring(convert(char(8),@thedate),5,2)
			SET @year = substring(convert(char(8),@thedate),1,4)
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

	SELECT @Result = h.run_duration 
		FROM msdb.dbo.sysjobs j
			JOIN msdb.dbo.sysjobhistory h ON (h.job_id = j.job_id)
	WHERE j.name = @jobname AND
		h.step_id = 0 AND
		h.run_date >= @startdate AND
		h.run_date <= @enddate

	-- Return the result of the function
	
	RETURN @Result

END
GO
GRANT EXECUTE ON [dbo].[f_dba19_sys_RunDuration] TO [db_proc_exec]
GO
