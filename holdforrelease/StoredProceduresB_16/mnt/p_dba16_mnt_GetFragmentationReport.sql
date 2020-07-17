USE [dba_db16]
GO

/****** Object:  StoredProcedure [dbo].[p_dba16_sys_GetFragmentationReport]    Script Date: 4/8/2013 12:27:40 PM ******/
DROP PROCEDURE [dbo].[p_dba16_sys_GetFragmentationReport]
GO

/****** Object:  StoredProcedure [dbo].[p_dba16_sys_GetFragmentationReport]    Script Date: 4/8/2013 12:27:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ==============================================================================
-- p_dba16_sys_GetFragmentationReport
--
-- Arguments:		None
--					None
--
-- Called BY:		None
-- Calls:			None
--
-- Description:	create fragmentation report. 
-- 
-- Date			Modified By			Changes
-- 10/27/2010   Aron E. Tekulsky    Initial Coding.
-- 04/19/2012	Aron E. Tekulsky	Update to v100.
-- 04/08/2013	Aron E. Tekulsky	Update to be non dynamic sql.
-- 07/27/2019	Aron E. Tekulsky	Update to v140.
-- ===============================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================

CREATE PROCEDURE [dbo].[p_dba16_sys_GetFragmentationReport] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @cmd nvarchar(4000)
	
	--SET @cmd = '	SELECT dbnam,schemaid, schemaname, objectid, objectname, indexid, indexname, indextype, 
 --         indexhold, partnm, avgfrag, disposit, alloc_unit_type_desc, index_level
	--FROM dba_db08.dbo.tmp_indexes
	--WHERE disposit <> ''Good'' '
	
	SELECT dbnam,schemaid, schemaname, objectid, objectname, indexid, indexname, indextype, 
          indexhold, partnm, avgfrag, disposit, alloc_unit_type_desc, index_level
		FROM dba_db16.dbo.tmp_indexes
	WHERE disposit <> 'Good' 
	
	--EXEC (@cmd)
END



GO

GRANT EXECUTE ON [dbo].[p_dba16_sys_GetFragmentationReport] TO [db_proc_exec] AS [dbo]
GO


