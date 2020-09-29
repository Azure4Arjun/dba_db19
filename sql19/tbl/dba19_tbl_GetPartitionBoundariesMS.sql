SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_tbl_GetPartitionBoundariesMS
--
--
-- Calls:		None
--
-- Description:	Returns the boundary values for each partition in the PartitionTable.
-- 
-- https://docs.microsoft.com/en-us/sql/relational-databases/partitions/create-partitioned-tables-and-indexes?view=sql-server-2017
-- 
-- Date			Modified By			Changes
-- 06/13/2019   Aron E. Tekulsky    Initial Coding.
-- 06/13/2019   Aron E. Tekulsky    Update to Version 140.
-- 08/26/2020   Aron E. Tekulsky    Update to Version 150.
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

	SELECT t.name AS TableName, i.name AS IndexName, p.partition_number, p.partition_id, i.data_space_id, 
			f.function_id, f.type_desc, r.boundary_id, r.value AS BoundaryValue   
		FROM sys.tables AS t  
			JOIN sys.indexes AS i ON (t.object_id = i.object_id)
			JOIN sys.partitions AS p ON (i.object_id = p.object_id) AND
										(i.index_id = p.index_id)
			JOIN  sys.partition_schemes AS s ON (i.data_space_id = s.data_space_id)
			JOIN sys.partition_functions AS f ON (s.function_id = f.function_id)
			LEFT JOIN sys.partition_range_values AS r ON (f.function_id = r.function_id) and
															(r.boundary_id = p.partition_number  )
	WHERE i.type <= 1  
	ORDER BY p.partition_number;  
`	
END
GO
