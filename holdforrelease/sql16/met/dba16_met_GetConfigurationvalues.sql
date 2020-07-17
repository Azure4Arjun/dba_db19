SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_met_GetConfigurationvalues
--
--
-- Calls:		None
--
-- Description:	Get a list of all configuration values for the SQL Server.
-- 
-- Date			Modified By			Changes
-- 01/09/2018   Aron E. Tekulsky    Initial Coding.
-- 01/09/2018   Aron E. Tekulsky    Update to V140.
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

	SELECT name as [Configuration Option]
			,value, value_in_use, [description]
		FROM sys.configurations
	ORDER BY name;
END
GO
