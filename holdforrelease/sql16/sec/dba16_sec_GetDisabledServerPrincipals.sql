SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sec_GetDisabledServerPrincipals
--
--
-- Calls:		None
--
-- Description:	Get a listing of server principals that are disabled.
-- 
-- Date			Modified By			Changes
-- 02/08/2012   Aron E. Tekulsky    Initial Coding.
-- 10/22/2017   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyrightę2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	SELECT p.name, p.type, p.type_desc, p.is_disabled, p.create_date, p.modify_date, p.default_database_name
		FROM sys.server_principals p
	WHERE p.is_disabled = 1
	ORDER BY p.name ASC;

END
GO
