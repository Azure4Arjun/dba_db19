SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_dig_DMGetDiskLatency.sql
--
--
-- Calls:		None
--
-- Description:	Get a listing of all of the disk latency.
--
--				Values: < 8ms - Awesome
--				 9 - 12ms - Great
--				13 – 20 - Good/Fair
--					>=21 - Poor
-- 
-- Date			Modified By			Changes
-- 11/16/2018   Aron E. Tekulsky    Initial Coding.
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

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	SELECT [ReadLatency] =
			CASE
				WHEN [num_of_reads] = 0 THEN 0
				ELSE ([io_stall_read_ms] / [num_of_reads])
			END,
			[WriteLatency] =
			CASE WHEN [num_of_writes] = 0 THEN 0
				ELSE ([io_stall_write_ms] / [num_of_writes])
			END,
			[Latency] =
				CASE WHEN ([num_of_reads] = 0 AND [num_of_writes] = 0) THEN 0
					ELSE ([io_stall] / ([num_of_reads] + [num_of_writes]))
				END,
			[AvgBPerRead] =
				CASE WHEN [num_of_reads] = 0 THEN 0
					ELSE ([num_of_bytes_read] / [num_of_reads])
				END,
			[AvgBPerWrite] =
				CASE WHEN [num_of_writes] = 0 THEN 0
					ELSE ([num_of_bytes_written] / [num_of_writes])
				END,
			[AvgBPerTransfer] =
				CASE WHEN ([num_of_reads] = 0 AND [num_of_writes] = 0) THEN 0
					ELSE
						(([num_of_bytes_read] + [num_of_bytes_written]) / ([num_of_reads] + [num_of_writes]))
					END,
			LEFT ([mf].[physical_name], 2) AS [Drive],
			DB_NAME ([vfs].[database_id]) AS [DB],
			[mf].[physical_name]
		FROM sys.dm_io_virtual_file_stats (NULL,NULL) AS [vfs]
			JOIN sys.master_files AS [mf] ON [vfs].[database_id] = [mf].[database_id]AND [vfs].[file_id] = [mf].[file_id]
-- WHERE [vfs].[file_id] = 2 -- log files
-- ORDER BY [Latency] DESC
	ORDER BY [ReadLatency] DESC;

END
GO
