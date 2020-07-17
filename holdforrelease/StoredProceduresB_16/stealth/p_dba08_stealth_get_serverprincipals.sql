USE [dba_db08]
GO

/****** Object:  StoredProcedure [dbo].[p_dba08_stealth_get_serverprincipals]    Script Date: 6/3/2016 1:54:58 PM ******/
DROP PROCEDURE [dbo].[p_dba08_stealth_get_serverprincipals]
GO

/****** Object:  StoredProcedure [dbo].[p_dba08_stealth_get_serverprincipals]    Script Date: 6/3/2016 1:54:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- p_dba08_stealth_get_serverprincipals
--
-- Arguments:	@server
--				@principaltype	0 - enabled, 1 - disabled, null - all
--					None
--
-- Called BY:	None
--
-- Description:	Get the server principals.  all, enabled, disabled
-- 
-- Date				Modified By			Changes
-- 02/08/2012   Aron E. Tekulsky  Initial Coding.
-- 04/03/2012	Aron E. Tekulsky	update to v100.
-- =============================================
--	Copyright©2009 - 2012 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================
CREATE PROCEDURE [dbo].[p_dba08_stealth_get_serverprincipals] 
	-- Add the parameters for the stored procedure here
	@server	nvarchar(128),
	@principaltype int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @cmd	nvarchar(4000)

	DECLARE @principalstable TABLE  (
		name					nvarchar(128),
		type					char(1),
		type_desc				nvarchar(60),
		is_disabled				bit,
		create_date				datetime,
		modify_date				datetime,
		default_database_name	nvarchar(128)
	)
    
    IF @principaltype <> 0 AND @principaltype <> 1 AND @principaltype <> NULL
		BEGIN
			RETURN -1
		END
		
	IF @principaltype = 0 OR @principaltype = 1
		BEGIN
			SET @cmd = '
				SELECT p.name, p.type, p.type_desc, p.is_disabled, p.create_date, p.modify_date, p.default_database_name
					FROM ['  + @server + '].sys.server_principals p
				WHERE p.is_disabled = @principaltype
				ORDER BY p.type, p.name ASC'
		END
	ELSE
		BEGIN
			SET @cmd = '
				SELECT p.name, p.type, p.type_desc, p.is_disabled, p.create_date, p.modify_date, p.default_database_name
					FROM [' + @server + + '].sys.server_principals p
				ORDER BY p.type, p.name ASC'
		END
		
	INSERT INTO @principalstable
	EXEC (@cmd);

	SELECT name, type, type_desc, is_disabled, create_date, modify_date, default_database_name
		FROM @principalstable;
		
	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END


GO

GRANT EXECUTE ON [dbo].[p_dba08_stealth_get_serverprincipals] TO [db_proc_exec] AS [dbo]
GO


