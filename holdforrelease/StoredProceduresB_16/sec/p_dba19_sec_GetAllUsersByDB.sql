USE [DBA_DB19]
GO

/****** Object:  StoredProcedure [dbo].[p_dba19_sec_GetAllUsersByDB]    Script Date: 3/22/2018 6:38:53 PM ******/
DROP PROCEDURE [dbo].[p_dba19_sec_GetAllUsersByDB]
GO

/****** Object:  StoredProcedure [dbo].[p_dba19_sec_GetAllUsersByDB]    Script Date: 3/22/2018 6:38:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ======================================================================================
-- p_dba19_sec_GetAllUsersByDB
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	p_dba19_met_GetCompleteSystemDBSpecs
--
-- Description:	Get a list of each of the users in each database.
-- 
-- Date			Modified By			Changes
-- 01/24/2013   Aron E. Tekulsky    Initial Coding.
-- 03/19/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE [dbo].[p_dba19_sec_GetAllUsersByDB] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    DECLARE @dbname	nvarchar(128),
			@cmd	nvarchar(4000)
    
    DECLARE @dbusers TABLE (
			dbname	nvarchar(128),
			userid	nvarchar(128),
			principal_id	int,
			utype			char(1),
			typ_desc		nvarchar(60),
			dschema			nvarchar(128),
			crdate			datetime,
			mdate			datetime,
			opid			int,
			sd				varbinary(85),
			ifixed			bit)  
    
    DECLARE db_cur CURSOR FOR
		SELECT d.name--, d.database_id, d.state_desc, d.state
			FROM sys.databases d
		WHERE d.state = 0 AND
				d.database_id > 4;
    
    OPEN db_cur;
    
    FETCH NEXT FROM db_cur
		 INTO @dbname;
		
	WHILE (@@FETCH_STATUS = 0 )
		BEGIN
		
			SET @cmd = 'SELECT ' + '''' + @dbname + '''' + ',[name], [principal_id],[type],[type_desc],[default_schema_name],
								[create_date],[modify_date],[owning_principal_id],[sid],[is_fixed_role]
							FROM [' + @dbname + '].[sys].[database_principals]
						WHERE type = ' + '''' + 'S' + '''' + ' AND
								principal_id > 2 AND
								sid IS NOT NULL;'
	    
	    PRINT @cmd;
	    
	    INSERT INTO @dbusers
			EXEC (@cmd);
	    	    
	    FETCH NEXT FROM db_cur 
			INTO @dbname;
	END
			
	SELECT '*** DB Users ***', *
		FROM @dbusers
	ORDER BY dbname ASC,
			userid ASC;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO

GRANT EXECUTE ON [dbo].[p_dba19_sec_GetAllUsersByDB] TO [db_proc_exec] AS [dbo]
GO


