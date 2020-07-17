SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sec_GetListAllDBWTDE
--
--
-- Calls:		None
--
-- Description:	How to restore encrypted databases 
--				(Cannot find server certificate with thumbprint).
-- 
-- https://deibymarcos.wordpress.com/2017/11/15/how-to-restore-encrypted-databases-cannot-find-server-certificate-with-thumbprint/
--
-- Date			Modified By			Changes
-- 04/08/2020   Aron E. Tekulsky    Initial Coding.
-- 04/08/2020   Aron E. Tekulsky    Update to Version 150.
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
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT name,DEK.*
		FROM sys.databases D
			JOIN sys.dm_database_encryption_keys DEK ON (DEK.database_id = D.database_id)
	ORDER BY  name;

END
GO
