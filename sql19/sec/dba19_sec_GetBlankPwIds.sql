SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sec_GetBlankPwIds
--
--
-- Calls:		None
--
-- Description:	Get a list of all sql id's with a blank password.
-- 
-- Date			Modified By			Changes
-- 12/06/2016   Aron E. Tekulsky    Initial Coding.
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

	SELECT l.name , l.principal_id , l.sid , l.create_date , l.type_desc , l.modify_date , l.default_database_name 
		FROM sys.sql_logins  l
	WHERE pwdcompare('',l.password_hash) = 1 AND
		l.is_disabled = 0
	ORDER BY l.name ASC;

END
GO
