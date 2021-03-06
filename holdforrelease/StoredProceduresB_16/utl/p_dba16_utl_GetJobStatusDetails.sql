USE [dba_db16]
GO
/****** Object:  StoredProcedure [dbo].[p_dba08_getjobstatus_details]    Script Date: 05/05/2008 08:32:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================================
-- p_dba16_utl_GetJobStatusDetails
--
-- Arguments:	None
--				None
--
-- Called BY:	None
--
-- Description:	Get the queries with the most IO not including dba_db.
-- 
-- Date				Modified By			Changes
-- 10/07/2002   Aron E. Tekulsky	Initial Coding.
-- 04/04/2012	Aron E. Tekulsky	Update to v100.
-- 05/17/2019   Aron E. Tekulsky    Update to Version 140.
-- ===============================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================



/****** Object:  Stored Procedure dbo.p_dba08_getjobstatus_details    Script Date: 10/7/2002 3:17:02 PM ******/


/****** Object:  Stored Procedure dbo.p_dba08_getjobstatus_details    Script Date: 7/26/2002 2:18:32 PM ******/
 CREATE PROCEDURE [dbo].[p_dba16_utl_GetJobStatusDetails]  
  AS
 BEGIN
         DECLARE @end_date  char(8),
                @day        int,
                @month      int,
                @year       int,
                @end_date_date datetime

/* get today's date */
         SELECT @end_date_date = dateadd(day, -7,getdate());

         SELECT @day  = day(@end_date_date);
         SELECT @month  = month(@end_date_date);
         SELECT @year  = year(@end_date_date);
         SELECT @end_date = convert(char(2),@month) + convert(char,@day) + convert(char,@year);

	SELECT a.job_id, a.name as job_name, a.description as job_description,
			b.server, b.step_id, b.step_name,   b.message,   b.sql_severity,
			run_date=substring(convert(char, b.run_date),5,2)+'/'+substring(convert(char, b.run_date),7,2)+'/'+substring(convert(char, b.run_date),1,4),
			run_time=substring(convert(char,b.run_time),0,2)+':'+substring(convert(char,b.run_time),len(run_time)-3,2)+':'+substring(convert(char,b.run_time),len(run_time)-1,2),
			b.run_status
		FROM msdb..sysjobs a
			LEFT JOIN msdb.dbo.sysjobhistory b on  b.job_id = a.job_id
-- WHERE b.step_id >= 0
	 WHERE b.step_id > 0
	    AND cast (convert(char,b.run_date) as datetime) >= @end_date_date
		AND b.run_status = 0
	ORDER BY run_date desc, b.step_id asc, run_time desc;

END


GO
GRANT EXECUTE ON [dbo].[p_dba16_utl_GetJobStatusDetails] TO [db_proc_exec]