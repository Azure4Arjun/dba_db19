SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_tbl_GetTableOnFileGroupPhysicalLocation
--
--
-- Calls:		None
--
-- Description:	See which tables are on which file group and their actual physical location.
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

	SELECT  OBJECT_NAME(i.id)   AS [Table_Name]
		   , i.indid
		   ,CASE  i.indid
				WHEN 0 THEN 'Heap'
				WHEN 1 THEN 'Clustered'
				WHEN 2 THEN 'Non Clustered'
				WHEN 3 THEN 'XML'
				WHEN 4 THEN 'Spatial'
				ELSE 'Non Clustered'
			END AS Type
		   , i.[name]           AS [Index_Name]
		   , i.groupid
		   , f.name             AS [File_Group]
		   , d.physical_name    AS [File_Name]
		   , s.name             AS [Data_Space]
		   , CASE f.is_read_only
				WHEN 1 THEN 'read-only'
				WHEN 0 THEN 'read/write'
			END AS IsReadOnly 
		FROM sys.sysindexes i
			INNER JOIN sys.filegroups f ON (f.data_space_id = i.groupid)
									AND (f.data_space_id = i.groupid)
			INNER JOIN sys.database_files d ON (f.data_space_id = d.data_space_id)
			INNER JOIN sys.data_spaces s ON (f.data_space_id = s.data_space_id)
	WHERE OBJECTPROPERTY(i.id, 'IsUserTable') = 1
	ORDER BY f.name, OBJECT_NAME(i.id), groupid;
END
GO
