SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sev_2002ListSQLServerOptionsER
--
--
-- Calls:		None
--
-- Description:	2002 - List SQL configuration for server.
--
-- From Edward Roepe - Perimeter DBA, LLC.  - www.perimeterdba.com
-- 
-- Date			Modified By			Changes
-- 09/08/2018   Aron E. Tekulsky    Initial Coding.
-- 06/10/2019   Aron E. Tekulsky    Update to Version 140.
-- 08/14/2020   Aron E. Tekulsky    Update to Version 150.
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

-- 2002 - List SQL configuration for server
-- Ed Roepe - 06/06/2012

	SELECT SERVERPROPERTY('ServerName') AS 'InstanceName', 
			SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS 'ComputerName', 
			a.configuration_id AS 'ConfigurationId', 
			a.name AS 'Name', 
			a.value AS 'Value', 
			a.minimum AS 'Minimum', 
			a.maximum AS 'Maximum', 
			a.value_in_use AS 'ValueInUse', 
			a.description AS 'Description', 
			a.is_dynamic AS 'IsDynamic', 
			a.is_advanced AS 'IsAdvanced'
		FROM master.sys.configurations AS a
	ORDER BY a.configuration_id;

END
GO
