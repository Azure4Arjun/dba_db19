SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba14_sys_GetHexaDecimal
--
-- Arguments:	@binvalue
--				@hexvalue OUTPUT
--
-- CallS:		None
--
-- Called BY:	p_dba16_sec_GetHelpRevLogin
--
-- Description:	Convert a varbinary  to a Hexadecimal value.
-- 
-- Date			Modified By			Changes
-- 06/11/2013   Aron E. Tekulsky    Initial Coding.
-- 05/17/2019   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba14_sys_GetHexaDecimal 
	-- Add the parameters for the stored procedure here
	@binvalue varbinary(256), 
	@hexvalue varchar(514) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @charvalue		varchar (514)
	DECLARE @hexstring		char(16)
	DECLARE @i				int
	DECLARE @length			int

	SELECT @charvalue = '0x'
	SELECT @i = 1
	SELECT @length = DATALENGTH (@binvalue)
	SELECT @hexstring = '0123456789ABCDEF'

	WHILE (@i <= @length)
		BEGIN
			DECLARE @firstint	int
			DECLARE @secondint	int
			DECLARE @tempint	int

			SELECT @tempint = CONVERT(int, SUBSTRING(@binvalue,@i,1));

			SELECT @firstint = FLOOR(@tempint/16);

			SELECT @secondint = @tempint - (@firstint*16);

			SELECT @charvalue = @charvalue +
					SUBSTRING(@hexstring, @firstint+1, 1) +
					SUBSTRING(@hexstring, @secondint+1, 1);

			SELECT @i = @i + 1;
		END

	SELECT @hexvalue = @charvalue;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba14_sys_GetHexaDecimal TO [db_proc_exec] AS [dbo]
GO
