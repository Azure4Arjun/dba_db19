USE [master]
GO
sp_configure 'show advanced options',1
GO
RECONFIGURE WITH OVERRIDE
GO
sp_configure 'Database Mail XPs',1
GO
RECONFIGURE 
GO

sp_configure 'Min Server Memory', 0
GO 
RECONFIGURE 
GO

-- (128gb 131072, 64gb 65536, 48gb 49152, 32gb 32768 16gb 16384
sp_configure 'Max Server Memory', 49152
GO 
RECONFIGURE 
GO

sp_configure 'Max Degree of Parallelism', 0
GO 
RECONFIGURE 
GO

sp_configure 'Remote admin connections', 1
GO 
RECONFIGURE 
GO

sp_configure 'XP_CmdShell', 1
GO 
RECONFIGURE 
GO

sp_configure 'Backup Compression Default', 1
GO 
RECONFIGURE 
GO

sp_configure 'Replace Alert Tokens Enabled', 1
GO 
RECONFIGURE 
GO



--
--
--
--

