SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_GetJobScheduleDetailsFailed
--
--
-- Calls:		None
--
-- Description:	Get sa list of job scheduler items that failed.
-- 
-- Date			Modified By			Changes
-- 02/08/2016   Aron E. Tekulsky    Initial Coding.
-- 01/02/2018   Aron E. Tekulsky    Update to V140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

        DECLARE @end_date_date	varchar(10)
        DECLARE @end_date		int
        DECLARE @run_dat		varchar(10)
        DECLARE @run_date		int

		SET @run_dat = Convert(varchar(10),getdate(),112);

        SELECT @end_date_date = convert(varchar(10),(dateadd(day, -3,convert(datetime,@run_dat,112))),112);

/* cONvert passed date and time FROM nvarchar to int */
        SELECT @run_date = convert(int, @run_dat);

        SELECT @run_date = isnull(@run_date,cONvert(int,getdate()));

/* get today's date */
         
		SET @end_date = @end_date_date;

		  --PRINT 'run date *' + convert(varchar(200),@run_date)
		  --PRINT 'run date end *' + convert(varchar(200),@end_date)

		SELECT convert(nvarchar(4000),a.job_id) as job_id, a.name as job_name,
-- a.descriptiON as job_descriptiON,
			b.server, b.step_id, b.step_name,   b.message,
			b.run_time, b.run_date,
--   b.sql_severity,
			CASE b.run_status
				WHEN 0 THEN 'Failure'
			    WHEN 1 THEN 'Succes'
				WHEN 2 THEN 'Retry'
				WHEN 3 THEN 'Cancelled'
		        WHEN 4 THEN 'In Progress'
			END as run_status
			FROM msdb..sysjobs a
				LEFT JOIN msdb.dbo.sysjobhistory b ON  b.job_id = a.job_id
		WHERE b.step_id > 0
			AND b.run_date <= @run_date
			AND b.run_date >= @end_date
			AND b.run_status = 0 AND
			a.name NOT IN ('collection_set_4_noncached_collect_and_upload','syspolicy_purge_history')
		ORDER BY run_date DESC, run_time ASC, b.step_id ASC;




END
GO
