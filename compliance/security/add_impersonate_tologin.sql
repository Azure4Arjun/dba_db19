--========================================================================
--	We need to grant impersonate of login soxuser to each domain id 
--	that has the potential to do structure changes to a db so that the
--	triggers can record the changes in the sox db.
--
--========================================================================

--USE [master]
--GO
--ALTER LOGIN [IIE\sshah] WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
--GO
use [master]
GO
GRANT IMPERSONATE ON LOGIN::[soxuser] TO [IIE\dkukharenko]
GO
GRANT IMPERSONATE ON LOGIN::[soxuser] TO [IIE\jchen2]
GO
GRANT IMPERSONATE ON LOGIN::[soxuser] TO [IIE\kmahadevan]
GO
GRANT IMPERSONATE ON LOGIN::[soxuser] TO [IIE\kswamy]
GO
GRANT IMPERSONATE ON LOGIN::[soxuser] TO [IIE\nrajmohan]
GO
GRANT IMPERSONATE ON LOGIN::[soxuser] TO [IIE\sshah]
GO
