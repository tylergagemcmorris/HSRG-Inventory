## Download link: https://gallery.technet.microsoft.com/scriptcenter/4208a159-a52e-4b99-83d4-8048468d29dd ##
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
        $Obj = Get-WmiObject win32_diskDrive -ComputerName $Computer  | select @{Label='ComputerID';Expression={$_.PSComputerName}}, Model,SerialNumber,InterfaceType, @{n='Size';e={"{0:N2}" -f[Decimal]($_.Size/1GB)}},Partitions 
        $Objs += $Obj
    }            

## Uncomment out if you want to make a new table ##
$Query = "CREATE TABLE HardDiskInformation (ComputerID TEXT PRIMARY KEY, Model TEXT, SerialNumber TEXT, InterfaceType TEXT, Size TEXT, Partitions TEXT)"
Invoke-SqliteQuery -DataSource $DataSource -Query $Query 


## Takes items pulled from object created and outputs them to datatable ##
$dtable = $objs | Out-DataTable

Invoke-SQLiteBulkCopy -DataTable $dtable -DataSource $DataSource -Table HardDiskInformation
