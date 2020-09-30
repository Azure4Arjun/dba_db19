SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_avg_SetSpnCode
--
--
-- Calls:		None
--
-- Description:	Set the SPN.
-- 
-- Date			Modified By			Changes
-- 06/10/2016   Aron E. Tekulsky    Initial Coding.
-- 09/17/2018   Aron E. Tekulsky    Update to Version 140.
-- 08/07/2020   Aron E. Tekulsky    Update to Version 150.
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
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @account		nvarchar(500)
	DECLARE @return_value	int
	DECLARE	@regvalue		nvarchar(500)

	EXEC @return_value = [dba_db19].[dbo].[p_dba19_sys_GetRegistryValue]
		@regitem = 2,
		@regvalue = @regvalue OUTPUT;

--SELECT	@regvalue as N'@regvalue'
--		SELECT	'Return Value' = @return_value


	SET @account = @regvalue;

--print 'the service account **** ' + @account;

	 SELECT 'setspn –S MSSQLSvc/' +
		  l.[dns_name]  + ':' + convert(varchar(10),l.port) + ' '  + @account
		FROM [master].[sys].[availability_groups_cluster] c
			JOIN [master].[sys].[availability_group_listeners] l ON (l.group_id = c.group_id );

END
GO
