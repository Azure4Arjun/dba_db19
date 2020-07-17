SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16)_dig_GetSQLTEMPDBSize
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 06/13/2013	Aron E. Tekulsky	Initial Coding.
-- 05/14/2019   Aron E. Tekulsky    Update to Version 140.
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

	SELECT f.name AS LogicalName
			,f.physical_name
			,f.type_desc
			,f.state_desc
			,f.size * 1.0 / 128 AS FileSizeinMB
			,CASE f.max_size
				WHEN 0
					THEN 'No growth is allowed.'
				WHEN - 1
					THEN 'File will grow until the disk is Full'
				WHEN 268435456
					THEN 'Log file will grow to a maximum size of 2 TB.'
				ELSE CONVERT(VARCHAR(128), f.max_size * 1 / 128)
				END AS max_size
			,f.growth AS 'GrowthValue'
			,
			------'' =
			CASE 
				WHEN f.growth = 0
					THEN 'Size is fixed and will not grow.'
				WHEN f.growth > 0
					AND f.is_percent_growth = 0
					THEN 'Growth value is in 8-KB pages.'
				ELSE 'Growth value is a percentage.'
				END AS GrowthIncrement
		FROM tempdb.sys.database_files f
	ORDER BY f.type_desc DESC,f.file_id ASC;
END
GO
