SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba16_idx_GetAllForeignKeys
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	get a list of all foreign key columns and what foreign key 
--						tables they correspond to.
-- 
-- Date			Modified By			Changes
-- 04/24/2007   Aron E. Tekulsky	Initial Coding.
-- 04/04/2012	Aron E. Tekulsky	Update to v100.
-- 03/19/2018   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba16_idx_GetAllForeignKeys 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    SELECT o.name AS table_name,
			o2.name AS fk_table,
--			index_col(o.name,f.fkey, 1) as fk_col,
			c.name AS fk_col,
			rt.name AS referenced_table,
			index_col(rt.name,f.rkey, 1) AS referenced_col
		FROM sys.sysobjects o
			JOIN sys.sysobjects o2 ON (o2.parent_obj = o.id)
			JOIN sys.sysforeignkeys f ON (o2.id = f.constid) 
			JOIN sys.sysobjects rt ON (f.rkeyid = rt.id)
			JOIN sys.syscolumns c ON (c.id = f.fkeyid) AND
									(c.colid = f.fkey)
    WHERE o.type = 'U' AND
    	  o2.type = 'F' AND
	      rt.type = 'U' 
    ORDER BY o.name, fk_col ASC;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba16_idx_GetAllForeignKeys TO [db_proc_exec] AS [dbo]
GO
