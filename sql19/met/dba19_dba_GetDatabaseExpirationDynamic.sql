SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- -- dba19_dba_GetDatabaseExpirationDynamic
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 05/16/2019   Aron E. Tekulsky    Initial Coding.
-- 05/16/2019   Aron E. Tekulsky    Update to Version 140.
-- 09/14/2020   Aron E. Tekulsky    Update to Version 150.
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

	--SELECT d.name, d.database_id, d.create_date, d.state_desc, d.recovery_model_desc, d.compatibility_level
	--	FROM sys.databases d
	--WHERE d.database_id > 4 AND
	--		d.name NOT IN 
	--		(SELECT b.database_name
	--			FROM msdb.dbo.backupset b)
	--ORDER BY d.database_id asc, d.name ASC


	DECLARE @db_backup_db							int
	DECLARE @db_expiration_days						int
	DECLARE	@expiration_date						datetime

	DECLARE @dba_database_expiration TABLE (
			name									nvarchar(128)	NOT NULL,
			db_owner								nvarchar(128)	NULL,
			db_dbid									smallint		NOT NULL,
			db_cr_date								datetime		NULL,
			db_expiration_date						datetime		NULL,
			db_restore_date							datetime		NULL,
			db_status								char(1)			NULL,
			db_compatibility_level					tinyint			NULL,
			db_is_in_standby						bit				NULL,
			db_is_master_key_encrypted_by_server	bit				NULL,
			db_log_reuse_wait_desc					nvarchar(60)	NULL, 
			db_owner_sid							varbinary(85)	NULL,
			db_recovery_model_desc					varchar(60)		NULL, 
			db_state_desc							nvarchar(60)	NULL,
			db_user_access_desc						nvarchar(60)	NULL)

	DECLARE @last_db_restore TABLE (
			destination_database_name				nvarchar(128)	NULL,
			max_restore_date						datetime		NULL)


-- set up restore dates
	INSERT @last_db_restore
		SELECT h.destination_database_name, MAX(h.restore_date) AS max_restore_date
			FROM msdb.dbo.restorehistory AS h LEFT OUTER JOIN
                         sys.databases AS e ON (h.destination_database_name = e.name) 
		WHERE (h.restore_type = 'D')
		GROUP BY h.destination_database_name;



	--IF @db_expiration_days IS NULL OR @db_expiration_days = '' 
	SET @db_expiration_days = 90


	SET @db_backup_db = 1
	SET @expiration_date = getdate() + @db_expiration_days -- expiration date is 90 days

	INSERT @dba_database_expiration
		SELECT d.name, l.name, d.database_id, d.create_date, @expiration_date, 
			(SELECT  max_restore_date FROM @last_db_restore
					WHERE destination_database_name = d.name), 
			CASE 
				WHEN d.[state] = 1 -- restoring so assume it is a mirror
						THEN 
							'M' 
				WHEN d.[state] = 0 -- online
						THEN 
							ISNULL(upper(substring(a.mirroring_role_desc,1,1)),'A') 
			END AS db_status,
			d.compatibility_level, d.is_in_standby, d.is_master_key_encrypted_by_server, d.log_reuse_wait_desc, d.owner_sid, d.recovery_model_desc, d.state_desc, d.user_access_desc
		FROM sys.databases d
			LEFT OUTER JOIN sys.database_mirroring a ON (d.database_id = a.database_id)
			LEFT JOIN sys.syslogins l ON (l.sid = d.owner_sid);
	--WHERE 
				--d.snapshot_isolation_state = 1 AND
						--d.source_database_id IS NOT NULL AND
						--d.name Not IN (SELECT name FROM dba_db08.dbo.dba_database_expiration);

		SELECT name									
			db_owner,
			db_dbid,
			db_cr_date,
			db_expiration_date,
			db_restore_date,
			db_status,
			db_compatibility_level,
			db_recovery_model_desc,
			db_state_desc,
			db_user_access_desc,
			db_is_in_standby,
			db_is_master_key_encrypted_by_server,
			db_log_reuse_wait_desc,
			db_owner_sid
			FROM @dba_database_expiration
		ORDER BY db_dbid ASC;



END
GO
