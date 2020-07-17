SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_dig_DMGetIOUtilizationByDBSS
--
--
-- Calls:		None
--
-- Description:	This query will give us good indicator about which database is using
--				the most IO resources on my server.
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

	WITH AggregateIOStatistics
		 AS (SELECT DB_NAME(database_id) AS [DB Name], 
					CAST(SUM(num_of_bytes_read + num_of_bytes_written) / 1048576 AS DECIMAL(12, 2)) AS io_in_mb
				 FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS [DM_IO_STATS]
			 GROUP BY database_id)
		 SELECT ROW_NUMBER() OVER(
				ORDER BY io_in_mb DESC) AS [I/O Rank], 
					[DB Name], 
					io_in_mb AS [Total I/O (MB)], 
					CAST(io_in_mb / SUM(io_in_mb) OVER() * 100.0 AS DECIMAL(5, 2)) AS [I/O Percent]
			FROM AggregateIOStatistics
		 ORDER BY [I/O Rank];
END
GO
