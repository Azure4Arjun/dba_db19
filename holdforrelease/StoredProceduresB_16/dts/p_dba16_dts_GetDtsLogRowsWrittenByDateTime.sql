USE [dba_db16]
GO
/****** Object:  StoredProcedure [dbo].[p_dba16_dts_GetDtsLogRowsWrittenByDateTime]    Script Date: 10/02/2007 11:46:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==============================================================================
-- p_dba16_dts_GetDtsLogRowsWrittenByDateTime
--
-- Arguments:	@startdatetime	nvarchar(50)   - 01/01/1900 00:00:00.000
--				@enddatetime	nvarchar(50)   - 01/01/1900 00:00:00.000
--				@dbname			nvarchar(4000) - cdr
--				@servernam		nvarchar(4000) - usnysqlcl2
--				@source			nvarchar(1024) - string to search for 
--				@tim			nvarchar(50)   - hour of run
--				None
--
-- CallS:		None
--
--
-- Called BY:	None
--
-- Description:	Get the number of rows written to each table by ssis.
--
-- Date				Modified By			Changes
-- 02/14/2007   Aron E. Tekulsky  Initial Coding.
-- 04/04/2012	Aron E. Tekulsky	Update to v100.
-- 05/17/2019   Aron E. Tekulsky    Update to Version 140.
-- ===============================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================

CREATE PROCEDURE [dbo].[p_dba16_dts_GetDtsLogRowsWrittenByDateTime] 
	-- Add the parameters for the stored procedure here
	@startdatetime nvarchar(50), 
	@enddatetime nvarchar(50),
    @dbname nvarchar(4000),
    @servernam nvarchar(4000),
    @source nvarchar(1024),
--    @tim    datetime
    @tim    nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @local_startdatetime	datetime
    DECLARE @sql_to_exec			nvarchar(4000)
    DECLARE @sql_source				nvarchar(1024)
    DECLARE @tim_int				int
--    @aron nvarchar(1000)

-- check for parameters and substitute defaults if no values sent
    IF @startdatetime IS NULL OR @startdatetime = ''
        SET @startdatetime = dateadd(dd,-1,convert(varchar(50),getdate(),101));
--    ELSE
--        BEGIN
--            SET @local_startdatetime = dba_db.dbo.f_dba_convertintdatetostring(convert(int,@startdatetime))
--        END

-- convert the time hours to an interger for addition
    SET @tim_int = convert(int,@tim);

-- add the hours    
    SET @local_startdatetime = dateadd(hh,@tim_int,convert(datetime,@startdatetime));

-- if user did not supply a databse name then use dba_db
    IF @dbname is NULL OR @dbname = ''
        SET @dbname = DB_NAME();
--    ELSE
--        SET @dbname = '"' + @dbname + '"'

-- if user supplied a linked servername then add the period after the name
    IF @servernam IS not NULL and @servernam = ''
        SET @servernam = @servernam + '.';
	ELSE
        SET @servernam = ' ';


    IF @source is NULL 
        SET @sql_source = '';
    ELSE    
        SET @sql_source = ' and d.source like (''%' + @source + '%'')';

    -- Insert statements for procedure here
    SET @sql_to_exec = 'SELECT d.source, d.message, substring(d.message, charindex(' + 
             '''wrote''' +
         ',d.message, 0)+5,charindex(' + '''rows''' + 
         ',d.message, 0) - charindex(' + '''wrote''' + 
         ',d.message, 0)-5) as numrows,' + 
        ' substring(d.message,  ' + 
          '(charindex(' + '''"''' + ',d.message, 2)+1), ' +
          '(charindex(' + '''(''' + ',d.message, 0) - charindex(' +  '''"''' + ',d.message, 2)-3)) as tablen' +
        ',' +
            'd.starttime, d.endtime ' +
	', datediff(day, ''Aug  9 2007 12:00AM'', d.starttime)' +
             'FROM ' + 
--            'd.starttime, ' + @local_startdatetime +' as endtime
--            'cdr.dbo.sysdtslog90 d
            @servernam  + 
            @dbname + '.dbo.sysdtslog90 d
        WHERE d.event = ' + '''OnInformation''' + ' AND
            charindex(' + '''component''' + ',d.message,0) > 0 and ' +
            'charindex(' + '''rows''' + ',d.message,0) > 0 and ' +
--            'charindex(' + '''wrote''' + ',d.message,0) > 0 ' 
            'charindex(' + '''wrote''' + ',d.message,0) > 0 and ' 


-- create the dynamic sql
	 IF  @enddatetime IS NULL or @enddatetime = ''
--    BEGIN
        SET @enddatetime = dateadd(dd,1,convert(varchar(50),getdate(),101));

--        SET @sql_to_exec = @sql_to_exec +
--             ' datediff(day, ''' + @startdatetime + ''',d.starttime) >= 0 ' 
--ELSE
    SET @sql_to_exec = @sql_to_exec + 
         ' datediff(day, ''' + @startdatetime + ''', d.starttime) >= 0' +
         ' and datediff(day, ''' + @enddatetime + ''' ,d.endtime) <= 0' ;

-- time check
    SET @sql_to_exec = @sql_to_exec + ' and datediff(hh,''' + convert(varchar(50),@local_startdatetime) + ''',
             d.starttime) = 0';

-- add the sort
    SET @sql_to_exec = @sql_to_exec + 
          @sql_source +
         ' order by d.source asc, tablen asc, d.starttime asc';

--print @aron

-- execute the dynamic sql
	EXEC  (@sql_to_exec);

--print @sql_to_exec
--print @servernam
--print @startdatetime 
--print @enddatetime 
--print @local_startdatetime

END
GO
GRANT EXECUTE ON [dbo].[p_dba16_dts_GetDtsLogRowsWrittenByDateTime] TO [db_proc_exec]
GO
