SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==============================================================================
-- f_dba19_utl_GetFrequencyInDays
--
-- Arguments:		None
--					None
--
-- Called BY:		None
--
-- Description:	Returns the frequency interval as a list of days.
-- 
-- Date				Modified By			Changes
-- 11/28/2006   Aron E. Tekulsky    Initial Coding.
-- 04/18/2012	Aron E. Tekulsky	Update to v100.
-- 12/26/2017   Aron E. Tekulsky    Update to Version 140.
-- 05/19/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================

CREATE FUNCTION f_dba19_utl_GetFrequencyInDays 
(
	-- Add the parameters for the function here
	@freq_interval int
)
RETURNS varchar(25)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @freq_days				varchar(25),
            @freq_interval_local	int

    -- intiialize
    SELECT @freq_days = ''
    SELECT @freq_interval_local = @freq_interval


	-- Add the T-SQL statements to compute the return value here
    --IF @freq_interval <= 64 and @freq_interval > 0 -- regular tabel lookup for 1 day
 --       BEGIN
   --         SELECT @freq_days = freq_interval_description
     --       FROM dbo.dba_sys_sched_freq_interval
       --     WHERE freq_interval = @freq_interval
  --      END
    --ELSE -- multiple days
            IF @freq_interval_local >= 64 
                    BEGIN
                       SELECT @freq_days = @freq_days + ' S'
                       SELECT @freq_interval_local = @freq_interval_local - 64
                    END
            IF @freq_interval_local >= 32 
                    BEGIN
                       SELECT @freq_days = @freq_days + ' F'
                       SELECT @freq_interval_local = @freq_interval_local - 32
                    END
            IF @freq_interval_local >= 16 
                    BEGIN
                       SELECT @freq_days = @freq_days + ' H'
                       SELECT @freq_interval_local = @freq_interval_local - 16
                    END
            IF @freq_interval_local >= 8 
                    BEGIN
                       SELECT @freq_days = @freq_days + ' W'
                       SELECT @freq_interval_local = @freq_interval_local - 8
                    END
            IF @freq_interval_local >= 4 
                    BEGIN
                       SELECT @freq_days = @freq_days + ' T'
                       SELECT @freq_interval_local = @freq_interval_local - 4
                    END
            IF @freq_interval_local >= 2 
                    BEGIN
                       SELECT @freq_days = @freq_days + ' M'
                       SELECT @freq_interval_local = @freq_interval_local - 2
                    END
            IF @freq_interval_local >= 1 
                    BEGIN
                       SELECT @freq_days = @freq_days + ' U'
                       SELECT @freq_interval_local = @freq_interval_local - 1
                    END
	-- Return the result of the function
	RETURN @freq_days

END
GO

GRANT EXECUTE ON [dbo].[f_dba19_utl_GetFrequencyInDays] TO [db_proc_exec]
GO
