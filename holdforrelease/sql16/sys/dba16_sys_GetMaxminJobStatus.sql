SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_GetMaxminJobStatus
--
--
-- Calls:		None
--
-- Description:	Get a listing of maximum and Minimumn job status.
-- 
-- Date			Modified By			Changes
-- 05/08/2013   Aron E. Tekulsky    Initial Coding.
-- 10/22/2017   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyrightę2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	SELECT j.name, convert(date, CAST(MAX(h.run_date) AS CHAR(12)), 101) AS maxrundate,
		MAX(h.run_time)  AS maxruntime, 
		convert(date, CAST(MIN(h.run_date)AS CHAR(12)), 101) AS minrundate, MIN(h.run_time) AS minruntime
		FROM msdb.dbo.sysjobs AS j 
			INNER JOIN msdb.dbo.sysjobhistory AS h ON j.job_id = h.job_id
	WHERE (h.step_id = 0)
	GROUP BY j.name;
END
GO
