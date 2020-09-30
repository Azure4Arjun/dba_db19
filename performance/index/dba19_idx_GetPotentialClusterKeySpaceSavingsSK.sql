SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_idx_GetPotentialClusterKeySpaceSavingsSK
--
--
-- Calls:		None
--
-- Description:	Get potential cluster key savings.
-- 
-- Date			Modified By			Changes
-- 07/22/2016   Aron E. Tekulsky    Initial Coding.
-- 10/25/2017   Aron E. Tekulsky    Update to Version 140.
-- 08/11/2020   Aron E. Tekulsky    Update to Version 150.
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

--/*============================================================================
--  File:     KeySpaceSavingsSingleResultSet.sql

--  Summary:  Potential cluster key space savings

--  SQL Server Versions: 2005 onwards
--——————————————————————————
--  Written by Paul S. Randal, SQLskills.com

--  (c) 2012, SQLskills.com. All rights reserved.

--  For more scripts and sample code, check out
--    http://www.SQLskills.com

--  You may alter this code for your own *non-commercial* purposes. You may
--  republish altered code as long as you include this copyright and give due
--  credit, but you must obtain prior permission before blogging this code.
 
--  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF
--  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED
--  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
--  PARTICULAR PURPOSE.
--============================================================================*/

--IF EXISTS (SELECT * FROM #sys.objects WHERE [name] = '#SQLskillsIKSpace')
--    DROP TABLE #SQLskillsIKSpace;
--GO
	CREATE TABLE #SQLskillsIKSpace (
--DECLARE #SQLskillsIKSpace TABLE  (
		DatabaseID1		SMALLINT,
		SchemaName1		SYSNAME,
		ObjectName1		SYSNAME,
		ObjectID1		INT,
		IndexCount1		SMALLINT ,
		TableRows1		BIGINT ,
		KeyCount1		SMALLINT ,
		KeyWidth1		INT DEFAULT (0))
    --KeyWidth1 SMALLINT )
    --IndexCount SMALLINT DEFAULT (0),
    --TableRows BIGINT DEFAULT (0),
    --KeyCount SMALLINT DEFAULT (0),
    --KeyWidth SMALLINT DEFAULT (0));
--GO

	EXEC sp_MSforeachdb
	  N'IF EXISTS (SELECT 1 FROM (SELECT DISTINCT [name]
		FROM sys.databases WHERE [state_desc] = ''ONLINE''
			AND [database_id] > 4
			AND [name] != ''pubs''
			AND [name] != ''Northwind''
			AND [name] != ''distribution''
			AND [name] NOT LIKE ''ReportServer%''
			AND [name] NOT LIKE ''Adventure%'') AS names WHERE [name] = ''?'')
	BEGIN
		USE [?]

		INSERT INTO #SQLskillsIKSpace
			(DatabaseID1, SchemaName1, ObjectName1, ObjectID1)
		SELECT DB_ID (''?''), SCHEMA_NAME (o.[schema_id]), OBJECT_NAME (o.[object_id]), o.[object_id]
			FROM sys.objects o
		WHERE o.[type_desc] IN (''USER_TABLE'', ''VIEW'')
			AND o.[is_ms_shipped] = 0
			AND EXISTS (
        SELECT *
			FROM sys.indexes i
        WHERE i.[index_id] = 1
            AND i.[object_id] = o.[object_id]);

	UPDATE #SQLskillsIKSpace
		SET [TableRows1] = (
			SELECT SUM ([rows])
				FROM sys.partitions p
			WHERE p.[object_id] = [ObjectID1]
				AND p.[index_id] = 1)
		WHERE [DatabaseID1] = DB_ID (''?'');
 
	UPDATE #SQLskillsIKSpace
		SET [IndexCount1] = (
			SELECT COUNT (*)
				FROM sys.indexes i
			WHERE i.[object_id] = [ObjectID1]
				AND i.[is_hypothetical] = 0
				AND i.[is_disabled] = 0
				AND i.[index_id] != 1)
		WHERE [DatabaseID1] = DB_ID (''?'');

	UPDATE #SQLskillsIKSpace
		SET [KeyCount1] = (
			SELECT COUNT (*)
				FROM sys.index_columns ic
			WHERE ic.[object_id] = [ObjectID1]
				AND ic.[index_id] = 1)
		WHERE [DatabaseID1] = DB_ID (''?'');

	UPDATE #SQLskillsIKSpace
		SET [KeyWidth1] = (
			SELECT SUM (c.[max_length])
				FROM sys.columns c
					JOIN sys.index_columns ic ON c.[object_id] = ic.[object_id]
						AND c.[object_id] = [ObjectID1]
						AND ic.[column_id] = c.[column_id]
						AND ic.[index_id] = 1)
	WHERE [DatabaseID1] = DB_ID (''?'');

	DELETE #SQLskillsIKSpace
	WHERE ([KeyCount1] = 1 AND [KeyWidth1] < 9)
		OR [IndexCount1] = 0 OR [TableRows1] = 0;

	END';

--GO

--SELECT
-- DB_NAME (x.DatabaseID1),
-- DatabaseID1 SMALLINT,
-- SchemaName1 SYSNAME,
-- ObjectName1 SYSNAME,
--    ObjectID1 INT,
--    IndexCount1 SMALLINT ,
--    TableRows1 BIGINT ,
--    KeyCount1 SMALLINT ,
--    KeyWidth1
--    --[IndexCount1] * [TableRows] * [KeyWidth] AS [KeySpaceInBytesa],
--    --([IndexCount1] * [TableRows] * ([KeyWidth] – 8)) AS [PotentialSavingsa]
--FROM #SQLskillsIKSpace x;
----ORDER BY [PotentialSavings] DESC;

----DROP TABLE #SQLskillsIKSpace;
----GO 


	SELECT DB_NAME(s.DatabaseID1) AS DbName, s.DatabaseID1,
		s.SchemaName1,
		s.ObjectName1,
		s.IndexCount1,
		s.KeyCount1,
		s.KeyWidth1,
		s.TableRows1,
		s.IndexCount1 * s.TableRows1 * s.KeyWidth1 AS [KeySpaceInBytesa], 
		--(s.IndexCount1 * s.TableRows1 * (s.KeyWidth1)) 
		(s.IndexCount1 * s.TableRows1 * (s.KeyWidth1 + (8 * -1))) AS [PotentialSavingsa]
		,s.ObjectID1
		FROM #SQLskillsIKSpace s
	ORDER BY [PotentialSavingsa] DESC;


	DROP TABLE #SQLskillsIKSpace;
END
GO
