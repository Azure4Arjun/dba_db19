USE [dba_db16]
GO
/****** Object:  StoredProcedure [dbo].[p_dba16_dts_GetDtsLogInfoByDate]    Script Date: 06/29/2007 14:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================================
-- p_dba16_dts_GetDtsLogInfoByDate
--
-- Arguments:	@startdatetime	varchar(50)
--				@enddatetime	varchar(50)
--				@dbname			nvarchar(4000),
--				@servernam		nvarchar(4000),
--				@source			nvarchar(1024)
--
-- CallS:		None
--
--
-- Called BY:	None
--
-- Description:	Review all errors for a job by date.
-- 
-- Date				Modified By			Changes
-- 02/12/2007   Aron E. Tekulsky	Initial Coding.
-- 04/04/2012	Aron E. Tekulsky	Update to v100.
-- 05/17/2019   Aron E. Tekulsky    Update to Version 140.
-- ===============================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================

CREATE PROCEDURE [dbo].[p_dba16_dts_GetDtsLogInfoByDate]
	-- Add the parameters for the stored procedure here
	@startdatetime varchar(50), 
--------	@startdatetime datetime, 
	@enddatetime varchar(50),
    @dbname nvarchar(4000),
    @servernam nvarchar(4000),
    @source nvarchar(1024)


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @return_code		int
	DECLARE @sql_to_exec		nvarchar(4000)
	DECLARE @sql_source			nvarchar(1024)
	DECLARE @startdatetime_time datetime

-- check for parameters and substitute defaults if no values sent
	IF @startdatetime is NULL
		BEGIN
			SET @startdatetime = convert(varchar(50),getdate(),101);
			-- now convert it to real datetime
			SET @startdatetime_time = convert(datetime, @startdatetime,101);
		END
	ELSE
		BEGIN
			SET @startdatetime_time = convert(datetime, @startdatetime, 110);
		END

	-- if user did not supply a databse name then use dba_db
	IF @dbname is NULL
		SET @dbname = DB_NAME();

	-- if user supplied a linked servername then add the period after the name
	IF @servernam IS not NULL
		SET @servernam = @servernam + '.';
	ELSE	
		SET @servernam = '';


	IF @source is NULL 
		SET @sql_source = ' and d.source like (''%' + 'a' + '%'')';
	ELSE
	    SET @sql_source = ' and d.source like (''%' + @source + '%'')';

	-- create the dynamic sql
	IF  @enddatetime IS NULL 
		SET @sql_to_exec = 'SELECT d.id, d.event, d.source, d.message,d.starttime, d.endtime ' 
					 +' FROM ' + @servernam  + @dbname + '.dbo.sysdtslog90 d
				            where datediff(day, ' + '''' + @startdatetime + '''' + ', d.starttime) >= 0 ' + 'and
					            d.event in (' + '''OnWarning''' + ',' + 
						        '''Diagnostic''' + ',' + '''OnInformation''' + ') 
							    ' + @sql_source +
								'order by d.starttime asc';

	ELSE
		SET @sql_to_exec = 'SELECT d.id, d.event, d.source, d.message,d.starttime, d.endtime '
---- + ',2' + 
----				' ,datediff(day, ' + ''''+ @startdatetime + ''''+ ', d.starttime )' +
----								',datediff(day, ' + '''' + @enddatetime + '''' + ', d.endtime)  ' 
							+ ' FROM ' + @servernam + @dbname + '.dbo.sysdtslog90 d
			                WHERE datediff(day, ' + '''' + @startdatetime + '''' + ', d.starttime) >= 0 ' + 'AND
					                d.event in (' + '''OnWarning''' + ',' + 
									'''Diagnostic''' + ',' + '''OnInformation''' + ') ' +
									@sql_source + 'AND
									datediff(day, ' + '''' + @enddatetime + '''' + ', d.endtime) <= 0 ' +
                            'ORDER BY d.starttime ASC'

	-- execute the dynamic sql
	EXEC  (@sql_to_exec);

	PRINT @sql_to_exec;
	PRINT @startdatetime;
	PRINT @startdatetime_time;
END

error_handler:
    IF @@ERROR <> 0
        PRINT N'error ' + cast(@return_code as nvarchar(8));

		GO
		GRANT EXECUTE ON [dbo].[p_dba16_dts_GetDtsLogInfoByDate] TO [db_proc_exec]
GO
