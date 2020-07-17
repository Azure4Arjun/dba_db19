SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba15_idx_GetIDXToMoveFileGroups
--
--
-- Calls:		None
--
-- Description:	Create a script to move all pk indexes and their corresponding
--				tables to a new file group.
-- 
-- Date			Modified By			Changes
-- 04/30/2018 Aron E. Tekulsky Initial Coding.
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

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @Cmd				nvarchar(4000)
	DECLARE @ColName			nvarchar(128)
	DECLARE @HoldAllColNames	nvarchar(128)
	DECLARE @IsUnique			int
	DECLARE @IndexId			int
	DECLARE @IndexColumnId		int
	DECLARE @LastTableName		nvarchar(128)
	DECLARE @LastPKName			nvarchar(128)
	DECLARE @LastColName		nvarchar(128)
	DECLARE @LastIsUnique		int
	DECLARE @LastIndexColumnId	int
	DECLARE @NewFileGrPName		nvarchar(128)
	DECLARE @PKName				nvarchar(128)
	DECLARE @TableNam			nvarchar(128)
	DECLARE @UniqueIDX			int
	DECLARE @IDXListing	TABLE (
			TableNam			nvarchar(128),
			PKName				nvarchar(128),
			ColName				nvarchar(128),
			IsUnique			int,
			ObjectId			int,
			IndexId				int,
			ColumnId			int,
			IndexColumnId		int
	)

	-- initialize --
	SET @NewFileGrPName = 'testing';

	INSERT INTO @IDXListing(
			TableNam, PKName, ColName, IsUnique, ObjectId, IndexId, ColumnId,
			IndexColumnId
	)
	SELECT o.name AS tablename, i.name AS pkname,s.name AS
			columnname,i.is_unique, i.object_id, i.index_id, c.object_id,
			c.index_column_id
		FROM sys.indexes i
			LEFT JOIN sys.index_columns c ON (c.object_id = i.object_id) AND
											(c.index_id = i.index_id)
			LEFT JOIN sys.objects o ON (o.object_id = i.object_id)
			LEFT JOIN sys.columns s ON ( c.object_id = s.object_id) AND
										(c.column_id = s.column_id)
			LEFT JOIN sys.types t ON (s.user_type_id = t.user_type_id)
	WHERE o.type = 'U' AND
		i.type = 1
	ORDER BY o.name ASC, c.index_id ASC, c.index_column_id ASC;

	DECLARE IDX_CUR CURSOR FOR
		SELECT TableNam, PKName, ColName, IsUnique, IndexColumnId--, IndexId
			FROM @IDXListing
		ORDER BY TableNam, IndexId, IndexColumnId ASC;

	OPEN IDX_CUR;

	FETCH NEXT FROM IDX_CUR INTO
		@TableNam, @PKName, @ColName, @IsUnique, @IndexColumnId--, @IndexId;

	SET @LastTableName		= @TableNam;
	SET @LastPKName			= @PKName;
	SET @LastColName		= @ColName;
	SET @LastIsUnique		= @IsUnique;
	SET @LastIndexColumnId	= @IndexColumnId;
	SET @HoldAllColNames	= '';-- Initialize

	WHILE (@@FETCH_STATUS <> -1)
		BEGIN
			IF @TableNam <> @LastTableName
				BEGIN
					SET @Cmd = 'CREATE ' + CASE @LastIsUnique
					WHEN 1 THEN
						' UNIQUE '
					ELSE
						''
					END
					+ 'CLUSTERED INDEX ' + @LastPKName + ' ON '
					+ @LastTableName
					+ ' (' + @HoldAllColNames + ')' + ' WITH
					DROP_EXISTING ' + ' ON ' + @NewFileGrPName + ';';

					PRINT @Cmd;

					SET @LastTableName		= @TableNam;
					SET @LastPKName			= @PKName;
					SET @LastColName		= @ColName;
					SET @LastIsUnique		= @IsUnique;
					SET @LastIndexColumnId	= @IndexColumnId;
					SET @HoldAllColNames	= ''; -- Initialize
				END

			IF @HoldAllColNames = ''
				BEGIN
					SET @HoldAllColNames = @ColName;
				END
			ELSE
				BEGIN
					SET @HoldAllColNames = @HoldAllColNames + ', ' +
						@ColName;
				END	

			FETCH NEXT FROM IDX_CUR INTO
				@TableNam, @PKName, @ColName, @IsUnique, @IndexColumnId--,
				--@IndexId;
		END

	SET @Cmd = 'CREATE ' + CASE @LastIsUnique
		WHEN 1 THEN
			' UNIQUE '
		ELSE
			''
		END
		+ 'CLUSTERED INDEX ' + @LastPKName + ' ON ' +
		@LastTableName
		+ ' (' + @HoldAllColNames + ')' + ' WITH DROP_EXISTING '
		+ ' ON ' + @NewFileGrPName + ';';

	PRINT @Cmd;

	CLOSE IDX_CUR;
	DEALLOCATE IDX_CUR;

	SELECT *
		FROM @IDXListing;
END
GO
