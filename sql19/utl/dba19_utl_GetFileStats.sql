SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_utl_GetFileStats
--
--
-- Calls:		None
--
-- Description:	Get the filestats to see file extent usage.
-- 
-- https://www.mssqltips.com/sqlservertip/1629/determine-free-space-consumed-space-and-total-space-allocated-for-sql-server-databases/
--
--
--				Page = 8Kb -----> Extent = 8 pages :: Extents = 64Kb
--				MB = 1024Kb :: MB = 16 Extents
--
-- Date			Modified By			Changes
-- 12/20/2019   Aron E. Tekulsky    Initial Coding.
-- 12/20/2019   Aron E. Tekulsky    Update to Version 150.
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

	DECLARE @FileStatTable AS TABLE (
		FileId			int,
		FileGroup		int,
		TotaLExtents	int,
		UsedExtents		int,
		LogicalName		nvarchar(128),
		FileName		nvarchar(128)
	)

	DECLARE @Cmd		nvarchar(4000)

	SET @Cmd = 'DBCC showfilestats;';

	INSERT INTO @FileStatTable (
		FileId, FileGroup, TotaLExtents, UsedExtents, LogicalName, FileName)
	EXEC (@Cmd);

	SELECT f.FileId, f.LogicalName,g.name AS FileGroup, f.FileName,
			f.TotaLExtents, CONVERT(decimal(20,2),f.TotaLExtents / 16.00) AS TotalMB,
			f.UsedExtents, CONVERT(decimal(20,2),f.UsedExtents / 16.00) AS UsedMB
		FROM @FileStatTable f
			JOIN sys.filegroups g ON (f.FileGroup = g.data_space_id );


END
GO
