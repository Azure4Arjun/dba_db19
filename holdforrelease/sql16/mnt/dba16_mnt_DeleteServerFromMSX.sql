SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_mnt_DeleteServerFromMSX
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 04/17/2018 Aron E. Tekulsky Initial Coding.
-- ======================================================================================
--	Copyrightę2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @ServerName nvarchar(128)

	SET @ServerName = 'SERVER\INSTANCE';

	EXEC msdb..sp_delete_targetserver @ServerName;
END
GO
