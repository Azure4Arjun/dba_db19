SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- f_dba19_utl_ConvertHexToDec
--
-- Arguments:	@hexvalue varchar(20)
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Convert a hexadecimal number to decimal.
--
-- Date			Modified By			Changes
-- 05/17/2013   Aron E. Tekulsky    Initial Coding.
-- 12/11/2017   Aron E. Tekulsky    Update to Version 140.
-- 05/19/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE FUNCTION f_dba19_utl_ConvertHexToDec 
(
	-- Add the parameters for the function here
	@hexvalue varchar(20)
)
RETURNS bigint
AS
BEGIN
	-------- Declare the return variable here
	------DECLARE @Result int

	-- Add the T-SQL statements to compute the return value here

	DECLARE @decimalout		bigint
	DECLARE @hexlen			int
	DECLARE @icount			int
--DECLARE @acharacter		char(1)
	DECLARE @newchar		char(8)
	DECLARE @thehex			char(8)
--DECLARE @decimalout2	bigint
--DECLARE @decimalout3	bigint
--DECLARE @newdecimalvalue	bigint

	DECLARE @fixed TABLE (
			hexvalue		char(1),
			rownumbr		int,
			decimalvalue	bigint)

	DECLARE @hex_alpha TABLE (
			hexletter		char(1),
			numbr			varchar(2))

	INSERT @hex_alpha (hexletter, numbr)
		VALUES ('A','10');

	INSERT @hex_alpha (hexletter, numbr)
		VALUES ('B','11');

	INSERT @hex_alpha (hexletter, numbr)
		VALUES ('C','12');

	INSERT @hex_alpha (hexletter, numbr)
		VALUES ('D','13');

	INSERT @hex_alpha (hexletter, numbr)
		VALUES ('E','14');

	INSERT @hex_alpha (hexletter, numbr)
		VALUES ('F','15');
		
	SET @thehex = @hexvalue;

--SET @thehex = '1000009d'
----SET @thehex = '0000009d'
----SET @thehex = '1234569d'

-- make a copy of the hex
	SET @newchar = @thehex;

--print 'newcar ' + @newchar

-- get the length of the hex number
	SET @hexlen = len(@thehex);

-- initialize the counter
	SET @icount = 1;

	WHILE (@icount <= @hexlen)
		BEGIN

			INSERT @fixed
				(hexvalue, rownumbr)
				SELECT SUBSTRING(@newchar,@icount,1), @icount;

		-- put it in the array
		
		-- update the pointer
			SET @icount = @icount + 1;

			IF @icount > @hexlen BREAK;

		END

	-- do another loop and update the decimalvalue with the decimal equivalent
	SET @icount = 1;

	--print 'reset icount ' + convert(char(2),@icount);

	WHILE (@icount <= @hexlen)
		BEGIN

		-- update numbers only
		UPDATE @fixed
			SET decimalvalue = 
				--(SELECT @icount, rownumbr, convert(int,hexvalue) * (POWER(16,(@hexlen - @icount  )))
				(SELECT convert(int,hexvalue) * (POWER(16,(@hexlen - @icount  )))
					FROM @fixed
				WHERE rownumbr = @icount AND 
						hexvalue IN ('0','1','2','3','4','5','6','7','8','9'))
			WHERE rownumbr = @icount;--);

			SET @icount = @icount + 1;

			IF @icount > @hexlen BREAK;
						
		END

		-- update Alpha only
			UPDATE @fixed
				SET decimalvalue = (SELECT a.numbr
										FROM @hex_alpha  a
											JOIN @fixed F ON (a.hexletter = f.hexvalue) AND
												f.hexvalue IN ('A','B','C','D','E','F'))
									WHERE hexvalue IN ('A','B','C','D','E','F');

--PRINT '** Done ** '
		--select * from @fixed

		SET @decimalout = (SELECT sum(decimalvalue)
			FROM @fixed);


	---- reconstruct into a single number


		--PRINT 'finished ' + convert(varchar(100),@decimalout)
		RETURN @decimalout
	-- Return the result of the function
	------RETURN @Result

END
GO

