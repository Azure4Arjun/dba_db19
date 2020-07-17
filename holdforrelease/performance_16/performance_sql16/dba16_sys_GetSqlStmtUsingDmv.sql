SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_GetSqlStmtUsingDmv
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 06/13/2013   Aron E. Tekulsky    Initial Coding.
-- 01/20/2018   Aron E. Tekulsky    Update to V140.
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

	SELECT SQLStatement       =
			SUBSTRING
				(qt.text,
					er.statement_start_offset/2,
				(CASE 
					WHEN er.statement_end_offset = -1
						THEN LEN(CONVERT(nvarchar(MAX), qt.text)) * 2
					ELSE er.statement_end_offset
                END - er.statement_start_offset)/2
			)
       
		FROM sys.dm_exec_requests er
			CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) AS qt
	WHERE er.session_id = 54;
END
GO
