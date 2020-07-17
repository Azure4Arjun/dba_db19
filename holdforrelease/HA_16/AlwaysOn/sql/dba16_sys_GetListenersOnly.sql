SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_GetListenersOnly
--
--
-- Calls:		None
--
-- Description:	Get a list of listeners only.
-- 
-- Date			Modified By			Changes
-- 10/20/2016   Aron E. Tekulsky    Initial Coding.
-- 12/27/2017   Aron E. Tekulsky    Update to V140.
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
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

/****** Script for SelectTopNRows command from SSMS  ******/
	SELECT -- l.[group_id]
      --,l.[listener_id],
		l.[dns_name] AS AvailabilityListenerName
		,l.[port]
      --,l.[is_conformant]
      --,l.[ip_configuration_string_from_cluster]
		--,i.[listener_id]
       ,i.[ip_subnet_mask]
		,CONVERT(nvarchar(16),i.[network_subnet_ip]) + '/' + 
		CONVERT(nvarchar(16),i.[network_subnet_prefix_length]) as Subnet
		,i.[ip_address]
      --,i.[is_dhcp]
      --,i.[network_subnet_ipv4_mask]
      --,i.[state]
      ,i.[state_desc]
		FROM [master].[sys].[availability_group_listeners] l
			JOIN [master].[sys].[availability_group_listener_ip_addresses] i ON (i.listener_id = l.listener_id );

END
GO
