SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- db16_met_DMGetIFIStatus
--
--
-- Calls:		None
--
-- Description:	Determine if this setting is enabled on each server of our infrastructure.
--
--  https://www.mssqltips.com/sqlservertip/5136/check-sql-server-instant-file-initialization-for-all-servers/
-- 
--				requires SQL 2016 SP1
--
-- Date			Modified By			Changes
-- 04/09/2019   Aron E. Tekulsky    Initial Coding.
-- 04/09/2019   Aron E. Tekulsky    Update to Version 140.
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

	SELECT  @@SERVERNAME AS [Server Name] ,
		    RIGHT(@@version, LEN(@@version) - 3 - CHARINDEX(' ON ', @@VERSION)) AS [OS Info] ,
			LEFT(@@VERSION, CHARINDEX('-', @@VERSION) - 2) + ' '
	        + CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(300)) AS [SQL Server Version] ,
		    service_account, 
	        instant_file_initialization_enabled
		FROM sys.dm_server_services s
	WHERE servicename LIKE 'SQL Server (%';
   
END
GO
