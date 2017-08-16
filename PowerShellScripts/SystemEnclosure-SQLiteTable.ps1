﻿## Download link: https://gallery.technet.microsoft.com/scriptcenter/4208a159-a52e-4b99-83d4-8048468d29dd ##
Import-Module PSSQLite


## Sets path for Inventory Listing ##
$ComputerName = gc -Path "C:\scripts\InventoryListTextFiles\HSRG-Inventory-Names.txt"
    $url = $null
 
 ## Gathers preliminary info and loops it for each computer ##
    $Objs = @()
    foreach ($Computer in $ComputerName){
         
        ## Invokes gathering Hardware Information ##
            $bios = Get-WmiObject Win32_SystemEnclosure -ComputerName $Computer  | Select Tag,AudibleAlarm,ChassisTypes,HeatGeneration,HotSwappable,InstallDate,LockPresent,PoweredOn,PartNumber,SerialNumber



                    $Obj = New-Object psobject -Property @{
                        'ComputerID' = $Computer
                        'Tag' = $bios.Tag
                        'AudibleAlarm' = $bios.AudibleAlarm
                        'ChassisTypes' = $bios.ChassisTypes | Out-String
                        'HeatGeneration' = $bios.HeatGeneration
                        'HotSwappable' = $bios.HotSwappable
                        'InstallDate' = $bios.InstallDate
                        'LockPresent' = $bios.LockPresent
                        'PoweredOn' = $bios.PoweredOn
                        'PartNumber' = $bios.PartNumber
                        'SerialNumber' = $bios.SerialNumber

                          }
                        $Objs += $Obj
                    }            

## Selects Object 
$objs | Select-Object ComputerID, Tag,AudibleAlarm,ChassisTypes,HeatGeneration,HotSwappable,InstallDate,LockPresent,PoweredOn,PartNumber,SerialNumber


## Creates Get-Type Function ##
function Get-Type 
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
 
## Details out function ## 
<# 
.SYNOPSIS 
Creates a DataTable for an object 
.DESCRIPTION 
Creates a DataTable based on an objects properties. 
.INPUTS 
Object 
    Any object can be piped to Out-DataTable 
.OUTPUTS 
   System.Data.DataTable 
.EXAMPLE 
$dt = Get-psdrive| Out-DataTable 
This example creates a DataTable from the properties of Get-psdrive and assigns output to $dt variable 
.NOTES 
Adapted from script by Marc van Orsouw see link 
Version History 
v1.0  - Chad Miller - Initial Release 
v1.1  - Chad Miller - Fixed Issue with Properties 
v1.2  - Chad Miller - Added setting column datatype by property as suggested by emp0 
v1.3  - Chad Miller - Corrected issue with setting datatype on empty properties 
v1.4  - Chad Miller - Corrected issue with DBNull 
v1.5  - Chad Miller - Updated example 
v1.6  - Chad Miller - Added column datatype logic with default to string 
v1.7 - Chad Miller - Fixed issue with IsArray 
.LINK 
http://thepowershellguy.com/blogs/posh/archive/2007/01/21/powershell-gui-scripblock-monitor-script.aspx 
#> 

## Creates Out-DataTable Function ##
function Out-DataTable 
{ 
    [CmdletBinding()] 
    param([Parameter(Position=0, Mandatory=$true, ValueFromPipeline = $true)] [PSObject[]]$InputObject) 
 
    Begin 
    { 
        $dt = new-object Data.datatable   
        $First = $true  
    } 
    Process 
    { 
        foreach ($object in $InputObject) 
        { 
            $DR = $DT.NewRow()   
            foreach($property in $object.PsObject.get_properties()) 
            {   
                if ($first) 
                {   
                    $Col =  new-object Data.DataColumn   
                    $Col.ColumnName = $property.Name.ToString()   
                    if ($property.value) 
                    { 
                        if ($property.value -isnot [System.DBNull]) { 
                            $Col.DataType = [System.Type]::GetType("$(Get-Type $property.TypeNameOfValue)") 
                         } 
                    } 
                    $DT.Columns.Add($Col) 
                }   
                if ($property.Gettype().IsArray) { 
                    $DR.Item($property.Name) =$property.value | ConvertTo-XML -AS String -NoTypeInformation -Depth 1 
                }   
               else { 
                    $DR.Item($property.Name) = $property.value 
                } 
            }   
            $DT.Rows.Add($DR)   
            $First = $false 
        } 
    }  
      
    End 
    { 
        Write-Output @(,($dt)) 
    } 
 
} 


## Opens Database ##
$DataSource = "C:\scripts\Databases\InventoryDetails.SQLite"

## Uncomment out if you want to make a new table ##
#$Query = "CREATE TABLE SystemEnclosure (ComputerID TEXT PRIMARY KEY, Tag TEXT, AudibleAlarm TEXT, ChassisTypes TEXT, HeatGeneration TEXT, HotSwappable TEXT, InstallDate TEXT, LockPresent TEXT, PoweredOn TEXT, PartNumber TEXT, SerialNumber TEXT)"
#Invoke-SqliteQuery -DataSource $DataSource -Query $Query 


## Takes items pulled from object created and outputs them to datatable ##
$logdsk = $Objs | select 
$dtable = $logdsk | Out-DataTable

Invoke-SQLiteBulkCopy -DataTable $dtable -DataSource $DataSource -Table SystemEnclosure
