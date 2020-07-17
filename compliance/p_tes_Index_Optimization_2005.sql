--USE [test]
--GO
/****** Object:  StoredProcedure [dbo].p_tes_Index_Optimization_2005    Script Date: 03/09/2009 11:51:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_WARNINGS ON
GO
/******************************************************************************
**		 
**		Name: p_tes_Index_Optimization_2005
**		Desc: It rebuilds or reorganize indexes for all databases of a server
              It selects all indexes with > 10 fragmentation for a particular db 
              and if frag > 30 then it Rebuilds index ONLINE OR
                  if frag < 30 then it Reorganize index
                  
--This code is designed for SQL Server 2005 or above..
**		Parameters:
**								
**		Auth: 
**		Date: 
*******************************************************************************/
ALTER PROCEDURE p_tes_Index_Optimization_2005
AS

CREATE table #Temp (id int identity, name varchar(80), dbStatus nvarchar(128))

INSERT INTO #TEMP(name,dbstatus)
SELECT Name,state_desc Status
		FROM	sys.databases
		WHERE	name NOT IN ('master', 'model', 'msdb', 'tempdb')
		AND state_desc = 'ONLINE'
		--AND    is_read_only <> 1 --means database=in read only mode
        order by state_desc desc
--select * from #Temp 
--drop table #temp 
Declare @Var int
Declare @name varchar(200)
Declare @dbid varchar(100)
--Declare @commandline varchar(4000)
set @var  = 1
While @var <= (select count(*) from #Temp)  
Begin
select @name= db_id(name) from #temp where id =@var 
set @dbid = @name
print 'This is database name '+ db_name(@name)
--Create Table #work_to_do table (obj_id int, index_id tinyint,partition_no tinyint, fragm int)
--Declare @name varchar(200)
--Declare @commandline varchar(4000)
--set @name = db_id('IIE_DM_FINANCE_OIG')
--select * from  sys.dm_db_index_physical_stats (10, NULL, NULL , NULL, 'LIMITED')
--order by object_id avg_fragmentation_in_percent desc */
 SELECT
    object_id AS objectid,
    index_id AS indexid,
    partition_number AS partitionnum,
    avg_fragmentation_in_percent AS frag
INTO #work_to_do
FROM sys.dm_db_index_physical_stats (@dbid, NULL, NULL , NULL, 'LIMITED')
WHERE avg_fragmentation_in_percent > 10.0 AND index_id > 0;
--EXEC (@commandline)
--select * from #work_to_do
--print @commandline

--print db_name(@name)
--drop table #work_to_do
--SET NOCOUNT ON;
DECLARE @objectid int;
DECLARE @indexid int;
DECLARE @partitioncount bigint;
DECLARE @schemaname nvarchar(130); 
DECLARE @objectname nvarchar(130); 
DECLARE @indexname nvarchar(130); 
DECLARE @partitionnum bigint;
DECLARE @partitions bigint;
DECLARE @frag float;
DECLARE @command nvarchar(4000); 
-- Conditionally select tables and indexes from the sys.dm_db_index_physical_stats function 
-- and convert object and index IDs to names.

-- Declare the cursor for the list of partitions to be processed.
DECLARE partitions CURSOR FOR 
SELECT * FROM #work_to_do;

-- Open the cursor.
OPEN partitions;

-- Loop through the partitions.
WHILE (1=1)
    BEGIN
        FETCH NEXT
           FROM partitions
           INTO @objectid, @indexid, @partitionnum, @frag;
        IF @@FETCH_STATUS < 0 BREAK;
        SELECT @objectname = QUOTENAME(o.name), @schemaname = QUOTENAME(s.name)
        FROM sys.objects AS o
        JOIN sys.schemas as s ON s.schema_id = o.schema_id
        WHERE o.object_id = @objectid;
        Print @objectname
        
        SELECT @indexname = QUOTENAME(name)
        FROM sys.indexes
        WHERE  object_id = @objectid AND index_id = @indexid;
        Print @indexname
        
        SELECT @partitioncount = count (*)
        FROM sys.partitions
        WHERE object_id = @objectid AND index_id = @indexid;
        Print @partitioncount

-- 30 is an arbitrary decision point at which to switch between reorganizing and rebuilding.
        IF @frag < 30.0
        Begin
            SET @command = N'USE '+db_name(@Dbid)+' ALTER INDEX ' + @indexname + N' ON ' + @schemaname + N'.' + @objectname + N' REORGANIZE'
            Print @command
        End    
        IF @frag >= 30.0
        Begin
            SET @command = N'USE '+db_name(@Dbid)+' ALTER INDEX ' + @indexname + N' ON ' + @schemaname + N'.' + @objectname + N' REBUILD WITH (ONLINE = ON,FillFactor =90)'
            --N'ALTER INDEX ' + @indexname + N' ON ' + @schemaname + N'.' + @objectname + N' REBUILD WITH (ONLINE = ON)';
            Print @command
        End    
        IF @partitioncount > 1
        Begin
            SET @command = @command + N' PARTITION=' + CAST(@partitionnum AS nvarchar(10));
            Print @frag
            Print @command
        End    
        EXEC (@command);
      PRINT N'Executed: ' + @command;
  
    END;

-- Close and deallocate the cursor.
CLOSE partitions;
DEALLOCATE partitions;

-- Drop the temporary table.
DROP TABLE #work_to_do;
Set @var =@var +1
End

--DROP TABLE #Temp

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_WARNINGS OFF
GO

