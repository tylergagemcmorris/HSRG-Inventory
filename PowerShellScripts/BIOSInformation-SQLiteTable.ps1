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
        $obj = Get-WmiObject win32_bios -ComputerName $Computer | Select-Object @{Label='ComputerID';Expression={$_.PSComputerName}}, Manufacturer,Name, BIOSVersion ,PrimaryBIOS,ReleaseDate,SMBIOSBIOSVersion,SMBIOSMajorVersion,SMBIOSMinorVersion 
        
        $Objs += $Obj
    }            

## Uncomment out if you want to make a new table ##
$Query = "CREATE TABLE BIOSInformation (ComputerID TEXT PRIMARY KEY, Manufacturer TEXT, Name TEXT, BIOSVersion TEXT, PrimaryBIOS TEXT, ReleaseDate TEXT ,SMBIOSBIOSVersion TEXT, SMBIOSMajorVersion TEXT, SMBIOSMinorVersion TEXT)"
Invoke-SqliteQuery -DataSource $DataSource -Query $Query 


## Takes items pulled from object created and outputs them to datatable ##
$dtable = $objs | Out-DataTable

Invoke-SQLiteBulkCopy -DataTable $dtable -DataSource $DataSource -Table BIOSInformation
