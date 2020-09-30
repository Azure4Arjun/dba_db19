SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_tbl_GetTotalTableSpaceOnDBCI
--
--
-- Calls:		None
--
-- Description:	check the space used by each table. For compression extimation.
--
-- https://codingsight.com/overview-of-data-compression-in-sql-server/
-- 
-- Date			Modified By			Changes
-- 12/06/2018	Aron E. Tekulsky	Initial Coding.
-- 05/17/2019   Aron E. Tekulsky    Update to Version 140.
-- 08/09/2019	Aron E. Tekulsky	Add Unused pages, Unused space, and fix decimals on mb.
--									Add schema name.
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

	SELECT t.NAME AS TableName
			,s.name AS SchemaName
			,i.name AS indexName
			,sum(p.rows) AS RowCounts
			,sum(a.total_pages) AS TotalPages
			,sum(a.used_pages) AS UsedPages
			,sum(a.total_pages) - sum(a.used_pages)  AS UnusedPages
			,sum(a.data_pages) AS DataPages
			,(CONVERT(decimal(20,2),sum(a.total_pages) * 8))  AS TotalSpaceKB
			,CONVERT(decimal(20,2),((CONVERT(decimal(20,2),(sum(a.total_pages) * 8)) / 1024.00))) AS TotalSpaceMB
			,(sum(a.used_pages) * 8) AS UsedSpaceKB
			,CONVERT(decimal(20,2),((CONVERT(decimal(20,2),(sum(a.used_pages) * 8)) / 1024))) AS UsedSpaceMB
			,(sum(a.total_pages) * 8) - (sum(a.used_pages) * 8) AS UnusedSpaceKB
			,CONVERT(decimal(20,2),((CONVERT(decimal(20,2),(sum(a.total_pages) * 8)) - CONVERT(decimal(20,2),(sum(a.used_pages) * 8))) / 1024)) AS UnusedSpaceMB
			,(sum(a.data_pages) * 8) AS DataSpaceKB
			,CONVERT(decimal(20,2),((CONVERT(decimal(20,2),(sum(a.data_pages) * 8)) / 1024))) AS DataSpaceMB
		FROM sys.tables t
			INNER JOIN sys.indexes i ON (t.OBJECT_ID = i.object_id)
			INNER JOIN sys.partitions p ON i.object_id = (p.OBJECT_ID)
										AND (i.index_id = p.index_id)
			INNER JOIN sys.allocation_units a ON (p.partition_id = a.container_id)
			INNER JOIN sys.schemas s ON (s.schema_id = t.schema_id )
	WHERE t.NAME NOT LIKE 'dt%'
			AND i.OBJECT_ID > 255
			AND i.index_id <= 1
	GROUP BY t.NAME
		,s.name
		,i.object_id
		,i.index_id
		,i.name
	ORDER BY TableName ASC, i.index_id ASC;
	----ORDER BY TotalSpaceMB DESC;


END
GO
