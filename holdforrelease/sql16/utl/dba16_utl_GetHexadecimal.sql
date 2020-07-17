-- ======================================================================================
-- dba16_utl_GetHexadecimal
--
-- Arguments:	@binvalue
--				@hexvalue OUTPUT
--
-- Called BY:	p_dba08_get_helprevlogin
--
-- Description:	Convert a varbinary  to a Hexadecimal value.
-- 
-- Date			Modified By			Changes
-- 06/11/2013   Aron E. Tekulsky    Initial Coding.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @binvalue	varbinary(256) 
	DECLARE @charvalue	varchar (514)
	DECLARE @hexstring	char(16)
	DECLARE @hexvalue	varchar(514) 
	DECLARE @i			int
	DECLARE @length		int

	SELECT @charvalue = '0x'
	SELECT @i = 1
	SELECT @length = DATALENGTH (@binvalue)
	SELECT @hexstring = '0123456789ABCDEF'

	WHILE (@i <= @length)
		BEGIN
			DECLARE @tempint	int
			DECLARE @firstint	int
			DECLARE @secondint	int

			SELECT @tempint = CONVERT(int, SUBSTRING(@binvalue,@i,1))
			SELECT @firstint = FLOOR(@tempint/16)
			SELECT @secondint = @tempint - (@firstint*16)
			SELECT @charvalue = @charvalue +
					SUBSTRING(@hexstring, @firstint+1, 1) +
					SUBSTRING(@hexstring, @secondint+1, 1)

			SELECT @i = @i + 1
		END

	SELECT @hexvalue = @charvalue
END