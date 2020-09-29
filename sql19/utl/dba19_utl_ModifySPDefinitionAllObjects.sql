SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_utl_ModifySPDefinitionAllObjects
--
--
-- Calls:		None
--
-- Description:	Get the definition of a SP and update the comments with a new version
--				number. for all objects in a database.
-- 
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-sql-modules-transact-sql?view=sql-server-ver15
-- 
-- Date			Modified By			Changes
-- 09/22/2020   Aron E. Tekulsky    Initial Coding.
-- 09/22/2020   Aron E. Tekulsky    Update to Version 150.
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

	DECLARE @headers TABLE (
			HeaderTxt			nvarchar(max),
			TotalLen			int,
			DefLength			int,
			BalanceofDef		nvarchar(max)
	)
	
	DECLARE @ObjList TABLE (
			ObjectName			nvarchar(128),
			ObjType				char(2),
			SkipFlag			bit,
			rnum				int identity(1,1)
	)
	
	DECLARE @Cmd				nvarchar(max)
	DECLARE @DBName				nvarchar(128)
	DECLARE @ObjectName			nvarchar(128)
	DECLARE @NewVersion			varchar(6)
	DECLARE @ObjType			char(2)
	------DECLARE @HeaderTxt	nvarchar(max)

	DECLARE @BalanceofDef		nvarchar(max)
	DECLARE @CopyRight			nvarchar(max)
	DECLARE @CommentOnly		nvarchar(max)
	DECLARE @CrLoc				int
	DECLARE @DateToUse			varchar(10)
	DECLARE @DBAVersion			varchar(3)
	DECLARE @DefLength			int
	DECLARE @EndCommentPosit	int
	DECLARE @HeaderTxt			nvarchar(max)
	DECLARE @HTLength			int
	DECLARE @Loc1				int
	DECLARE @NewComment			nvarchar(max)
	DECLARE @StartNewCommentPos	int
	DECLARE @SQLCompatability	varchar(4)
	DECLARE @FindCompatLevel	bigint
	DECLARE @TotalLen			int

	DECLARE @MaxRowcount		bigint
	DECLARE @UndoneCount		bigint

	-- Initialize
	SET @DBName				= 'dba_db19';
	----SET @ObjectName = 'p_dba19_sys_GetExpiredDB';
	SET @ObjectName			= '';
	SET @NewVersion			= 'dba19';
	SET @ObjType			= 'P';
	SET @HeaderTxt			= '';

	SET @DateToUse			= '09/22/2020';
	SET @SQLCompatability	= '150';
	SET @DBAVersion			= '19';
	SET @NewComment			= '-- ' + @DateToUse +
		'   Aron E. Tekulsky    Update to Version ' + @SQLCompatability + '.' ;
	SET @FindCompatLevel	= 0;
	SET @UndoneCount		= 0;

	-- 1 - get the items in the db

	SET @Cmd = '
		SELECT o.name, o.type
			FROM [' + @DBName + '].[sys].[objects] o
		WHERE o.type = ' +'''' +  @ObjType + '''' +  ';';

			-- Load all objects
	INSERT INTO @ObjList (
		ObjectName, ObjType
		)
	EXEC (@Cmd);

	-- get the # of items loaded.
	SELECT @MaxRowcount = COUNT(*)
		FROM @ObjList;

-- Declare the cursor.
	DECLARE db_cur CURSOR FOR
		SELECT ObjectName, ObjType
			FROM @ObjList
		ORDER BY ObjectName  ASC;
						
	-- Open the cursor.
	OPEN db_cur;

	-- Do the first fetch of the cursor.
	FETCH NEXT FROM db_cur INTO
		@ObjectName, @ObjType;

	-- Set up the loop.
	WHILE (@@FETCH_STATUS <> -1)
		BEGIN
	--  place Code here --

			SET @Cmd = 
			'SELECT SUBSTRING(m.definition,1,(CHARINDEX(' + '''' + 'PROCEDURE' + '''' + ', m.definition, 1)-8)),
						LEN(m.definition),
					CHARINDEX(' + '''' + 'PROCEDURE' + '''' + ', m.definition, 1),
						SUBSTRING(m.definition,(CHARINDEX(' + '''' + 'PROCEDURE' + '''' + ', m.definition, 1)-8), LEN(m.definition))
				FROM [' + @DBName + '].[sys].[sql_modules] m 
					INNER JOIN [' + @DBName + '].[sys].[objects] o ON (m.object_id=o.object_id)
			WHERE o.name = ' + '''' + @ObjectName + '''' + ' AND o.type = ' + '''' + @ObjType + ''''   ;

			INSERT INTO @headers (
				HeaderTxt, TotalLen,DefLength, BalanceofDef
			)
			EXEC(@Cmd);

			------SELECT 'dump ',*
			------	FROM @headers;


			SELECT @HeaderTxt = HeaderTxt, @TotalLen = TotalLen, @DefLength = DefLength, @BalanceofDef = BalanceofDef
				FROM @headers;

			-- check to see if already upgraded
			SELECT @FindCompatLevel = CHARINDEX(@SQLCompatability,@HeaderTxt,1)

			----PRINT 'old compat is ' +CONVERT(varchar(20), @FindCompatLevel);
			IF @FindCompatLevel > 0 
				BEGIN

					-- Get length of header text
					SELECT @HTLength = LEN(@HeaderTxt);


					-- get position of first comment box line
					SELECT @Loc1 = CHARINDEX('-- ==', @HeaderTxt, 0);


					-- find position of final comment box line
					SELECT @EndCommentPosit = CHARINDEX('-- ==', @HeaderTxt, 10);
	
					-- break out the comments only
					SELECT @CommentOnly = SUBSTRING(@HeaderTxt,@Loc1,@EndCommentPosit-1);

					----PRINT '***** comments only *****';
					PRINT @CommentOnly;
					------------PRINT '***** END comments only *****';

					-- position to start new comment line
					SET @StartNewCommentPos = @EndCommentPosit -1;

					PRINT @NewComment;
					----------PRINT 'end comments ' + CONVERT(varchar(128),@EndCommentPosit);


					SELECT @CopyRight = SUBSTRING(@HeaderTxt,@EndCommentPosit, @HTLength);
	

					--------PRINT 'copyright is ';
					PRINT TRIM(@CopyRight);

					--------PRINT '@BalanceofDef ' + ;

					SELECT @BalanceofDef = REPLACE(@BalanceofDef, 'CREATE PROCEDURE', 'ALTER PROCEDURE')
					PRINT TRIM(@BalanceofDef);

				END
			ELSE 
				BEGIN
					SET @UndoneCount = @UndoneCount + 1;

					UPDATE @ObjList
						SET SkipFlag = 1
					WHERE  ObjectName = @ObjectName;
				END

				----PRINT'' +  CHAR(13);

				-- end code
				FETCH NEXT FROM db_cur INTO
					@ObjectName, @ObjType;

				DELETE FROM @headers;
		END

		-- Close the cursor.
		CLOSE db_cur;

		-- Deallocate the cursor.
		DEALLOCATE db_cur;

		PRINT 'Total Rows Processed ' + CONVERT(varchar(20),@MaxRowcount);
		PRINT 'TOTAL Rows skipped   ' + CONVERT(varchar(20),@UndoneCount);

		SELECT ObjectName AS AlreadyUpToDate
			FROM @ObjList 
		WHERE SkipFlag = 1;

END
GO
