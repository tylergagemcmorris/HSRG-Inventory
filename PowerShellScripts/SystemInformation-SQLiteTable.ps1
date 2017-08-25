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
        $Obj = Get-WmiObject Win32_ComputerSystemProduct -ComputerName $Computer  | Select @{Label='ComputerID';Expression={$_.PSComputerName}}, Vendor,Version,Name,IdentifyingNumber,UUID
 	      
        $Objs += $Obj
    }            

## Uncomment out if you want to make a new table ##
$Query = "CREATE TABLE SystemInformation (ComputerID TEXT PRIMARY KEY, Vendor TEXT, Version TEXT, Name TEXT, IdentifyingNumber TEXT, UUID TEXT)"
Invoke-SqliteQuery -DataSource $DataSource -Query $Query 


## Takes items pulled from object created and outputs them to datatable ##
$dtable = $Objs | Out-DataTable

Invoke-SQLiteBulkCopy -DataTable $dtable -DataSource $DataSource -Table SystemInformation
