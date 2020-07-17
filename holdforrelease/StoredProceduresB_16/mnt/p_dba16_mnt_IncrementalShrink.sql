SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba16_mnt_IncrementalShrink
--
-- Arguments:	@DBFileName
--				@TargetFreeMB
--				@ShrinkIncrementMB 
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	
-- 
-- https://www.sqlservercentral.com/blogs/sql-database-incremental-shrink-tsql
--
-- Date			Modified By			Changes
-- 12/11/2019   Aron E. Tekulsky    Initial Coding.
-- 12/11/2019   Aron E. Tekulsky    Update to Version 140.
-- 06/11/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba16_mnt_IncrementalShrink 
	-- Add the parameters for the stored procedure here
	@DBFileName			nvarchar(128), 
	@TargetFreeMB		int = 0,
	@ShrinkIncrementMB	int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	------declare @DBFileName sysname
	------declare @TargetFreeMB int
	------declare @ShrinkIncrementMBint

	DECLARE @sql	varchar(8000)
	DECLARE @SizeMB float
	DECLARE @UsedMB float

	-- Set Name of Database file to shrink
	SET @DBFileName = '';

	-- Set Desired file free space in MB after shrink
	SET @TargetFreeMB = 0;

	-- Set Increment to shrink file by in MB
	SET @ShrinkIncrementMB= 100;

	-- Show Size, Space Used, Unused Space, and Name of all database files
	SELECT [FileSizeMB] = CONVERT(numeric(10,2),ROUND(a.size/128.,2)),
		   [UsedSpaceMB]= CONVERT(numeric(10,2),ROUND(FILEPROPERTY( a.name,'SpaceUsed')/128.,2)) ,
		   [UnusedSpaceMB]= CONVERT(numeric(10,2),ROUND((a.size-FILEPROPERTY( a.name,'SpaceUsed'))/128.,2)) ,
		   [DBFileName]= a.name
	FROM sysfiles a;


	-- Get current file size in MB
	SELECT @SizeMB = size/128. 
		FROM sysfiles WHERE name = @DBFileName;

	-- Get current space used in MB
	SELECT @UsedMB = fileproperty( @DBFileName,'SpaceUsed')/128.0;

	-- Loop until file at desired size
	WHILE  (@SizeMB > (@UsedMB + @TargetFreeMB + @ShrinkIncrementMB))
		BEGIN
			 SET @sql = 'dbcc shrinkfile ( '+@DBFileName+', ' + 
				CONVERT(varchar(20),@SizeMB-@ShrinkIncrementMB)+' ) WITH NO_INFOMSGS';

			 PRINT 'Start ' + @sql + ' at ' + CONVERT(varchar(30),GETDATE(),121);

			 ----EXEC ( @sql );
			 PRINT @SQL -- testing

			 PRINT 'Done ' + @sql + ' at '+CONVERT(varchar(30),GETDATE(),121);

			 -- Get current file size in MB
			 SELECT @SizeMB = size/128. 
				FROM sysfiles WHERE name = @DBFileName;

			 -- Get current space used in MB
			 SELECT @UsedMB = FILEPROPERTY( @DBFileName,'SpaceUsed')/128.0;

			 PRINT 'SizeMB=' + CONVERT(varchar(20),@SizeMB) + ' UsedMB=' + CONVERT(varchar(20),@UsedMB);
		END

	SELECT [EndFileSize] = @SizeMB, [EndUsedSpace] = @UsedMB, [DBFileName] = @DBFileName;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba16_mnt_IncrementalShrink TO [db_proc_exec] AS [dbo]
GO
