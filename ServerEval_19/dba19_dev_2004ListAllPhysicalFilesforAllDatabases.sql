SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_dev_2004ListAllPhysicalFilesforAllDatabases
--
--
-- Calls:		None
--
-- Description:	2004 - List all physical files for all databases.
--
-- From Edward Roepe - Perimeter DBA, LLC.  - www.perimeterdba.com
-- 
-- Date			Modified By			Changes
-- 03/31/2018   Aron E. Tekulsky    Initial Coding.
-- 06/10/2019   Aron E. Tekulsky    Update to Version 140.
-- 08/14/2020   Aron E. Tekulsky    Update to Version 150.
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

-- 2004 - List all physical files for all databases
-- Ed Roepe - 06/06/2012 - Original program
-- Ed Roepe - 07-01-2014 - Fix for large databases

	SELECT SERVERPROPERTY('ServerName') AS 'InstanceName', 
			SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS 'ComputerName', 
			a.name AS 'DatabaseName', 
			a.database_id AS 'DatabaseId', 
			SUSER_SNAME(a.owner_sid) AS 'DatabaseOwner', 
			b.type_desc AS 'Type', 
			b.data_space_id AS 'DataSpaceId', 
			b.name AS 'LogicalName', 
			b.physical_name AS 'PhysicalName', 
			b.state_desc AS 'State', 
			CONVERT(BIGINT, b.size * 8.0 / 1024) AS 'SizeMB',
			CASE b.is_percent_growth
				WHEN 1
				THEN 'Yes'
				WHEN 0
				THEN 'No'
				ELSE 'Error'
			END AS 'IsGrowthPercent', 
			b.growth AS 'FileGrowth',
			CASE
				WHEN b.is_percent_growth = 1
				THEN b.growth
				ELSE 0
			END AS 'FileGrowth (%)',
			CASE
				WHEN b.is_percent_growth = 0
				THEN b.growth / 128
				ELSE 0
			END AS 'FileGrowth (MB)',
			CASE b.max_size
				WHEN-1
				THEN 'Unlimited'
				WHEN 0
				THEN 'NoGrowth'
				WHEN 268435456
				THEN 'Log2TB'
				ELSE CONVERT(VARCHAR(20), b.max_size) -- 'Error'
			END AS 'MaxSize',
			CASE b.is_sparse
				WHEN 1
				THEN 'Yes'
				WHEN 0
				THEN 'No'
				ELSE 'Error'
			END AS 'IsSparse'
		FROM sys.databases AS a
			LEFT JOIN sys.master_files AS b ON a.database_id = b.database_id
	WHERE 0 = 0
        -- and a.name = 'tempdb'
	ORDER BY a.name;

END
GO
