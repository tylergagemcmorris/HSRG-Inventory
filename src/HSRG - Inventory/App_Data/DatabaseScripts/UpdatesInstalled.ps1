Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string] $DataSource,

    [Parameter(Mandatory=$True)]
    [string] $FilePath
)

function Out-DataTable
{
<#
.SYNOPSIS
    Creates a DataTable for an object

.DESCRIPTION
    Creates a DataTable based on an object's properties.

.PARAMETER InputObject
    One or more objects to convert into a DataTable

.PARAMETER NonNullable
    A list of columns to set disable AllowDBNull on

.INPUTS
    Object
        Any object can be piped to Out-DataTable

.OUTPUTS
   System.Data.DataTable

.EXAMPLE
    $dt = Get-psdrive | Out-DataTable
    
    # This example creates a DataTable from the properties of Get-psdrive and assigns output to $dt variable

.EXAMPLE
    Get-Process | Select Name, CPU | Out-DataTable | Invoke-SQLBulkCopy -ServerInstance $SQLInstance -Database $Database -Table $SQLTable -force -verbose

    # Get a list of processes and their CPU, create a datatable, bulk import that data

.NOTES
    Adapted from script by Marc van Orsouw and function from Chad Miller
    Version History
    v1.0  - Chad Miller - Initial Release
    v1.1  - Chad Miller - Fixed Issue with Properties
    v1.2  - Chad Miller - Added setting column datatype by property as suggested by emp0
    v1.3  - Chad Miller - Corrected issue with setting datatype on empty properties
    v1.4  - Chad Miller - Corrected issue with DBNull
    v1.5  - Chad Miller - Updated example
    v1.6  - Chad Miller - Added column datatype logic with default to string
    v1.7  - Chad Miller - Fixed issue with IsArray
    v1.8  - ramblingcookiemonster - Removed if($Value) logic.  This would not catch empty strings, zero, $false and other non-null items
                                  - Added perhaps pointless error handling

.LINK
    https://github.com/RamblingCookieMonster/PowerShell

.LINK
    Invoke-SQLBulkCopy

.LINK
    Invoke-Sqlcmd2

.LINK
    New-SQLConnection

.FUNCTIONALITY
    SQL
#>
    [CmdletBinding()]
    [OutputType([System.Data.DataTable])]
    param(
        [Parameter( Position=0,
                    Mandatory=$true,
                    ValueFromPipeline = $true)]
        [PSObject[]]$InputObject,

        [string[]]$NonNullable = @()
    )

    Begin
    {
        $dt = New-Object Data.datatable  
        $First = $true 

        function Get-ODTType
        {
            param($type)

            $types = @(
                'System.Boolean',
                'System.Byte[]',
                'System.Byte',
                'System.Char',
                'System.Datetime',
                'System.Decimal',
                'System.Double',
                'System.Guid',
                'System.Int16',
                'System.Int32',
                'System.Int64',
                'System.Single',
                'System.UInt16',
                'System.UInt32',
                'System.UInt64')

            if ( $types -contains $type ) {
                Write-Output "$type"
            }
            else {
                Write-Output 'System.String'
            }
        } #Get-Type
    }
    Process
    {
        foreach ($Object in $InputObject)
        {
            $DR = $DT.NewRow()  
            foreach ($Property in $Object.PsObject.Properties)
            {
                $Name = $Property.Name
                $Value = $Property.Value
                
                #RCM: what if the first property is not reflective of all the properties?  Unlikely, but...
                if ($First)
                {
                    $Col = New-Object Data.DataColumn  
                    $Col.ColumnName = $Name  
                    
                    #If it's not DBNull or Null, get the type
                    if ($Value -isnot [System.DBNull] -and $Value -ne $null)
                    {
                        $Col.DataType = [System.Type]::GetType( $(Get-ODTType $property.TypeNameOfValue) )
                    }
                    
                    #Set it to nonnullable if specified
                    if ($NonNullable -contains $Name )
                    {
                        $col.AllowDBNull = $false
                    }

                    try
                    {
                        $DT.Columns.Add($Col)
                    }
                    catch
                    {
                        Write-Error "Could not add column $($Col | Out-String) for property '$Name' with value '$Value' and type '$($Value.GetType().FullName)':`n$_"
                    }
                }  
                
                Try
                {
                    #Handle arrays and nulls
                    if ($property.GetType().IsArray)
                    {
                        $DR.Item($Name) = $Value | ConvertTo-XML -As String -NoTypeInformation -Depth 1
                    }
                    elseif($Value -eq $null)
                    {
                        $DR.Item($Name) = [DBNull]::Value
                    }
                    else
                    {
                        $DR.Item($Name) = $Value
                    }
                }
                Catch
                {
                    Write-Error "Could not add property '$Name' with value '$Value' and type '$($Value.GetType().FullName)'"
                    continue
                }

                #Did we get a null or dbnull for a non-nullable item?  let the user know.
                if($NonNullable -contains $Name -and ($Value -is [System.DBNull] -or $Value -eq $null))
                {
                    write-verbose "NonNullable property '$Name' with null value found: $($object | out-string)"
                }

            } 

            Try
            {
                $DT.Rows.Add($DR)
            }
            Catch
            {
                Write-Error "Failed to add row '$($DR | Out-String)':`n$_"
            }

            $First = $false
        }
    } 
     
    End
    {
        Write-Output @(,$dt)
    }

} #Out-DataTable

function Invoke-SQLiteBulkCopy {
<#
.SYNOPSIS
    Use a SQLite transaction to quickly insert data

.DESCRIPTION
    Use a SQLite transaction to quickly insert data.  If we run into any errors, we roll back the transaction.
    
    The data source is not limited to SQL Server; any data source can be used, as long as the data can be loaded to a DataTable instance or read with a IDataReader instance.

.PARAMETER DataSource
    Path to one ore more SQLite data sources to query 

.PARAMETER Force
    If specified, skip the confirm prompt

.PARAMETER  NotifyAfter
	The number of rows to fire the notification event after transferring.  0 means don't notify.  Notifications hit the verbose stream (use -verbose to see them)

.PARAMETER QueryTimeout
    Specifies the number of seconds before the queries time out.

.PARAMETER SQLiteConnection
    An existing SQLiteConnection to use.  We do not close this connection upon completed query.

.PARAMETER ConflictClause
    The conflict clause to use in case a conflict occurs during insert. Valid values: Rollback, Abort, Fail, Ignore, Replace

    See https://www.sqlite.org/lang_conflict.html for more details

.EXAMPLE
    #
    #Create a table
        Invoke-SqliteQuery -DataSource "C:\Names.SQLite" -Query "CREATE TABLE NAMES (
            fullname VARCHAR(20) PRIMARY KEY,
            surname TEXT,
            givenname TEXT,
            BirthDate DATETIME)" 

    #Build up some fake data to bulk insert, convert it to a datatable
        $DataTable = 1..10000 | %{
            [pscustomobject]@{
                fullname = "Name $_"
                surname = "Name"
                givenname = "$_"
                BirthDate = (Get-Date).Adddays(-$_)
            }
        } | Out-DataTable

    #Copy the data in within a single transaction (SQLite is faster this way)
        Invoke-SQLiteBulkCopy -DataTable $DataTable -DataSource $Database -Table Names -NotifyAfter 1000 -ConflictClause Ignore -Verbose 
        
.INPUTS
    System.Data.DataTable

.OUTPUTS
    None
        Produces no output

.NOTES
    This function borrows from:
        Chad Miller's Write-Datatable
        jbs534's Invoke-SQLBulkCopy
        Mike Shepard's Invoke-BulkCopy from SQLPSX

.LINK
    https://github.com/RamblingCookieMonster/Invoke-SQLiteQuery

.LINK
    New-SQLiteConnection

.LINK
    Invoke-SQLiteBulkCopy

.LINK
    Out-DataTable

.FUNCTIONALITY
    SQL
#>
    [cmdletBinding( DefaultParameterSetName = 'Datasource',
                    SupportsShouldProcess = $true,
                    ConfirmImpact = 'High' )]
    param(
        [parameter( Position = 0,
                    Mandatory = $true,
                    ValueFromPipeline = $false,
                    ValueFromPipelineByPropertyName= $false)]
        [System.Data.DataTable]
        $DataTable,

        [Parameter( ParameterSetName='Datasource',
                    Position=1,
                    Mandatory=$true,
                    ValueFromRemainingArguments=$false,
                    HelpMessage='SQLite Data Source required...' )]
        [Alias('Path','File','FullName','Database')]
        [validatescript({
            #This should match memory, or the parent path should exist
            if ( $_ -match ":MEMORY:" -or (Test-Path $_) ) {
                $True
            }
            else {
                Throw "Invalid datasource '$_'.`nThis must match :MEMORY:, or must exist"
            }
        })]
        [string]
        $DataSource,

        [Parameter( ParameterSetName = 'Connection',
                    Position=1,
                    Mandatory=$true,
                    ValueFromPipeline=$false,
                    ValueFromPipelineByPropertyName=$true,
                    ValueFromRemainingArguments=$false )]
        [Alias( 'Connection', 'Conn' )]
        [System.Data.SQLite.SQLiteConnection]
        $SQLiteConnection,

        [parameter( Position=2,
                    Mandatory = $true)]
        [string]
        $Table,

        [Parameter( Position=3,
                     Mandatory=$false,
                     ValueFromPipeline=$false,
                     ValueFromPipelineByPropertyName=$false,
                     ValueFromRemainingArguments=$false)]
        [ValidateSet("Rollback","Abort","Fail","Ignore","Replace")]
        [string]
        $ConflictClause,

        [int]
        $NotifyAfter = 0,

        [switch]
        $Force,

        [Int32]
        $QueryTimeout = 600

    )

    Write-Verbose "Running Invoke-SQLiteBulkCopy with ParameterSet '$($PSCmdlet.ParameterSetName)'."

    Function CleanUp
    {
        [cmdletbinding()]
        param($conn, $com, $BoundParams)
        #Only dispose of the connection if we created it
        if($BoundParams.Keys -notcontains 'SQLiteConnection')
        {
            $conn.Close()
            $conn.Dispose()
            Write-Verbose "Closed connection"
        }
        $com.Dispose()
    }

    function Get-ParameterName
    {
        [CmdletBinding()]
        Param(
            [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
            [string[]]$InputObject,

            [Parameter(ValueFromPipelineByPropertyName = $true)]
            [string]$Regex = '(\W+)',

            [Parameter(ValueFromPipelineByPropertyName = $true)]
            [string]$Separator = '_'
        )

        Process{
            $InputObject | ForEach-Object {
                if($_ -match $Regex){
                    $Groups = @($_ -split $Regex | Where-Object {$_})
                    for($i = 0; $i -lt $Groups.Count; $i++){
                        if($Groups[$i] -match $Regex){
                            $Groups[$i] = ($Groups[$i].ToCharArray() | ForEach-Object {[string][int]$_}) -join $Separator
                        }
                    }
                    $Groups -join $Separator
                } else {
                    $_
                }
            }
        }
    }

    function New-SqliteBulkQuery {
        [CmdletBinding()]
        Param(
            [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
            [string]$Table,

            [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
            [string[]]$Columns,

            [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
            [string[]]$Parameters,

            [Parameter(ValueFromPipelineByPropertyName = $true)]
            [string]$ConflictClause = ''
        )

        Begin{
            $EscapeSingleQuote = "'","''"
            $Delimeter = ", "
            $QueryTemplate = "INSERT{0} INTO {1} ({2}) VALUES ({3})"
        }

        Process{
            $fmtConflictClause = if($ConflictClause){" OR $ConflictClause"}
            $fmtTable = "'{0}'" -f ($Table -replace $EscapeSingleQuote)
            $fmtColumns = ($Columns | ForEach-Object { "'{0}'" -f ($_ -replace $EscapeSingleQuote) }) -join $Delimeter
            $fmtParameters = ($Parameters | ForEach-Object { "@$_"}) -join $Delimeter

            $QueryTemplate -f $fmtConflictClause, $fmtTable, $fmtColumns, $fmtParameters
        }
    }

    #Connections
        if($PSBoundParameters.Keys -notcontains "SQLiteConnection")
        {
            if ($DataSource -match ':MEMORY:') 
            {
                $Database = $DataSource
            }
            else 
            {
                $Database = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($DataSource)    
            }

            $ConnectionString = "Data Source={0}" -f $Database
            $SQLiteConnection = New-Object System.Data.SQLite.SQLiteConnection -ArgumentList $ConnectionString
            $SQLiteConnection.ParseViaFramework = $true #Allow UNC paths, thanks to Ray Alex!
        }

        Write-Debug "ConnectionString $($SQLiteConnection.ConnectionString)"
        Try
        {
            if($SQLiteConnection.State -notlike "Open")
            {
                $SQLiteConnection.Open()
            }
            $Command = $SQLiteConnection.CreateCommand()
            $CommandTimeout = $QueryTimeout
            $Transaction = $SQLiteConnection.BeginTransaction()
        }
        Catch
        {
            Throw $_
        }
    
    write-verbose "DATATABLE IS $($DataTable.gettype().fullname) with value $($Datatable | out-string)"
    $RowCount = $Datatable.Rows.Count
    Write-Verbose "Processing datatable with $RowCount rows"

    if ($Force -or $PSCmdlet.ShouldProcess("$($DataTable.Rows.Count) rows, with BoundParameters $($PSBoundParameters | Out-String)", "SQL Bulk Copy"))
    {
        #Get column info...
            [array]$Columns = $DataTable.Columns | Select-Object -ExpandProperty ColumnName
            $ColumnTypeHash = @{}
            $ColumnToParamHash = @{}
            $Index = 0
            foreach($Col in $DataTable.Columns)
            {
                $Type = Switch -regex ($Col.DataType.FullName)
                {
                    # I figure we create a hashtable, can act upon expected data when doing insert
                    # Might be a better way to handle this...
                    '^(|\ASystem\.)Boolean$' {"BOOLEAN"} #I know they're fake...
                    '^(|\ASystem\.)Byte\[\]' {"BLOB"}
                    '^(|\ASystem\.)Byte$'  {"BLOB"}
                    '^(|\ASystem\.)Datetime$'  {"DATETIME"}
                    '^(|\ASystem\.)Decimal$' {"REAL"}
                    '^(|\ASystem\.)Double$' {"REAL"}
                    '^(|\ASystem\.)Guid$' {"TEXT"}
                    '^(|\ASystem\.)Int16$'  {"INTEGER"}
                    '^(|\ASystem\.)Int32$'  {"INTEGER"}
                    '^(|\ASystem\.)Int64$' {"INTEGER"}
                    '^(|\ASystem\.)UInt16$'  {"INTEGER"}
                    '^(|\ASystem\.)UInt32$'  {"INTEGER"}
                    '^(|\ASystem\.)UInt64$' {"INTEGER"}
                    '^(|\ASystem\.)Single$' {"REAL"}
                    '^(|\ASystem\.)String$' {"TEXT"}
                    Default {"BLOB"} #Let SQLite handle the rest...
                }

                #We ref columns by their index, so add that...
                $ColumnTypeHash.Add($Index,$Type)

                # Parameter names can only be alphanumeric: https://www.sqlite.org/c3ref/bind_blob.html
                # So we have to replace all non-alphanumeric chars in column name to use it as parameter later.
                # This builds hashtable to correlate column name with parameter name.
                $ColumnToParamHash.Add($Col.ColumnName, (Get-ParameterName $Col.ColumnName))

                $Index++
            }

        #Build up the query
            if ($PSBoundParameters.ContainsKey('ConflictClause'))
            {
                $Command.CommandText = New-SqliteBulkQuery -Table $Table -Columns $ColumnToParamHash.Keys -Parameters $ColumnToParamHash.Values -ConflictClause $ConflictClause
            }
            else
            {
                $Command.CommandText = New-SqliteBulkQuery -Table $Table -Columns $ColumnToParamHash.Keys -Parameters $ColumnToParamHash.Values
            }

            foreach ($Column in $Columns)
            {
                $param = New-Object System.Data.SQLite.SqLiteParameter $ColumnToParamHash[$Column]
                [void]$Command.Parameters.Add($param)
            }
            
            for ($RowNumber = 0; $RowNumber -lt $RowCount; $RowNumber++)
            {
                $row = $Datatable.Rows[$RowNumber]
                for($col = 0; $col -lt $Columns.count; $col++)
                {
                    # Depending on the type of thid column, quote it
                    # For dates, convert it to a string SQLite will recognize
                    switch ($ColumnTypeHash[$col])
                    {
                        "BOOLEAN" {
                            $Command.Parameters[$ColumnToParamHash[$Columns[$col]]].Value = [int][boolean]$row[$col]
                        }
                        "DATETIME" {
                            Try
                            {
                                $Command.Parameters[$ColumnToParamHash[$Columns[$col]]].Value = $row[$col].ToString("yyyy-MM-dd HH:mm:ss")
                            }
                            Catch
                            {
                                $Command.Parameters[$ColumnToParamHash[$Columns[$col]]].Value = $row[$col]
                            }
                        }
                        Default {
                            $Command.Parameters[$ColumnToParamHash[$Columns[$col]]].Value = $row[$col]
                        }
                    }
                }

                #We have the query, execute!
                    Try
                    {
                        [void]$Command.ExecuteNonQuery()
                    }
                    Catch
                    {
                        #Minimal testing for this rollback...
                            Write-Verbose "Rolling back due to error:`n$_"
                            $Transaction.Rollback()
                        
                        #Clean up and throw an error
                            CleanUp -conn $SQLiteConnection -com $Command -BoundParams $PSBoundParameters
                            Throw "Rolled back due to error:`n$_"
                    }

                if($NotifyAfter -gt 0 -and $($RowNumber % $NotifyAfter) -eq 0)
                {
                    Write-Verbose "Processed $($RowNumber + 1) records"
                }
            }  
    }
    
    #Commit the transaction and clean up the connection
        $Transaction.Commit()
        CleanUp -conn $SQLiteConnection -com $Command -BoundParams $PSBoundParameters
    
}

$ComputerName = gc -Path $FilePath
 
 ## Gathers preliminary info and loops it for each computer ##
    $Objs = @()
    foreach ($Computer in $ComputerName){
         
        ## Invokes gathering Hardware Information ##
        $Obj = Get-HotFix -ComputerName $Computer | Select-Object @{Label='ComputerID';Expression={$_.PSComputerName}}, HotFixID,Description,InstalledBy,InstalledOn | Sort-Object InstalledOn -Descending
        
        $Objs += $Obj
    }
                 
## Uncomment out if you want to make a new table ##
#$Query = "CREATE TABLE UpdatesInstalled (ComputerID TEXT, HotFixID TEXT, Description TEXT, InstalledBy TEXT, InstalledOn TEXT, PRIMARY KEY (ComputerID, HotFixID))"
#Invoke-SqliteQuery -DataSource $DataSource -Query $Query 


## Takes items pulled from object created and outputs them to datatable ##
$dtable = $Objs | Out-DataTable

Invoke-SQLiteBulkCopy -DataTable $dtable -DataSource $DataSource -Table UpdatesInstalled -Confirm:$false
