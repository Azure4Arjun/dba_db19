SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_dsk_DMGetDiskLatencyBO
--
--
-- Calls:		None
--
-- Description:	SQL Server tracks read and write speeds for each database file – 
--				both data and log files
-- 
-- https://www.brentozar.com/blitz/slow-storage-reads-writes/
--
--				This part of our SQL Server sp_Blitz script checks sys.dm_io_virtual_file_stats
--				looking for average read stalls (latency) over 200 milliseconds and average
--				write stalls over 100 milliseconds. Yes, those thresholds are
--				horrifically high.
--
--				At Microsoft SQL Customer Advisory Team – in point #4 in their Top 10 OLTP
--				Issues, they suggest that reads over 15ms are a bottleneck and that
--				log file writes should be 1ms or less.
--
--				There’s two ways to fix slow storage: make the storage go faster, or ask
--				the storage do to less work.
--
--				The second option – asking storage to do less work – is usually the easiest
--				way to start.  
--
--				By dropping unused indexes, we can insert/update/delete data faster,
--				run backups faster, do DBCCs faster, and even do index rebuild jobs 
--				faster.  By using the right indexes, we can avoid storage-intensive table
--				scans and do less data juggling in TempDB.
--
--				Legend
--				brilliant:				< 1ms
--				great:					< 5ms
--				good quality:		5	– 10ms
--				Poor:				10	– 20ms
--				horrific:			20	– 100ms
--				disgracefully bad: 100	– 500ms
--				WOW!:					> 500ms
-- 
-- Date			Modified By			Changes
-- 08/02/2019   Aron E. Tekulsky    Initial Coding.
-- 08/02/2019   Aron E. Tekulsky    Update to Version 140.
-- 05/12/2020	Aron E. Tekulsky	Add Legend.
-- 08/12/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
--
--  This code and information are provided "AS IS" without warranty of
--  any kind, either expressed or implied, including but not limited
--  to the implied warranties of merchantability and/or fitness for a
--  particular purpose.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT  DB_NAME(a.database_id) AS [Database Name] ,
		    b.name + N' [' + b.type_desc COLLATE SQL_Latin1_General_CP1_CI_AS + N']' AS [Logical File Name] ,
			UPPER(SUBSTRING(b.physical_name, 1, 2)) AS [Drive] ,
	        CAST(( ( a.size_on_disk_bytes / 1024.0 ) / (1024.0*1024.0) ) AS DECIMAL(9,2)) AS [Size (GB)] ,
		    a.io_stall_read_ms AS [Total IO Read Stall(ms)] ,
			a.num_of_reads AS [Total Reads] ,
	        CASE WHEN a.num_of_bytes_read > 0 
		        THEN CAST(a.num_of_bytes_read/1024.0/1024.0/1024.0 AS NUMERIC(23,1))
			    ELSE 0 
			END AS [GB Read],
	        CAST(a.io_stall_read_ms / ( 1.0 * a.num_of_reads ) AS INT) AS [Avg Read Stall (ms)] 
			,CASE 
				WHEN (
					a.num_of_reads = 0
					AND a.num_of_writes = 0
					)
					THEN ''
				ELSE 
					CASE 
						WHEN (a.io_stall / (a.num_of_reads + a.num_of_writes)) < 1 THEN 'Brilliant!'
						WHEN (a.io_stall / (a.num_of_reads + a.num_of_writes)) < 5 THEN 'Great!'
						WHEN (a.io_stall / (a.num_of_reads + a.num_of_writes)) >= 5 AND
							 (a.io_stall / (a.num_of_reads + a.num_of_writes)) < 10 THEN 'Good Quality!'
						WHEN (a.io_stall / (a.num_of_reads + a.num_of_writes)) >= 10 AND
							 (a.io_stall / (a.num_of_reads + a.num_of_writes)) < 20 THEN 'Poor!'
						WHEN (a.io_stall / (a.num_of_reads + a.num_of_writes)) >= 20 AND
							 (a.io_stall / (a.num_of_reads + a.num_of_writes)) < 100 THEN 'Horriffic!'
						WHEN (a.io_stall / (a.num_of_reads + a.num_of_writes)) >= 100 AND
							 (a.io_stall / (a.num_of_reads + a.num_of_writes)) < 500 THEN 'Disgracefully Bad!'
						WHEN (a.io_stall / (a.num_of_reads + a.num_of_writes)) > 500 THEN 'Wow!'
						ELSE ''
						END
			END AS [Legend],
		    CASE 
			    WHEN b.type = 0 THEN 30 /* data files */
				WHEN b.type = 1 THEN 5 /* log files */
	            ELSE 0
		    END AS [Max Rec Read Stall Avg],
			a.io_stall_write_ms AS [Total IO Write Stall(ms)] ,
	        a.num_of_writes [Total Writes] ,
		    CASE WHEN a.num_of_bytes_written > 0 
			    THEN CAST(a.num_of_bytes_written/1024.0/1024.0/1024.0 AS NUMERIC(23,1))
				ELSE 0 
	        END AS [GB Written],
		    CAST(a.io_stall_write_ms / ( 1.0 * a.num_of_writes ) AS INT) AS [Avg Write Stall (ms)] ,
			CASE 
				WHEN b.type = 0 THEN 30 /* data files */
	            WHEN b.type = 1 THEN 2 /* log files */
		        ELSE 0
			END AS [Max Rec Write Stall Avg] ,
	        b.physical_name AS [Physical File Name],
		    CASE
			    WHEN b.name = 'tempdb' THEN 'N/A'
				WHEN b.type = 1 THEN 'N/A' /* log files */
	            ELSE 'PAGEIOLATCH*'
		    END AS [Read-Related Wait Stat],
			CASE
				WHEN b.type = 1 THEN 'WRITELOG' /* log files */
	            WHEN b.name = 'tempdb' THEN 'xxx' /* tempdb data files */
		        WHEN b.type = 0 THEN 'ASYNC_IO_COMPLETION' /* data files */
	            ELSE 'xxx'
		    END AS [Write-Related Wait Stat],
			GETDATE() AS [Sample Time],
	        b.type_desc
		FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS a
			INNER JOIN sys.master_files AS b ON (a.file_id = b.file_id)
											AND (a.database_id = b.database_id)
	WHERE   a.num_of_reads > 0
			AND a.num_of_writes > 0
	ORDER BY  CAST(a.io_stall_read_ms / ( 1.0 * a.num_of_reads ) AS INT) DESC;

END
GO
