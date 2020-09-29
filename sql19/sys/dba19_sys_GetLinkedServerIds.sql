SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sys_GetLinkedServerIds
--
--
-- Calls:		None
--
-- Description:	Get a listing of the linked server id's.
-- 
-- Date			Modified By			Changes
-- 01/22/2013   Aron E. Tekulsky    Initial Coding.
-- 10/22/2017   Aron E. Tekulsky    Update to Version 140.
-- 08/28/2020   Aron E. Tekulsky    Update to Version 150.
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

	SELECT s.server_id, s.name, l.remote_name, s.catalog, s.provider, s.data_source, s.catalog,s.is_data_access_enabled, s.is_remote_login_enabled, s.is_rpc_out_enabled,
		l.local_principal_id, l.remote_name, l.server_id, l.uses_self_credential
	FROM sys.servers s
		LEFT JOIN sys.linked_logins l ON (l.server_id = s.server_id)
	WHERE s.server_id > 0;

END
GO
