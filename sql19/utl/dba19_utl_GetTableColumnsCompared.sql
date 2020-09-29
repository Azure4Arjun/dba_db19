SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_utl_GetTableColumnsCompared
--
--
-- Calls:		None
--
-- Description:	Get a listing of all tables and their columns compared.
-- 
-- Date			Modified By			Changes
-- 12/12/2016   Aron E. Tekulsky    Initial Coding.
-- 01/01/2018	Aron E. Tekulsky	convert to v140.
-- 08/07/2019	Aron E. Tekulsky	add functionality to allow single db as 
--									well as cross db checking.
-- 08/08/2019	Aron E. Tekulsky	Add key and column constraints.
-- 08/26/2020   Aron E. Tekulsky    Update to Version 150.
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

	DECLARE @cmd			nvarchar(4000)
	DECLARE @dbname			nvarchar(128)

------DECLARE @Schematable2 TABLE (
------		[aschemakey]					int,
------		[aTABLE_CATALOG]			nvarchar(128),
------		[aTABLE_SCHEMA]				nvarchar(128),
------		[aTABLE_NAME]				nvarchar(128),
------		[aCOLUMN_NAME]				nvarchar(128),
------		[aDATA_TYPE]				nvarchar(128),
------		[aCHARACTER_MAXIMUM_LENGTH]	int,
------		[aIS_NULLABLE]				varchar(3),
------		[aORDINAL_POSITION]			int,
------		[bschemakey]					int,
------		[bTABLE_CATALOG]			nvarchar(128),
------		[bTABLE_SCHEMA]				nvarchar(128),
------		[bTABLE_NAME]				nvarchar(128),
------		[bCOLUMN_NAME]				nvarchar(128),
------		[bDATA_TYPE]				nvarchar(128),
------		[bCHARACTER_MAXIMUM_LENGTH]	int,
------		[bIS_NULLABLE]				varchar(3),
------		[bORDINAL_POSITION]			int
------)

	SET @dbname = 'dba_db16';


	TRUNCATE TABLE [dba_db16].[dbo].Schematable;
	TRUNCATE TABLE [dba_db16].[dbo].[SchematableCompared];

	IF @dbname = '' OR @dbname IS NULL
		BEGIN
			DECLARE db_cur CURSOR FOR
				SELECT Name--,state_desc Status
					FROM sys.databases
				WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb','ReportServer','ReportServerTempDB','dba_db16','SSISDB','QaAutomation','test','Medicube_nextGen', 'Analysis','QAXfer','BackupDB','DBA')
						AND state_desc = 'ONLINE'
						AND is_read_only <> 1 --means database=in read only mode
						AND	CHARINDEX('-',name) = 0 --AND-- no dashes in dbname
							--[dba_db08].[dbo].[f_dba14_get_dbrole] (name) = 1
				ORDER BY NAME ASC;
		END

	ELSE -- a specific db only.
		BEGIN
			DECLARE db_cur CURSOR FOR
				SELECT Name--,state_desc Status
					FROM sys.databases
				WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb','ReportServer','ReportServerTempDB','dba_db16','SSISDB','QaAutomation','test','Medicube_nextGen', 'Analysis','QAXfer','BackupDB','DBA')
						AND state_desc = 'ONLINE'
						AND is_read_only <> 1 --means database=in read only mode
						AND	CHARINDEX('-',name) = 0 --AND-- no dashes in dbname
							--[dba_db08].[dbo].[f_dba14_get_dbrole] (name) = 1
						AND name = @dbname
				ORDER BY NAME ASC;
		END


	OPEN db_cur;

	FETCH NEXT FROM db_cur INTO
		@dbname;

	WHILE (@@FETCH_STATUS <> -1)
		BEGIN
			SET  @cmd = '
				USE [' + @dbname + ']' + --CHAR(13) + 
			'				SELECT  isc.[TABLE_CATALOG]
				    ,isc.[TABLE_SCHEMA]
					,isc.[TABLE_NAME]
					,isc.[COLUMN_NAME]
					,isc.[DATA_TYPE]
					,isc.[CHARACTER_MAXIMUM_LENGTH]
					,isc.[IS_NULLABLE]
					,isc.[ORDINAL_POSITION]
					,isk.[CONSTRAINT_NAME] AS KCONSTRAINT_NAME
					,isu.CONSTRAINT_NAME AS UCONSTRAINT_NAME
				FROM [' + @dbname + '].[INFORMATION_SCHEMA].[COLUMNS] isc
					LEFT JOIN [' + @dbname + '].[INFORMATION_SCHEMA].[KEY_COLUMN_USAGE] isk ON (isk.TABLE_CATALOG = isc.TABLE_CATALOG )
																							AND (isk.TABLE_SCHEMA = isc.TABLE_SCHEMA )
																							AND (isk.TABLE_NAME = isc.TABLE_NAME )
																							AND (isk.COLUMN_NAME = isc.COLUMN_NAME )
					LEFT JOIN [' + @dbname + '].[INFORMATION_SCHEMA].[CONSTRAINT_COLUMN_USAGE] isu ON (isu.TABLE_CATALOG = isc.TABLE_CATALOG )
																								AND (isu.TABLE_SCHEMA = isc.TABLE_SCHEMA )
																								AND (isu.TABLE_NAME = isc.TABLE_NAME )
																								AND (isu.COLUMN_NAME = isc.COLUMN_NAME )
			ORDER BY isc.[TABLE_CATALOG], isc.[TABLE_SCHEMA], isc.[TABLE_NAME], isc.[ORDINAL_POSITION] ASC'

			----------	USE [' + @dbname + ']' + --CHAR(13) + 
			----------'SELECT  [TABLE_CATALOG]
			----------	    ,[TABLE_SCHEMA]
			----------		,[TABLE_NAME]
			----------		,[COLUMN_NAME]
			----------		,[DATA_TYPE]
			----------		,[CHARACTER_MAXIMUM_LENGTH]
			----------		,[IS_NULLABLE]
			----------		,[ORDINAL_POSITION]
			----------	FROM [' + @dbname + '].[INFORMATION_SCHEMA].[COLUMNS]
			----------ORDER BY [TABLE_CATALOG], [TABLE_SCHEMA], [TABLE_NAME], [ORDINAL_POSITION] ASC'

		----INSERT INTO @Schematable
			INSERT INTO [dba_db16].dbo.Schematable
				EXEC(@cmd);

			PRINT @cmd;

		
			FETCH NEXT FROM db_cur INTO
				@dbname;
		END

		CLOSE db_cur;

		DEALLOCATE db_cur;

	-------- test
	--------SELECT *
	--------	FROM [dba_db16].dbo.Schematable;
		----FROM @Schematable;
	------	-- end test


	IF @dbname = '' OR @dbname IS NULL
		BEGIN
			-- insert into local table with no duplicates.
			INSERT INTO [dba_db16].[dbo].[SchematableCompared]
					([aschemakey],[aTABLE_CATALOG], [aTABLE_SCHEMA], [aTABLE_NAME], [aCOLUMN_NAME], [aDATA_TYPE], [aCHARACTER_MAXIMUM_LENGTH], [aIS_NULLABLE],[aORDINAL_POSITION],[aKCONSTRAINT_NAME], [aUCONSTRAINT_NAME],
					[bschemakey],[bTABLE_CATALOG],  [bTABLE_SCHEMA],[bTABLE_NAME], [bCOLUMN_NAME], 	[bDATA_TYPE], [bCHARACTER_MAXIMUM_LENGTH], [bIS_NULLABLE], [bORDINAL_POSITION],[bKCONSTRAINT_NAME], [bUCONSTRAINT_NAME])
			SELECT  a.[schemakey],a.[TABLE_CATALOG] ,a.[TABLE_SCHEMA],a.[TABLE_NAME],a.[COLUMN_NAME],a.[DATA_TYPE],a.[CHARACTER_MAXIMUM_LENGTH],a.[IS_NULLABLE],a.[ORDINAL_POSITION], a.[KCONSTRAINT_NAME], a.[UCONSTRAINT_NAME]
					, b.[schemakey],b.[table_catalog] , b.[TABLE_SCHEMA], b.[table_name], b.[column_name], b.[DATA_TYPE], b.[CHARACTER_MAXIMUM_LENGTH],b.[IS_NULLABLE],b.[ORDINAL_POSITION], b.[KCONSTRAINT_NAME], b.[UCONSTRAINT_NAME]
				FROM dba_db16.dbo.Schematable a
					RIGHT JOIN dba_db16.dbo.Schematable b ON (b.[COLUMN_NAME] = a.[COLUMN_NAME])
			WHERE (b.table_catalog <> a.table_catalog)
				AND (b.[schemakey] NOT IN (
		------AND (a.[schemakey] NOT IN (
					------SELECT [bschemakey]	
					------	FROM [dba_db16].[dbo].[SchematableCompared]))
					SELECT [aschemakey]	
						FROM [dba_db16].[dbo].[SchematableCompared]))
				ORDER BY a.[TABLE_CATALOG]
				    ,a.[TABLE_SCHEMA]
					,a.[TABLE_NAME]
					,a.[ORDINAL_POSITION] ASC;
		END

	ELSE -- a specific db only.
		BEGIN
			-- insert into local table with no duplicates.
			INSERT INTO [dba_db16].[dbo].[SchematableCompared]
					([aschemakey],[aTABLE_CATALOG], [aTABLE_SCHEMA], [aTABLE_NAME], [aCOLUMN_NAME], [aDATA_TYPE], [aCHARACTER_MAXIMUM_LENGTH], [aIS_NULLABLE],[aORDINAL_POSITION],[aKCONSTRAINT_NAME], [aUCONSTRAINT_NAME],
					[bschemakey],[bTABLE_CATALOG],  [bTABLE_SCHEMA],[bTABLE_NAME], [bCOLUMN_NAME], 	[bDATA_TYPE], [bCHARACTER_MAXIMUM_LENGTH], [bIS_NULLABLE], [bORDINAL_POSITION],[bKCONSTRAINT_NAME], [bUCONSTRAINT_NAME])
			SELECT  a.[schemakey],a.[TABLE_CATALOG] ,a.[TABLE_SCHEMA],a.[TABLE_NAME],a.[COLUMN_NAME],a.[DATA_TYPE],a.[CHARACTER_MAXIMUM_LENGTH],a.[IS_NULLABLE],a.[ORDINAL_POSITION], a.[KCONSTRAINT_NAME], a.[UCONSTRAINT_NAME]
					, b.[schemakey],b.[table_catalog] , b.[TABLE_SCHEMA], b.[table_name], b.[column_name], b.[DATA_TYPE], b.[CHARACTER_MAXIMUM_LENGTH],b.[IS_NULLABLE],b.[ORDINAL_POSITION], b.[KCONSTRAINT_NAME], b.[UCONSTRAINT_NAME]
				FROM dba_db16.dbo.Schematable a
					RIGHT JOIN dba_db16.dbo.Schematable b ON (b.[COLUMN_NAME] = a.[COLUMN_NAME])
			WHERE (b.TABLE_NAME  <> a.TABLE_NAME )
				AND (b.[schemakey] NOT IN (
		------AND (a.[schemakey] NOT IN (
					------SELECT [bschemakey]	
					------	FROM [dba_db16].[dbo].[SchematableCompared]))
					SELECT [aschemakey]	
						FROM [dba_db16].[dbo].[SchematableCompared]))
				------ORDER BY a.[TABLE_CATALOG]
				------    ,a.[TABLE_SCHEMA]
				------	,a.[TABLE_NAME]
				------	,a.[ORDINAL_POSITION] ASC;
		END

		------SELECT [aschemakey],[aTABLE_CATALOG], [aTABLE_SCHEMA], [aTABLE_NAME], [aCOLUMN_NAME], [aDATA_TYPE], [aCHARACTER_MAXIMUM_LENGTH], [aIS_NULLABLE],[aORDINAL_POSITION],
		------		[bschemakey],[bTABLE_CATALOG],  [bTABLE_SCHEMA],[bTABLE_NAME], [bCOLUMN_NAME], 	[bDATA_TYPE], [bCHARACTER_MAXIMUM_LENGTH], [bIS_NULLABLE], [bORDINAL_POSITION]
		------	FROM [dba_db16].[dbo].[SchematableCompared] 

		SELECT isc.[aschemakey],isc.[aTABLE_CATALOG], isc.[aTABLE_SCHEMA], isc.[aTABLE_NAME], isc.[aCOLUMN_NAME], isc.[aDATA_TYPE], 
				isc.[aCHARACTER_MAXIMUM_LENGTH] AS AMaxLen, isc.[aIS_NULLABLE] AS ANull,isc.[aORDINAL_POSITION] AS AOrd,isc.[aKCONSTRAINT_NAME] AS AKYCon,isc.[aUCONSTRAINT_NAME] AS ACkCon,
				isc.[bschemakey],isc.[bTABLE_CATALOG],  isc.[bTABLE_SCHEMA],isc.[bTABLE_NAME], isc.[bCOLUMN_NAME], isc.[bDATA_TYPE], 
				isc.[bCHARACTER_MAXIMUM_LENGTH] AS BMaxLen, isc.[bIS_NULLABLE] AS BNull, isc.[bORDINAL_POSITION] AS BOrd, isc.[bKCONSTRAINT_NAME] AS BKYCon,isc.[bUCONSTRAINT_NAME] AS BCkCon
			FROM [dba_db16].[dbo].[SchematableCompared] isc

		ORDER BY isc.[aTABLE_CATALOG]
				    ,isc.[aTABLE_SCHEMA]
					,isc.[aTABLE_NAME]
					,isc.[aORDINAL_POSITION] ASC;


END
GO
