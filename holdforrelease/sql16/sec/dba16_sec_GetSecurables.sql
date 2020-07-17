SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sec_GetSecurables
--
--
-- Calls:		None
--
-- Description:	Get a listing of securables.
-- 
-- Date			Modified By			Changes
-- 08/09/2016   Aron E. Tekulsky    Initial Coding.
-- 10/31/2017   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	SELECT u.name, u.uid, u.status, u.sid,
			p.action, p.protecttype, p.columns, p.grantor, p.id,
			o.name, o.xtype
		FROM sys.sysusers u
			JOIN sys.sysprotects p on (p.uid = u.uid)
			JOIN sys.sysobjects o on (p.id = o.id)
	ORDER BY xtype, o.name ASC;

END
GO
