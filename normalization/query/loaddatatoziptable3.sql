USE [form0]
GO

INSERT INTO [dbo].[ziptable3]
           ([zp]
           ,[city]
           ,[st])
SELECT [zp]
      ,[city]
      ,[st]
  FROM [dbo].[addrtable2]
GO


