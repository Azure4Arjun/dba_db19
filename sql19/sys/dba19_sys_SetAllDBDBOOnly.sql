SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sys_SetAllDBDBOOnly
--
--
-- Calls:		None
--
-- Description:	Set all db to dbo only.
-- 
-- Date			Modified By			Changes
-- 08/13/2010   Aron E. Tekulsky    Initial Coding.
-- 11/07/2017   Aron E. Tekulsky    Update to Version 140.
-- 08/26/2020   Aron E. Tekulsky    Update to Version 150.
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

	DECLARE @access_toset			varchar(15),
			@cmd					nvarchar(4000),
			@compatibility_level	int,
			@database_id			int,
			@name					varchar(200),
			@state					int, 
			@state_desc				varchar(15),
			@user_access_desc		varchar(15),
			@user_access			int

	SET @access_toset = 'RESTRICTED_USER';

	DECLARE db_cur CURSOR FOR 
		SELECT name, database_id, compatibility_level, user_access_desc, user_access, state, state_desc
			FROM sys.databases
		WHERE database_id > 4;
	
	OPEN db_cur;

	FETCH NEXT FROM db_cur
		INTO @name,	@database_id, @compatibility_level, @user_access_desc, @user_access, @state, @state_desc


	WHILE (@@FETCH_STATUS = 0)
		BEGIN

			SET @cmd = 'ALTER DATABASE ' + @name + ' SET ' + @access_toset + ' WITH ROLLBACK IMMEDIATE;';

		----EXEC (@cmd)
			PRINT @CMD;
		
			FETCH NEXT FROM db_cur
				INTO @name,	@database_id, @compatibility_level, @user_access_desc, @user_access, @state, @state_desc;

		END
	
		CLOSE db_cur;
	
		DEALLOCATE db_cur;

END
GO
