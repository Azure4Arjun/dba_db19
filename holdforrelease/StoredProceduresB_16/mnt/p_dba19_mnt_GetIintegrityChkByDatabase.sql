USE [dba_db19]
GO

/****** Object:  StoredProcedure [dbo].[p_dba19_mnt_GetIintegrityChkByDatabase]    Script Date: 10/24/2016 9:46:56 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- ==============================================================================
-- p_dba19_mnt_GetIintegrityChkByDatabase
--
-- Arguments:		@dbname	nvarchar(1000)
--					None
--
-- Called BY:		p_dba19_mnt_GetIntegrityChkDatabaseList
--
-- Description:	Integrity checks. 
-- 
-- Date				Modified By			Changes
-- 10/27/2010   Aron E. Tekulsky	Initial Coding.
-- 04/05/2012	Aron E. Tekulsky	Update to v100.
-- 10/24/2016	Aron E. Tekulsky	Update to v110.  
--									add [] to dbnames.
--									change dbname to nvc(128)
-- 01/30/2018	Aron E. Tekulsky    Update to V140.
-- 05/19/2020	Aron E. Tekulsky    Update to V150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================

CREATE PROCEDURE [dbo].[p_dba19_mnt_GetIintegrityChkByDatabase] 
	-- Add the parameters for the stored procedure here
	@dbname	nvarchar(128)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @CurrentCommandSelect01	nvarchar(2000)
    DECLARE @CurrentDatabase		nvarchar(128)

    -- set current database to the value passed in
    SET @CurrentDatabase = @dbname ;        
         
    ------------SET @CurrentCommandSelect01 = ' DBCC CHECKDB ' + '(' +  '''' + '[' +
    SET @CurrentCommandSelect01 = ' DBCC CHECKDB ' + '(' +  '[' +
        @CurrentDatabase + ']' + 
        ------------@CurrentDatabase + ']' + ''''  +
        ' ,NOINDEX ' + ')' +
		' WITH ' +
        ' ALL_ERRORMSGS ;';
              
    PRINT @CurrentCommandSelect01;
      
	EXEC (@CurrentCommandSelect01);
      
	
END




--GO
GRANT EXECUTE ON [dbo].[p_dba19_mnt_GetIintegrityChkByDatabase] TO [db_proc_exec] AS [dbo]



GO


