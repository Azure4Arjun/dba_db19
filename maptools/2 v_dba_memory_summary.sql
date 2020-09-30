--USE [serverinventory20160822]
--GO

/****** Object:  View [dbo].[v_dba_memory_summary]    Script Date: 10/17/2016 2:42:41 PM ******/
DROP VIEW [dbo].[v_dba_memory_summary]
GO

/****** Object:  View [dbo].[v_dba_memory_summary]    Script Date: 10/17/2016 2:42:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[v_dba_memory_summary] AS
	SELECT [DeviceNumber]
		  ------------,[Uid]
		 ,[Capacity]/1024/1024 AS TotalCapacity
      ------,[CreateCollectorId]
      --,[CreateDatetime]
      ------,[DataWidth]
      --,[DeviceLocator]
      --,[Speed]
      --,[Tag]
      ------,[TotalWidth]
      ------,[TypeDetail]
      --,[UpdateCollectorId]
      --,[UpdateDatetime]
	FROM [serverinventory201701].[dbo].[v_dba_memory]
--GROUP BY [DeviceNumber]--, [Uid]


GO


