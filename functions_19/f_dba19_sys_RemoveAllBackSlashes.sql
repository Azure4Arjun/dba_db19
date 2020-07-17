USE [dba_db19]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ======================================================================================
-- f_dba19_sys_RemoveAllBackSlashes
--
-- Arguments:	@p1	nvarchar(4000)
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Remove all back slashes from the string passed.
--
-- Date			Modified By			Changes
-- 02/06/2013   Aron E. Tekulsky    Initial Coding.
-- 12/26/2017   Aron E. Tekulsky    Update to Version 140.
-- 05/19/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE FUNCTION [dbo].[f_dba19_sys_RemoveAllBackSlashes] 
(
	-- Add the parameters for the function here
	@p1 nvarchar(4000)
)
RETURNS nvarchar(4000)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result nvarchar(4000)

	-- Add the T-SQL statements to compute the return value here		
	DECLARE @char_location		int
	DECLARE @start_pos			int

	SET @char_location = 1

	--SET @p1 = 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.DBS2008R2\MSSQL\DATA\master.mdf'
	
	SET @start_pos = 1

	WHILE (@char_location > 0)
		BEGIN


	-- Add the T-SQL statements to compute the return value here
	
	
		SET @char_location = CHARINDEX('\',@p1,@start_pos)

		IF @char_location > 0
			BEGIN
				SET @p1 = SUBSTRING(@p1,@char_location + 1 , LEN(@p1) - @char_location)
				SET @start_pos =  1
				--print 'startpos ' + convert(varchar(5), @start_pos)
			END
	
		ELSE
			begin
				SET @p1 = SUBSTRING(@p1,1, LEN(@p1)) -- @char_location
				SET @Result = @p1
				--print ' **** done ****'
			end
		
	
			--PRINT @p1 + ' ch loc ' +  convert(varchar(5),isnull(@char_location,0)) + ' stpos ' + convert(varchar(5),isnull(@start_pos,0))
	
		END
	
	-- Return the result of the function
	RETURN @Result

END

GO


