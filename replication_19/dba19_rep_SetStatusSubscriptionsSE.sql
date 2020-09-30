SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_rep_SetStatusSubscriptionsSE
--
--
-- Calls:		None
--
-- Description:	Fix SQL Subscription that is marked inactive.
--
-- Status of the subscription: 0 = Inactive; 1 = Subscribed; 2 = Active
--
-- https://dba.stackexchange.com/questions/33801/sql-server-replication-subscriptions-marked-as-inactive
--
--- Author: Kin Shah
-- Date: 4-1-2013
-- For dba.stackexchange.com
-- 
-- Date			Modified By			Changes
-- 04/24/2019	Aron E. Tekulsky	Initial Coding.
-- 05/14/2019   Aron E. Tekulsky    Update to Version 140.
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

	DECLARE @PublisherID	SMALLINT
	DECLARE @publisherdb	NVARCHAR(128)
	DECLARE @publicationid	INT
	DECLARE @subscriberid	SMALLINT
	DECLARE @subscriberdb	NVARCHAR(128)

	DECLARE SUBS_CUR CURSOR FOR
		SELECT --[publisher_database_id]
		--,
				[publisher_id]	,[publisher_db]	,[publication_id]	----,[article_id]	
				,[subscriber_id]	,[subscriber_db]
				----,[subscription_type]
				----,[sync_type]
				----,[status]
				----,[subscription_seqno]
				----,[snapshot_seqno_flag]
				----,[independent_agent]
				----,[subscription_time]
				----,[loopback_detection]
				----,[agent_id]
				----,[update_mode]
				----,[publisher_seqno]
				----,[ss_cplt_seqno]
				----,[nosync_type]
			FROM DISTRIBUTION..MSsubscriptions;

	OPEN SUBS_CUR;

	FETCH NEXT FROM SUBS_CUR
		INTO 
			@PublisherID, @publisherdb, @publicationid, @subscriberid, @subscriberdb;

	WHILE (@@FETCH_STATUS <> - 1)
		BEGIN
			--- based on the above values, run below statement
			--- this can be run using SQLAgent job
			IF EXISTS (
					SELECT 1
						FROM DISTRIBUTION..MSsubscriptions
					WHERE STATUS = 0
				)
					BEGIN
						UPDATE distribution..MSsubscriptions
							SET STATUS = 2
						WHERE publisher_id = @PublisherID --'--publisher_id -- will be integer --'
							AND publisher_db = @publisherdb --'--publisher db name ---'
							AND publication_id = @publicationid -- '--publication_id -- will be integer --'
							AND subscriber_id = @subscriberid -- '--subscriber_id -- will be integer ---'
							AND subscriber_db = @subscriberdb -- '-- subscriber_db ---';
					END
			ELSE
					BEGIN
						PRINT 'Publisher db ' + @publisherdb + 'The subscription for ' + @subscriberdb +
						' is not INACTIVE ... you are good for now .... !!';
					END

			FETCH NEXT FROM SUBS_CUR
				INTO 
					@PublisherID, @publisherdb, @publicationid, @subscriberid, @subscriberdb;
		END

	CLOSE SUBS_CUR;

	DEALLOCATE SUBS_CUR;

END
GO
