-- ======================================================================================
-- dba16_sys_GetSysConfigurations
--
--
-- Calls:		None
--
-- Description:	Det the Facets for sytem configuraion items.
-- 
-- Date			Modified By			Changes
-- 03/09/2017   Aron E. Tekulsky    Initial Coding.
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

	SELECT name, value, value_in_use, [description] 
		FROM sys.configurations
	--WHERE name like '%server memory%'
	ORDER BY name OPTION (RECOMPILE);

END
GO
