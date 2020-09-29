SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sys_GetDBSizesDetailRollupOnlineOnly
--
--
-- Calls:		None
--
-- Description:	Get db sizes detail rollup online only.
-- 
-- Date			Modified By			Changes
-- 09/28/2016   Aron E. Tekulsky    Initial Coding.
-- 10/07/2017   Aron E. Tekulsky    Update to Version 140.
-- 08/25/2020   Aron E. Tekulsky    Update to Version 150.
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

	DECLARE @dbsizetabledata TABLE (
		dbnames			nvarchar(255),
		Sizedatamb		float,
		thefileid		int
	)
	DECLARE @dbsizetablelog TABLE (
		dbnames			nvarchar(255),
		Sizelogmb		float,
		thefileid		int
	)

	DECLARE @dbsizetablecombined TABLE (
		dbnames			nvarchar(255),
		SizeDataGB		float,
		SizeLogGB		float,
		TotalDbSizeGB	float,
		state			int
	)

-- get data
	INSERT INTO @dbsizetabledata (
		dbnames, Sizedatamb, thefileid
	)
	SELECT DB_NAME(database_id ) AS dbname, ROUND(CONVERT(float, size) *
	       (SELECT low
		           FROM master.dbo.spt_values
				WHERE (type = 'E') AND (number = 1)) / 1048576, 1) AS sizemb, 
		 --dbid,
		  --CASE fileid WHEN 1 THEN 'D' ELSE 'L' END AS Expr1, 
			  file_id
		FROM sys.master_files
	WHERE database_id > 4 AND 
		file_id = 1;

-- get logs
	INSERT INTO @dbsizetablelog (
		dbnames, Sizelogmb, thefileid
	)
	SELECT DB_NAME(database_id ) AS dbname, ROUND(CONVERT(float, size) *
	      (SELECT low
	            FROM master.dbo.spt_values
				WHERE (type = 'E') AND (number = 1)) / 1048576, 1) AS sizemb, 
		 --dbid,
		  --CASE fileid WHEN 1 THEN 'D' ELSE 'L' END AS Expr1, 
			  file_id
		FROM sys.master_files
	WHERE database_id > 4 AND 
		file_id = 2;


	INSERT INTO @dbsizetablecombined 
		(dbnames, SizeDataGB, SizeLogGB)
	SELECT d.dbnames , d.Sizedatamb /1024 AS SizeDataGB, l.Sizelogmb/1024 AS SizeLogGB --, l.dbnames 
		FROM @dbsizetabledata d
			JOIN @dbsizetablelog l ON (d.dbnames = l.dbnames )
			ORDER BY d.dbnames ASC;

	UPDATE @dbsizetablecombined
		SET TotalDbSizeGB = SizeDataGB + SizeLogGB;

	UPDATE @dbsizetablecombined
		SET state = (SELECT d.state
					FROM sys.databases d
				WHERE d.name = dbnames)

	SELECT dbnames, SizeDataGB, SizeLogGB, TotalDbSizeGB, state
		FROM @dbsizetablecombined
	WHERE state = 0
		AND dbnames NOT in ('test','test1','test2','dba_db08')
	ORDER BY dbnames ASC;

END
GO
