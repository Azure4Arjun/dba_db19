SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_mnt_SetShrinkDBFile
--
-- Arguments:	@DBName
--				@FiletoShrink - file logical name
--				@ShrinkAmt
--				@TruncateOnlyFlag - 0 Dont truncate, 1 Truncate only, 2 No Truncate
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Shrink a db file.
-- 
-- 
-- https://www.sqlservercentral.com/blogs/sql-database-incremental-shrink-tsql
--
-- Date			Modified By			Changes
-- 12/10/2019   Aron E. Tekulsky    Initial Coding.
-- 12/10/2019   Aron E. Tekulsky    Update to Version 140.
-- 06/11/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_mnt_SetShrinkDBFile 
	-- Add the parameters for the stored procedure here
	@DBName				nvarchar(128), 
	@FiletoShrink		nvarchar(128),
	@ShrinkAmt			int,
	@TruncateOnlyFlag	int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @Cmd	nvarchar(4000)

	-- set up the db to use
	SET @Cmd = '
			USE [' + @DBName + ']
			; '

	-- execute the shrink
	SET @Cmd = @Cmd + '
		DBCC SHRINKFILE (N' + '''' + @FiletoShrink + '''' + ' , ' +
			CONVERT(nvarchar(128), @ShrinkAmt) ;

	IF @TruncateOnlyFlag = 1 
		BEGIN
			SET @Cmd = @Cmd + ', TRUNCATEONLY);';
		END
	ELSE IF @TruncateOnlyFlag = 2
			BEGIN
				SET @Cmd = @Cmd + ', NOTRUNCATE);';
			END

		ELSE
			BEGIN
				SET @Cmd = @Cmd + ');';
			END

	PRINT @Cmd;

	EXEC SP_EXECUTESQL @Cmd;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_mnt_SetShrinkDBFile TO [db_proc_exec] AS [dbo]
GO
