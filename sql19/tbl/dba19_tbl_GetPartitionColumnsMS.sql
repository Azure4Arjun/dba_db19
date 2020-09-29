SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_tbl_GetPartitionColumnsMS
--
--
-- Calls:		None
--
-- Description:	Returns the name of the partitioning column for Partitioned Table.
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

	SELECT t.[object_id] AS ObjectID   
			, t.name AS TableName   
			, ic.column_id AS PartitioningColumnID   
			, c.name AS PartitioningColumnName   
		FROM sys.tables AS t   
			JOIN sys.indexes AS i ON (t.[object_id] = i.[object_id])
									AND (i.[type] <= 1) -- clustered index or a heap   
			JOIN sys.partition_schemes AS ps ON (ps.data_space_id = i.data_space_id)
			JOIN sys.index_columns AS ic ON (ic.[object_id] = i.[object_id])
											AND (ic.index_id = i.index_id)
											AND (ic.partition_ordinal >= 1) -- because 0 = non-partitioning column   
			JOIN sys.columns AS c ON (t.[object_id] = c.[object_id])
										AND (ic.column_id = c.column_id);

END
GO
