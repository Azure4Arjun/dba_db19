SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba16_sys_GetDiskDefragResultsNumeric
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get the numeric values of the disk defragmentation analysis.
-- 
-- Date			Modified By			Changes
-- 05/31/2012   Aron E. Tekulsky    Initial Coding.
-- 06/14/2012	Aron E. Tekulsky	Update to v100.
-- 03/31/2018   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba16_sys_GetDiskDefragResultsNumeric 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT f.drive_letter, 
	--		substring(f.frag_pct,1,charindex('Total',f.frag_pct,1)+4) AS disk_size,
	--		substring(f.frag_pct,charindex('Total',f.frag_pct,1)+7,(charindex('Free',f.frag_pct,1)-charindex('Total',f.frag_pct,1)-3)) AS disk_free,
	--		substring(f.frag_pct,charindex('Free',f.frag_pct,1)+7,(charindex('Fragmentation)',f.frag_pct,1)-charindex('Total',f.frag_pct,1)-3)) AS disk_fragmented,
			substring(f.frag_pct,1,charindex('Total',f.frag_pct,1)-5) AS disk_sizegb,
			substring(f.frag_pct,charindex('Total',f.frag_pct,1)+7,(charindex('GB',f.frag_pct,1)-5)) AS disk_freegb,
	--		substring(f.frag_pct,charindex('Total',f.frag_pct,1)+7,(charindex('GB',f.frag_pct,1)+2)) AS disk_freepct,
			substring(f.frag_pct,charindex('Free',f.frag_pct,1)+7,(charindex('% Fragmented ',f.frag_pct,1)-charindex('Free',f.frag_pct,1)-7)) AS disk_fragpct,
			substring(f.frag_pct,charindex('Fragmented',f.frag_pct,1)+12,2) AS file_fragpct,
			f.frag_decision, f.last_modified
		FROM [dbo].[dba_disk_fragmentation] f
	WHERE frag_pct NOT like ('Windows Disk Defragmenter%')
	ORDER BY f.drive_letter ASC,f.last_modified DESC;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba16_sys_GetDiskDefragResultsNumeric TO [db_proc_exec] AS [dbo]
GO
