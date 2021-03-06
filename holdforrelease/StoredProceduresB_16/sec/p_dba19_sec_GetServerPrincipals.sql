USE [dba_db19]
GO
/****** Object:  StoredProcedure [dbo].[p_dba19_sec_GetServerPrincipals]    Script Date: 02/15/2012 12:30:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================================
-- p_dba19_sec_GetServerPrincipals
--
-- Arguments:	@principaltype	0 - enabled, 1 - disabled, null - all
--					None
--
-- Called BY:	None
--
-- Description:	Get the server principals.  all, enabled, disabled
-- 
-- Date				Modified By			Changes
-- 02/08/2012   Aron E. Tekulsky	Initial Coding.
-- 04/03/2012	Aron E. Tekulsky	update to v100.
-- 07/27/2019	Aron E. Tekulsky	update to v140.
-- 05/26/2020	Aron E. Tekulsky	update to v150.
-- ===============================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================
CREATE PROCEDURE [dbo].[p_dba19_sec_GetServerPrincipals] 
	-- Add the parameters for the stored procedure here
	@principaltype int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
 	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
   
    IF @principaltype <> 0 AND @principaltype <> 1 AND @principaltype <> NULL
		BEGIN
			RETURN -1
		END
		
	IF @principaltype = 0 OR @principaltype = 1
		BEGIN
			SELECT p.name, p.type, p.type_desc, p.is_disabled, p.create_date, p.modify_date, p.default_database_name
				FROM sys.server_principals p
			WHERE p.is_disabled = @principaltype
			ORDER BY p.type, p.name ASC;
		END
	ELSE
		BEGIN
			SELECT p.name, p.type, p.type_desc, p.is_disabled, p.create_date, p.modify_date, p.default_database_name
				FROM sys.server_principals p
			ORDER BY p.type, p.name ASC;
		END
		
		
	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END

GO
GRANT EXECUTE ON [dbo].[p_dba19_sec_GetServerPrincipals] TO [db_proc_exec] AS [dbo]