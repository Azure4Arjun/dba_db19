SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_mnt_DMGetFragmentation
--
--
-- Calls:		None
--
-- Description:	List database keys and fragmentation.
-- 
-- Date			Modified By			Changes
-- 10/27/2010   Aron E. Tekulsky    Initial Coding.
-- 04/05/2012	Aron E. Tekulsky	Update to Version 100.
-- 06/14/2016	Aron E. Tekulsky	Increase size form 80 to 1000 for 
--									dbname in temp table.
-- 06/21/2016	Aron E. Tekulsky	Modify 	@CurrentCommandSelect01 & 
--									@CurrentCommandSelect02 to nvc(4000)
-- 02/18/2018   Aron E. Tekulsky    Update to Version 140.
-- 08/24/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
--
--  This code and information are provided "AS IS" without warranty of
--  any kind, either expressed or implied, including but not limited
--  to the implied warranties of merchantability and/or fitness for a
--  particular purpose.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    DECLARE @CurrentCommandSelect01	nvarchar(4000)
	DECLARE @CurrentCommandSelect02	nvarchar(4000)
    DECLARE @CurrentDatabase		nvarchar(1000)
    DECLARE @CurrentSchemaID		int
    DECLARE @CurrentObjectID		int
    DECLARE @CurrentIndexID			int
    DECLARE @CurrentIndexType		int
    DECLARE @CurrentSchemaName		nvarchar(250)
    DECLARE @CurrentObjectName		nvarchar(250)
    DECLARE @CurrentIndexName		nvarchar(250)
    DECLARE @dbname					nvarchar(1000)
    DECLARE @CurrentIndexTypeDesc	nvarchar(250)
    DECLARE @allowrowlocks			bit
	DECLARE @allowpagelocks			bit
    
	DECLARE @alwayson				int

    CREATE TABLE #tmp_indexes (
          dbnam						nvarchar(1000),
          schemaid					int,
          schemaname				nvarchar(250),
          objectid					int,
          objectname				nvarchar(250),
          indexid					int,
          indexname					nvarchar(250),
          indextype					int,
          indexhold					int,
		  indextypedesc				nvarchar(60),
		  allowrowlocks				bit,
		  allowpagelocks			bit,
          partnm					int,
		  avgfrag					numeric(10,3),
		  disposit					varchar(100),
		  alloc_unit_type_desc		varchar(100),
		  index_level				int

          )

    TRUNCATE TABLE #tmp_indexes;
          
-- create table to hold db names
    CREATE table #Temp (
          id						int identity,
		  name						nvarchar(1000), 
		  dbStatus					nvarchar(128))

	IF ISNULL(CONVERT(int,serverproperty('IsHadrEnabled')), 0) = 1 
		SET @alwayson = 1;

	------------	 @Result = s.[role]
	------------	FROM [master].[sys].[dm_hadr_availability_replica_states] s
	------------		JOIN sys.databases d ON (s.replica_id = d.replica_id )
	------------WHERE d.name = @dbname;

-- populate table with db names
	IF @alwayson = 1
		BEGIN

			INSERT INTO #TEMP(name,dbstatus)
				SELECT d.Name,d.state_desc Status
					FROM sys.databases d
						JOIN [master].[sys].[dm_hadr_availability_replica_states] s ON (s.replica_id = d.replica_id)
				WHERE d.name NOT IN ('master', 'model', 'msdb', 'tempdb')
					AND d.state_desc = 'ONLINE'
				--AND name in ('iie_enterprise')--'iie_enterprise','iiedb1')
					AND    d.is_read_only <> 1 --means database=in read only mode
					AND CHARINDEX('-',d.name) = 0 AND -- no dashes in dbname
					 s.[role] = 1
				order by name asc;
		END
	ELSE 
		BEGIN
			INSERT INTO #TEMP(name,dbstatus)
				SELECT Name,state_desc Status
					FROM sys.databases
				WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb')
					AND state_desc = 'ONLINE'
				--AND name in ('iie_enterprise')--'iie_enterprise','iiedb1')
					AND    is_read_only <> 1 --means database=in read only mode
					AND CHARINDEX('-',name) = 0 --AND-- no dashes in dbname
				order by name asc;
		END

--select *
--from sys.databases where name NOT IN ('master', 'model', 'msdb', 'tempdb')
--			order by name asc;

	SELECT * FROM #TEMP;

-- cursor for db
	DECLARE db_cur CURSOR FOR
			SELECT name
			FROM #TEMP;
			
	OPEN db_cur;
		
	FETCH NEXT FROM db_cur
			INTO @CurrentDatabase;
          
          --set @CurrentDatabase = 'iie_enterprise'
          
    WHILE (@@FETCH_STATUS <> -1)
		BEGIN
          
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
				' FROM ' +
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
		--from tmp_indexes
      
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
			FROM tmp_indexes;

			OPEN idx_cur;
	
			FETCH NEXT FROM idx_cur 
				INTO @dbname, @CurrentSchemaID,@CurrentSchemaName, @CurrentObjectID, @CurrentObjectName, @CurrentIndexID,@CurrentIndexName, @CurrentIndexType, @CurrentIndexTypeDesc;

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
						WHERE s.index_id > 0 

					FETCH NEXT FROM idx_cur 
						INTO @dbname, @CurrentSchemaID,@CurrentSchemaName, @CurrentObjectID, @CurrentObjectName, @CurrentIndexID,@CurrentIndexName, @CurrentIndexType, @CurrentIndexTypeDesc;
				END

			--SELECT *
			--	FROM tmp_indexes
			--WHERE disposit <> 'Good'


			--TRUNCATE TABLE tmp_indexes;
			CLOSE idx_cur;
			DEALLOCATE idx_cur;

			FETCH NEXT FROM db_cur
				INTO @CurrentDatabase;

		END

	CLOSE db_cur;
	DEALLOCATE db_cur;
	
	SELECT dbnam,schemaid, schemaname, objectid, objectname, indexid, indexname, indextype, 
          indexhold, partnm, avgfrag, disposit, alloc_unit_type_desc, index_level
	FROM #tmp_indexes;
	--------WHERE disposit <> 'Good'

	DROP TABLE #Temp;
	DROP TABLE #tmp_indexes;
	


	------------IF @@ERROR <> 0 GOTO ErrorHandler

	------------RETURN 1

	------------ErrorHandler:
	------------RETURN -1 
END
GO
