SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_tbl_GenerateTableCreateScripts
--
--
-- Calls:		None
--
-- Description:	Generate a script to create tables and indexes in a database
-- 
-- Date			Modified By			Changes
-- 12/11/2019   Aron E. Tekulsky    Initial Coding.
-- 12/11/2019   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
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
			PartitionSchema		nvarchar(128),
			FileGroup			nvarchar(128),
			DatabaseSpaceID		int,
			DatabaseFileName	nvarchar(260),
			DatabaseId			int,				-- testing
			FileId				int
				)
-- The following two queries return information about 
-- which objects belongs to which filegroup
	-- set the name of the db to find
	----SET @DBNametoFind = 'dba_db16';

	SET @DBNametoFind = 'test6';

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
						,pf.name AS [Partition Schema]
						,f.[name] AS [FileGroup]
						,i.[data_space_id] AS [DatabaseSpaceID]
						,d.[physical_name] AS [DatabaseFileName]
						, ' + '''' +  CONVERT(nvarchar(10),@DBId) + '''' + '
						, d.file_id
					FROM [sys].[indexes] i
						LEFT JOIN SYS.partition_schemes pf ON pf.[data_space_id] = i.[data_space_id]
						INNER JOIN [sys].[filegroups] f ON f.[data_space_id] = i.[data_space_id]
						------INNER JOIN [sys].[database_files] d ON f.[data_space_id] = d.[data_space_id]
						LEFT JOIN [sys].[database_files] d ON f.[data_space_id] = d.[data_space_id]
						INNER JOIN [sys].[data_spaces] s ON f.[data_space_id] = s.[data_space_id]
				WHERE OBJECTPROPERTY(i.[object_id], ' + '''' + 'IsUserTable' + '''' + ') = 1
				ORDER BY OBJECT_NAME(i.[object_id]) ASC, f.[name] ASC;'
				------ORDER BY OBJECT_NAME(i.[object_id]) ASC, m.[name] ASC, i.[data_space_id] ASC;'

				----------				' SELECT ' + '''' + @@ServerName + '''' + ', ' + '''' + @DBName + '''' + ', ' + 
				----------		'OBJECT_NAME(i.[object_id]) AS [ObjectName]
				----------		,i.[index_id] AS [IndexID]
				----------		,i.[name] AS [IndexName]
				----------		,i.[type_desc] AS [IndexType]
				----------		,pm.name AS [Partition Schema]
				----------		,m.[name] AS [FileGroup]
				----------		,i.[data_space_id] AS [DatabaseSpaceID]
				----------		,d.[physical_name] AS [DatabaseFileName]
				----------	FROM [sys].[indexes] i
				----------		LEFT JOIN SYS.partition_schemes pf ON pm.[data_space_id] = i.[data_space_id]
				----------		INNER JOIN [sys].[filegroups] f ON m.[data_space_id] = i.[data_space_id]
				----------		INNER JOIN [sys].[database_files] d ON m.[data_space_id] = d.[data_space_id]
				----------		INNER JOIN [sys].[data_spaces] s ON m.[data_space_id] = s.[data_space_id]
				----------		INNER JOIN sys.all_objects o ON i.[object_id] = o.[object_id] 
				----------WHERE OBJECTPROPERTY(i.[object_id], ' + '''' + 'IsUserTable' + '''' + ') = 1
				----------AND o.type = ' + '''' + 'U' + '''' + '
				----------ORDER BY OBJECT_NAME(i.[object_id]), m.[name], i.[data_space_id];'

				----INNER JOIN sys.all_objects o ON i.[object_id] = o.[object_id] testing from blog authority
				----AND o.type = 'U'  V

				PRINT @CMD;

				INSERT INTO @ObjectsnPartitions
						( ServerName,
						DBName, 
						ObjectName, 
						IndexID, 
						IndexName, 
						IndexType, 
						PartitionSchema, 
						FileGroup, 
						DatabaseSpaceID, 
						DatabaseFileName,
						DatabaseId,
						FileId)
					EXEC (@CMD);

		FETCH NEXT
		FROM db_cur
			INTO @DBName, @DBId;

	END

	CLOSE db_cur;

	DEALLOCATE db_cur;


	SELECT *
		FROM @ObjectsnPartitions;

	/****** Script for SelectTopNRows command from SSMS  ******/
	DECLARE @cmd						nvarchar(4000)
	DECLARE @dbname						nvarchar(128)
	DECLARE @FileGroup					nvarchar(128)
	DECLARE @FirstTimeFlag				tinyint
	DECLARE @TABLE_CATALOG				nvarchar(128)
	DECLARE @TABLE_SCHEMA				nvarchar(128)
	DECLARE @TABLE_NAME					nvarchar(128)
	DECLARE @COLUMN_NAME				nvarchar(128)
	DECLARE @DATA_TYPE					nvarchar(128)
	DECLARE @CHARACTER_MAXIMUM_LENGTH	int
	DECLARE @IS_NULLABLE				varchar(3)
	DECLARE @NUMERIC_PRECISION			tinyint
    DECLARE @NUMERIC_SCALE				int
	DECLARE @oldTABLE_SCHEMA			nvarchar(128)
	DECLARE @oldTABLE_NAME				nvarchar(128)
	DECLARE @OldCOLUMN_NAME				nvarchar(128)
	DECLARE @oldFileGroup				nvarchar(128)


	DECLARE @Schematable TABLE (
			[TABLE_CATALOG]				nvarchar(128),
			[TABLE_SCHEMA]				nvarchar(128),
			[TABLE_NAME]				nvarchar(128),
			[COLUMN_NAME]				nvarchar(128),
			[DATA_TYPE]					nvarchar(128),
			[CHARACTER_MAXIMUM_LENGTH]	int,
			[IS_NULLABLE]				varchar(3),
			[NUMERIC_PRECISION]			tinyint,
			[NUMERIC_SCALE]				int)

	SET @dbname = 'test6';
	SET @FileGroup = 'fg1';

		SET  @cmd = '
			USE [' + @dbname + ']  ' + --CHAR(13) + 
		'SELECT  [TABLE_CATALOG]
		    ,[TABLE_SCHEMA]
			,[TABLE_NAME]
		    ,[COLUMN_NAME]
			,[DATA_TYPE]
			,[CHARACTER_MAXIMUM_LENGTH]
			,[IS_NULLABLE]
			,[NUMERIC_PRECISION]
			,[NUMERIC_SCALE]
			FROM [' + @dbname + '].[INFORMATION_SCHEMA].[COLUMNS]
		ORDER BY [TABLE_CATALOG], [TABLE_SCHEMA], [TABLE_NAME], [ORDINAL_POSITION] ASC'

		INSERT INTO @Schematable
			EXEC(@cmd);

			PRINT @cmd;

			-- initialize
		SET @Cmd			= '';
		SET @FirstTimeFlag	= 1;

	DECLARE table_cur CURSOR FOR 
		SELECT TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE,NUMERIC_PRECISION	,NUMERIC_SCALE
			FROM @Schematable;

	OPEN table_cur;

	FETCH NEXT FROM table_cur INTO
		@TABLE_CATALOG, @TABLE_SCHEMA, @TABLE_NAME, @COLUMN_NAME, @DATA_TYPE, @CHARACTER_MAXIMUM_LENGTH, @IS_NULLABLE, @NUMERIC_PRECISION, @NUMERIC_SCALE;

	SET @oldTABLE_SCHEMA	= @TABLE_SCHEMA;
	SET @oldTABLE_NAME		= ''; --@TABLE_NAME;
	SET @OldCOLUMN_NAME		= @COLUMN_NAME;

	WHILE (@@FETCH_STATUS <> -1)
		BEGIN
	
	-- set up to build create for table.

			IF @TABLE_SCHEMA <> @oldTABLE_SCHEMA
				BEGIN
					SET @oldTABLE_SCHEMA	= @TABLE_SCHEMA;
				END

			 IF @TABLE_NAME <> @oldTABLE_NAME
					BEGIN

						IF @FirstTimeFlag <> 1
							BEGIN
								SET @Cmd = @Cmd + ') ON [' + @FileGroup + '];'
								-- print out table

								PRINT @Cmd;
							END

						------ELSE
						SET @FirstTimeFlag	= 0;


					-- reset old value
						SET @oldTABLE_NAME = @TABLE_NAME;

					-- start a new table
						SET @Cmd = '
							CREATE TABLE [' + @TABLE_SCHEMA + '].[' + @TABLE_NAME + '](' +
								' [' + @COLUMN_NAME + ']   ' + @DATA_TYPE 
								+ 
						 --do the datatype
						CASE LOWER(@DATA_TYPE) 
							----WHEN 'int'			THEN ', '
							----WHEN 'tinyint'		THEN ', '
							----WHEN 'bigint'		THEN ', '
							----WHEN 'bit'			THEN ', '
							----WHEN 'sql_variant'	THEN ', '
							WHEN 'decimal'		THEN '(' + CONVERT(varchar(128), @NUMERIC_PRECISION) +',' +CONVERT(varchar(128),  @NUMERIC_SCALE) +')'
							WHEN 'money'		THEN '( '+ CONVERT(varchar(128), @NUMERIC_PRECISION) +',' +CONVERT(varchar(128),  @NUMERIC_SCALE) +')'
							WHEN 'numeric'		THEN '(' + CONVERT(varchar(128), @NUMERIC_PRECISION) +',' +CONVERT(varchar(128),  @NUMERIC_SCALE) +')'
							WHEN 'smallmoney'	THEN '(' + CONVERT(varchar(128), @NUMERIC_PRECISION) +',' +CONVERT(varchar(128),  @NUMERIC_SCALE) +')'
							WHEN 'char'			THEN '(' + CONVERT(varchar(128),@CHARACTER_MAXIMUM_LENGTH) + ')'
							WHEN 'varchar'		THEN '(' + CONVERT(varchar(128),@CHARACTER_MAXIMUM_LENGTH) + ')'
							WHEN 'nchar'		THEN '(' + CONVERT(varchar(128),@CHARACTER_MAXIMUM_LENGTH) + ')'
							WHEN 'nvarchar'		THEN '(' + CONVERT(varchar(128),@CHARACTER_MAXIMUM_LENGTH) + ')'
							WHEN 'binary'		THEN '(' + CONVERT(varchar(128), @NUMERIC_PRECISION) +',' +CONVERT(varchar(128),  @NUMERIC_SCALE) + ')'
							WHEN 'varbinary'	THEN '(' +CONVERT(varchar(128), @NUMERIC_PRECISION) +',' +CONVERT(varchar(128),  @NUMERIC_SCALE) + ')'
						ELSE ' '
						END 
						+

						 --do the nullability
						CASE @IS_NULLABLE
							WHEN 'YES' THEN ' NULL '
							ELSE ' NOT NULL '
						END
					END

				ELSE IF @COLUMN_NAME <> @OldCOLUMN_NAME
					 --------IF @COLUMN_NAME <> @OldCOLUMN_NAME
						BEGIN
							-- set  up for next column
							SET @Cmd = @Cmd + ',' +
								' [' + @COLUMN_NAME + ']   ' + @DATA_TYPE 
								+ 
								 --do the datatype
								CASE LOWER(@DATA_TYPE) 
									----WHEN 'int'			THEN ', '
									----WHEN 'tinyint'		THEN ', '
									----WHEN 'bigint'		THEN ', '
									----WHEN 'bit'			THEN ', '
									----WHEN 'sql_variant'	THEN ', '
									WHEN 'decimal'		THEN '(' + CONVERT(varchar(128), @NUMERIC_PRECISION) +',' +CONVERT(varchar(128),  @NUMERIC_SCALE) +')'
									WHEN 'money'		THEN '( '+ CONVERT(varchar(128), @NUMERIC_PRECISION) +',' +CONVERT(varchar(128),  @NUMERIC_SCALE) +')'
									WHEN 'numeric'		THEN '(' + CONVERT(varchar(128), @NUMERIC_PRECISION) +',' +CONVERT(varchar(128),  @NUMERIC_SCALE) +')'
									WHEN 'smallmoney'	THEN '(' + CONVERT(varchar(128), @NUMERIC_PRECISION) +',' +CONVERT(varchar(128),  @NUMERIC_SCALE) +')'
									WHEN 'char'			THEN '(' + CONVERT(varchar(128),@CHARACTER_MAXIMUM_LENGTH) + ')'
									WHEN 'varchar'		THEN '(' + CONVERT(varchar(128),@CHARACTER_MAXIMUM_LENGTH) + ')'
									WHEN 'nchar'		THEN '(' + CONVERT(varchar(128),@CHARACTER_MAXIMUM_LENGTH) + ')'
									WHEN 'nvarchar'		THEN '(' + CONVERT(varchar(128),@CHARACTER_MAXIMUM_LENGTH) + ')'
									WHEN 'binary'		THEN '(' + CONVERT(varchar(128), @NUMERIC_PRECISION) +',' +CONVERT(varchar(128),  @NUMERIC_SCALE) + ')'
									WHEN 'varbinary'	THEN '(' +CONVERT(varchar(128), @NUMERIC_PRECISION) +',' +CONVERT(varchar(128),  @NUMERIC_SCALE) + ')'
								ELSE ' '
								END 
						+

						 --do the nullability
						CASE @IS_NULLABLE
							WHEN 'YES' THEN ' NULL '
							ELSE ' NOT NULL '
						END

							SET @OldCOLUMN_NAME		= @COLUMN_NAME;
						END


			FETCH NEXT FROM table_cur INTO
				@TABLE_CATALOG, @TABLE_SCHEMA, @TABLE_NAME, @COLUMN_NAME, @DATA_TYPE, @CHARACTER_MAXIMUM_LENGTH, @IS_NULLABLE, @NUMERIC_PRECISION, @NUMERIC_SCALE;
		
		END

		SET @Cmd = @Cmd + ') ON [' + @FileGroup + '];'
		-- print out table

		PRINT @Cmd;

	CLOSE table_cur;
	DEALLOCATE table_cur;

------	CREATE TABLE [dbo].[Table_1](
------	[idn] [int] NOT NULL,
------	[testfn] [varchar](10) NULL,
------	[testln] [varchar](20) NULL
------) ON [test6_fg2]
------GO




END
GO
