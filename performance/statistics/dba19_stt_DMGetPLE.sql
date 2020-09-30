SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_stt_DMGetPLE
--
--
-- Calls:		None
--
-- Description:	Get the Page Life Expectancy of ther DB server.
-- 
-- Date			Modified By			Changes
-- 02/18/2018   Aron E. Tekulsky    Initial Coding.
-- 02/18/2018   Aron E. Tekulsky    Update to Version 140.
-- 08/13/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyrightę2001 - 2025 Aron Tekulsky.  World wide rights reserved.
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

	SELECT [object_name],
			[counter_name],
			[cntr_value] 
		FROM sys.dm_os_performance_counters
	WHERE [object_name] LIKE '%Manager%'
		AND [counter_name] = 'Page life expectancy';

END
GO
