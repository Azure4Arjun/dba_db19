SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_dig_Get_ListofConnectionstoDB
--
--
-- Calls:		None
--
-- Description:	Get a listing of all the users connected to each database.
--
-- https://stackoverflow.com/questions/1248423/how-do-i-see-active-sql-server-connections
--
-- Date			Modified By			Changes
-- 12/04/2018	Aron E. Tekulsky	Initial Coding.
-- 05/17/2019   Aron E. Tekulsky    Update to Version 140.
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
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	SELECT DB_NAME(dbid) as DBName, COUNT(dbid) as NumberOfConnections, loginame as LoginName
		FROM sys.sysprocesses
	WHERE dbid > 0 --AND
		--DB_NAME(dbid) = 'SmartGrid'
	GROUP BY dbid, loginame;

END
GO
