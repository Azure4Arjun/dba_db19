--USE [dba_db]
--Go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************************************************************
**		 
**		Name: [p_tes_object_give_permission]
**		Desc: It calls SP p_tes_object_check_permission and
              gives permission to those objects who dont have
              db_proc_exec role and after that it displays total SP and Functions in database
              and all sp and Functions who has db_proc_exec permission

**		Parameters:
**		Input	 = @Database  =database name						

**		Auth: Nirav Parikh
**		Date: 03/09/2009
*******************************************************************************/


CREATE PROCEDURE p_tes_object_give_permission
@database varchar(100)
AS

CREATE TABLE #TEMP
(name varchar(100), id int, xtype varchar(3),type varchar(3),crdate datetime, role varchar(20))

--SET ansi_warnings off
--DECLARE @database varchar(100)
--SET @database = 'dba_db'
INSERT into #TEMP
Exec [p_tes_object_check_permission] @database

CREATE table #test
(number int identity,name varchar(100), id int, xtype varchar(3),role varchar(20))

INSERT into #Test--(number,name,id,xtype,role) 
SELECT name,id,xtype,role 
FROM #TEMP WHERE id not in 
(SELECT id FROM #TEMP WHERE role = 'db_proc_exec')
--SELECT * FROM #test

DECLARE @name varchar(100)
DECLARE @var int
--DECLARE @database varchar(100)
--SET @database = 'dba_db'
SET @var =1
WHILE @var <= (SELECT count(*) FROM #test) 
BEGIN
--SELECT @name=name FROM #TEMPWHERE number = @var
SELECT @name =name FROM #test WHERE number = @var
EXEC('use ['+@database+']
GRANT EXECUTE ON ['+@name+']  TO db_proc_exec')
--print @var 
SET @var = @var +1
END

--drop table #TEMP
--drop table #test
--DECLARE @database varchar(100)
--SET @database = 'northwind'
EXEC('select count(*) as ''no of F and P'' from ['+@Database+']..sysobjects 
WHERE 
(Xtype = '''+'FN'+''' or 
 Xtype = '''+'IF' +'''or 
 Xtype = '''+'P'+'''  
 or Xtype = '''+'TF'+''' 
 --or Xtype = '''+'V'+''' 
)
and name not like '''+'%sys%'+'''
and name not like '''+'%dt%'+''' ')


--DECLARE @database varchar(100)
--SET @database = 'northwind'
Exec ('SELECT a.name, a.id, a.xtype, a.type,a.crdate,c.name as role
FROM ['+@database + ']..sysobjects a Left join ['+
@database + ']..syspermissions b On a.id = b.id
Left join ['+
@database + ']..sysusers c On b.grantee = c.uid
WHERE 
(Xtype = '''+'FN'+''' or 
 Xtype = '''+'IF' +'''or 
 Xtype = '''+'P'+'''  
 or Xtype = '''+'TF'+''' 
 --or Xtype = '''+'V'+''' 
)
and a.name not like '''+'%sys%'+'''
and a.name not like '''+'%dt%'+''' 
and c.name = ''db_proc_exec'' 
order by a.xtype, c.name desc')

/*select count(*)as 'no of F and P' from northwind..sysobjects 
where type = 'P' --or type = 'FN'
and name not like '%sys%' and
name not like 'dt%' 

SELECT a.name, a.id, a.xtype, a.type,a.crdate,c.name as role
FROM northwind..sysobjects a left join northwind..syspermissions b  
On a.id  = b.id left join northwind..sysusers c on b.grantee = c.uid
WHERE --(Xtype = 'FN' or Xtype = 'IF' or 
(Xtype = 'P') 
--or Xtype = 'TF')
 and
a.name not like '%sys%' and
a.name not like 'dt%' 
and c.name = 'db_proc_exec'
ORDER BY a.xtype*/


SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO











