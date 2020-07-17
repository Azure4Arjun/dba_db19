SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_met_GetDBCapacityEstimate
--
--
-- Calls:		None
--
-- Description:	Get a listig of the databse capacity required for each db.
-- 
-- Date			Modified By			Changes
-- 09/25/2017   Aron E. Tekulsky    Initial Coding.
-- 11/22/2017   Aron E. Tekulsky    Update to Version 140.
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

/****** Script for SelectTopNRows command from SSMS  ******/
		DECLARE @cmd					nvarchar(4000)
		DECLARE @dbname					nvarchar(128)

		DECLARE @Schematable TABLE (
				[TABLE_CATALOG]			nvarchar(128),
				[TABLE_SCHEMA]			nvarchar(128),
				[TABLE_NAME]			nvarchar(128),
				[statcount]				bigint,
				[varcount]				bigint
		)

		DECLARE db_cur CURSOR FOR
			SELECT Name--,state_desc Status
				FROM sys.databases
			WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb')
					AND state_desc = 'ONLINE'
					AND is_read_only <> 1 --means database=in read only mode
					AND CHARINDEX('-',name) = 0 --AND-- no dashes in dbname
							--[dba_db08].[dbo].[f_dba14_get_dbrole] (name) = 1
			ORDER BY NAME ASC;

		OPEN db_cur;

		FETCH NEXT FROM db_cur INTO
			@dbname;

		WHILE (@@FETCH_STATUS <> -1)
			BEGIN
				SET  @cmd = '
					USE [' + @dbname + ']' + --CHAR(13) + 
				'SELECT  s.[TABLE_CATALOG]
					,s.[TABLE_SCHEMA]
					,s.[TABLE_NAME]
					,SUM(CASE  
						WHEN (s.[DATA_TYPE] = ' + '''' + 'varchar' + '''' + ') OR (s.[DATA_TYPE] = ' + '''' + 'nvarchar' + '''' + ') OR (s.[DATA_TYPE] = ' +  '''' + 'varbinary' + '''' + ') THEN
								0
						ELSE
							ISNULL(s.[CHARACTER_MAXIMUM_LENGTH], t.max_length) --AS CHARACTER_MAXIMUM_LENGTH
						END) AS statcount
					,SUM(CASE  
						WHEN (s.[DATA_TYPE] = ' + '''' + 'varchar' + '''' + ') OR (s.[DATA_TYPE] = ' + '''' + 'nvarchar' + '''' + ') OR (s.[DATA_TYPE] = ' +  '''' + 'varbinary' + '''' + ') THEN
							ISNULL(s.[CHARACTER_MAXIMUM_LENGTH], t.max_length) --AS CHARACTER_MAXIMUM_LENGTH
						ELSE
								0
						END) AS varcount
					FROM [' + @dbname + '].[INFORMATION_SCHEMA].[COLUMNS] s
						JOIN sys.types t ON (s.DATA_TYPE = t.name )
				WHERE s.[TABLE_NAME] IN (' + '''' + 'dba08_disaster_dblist' + '''' + 
										   +', ' + '''' + 'dba08_drive_limits' + '''' +
										   +', ' + '''' + 'dba08_excluded_ids' + '''' +
										   +', ' + '''' + 'dba08_ftp_server_list' + '''' +
										   +', ' + '''' + 'dba08_options' + '''' +
										   +', ' + '''' + 'dba08_server_disks' + '''' +
										   +', ' + '''' + 'dba08_server_info' + '''' +
										   +', ' + '''' + 'dba08_server_specs' + '''' +
										   +', ' + '''' + 'dba08_system_config_values' + '''' +
										   +', ' + '''' + 'dba08_system_config_values_history' + '''' +
										   +', ' + '''' + 'dbstatus_codes' + '''' +
										   +', ' + '''' + 'dbstatus2_codes' + '''' +
										   +', ' + '''' + 'sysdiagrams' + '''' +
										   --+', ' + '''' + 'sysdtslog90' + '''' +
										   +', ' + '''' + 'v_disasterdblist' + '''' +
										   +', ' + '''' + 'v_job_step_counts' + '''' +
										   +', ' + '''' + 'v_maxminjobstatus' + '''' +
				')
				GROUP BY s.[TABLE_CATALOG], s.[TABLE_SCHEMA], s.[TABLE_NAME]
				ORDER BY s.[TABLE_CATALOG], s.[TABLE_SCHEMA],s.[TABLE_NAME]'

				INSERT INTO @Schematable
					EXEC(@cmd);

					PRINT @cmd;

		
				FETCH NEXT FROM db_cur INTO
					@dbname;
			END

		CLOSE db_cur;

		DEALLOCATE db_cur;

		SELECT *
			FROM @Schematable;


END
GO
