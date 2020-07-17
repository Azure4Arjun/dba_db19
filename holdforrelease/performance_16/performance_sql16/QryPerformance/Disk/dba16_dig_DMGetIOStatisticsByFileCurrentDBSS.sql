SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_dig_DMGetIOStatisticsByFileCurrentDBSS
--
--
-- Calls:		None
--
-- Description:	This query helps you characterize your workload better from an I/O 
--				perspective for this database. Also, it helps you to determine whether 
--				you have an OLTP or DW/DSS type of workload.
-- 
-- https://www.sqlshack.com/how-to-analyze-storage-subsystem-performance-in-sql-server/
--
-- Date			Modified By			Changes
-- 10/17/2019   Aron E. Tekulsky    Initial Coding.
-- 10/17/2019   Aron E. Tekulsky    Update to Version 140.
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

	SELECT DB_NAME(DB_ID()) AS [DB_Name], 
				DFS.name AS [Logical_Name], 
				DIVFS.[file_id], 
			   DFS.physical_name AS [PH_Name], 
			   DIVFS.num_of_reads, 
			   DIVFS.num_of_writes, 
			   DIVFS.io_stall_read_ms, 
			   DIVFS.io_stall_write_ms, 
			   CAST(100. * DIVFS.io_stall_read_ms / (DIVFS.io_stall_read_ms + DIVFS.io_stall_write_ms) AS DECIMAL(10, 1)) AS [IO_Stall_Reads_Pct], 
			   CAST(100. * DIVFS.io_stall_write_ms / (DIVFS.io_stall_write_ms + DIVFS.io_stall_read_ms) AS DECIMAL(10, 1)) AS [IO_Stall_Writes_Pct], 
			   (DIVFS.num_of_reads + DIVFS.num_of_writes) AS [Writes + Reads], 
			   CAST(DIVFS.num_of_bytes_read / 1048576.0 AS DECIMAL(10, 2)) AS [MB Read], 
			   CAST(DIVFS.num_of_bytes_written / 1048576.0 AS DECIMAL(10, 2)) AS [MB Written], 
			   CAST(100. * DIVFS.num_of_reads / (DIVFS.num_of_reads + DIVFS.num_of_writes) AS DECIMAL(10, 1)) AS [# Reads Pct], 
			   CAST(100. * DIVFS.num_of_writes / (DIVFS.num_of_reads + DIVFS.num_of_writes) AS DECIMAL(10, 1)) AS [# Write Pct], 
			   CAST(100. * DIVFS.num_of_bytes_read / (DIVFS.num_of_bytes_read + DIVFS.num_of_bytes_written) AS DECIMAL(10, 1)) AS [Read Bytes Pct], 
			   CAST(100. * DIVFS.num_of_bytes_written / (DIVFS.num_of_bytes_read + DIVFS.num_of_bytes_written) AS DECIMAL(10, 1)) AS [Written Bytes Pct]
		FROM sys.dm_io_virtual_file_stats(DB_ID(), NULL) AS DIVFS
			 INNER JOIN sys.database_files AS DFS WITH(NOLOCK) ON DIVFS.[file_id] = DFS.[file_id];
			 
END
GO
