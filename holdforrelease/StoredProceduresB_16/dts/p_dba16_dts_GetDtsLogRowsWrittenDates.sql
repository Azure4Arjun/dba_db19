USE [dba_db16]
GO
/****** Object:  StoredProcedure [dbo].[p_dba16_dts_GetDtsLogRowsWrittenDates]    Script Date: 10/03/2007 13:07:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==============================================================================
-- p_dba16_dts_GetDtsLogRowsWrittenDates
--
-- Arguments:	dbname		nvarchar(4000) - cdr
--				@servernam	nvarchar(4000) - usnysqlcl2
--				@source		nvarchar(1024) - string to search for 
--				None
--
-- CallS:		None
--
--
-- Called BY:	None
--
-- Description:	Get the dates of rows written to each table by ssis.
-- 
-- Date				Modified By			Changes
-- 02/14/2007   Aron E. Tekulsky	initial Coding.
-- 08/16/2007	Aron E. Tekulsky	Add source to query.
-- 04/04/2012	Aron E. Tekulsky	Update to v100.
-- 05/17/2019   Aron E. Tekulsky    Update to Version 140.
-- ===============================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================

 CREATE PROCEDURE [dbo].[p_dba16_dts_GetDtsLogRowsWrittenDates] 
	-- Add the parameters for the stored procedure here
    @dbname nvarchar(4000),
    @servernam nvarchar(4000),
    @source nvarchar(1024)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   DECLARE @sql_source	nvarchar(1024)
   DECLARE @sql_to_exec	nvarchar(4000)

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

    IF @source is NULL OR @source = ''
        SET @sql_source = '';
    ELSE    
        SET @sql_source = ' and d.source like (''%' + @source + '%'')';

--    SET @sql_to_exec = 'select top (15) dba_db.dbo.f_dba_convertdatetimetostring(starttime)as indate, dba_db.dbo.f_dba_convertdatetimetostring(endtime) as outdate' + 
    SET @sql_to_exec = 'SET rowcount 8 select dba_db16.dbo.f_dba16_convertdatetimetostring(starttime)as indate, dba_db08.dbo.f_dba16_convertdatetimetostring(endtime) as outdate' + 
           ' FROM ' + 
            @servernam  + 
            @dbname + '.dbo.sysdtslog90 d ' +
        'WHERE d.event = ' +  '''OnInformation''' + ' and 
            charindex(' + '''component''' + ',d.message,0) > 0 and ' +
            'charindex(' + '''rows''' + ' ,d.message,0) > 0 and ' +
            'charindex(' + '''wrote''' + ',d.message,0) > 0 ' + 
        @sql_source + ' '+
        'GROUP BY dba_db16.dbo.f_dba16_convertdatetimetostring(starttime), dba_db16.dbo.f_dba16_convertdatetimetostring(endtime)' +
        'ORDER BY indate desc ' + 'set rowcount 0'

-- execute the dynamic sql
	EXEC  (@sql_to_exec);

	PRINT @sql_to_exec;
--print @servernam

END
GO
GRANT EXECUTE ON [dbo].[p_dba16_dts_GetDtsLogRowsWrittenDates] TO [db_proc_exec]
GO