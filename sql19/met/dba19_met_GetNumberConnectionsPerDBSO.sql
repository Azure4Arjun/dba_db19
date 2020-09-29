SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_met_GetNumberConnectionsPerDBSO
--
--
-- Calls:		None
--
-- Description:	Get numer of data connections for each db.
--
-- https://stackoverflow.com/questions/216007/how-to-determine-total-number-of-openactive-connections-in-ms-sql-server-2005
-- 
-- Date			Modified By			Changes
-- 05/14/2019   Aron E. Tekulsky    Initial Coding.
-- 05/14/2019   Aron E. Tekulsky    Update to Version 140.
-- 08/24/2020   Aron E. Tekulsky    Update to Version 150.
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

	SELECT DB_NAME(dbid) as DBName, COUNT(dbid) as NumberOfConnections,
			loginame as LoginName
		FROM sys.sysprocesses
	WHERE dbid > 0 --AND
		------DB_NAME(dbid) = 'xxx'
	GROUP BY dbid, loginame;

END
GO
