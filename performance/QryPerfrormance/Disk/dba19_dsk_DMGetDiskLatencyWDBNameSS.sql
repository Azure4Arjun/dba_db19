SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_dig_DMGetDiskLatencyWDBNameSS
--
--
-- Calls:		None
--
-- Description:	information for reads and writes, in milliseconds and
--				based on my experience I found that the Latency above
--				20-25ms is usually a problem.
--
-- https://www.sqlshack.com/how-to-analyze-storage-subsystem-performance-in-sql-server/
--
-- 
-- Date			Modified By			Changes
-- 02/15/2019   Aron E. Tekulsky    Initial Coding.
-- 05/09/2019   Aron E. Tekulsky    Update to Version 140.
-- 10/17/2019	Aron E. Tekulsky	Renamed from dba16_dig_GetSqlShackDiskLatency.
-- 02/03/2020	Aron E. Tekulsky	Add detail to MP level.
-- 05/12/2020   Aron E. Tekulsky    Update to Version 150.
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

	CREATE TABLE #DiskInformation (
		DISK_Drive					char(100)
		,MP							varchar(128)
		,DBFile						varchar(128)
		,DISK_num_of_reads			bigint
		,DISK_io_stall_read_ms		bigint
		,DISK_num_of_writes			bigint
		,DISK_io_stall_write_ms		bigint
		,DISK_num_of_bytes_read		bigint
		,DISK_num_of_bytes_written	bigint
		,DISK_io_stall				bigint
		,DatabaseId					int
		)

	INSERT INTO #DiskInformation (
		DISK_Drive
		,MP
		,DBFile
		,DISK_num_of_reads
		,DISK_io_stall_read_ms
		,DISK_num_of_writes
		,DISK_io_stall_write_ms
		,DISK_num_of_bytes_read
		,DISK_num_of_bytes_written
		,DISK_io_stall
		,DatabaseId
		)

	SELECT LEFT(UPPER(mf.physical_name), 2) AS DISK_Drive
			,SUBSTRING(UPPER(mf.physical_name), 4, CHARINDEX('\', mf.physical_name,4) -4) AS MP2
			,SUBSTRING(UPPER(mf.physical_name), CHARINDEX('\', mf.physical_name,4) +1, LEN(mf.physical_name) -3) AS DBFile
			,SUM(num_of_reads) AS DISK_num_of_reads
			,SUM(io_stall_read_ms) AS DISK_io_stall_read_ms
			,SUM(num_of_writes) AS DISK_num_of_writes
			,SUM(io_stall_write_ms) AS DISK_io_stall_write_ms
			,SUM(num_of_bytes_read) AS DISK_num_of_bytes_read
			,SUM(num_of_bytes_written) AS DISK_num_of_bytes_written
			,SUM(io_stall) AS io_stall
			,mf.database_id 
		FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
			INNER JOIN sys.master_files AS mf WITH (NOLOCK) ON (vfs.database_id = mf.database_id)
															AND (vfs.file_id = mf.file_id)
	------GROUP BY mf.database_id, LEFT(UPPER(mf.physical_name), 2);
	GROUP BY mf.database_id, LEFT(UPPER(mf.physical_name), 2),
			SUBSTRING(UPPER(mf.physical_name), 4, CHARINDEX('\', mf.physical_name,4) -4),
			SUBSTRING(UPPER(mf.physical_name), CHARINDEX('\', mf.physical_name,4) +1, LEN(mf.physical_name) -3);

	SELECT db_name(databaseid) AS DBName
			,DISK_Drive
			,MP
			,DBFile
			,CASE 
				WHEN DISK_num_of_reads = 0
					THEN 0
				ELSE (DISK_io_stall_read_ms / DISK_num_of_reads)
			END AS [Read Latency]
			,CASE 
				WHEN DISK_io_stall_write_ms = 0
					THEN 0
				ELSE (DISK_io_stall_write_ms / DISK_num_of_writes)
			END AS [Write Latency]
			,CASE 
				WHEN (
					DISK_num_of_reads = 0
					AND DISK_num_of_writes = 0
					)
					THEN 0
				ELSE (DISK_io_stall / (DISK_num_of_reads + DISK_num_of_writes))
			END AS [Overall Latency]
			,CASE 
				WHEN DISK_num_of_reads = 0
					THEN 0
				ELSE (DISK_num_of_bytes_read / DISK_num_of_reads)
			END AS [Avg Bytes/Read]
			,CASE 
				WHEN DISK_io_stall_write_ms = 0
					THEN 0
				ELSE (DISK_num_of_bytes_written / DISK_num_of_writes)
			END AS [Avg Bytes/Write]
			,CASE 
				WHEN (
					DISK_num_of_reads = 0
					AND DISK_num_of_writes = 0
					)
					THEN 0
				ELSE ((DISK_num_of_bytes_read + DISK_num_of_bytes_written) / (DISK_num_of_reads + DISK_num_of_writes))
			END AS [Avg Bytes/Transfer]
		FROM #DiskInformation
	ORDER BY [Overall Latency] DESC, MP ASC, DBFile ASC
	OPTION (RECOMPILE);

	DROP TABLE #DiskInformation;

END
GO
