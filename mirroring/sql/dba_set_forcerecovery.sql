--****************************************************
-- Force failover of Mirror to bring it on-line when  *
-- principal is down and either there is no mirror or *
-- mirror is down as well.                            *
--*****************************************************

ALTER DATABASE <database_name> SET PARTNER FORCE_SERVICE_ALLOW_DATA_LOSS

