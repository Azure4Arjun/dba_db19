SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba16_idx_DMGetUnusedIndexe
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	List of unused indexes for each database.
-- 
-- Date			Modified By			Changes
-- 06/20/2012   Aron E. Tekulsky    Initial Coding.
-- 06/24/2012	Aron E. Tekulsky	Update to v100.
-- 03/05/2013	Aron E. Tekulsky	switch to using table variable.
-- 10/20/2015	Aron E. Tekulsky	Add server name.
-- 03/08/2018   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyrightę2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba16_idx_DMGetUnusedIndexe 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--CREATE TABLE dba_unused_indexes (
	--	dbname		nvarchar(128)	NULL,
	--	schema_nam	nvarchar(128)	NULL,
	--	obj_name	nvarchar(128)	NULL,
	--	idx_name	nvarchar(128)	NULL)
	
	--DECLARE @dba_unused_indexes TABLE (
	--		[dbname]			[nvarchar](128) NULL,
	--		[schema_nam]		[nvarchar](128) NULL,
	--		[obj_name]			[nvarchar](128) NULL,
	--		[idx_name]			[nvarchar](128) NULL,
	--		[idx_type]			[tinyint] NULL,
	--		[idx_type_desc]		[nvarchar](60) NULL,
	--		[is_primary_key]	[bit] NULL,
	--		[idx_id]			[int] NULL)


	DECLARE @cmd			nvarchar(4000)
	DECLARE @dbname			varchar(128)
	DECLARE @database_id	int	


	DECLARE db_cur CURSOR FOR
		SELECT name, database_id
			FROM sys.databases
		WHERE state = 0 AND  -- online
			database_id > 4 AND
			name NOT IN ('Analysis Services Repository'); 

	OPEN db_cur;

	FETCH NEXT FROM db_cur 
		INTO @dbname, @database_id;

	WHILE (@@FETCH_STATUS = 0)
		BEGIN
			SET @cmd = 	' USE [' + @dbname + '] ' +
					'; ' +

						--' INSERT INTO dba_db08.dbo.dba_unused_indexes 
						' INSERT INTO dba_db16.dbo.dba_unused_indexes 
							(servername,' +  'dbname, schema_nam, obj_name, idx_name,idx_type,  idx_type_desc, is_primary_key, idx_id) ' +
						'SELECT ' + '''' + @@servername + '''' + ', ' + '''' + @dbname + '''' + ' AS dbname, OBJECT_SCHEMA_NAME(I.OBJECT_ID,' + convert(varchar(4),@database_id) + ') AS SchemaName,
									OBJECT_NAME(I.OBJECT_ID,' + convert(varchar(4),@database_id) + ') AS ObjectName, I.NAME AS IndexName,
									i.type, i.type_desc, i.is_primary_key, i.index_id
							FROM [' + @dbname + '].sys.indexes I   
						WHERE OBJECTPROPERTY(I.OBJECT_ID, ' + '''' + 'IsUserTable' + '''' + ') = 1 -- only get indexes for user created tables
  							AND OBJECT_NAME(I.OBJECT_ID) <> ' + '''' + 'sysdiagrams' + '''' + 
							'AND I.NAME IS NOT NULL ' +
        -- find all indexes that exists but are NOT used
							'AND NOT EXISTS ( 
									 SELECT  index_id 
										FROM [' + @dbname +  '].sys.dm_db_index_usage_stats
									WHERE OBJECT_ID = I.OBJECT_ID 
										AND I.index_id = index_id 
                            -- limit our query only for the current db
										AND database_id =  ' + convert(varchar(4),@database_id) + ') 
										AND i.is_primary_key = 0 -- no primary keys
										AND i.index_id <> 1
						ORDER BY dbname, SchemaName, ObjectName, IndexName  ASC';


			PRINT @cmd;

			EXEC (@cmd);

			FETCH NEXT FROM db_cur 
				INTO @dbname, @database_id;

		END

	CLOSE db_cur;
	 
	DEALLOCATE db_cur;

	-- list all data.
	SELECT dbname, schema_nam, obj_name, idx_name, idx_type,  idx_type_desc, is_primary_key, idx_id
		--FROM dba_db08.dbo.dba_unused_indexes
		FROM dba_db16.dbo.dba_unused_indexes
	ORDER BY dbname, schema_nam, obj_name, idx_name ASC

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba16_idx_DMGetUnusedIndexe TO [db_proc_exec] AS [dbo]
GO
