SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_tbl_GetListTablesINViewsSO
--
--
-- Calls:		None
--
-- Description:	Get a list of all of the views in a database and each table that
--				is a part of the view.
--
-- https://stackoverflow.com/questions/12000999/how-to-list-the-source-table-name-of-columns-in-a-view-sql-server-2005
--
-- Date			Modified By			Changes
-- 09/24/2020   Aron E. Tekulsky    Initial Coding.
-- 09/24/2020   Aron E. Tekulsky    Update to Version 150.
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

	SELECT [VIEW_CATALOG]
		  ,[VIEW_SCHEMA]
		  ,[VIEW_NAME]
		  ,[TABLE_CATALOG]
		  ,[TABLE_SCHEMA]
		  ,[TABLE_NAME]
	  FROM [INFORMATION_SCHEMA].[VIEW_TABLE_USAGE]
  ORDER BY [VIEW_CATALOG]
      ,[VIEW_SCHEMA]
      ,[VIEW_NAME]
      ,[TABLE_CATALOG]
      ,[TABLE_SCHEMA]
      ,[TABLE_NAME] ASC;
END
GO
