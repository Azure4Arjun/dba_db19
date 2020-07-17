--USE [serverinventory20160822]
--GO

/****** Object:  View [dbo].[v_dba_memory]    Script Date: 9/28/2016 2:29:35 PM ******/
DROP VIEW [dbo].[v_dba_memory]
GO

/****** Object:  View [dbo].[v_dba_memory]    Script Date: 9/28/2016 2:29:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[v_dba_memory] AS
SELECT m.[DeviceNumber]
      ,m.[Uid]
      ,m.[Capacity]
      ,m.[CreateCollectorId]
      ,m.[CreateDatetime]
      ,m.[DataWidth]
      ,m.[DeviceLocator]
      ,m.[Speed]
      ,m.[Tag]
      ,m.[TotalWidth]
      ,m.[TypeDetail]
      ,m.[UpdateCollectorId]
      ,m.[UpdateDatetime]
FROM [serverinventory201701].[Win_Inventory].[PhysicalMemory] m 
--ORDER BY m.DeviceNumber , m.Uid 
GO


