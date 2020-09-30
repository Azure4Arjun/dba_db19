SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_rep_GetOrphanedSubscribers
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 05/14/2019   Aron E. Tekulsky    Initial Coding.
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

--Run from distributor
	SELECT pub.data_source AS Publisher ,a.Publisher_db ,p.Publication ,sub.data_source AS Subscriber ,
			s.Subscriber_db ,a.Article
		FROM distribution.dbo.MSarticles as a
			LEFT JOIN distribution.dbo.MSpublications AS p ON a.publisher_id = p.publisher_id AND
															a.publication_id = p.publication_id
			JOIN sys.servers AS pub ON p.publisher_id = pub.server_id
			LEFT JOIN distribution.dbo.MSsubscriptions AS s ON a.publisher_id = s.publisher_id AND
															 a.publication_id = s.publication_id AND 
															 a.article_id = s.article_id
			LEFT JOIN sys.servers AS sub ON s.subscriber_id = sub.server_id
	WHERE s.subscriber_db IS NULL; --Leave off for great documentation, but this will show the "orphaned" subscribers effected by this issue.

END
GO
