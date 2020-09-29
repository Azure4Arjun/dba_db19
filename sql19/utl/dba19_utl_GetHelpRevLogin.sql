SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_utl_GetHelpRevLogin
--
--
-- Calls:		p_dba08_get_hexadecimal
--
-- Description:	Generate a SQL script to copy a SQL login 
--				including loginid, SID, Password.
-- 
-- Date			Modified By			Changes
-- 06/11/2013   Aron E. Tekulsky    Initial Coding.
-- 06/11/2013	Aron E. Tekulsky	Build in functionality of p_dba08_get_hexadecimal.
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

    DECLARE @defaultdb				sysname
    DECLARE @denylogin				int
    DECLARE @hasaccess				int
    DECLARE @is_disabled			int
    DECLARE @is_expiration_checked	varchar (3)
    DECLARE @is_policy_checked		varchar (3)
    DECLARE @name					sysname
    DECLARE @PWD_varbinary			varbinary (256)
    DECLARE @PWD_string				varchar (514)
    DECLARE @SID_varbinary			varbinary (85)
    DECLARE @SID_string				varchar (514)
    DECLARE @tmpstr					varchar (1024)
    DECLARE @type					varchar (1)


-- hex setups
	DECLARE @binvalue				varbinary(256) 
	DECLARE @hexvalue				varchar(514) 

	DECLARE @charvalue				varchar (514)
	DECLARE @hexstring				char(16)
	DECLARE @i						int
	DECLARE @j						int
	DECLARE @length					int

-- end hex setups

	--IF (@login_name IS NULL)
		DECLARE login_curs CURSOR FOR
			SELECT p.sid, p.name, p.type, p.is_disabled, p.default_database_name, l.hasaccess, l.denylogin 
				FROM sys.server_principals p 
				LEFT JOIN sys.syslogins l ON ( l.name = p.name ) 
			WHERE p.type IN ( 'S', 'G', 'U' ) AND 
				p.name <> 'sa';
	--ELSE
	--	DECLARE login_curs CURSOR FOR
	--		SELECT p.sid, p.name, p.type, p.is_disabled, p.default_database_name, l.hasaccess, l.denylogin 
	--			FROM sys.server_principals p LEFT JOIN sys.syslogins l ON ( l.name = p.name ) 
	--		WHERE p.type IN ( 'S', 'G', 'U' ) AND 
	--			p.name = @login_name;

	OPEN login_curs;

	FETCH NEXT FROM login_curs 
		INTO 
			@SID_varbinary, @name, @type, @is_disabled, @defaultdb, @hasaccess, @denylogin;

	IF (@@fetch_status = -1)
		BEGIN
			PRINT 'No login(s) found.';
			CLOSE login_curs;
			DEALLOCATE login_curs;
		 --RETURN -1
		END

	SET @tmpstr = '/* sp_help_revlogin script ';
	PRINT @tmpstr;
	SET @tmpstr = '** Generated ' + CONVERT (varchar, GETDATE()) + ' on ' + @@SERVERNAME + ' */';
	PRINT @tmpstr;
	PRINT '';

	WHILE (@@fetch_status <> -1)   --The FETCH statement failed or the row was beyond the result set.
		BEGIN
		 IF (@@fetch_status <> -2) --The row fetched is missing.
			 BEGIN
				PRINT '';
				SET @tmpstr = '-- Login: ' + @name;
				PRINT @tmpstr;
				IF (@type IN ( 'G', 'U'))
					BEGIN -- NT authenticated account/group
						SET @tmpstr = 'CREATE LOGIN ' + QUOTENAME( @name ) + 
							' FROM WINDOWS WITH DEFAULT_DATABASE = [' + @defaultdb + ']';
					END
			------------END
			    ELSE 
			  BEGIN -- SQL Server authentication
        -- obtain password and sid
					SET @PWD_varbinary = CAST( LOGINPROPERTY( @name, 'PasswordHash' ) AS varbinary (256) );

					--EXEC [dba_db08].dbo.p_dba08_get_hexadecimal @PWD_varbinary, @PWD_string OUT

-- ************************************************
-- **        Start Hex routines                  **
-- ************************************************

					SET @J = 1;

					WHILE (@j < 3)

						BEGIN


	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
							SET NOCOUNT ON;

							IF @j = 1
								SET @binvalue = @PWD_varbinary;
							ELSE
								SET @binvalue = @SID_varbinary;
						--END

    -- Insert statements for procedure here

							SELECT @charvalue = '0x';
							SELECT @i = 1;
							SELECT @length = DATALENGTH (@binvalue);
							SELECT @hexstring = '0123456789ABCDEF';
							WHILE (@i <= @length)
								BEGIN
									DECLARE @tempint int
									DECLARE @firstint int
									DECLARE @secondint int
									SELECT @tempint = CONVERT(int, SUBSTRING(@binvalue,@i,1))
									SELECT @firstint = FLOOR(@tempint/16)
									SELECT @secondint = @tempint - (@firstint*16)
									SELECT @charvalue = @charvalue +
									SUBSTRING(@hexstring, @firstint+1, 1) +
									SUBSTRING(@hexstring, @secondint+1, 1)
									SELECT @i = @i + 1
								END

							SELECT @hexvalue = @charvalue;

							IF @J = 1
								SET @PWD_string = @hexvalue;
							ELSE
								SET @SID_string = @hexvalue;
							--END

							SELECT @J = @j + 1;
						END

-- ************************************************
-- **          End Hex routines                  **
-- ************************************************

					--EXEC [dba_db08].dbo.p_dba08_get_hexadecimal @SID_varbinary,@SID_string OUT

        -- obtain password policy state
					SELECT @is_policy_checked = 
						CASE is_policy_checked 
							WHEN 1 THEN 'ON' 
							WHEN 0 THEN 'OFF' 
							ELSE NULL END
						FROM sys.sql_logins 
					WHERE name = @name;

		-- obtain password expiration state
					SELECT @is_expiration_checked = 
						CASE is_expiration_checked 
							WHEN 1 THEN 'ON' 
							WHEN 0 THEN 'OFF' 
							ELSE NULL END
						FROM sys.sql_logins 
					WHERE name = @name;

				    SET @tmpstr = 'CREATE LOGIN ' + QUOTENAME( @name ) + ' WITH PASSWORD = ' + @PWD_string + 
						' HASHED, SID = ' + @SID_string + ', DEFAULT_DATABASE = [' + @defaultdb + ']';
				    --SET @tmpstr = 'CREATE LOGIN ' + QUOTENAME( @name ) + ' HASHED, SID = ' + @SID_string + ', DEFAULT_DATABASE = [' + @defaultdb + ']';

					IF ( @is_policy_checked IS NOT NULL )
						BEGIN
						 SET @tmpstr = @tmpstr + ', CHECK_POLICY = ' + @is_policy_checked;
						END

					IF ( @is_expiration_checked IS NOT NULL )
					  BEGIN
					    SET @tmpstr = @tmpstr + ', CHECK_EXPIRATION = ' + @is_expiration_checked;
					  END
				END -----

			IF (@denylogin = 1)
				BEGIN -- login is denied access
				 SET @tmpstr = @tmpstr + '; DENY CONNECT SQL TO ' + QUOTENAME( @name );
				END
			ELSE IF (@hasaccess = 0)
					 BEGIN -- login exists but does not have access
						SET @tmpstr = @tmpstr + '; REVOKE CONNECT SQL TO ' + QUOTENAME( @name );
					 END

			IF (@is_disabled = 1)
				BEGIN -- login is disabled
					SET @tmpstr = @tmpstr + '; ALTER LOGIN ' + QUOTENAME( @name ) + ' DISABLE';
				END

			PRINT @tmpstr;
		END

	FETCH NEXT FROM login_curs INTO @SID_varbinary, @name, @type, @is_disabled, @defaultdb, @hasaccess, @denylogin;
   END

	CLOSE login_curs;
	DEALLOCATE login_curs;

END
GO
