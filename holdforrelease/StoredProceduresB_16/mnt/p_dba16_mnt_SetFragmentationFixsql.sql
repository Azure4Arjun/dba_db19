SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba16_mnt_SetFragmentationFix
--
-- Arguments:	@Database		nvarchar(1000),
--				@SchemaID		int,
--				@SchemaName		nvarchar(250),
--				@ObjectID		int,
--				@ObjectName		nvarchar(250),
--				@IndexID		int,
--				@IndexName		nvarchar(250),
--				@Partnm			int,
--				@Frag			numeric(10,3)e
----
-- CallS:		None
--
-- Called BY:	p_dba16_mnt_GetGragmentationByDatabase
--
-- Description:	Take action to eliminate fragmentation.
-- 
-- Date			Modified By			Changes
-- 10/28/2010   Aron E. Tekulsky	Initial Coding.
-- 05/09/2011	Aron E. Tekulsky	Add square brackets surrounding objects.
-- 04/04/2012	Aron E. Tekulsky	Update to v100.
-- 11/09/2015	Aron E. Tekulsky	Change to online=on for rebuild.
-- 06/28/2016	Aron E. Tekulsky	Update to v120.
-- 06/28/2016	Aron E. Tekulsky	Increase size form 80 to 1000 for 
--									@Database.
-- 02/19/2018   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba16_mnt_SetFragmentationFix 
	-- Add the parameters for the stored procedure here
	@Database		nvarchar(1000),
	@SchemaID		int,
	@SchemaName		nvarchar(250),
	@ObjectID		int,
	@ObjectName		nvarchar(250),
	@IndexID		int,
	@IndexName		nvarchar(250),
	@Partnm			int,
	@Frag			numeric(10,3)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    --DECLARE @CurrentDatabase		nvarchar(1000)
    --DECLARE @CurrentSchemaID		int
    --DECLARE @CurrentObjectID		int
    --DECLARE @CurrentIndexID			int
    --DECLARE @CurrentIndexType		int
    --DECLARE @CurrentSchemaName		nvarchar(250)
    --DECLARE @CurrentObjectName		nvarchar(250)
    --DECLARE @CurrentIndexName		nvarchar(250)
    --DECLARE @CurerentPartnm			int
    --DECLARE	@AvgFrag				numeric(10,3)
    
    DECLARE @command		nvarchar(4000)
    DECLARE @StartMessage	nvarchar(4000)
    DECLARE @errormsg		nvarchar(4000)

	IF @Frag > 5.0 AND @Frag <= 30.0
	   Begin
		    SET @command = N'ALTER INDEX [' + @indexname + ']' + N' ON [' + @Database + '].[' + @schemaname + '].[' + @objectname + '] REORGANIZE WITH (LOB_COMPACTION = OFF)';
	
			SET @StartMessage = ' frag <= 30 :' + @command;
			RAISERROR(@StartMessage,10,1) WITH NOWAIT;
       End    
	        
	IF @Frag > 30.0
		Begin
			--SET @command = N'ALTER INDEX ' + @indexname + N' ON ' + @Database + '.' + @schemaname + N'.' + @objectname + N' REBUILD WITH (SORT_IN_TEMPDB = ON, ONLINE = ON)';
			--SET @command = N'ALTER INDEX ' + @indexname + N' ON ' + @Database + '.' + @schemaname + N'.' + @objectname + N' REBUILD WITH (SORT_IN_TEMPDB = OFF, ONLINE = ON)';
--			SET @command = N'ALTER INDEX ' + @indexname + N' ON ' + @Database + '.' + @schemaname + N'.' + @objectname + N' REBUILD WITH (SORT_IN_TEMPDB = ON, ONLINE = ON, PAD_INDEX=OFF, STATISTICS_NORECOMPUTE=OFF, ALLOW_ROW_LOCKS=ON, ALLOW_PAGE_LOCKS=ON)';

-- testing with change to online=off aet 05/4/11
			SET @command = N'ALTER INDEX [' + @indexname + ']' + N' ON [' + @Database + '].[' + @schemaname + N'].[' + @objectname + N'] REBUILD WITH (SORT_IN_TEMPDB = ON, ONLINE = OFF, PAD_INDEX=OFF, STATISTICS_NORECOMPUTE=OFF, ALLOW_ROW_LOCKS=ON, ALLOW_PAGE_LOCKS=ON)';
			--SET @command = N'ALTER INDEX [' + @indexname + ']' + N' ON [' + @Database + '].[' + @schemaname + N'].[' + @objectname + N'] REBUILD WITH (SORT_IN_TEMPDB = ON, ONLINE = ON, PAD_INDEX=OFF, STATISTICS_NORECOMPUTE=OFF, ALLOW_ROW_LOCKS=ON, ALLOW_PAGE_LOCKS=ON)';
				
			SET @StartMessage = 'frag > 30 : ' + @command;
			RAISERROR(@StartMessage,10,1) WITH NOWAIT;
		End   
		 
	SET @errormsg = '';
			
	EXEC (@command);
	
	SET @errormsg = convert(nvarchar(4000),@@ERROR);
	
	IF (@errormsg) <> '' 
		BEGIN
			SET @errormsg = 'ERROR is : ' + @errormsg;
			RAISERROR(@errormsg, 10, 1);
		END

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba16_mnt_SetFragmentationFix TO [db_proc_exec] AS [dbo]
GO
