USE [dba_db08]
GO
/****** Object:  StoredProcedure [dbo].[p_dba08_stealth_dm_get_missing_indexes]    Script Date: 03/05/2013 09:47:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- p_dba08_stealth_dm_get_missing_indexes
--
-- Arguments:	None
--				None
--
-- Called BY:	None
--
-- Description:	Find out if there are any missing 
--						indexes on tables in each database
--						based on query statistics.
-- 
-- Date			Modified By			Changes
-- 03/02/2012   Aron E. Tekulsky    Initial Coding.
-- 04/16/2012	Aron E. Tekulsky	Update to v100.
-- =============================================
--	Copyright©2009 - 2012 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================
ALTER PROCEDURE [dbo].[p_dba08_stealth_dm_get_missing_indexes]
		@server_name	nvarchar(126)
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @runtime	datetime,
			@cmd		nvarchar(4000)
			
	DECLARE @missingindex TABLE (
			servername			nvarchar(126),
			name				nvarchar(128),
			runtime				varchar(128),
			improvement_measure	decimal(28,1),
			dbschematable		varchar(8000),
			Avg_Total_User_Cost	float,
			Avg_User_Impact		float,
			User_Seeks			bigint,
			User_Scans			bigint,
			Database_ID			smallint,
			Object_ID			int,
			crindex				varchar(8000)
	)
	
	SET @runtime = GETDATE()

--migs.Avg_Total_User_Cost,

	SET @cmd = '
	SELECT ''' + @server_name + ''' as servername, d.name, CONVERT (varchar, ' + '''' + CONVERT(varchar,@runtime,126) + '''' + ', 126) AS Runtime,  CONVERT (decimal (28,1), 
			migs.avg_total_user_cost * migs.avg_user_impact/100 * (migs.user_seeks + migs.user_scans)) AS improvement_measure,
			mid.statement as ' + '''' + 'Database.Schema.Table' + '''' + ',  migs.Avg_Total_User_Cost, migs.Avg_User_Impact, migs.User_Seeks, 
			migs.User_Scans,  mid.Database_ID, mid.[Object_ID],' + '''' + 
			 'CREATE INDEX IX_MI_' + '''' + '+ object_name(mid.object_id, mid.database_id) + ' + '''' + '_' + '''' + 
			 '+ CONVERT (varchar, mig.index_group_handle) + ' + '''' + '_' + '''' + ' + CONVERT (varchar, mid.index_handle)  + ' + '''' + ' ON ' + '''' + ' + mid.statement + ' + 
			 '''' + ' (' + '''' + ' + ISNULL (mid.equality_columns,' + '''' + '''' + ')  + ' + 
			 'CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL 
					THEN ' + '''' + ',' + '''' + 
				'ELSE ' + '''' + '' + '''' + '
			 END ' +
			'+ ISNULL (mid.inequality_columns, ' + '''' + '' + '''' + ') + ' + '''' + ')' + ''''+ '+ ISNULL (' + '''' + ' INCLUDE (' + '''' + ' + mid.included_columns + ' + '''' + ')' + '''' + ', ' + '''' + '''' + ') AS create_index_statement
		FROM [' + @server_name + '].master.sys.dm_db_missing_index_groups mig  with (nolock)
                INNER JOIN [' + @server_name + '].master.sys.dm_db_missing_index_group_stats migs  with (nolock) ON migs.group_handle = mig.index_group_handle
                INNER JOIN [' + @server_name + '].master.sys.dm_db_missing_index_details mid  with (nolock) ON mig.index_handle = mid.index_handle
                LEFT JOIN [' + @server_name + '].master.sys.databases d ON (mid.database_id = d.database_id)
	WHERE CONVERT (decimal (28,1), migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans)) > 10 AND
		mid.database_id > 4
	ORDER BY d.name ASC, migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) DESC;'
	
	Print @cmd

	INSERT INTO @missingindex
		EXEC (@cmd);
		
	SELECT servername,name,runtime, improvement_measure, dbschematable, Avg_Total_User_Cost,
			Avg_User_Impact, User_Seeks, User_Scans, Database_ID, Object_ID, crindex
		FROM @missingindex;
	
	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
		RETURN -1 
END





GO
GRANT EXECUTE ON [dbo].[p_dba08_stealth_dm_get_missing_indexes] TO [db_proc_exec] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[p_dba08_stealth_dm_get_missing_indexes] TO [db_proc_exec] AS [dbo]