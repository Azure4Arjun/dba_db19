SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_tbl_GetAllocationUnitsSO
--
--
-- Calls:		None
--
-- Description:	Get Allocation Units by file and partition.
-- 
-- https://stackoverflow.com/questions/20129001/see-what-data-is-in-what-sql-server-data-file
--
-- Date			Modified By			Changes
-- 12/17/2019   Aron E. Tekulsky    Initial Coding.
-- 12/17/2019   Aron E. Tekulsky    Update to Version 150.
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

	-- Get allocation units by file and partition
	SELECT 
		OBJECT_NAME(p.object_id) as my_table_name, 
		u.type_desc,
		f.file_id,
		f.name,
		f.physical_name,
		f.size,
		f.max_size,
		f.growth,
		u.total_pages,
		u.used_pages,
		u.data_pages,
		p.partition_id,
		p.rows
	FROM sys.allocation_units u 
		JOIN sys.database_files f ON( u.data_space_id = f.data_space_id )
		JOIN sys.partitions p ON( u.container_id = p.hobt_id)
	WHERE 
		----u.type IN (1, 3)  and 
		u.type IN (3)   -- 1 system, 3 user
		----OBJECT_NAME(p.object_id) = 'PageSplits'
END
GO
