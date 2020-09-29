SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_utl_ModifySPDefinition
--
--
-- Calls:		None
--
-- Description:	Get the definition of a SP and update the comments with a new version number.
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

	DECLARE @Cmd		nvarchar(max)
	DECLARE @DBName		nvarchar(128)
	DECLARE @ObjectName	nvarchar(128)
	DECLARE @NewVersion	varchar(6)
	DECLARE @ObjType	char(2)
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
	DECLARE @TotalLen			int


	-- Initialize
	SET @DBName = 'dba_db19';
	SET @ObjectName = 'p_dba16_sys_GetExpiredDB';
	SET @NewVersion = 'dba19';
	SET @ObjType = 'P';
	SET @HeaderTxt = '';

	SET @DateToUse			= '09/22/2020';
	SET @SQLCompatability	= '160';
	SET @DBAVersion			= '19';
	SET @NewComment			= '-- ' + @DateToUse +
		'   Aron E. Tekulsky    Update to Version ' + @SQLCompatability + '.' ;

	------SET @Cmd = 
	------	'USE [' + @DBName + ']' + char(13) + 
	------	'
	------	SELECT o.name AS Object_Name,o.type_desc, m.definition
	------		FROM sys.sql_modules m 
	------			INNER JOIN sys.objects o ON m.object_id=o.object_id
	------		WHERE o.name = ' + '''' + @ObjectName + '''' + ';';

	----SET @Cmd = 
	----	'USE [' + @DBName + ']' + char(13) + 
	----	'
		----SELECT @HeaderTxt = SUBSTRING('+ 'm.definition,' + '1,(CHARINDEX(' + '''' + 'PROCEDURE' + '''' + ', ' + 'm.definition, 1' + ')-8)),
		----		@TotalLen = LEN(m.definition)
		----	FROM sys.sql_modules m 
		----		INNER JOIN sys.objects o ON m.object_id=o.object_id
		----	WHERE o.name = ' + '''' + @ObjectName + '''' + 
		----		' AND o.type = ' + '''' + @ObjType + '''' + ' ;';

	----EXEC(@Cmd);


	SELECT @HeaderTxt = SUBSTRING(m.definition,1,(CHARINDEX('PROCEDURE', m.definition, 1)-8)),
			@TotalLen = LEN(m.definition),
			@DefLength = CHARINDEX('PROCEDURE', m.definition, 1),
			@BalanceofDef = SUBSTRING(m.definition,(CHARINDEX('PROCEDURE', m.definition, 1)-8), @TotalLen)
		FROM sys.sql_modules m 
			INNER JOIN sys.objects o ON m.object_id=o.object_id
	WHERE o.name = 'p_dba19_sys_GetExpiredDB' AND o.type = 'P' ;

	
	------SELECT @HeaderTxt = SUBSTRING(m.definition,1,(CHARINDEX('PROCEDURE', m.definition, 1)-8))
	------	FROM sys.sql_modules m 
	------		INNER JOIN sys.objects o ON m.object_id=o.object_id
	------WHERE o.name = 'p_dba19_sys_GetExpiredDB' AND o.type = 'P ' ;

	-- Get length of header text
	SELECT @HTLength = LEN(@HeaderTxt);

	------SELECT @DefLength = CHARINDEX('PROCEDURE', m.definition, 1)
	------	FROM sys.sql_modules m 
	------		INNER JOIN sys.objects o ON m.object_id=o.object_id
	------WHERE o.name = 'p_dba19_sys_GetExpiredDB' AND o.type = 'P ' ;

	------SELECT @BalanceofDef = SUBSTRING(m.definition,(CHARINDEX('PROCEDURE', m.definition, 1)-8), @TotalLen)
	------	FROM sys.sql_modules m 
	------		INNER JOIN sys.objects o ON m.object_id=o.object_id
	------WHERE o.name = 'p_dba19_sys_GetExpiredDB' AND o.type = 'P ' ;

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

	----PRINT @Cmd;

END
GO
