SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_utl_GetBackupSetStatistics
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 02/05/2020   Aron E. Tekulsky    Initial Coding.
-- 02/05/2020   Aron E. Tekulsky    Update to Version 150.
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

	SELECT TOP (1000) [backup_set_id]
			  ,[server_name]
			  ,[database_name]
			  ,[machine_name]
			  ----,[backup_set_uuid]
			  ----,[media_set_id]
			  ----,[first_family_number]
			  ----,[first_media_number]
			  ----,[last_family_number]
			  ----,[last_media_number]
			  ----,[catalog_family_number]
			  ----,[catalog_media_number]
			  ,[position]
			  ,[expiration_date]
			  ----,[software_vendor_id]
			  ,[name]
			  ,[description]
			  ,[user_name]
			  ,[software_major_version]
			  ,[software_minor_version]
			  ----,[software_build_version]
			  ----,[time_zone]
			  ----,[mtf_minor_version]
			  ----,[first_lsn]
			  ----,[last_lsn]
			  ----,[checkpoint_lsn]
			  ----,[database_backup_lsn]
			  ,[database_creation_date]
			  ,[backup_start_date]
			  ,[backup_finish_date]
			  ,[backup_finish_date] - [backup_start_date] AS ElapsedBackupTime
			  ,[type]
			  ----,[sort_order]
			  ----,[code_page]
			  ,[compatibility_level]
			  ----,[database_version]
			  ,CONVERT(decimal(10,2),([backup_size] / 1024/1024)) AS [backup_size (MB)]
			  ,CONVERT(decimal(10,2),([compressed_backup_size]/1024/1024)) AS [compressed_backup_size (MB)]
			  ,CONVERT(decimal(10,4),(([backup_size] /[compressed_backup_size] ))) AS [CompressionRatio]
			  ,[flags]
			  ----,[unicode_locale]
			  ----,[unicode_compare_style]
			  ,[collation_name]
			  ,[is_password_protected]
			  ,[recovery_model]
			  ----,[has_bulk_logged_data]
			  ----,[is_snapshot]
			  ----,[is_readonly]
			  ----,[is_single_user]
			  ----,[has_backup_checksums]
			  ----,[is_damaged]
			  ----,[begins_log_chain]
			  ----,[has_incomplete_metadata]
			  ----,[is_force_offline]
			  ----,[is_copy_only]
			  ----,[first_recovery_fork_guid]
			  ----,[last_recovery_fork_guid]
			  ----,[fork_point_lsn]
			  ----,[database_guid]
			  ----,[family_guid]
			  ----,[differential_base_lsn]
			  ----,[differential_base_guid]
			  ----,[key_algorithm]
			  ----,[encryptor_thumbprint]
			  ,[encryptor_type]
		  FROM [msdb].[dbo].[backupset]
		WHERE [backup_finish_date] >= CONVERT(datetime,'04-19-2020')
		ORDER BY [server_name] ASC, [database_name] ASC, [backup_finish_date] DESC;
END
GO
