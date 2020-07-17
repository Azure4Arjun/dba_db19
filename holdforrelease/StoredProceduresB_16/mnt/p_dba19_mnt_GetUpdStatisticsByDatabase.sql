USE [dba_db19]
GO

/****** Object:  StoredProcedure [dbo].[p_dba19_mnt_GetUpdStatisticsByDatabase]    Script Date: 10/21/2016 3:02:19 PM ******/
DROP PROCEDURE [dbo].[p_dba19_mnt_GetUpdStatisticsByDatabase]
GO

/****** Object:  StoredProcedure [dbo].[p_dba19_mnt_GetUpdStatisticsByDatabase]    Script Date: 10/21/2016 3:02:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ==============================================================================
-- p_dba19_mnt_GetUpdStatisticsByDatabase
--
-- Arguments:		@dbname	nvarchar(128)
--					None
--
-- Called BY:		p_dba19_mnt_GetUpdStatisticsDatabaseList
--
-- Calls:			p_dba19_mnt_SetUpdStatistics
--
-- Description:	list database keys and statistics
-- 
-- Date				Modified By		Changes
-- 10/27/2010   Aron E. Tekulsky    Initial Coding.
-- 04/16/2012	Aron E. Tekulsky	Update to v100.
-- 06/21/2016	Aron E. Tekulsky	Update @CurrentCommandSelect01 to nvc(4000)
-- 01/30/2018   Aron E. Tekulsky    Update to V140.
-- 05/19/2020   Aron E. Tekulsky    Update to V150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================

CREATE PROCEDURE [dbo].[p_dba19_mnt_GetUpdStatisticsByDatabase] 
	-- Add the parameters for the stored procedure here
	@dbname	nvarchar(128)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE	@AvgFrag					numeric(10,3)
    DECLARE @allowrowlocks				bit
	DECLARE @allowpagelocks				bit
    DECLARE @CurrentCommandSelect01		nvarchar(4000)
    DECLARE @CurrentDatabase			nvarchar(128)
    DECLARE @CurrentSchemaID			int
    DECLARE @CurrentObjectID			int
    DECLARE @CurrentIndexID				int
    DECLARE @CurrentIndexType			int
    DECLARE @CurrentSchemaName			nvarchar(128)
    DECLARE @CurrentObjectName			nvarchar(128)
    DECLARE @CurrentIndexName			nvarchar(250)
    DECLARE @CurrentPartnm				int
    DECLARE @CurrentIndextypedesc		nvarchar(128)

         
    CREATE TABLE #tmp_indexes (
          dbnam							nvarchar(128),
          schemaid						int,
          schemaname					nvarchar(128),
          objectid						int,
          objectname					nvarchar(250),
          indexid						int,
          indexname						nvarchar(250),
          indextype						int,
          indexhold						int,
          partnm						int,
		  avgfrag						numeric(10,3),
		  disposit						varchar(100),
		  alloc_unit_type_desc			varchar(100),
		  index_level					int,
		  indextypedesc					nvarchar(60),
		  allowrowlocks					bit,
		  allowpagelocks				bit
          )
                       
    -- set current database to the value passed in
    set @CurrentDatabase = @dbname
                   
    SET @CurrentCommandSelect01 = ' INSERT INTO #tmp_indexes ' +
	          '(dbnam,schemaid,schemaname,objectid,objectname, indexid,indexname,indextype,indexhold, indextypedesc, allowrowlocks, allowpagelocks) ' +
		      'SELECT  ' +  '''' + @CurrentDatabase  + '''' +' , ' + QUOTENAME(@CurrentDatabase) + '.sys.schemas.[schema_id], ' +
				QUOTENAME(@CurrentDatabase) + '.sys.schemas.[name] as schemaname, ' + 
				QUOTENAME(@CurrentDatabase) + '.sys.objects.[object_id], ' + 
				 QUOTENAME(@CurrentDatabase) + '.sys.objects.[name], ' + 
				 QUOTENAME(@CurrentDatabase) + '.sys.indexes.index_id, ' + 
				 QUOTENAME(@CurrentDatabase) + '.sys.indexes.[name], ' + 
				 QUOTENAME(@CurrentDatabase) + '.sys.indexes.[type], 0, ' +
 				 QUOTENAME(@CurrentDatabase) + '.sys.indexes.[type_desc], ' +
 				 QUOTENAME(@CurrentDatabase) + '.sys.indexes.[allow_row_locks], ' +
 				 QUOTENAME(@CurrentDatabase) + '.sys.indexes.[allow_page_locks] ' +
					'FROM ' +
				 + QUOTENAME(@CurrentDatabase) + '.sys.indexes INNER JOIN ' + 
				 QUOTENAME(@CurrentDatabase) + '.sys.objects ON ' + QUOTENAME(@CurrentDatabase) + '.sys.indexes.[object_id] = ' + QUOTENAME(@CurrentDatabase) + '.sys.objects.[object_id] INNER JOIN ' +
				  QUOTENAME(@CurrentDatabase) + '.sys.schemas ON ' + QUOTENAME(@CurrentDatabase) + '.sys.objects.[schema_id] = ' + QUOTENAME(@CurrentDatabase) + '.sys.schemas.[schema_id] ' +
				  'WHERE ' +
				   QUOTENAME(@CurrentDatabase) + '.sys.objects.[type] = ''U'' AND ' + 
				   QUOTENAME(@CurrentDatabase) + '.sys.objects.is_ms_shipped = 0 AND ' + 
				   QUOTENAME(@CurrentDatabase) + '.sys.indexes.[type] IN(1,2) AND ' +
				    QUOTENAME(@CurrentDatabase) + '.sys.indexes.is_disabled = 0 AND ' + 
				    QUOTENAME(@CurrentDatabase) + '.sys.indexes.is_hypothetical = 0 ORDER BY ' +
			     QUOTENAME(@CurrentDatabase) + '.sys.schemas.[schema_id] ASC, ' + QUOTENAME(@CurrentDatabase) + '.sys.objects.[object_id] ASC, ' + QUOTENAME(@CurrentDatabase) + '.sys.indexes.index_id ASC';

	PRINT @CurrentCommandSelect01;
      
	EXEC (@CurrentCommandSelect01);
      
	SELECT *
		FROM #tmp_indexes;


--	 do the actual index update
	
	DECLARE idx_upd_cur CURSOR FOR
		SELECT dbnam, schemaname, objectid, objectname
		FROM #tmp_indexes;
	
	OPEN idx_upd_cur;
	
	FETCH NEXT FROM idx_upd_cur
		INTO @dbname, @CurrentSchemaName,  @CurrentObjectID, @CurrentObjectName;

	WHILE (@@FETCH_STATUS <> -1)
		BEGIN
--		 call procedure to fix index
		
			EXEC dba_db19.dbo.p_dba19_mnt_SetUpdStatistics @dbname,  @CurrentSchemaName, @CurrentObjectID, @CurrentObjectName;
			
			PRINT 'the table is [' + @CurrentObjectName + ']';
				
			FETCH NEXT FROM idx_upd_cur
				INTO @dbname, @CurrentSchemaName, @CurrentObjectID, @CurrentObjectName;

		END
		
	CLOSE idx_upd_cur;
	DEALLOCATE idx_upd_cur;


	DROP TABLE #tmp_indexes;
	

END







GO


