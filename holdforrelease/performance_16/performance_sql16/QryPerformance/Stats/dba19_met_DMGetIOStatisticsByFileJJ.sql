SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_met_DMGetIOStatisticsByFileJJ
--
--
-- Calls:		None
--
-- Description:	I/O Statistics by file for current database.
--
--				Jean Joseph
--
-- Date			Modified By			Changes
-- 10/08/2019   Aron E. Tekulsky    Initial Coding.
-- 10/08/2019   Aron E. Tekulsky    Update to Version 150.
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

	-- I/O Statistics by file for the current database (Query 35) (IO Stats By File)
	SELECT 'I/O Statistics by file' AS ReportName, DB_NAME(DB_ID()) AS [Database Name], 
			df.name AS [Logical Name], vfs.file_id, 
			df.physical_name AS [Physical Name], vfs.num_of_reads, vfs.num_of_writes, vfs.io_stall_read_ms, vfs.io_stall_write_ms,
			CAST(100. * vfs.io_stall_read_ms/(vfs.io_stall_write_ms + vfs.io_stall_read_ms) AS DECIMAL(10,1)) AS [IO Stall Reads Pct],
			CAST(100. * vfs.io_stall_write_ms/(vfs.io_stall_write_ms + vfs.io_stall_read_ms) AS DECIMAL(10,1)) AS [IO Stall Writes Pct],
			(vfs.num_of_reads + vfs.num_of_writes) AS [Writes + Reads], vfs.num_of_bytes_read, vfs.num_of_bytes_written,
			CAST(100. * vfs.num_of_reads/(vfs.num_of_reads + vfs.num_of_writes) AS DECIMAL(10,1)) AS [# Reads Pct],
			CAST(100. * vfs.num_of_writes/(vfs.io_stall_write_ms + vfs.io_stall_read_ms) AS DECIMAL(10,1)) AS [# Wrtites Pct],
			CAST(100. * vfs.num_of_bytes_read/(vfs.num_of_bytes_read + vfs.num_of_bytes_written) AS DECIMAL(10,1)) AS [Read Bytes Pct],
			CAST(100. * vfs.num_of_bytes_written/(vfs.num_of_bytes_read + vfs.num_of_bytes_written) AS DECIMAL(10,1)) AS [Writeten Bytes Pct]
		FROM sys.dm_io_virtual_file_stats(DB_ID(),NULL) AS vfs
			INNER JOIN sys.database_files AS df WITH (NOLOCK) ON (vfs.file_id = df.file_id)
	OPTION (RECOMPILE);

END
GO
