USE [dba_db19]
GO

/****** Object:  StoredProcedure [dbo].[p_dba19_mnt_GetIntegrityChkDatabaseList]    Script Date: 10/24/2016 9:42:57 AM ******/
DROP PROCEDURE [dbo].[p_dba19_mnt_GetIntegrityChkDatabaseList]
GO

/****** Object:  StoredProcedure [dbo].[p_dba19_mnt_GetIntegrityChkDatabaseList]    Script Date: 10/24/2016 9:42:57 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- ==============================================================================
-- p_dba19_mnt_GetIntegrityChkDatabaseList
--
-- Arguments:		None
--					None
--
-- Called BY:		None
--
-- Calls:			p_dba19_get_integritychk_bydatabase @CurrentDatabase
--
-- Description:	list database to run with integrity checks 
-- 
-- Date				Modified By				Changes
-- 03/18/2011   Aron E. Tekulsky    	Initial Coding.
-- 04/05/2012	Aron E. Tekulsky		Update to v100.
-- 07/25/2016	Aron E. Tekulsky		Update to v120.
-- 07/25/2016	Aron E. Tekulsky		add support for always on and
--										db name nvc(1000).
-- 10/24/2016	Aron E. Tekulsky		set name back to nvc(128).  
--										Add [] to all dbnames.
-- 01/30/2018	Aron E. Tekulsky    Update to V140.
-- 05/19/2020	Aron E. Tekulsky    Update to V150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================

CREATE PROCEDURE [dbo].[p_dba19_mnt_GetIntegrityChkDatabaseList] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @CurrentDatabase		nvarchar(128)
    DECLARE @alwayson				int

-- create table to hold db names
    CREATE table #Temp (
          id						int identity,
		  name						nvarchar(128), 
		  dbStatus					nvarchar(128))

-- get alwayas on status
	IF [dba_db19].[dbo].[f_dba19_utl_GetAlwaysOnNumeric] () = 1 
		SET @alwayson = 1;

-- populate table with db names
	IF @alwayson = 1
		BEGIN

			INSERT INTO #TEMP(name,dbstatus)
					SELECT Name,state_desc Status
						FROM sys.databases
					WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb','Analysis Services Repository')
						AND state_desc = 'ONLINE'
						AND is_read_only <> 1 --means database=in read only mode
						--AND CHARINDEX('-',name) = 0 -- no dashes in dbname
						AND [dba_db16].[dbo].[f_dba19_utl_GetDBRole] (name) = 1
					ORDER BY name ASC;
		END
	ELSE
		BEGIN
			INSERT INTO #TEMP(name,dbstatus)
					SELECT Name,state_desc Status
						FROM sys.databases
					WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb','Analysis Services Repository')
						AND state_desc = 'ONLINE'
						AND is_read_only <> 1 --means database=in read only mode
						--AND CHARINDEX('-',name) = 0 -- no dashes in dbname
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
			Print '[' +  @CurrentDatabase + ']';

          -- call check for fragmentaion
			EXEC dba_db19.dbo.p_dba19_mnt_GetIintegrityChkByDatabase @CurrentDatabase;
          
          -- call execute on fragmantation

			FETCH NEXT FROM db_cur
				INTO @CurrentDatabase;

		END

	CLOSE db_cur;
	DEALLOCATE db_cur;
	
	

END




--GO
GRANT EXECUTE ON [dbo].[p_dba19_mnt_GetIntegrityChkDatabaseList] TO [db_proc_exec] AS [dbo]




















GO


