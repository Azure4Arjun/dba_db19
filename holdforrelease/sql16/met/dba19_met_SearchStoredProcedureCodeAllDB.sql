SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_met_SearchStoredProcedureCodeAllDB
--
--
-- Calls:		None
--
-- Description:	Search for an object in all datbases.
-- 
-- Date			Modified By			Changes
-- 05/01/2020   Aron E. Tekulsky    Initial Coding.
-- 05/01/2020   Aron E. Tekulsky    Update to Version 150.
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

	DECLARE @Cmd			nvarchar(4000)
	DECLARE @DBName			nvarchar(128)
	DECLARE @ObjectToFind	nvarchar(128)


	DECLARE @SearchTable AS TABLE (
		DBName				nvarchar(128),
		ObjectName			nvarchar(128),
		ObjectId			int,
		SchemaId			int,
		Typ					Char(2),
		TypeDesc			nvarchar(60),
		CreateDate			datetime,
		ModifyDate			datetime,
		Definitn			nvarchar(max))

	-- Initialize
	SET @ObjectToFind = 'system_config_values';



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
					SELECT ' + '''' + @DBName + '''' + ' AS DBNam, p.name
							,p.object_id
							,p.Schema_id
							,p.type
							,p.type_desc
							,p.create_date
							,p.modify_date
							,m.definition
						FROM [' + @DBName + '].[sys].[procedures] p
							JOIN [' + @DBName + '].[sys].[sql_modules] m ON (m.object_id =  p.object_id)
					WHERE m.definition LIKE (' + '''' + '%' + @ObjectToFind + '%' + '''' + ');';

				PRINT @Cmd;

				INSERT INTO @SearchTable
					(DBName, ObjectName, ObjectId, SchemaId, Typ, TypeDesc, 
					CreateDate, ModifyDate, Definitn)
				EXEC (@Cmd);

				FETCH NEXT FROM db_cur INTO
					@dbname;
			END
	-- Close the cursor.
		CLOSE db_cur;

	-- Deallocate the cursor.
		DEALLOCATE db_cur;
				
		SELECT DBName, ObjectName, ObjectId, SchemaId, Typ, TypeDesc, 
				CreateDate, ModifyDate, Definitn,
				SUBSTRING(Definitn, CHARINDEX( @ObjectToFind ,Definitn) -30, 100) AS Details
			FROM  @SearchTable 
		ORDER BY DBName ASC, Typ ASC, ObjectName ASC;

END
GO
