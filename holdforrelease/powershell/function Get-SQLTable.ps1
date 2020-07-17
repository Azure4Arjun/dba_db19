<# function Get-SQLTable
{ #>
    <# [CmdletBinding()]
    param( 
  
        [Parameter(Mandatory=$true)]
        [string] $SourceSQLInstance,
 
        [Parameter(Mandatory=$true)]
        [string] $SourceDatabase,        
         
        [Parameter(Mandatory=$true)]
        [string] $TargetSQLInstance,
         
        [Parameter(Mandatory=$true)]
        [string] $TargetDatabase,
         
        [Parameter(Mandatory=$true)]
        [string[]] $Tables,
 
        [Parameter(Mandatory=$false)]
        [int] $BulkCopyBatchSize = 10000,
 
        [Parameter(Mandatory=$false)]
        [int] $BulkCopyTimeout = 600   
  
    ) #>
  
     $SourceSQLInstance = "E-TEKNOLOGIES\SQL2016"
     $SourceDatabase = "test8_partitions"
     $TargetSQLInstance = "E-TEKNOLOGIES\SQL2019"
     $TargetDatabase = "test8_partitions"
     $Tables = "Table_2nonpartitioned"
 
    
  
    $sourceConnStr = "Data Source=$SourceSQLInstance;Initial Catalog=$SourceDatabase;Integrated Security=True;"
    $TargetConnStr = "Data Source=$TargetSQLInstance;Initial Catalog=$TargetDatabase;Integrated Security=True;"
      
    try
    {    
           
        Import-Module -Name SQLServer
        write-host 'module loaded'
        $sourceSQLServer = New-Object Microsoft.SqlServer.Management.Smo.Server $SourceSQLInstance
        $sourceDB = $sourceSQLServer.Databases[$SourceDatabase]
       $sourceConn  = New-Object System.Data.SqlClient.SQLConnection($sourceConnStr)
     
        $sourceConn.Open()
      
        write-host "SourceSQLServer is $SourceSQLServer"
        write-host "SourceDatabase is $SourceDatabase"
     
 
        foreach($table in $sourceDB.Tables)
        {
        
            $tableName = $table.Name
            $schemaName = $table.Schema
            $tableAndSchema = "$schemaName.$tableName"
 
             if ($Tables.Contains($tableAndSchema))
            {
            $Tablescript = ($table.Script() | Out-String)
            $Tablescript
 
                Invoke-Sqlcmd `
                            -ServerInstance $TargetSQLInstance `
                            -Database $TargetDatabase `
                            -Query $Tablescript
  
             
                    $sql = "SELECT * FROM $tableAndSchema"
                    $sqlCommand = New-Object system.Data.SqlClient.SqlCommand($sql, $sourceConn) 
                    [System.Data.SqlClient.SqlDataReader] $sqlReader = $sqlCommand.ExecuteReader()        
                    $bulkCopy = New-Object Data.SqlClient.SqlBulkCopy($TargetConnStr, [System.Data.SqlClient.SqlBulkCopyOptions]::KeepIdentity)
                    $bulkCopy.DestinationTableName = $tableAndSchema
                    $bulkCopy.BulkCopyTimeOut = $BulkCopyTimeout
                    $bulkCopy.BatchSize = $BulkCopyBatchSize
                    $bulkCopy.WriteToServer($sqlReader)
                    $sqlReader.Close()
                    $bulkCopy.Close()
                }
                }
 
 
  
 
        $sourceConn.Close()
 
 
    }
    catch
    {
        [Exception]$ex = $_.Exception
        write-host $ex.Message
    }
    finally
    {
        #Return value if any
    }
#}