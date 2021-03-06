SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_rep_SetRedirectPublisher
--
--
-- Calls:		None
--
-- Description:	At the distributor, in the distribution database, run the
--				stored procedure sp_redirect_publisher to associate the original
--				publisher and the published database with the availability group
--				listener name of the availability group.
--				Where :
--						MyPublisher is :		the instance/server name of the original publisher
--						MyPublishdDB is :		the name of the database
--						MyAGListenerName is :	the name of your AlwaysOn Listener.
-- 
-- Date			Modified By			Changes
-- 05/14/2019   Aron E. Tekulsky    Initial Coding.
-- 05/14/2019   Aron E. Tekulsky    Update to Version 140.
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

	DECLARE @original_publisher2	NVARCHAR(128)
	DECLARE @publisher_db2			NVARCHAR(128)
	DECLARE @redirected_publisher2	NVARCHAR(128)

	SET @original_publisher2 = 'originalopublishernode\originalinstance';
	SET @publisher_db2 = 'newinstance';
	SET @redirected_publisher2 = 'newpublishernode';

	USE [distribution];

----GO
	EXEC sys.sp_redirect_publisher @original_publisher = @original_publisher2
		,@publisher_db = @publisher_db2
		,@redirected_publisher = @redirected_publisher2;
END
GO
