USE [dba_db16]
GO

/****** Object:  StoredProcedure [dbo].[p_dba16_mnt_GetFragmentationDatabaseList]    Script Date: 6/28/2016 2:07:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- ==============================================================================
-- p_dba16_mnt_GetFragmentationDatabaseList
--
-- Arguments:		None
--					None
--
-- Called BY:		None
--
-- Calls:			p_dba16_mnt_GetFragmentationByDatabase
--
-- Description:	List database keys and fragmentation.
-- 
-- Date				Modified By			Changes
-- 10/27/2010   Aron E. Tekulsky	Initial Coding.
-- 04/04/2012	Aron E. Tekulsky	Update to v100.
-- 06/28/2016	Aron E. Tekulsky	Update to v120.
-- 06/28/2016	Aron E. Tekulsky	Increase size form 80 to 1000 for 
--									name in temp table.
-- 06/28/2016	Aron E. Tekulsky	Modify 	@CurrentCommandSelect01 & 
--									@CurrentCommandSelect02 to nvc(4000) AND
--									add test for always on.
-- 01/30/2018	Aron E. Tekulsky    Update to V140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================

CREATE PROCEDURE [dbo].[p_dba16_mnt_GetFragmentationDatabaseList] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @CurrentDatabase		nvarchar(1000)
	DECLARE @alwayson				int

-- create table to hold db names
    CREATE table #Temp (
          id						int identity,
		  name						varchar(1000), 
		  dbStatus					nvarchar(128))

	IF [dba_db16].[dbo].[f_dba16_utl_GetAlwaysOnNumeric] () = 1 
		SET @alwayson = 1;

-- populate table with db names
	IF @alwayson = 1
		BEGIN
			INSERT INTO #TEMP(name,dbstatus)
				SELECT Name,state_desc Status
					FROM sys.databases
				WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb')
					AND state_desc = 'ONLINE'
					AND is_read_only <> 1 --means database=in read only mode
					AND CHARINDEX('-',name) = 0 AND-- no dashes in dbname
					[dba_db16].[dbo].[f_dba16_utl_GetDBRole] (name) = 1
				ORDER BY name ASC;
		END
	ELSE
		BEGIN
			INSERT INTO #TEMP(name,dbstatus)
				SELECT Name,state_desc Status
					FROM sys.databases
				WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb')
					AND state_desc = 'ONLINE'
					AND is_read_only <> 1 --means database=in read only mode
					AND CHARINDEX('-',name) = 0 -- no dashes in dbname
				ORDER BY name ASC;
		END


	SELECT * 
		FROM #TEMP;

-- cursor for db
	DECLARE db_cur CURSOR FOR
			SELECT name
				FROM #TEMP;
			
	OPEN db_cur;
		
	FETCH NEXT FROM db_cur
			INTO @CurrentDatabase;
          
          
    WHILE (@@FETCH_STATUS <> -1)
		BEGIN
          -- call check for fragmentaion
          EXEC dba_db16.dbo.p_dba16_mnt_GetFragmentationByDatabase @CurrentDatabase
          
          -- call execute on fragmantation

			FETCH NEXT FROM db_cur
				INTO @CurrentDatabase;

		END

	CLOSE db_cur;
	DEALLOCATE db_cur;
	
	

END




--GO
GRANT EXECUTE ON [dbo].[p_dba16_mnt_GetFragmentationDatabaseList] TO [db_proc_exec] AS [dbo]




GO

GRANT TAKE OWNERSHIP ON [dbo].[p_dba16_mnt_GetFragmentationDatabaseList] TO [db_proc_exec] AS [dbo]
GO

GRANT VIEW DEFINITION ON [dbo].[p_dba16_mnt_GetFragmentationDatabaseList] TO [db_proc_exec] AS [dbo]
GO


