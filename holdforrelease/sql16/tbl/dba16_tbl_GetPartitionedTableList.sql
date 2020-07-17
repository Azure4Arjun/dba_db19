SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_tbl_GetPartitionedTableList
--
--
-- Calls:		None
--
-- Description:	Returns one or more rows if the tables are partitioned. If the table 
--				is not partitioned, no rows are returned.
-- 
-- https://docs.microsoft.com/en-us/sql/relational-databases/partitions/create-partitioned-tables-and-indexes?view=sql-server-2017
--
-- Date			Modified By			Changes
-- 06/13/2019   Aron E. Tekulsky    Initial Coding.
-- 06/13/2019   Aron E. Tekulsky    Update to Version 140.
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

	SELECT *   
		FROM sys.tables AS t   
			JOIN sys.indexes AS i ON (t.[object_id] = i.[object_id])
									AND (i.[type] IN (0,1))
			JOIN sys.partition_schemes ps ON (i.data_space_id = ps.data_space_id)
END
GO
