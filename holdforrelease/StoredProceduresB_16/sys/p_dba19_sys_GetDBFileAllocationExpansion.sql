SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_sys_GetDBFileAllocationExpansion
--
-- Arguments:	@DbName nvarchar(128)
--				None
--
-- CallS:		None
--
-- Called BY:	p_dba19_sys_DMGetDBDiskSpaceByLogicalName
--				p_dba19_inf_SetMaxFileGroupSize
--
-- Description:	Get the existing db files sizes and the disk sizes for disks they sit on.
-- 
-- Date			Modified By			Changes
-- 12/01/2016   Aron E. Tekulsky    Initial Coding.
-- 02/17/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_sys_GetDBFileAllocationExpansion 
	-- Add the parameters for the stored procedure here
	@DbName nvarchar(128) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @command			nvarchar(4000)  
	DECLARE @DBLogicalFileName	nvarchar(128)
	DECLARE @DatabaseName		nvarchar(128)
	DECLARE @FileSizeMB			int
	DECLARE @Growth				int
	DECLARE @LogicalFileName	nvarchar(128)
	DECLARE @MaxUsable			bigint
	DECLARE @Maxsize			int

	DECLARE @MaxIncrements		int
	DECLARE @IncrementsToUse	int

	CREATE TABLE #DBInfo (
		ServerName				varchar(100),  --
		DatabaseName			nvarchar(128),  --
		FileSizeMB				int,  --
		LogicalFileName			sysname,  --
		PhysicalFileName		nvarchar(520), 
		FileGroup				nvarchar(128),--
		Status					sysname,  --
		Updateability			sysname,  
		RecoveryMode			sysname,  
		FreeSpaceMB				int,  --
		FreeSpacePct			varchar(7),  --
		maxsize					int,--
		growth					int,--
		statusval				int,
		StateDesc				nvarchar(60), 
		MaxSizeMB				numeric(20,3),
		GrowthAmt				numeric(20,3),
		FileType				tinyint,
		FileId					int)

--
-- Step 1 - Get the db files and their space information.
--

	SELECT @command = 'Use [' + @DBName + '] ' + CHAR(10) +
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


	SELECT *
		FROM #DBInfo;

--
-- Step 2 - curosr through the db info and get disk info for each
-- then execute the sp to get disk info.
--

	DECLARE db_cur CURSOR FOR 
		SELECT DatabaseName, LogicalFileName, FileSizeMB, Growth, Maxsize
			FROM #DBInfo;

	OPEN db_cur;

	FETCH NEXT FROM db_cur INTO
		@DatabaseName, @LogicalFileName, @FileSizeMB, @Growth, @Maxsize;

	WHILE (@@FETCH_STATUS <> -1)
		BEGIN
			SET @MaxUsable			= 0;
			SET @MaxIncrements		= 0;
			SET @IncrementsToUse	= 0;
		--
		-- check to determine if we need to change this device or skip it.
		--

		-- scenario 1 - file size = maxsize.

		IF @FileSizeMB = @Maxsize
			BEGIN
				EXEC p_dba19_sys_DMGetDBDiskSpaceByLogicalName @LogicalFileName, @DatabaseName, @MaxUsable OUTPUT;
				
				IF @MaxUsable > 0
					BEGIN
					-- 
					-- Step 3 - take the disk info and execute
					--

					-- calculate number of increments we can get out of disk. maxusable / growth
					SET @MaxIncrements = @MaxUsable / @Growth
					
					IF @MaxIncrements > 0 
						BEGIN

					-- see how many we want to use

						PRINT ' Old max sized is= ' + CONVERT(varchar(20),@Maxsize)

							IF @MaxIncrements > 5 SET @IncrementsToUse = (5 * @Growth)
							ELSE SET @IncrementsToUse = (@MaxIncrements* @Growth);

					-- add the new chunks to the existing total
							SET @Maxsize = @Maxsize + @IncrementsToUse;

						PRINT ' new max sized is= ' + CONVERT(varchar(20),@Maxsize)

						END

						PRINT 'file size = maxsize' + CHAR(10) + 'EXEC [dbo].[p_dba14_inf_SetMaxFileGroupSize] ' + @DatabaseName + ' , ' + @LogicalFileName + ' , ' +CONVERT(nvarchar(20), @Maxsize) + ' ; ' + CHAR(10)
						EXEC [p_dba19_inf_SetMaxFileGroupSize] @DatabaseName, @LogicalFileName, @Maxsize;
						----------EXEC [dbo].[p_dba14_inf_SetMaxFileGroupSize] @DatabaseName, @LogicalFileName, @MaxUsable;

					END
			END

		-- scenario 2 - file size < maxsize but file size + growth increment will go past maxsize.
		ELSE IF (@FileSizeMB < @Maxsize) AND ((@FileSizeMB + @Growth) >= @Maxsize)
				BEGIN
					EXEC p_dba19_sys_DMGetDBDiskSpaceByLogicalName @LogicalFileName, @DatabaseName, @MaxUsable OUTPUT;
				
					IF @MaxUsable > 0
						BEGIN
						-- 
						-- Step 3 - take the disk info and execute
						--

					-- calculate number of increments we can get out of disk. maxusable / growth
							SET @MaxIncrements = @MaxUsable / @Growth
					
							IF @MaxIncrements > 0 
								BEGIN
					-- see how many we want to use

						PRINT ' Old max sized is< ' + CONVERT(varchar(20),@Maxsize)

									IF @MaxIncrements > 5 SET @IncrementsToUse = (5 * @Growth)
									ELSE SET @IncrementsToUse = (@MaxIncrements* @Growth);

					-- add the new chunks to the existing total
									SET @Maxsize = @Maxsize + @IncrementsToUse;

						PRINT ' new max sized is< ' + CONVERT(varchar(20),@Maxsize)


								END


							PRINT 'file size < maxsize but file size + growth increment will go past maxsize' +  CHAR(10) + 'EXEC [dbo].[p_dba14_inf_SetMaxFileGroupSize] ' + @DatabaseName + ' , ' + @LogicalFileName + ' , ' +CONVERT(nvarchar(20), @Maxsize) + ' ; ' + CHAR(10)
							EXEC [p_dba19_inf_SetMaxFileGroupSize] @DatabaseName, @LogicalFileName, @Maxsize;
							------------EXEC [dbo].[p_dba14_inf_SetMaxFileGroupSize] @DatabaseName, @LogicalFileName, @MaxUsable;

						END
				END

		-- scenario 3 - (file size + growth) < maxsize.
		----------ELSE  
		----------	BEGIN
		----------	END



		--PRINT char(10) + 'EXEC dba_db08.dbo.p_dba14_DMGetDBDiskSpaceByLogicalName ' + @LogicalFileName + ' , ' + @DatabaseName + ', ' + CONVERT(nvarchar(20),@MaxUsable) + ' OUTPUT;' + char(10)


			FETCH NEXT FROM db_cur INTO
				@DatabaseName, @LogicalFileName, @FileSizeMB, @Growth, @Maxsize;
		END

	CLOSE db_cur;

	DEALLOCATE db_cur;


	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_sys_GetDBFileAllocationExpansion TO [db_proc_exec] AS [dbo]
GO
