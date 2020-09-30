SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_dig_GetAllFileStats
--
-- Arguments:	@dbname		sysname
--				@filenum	tinyint
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get detailed information about file stats for each db on the server.
-- 
-- Date			Modified By			Changes
-- 10/23/2013   Aron E. Tekulsky    Initial Coding.
-- 02/13/2018   Aron E. Tekulsky    Update to Version 140.
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
CREATE PROCEDURE p_dba19_dig_GetAllFileStats 
	-- Add the parameters for the stored procedure here
	@dbname		sysname,
	@filenum	tinyint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	--IF @dbname IS NULL AND @dbid IS NULL
	--	BEGIN
	--		GOTO ErrorHandler
	--	END
	DECLARE @vfs TABLE (
		database_id				smallint,
		file_id					smallint, 
		sample_ms				int, 
		num_of_reads			bigint, 
		num_of_bytes_read		bigint, 
		io_stall_read_ms		bigint, 
		num_of_writes			bigint, 
		num_of_bytes_written	bigint, 
		io_stall_write_ms		bigint, 
		io_stall				bigint, 
		size_on_disk_bytes		bigint,
		type					tinyint,
		type_desc				nvarchar(60))--, 
	--  file_handle				varbinary)

	INSERT INTO @vfs
		SELECT database_id,  file_id, sample_ms, num_of_reads, num_of_bytes_read, io_stall_read_ms,
				num_of_writes, num_of_bytes_written,
				io_stall_write_ms, io_stall, size_on_disk_bytes, 0,''--, file_handle
			FROM [sys].[dm_io_virtual_file_stats](db_id(@dbname),@filenum);


	SELECT  d.name, d.database_id, d.create_date, d.compatibility_level, d.state_desc,
			v.file_id, v.sample_ms, v.num_of_reads, v.num_of_bytes_read, v.io_stall_read_ms, v.num_of_writes, 
			v.num_of_bytes_written, v.io_stall_write_ms, v.io_stall, v.size_on_disk_bytes
		FROM @vfs v
			JOIN sys.databases d ON (d.database_id = v.database_id)
		ORDER BY d.database_id, v.file_id ASC;


	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
----GRANT EXECUTE ON p_dba19_dig_GetAllFileStats TO [db_proc_exec] AS [dbo]
----GO
