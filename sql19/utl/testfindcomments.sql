
	DECLARE @BalanceofDef		nvarchar(max)
	DECLARE @CopyRight			nvarchar(max)
	DECLARE @CommentOnly		nvarchar(max)
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
	DECLARE @TotalLen			int

	SET @DateToUse			= '09/22/2020';
	SET @SQLCompatability	= '160';
	SET @DBAVersion			= '19';
	SET @NewComment			= '-- ' + @DateToUse +
		'   Aron E. Tekulsky    Update to Version ' + @SQLCompatability + '.' ;

	SELECT @TotalLen = LEN(m.definition)
		FROM sys.sql_modules m 
			INNER JOIN sys.objects o ON m.object_id=o.object_id
	WHERE o.name = 'p_dba19_sys_GetExpiredDB' AND o.type = 'P ' ;

	SELECT @HeaderTxt = SUBSTRING(m.definition,1,(CHARINDEX('PROCEDURE', m.definition, 1)-8))
		FROM sys.sql_modules m 
			INNER JOIN sys.objects o ON m.object_id=o.object_id
	WHERE o.name = 'p_dba19_sys_GetExpiredDB' AND o.type = 'P ' ;

	-- Get length of header text
	SELECT @HTLength = LEN(@HeaderTxt);

	SELECT @DefLength = CHARINDEX('PROCEDURE', m.definition, 1)
		FROM sys.sql_modules m 
			INNER JOIN sys.objects o ON m.object_id=o.object_id
	WHERE o.name = 'p_dba19_sys_GetExpiredDB' AND o.type = 'P ' ;

	SELECT @BalanceofDef = SUBSTRING(m.definition,(CHARINDEX('PROCEDURE', m.definition, 1)-8), @TotalLen)
		FROM sys.sql_modules m 
			INNER JOIN sys.objects o ON m.object_id=o.object_id
	WHERE o.name = 'p_dba19_sys_GetExpiredDB' AND o.type = 'P ' ;

-- get position of first comment box line
	SELECT @Loc1 = CHARINDEX('-- ==', @HeaderTxt, 0);


	-- find position of final comment box line
	SELECT @EndCommentPosit = CHARINDEX('-- ==', @HeaderTxt, 10);
	
	-- break out the comments only
	SELECT @CommentOnly = SUBSTRING(@HeaderTxt,@Loc1,@EndCommentPosit-1);

	----------PRINT '***** comments only *****';
	PRINT @CommentOnly;
	------------PRINT '***** END comments only *****';

	-- position to start new comment line
	SET @StartNewCommentPos = @EndCommentPosit -1;

	PRINT @NewComment;
	----------PRINT 'end comments ' + CONVERT(varchar(128),@EndCommentPosit);


	SELECT @CopyRight = SUBSTRING(@HeaderTxt,@EndCommentPosit, @HTLength);
	

	----------PRINT 'copyright is ';
	PRINT TRIM(@CopyRight);

	----------PRINT '@BalanceofDef ' + ;
	PRINT TRIM(@BalanceofDef);


