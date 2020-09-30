Get-SqlDatabase -ServerInstance E-TEKNOLOGIES\SQL2019 | Where { $_.Name -ne 'tempdb' } | Backup-SqlDatabase
