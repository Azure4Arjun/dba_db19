SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_rep_GetRedirectedPublisher
--
--
-- Calls:		None
--
-- Description:	List the redirected publishers.
-- 
-- Date			Modified By			Changes
-- 06/08/2018   Aron E. Tekulsky    Initial Coding.
-- 08/13/2020   Aron E. Tekulsky    Update to Version 150.
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

	DECLARE @Cmd					nvarchar(4000)
	DECLARE @original_publisher2	nvarchar(128)
	DECLARE @publisher_db2			nvarchar(128)
	DECLARE @redirected_publisher2	sysname

------SET @original_publisher2 = 'WCDCBPMDBQ01A\QA';
	SET @original_publisher2 = 'WADCWR2DB14D1A\TEST';
------SET @publisher_db2 = 'OT_PS_QA';
	SET @publisher_db2 = 'Test1';
	SET @Cmd = ' DECLARE @redirected_publisher2 sysname ;' +
			'USE [distribution]
			' +
			'EXEC sys.sp_validate_replica_hosts_as_publishers
			@original_publisher = ' + '''' + @original_publisher2 + '''' + ',
			@publisher_db = ' + '''' + @publisher_db2 + '''' + ',
			@redirected_publisher = @redirected_publisher2 output; ';

------PRINT @Cmd + ' ' + ' ***';

	EXEC (@Cmd);

END
GO
