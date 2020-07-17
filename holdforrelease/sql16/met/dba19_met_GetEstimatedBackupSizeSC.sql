SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_met_GetEstimatedBackupSizeSC
--
--
-- Calls:		None
--
-- Description:	
-- 
-- https://www.sqlservercentral.com/forums/topic/estimate-backup-size-before-backup-strat
--
-- Date			Modified By			Changes
-- 05/05/2020   Aron E. Tekulsky    Initial Coding.
-- 05/05/2020   Aron E. Tekulsky    Update to Version 150.
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
	DECLARE @dataSize	Float
	DECLARE @DBName		nvarchar(128)
	DECLARE @sql		nvarchar(100)
	Declare @LogSize	Float

	--------CREATE TABLE #Log_info ( 
	DECLARE @Log_info AS TABLE  ( 
		RU			int,
		FieldId		Int, 
		FileSize	Bigint, 
		Startoff	Bigint, 
		FseqNo		int, 
		Status		smallint,
		Parity		Bigint, 
		CreateLsn	numeric)

	DECLARE @DBBackEst AS TABLE (
		DBName		nvarchar(128),
		DataSize	Float,
		FileSize	float,
		LogSize		float
	)

-- My snipet sql code goes here --
-- Declare the cursor.
	DECLARE db_cur CURSOR FOR
		SELECT Name--,state_desc Status
			FROM sys.databases
		WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb','ReportServer','ReportServerTempDB','SSISDB')
			AND state_desc = 'ONLINE'
			AND is_read_only <> 1 --means database=in read only mode
			AND CHARINDEX('-',name) = 0 --AND-- no dashes in dbname
			--[dba_db08].[dbo].[f_dba14_get_dbrole] (name) = 1
		ORDER BY NAME ASC;
						
-- Open the cursor.
	OPEN db_cur;

-- Do the first fetch of the cursor.
	FETCH NEXT FROM db_cur INTO
			@DBName;

-- Set up the loop.
	WHILE (@@FETCH_STATUS <> -1)
		BEGIN
	--  place Code here --
			SET @Cmd = '
				SELECT (SUM(used_pages) * 8) / (1024.00) 
					From [' + @DBName + '].[sys].[allocation_units];'; -- + CHAR(13) + ' ' ; -- Run it in YourDatabase

			PRINT @Cmd;

			INSERT @DBBackEst (
				DataSize)
			EXEC (@Cmd);

			-- Log Size
			----------SET @Cmd =  '
			SET @sql =  'dbcc loginfo(' + @DBName + ')';-- + CHAR(13);

			INSERT INTO @Log_info
				EXEC sp_executesql @sql;

			UPDATE @DBBackEst
				SET FileSize = (
					SELECT FileSize/ (1024.00 * 1024.00) 
						FROM @Log_info 
					WHERE [Status] = 2
					GROUP BY FileSize); -- Only Active VLFs

			SELECT *
				FROM @DBBackEst;


			SELECT @dataSize DataSize_inMB, @LogSize LogSize_inMB, @dataSize + @LogSize AS [BackupSize_Approx(90%)];

			------TRUNCATE TABLE @Log_info;
			DELETE FROM @DBBackEst;
					
			FETCH NEXT FROM db_cur INTO
				@dbname;
		END
-- Close the cursor.
	CLOSE db_cur;
-- Deallocate the cursor.
	DEALLOCATE db_cur;
				

	--------SELECT @dataSize = (SUM(used_pages) * 8) / (1024.00) 
	--------	From sys.allocation_units; -- Run it in YourDatabase

	---------- Log Size
	--------SET @sql = 'dbcc loginfo(Brent)';

	--------INSERT INTO #log_info
	--------	EXEC sp_executesql @sql;


	--------SELECT @LogSize= FileSize/ (1024.00 * 1024.00) FROM #Log_info WHERE [Status] = 2; -- Only Active VLFs

	--------SELECT @dataSize DataSize_inMB, @LogSize LogSize_inMB, @dataSize + @LogSize AS [BackupSize_Approx(90%)];


END
GO
