SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_met_GetMonthlyAverageBackupTimebyDBSS
--
--
-- Calls:		None
--
-- Description:	It gives average backup size of the month for each DB.
-- 
-- https://www.sqlshack.com/forecast-sql-backup-size/
--
-- Date			Modified By			Changes
-- 05/06/2020   Aron E. Tekulsky    Initial Coding.
-- 05/06/2020   Aron E. Tekulsky    Update to Version 150.
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
	
-- My snipet sql code goes here --
	DECLARE @Cmd	nvarchar(4000)
	DECLARE @DBName	nvarchar(128)

	DECLARE @MonthlyAverageBackupTime AS TABLE (
		DBName		nvarchar(128),
		BackupMonth	int,
		BackupSize	numeric(20,0),
		BackupYr	int
	)

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
				SELECT s.database_name, DATEPART(MONTH,s.backup_finish_date) AS [BackupMonth] ,
						 (AVG(s.backup_size)/1048576) as [BackupSize (MB)] ,
						DATEPART(YEAR,s.backup_finish_date)  AS [BackupYear]
 					FROM msdb.dbo.backupmediafamily m
						INNER JOIN msdb.dbo.backupset  s ON (m.media_set_id = s.media_set_id)
				WHERE  s.type =' + '''' + 'D' + '''' + 
					' AND s.database_name =' + '''' + @DBName + '''' + 
					' AND DATEPART(YEAR,s.backup_finish_date) = DATEPART(YEAR,GETDATE())
				GROUP BY s.database_name 
					, DATEPART(MONTH,s.backup_finish_date)
					, DATEPART(YEAR,s.backup_finish_date) ;'
				------ORDER BY DATEPART(MONTH,s.backup_finish_date) Asc;'
				
			INSERT @MonthlyAverageBackupTime (
				DBName, BackupMonth, BackupSize, BackupYr
				)
			EXEC (@Cmd);

			FETCH NEXT FROM db_cur INTO
				@dbname;
		END

-- Close the cursor.
	CLOSE db_cur;

-- Deallocate the cursor.
	DEALLOCATE db_cur;
				
	SELECT DBName, BackupYr, BackupMonth, BackupSize
		FROM @MonthlyAverageBackupTime
	ORDER BY DBName ASC, BackupYr ASC, BackupMonth ASC

END
GO
