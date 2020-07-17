SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sec_SetMigrateTDEKey
--
--
-- Calls:		None
--
-- Description:	How to restore encrypted databases 
--				(Cannot find server certificate with thumbprint).
-- 
-- https://deibymarcos.wordpress.com/2017/11/15/how-to-restore-encrypted-databases-cannot-find-server-certificate-with-thumbprint/
--
-- Date			Modified By			Changes
-- 04/08/2020   Aron E. Tekulsky    Initial Coding.
-- 04/08/2020   Aron E. Tekulsky    Update to Version 150.
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

	DECLARE @Cmd				nvarchar(4000)
	DECLARE @Password			nvarchar(128)
	DECLARE @CertFileLocation	nvarchar(128)
	DECLARE @CertificateName	nvarchar(128)

	-- Initialize
	SET @Password			= '@Password1';
	SET @CertFileLocation	= 'L:\mydirlists';
	SET @CertificateName	= 'test';

	-- First, identify all the objects affected
	PRINT 'First, identify all the objects affected';

	SELECT name,DEK.*
		FROM sys.databases D
			JOIN sys.dm_database_encryption_keys DEK ON (DEK.database_id = D.database_id)
	ORDER BY name ASC;

	-- Second, identify the certificate by navigating in the source server to Master –> Security –> Certificates
	PRINT 'Second, identify the certificate by navigating in the source server to 
			Master –> Security –> Certificates';

	-- Next, create a master key in the destination server.
	PRINT 'Next, create a master key in the destination server.';

	CREATE MASTER KEY ENCRYPTION BY PASSWORD ='@Password1';

	-- Next, you have to backup the certificate in the source and create a copy of it in the 
	--	destination server. It must be with password and private key.
	PRINT 'Next, you have to backup the certificate in the source and create a copy of it in the';
	PRINT 'destination server. It must be with password and private key.';

	SET @Cmd = '
		USE Master ';

	SET @Cmd = @Cmd + 
		'BACKUP CERTIFICATE ' + @CertificateName + 
			' TO FILE = '+ '''' + @CertFileLocation + '\' + @CertificateName + '.cer' + '''' + 
				' WITH PRIVATE KEY(
					FILE = ' + '''' + @CertFileLocation + '\' + @CertificateName + '.prvk' + '''' + ',
						ENCRYPTION BY PASSWORD = ' + '''' + @Password + '''' + ')';

	PRINT @Cmd;

	EXEC (@Cmd);

	-- Finally, you can restore the database with your normal method and it will with no issues
	PRINT 'Finally, you can restore the database with your normal method and it will with no issues';

END
GO
