SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_utl_GenerateDatabaseFilesOnFileGroups
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 02/04/2020   Aron E. Tekulsky    Initial Coding.
-- 02/04/2020   Aron E. Tekulsky    Update to Version 150.
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

	DECLARE @Cmd		nvarchar(4000)
	DECLARE @DBName		nvarchar(128)
	DECLARE @FGName		nvarchar(128)
	DECLARE @ICount		tinyint

	DECLARE @FileGroups AS TABLE (
		name			nvarchar(128),
		data_space_id	int,
		is_default		bit
	)

	-- Initialize get existing DB name.
	SET @DBName = 'test6'; -- set to the db you want to use as source.
	SET @ICount =  1; -- initialize.

	-- read file groups for existing db.
	SET @Cmd = ' USE [' + @DBName + ']
		SELECT name, data_space_id, is_default
			FROM sys.filegroups';

	INSERT INTO @FileGroups (
		name, data_space_id, is_default)
	EXEC (@Cmd);


	----SELECT *
	----	FROM @FileGroups;

	-- My snipet sql code goes here --
-- Declare the cursor.
	DECLARE db_cur CURSOR FOR
		SELECT Name--,state_desc Status
			FROM @FileGroups
		WHERE data_space_id > 1
		ORDER BY data_space_id ASC;
						
-- Open the cursor.
	OPEN db_cur;

-- Do the first fetch of the cursor.
	FETCH NEXT FROM db_cur INTO
			@FGName;

-- Set up the loop.
	WHILE (@@FETCH_STATUS <> -1)
		BEGIN
	--  place Code here --
			SET @Cmd = '';

			IF @ICount = 1
				BEGIN
					SET @Cmd = 
						'USE [master] ' + CHAR(13);
				END

			SET @Cmd = @Cmd + 
				'ALTER DATABASE [' + @DBName + '] ADD FILEGROUP [' + @FGName + ']' + CHAR(13);

			-- print them to be a script.

			PRINT @Cmd;



			FETCH NEXT FROM db_cur INTO
				@FGName;

			SET @ICount = @ICount + 1;
		END

-- Close the cursor.
	CLOSE db_cur;

-- Deallocate the cursor.
	DEALLOCATE db_cur;
				

END
GO
