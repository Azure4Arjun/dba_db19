SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_job_GenerateJobCategoryLoadList
--
--
-- Calls:		None
--
-- Description:	Genreate a list of categoryies in a script format.
-- 
-- Date			Modified By			Changes
-- 04/06/2020   Aron E. Tekulsky    Initial Coding.
-- 04/06/2020   Aron E. Tekulsky    Update to Version 150.
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

	DECLARE @CategoryClass	varchar(8)
	DECLARE @CategoryType	varchar(12)
	DECLARE @CategoryName	nvarchar(128)

	DECLARE category_cur CURSOR FOR
		SELECT CASE c.category_class
					WHEN 1 THEN 'JOB'
					WHEN 2 THEN 'ALERT'
					WHEN 3 THEN 'OPERATOR'
				END AS category_class, 
				CASE c.category_type
					WHEN 1 THEN 'LOCAL'
					WHEN 2 THEN 'MULTISERVER'
					WHEN 0 THEN 'NONE'
				END as category_type, c.name
			FROM msdb.dbo.syscategories c
		WHERE c.name NOT IN ('[Uncategorized (Local)]','[Uncategorized (Multi-Server)]','[Uncategorized]',
			'Database Engine Tuning Advisor','Database Maintenance','Full-Text','Log Shipping','REPL-Alert Response',
			'REPL-Checkup','REPL-Distribution','REPL-Distribution Cleanup','REPL-History Cleanup','Replication',
			'REPL-LogReader','REPL-Merge','REPL-QueueReader','REPL-Snapshot','REPL-Subscription Cleanup',
			'Data Collector','Jobs from MSX');

	OPEN category_cur;

	FETCH NEXT FROM category_cur INTO
		@CategoryClass, @CategoryType, @CategoryName;

	WHILE (@@FETCH_STATUS <> -1)
		BEGIN

			PRINT 'EXEC sp_add_category ' + '''' + @CategoryClass + '''' + ', ' + '''' + @CategoryType + '''' + ', ' + '''' + @CategoryName + '''' + ';';

			FETCH NEXT FROM category_cur INTO
				@CategoryClass, @CategoryType, @CategoryName;

		END

	CLOSE category_cur;
	DEALLOCATE category_cur;




END
GO
