SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sys_GetCheckSpaceThresholdSP
--
--
-- Calls:		None
--
-- Description:	Check the space threshold on the disk..
--				--- Modified from Erin's blog : Proactive SQL Server Health Checks, Part 1 : Disk Space
--				--- source http://sqlperformance.com/2014/12/io-subsystem/proactive-sql-server-health-checks-1
-- 
-- Date			Modified By			Changes
-- 11/14/2016   Aron E. Tekulsky    Initial Coding.
-- 11/22/2017   Aron E. Tekulsky    Update to Version 140.
-- 08/25/2020   Aron E. Tekulsky    Update to Version 150.
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

	IF object_id('tempdb..#dbserversize') is not null
	  DROP TABLE #dbserversize;

    CREATE TABLE dbo.#dbserversize (
		 [id]				int identity (1,1)
		,[databaseName]		sysname
		,[Drive]			varchar(3)
		,[Logical Name]		sysname
		,[Physical Name]    varchar(max)
		,[File Size MB]		decimal(38, 2)
		,[Space Used MB]    decimal(38, 2)
		,[Free Space]		decimal(38, 2)
		,[%Free Space]		decimal(38, 2)
		,[Max Size]			varchar(max)
		,[Growth Rate]		varchar(max)
		)

    DECLARE @dbname			sysname
    DECLARE @freespacePct	int
    DECLARE @id				int
    DECLARE @sqltext		nvarchar(max)
    DECLARE @threshold		int



    --set @threshold = 20   --->>>>>>>>>>>>>>>>> CHANGE HERE <<<<<<<<<<<<<<<<<<<<<---
    SET @threshold = 20;   --->>>>>>>>>>>>>>>>> CHANGE HERE <<<<<<<<<<<<<<<<<<<<<---

    SELECT @dbname = min(name) 
		FROM sys.databases 
	WHERE database_id > 4 AND
		 [state] = 0; 

    WHILE @dbname IS NOT NULL
		BEGIN
			SELECT @dbname = name 
				FROM sys.databases 
			WHERE name = @dbname AND 
					database_id > 4 AND
					 [state] = 0 ;


			SET @sqltext =  ' USE ['+@dbname+'];'+' 
					INSERT INTO dbo.#dbserversize
						 SELECT '''+@dbname+'''  AS [databaseName]
							 ,substring([physical_name], 1, 3) AS [Drive]
							 ,[name] AS [Logical Name]
							 ,[physical_name] AS [Physical Name]
							 ,CAST(CAST([size] AS decimal(38, 2)) / 128.0 AS decimal(38, 2)) AS [File Size MB]
							,CAST(CAST(FILEPROPERTY([name], ''SpaceUsed'') AS decimal(38, 2)) / 128.0 AS decimal(38, 2)) AS [Space Used MB]
							,CAST((CAST([size] AS decimal(38, 0)) / 128) - (CAST(FILEPROPERTY([name], ''SpaceUsed'') AS decimal(38, 0)) / 128.) 
													AS decimal(38, 2)) AS [Free Space]
							,CAST(((CAST([size] AS decimal(38, 2)) / 128) - (CAST(FILEPROPERTY([name], ''SpaceUsed'') as decimal(38, 2)) / 128.0)) * 100.0 / (CAST([size] 
													AS decimal(38, 2)) / 128) AS decimal(38, 2)) AS [%Free Space]
							 ,CASE 
								 WHEN CAST([max_size] AS varchar(max)) = - 1
									THEN ''UNLIMITED''
								 ELSE CAST([max_size] AS varchar(max))
								 END AS [Max Size]
							 ,CASE 
								 WHEN is_percent_growth = 1
									THEN CAST([growth] as varchar(20)) + ''%''
								 ELSE CAST([growth] as varchar(20)) + ''MB''
								 END AS [Growth Rate]
							FROM sys.database_files
						 WHERE type = 0 -- for Rows , 1 = LOG;';

            ----------print @sqltext
            EXEC (@sqltext);


            SELECT @dbname = min(name) 
				FROM sys.databases 
			WHERE name > @dbname and database_id > 4 AND 
				[state] = 0 ;
		END

		------SELECT 'report ', *
		------	FROM #dbserversize;

    --- delete the entries that do not meet the threshold 

    DELETE FROM dbo.#dbserversize
		WHERE [%Free Space] > @threshold;
		----WHERE [%Free Space] < @threshold;


    SELECT * 
		FROM dbo.#dbserversize;

    --- NOW Raise errors for the databases that we got flagged up

    WHILE exists (SELECT null FROM dbo.#dbserversize)
		BEGIN

			SELECT TOP 1 @id = id,
			      @dbname = databaseName,
                  @freespacePct = [%Free Space]
                FROM dbo.#dbserversize;

				------------PRINT @dbname + ' ' + CONVERT(varchar(100),@freespacePct)
            RAISERROR(911421, 10,1,@freespacePct, @dbname) with LOG;

            DELETE FROM dbo.#dbserversize 
			WHERE id = @id;


END
GO
