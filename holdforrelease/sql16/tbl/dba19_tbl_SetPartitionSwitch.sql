SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_tbl_SetPartitionSwitch
--
--
-- Calls:		None
--
-- Description:	Partition Switching.
-- 
-- Date			Modified By			Changes
-- 11/07/2019   Aron E. Tekulsky    Initial Coding.
-- 11/07/2019   Aron E. Tekulsky    Update to Version 150.
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

	DECLARE @Cmd			nvarchar(4000);
	DECLARE @PartitionNum	tinyint;
	DECLARE	@SourceSchema	nvarchar(128);
	DECLARE	@SourceTable	nvarchar(128);
	DECLARE	@TargetSchema	nvarchar(128);
	DECLARE	@TargetTable	nvarchar(128);

	-- Initialization
	SET @PartitionNum	= 1;
	SET @SourceSchema	= 'dbo';
	SET @SourceTable	= 'Table_1nonpartitioned'; --Table_2_partitionnew';
	SET @TargetSchema	= 'dbo';
	SET @TargetTable	= 'Table_2nonpartitioned'; --Table_1_partitionold';

	-- Define the action
	SET @Cmd = '
		ALTER TABLE [' + @SourceSchema + '].[' + @SourceTable + '] SWITCH TO
			[' + @TargetSchema + '].[' + @TargetTable + ']' +
			'PARTITION ' + CONVERT(varchar(5), @PartitionNum) + ' ;';

	PRINT @Cmd;

	-- execute the script
	EXEC SP_EXECUTESQL @Cmd;


END
GO
