SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sec_FindSpnFuncPermissions
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 11/22/2017   Aron E. Tekulsky    Initial Coding.
-- 11/22/2017   Aron E. Tekulsky    Update to Version 140.
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

	SELECT o.name, o.id, o.xtype,
			p.grantee, p.grantor, p.actmod, p.actmod, p.seladd,
			p.selmod, p.updadd, p.updmod, p.refadd, p.refmod
		FROM sysobjects o
			LEFT OUTER JOIN syspermissions p ON (o.id = p.id)
	WHERE  o.xtype IN ('P', 'FN', 'TF',  'IF') AND
			o.name NOT LIKE ('dt_%')
	ORDER BY  o.name ASC;

END
GO
