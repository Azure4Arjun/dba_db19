USE [dba_db08]
GO

/****** Object:  StoredProcedure [dbo].[p_dba08_object_check_permission]    Script Date: 03/09/2009 11:51:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_WARNINGS ON
GO

-- ==============================================================================
-- p_dba08_object_check_permission
--
-- Arguments:		@Database  =database name
--					None
--
-- Called BY:		None
--
-- Description:	Lists all SP and Functions who have db_proc_exec role or not.
-- 
-- Date				Modified By			Changes
-- 02/04/2009	Aron E. Tekulsky    Initial Coding.
-- 04/18/2012	Aron E. Tekulsky	Update to v100.
-- ===============================================================================
--	Copyright©2009 - 2012 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================

create Procedure [dbo].[p_dba08_object_check_permission]
@database varchar(50)
As
BEGIN

SET NOCOUNT ON;

DECLARE @dbname varchar(30) 
--DECLARE @database varchar(30) 
--DECLARE cursor
DECLARE all_db cursor for 
SELECT name 
FROM sys.databases 
WHERE name  = @database /*not in ('master','model','msdb','tempdb') */

--open cursor
Open all_db 

Fetch next FROM all_db INTO @dbname

WHILE  (@@Fetch_status = 0) 

BEGIN
SET @database = @dbname 

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
--and c.name = ''db_proc_exec'' 
order by a.xtype, c.name desc')

Fetch next FROM all_db INTO @dbname

END
close all_db
deallocate all_db
END

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_WARNINGS OFF
GO



/*select a.name, a.id, a.xtype, a.type,a.crdate,c.name as role
FROM sysobjects a left join syspermissions b  
On a.id  = b.id left join sysusers c on b.grantee = c.uid
where (Xtype = 'FN' or Xtype = 'IF' or 
Xtype = 'P' or 
Xtype = 'TF') and
a.name not like '%sys%' and
a.name not like 'dt%' 
and c.name = 'db_proc_exec'
order by a.xtype*/
