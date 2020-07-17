SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_rep_ConfigureAGDistribution
--
--
-- Calls:		None
--
-- Description:	Configure the distribution for replication with AG's.
--				Steps 1 to 3.
-- 
---- https://docs.microsoft.com/en-us/sql/database-engine/availability-groups/
---- windows/configure-replication-for-always-on-availability-groups-sql-server?
---- iew=sql-server-2017
--
-- Date			Modified By			Changes
-- 06/08/2018   Aron E. Tekulsky    Initial Coding.
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

	DECLARE @Cmd nvarchar(4000)
	DECLARE @Comment nvarchar(4000)
	DECLARE @Distributor1 nvarchar(128)
	DECLARE @DistrDB nvarchar(128)
	DECLARE @DataPath nvarchar(128)
	DECLARE @LogPath nvarchar(128)
	DECLARE @ReplDataPath nvarchar(128)
	DECLARE @Password1 nvarchar(128)
	DECLARE @PubPrimary1 nvarchar(128)
	DECLARE @PubSecondary2 nvarchar(128)
	DECLARE @PublisherTypePrimary1 nvarchar(128)
	DECLARE @PublisherTypeSecondary2 nvarchar(128)
	DECLARE @ReplDistributor1 nvarchar(128)
	DECLARE @ReplDistributor2 nvarchar(128)
	DECLARE @WorkingDirPrimary1 nvarchar(128)
	DECLARE @WorkingDirSecondary2 nvarchar(128)

	SET @Distributor1 = 'WADCWR2DB14D1A\TEST';
	SET @Password1 = '@Testing1';
	SET @DistrDB = 'distribution';
	SET @DataPath = 'E:\ss2k14$TEST\dbdata';
	SET @LogPath = 'D:\ss2k14$TEST\dbtlog';
	SET @ReplDataPath = 'E:\ss2k14$TEST\MSSQL12.TEST\MSSQL\ReplData';

	SET @PubPrimary1 = 'wadcwr2db14d1a\TEST';
	SET @PubSecondary2 = 'wadcwr2db14d1b\TEST';
	SET @WorkingDirPrimary1 = 'E:\ss2k14$TEST\MSSQL12.TEST\MSSQL\ReplData';
	SET @WorkingDirSecondary2 = 'E:\ss2k14$TEST\MSSQL12.TEST\MSSQL\ReplData';
	SET @PublisherTypePrimary1 = 'MSSQLSERVER';
	SET @PublisherTypeSecondary2 = 'MSSQLSERVER';
	SET @ReplDistributor1 = 'repl_distributor';
	SET @ReplDistributor2 = 'repl_distributor';

/****** Scripting replication configuration. Script Date: 5/16/2018 12:41:21 PM ******/
/****** Please Note: For security reasons, all password parameters were scripted with either NULL or an empty string. ******/
/****** Installing the server as a Distributor. Script Date: 5/16/2018 12:41:21PM ******/

	SET @Comment = '-- 1 Configure distribution at the distributor. ';
	PRINT @Comment;

	SET @Comment = '-- 2 Create the distribution database at the distributor.';
	PRINT @Comment;

-- 1 Configure distribution at the distributor.
-- 2 Create the distribution database at the distributor.
	SET @Cmd = '
		USE [master]
		EXEC sp_adddistributor @distributor = N' + '''' + @Distributor1 + '''' +
			', @password = N' + '''' + @Password1 + '''' + '
		GO

		EXEC sp_adddistributiondb @database = N' + '''' + @DistrDB + '''' + ',
			@data_folder = N' + '''' + @DataPath + '''' +
			', @log_folder = N' + '''' + @LogPath + '''' + ', @log_file_size
			= 2, @min_distretention = 0, @max_distretention = 72,
			@history_retention = 48, @security_mode = 1
		GO ';

	PRINT @Cmd;

	SET @CMD = '
		USE [distribution]
		IF (NOT EXISTS (SELECT * FROM sysobjects WHERE name = ' + '''' +
			'UIProperties' + '''' + ' AND type = ' + '''' + 'U ' + '''' + '))
			CREATE TABLE UIProperties(id int)
		IF (EXISTS (SELECT * FROM ::fn_listextendedproperty(' + '''' +
			'SnapshotFolder' + '''' + ', ' + '''' + 'user' + '''' +
			', ' + '''' + 'dbo' + '''' + ', ' + '''' + 'table' + '''' + ', '
			+ '''' + 'UIProperties' + '''' + ', null, null)))

			EXEC sp_updateextendedproperty N' + '''' + 'SnapshotFolder' + '''' +
				', N' + '''' + @ReplDataPath + '''' +
				', ' + '''' + 'user' + '''' + ', dbo, ' + '''' + 'table' + '''' +
				', ' + '''' + 'UIProperties' + '''' + '
		ELSE
			EXEC sp_addextendedproperty N' + '''' + 'SnapshotFolder' + '''' + ',
				N' + '''' + @ReplDataPath + '''' + ', ' + '''' +
				'user' + '''' + ', dbo, ' + '''' + 'table' + '''' + ', ' + ''''
				+ 'UIProperties' + '''' + '
			GO';

	PRINT @Cmd + CHAR(13);

	SET @Comment = '-- 3a Configure the remote publisher. ';
	PRINT @Comment;

-- 3a Configure the remote publisher.
	SET @Cmd = '
		sp_adddistpublisher @publisher = N' + '''' + @PubPrimary1 + '''' + ',
			@distribution_db = N' + '''' + @DistrDB + '''' +
			', @security_mode = 1, @working_directory = N' + '''' +
			@WorkingDirPrimary1 + '''' +
			', @trusted = N' + '''' + 'false' + '''' + ', @thirdparty_flag = 0,
			@publisher_type = N' + '''' + @PublisherTypePrimary1 + '''' + '
		GO ';

	PRINT @Cmd + CHAR(13);

	SET @Comment = '-- 3b Configure the publisher at Primary. ';
	PRINT @Comment;

-- 3b Configure the publisher at Primary.
	SET @Cmd = '
		EXEC sp_adddistpublisher @publisher = N' + '''' + @PubSecondary2 + '''' +
			', @distribution_db = N' + '''' + @DistrDB + '''' + ', @security_mode
			= 1,
			@working_directory = N' + '''' + @WorkingDirSecondary2 + '''' + ',
			@trusted = N' + '''' + 'false' + '''' +
			', @thirdparty_flag = 0, @publisher_type = N' + '''' +
			@PublisherTypeSecondary2 + '''' + '
		GO ';

	PRINT @Cmd + CHAR(13);

-- set up linked servers for dataaccess
	SET @Comment = '-- 3c Set Linked server to allow data access at Primary. ';

	PRINT @Comment;

	SET @Cmd = '
		EXEC master.dbo.sp_serveroption @server=N' + '''' + @PubPrimary1 + '''' +
		',
		@optname=N' + '''' + 'Data Access' + '''' + ', @optvalue=N' + '''' +
		'TRUE' + '''' + ';';

	PRINT @Cmd + CHAR(13);	

	SET @Comment = '-- 3c Set Linked server to allow data access at Secondary.';
	PRINT @Comment;

	SET @Cmd = '
		EXEC master.dbo.sp_serveroption @server=N' + '''' + @PubSecondary2 + ''''
			+ ',
			@optname=N' + '''' + 'Data Access' + '''' + ', @optvalue=N' + '''' +
			'TRUE' + '''' + ';';

	PRINT @Cmd + CHAR(13);

	SET @Comment = '-- 3d Set Linked server to allow data access at Primary for
		repl_distriutor. ';
	PRINT @Comment;

	SET @Cmd = '
		EXEC master.dbo.sp_serveroption @server=N' + '''' + @ReplDistributor1 +
		'''' + ',
		@optname=N' + '''' + 'Data Access' + '''' + ', @optvalue=N' + '''' +
		'TRUE' + '''' + ';';

	PRINT @Cmd + CHAR(13);
END
GO
