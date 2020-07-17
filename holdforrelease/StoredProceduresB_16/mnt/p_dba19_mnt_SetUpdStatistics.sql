USE [dba_db19]
GO

/****** Object:  StoredProcedure [dbo].[p_dba19_mnt_SetUpdStatistics]    Script Date: 10/21/2016 2:50:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






-- ==============================================================================
-- p_dba19_mnt_SetUpdStatistics
--
-- Arguments:		@dbname	nvarchar(1000)
--					None
--
-- Called BY:		p_dba19_mnt_GetUpdStatisticsByDatabase
--
-- Calls:			None
--
-- Description:	Update the statistics.
-- 
-- Date				Modified By		Changes
-- 10/27/2010   Aron E. Tekulsky    Initial Coding.
-- 04/16/2012	Aron E. Tekulsky	Update to v100.
-- 10/21/2016	Aron E. Tekulsky	update to use [ and ] surrounding db name to
--									 catch db with - in name.
-- 01/30/2018   Aron E. Tekulsky    Update to V140.
-- 05/19/2020   Aron E. Tekulsky    Update to V150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================

CREATE PROCEDURE [dbo].[p_dba19_mnt_SetUpdStatistics] 
	-- Add the parameters for the stored procedure here
	     @Database		nvarchar(128),
	     @Schemaname	Varchar(100),  
		 @ObjectID		int,
		 @ObjectName	nvarchar(250)
		 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    
    
    DECLARE @command		nvarchar(4000)
    DECLARE @StartMessage	nvarchar(4000)
    DECLARE @errormsg		nvarchar(4000)
    DECLARE @errorvar		int

	PRINT 'Using database [' + @Database + '] and table [' + @ObjectName + ']';

    --SET @command = N'UPDATE STATISTICS ' + @Database + '.dbo.' + @ObjectName + ' WITH FULLSCAN;'
    --SET @command = N'UPDATE STATISTICS ' + @Database + '.dbo.['+@ObjectName+'] WITH FULLSCAN;'
    SET @command = N'UPDATE STATISTICS ' + '['+ @Database + '].['+ @schemaname+'].['+@ObjectName+'] WITH FULLSCAN;';
    
    print @command
    
	SET @StartMessage = ' UPDATING STATISTICS FOR:' + + '[' + @Database + '].[' + @schemaname +'].[' + @ObjectName + ']';
			RAISERROR(@StartMessage,10,1) WITH NOWAIT;
		 
	SET @errormsg = '';

	EXEC (@command);
	
	SET @errorvar = @@ERROR;
	
	SET @errormsg = convert(nvarchar(4000),@errorvar);
	
	IF (@errormsg) <> '' 
		BEGIN
			SET @errormsg = 'ERROR is : ' + @errormsg;
			RAISERROR(@errormsg, 10, 1) WITH NOWAIT;
		END
	
END






GO

GRANT EXECUTE ON [dbo].[p_dba19_mnt_SetUpdStatistics] TO [db_proc_exec] AS [dbo]
GO


