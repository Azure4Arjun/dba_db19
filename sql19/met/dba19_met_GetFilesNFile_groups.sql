SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_met_GetFilesNFile_groups
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 05/09/2019   Aron E. Tekulsky    Initial Coding.
-- 09/09/2018   Aron E. Tekulsky    Update to Version 140.
-- 10/07/2019	Aron E. Tekulsky	Add FileID.
-- 08/24/2020   Aron E. Tekulsky    Update to Version 150.
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

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @Cmd			NVARCHAR(4000)
	DECLARE @DBName			NVARCHAR(128)
	DECLARE @DBNametoFind	NVARCHAR(128)

	DECLARE @DBTable TABLE (
		ServerName			NVARCHAR(128)
		,DBName				NVARCHAR(128)
		,LogicalName		NVARCHAR(128)
		,FileId				int
		,FileType			NVARCHAR(128)
		,FileGrp			NVARCHAR(128)
		,PhysicalName		NVARCHAR(128)
		,StateDesc			NVARCHAR(128)
		,InitialSize		BIGINT
		,AutoGrowth			BIGINT
		,MaxSize			BIGINT
		)

	-- set the name of the db to find
	SET @DBNametoFind = '';

	----SET @DBNametoFind = '';
	IF @DBNametoFind IS NULL
		OR @DBNametoFind = ''
		BEGIN
			DECLARE db_cur CURSOR
				FOR
					SELECT d.name
						FROM sys.databases d
					WHERE d.database_id > 4;
		END
	ELSE
		BEGIN
			DECLARE db_cur CURSOR
				FOR
					SELECT d.name
						FROM sys.databases d
					WHERE d.database_id > 4
						AND d.name = @DBNametoFind;
		END

	OPEN db_cur;

	FETCH NEXT
		FROM db_cur
			INTO @DBName;

	------PRINT @DBName;
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
			SET @Cmd = '
				SELECT ' + '''' + @@ServerName + '''' + ', ' + '''' + @DBName + '''' + ', f.name as LogicalName, f.[file_id] AS [File ID], f.type_desc AS FileType,g.name AS
						Filegroup,f.physical_name , f.state_desc ,
						(f.size * 8) /1024 AS "Initial Size (mb)", (growth* 8) /1024
						AS "Autogrowth(mb)",(CONVERT(bigint,f.max_size) *8)/1024 AS "Maxsize(mb)"
					FROM sys.master_files f
						LEFT JOIN sys.filegroups g ON (f.data_space_id = g.data_space_id )
				WHERE f.name LIKE (' + '''' + '%' + @DBName + '%' + '''' + ')
				ORDER BY f.type ASC;'

			----------WHERE f.name LIKE (' + '''' + '%OSSDBADB%' + '''' + ')
			PRINT @Cmd;

			INSERT INTO @DBTable
	
			EXEC (@Cmd);

			FETCH NEXT
				FROM db_cur
					INTO @DBName;
		END

	CLOSE db_cur;;

	DEALLOCATE db_cur;

	SELECT ServerName
			,DBName
			,LogicalName
			,FileId
			,FileType
			,FileGrp
			,PhysicalName
			,StateDesc
			,InitialSize
			,AutoGrowth
			,MaxSize
		FROM @DBTable
	----WHERE FileGrp = 'PRIMARY'
	----	AND MaxSize = 32;

-------- generate alter code
------	SET @Cmd = 'USE [master] ' + CHAR(13) + 'GO ' + CHAR(13) + 'ALTER DATABASE [OSSDBADB] MODIFY FILE ( NAME = N' + '''' + 'OSSDBADB' + '''' + ', MAXSIZE = 131072KB )'

------	PRINT @Cmd;
END
GO
