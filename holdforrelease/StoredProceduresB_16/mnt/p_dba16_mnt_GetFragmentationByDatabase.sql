USE [dba_db16]
GO

/****** Object:  StoredProcedure [dbo].[p_dba16_mnt_GetFragmentationByDatabase]    Script Date: 6/28/2016 2:15:45 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- ==============================================================================
-- p_dba16_mnt_GetFragmentationByDatabase
--
-- Arguments:		@dbname	nvarchar(1000)
--					None
--
-- Called BY:		p_dba16_mnt_GetFragmentationDatabaseList
--
-- Calls:			p_dba16_mnt_SetFragmentationFix
--
-- Description:	list database keys and fragmentation 
-- 
-- Date				Modified By			Changes
-- 10/27/2010   Aron E. Tekulsky	Initial Coding.
-- 04/05/2012	Aron E. Tekulsky	Update to v100.
-- 06/28/2016	Aron E. Tekulsky	Update to v120.
-- 06/28/2016	Aron E. Tekulsky	Increase size form 80 to 1000 for 
--									name in temp table.
-- 06/28/2016	Aron E. Tekulsky	Modify 	@CurrentCommandSelect01 to nvc(4000)
--									and add test for always on.
-- 01/30/2018	Aron E. Tekulsky    Update to V140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================


CREATE PROCEDURE [dbo].[p_dba16_mnt_GetFragmentationByDatabase] 
	-- Add the parameters for the stored procedure here
	@dbname	nvarchar(1000)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @allowrowlocks				bit
	DECLARE @allowpagelocks				bit
    DECLARE	@AvgFrag					numeric(10,3)
    DECLARE @CurrentCommandSelect01		nvarchar(4000)
	--DECLARE @CurrentCommandSelect02	nvarchar(2000)
    DECLARE @CurrentDatabase			nvarchar(1000)
    DECLARE @CurrentSchemaID			int
    DECLARE @CurrentObjectID			int
    DECLARE @CurrentIndexID				int
    DECLARE @CurrentIndexType			int
    DECLARE @CurrentSchemaName			nvarchar(250)
    DECLARE @CurrentObjectName			nvarchar(250)
    DECLARE @CurrentIndexName			nvarchar(250)
    DECLARE @CurrentPartnm				int
    DECLARE @CurrentIndextypedesc		nvarchar(128)

    --DECLARE @dbname					nvarchar(250)
          
    CREATE TABLE #tmp_indexes (
          dbnam							nvarchar(1000),
          schemaid						int,
          schemaname					nvarchar(250),
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
    
    --TRUNCATE TABLE dbo.#tmp_indexes;
                   
    -- set current database to the value passed in
    SET @CurrentDatabase = @dbname;
          
  --  WHILE (@@FETCH_STATUS <> -1)
		--BEGIN
          
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
      
		--  select *
		--from #tmp_indexes
      
	DECLARE idx_cur CURSOR FOR
		SELECT dbnam,
				schemaid,
				schemaname,
				objectid,
				objectname,
				indexid,
				indexname,
				indextype,
				indextypedesc
			FROM #tmp_indexes;

	OPEN idx_cur;
	
	FETCH NEXT FROM idx_cur 
			INTO @dbname, @CurrentSchemaID,@CurrentSchemaName, @CurrentObjectID, @CurrentObjectName, @CurrentIndexID,@CurrentIndexName, @CurrentIndexType, @CurrentIndextypedesc;

	WHILE (@@FETCH_STATUS <> -1)
		BEGIN     
      		UPDATE #tmp_indexes
      			SET partnm               = s.partition_number,
      				avgfrag              = s.avg_fragmentation_in_percent,
      				alloc_unit_type_desc = s.alloc_unit_type_desc,
      				index_level          = s.index_level,
      				disposit             = 
					CASE 
						WHEN s.avg_fragmentation_in_percent <= 5.0 THEN 'Good'
						WHEN s.avg_fragmentation_in_percent <= 30.0 THEN 'Reorganize'
						ELSE 'Rebuild'
						END
					FROM sys.dm_db_index_physical_stats (db_id(@dbname), @CurrentObjectID, @CurrentIndexID , null, 'LIMITED') s
							JOIN #tmp_indexes t ON (db_id(t.dbnam) = s.database_id) AND
														(t.objectid = s.object_id) AND
														(t.indexid = s.index_id)
						WHERE s.index_id > 0 AND s.alloc_unit_type_desc = 'IN_ROW_DATA';

			FETCH NEXT FROM idx_cur 
						INTO @dbname, @CurrentSchemaID,@CurrentSchemaName, @CurrentObjectID, @CurrentObjectName, @CurrentIndexID,@CurrentIndexName, @CurrentIndexType, @CurrentIndextypedesc;
		END

		SELECT *
			FROM #tmp_indexes
		WHERE disposit <> 'Good';


			--TRUNCATE TABLE #tmp_indexes;

		CLOSE idx_cur;
		DEALLOCATE idx_cur;

	--		FETCH NEXT FROM db_cur
	--			INTO @CurrentDatabase;

	--	END

	--DEALLOCATE db_cur;
	
	-- do the actual index update
	
	DECLARE idx_upd_cur CURSOR FOR
		SELECT dbnam, schemaid, schemaname, objectid, objectname, indexid, indexname, 
          indextype, partnm, avgfrag,--, disposit, alloc_unit_type_desc, index_level
   		  allowrowlocks, allowpagelocks

		FROM #tmp_indexes
		WHERE disposit <> 'Good';
	
	OPEN idx_upd_cur;
	
	FETCH NEXT FROM idx_upd_cur
		INTO @dbname, @CurrentSchemaID,@CurrentSchemaName, @CurrentObjectID, @CurrentObjectName, @CurrentIndexID,@CurrentIndexName,
			 @CurrentIndexType, @CurrentPartnm, @AvgFrag, @allowrowlocks, @allowpagelocks;

	WHILE (@@FETCH_STATUS <> -1)
		BEGIN
		-- call procedure to fix index
		
			--IF @allowpagelocks = 1 
			--	BEGIN
					EXEC dba_db16.dbo.p_dba16_mnt_SetFragmentationFix @dbname, @CurrentSchemaID, @CurrentSchemaName, @CurrentObjectID, @CurrentObjectName, @CurrentIndexID,@CurrentIndexName,
													@CurrentPartnm, @AvgFrag
				--END
				PRINT 'the index is ' + @CurrentIndexName
				
			FETCH NEXT FROM idx_upd_cur
				INTO @dbname, @CurrentSchemaID,@CurrentSchemaName, @CurrentObjectID, @CurrentObjectName, @CurrentIndexID,@CurrentIndexName,
					@CurrentIndexType, @CurrentPartnm, @AvgFrag, @allowrowlocks, @allowpagelocks;

		END
		
	CLOSE idx_upd_cur;
	DEALLOCATE idx_upd_cur;


	--DROP TABLE #Temp;
	DROP TABLE #tmp_indexes;
	

END




--GO
GRANT EXECUTE ON [dbo].[p_dba16_mnt_GetFragmentationByDatabase] TO [db_proc_exec] AS [dbo]


GO

GRANT TAKE OWNERSHIP ON [dbo].[p_dba16_mnt_GetFragmentationByDatabase] TO [db_proc_exec] AS [dbo]
GO

GRANT VIEW DEFINITION ON [dbo].[p_dba16_mnt_GetFragmentationByDatabase] TO [db_proc_exec] AS [dbo]
GO


