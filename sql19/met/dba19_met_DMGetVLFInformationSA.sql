SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_met_DMGetVLFInformationSA
--
--
-- Calls:		None
--
-- Description:	Get information about the VLF count and its size with the newly
--				introduced Dynamic Management Functions (DMF
--				Note - requires SQL 2016 SP2.
--
-- https://blog.sqlauthority.com/2018/02/18/get-vlf-count-size-sql-server-interview-question-week-161/
-- 
-- Date			Modified By			Changes
-- 04/02/2019	Aron E. Tekulsky	Initial Coding.
-- 05/14/2019   Aron E. Tekulsky    Update to Version 140.
-- 08/21/2020   Aron E. Tekulsky    Update to Version 150.
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

	SELECT [name], s.database_id, COUNT(l.database_id) AS 'VLF Count', SUM(vlf_size_mb) AS 'VLF Size (MB)',
			SUM(CAST(vlf_active AS INT)) AS 'Active VLF', SUM(vlf_active*vlf_size_mb) AS 'Active VLF Size (MB)',
			COUNT(l.database_id)-SUM(CAST(vlf_active AS INT)) AS 'In-active VLF',
			SUM(vlf_size_mb)-SUM(vlf_active*vlf_size_mb) AS 'In-active VLF Size (MB)'
		FROM sys.databases s
			CROSS APPLY sys.dm_db_log_info(s.database_id) l
	GROUP BY [name], s.database_id
	ORDER BY 'VLF Count' DESC;

END
GO
