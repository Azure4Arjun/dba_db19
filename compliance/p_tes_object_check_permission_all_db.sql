USE [test]
GO
/****** Object:  StoredProcedure [dbo].[p_tes_object_check_permission_all_db]    Script Date: 03/09/2009 11:51:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_WARNINGS ON
GO
/******************************************************************************
**		 
**		Name: [p_tes_object_check_permission_all_db]
**		Desc: Lists all SP and Functions who have db_proc_exec role or not

**		Parameters:
**		Input	 					

**		Auth: Nirav Parikh
**		Date: 3/11/2009
*******************************************************************************/
  
ALTER Procedure [dbo].[p_tes_object_check_permission_all_db]
--@database varchar(50)
As
BEGIN

CREATE TABLE #Temp (id int identity, name varchar(80), dbStatus nvarchar(128))

INSERT INTO #TEMP(name,dbstatus)
SELECT Name,convert(varchar,databasepropertyex(Name,'Status'))as DBStatus
		FROM	master..sysdatabases
		WHERE	name NOT IN ('master', 'model', 'msdb', 'tempdb')
		AND databasepropertyex(Name,'Status') = 'ONLINE'
		--AND name <> ('SQLdmRepository')
		ORDER BY databasepropertyex(Name,'Status') desc
--SELECT * FROM #Temp 
--DROP TABLE #temp 
CREATE TABLE IIE(dbname varchar(200),objectname varchar(200), id int,xtype char(2),type char(2),crdate datetime,role varchar(100))
DECLARE @var int
DECLARE @name varchar(200)
--DECLARE @dbname varchar(200)
SET @var = 1
while @var < = (SELECT count(*) from #temp) --SELECT * from #temp
Begin
DECLARE @dbname varchar(200)
DECLARE @CMD varchar(500)
SELECT @dbname= name FROM #temp WHERE id =@var  --print @dbname 
SET @name = @dbname
--Insert into IIE (dbname)values(@dbname)
--DECLARE @name varchar(200)
--DECLARE @CMD varchar(500)
--SET @name = 'pubs'
--SELECT ['+@name+'] as dbname,
--SELECT @cmd=(' 
print 'inserting into ['+@name+']'
Insert into IIE
--PRINT ('
EXEC('
SELECT '''
+@name+''' as dbname,a.name,a.id,a.xtype,a.type,a.crdate,c.name as role
FROM ['+@name+']..sysobjects a left join ['+@name+']..syspermissions b  
On a.id  = b.id left join ['+@name+']..sysusers c on b.grantee = c.uid
WHERE 
(a.xtype = '''+'FN'+''' or 
 a.xtype = '''+'IF' +'''or 
 a.xtype = '''+'P'+'''  
 or a.xtype = '''+'TF'+''' 
 --or a.xtype = '''+'V'+''' 
)
and a.name not like '''+'%sys%'+'''
and a.name not like '''+'%dt%'+''' 
--and c.name = ''db_proc_exec'' ')
--EXEC (@cmd)
--print @cmd
--SELECT * from IIE 
--END
SET @var =@var + 1
END
SELECT * from IIE order by dbname
DROP TABLE IIE
END
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_WARNINGS OFF
GO 