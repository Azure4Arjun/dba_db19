SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_dig_DMGUnusedIndexes
--
--
-- Calls:		None
--
-- Description:	Get unused index for a database.
-- 
-- Date			Modified By			Changes
-- 06/20/2012   Aron E. Tekulsky    Initial Coding.
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

	SELECT  OBJECT_SCHEMA_NAME(I.OBJECT_ID) AS SchemaName,
        OBJECT_NAME(I.OBJECT_ID) AS ObjectName,
        I.NAME AS IndexName        
		FROM    sys.indexes I   
	WHERE   -- only get indexes for user created tables
        OBJECTPROPERTY(I.OBJECT_ID, 'IsUserTable') = 1 
        -- find all indexes that exists but are NOT used
        AND NOT EXISTS ( 
                    SELECT  index_id 
                    FROM    sys.dm_db_index_usage_stats
                    WHERE   OBJECT_ID = I.OBJECT_ID 
                            AND I.index_id = index_id 
                            -- limit our query only for the current db
                            AND database_id = DB_ID()) 
	ORDER BY SchemaName, ObjectName, IndexName  ASC

END
GO
