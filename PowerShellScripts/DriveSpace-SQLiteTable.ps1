﻿## Download link: https://gallery.technet.microsoft.com/scriptcenter/4208a159-a52e-4b99-83d4-8048468d29dd ##
Import-Module PSSQLite

## Sets path for Database ##
$OpenFileDialog1 = New-Object -TypeName System.Windows.Forms.OpenFileDialog
$OpenFileDialog1.Title ="Select the database file for the script."
$OpenFileDialog1.ShowDialog()
$DataSource = $OpenFileDialog1.FileName

## Sets path for Inventory Listing ##
$OpenFileDialog2 = New-Object -TypeName System.Windows.Forms.OpenFileDialog
$OpenFileDialog2.Title ="Select the Inventory file for the script."
$OpenFileDialog2.ShowDialog()
$ComputerName = gc -Path $OpenFileDialog2.FileName
$url = $null
 
 ## Gathers preliminary info and loops it for each computer ##
    $Objs = @()
    foreach ($Computer in $ComputerName){ 
        ## Invokes gathering Hardware Information ##
        $bios = Get-WmiObject win32_logicaldisk -Computer $Computer | select @{Label='ComputerID';Expression={$_.PSComputerName}}, @{Label='Drive Letter';Expression={$_.DeviceID}}, @{Label='Label';Expression={$_.VolumeName}}, @{LABEL='Free Space - GB';EXPRESSION={"{0:N2}" -f($_.freespace/1GB)} },@{LABEL='Total Space - GB';EXPRESSION={"{0:N2}" -f($_.Size/1GB)} }
        $Objs += $bios
        }            

## Selects Object 
##$objs | Select-Object ComputerID, 'Drive Letter', Label, 'Free Space - GB', 'Total Space - GB'

## Uncomment out if you want to make a new table ##
##$Query = "CREATE TABLE DriveSpace (ComputerID TEXT, 'Drive Letter' TEXT, Label TEXT, 'Free Space - GB' TEXT, 'Total Space - GB' TEXT, PRIMARY KEY (ComputerID, 'Drive Letter'))"
##Invoke-SqliteQuery -DataSource $DataSource -Query $Query 


## Takes items pulled from object created and outputs them to datatable ##
$logdsk = $Objs | select ComputerID, 'Drive Letter', Label, 'Free Space - GB', 'Total Space - GB'
$dtable = $logdsk | Out-DataTable

Invoke-SQLiteBulkCopy -DataTable $dtable -DataSource $DataSource -Table DriveSpace
