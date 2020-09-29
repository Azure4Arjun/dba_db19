SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_xev_GetListofEvents
--
--
-- Calls:		None
--
-- Description:	list out all possible extended events and their descriptions.
-- 
-- https://docs.microsoft.com/en-us/sql/relational-databases/extended-events/extended-events?view=sql-server-ver15
--
-- Date			Modified By			Changes
-- 05/09/2020   Aron E. Tekulsky    Initial Coding.
-- 05/09/2020   Aron E. Tekulsky    Update to Version 150.
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

	SELECT
		 obj1.name as [XEvent-name],
		 col2.name as [XEvent-column],
		 obj1.description as [Descr-name],
		 col2.description as [Descr-column]
	  FROM sys.dm_xe_objects as obj1
		  JOIN sys.dm_xe_object_columns as col2 on col2.object_name = obj1.name
	  ORDER BY obj1.name, col2.name;
END
GO
