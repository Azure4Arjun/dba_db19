SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_met_GetEstimateBackpSizeAllDBDetail
--
--
-- Calls:		None
--
-- Description:	Get an estimate of the size of a native full backup for all
--				db's on the server.
-- 
-- Date			Modified By			Changes
-- 01/01/2012	Aron E. Tekulsky	Initial Coding.
-- 05/14/2019   Aron E. Tekulsky    Update to Version 140.
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
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED



--WARNING! ERRORS ENCOUNTERED DURING SQL PARSING!
--------DECLARE @Spaceusedtable TABLE (
	CREATE TABLE #Spaceusedtable (
		DatabaseName		NVARCHAR(128)
		,DatabaseSize		DECIMAL(15, 2)
		,UnallocatedSpace	DECIMAL(15, 2)
		,ReservedPart		DECIMAL(15, 2) -- @reservedpages
		,DataPart			DECIMAL(15, 2)
		,IndexSize			DECIMAL(15, 2)
		,UnusedPart			DECIMAL(15, 2)
		,Pages				DECIMAL(15, 2)
		,logsize			DECIMAL(15, 2)
		,EstBackupSizeMB	DECIMAL(15, 2)
	)	

	DECLARE @Cmd			NVARCHAR(4000)
	DECLARE @dbname			SYSNAME
	DECLARE @dbsize			BIGINT
	DECLARE @id				INT -- The object id that takes up space
	DECLARE @logsize		BIGINT
	DECLARE @pages			BIGINT -- Working variable for size calc.
	DECLARE @reservedpages	BIGINT
	DECLARE @rowCount		BIGINT
	DECLARE @Status			VARCHAR(12)
	DECLARE @type			CHARACTER(2) -- The object type.
	DECLARE @TAbleName		NVARCHAR(128)
	DECLARE @usedpages		BIGINT

	SET @TAbleName = '#Spaceusedtable';

----------SET @dbname = 'test5';
----------SET @Cmd = 'USE [' + @dbname + '] ' + CHAR(13) + --'Go ' + CHAR(13) +
------' DECLARE @reservedpages bigint
------ DECLARE @usedpages bigint
------ DECLARE @pages bigint ' + CHAR(13) +
----------DECLARE @alwayson int
------------ create table to hold db names
---------- CREATE table #Temp (
---------- id int identity,
---------- name nvarchar(128),
---------- dbStatus nvarchar(128))
--IF [dba_db08].[dbo].[f_dba14_get_alwaysonnumeric] () = 1
----------SET @alwayson = 0;
-- populate table with db names
----------IF @alwayson = 1
---------- BEGIN
----------INSERT INTO #TEMP(name,dbstatus)

	DECLARE db_cur CURSOR FOR
		SELECT Name --,state_desc Status
			FROM sys.databases
		WHERE name NOT IN ('master','model','msdb','tempdb','OSSDBADB')
			AND state_desc = 'ONLINE'
			AND is_read_only <> 1 --means database=in read only mode
			AND CHARINDEX('-', name) = 0 --AND-- no dashes in dbname
	--[dba_db08].[dbo].[f_dba14_get_dbrole] (name) = 1
		ORDER BY NAME ASC;

----------END
	OPEN db_cur;

	FETCH NEXT FROM db_cur
		INTO 
			@dbname;

	WHILE (@@FETCH_STATUS <> - 1)
		BEGIN
			SET @Cmd = 'USE [' + @dbname + '] ' + CHAR(13) + 'SELECT ' + '''' + @dbname + '''' + ',
				sum(a.total_pages), -- @reservedpages
				sum(a.used_pages), -- @usedpages
				sum(
					CASE
						-- XML-Index and FT-Index and semantic index internal tables are not considered "data", but is part of "index_size"
						WHEN it.internal_type IN (202,204,207,211,212,213,214,215,216,221,222,236) THEN 0
						WHEN a.type <> 1 and p.index_id < 2 THEN a.used_pages
						WHEN p.index_id < 2 THEN a.data_pages
						ELSE 0
					END) -- @pages
			FROM ' + '[' + @dbname + '].sys.partitions p
				JOIN ' + '[' + @dbname + '].sys.allocation_units a ON (p.partition_id = a.container_id)
				LEFT JOIN [' + @dbname + '].sys.internal_tables it ON (p.object_id = it.object_id);'

	PRINT '1 is ' + @Cmd;

			INSERT INTO #Spaceusedtable (
				DatabaseName,
			------DatabaseSize,
			------UnallocatedSpace,
				ReservedPart
				,DataPart
				,Pages
				) --,
			------IndexSize,
			------UnusedPart,
			------EstBackupSizeMB)
			EXEC sp_executesql @Cmd
				,N'@eStatus varchar(12)'
				,@eStatus = @Status;

	-- Update with the dataabse size
			SET @Cmd = ' UPDATE [' + @TAbleName + '] ' + ' SET DatabaseSize = ' + '(SELECT sum(convert(bigint,case when status & 64 = 0 THEN size
					ELSE 0
					END))
				FROM [' + @dbname + '].dbo.sysfiles)'
				------(EXEC SET @dbsize = sp_executesql @Cmd, N'@eStatus varchar(12)',@eStatus = @Status )

	--------SET @dbsize =(
		PRINT '2 is '  + @Cmd;

			EXEC sp_executesql @Cmd
					,N'@eStatus varchar(12)'
					,@eStatus = @Status

	-- Update with the log size
		SET @Cmd = ' UPDATE [' + @TAbleName + '] ' + ' SET logsize = ' + '(SELECT sum(convert(bigint,case when status & 64 <> 0 THEN size
				ELSE 0
				END))
				FROM [' + @dbname + '].dbo.sysfiles)'

		PRINT '3 is ' + @Cmd;
	
		EXEC sp_executesql @Cmd
			,N'@eStatus varchar(12)'
			,@eStatus = @Status
			------SET @Cmd = ' UPDATE [' + @TAbleName + '] ' + ' SET DatabaseSize = ' +	------ ' (
				SELECT ((convert(DEC(15, 2), @dbsize) + convert(DEC(15, 2), @logsize)) * 8192 / 1048576)
					------ )'
				------PRINT @Cmd;
				------EXEC sp_executesql @Cmd, N'@eStatus varchar(12)', @eStatus=@Status
				--------------------INSERT INTO #Spaceusedtable (
				-------------------- ----------DatabaseName,
				-------------------- DatabaseSize,
				-------------------- UnallocatedSpace,
				-------------------- ReservedPart,
				-------------------- DataPart,
				-------------------- IndexSize,
				-------------------- UnusedPart,
				-------------------- EstBackupSizeMB)
				--------------------VALUES (
				-------------------- ----------db_name(),
				-------------------- ((convert (dec (15,2),@dbsize) + convert (dec(15, 2),@logsize) ) * 8192 / 1048576 ),-- DatabaseSize
		-------------------- (CASE WHEN @dbsize >= @reservedpages THEN
		-------------------- (convert (dec (15,2),@dbsize) - convert (dec(15,2)	,@reservedpages ) ) * 8192 / 1048576
		-------------------- ELSE 0 END), -- UnallocatedSpace
		-------------------- @reservedpages * 8192 / 1024, -- ReservedPart
		-------------------- @pages * 8192 / 1024, -- DataPart
		-------------------- ((@usedpages - @pages) * 8192 / 1024), -- IndexSize
		-------------------- ((@reservedpages - @usedpages) * 8192 / 1024) --UnusedPart
		-------------------- ,convert (dec (15,2),(convert (dec (15,2),(@reservedpages * 8192 / 1024) ) - convert(DEC(15, 2), ((@reservedpages - @usedpages) * 8192 / 1024)) ) / 1024 ) -- EstBackupSizeMB
		--------------------)

		--------SET @Cmd = ' UPDATE [' + @TAbleName + '] ' + ' SET EstBackupSizeMB = ' + 
		--------	'convert (dec (15,2),(convert (dec (15,2),(@reservedpages * 8192 / 1024) ) - convert(DEC(15, 2), ((@reservedpages - @usedpages) * 8192 / 1024)) ) / 1024 )'

		--------SET @Cmd = ' UPDATE [' + @TAbleName + '] ' + ' SET logsize = ' + '(SELECT sum(convert(bigint,case when status & 64 <> 0 THEN size
		--------		ELSE 0
		--------		END))
		--------		FROM [' + @dbname + '].dbo.sysfiles)'

		--------PRINT '4 is ' + @Cmd;
	
		--------EXEC sp_executesql @Cmd
		--------	,N'@eStatus varchar(12)'
		--------	,@eStatus = @Status

		-- works
	----------	SELECT DatabaseName, DatabaseSize, UnallocatedSpace	,ReservedPart
	----------	,DataPart ,(ReservedPart - Pages) * 8192 /1024 AS IndexSize 
	----------	,(ReservedPart - DataPart) * 8192 /1024 AS UnusedPart ,Pages
	----------	,logsize ,convert (dec (15,2),(convert (dec (15,2),(ReservedPart * 8192 / 1024) ) - 
	----------	convert(DEC(15, 2), ((ReservedPart - UnusedPart) * 8192 / 1024)) ) / 1024 ) AS EstBackupSizeMB
	----------FROM #Spaceusedtable



		FETCH NEXT FROM db_cur
			INTO @dbname;
	END

	CLOSE db_cur;

	DEALLOCATE db_cur;

	SELECT DatabaseName
			,DatabaseSize AS DatabaseSizeMB
			,UnallocatedSpace AS UnallocatedSpaceMB
			,(ReservedPart * 8192 / 1024) AS ReservedPartMB
			,(Pages * 8192 / 1024) AS DataPartMB
			,IndexSize AS IndexSizeMB
			,UnusedPart AS UnusedPartMB
			,Pages
			,logsize
			,convert (dec (15,2),(convert (dec (15,2),(ReservedPart * 8192 / 1024) ) - 
				convert(DEC(15, 2), ((ReservedPart - UnusedPart) * 8192 / 1024)) ) / 1024 ) AS EstBackupSizeMB
			,convert(DECIMAL(15, 2), EstBackupSizeMB / 1024) AS EstBackupSizeGB
		FROM #Spaceusedtable;

	DROP TABLE #Spaceusedtable;


END
GO
