-- set up Dedicated Administrator Connection - used when server is in bad state.
sp_configure 'remote admin connections', 1;
GO
RECONFIGURE;
GO