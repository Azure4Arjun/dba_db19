USE [dba_db19]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ==============================================================================
-- f_dba19_utl_GetAlwaysOn
--
-- Arguments:		None
--					None
--
-- Called BY:		None
--
-- Description:	Get whethere always on is enabled.
-- 
-- Date				Modified By			Changes
-- 06/17/2016   Aron E. Tekulsky    Initial Coding.
-- 06/17/2016	Aron E. Tekulsky	Update to v120.
-- 12/26/2017   Aron E. Tekulsky    Update to V140.
-- 05/19/2020   Aron E. Tekulsky    Update to V150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================

CREATE FUNCTION [dbo].[f_dba19_utl_GetAlwaysOn] 
(
	-- Add the parameters for the function here
)
RETURNS nvarchar(20)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result	nvarchar(20)

	-- Add the T-SQL statements to compute the return value here
	SET @Result = CASE convert(nvarchar(128),serverproperty('IsHadrEnabled'))
					WHEN 1 THEN
						' Always On enabled'
					WHEN 0 THEN
						' Always On disabled'
					END;

	-- Return the result of the function
	RETURN @Result

END


GO


