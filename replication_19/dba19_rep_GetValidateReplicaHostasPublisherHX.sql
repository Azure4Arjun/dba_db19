SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_rep_GetValidateReplicaHostasPublisherHX
--
--
-- Calls:		None
--
-- Description:	At the distributor, in the distribution database, run the
--				stored procedure sp_validate_replica_hosts_as_publishers to
--				verify that all replica hosts are now conifgured to server as
--				publishers for the published database.
--
-- https://support.hexagonsafetyinfrastructure.com/infocenter/index?page=content&id=HOW5742&actp=LIST&showDraft=false
-- 
-- Date			Modified By			Changes
-- 06/08/2018   Aron E. Tekulsky    Initial Coding.
-- 08/13/2020   Aron E. Tekulsky    Update to Version 150.
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

	DECLARE @original_publisher		nvarchar(128)
	DECLARE @publisher_db			nvarchar(128)
	DECLARE @redirected_publisher2	sysname

	SET @original_publisher = 'WADCWR2DB14D1A\TEST';
	SET @publisher_db		= 'Test1';

	USE distribution;
-- GO

	EXEC sys.sp_validate_replica_hosts_as_publishers
		@original_publisher = @original_publisher,
		@publisher_db = @publisher_db,
		@redirected_publisher = @redirected_publisher2 output;

END
GO
