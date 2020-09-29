SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_idx_GetListAllObjectsnIndexesBN
--
--
-- Calls:		None
--
-- Description:	List all Objects and Indexes.
--
-- https://basitaalishan.com/2013/03/03/list-all-objects-and-indexes-per-filegroup-partition/
-- 
-- Date			Modified By			Changes
-- 07/29/2019   Aron E. Tekulsky    Initial Coding.
-- 07/29/2019   Aron E. Tekulsky    Update to Version 140.
-- 07/30/2019	Aron E. Tekulsky	Add mount points that items are on.
-- 08/21/2020   Aron E. Tekulsky    Update to Version 150.
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

	DECLARE @Cmd				NVARCHAR(4000)
	DECLARE @DBId				int	-- testing
	DECLARE @DBName				NVARCHAR(128)
	DECLARE @DBNametoFind		NVARCHAR(128)

	DECLARE @ObjectsnPartitions TABLE (
			ServerName			nvarchar(128),
			DBName				nvarchar(128),
			ObjectName			nvarchar(128),
			IndexID				int,
			IndexName			nvarchar(128),
			----IndexType			tinyint,	-- 0 = Heap, 1 = Clustered, 2 = Nonclustered, 3 = XML, 4 = Spatial, 5 = Clustered columnstore index. Applies to: SQL Server 2014 (12.x) through SQL Server 2017.
			IndexType			nvarchar(128),	-- 0 = Heap, 1 = Clustered, 2 = Nonclustered, 3 = XML, 4 = Spatial, 5 = Clustered columnstore index. Applies to: SQL Server 2014 (12.x) through SQL Server 2017.
										-- 6 = Nonclustered columnstore index. Applies to: SQL Server 2012 (11.x) through SQL Server 2017.
										-- 7 = Nonclustered hash index. Applies to: SQL Server 2014 (12.x) through SQL Server 2017.
			IsUnique			bit,			-- 1 = index unique, 2 = index not unique, always 0 for clustered column store indexes.
			IgnoreDupeKey		bit,
			IsPrimaryKey		bit,
			IsUniqueConstraint	bit,
			PartitionSchema		nvarchar(128),
			DatabaseSpaceID		int,
			DatabaseId			int,
			SchemaId			int,
			SchemaName			nvarchar(128)
				)


-- The following two queries return information about 
-- which objects belongs to which filegroup
	-- set the name of the db to find
	----SET @DBNametoFind = 'dba_db16';

	SET @DBNametoFind = '';
	----SET @DBNametoFind = 'test8_partitions';

	----SET @DBNametoFind = '';
	IF @DBNametoFind IS NULL
		OR @DBNametoFind = ''
		BEGIN
			DECLARE db_cur CURSOR
				FOR
					SELECT d.name, d.database_id
						FROM sys.databases d
					WHERE d.database_id > 4;
		END
	ELSE
		BEGIN
			DECLARE db_cur CURSOR
				FOR
					SELECT d.name, d.database_id
						FROM sys.databases d
					WHERE d.database_id > 4
						AND d.name = @DBNametoFind;
		END

	OPEN db_cur;

	FETCH NEXT
		FROM db_cur
			INTO @DBName, @DBId;

	WHILE (@@FETCH_STATUS = 0)
		BEGIN
			SET @CMD = 'USE [' + @DBName + '] ' +
			 
				' SELECT ' + '''' + @@ServerName + '''' + ', ' + '''' + @DBName + '''' + ', ' + 
						'OBJECT_NAME(i.[object_id]) AS [ObjectName]
						,i.[index_id] AS [IndexID]
						,i.[name] AS [IndexName]
						,i.[type_desc] AS [IndexType]
						,i.is_unique
						,i.ignore_dup_key
						,i.is_primary_key
						,i.is_unique_constraint
						,pf.name AS [Partition Schema]
						,i.[data_space_id] AS [DatabaseSpaceID]
						, ' + '''' +  CONVERT(nvarchar(10),@DBId) + '''' + '
						,o.schema_id
						,s.name
					FROM [sys].[indexes] i
						LEFT JOIN SYS.partition_schemes pf ON pf.[data_space_id] = i.[data_space_id]
						LEFT JOIN sys.objects o ON (o.name = i.name)
						LEFT JOIN sys.schemas s ON (s.schema_id = o.schema_id)
				WHERE OBJECTPROPERTY(i.[object_id], ' + '''' + 'IsUserTable' + '''' + ') = 1
				ORDER BY OBJECT_NAME(i.[object_id]) ASC;'

				PRINT @CMD;

				INSERT INTO @ObjectsnPartitions
						( ServerName,
						DBName, 
						ObjectName, 
						IndexID, 
						IndexName, 
						IndexType,
						IsUnique,
						IgnoreDupeKey, 
						IsPrimaryKey,
						IsUniqueConstraint,
						PartitionSchema, 
						DatabaseSpaceID, 
						DatabaseId,
						SchemaId,
						SchemaName)
					EXEC (@CMD);

		FETCH NEXT
		FROM db_cur
			INTO @DBName, @DBId;

	END

	CLOSE db_cur;

	DEALLOCATE db_cur;

	SELECT o.ServerName, o.DBName, ISNULL(o.PartitionSchema,'DBO') AS PartitionSchema, o.SchemaName, o.ObjectName, o.IndexID, o.IndexName, o.IndexType
				,CASE o.IsUnique
					WHEN 0 THEN 'No'
					ELSE 'Yes'
				END AS IsUnique
				,CASE o.IgnoreDupeKey
					WHEN 0 THEN 'No'
					ELSE 'Yes'
				END AS IgnoreDupeKey
				,CASE o.IsPrimaryKey
					WHEN 0 THEN 'No'
					ELSE 'Yes'
				END AS IsPrimaryKey
				,CASE o.IsUniqueConstraint
					WHEN 0 THEN 'No'
					ELSE 'Yes'
				END AS IsUniqueConstraint
		FROM @ObjectsnPartitions o		
	ORDER BY ServerName ASC, DBName ASC, o.PartitionSchema, o.SchemaName,
				ObjectName ASC, IndexID ASC, DatabaseSpaceID ASC;


END
GO
