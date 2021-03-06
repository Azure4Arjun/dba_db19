USE [dba_db08]
GO
/****** Object:  StoredProcedure [dbo].[p_dba08_stealth_getjobstatus_details_failed_multi]    Script Date: 03/05/2013 12:44:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==============================================================================
-- p_dba08_stealth_getjobstatus_details_failed_multi
--
-- Arguments:		@run_dat		nvarchar(100),
--		            @server_name	nvarchar(126)
--					None
--
-- Called BY:		None
-- Calls:			None
--
-- Description:	Stealth Edition. Get a listing of failed jobs for 
--				each database.
-- 
-- Date			Modified By			Changes
-- 10/12/2009   Aron E. Tekulsky    Initial Coding.
-- 04/19/2012	Aron E. Tekulsky	Update to v100.
-- ===============================================================================
--	Copyright©2009 - 2012 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================

 ALTER PROCEDURE [dbo].[p_dba08_stealth_getjobstatus_details_failed_multi] 
            @run_dat		nvarchar(100),
            @server_name	nvarchar(126)
 AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
          DECLARE @run_date      int,
                  @end_date_date datetime,
                  @day			 int,
                  @month	 	 int,
                  @year			 int,
                  @end_date		 int,
                  @cmd			 nvarchar(2000)

         SELECT @end_date_date = dateadd(day, -1,convert(datetime, @run_dat,112))

/* convert passed date and time from nvarchar to int */
         SELECT @run_date = convert(int, @run_dat)

         SELECT @run_date = isnull(@run_date,convert(int,getdate()))

/* get today's date */
         
--         SELECT @end_date_date = dateadd(day, -1,dbo.f_dba_convertintdatetostring(@run_date))
         SELECT @end_date = convert(int,dba_db08.dbo.f_dba08_convertdatetimetostring(@end_date_date))
         
-- a.description as job_description,
--   b.sql_severity,

SET @cmd = 'select  convert(nvarchar(1000),a.job_id) as job_id,a.name as job_name,
        b.server, b.step_id, b.step_name,   b.message,
        dba_db08.dbo.f_dba08_convertinttimetostring(b.run_time) as run_time,
        dba_db08.dbo.f_dba08_convertintdatetostring(b.run_date) as run_date,' +
        'CASE b.run_status
            WHEN 0 THEN ''Failure''
            WHEN 1 THEN ''Succes''
            WHEN 2 THEN ''Retry''
            WHEN 3 THEN ''Cancelled''
            WHEN 4 THEN ''In Progress''
        END as run_status ' + 
 'from [' + @server_name + '].msdb.dbo.sysjobs a
	left join [' + @server_name + '].msdb.dbo.sysjobhistory b on  b.job_id = a.job_id
 WHERE b.step_id > 0
    AND b.run_date <= ''' + convert(varchar(20),@run_date) +
    '''AND b.run_date >= ''' + convert(varchar(20),@end_date) +
    '''AND b.run_status = 0
 order by run_date desc, run_time asc, b.step_id asc'
 
	 print @cmd

	EXEC (@cmd)

--print @end_date_date
--print @end_date
--print @run_date

END



GO
GRANT EXECUTE ON [dbo].[p_dba08_stealth_getjobstatus_details_failed_multi] TO [db_proc_exec] AS [dbo]