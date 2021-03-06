USE [master]
GO
ALTER LOGIN [soxuser] WITH DEFAULT_DATABASE=[sox], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF, NO CREDENTIAL
GO
USE [bo5rep]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [bo5rep]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [bobjecms ]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [bobjecms_qa]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [bobjecms_qa]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [borepo]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [borepo]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [btt]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [btt]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [cdr]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [cdr]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [cdr_SAP]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [cdr_SAP]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [ciesuser]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [ciesuser]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [ciesweb]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [ciesweb]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [congressional_district]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [congressional_district]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [de_pep]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [de_pep]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [dms]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [dms]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [dmsembark]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [dmsembark]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [dt2]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [dt2]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [eapsecurity]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [eapsecurity]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [eautopay]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [eautopay]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [etime]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [etime]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [faip]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [faip]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [FGS]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [FGS]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [frpt]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [frpt]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [frptfust]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [frptfust]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [fsp]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [fsp]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [fsp_sec]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [fsp_sec]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [fsp_sec_uat]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [fsp_sec_uat]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [fsp_uat]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [fsp_uat]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [Fulbright]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [Fulbright]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [grantax]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [grantax]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [gsgl]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [gsgl]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [gtlf]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [gtlf]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [gtlf_sec]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [gtlf_sec]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [gtlf_sec_uat]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [gtlf_sec_uat]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [gtlf_uat]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [gtlf_uat]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [ifp]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [ifp]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [ihrip]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [ihrip]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [iie_dm_eca]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [iie_dm_eca]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [iie_dm_finance]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [iie_dm_finance]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [iie_dm_finance_SAP]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [iie_dm_finance_SAP]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [iie_enterprise]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [iie_enterprise]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [iie_enterprise_eautopay_sec]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [iie_enterprise_eautopay_sec]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [iie_enterprise_fgs_sec]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [iie_enterprise_fgs_sec]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [iie_enterprise_QA]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [iie_enterprise_QA]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [iie_enterprise_sec]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [iie_enterprise_sec]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [iie_enterprise_sec_training]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [iie_enterprise_sec_training]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [iie_enterprise_sec_uat]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [iie_enterprise_sec_uat]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [iie_enterprise_sevis]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [iie_enterprise_sevis]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [iie_enterprise_training]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [iie_enterprise_training]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [iie_enterprise_uat]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [iie_enterprise_uat]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [iiemasterdb]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [iiemasterdb]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [iienew]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [iienew]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [iiesecurity]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [iiesecurity]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [iiesecurityadmin_assyst]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [iiesecurityapplicant_assyst]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [insrpt]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [insrpt]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [itreq]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [itreq]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [itt]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [itt]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [jiradb]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [jiradb]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [nsep]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [nsep]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [olp]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [olp]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [paymentrequest]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [paymentrequest]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [pep]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [pep]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [pep_financial]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [pep_financial]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [sch]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [sch]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [sevis]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [sevis]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [ssmatesterdb_syb]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [ssmatesterdb_syb]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [survey]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [survey]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [testchecksum]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [testchecksum]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [tng]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [tng]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [transponder]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [transponder]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [transponder2]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [transponder2]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [webdb_finip]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [webdb_finip]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
USE [wit]
GO
CREATE USER [soxuser] FOR LOGIN [soxuser]
GO
USE [wit]
GO
EXEC sp_addrolemember N'db_proc_exec', N'soxuser'
GO
