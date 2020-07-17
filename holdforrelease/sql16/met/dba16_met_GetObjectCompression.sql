SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_met_GetObjectCompression
--
--
-- Calls:		None
--
-- Description:	View compression settings for objects in the database.
--
-- https://codingsight.com/overview-of-data-compression-in-sql-server/
--
-- Date			Modified By			Changes
-- 12/06/2018   Aron E. Tekulsky    Initial Coding.
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

	SELECT S.name AS SchemaName, O.name AS ObjectName, I.name AS IndexName,
			I.type_desc AS IndexType, P.data_compression_desc AS Compression
		FROM sys.schemas AS S
			JOIN sys.objects AS O ON (S.schema_id = O.schema_id)
			JOIN sys.indexes AS I ON (O.object_id = I.object_id)
			JOIN sys.partitions AS P ON (I.object_id = P.object_id) AND
										(I.index_id = P.index_id)
	WHERE O.TYPE = 'U'
	ORDER BY S.name, O.name, I.index_id ASC;

END
GO
