USE [form0]
GO

INSERT INTO [dbo].[addrtable3]
           ([custnum]
           ,[addr]
           ,[zp])
SELECT [custnum]
      ,[addr]
      ,[zp]
  FROM [dbo].[addrtable2]
GO


