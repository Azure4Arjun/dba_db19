USE [dba_db08]
GO

/****** Object:  StoredProcedure [dbo].[p_dba08_stealth_get_jobstatdetfailmlt]    Script Date: 6/1/2016 1:17:44 PM ******/
DROP PROCEDURE [dbo].[p_dba08_stealth_get_jobstatdetfailmlt]
GO

/****** Object:  StoredProcedure [dbo].[p_dba08_stealth_get_jobstatdetfailmlt]    Script Date: 6/1/2016 1:17:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ==============================================================================
-- p_dba08_stealth_get_jobstatdetfailmlt
--
-- Arguments:		@server_name	nvarchar(126),
--					@run_dat		nvarchar(100)
--					None
--
-- Called BY:		None
-- Calls:			None
--
-- Description:	cr.
-- 
-- Date			Modified By			Changes
-- 10/14/2009   Aron E. Tekulsky    Initial Coding.
-- 04/19/2012	Aron E. Tekulsky	Update to v100.
-- 06/01/2016	Aron E. Tekulsky	update sysmsg to nvc 4000.
-- ===============================================================================
--	Copyright©2009 - 2012 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================

CREATE PROCEDURE [dbo].[p_dba08_stealth_get_jobstatdetfailmlt] 
	-- Add the parameters for the stored procedure here
    @server_name	nvarchar(126),
	@run_dat		nvarchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
          DECLARE @run_date				int,
                  @end_date_date		datetime,
                  @day					int,
                  @month	 			int,
                  @year					int,
                  @end_date				int,
                  @cmd					nvarchar(4000),
                  @run_date_datetime	datetime,
                  @start_date_char		varchar(20),
				  @end_date_char		varchar(20),
				  @start_date_int		int,
				  @end_date_int			int,
				  @testdate				int,
				  @cmd2					nvarchar(4000)
--print 'testing'


			DECLARE @failedjobstable TABLE (
			        job_id		nvarchar(1000),
			        job_name    nvarchar(128),
			        server		nvarchar(128),
			        step_id		int,
			        step_name	nvarchar(128),
			        sqlmsg		nvarchar(4000),
			        run_time	int,
			        run_date	int,
			        run_status	nvarchar(25)
					)			
					
         ------SELECT @end_date_date = dateadd(day, -1,convert(datetime, isnull(@run_dat,getdate()),112))
         SELECT @end_date_date = dateadd(day, -1,getdate())
         --SET @end_date_char =  convert(varchar(20),@end_date_date)
		 --SET @end_date_int = convert(int,@end_date_date)
		 
		 SET @end_date_int = convert(int,dba_db08.dbo.f_dba08_convertdatetimetostring(@end_date_date))
         SET @end_date_char =  convert(varchar(20),@end_date_int)

/* convert passed date and time from nvarchar to int */
         ----SELECT @run_date = convert(int, @run_dat)

         ----SELECT @run_date = isnull(@run_date,convert(int,getdate()))
         --SELECT @run_date = isnull(@run_dat,getdate())
         
         ----SET @run_date_datetime = convert(datetime, @run_date)
         ------SET @run_date_datetime = convert(datetime, isnull(@run_dat,getdate()))
         
         SET @run_date_datetime = convert(datetime,getdate(),112)
         --SET @start_date_char = convert(varchar(20),@run_date_datetime)
         --SET @start_date_int = convert(int,@run_date_datetime)
         
         SET @start_date_int = convert(int,dba_db08.dbo.f_dba08_convertdatetimetostring(getdate()))
         SET @start_date_char = convert(varchar(20),@start_date_int)
         
         --SET @testdate = convert(int,dba_db.dbo.f_dba_convertdatetimetostring(getdate()))
         print @start_date_char
         print @end_date_char
      
--print 'testing2'
/* get today's date */
         
--         SELECT @end_date_date = dateadd(day, -1,dbo.f_dba_convertintdatetostring(@run_date))
         --SELECT @end_date = convert(int,dba_db.dbo.f_dba_convertdatetimetostring(@end_date_date))
         
-- a.description as job_description,
--   b.sql_severity,

	IF @server_name IS NULL OR @server_name = ''
		SET @server_name = @@servername 

--print @start_date_char + ' to ' + @end_date_char

--print 'testing3'

    set @cmd = 'select convert(nvarchar(1000),a.job_id) as job_id,a.name as job_name  ' +
			   ',b.server ' + 
			   ',b.step_id ' +
			   ', b.step_name' + ', b.message as sqlmsg ' +
 			   	--,dba_db.dbo.f_dba_convertinttimetostring(b.run_time) as run_time 
			    --,dba_db.dbo.f_dba_convertintdatetostring(b.run_date) as run_date 
			    ',b.run_time, b.run_date' +
			    ', CASE b.run_status
				    WHEN 0 THEN ''Failure''
					WHEN 1 THEN ''Succes''
					WHEN 2 THEN ''Retry''
				    WHEN 3 THEN ''Cancelled''
			        WHEN 4 THEN ''In Progress''
				END as run_status ' +
 ' from [' + @server_name + '].msdb.dbo.sysjobs a
			   	left join [' + @server_name + '].msdb.dbo.sysjobhistory b on  b.job_id = a.job_id 
			 WHERE b.step_id > 0 ' +
				' AND b.run_date <= convert (int,''' + @start_date_char  + ''')'+
		        ' AND b.run_date >= convert (int,''' + @end_date_char  + ''')' +
		     ' AND b.run_status = 0' +
			' order by run_date desc, run_time asc, b.step_id asc'

 
	 print @cmd

	INSERT INTO @failedjobstable
	EXEC (@cmd)

	SELECT job_id,
			        job_name,
			        server,
			        step_id,
			        step_name,
			        sqlmsg,
			        run_time,
			        run_date,
			        run_status
				FROM  @failedjobstable 

END








GO

GRANT EXECUTE ON [dbo].[p_dba08_stealth_get_jobstatdetfailmlt] TO [db_proc_exec] AS [dbo]
GO


