SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_tbl_DBCompressionSC
--
--
-- Calls:		None
--
-- Description:	Get a list of all compressed tables in DB.
--
-- https://www.sqlservercentral.com/forums/topic/find-all-compressed-tables-in-database-script
-- 
-- Date			Modified By			Changes
-- 04/08/2019   Aron E. Tekulsky    Initial Coding.
-- 04/08/2019   Aron E. Tekulsky    Update to Version 140.
-- 08/25/2020   Aron E. Tekulsky    Update to Version 150.
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

	SELECT st.name, st.object_id, sp.partition_id, sp.partition_number, sp.data_compression, 
			sp.data_compression_desc 
		FROM sys.partitions SP
			INNER JOIN sys.tables ST ON st.object_id = sp.object_id
	WHERE data_compression <> 0;

END
GO
