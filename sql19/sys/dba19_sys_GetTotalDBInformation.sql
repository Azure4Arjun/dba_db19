SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sys_GetTotalDBInformation
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 10/20/2016   Aron E. Tekulsky    Initial Coding.
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

-- Script for SQL2008 and up only

-- declare local variables
	DECLARE	@cmd				nvarchar(4000),
			@cmd2				nvarchar(4000),
			@dbname				nvarchar(128)

-- create the master table
	DECLARE @database_master TABLE (
		name					nvarchar(128),
		database_id				int,
		create_date				datetime,
		compatibility_level		tinyint,
		collation_name			nvarchar(128),
		state_desc				nvarchar(60),
		is_in_standby			bit,
		recovery_model_desc		nvarchar(60),
		page_verify_option_desc	nvarchar(60),
		dbowner					nvarchar(128))
	
-- create databse files table  max_size, growth, status
	DECLARE @database_devices TABLE (
		dbname				nvarchar(128),
		logicalname			nvarchar(128),
		type				tinyint,
		type_desc			nvarchar(60),
		physical_name		nvarchar(260),
		state				tinyint,
		state_desc			nvarchar(60),
		initialsize			int,
		spaceused			int,
		freespace			int,
		growth				int,
		max_size			varchar(128),
		IsPercentGrowth		int)
		--max_size				int)
			
		--FreeSpacePct		VARCHAR(7),  
		--FreeSpacePages		INT,  
		--PollDate			datetime,
		--statusval			int,

-- create indexes table
	DECLARE @database_indexes TABLE (
		dbname				nvarchar(128),
		obj_name			nvarchar(128),
		--id					int,
		--indid				smallint,
		--keycnt				smallint,
		rowcnt				bigint,
		name				nvarchar(128),
		rows				int)
	


-- first we get the basic database information - non system db only

	INSERT INTO @database_master
		SELECT d.name, d.database_id, d.create_date, d.compatibility_level, d.collation_name, --d.owner_sid,
				d.state_desc, d.is_in_standby, d.recovery_model_desc, d.page_verify_option_desc,
				l.name
			FROM sys.databases d
				JOIN sys.syslogins l ON (d.owner_sid = l.sid)
		WHERE database_id > 4  AND
			state = 0;
		
		
	--------------SELECT *
	--------------FROM @database_master;
	
	DECLARE db_cur CURSOR FOR
		SELECT name 
			FROM @database_master;
		
	OPEN db_cur;

	FETCH NEXT FROM db_cur
		INTO @dbname;
	
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
			SET @cmd = 
				'USE [' + @dbname + '] ; ' + 
				' SELECT ' + '''' + @dbname + '''' + ', f.name,f.type, f.type_desc, f.physical_name, f.state, f.state_desc, f.size*8/1024 as size, 
					 fileproperty(f.name, ''SpaceUsed'')*8/1024 as SpaceUsed,
					CAST(f.size/128.0 - CAST(FILEPROPERTY(f.name, ''SpaceUsed'') AS int)/128.0 AS int) AS FreeSpaceMB,
					CASE Is_Percent_Growth
						WHEN 0 THEN growth/128
						ELSE growth
					END as growth,
					CASE max_size
						WHEN 0 THEN ' + '''' + 'No Growth' + '''' + 
						'WHEN -1 THEN ' + '''' + 'File will grow until disk is full' + '''' + 
						'WHEN 268435456 THEN ' + '''' + ' Log file will grow to a maximum size of 2 TB.' + '''' +
						'ELSE convert(varchar(128),(max_size/128)) + ' + '''' + ' MB' + '''' + 
					'END as max_size,
					Is_Percent_Growth

					FROM [' + @dbname + '].sys.database_files f;'
			
			PRINT @cmd
			
			INSERT INTO  @database_devices
				EXEC (@cmd);
			
			SET @cmd2 = 'SELECT ' + '''' +  @dbname + '''' + 'AS dbname,object_name(id) AS tname ,rowcnt, name, rows 
				FROM [' + @dbname + '].sys.sysindexes 
			WHERE indid IN (1,0) AND OBJECTPROPERTY(id,' +  '''' + 'IsUserTable' +'''' + ') = 1 ' --+ 
			--' AND
			--rowcnt > 0'

			PRINT @cmd2
				
			INSERT INTO @database_indexes
				EXEC (@cmd2);

			FETCH NEXT FROM db_cur
				INTO @dbname;
		END
	--f.max_size, f.growth, f.is_percent_growth,
	CLOSE db_cur;
	DEALLOCATE db_cur;

		 --state_desc, initialsize AS DBSizeMB, growth as DBGrowthMB, spaceused AS DBSpaceUsedMB, CONVERT(decimal(5,2),(spaceused/initialsize)*100) AS DBSpaceUsedPCT,
	
	
	SELECT dbname, logicalname,--type,
		 type_desc, physical_name, --state,
		 state_desc, initialsize AS DBSizeMB, growth as DBGrowth, 
		 CASE IsPercentGrowth
			WHEN 1 THEN 'Pct'
			ELSE 'MB'
		END as GrowthType,
		 spaceused AS DBSpaceUsedMB, CONVERT(decimal(5,2),((CONVERT(decimal(10,3),spaceused)/initialsize)*100)) AS DBSpaceUsedPCT,
		  freespace AS DBFreeSpace, max_size AS MaxSizeMB
		FROM @database_devices
	WHERE type = 0
	ORDER BY logicalname ASC, type ASC;
	
	 
----------SELECT *
----------	FROM @database_indexes
			
			

END
GO
