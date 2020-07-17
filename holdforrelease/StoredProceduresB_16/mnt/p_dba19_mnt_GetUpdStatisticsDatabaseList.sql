USE [dba_db19]
GO

/****** Object:  StoredProcedure [dbo].[p_dba19_mnt_GetUpdStatisticsDatabaseList]    Script Date: 10/25/2016 9:10:09 AM ******/
DROP PROCEDURE [dbo].[p_dba19_mnt_GetUpdStatisticsDatabaseList]
GO

/****** Object:  StoredProcedure [dbo].[p_dba19_mnt_GetUpdStatisticsDatabaseList]    Script Date: 10/25/2016 9:10:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ===================================================================================
-- p_dba19_mnt_GetUpdStatisticsDatabaseList
--
-- Arguments:		None
--					None
--
-- Called BY:		None
--
-- Calls:			p_dba19_mnt_GetUpdStatisticsByDatabase @CurrentDatabase
--
-- Description:	list database to run with integrity checks .
-- 
-- Date			Modified By			Changes
-- 03/18/2011   Aron E. Tekulsky    Initial Coding.
-- 04/16/2012	Aron E. Tekulsky	Update to v100.
-- 06/13/2016	Aron E. Tekulsky	update to eliminate db in readonly mode or 
--									with dash in its name.
-- 06/17/2016	Aron E. Tekulsky	Add code to test for always on and primary 
--									or secondary role.
-- 06/17/2016	Aron E. Tekulsky	Update to v120.
-- 10/21/2016	Aron E. Tekulsky	update to accept - in db name and use [ ].
-- 10/25/2016	Aron E. Tekulsky	UPdate to use flag for execution.  
--									0 or Null is exit no run.  1 is run.	
--									Update returne values
--	10/25/2016	Aron E. Tekulsky	Update to add error handler.
--									0 FAILURE
--									1 SUCCESS
--									2 RETRY
--									3 CANCEL
-- 01/30/2018   Aron E. Tekulsky    Update to V140.
-- 05/19/2020   Aron E. Tekulsky    Update to V150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================

CREATE PROCEDURE [dbo].[p_dba19_mnt_GetUpdStatisticsDatabaseList] 
	-- Add the parameters for the stored procedure here
	@ExecutionFlag	int
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
		  name						nvarchar(1000), 
		  dbStatus					nvarchar(128))--,
		 --replica_id					uniqueidentifier)

-- check for execution status.
	IF ISNULL(@ExecutionFlag,0) <= 0
		RETURN 3; -- success


-- find out if server is runnig always on

	IF [dba_db19].[dbo].[f_dba19_utl_GetAlwaysOnNumeric] () = 1 
		SET @alwayson = 1;

-- populate table with db names

	IF @alwayson = 1
		BEGIN
			INSERT INTO #TEMP(name,dbstatus)--, replica_id)
				SELECT d.Name,d.state_desc Status--, d.replica_id
					FROM sys.databases d
				WHERE d.name NOT IN ('master', 'model', 'msdb', 'tempdb','Analysis Services Repository')
					AND d.state_desc = 'ONLINE'
					AND d.is_read_only <> 1 AND --means database=in read only mode
					--CHARINDEX('-',d.name) = 0 AND -- no dashes in dbname
					[dba_db19].[dbo].[f_dba19_utl_GetDBRole] (d.name) = 1 -- primary
				ORDER BY d.name ASC;
		END
	ELSE
		BEGIN
			INSERT INTO #TEMP(name,dbstatus)--, replica_id)
				SELECT d.Name,d.state_desc Status--, d.replica_id
					FROM sys.databases d
				WHERE d.name NOT IN ('master', 'model', 'msdb', 'tempdb','Analysis Services Repository')
					AND d.state_desc = 'ONLINE'
					AND d.is_read_only <> 1 --AND --means database=in read only mode
					------CHARINDEX('-',d.name) = 0 --AND -- no dashes in dbname
					--[dba_db08].[dbo].[f_dba14_get_dbrole] (d.name) = 1
				ORDER BY d.name ASC;
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
			PRINT 'current database is -1 [' + @CurrentDatabase + ']';

          -- call check for fragmentaion
			EXEC dba_db19.dbo.p_dba19_mnt_GetUpdStatisticsByDatabase @CurrentDatabase;
          
          -- call execute on fragmantation

			FETCH NEXT FROM db_cur
				INTO @CurrentDatabase;

		END

	CLOSE db_cur;
	DEALLOCATE db_cur;
	
	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

ErrorHandler:
	RETURN -1 


END




--GO
GRANT EXECUTE ON [dbo].[p_dba19_mnt_GetUpdStatisticsDatabaseList] TO [db_proc_exec] AS [dbo]

































GO


