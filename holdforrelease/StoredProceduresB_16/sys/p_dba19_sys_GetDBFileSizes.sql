SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_sys_GetDBFileSizes
--
-- Arguments:	@DbName		nvarchar(128)
--				None
--
-- CallS:		p_dba19_inf_SetMaxFileGroupSize
--				p_dba19_sys_DMGetDBDiskSpaceByLogicalName
--
-- Called BY:	p_dba19_alt_Set1105Error
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 11/29/2016   Aron E. Tekulsky    Initial Coding.
-- 02/17/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_sys_GetDBFileSizes 
	-- Add the parameters for the stored procedure here
	@DbName		nvarchar(128)--,
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @command			nvarchar(4000)  
	DECLARE @DBLogicalFileName	nvarchar(128)
	DECLARE @MaxUsable			bigint
	DECLARE @growth				int
	DECLARE @statusval			int
	DECLARE @NumberofIncrements	int
	DECLARE @NewMaxSize			int
	DECLARE @MaxSize			int

	CREATE TABLE #DBInfo (
		ServerName				VARCHAR(100),  --
		DatabaseName			NVARCHAR(128),  --
		FileSizeMB				INT,  --
		LogicalFileName			sysname,  --
		PhysicalFileName		NVARCHAR(520), 
		FileGroup				nvarchar(128),--
		Status					sysname,  --
		Updateability			sysname,  
		RecoveryMode			sysname,  
		FreeSpaceMB				INT,  --
		FreeSpacePct			VARCHAR(7),  --
		maxsize					int,--
		growth					int,--
		statusval				int,
		StateDesc				nvarchar(60), 
		MaxSizeMB				Numeric(20,3),
		GrowthAmt				numeric(20,3),
		FileType				tinyint,
		FileId					int)

	CREATE TABLE #DBInfo2 (
		ServerName				VARCHAR(100),  --
		DatabaseName			NVARCHAR(128),  --
		LogicalFileName			sysname,  --
		PhysicalFileName		NVARCHAR(520), 
		FileGroup				nvarchar(128),--
		--Status					sysname,  --
		--Updateability			sysname,  
		RecoveryMode			sysname,  
		FreeSpaceMB				INT,  --
		FreeSpacePct			VARCHAR(7),  --
		FileSizeMB				INT,  --
		maxsize					int,--
		growth					int,--
		statusval				int,
		StateDesc				nvarchar(60), 
		--MaxSizeMB				Numeric(20,3),
		--GrowthAmt				numeric(20,3),
		FileType				tinyint,
		FileId					int)

------------SET @DBName = 'EDW'



	SELECT @command = 'Use [' + @DBName + '] ' + CHAR(10) +
		------------------'SELECT  
		------------------	@@servername as ServerName,  
		------------------	' + '''' + @DBName + '''' + ' AS DatabaseName,  
		------------------	CAST(f.size AS int) AS FileSize,  
		------------------	f.name AS LogicalFileName, f.physical_name AS PhysicalFileName, s.name,
		------------------	CONVERT(sysname,DatabasePropertyEx(' + '''' + @DBName + '''' +  ',''Status'')) AS Status,  
		------------------	CONVERT(sysname,DatabasePropertyEx('+ '''' + @DBName + '''' + ',''Updateability'')) AS Updateability,  
		------------------	CONVERT(sysname,DatabasePropertyEx('+ '''' + @DBName + '''' + ',''Recovery'')) AS RecoveryMode,  
		------------------	CAST(f.size - CAST(FILEPROPERTY(f.name, ' + '''' +  
		------------------	 'SpaceUsed' + '''' + ' ) AS int) AS int) AS FreeSpaceMB,  
		------------------	CAST(100 * (CAST (((f.size -CAST(FILEPROPERTY(f.name,  
		------------------		' + '''' + 'SpaceUsed' + '''' + ' ) AS int))/(f.size))  
		------------------	AS decimal(4,2))) AS varchar(8)) + ' + '''' +  '''' + ' AS FreeSpacePct, max_size, growth, [state] AS status, [state_desc] as StateDesc, 0, 0,
		------------------	f.type, file_id
		------------------FROM sys.database_files f ' + 
		------------------	'LEFT OUTER JOIN sys.data_spaces s ON (s.data_space_id = f.data_space_id)' 

		'SELECT  
			@@servername as ServerName,  
			' + '''' + @DBName + '''' + ' AS DatabaseName,  
			CAST(f.size/128.0 AS int) AS FileSize,  
			f.name AS LogicalFileName, f.physical_name AS PhysicalFileName, s.name,
			CONVERT(sysname,DatabasePropertyEx(' + '''' + @DBName + '''' +  ',''Status'')) AS Status,  
			CONVERT(sysname,DatabasePropertyEx('+ '''' + @DBName + '''' + ',''Updateability'')) AS Updateability,  
			CONVERT(sysname,DatabasePropertyEx('+ '''' + @DBName + '''' + ',''Recovery'')) AS RecoveryMode,  
			CAST(f.size/128.0 - CAST(FILEPROPERTY(f.name, ' + '''' +  
			 'SpaceUsed' + '''' + ' ) AS int)/128.0 AS int) AS FreeSpaceMB,  
			CAST(100 * (CAST (((f.size/128.0 -CAST(FILEPROPERTY(f.name,  
				' + '''' + 'SpaceUsed' + '''' + ' ) AS int)/128.0)/(f.size/128.0))  
			AS decimal(4,2))) AS varchar(8)) + ' + '''' +  '''' + ' AS FreeSpacePct, max_size/128 AS max_size, growth/128 AS growth, [state] AS status, [state_desc] as StateDesc, 0, 0,
			f.type, file_id
		FROM sys.database_files f ' + 
			'LEFT OUTER JOIN sys.data_spaces s ON (s.data_space_id = f.data_space_id)' 

	INSERT INTO #DBInfo  
	   (ServerName,  
	   DatabaseName,  
	   FileSizeMB,  
	   LogicalFileName,  
	   PhysicalFileName,
	   FileGroup,  
	   Status,  
	   Updateability,  
	   RecoveryMode,  
	   FreeSpaceMB,  
	   FreeSpacePct,
	   maxsize, 
	   growth , 
	   statusval,
	   StateDesc,
	   MaxSizeMB,
	   GrowthAmt,
	   FileType,
	   FileId)
	EXEC (@command);

	PRINT @command

	INSERT INTO #DBInfo2  
	   (ServerName,  
	   DatabaseName,  
	   LogicalFileName,  
	   PhysicalFileName,
	   FileGroup,  
	   --Status,  
	   --Updateability,  
	   RecoveryMode,  
	   FreeSpaceMB,  
	   FreeSpacePct,
	   FileSizeMB,
	   maxsize,  
	   growth,
	   --MaxSizeMB,
	   --GrowthAmt,
	   statusval,
	   StateDesc,
	   FileType,
	   FileId)
		SELECT  
			db.ServerName,
			db.DatabaseName as DBName,  
			db.LogicalFileName, --as DBLogicalFileName--,  
			db.PhysicalFileName as DBPhysicalFileName,  
			db.FileGroup ,
			db.RecoveryMode as DBRecoveryMode,  
			db.FreeSpaceMB as DBFreeSpaceMB,  
			db.FreeSpacePct as DBFreeSpacePct,
			db.FileSizeMB AS DBFileSizeMB,  
			maxsize, 
			growth, 
			statusval, 
			------------CASE maxsize
			------------	WHEN 0 THEN 'No Growth'
			------------	WHEN -1 THEN 'File will grow until disk is full'
			------------	WHEN 268435456 THEN ' Log file will grow to a maximum size of 2 TB.'
			------------	ELSE convert(varchar(128),(maxsize/128)) + ' MB'
			------------END as maxsize,
			------------CASE LEN(statusval)
			------------	WHEN 1 THEN
			------------		Convert(varchar(128),growth/128) + ' MB'
			------------	WHEN 2 THEN
			------------		Convert(varchar(128),growth/128) + ' MB'
			------------	ELSE
			------------		Convert(varchar(128),growth) + ' Percentage'
			------------END AS GrowthAmt,
			StateDesc,
			FileType,
			FileId
			FROM #DBInfo db
		WHERE db.DatabaseName not in (
				SELECT DatabaseName
					FROM #DBInfo DB) 
	UNION ALL
		SELECT  
			db.ServerName,
			db.DatabaseName as DBName,  
			db.LogicalFileName,   
			db.PhysicalFileName as DBPhysicalFileName,  
			db.FileGroup ,
			db.RecoveryMode as DBRecoveryMode,  
			db.FreeSpaceMB as DBFreeSpaceMB,  
			db.FreeSpacePct as DBFreeSpacePct,
			db.FileSizeMB AS DBFileSizeMB, 
			maxsize, 
			growth, 
			statusval,  
			------------CASE maxsize
			------------	WHEN 0 THEN 'No Growth'
			------------	WHEN -1 THEN 'File will grow until disk is full'
			------------	WHEN 268435456 THEN ' Log file will grow to a maximum size of 2 TB.'
			------------	ELSE convert(varchar(128),(maxsize/128)) + ' MB'
			------------END as maxsize,
			------------CASE LEN(statusval)
			------------	WHEN 1 THEN
			------------		Convert(varchar(128),growth/128) + ' MB'
			------------	WHEN 2 THEN
			------------		Convert(varchar(128),growth/128) + ' MB'
			------------	ELSE
			------------		Convert(varchar(128),growth) + ' Percentage'
			------------END AS GrowthAmt,
			StateDesc,
			FileType,
			FileId
			FROM #DBInfo db
		WHERE DatabaseName = @DBName
		ORDER BY db.DatabaseName, FileType, FileId ASC;

	DROP TABLE #DBInfo;

	------------SELECT @DBLogicalFileName = LogicalFileName
	SELECT *
		FROM #DBInfo2;

	-- now set up to cursor over list of devices for db and adjust each one.
	DECLARE db_cur CURSOR FOR
		SELECT LogicalFileName, growth, statusval, maxsize
			FROM #DBInfo2
		WHERE maxsize > 0 AND
			FileGroup IS NOT NULL AND
			FreeSpacePct < 40.00;

	OPEN db_cur;

	FETCH NEXT FROM db_cur
		INTO @DBLogicalFileName, @growth, @statusval, @MaxSize;

	WHILE (@@FETCH_STATUS <> -1)
		BEGIN
			EXEC p_dba19_sys_DMGetDBDiskSpaceByLogicalName  @DBLogicalFileName, @DbName, @MaxUsable OUTPUT

			PRINT 'The value is ' + CONVERT(varchar(20),@MaxUsable)

			-- calculate increase --
			SET @NumberofIncrements = ROUND(@MaxUsable / @growth,0)
			
			-- evaluate increments
			IF @NumberofIncrements > 5
				BEGIN
					SET @NewMaxSize = @MaxSize + (@growth * 5)
				END
			ELSE 
				BEGIN
					SET @NewMaxSize = @MaxSize + (@growth * @NumberofIncrements)
				END

			PRINT 'increments are ' + convert(varchar(20),@NumberofIncrements)
			-- now make a call to adjust space maximum --
			EXEC p_dba19_inf_SetMaxFileGroupSize @DbName, @DBLogicalFileName, @NewMaxSize

			FETCH NEXT FROM db_cur
				INTO @DBLogicalFileName, @growth, @statusval, @MaxSize;
		END

	CLOSE db_cur;
	DEALLOCATE db_cur;

	------------SET @DBLogical = @DBLogicalFileName;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_sys_GetDBFileSizes TO [db_proc_exec] AS [dbo]
GO
