## Download link: https://gallery.technet.microsoft.com/scriptcenter/4208a159-a52e-4b99-83d4-8048468d29dd ##
Import-Module PSSQLite


## Sets path for Inventory Listing ##
$ComputerName = gc -Path "C:\scripts\InventoryListTextFiles\HSRG-Inventory-Names.txt"
    $url = $null
 
 ## Gathers preliminary info and loops it for each computer ##
    $Objs = @()
    foreach ($Computer in $ComputerName){
         
        ## Invokes gathering Hardware Information ##
            $bios = Get-WmiObject win32_networkadapter -ComputerName $Computer  | Select Name,Manufacturer,Description,AdapterType,Speed,MACAddress,NetConnectionID | Where-Object {$_.NetConnectionID -ne $null}

                    $Obj = New-Object psobject -Property @{
                        'ComputerID' = $Computer
                        'Name' = $bios.Name | Out-String
                        'Manufacturer' = $bios.Manufacturer | Out-String
                        'Description' = $bios.Description | Out-String
                        'AdapterType' = $bios.AdapterType | Out-String
                        'Speed' = $bios.Speed | Out-String
                        'MACAddress' = $bios.MACAddress | Out-String
                        'NetConnectionID' = $bios.NetConnectionID | Out-String
                          }
                        $Objs += $Obj
                    }            

## Selects Object 
$objs | Select-Object ComputerID, Name,Manufacturer,Description,AdapterType,Speed,MACAddress,NetConnectionID 


## Opens Database ##
$DataSource = "C:\scripts\Databases\InventoryDetails.SQLite"

## Uncomment out if you want to make a new table ##
#$Query = "CREATE TABLE NetworkAdapters (ComputerID TEXT PRIMARY KEY, Name TEXT, Manufacturer TEXT, Description TEXT, AdapterType TEXT, Speed INTEGER, MACAddress TEXT, NetConnectionID TEXT)"
#Invoke-SqliteQuery -DataSource $DataSource -Query $Query 


## Takes items pulled from object created and outputs them to datatable ##
$logdsk = $Objs | select ComputerID, Name,Manufacturer,Description,AdapterType,Speed,MACAddress,NetConnectionID
$dtable = $logdsk | Out-DataTable

Invoke-SQLiteBulkCopy -DataTable $dtable -DataSource $DataSource -Table NetworkAdapters
