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
            $Bios = gwmi win32_bios -Computername $Computer
            $Hardware = gwmi Win32_computerSystem -Computername $Computer
            $Sysbuild = gwmi Win32_WmiSetting -Computername $Computer
            $OS = gwmi Win32_OperatingSystem -Computername $Computer
            $Networks = gwmi Win32_NetworkAdapterConfiguration -ComputerName $Computer | ? {$_.IPEnabled}
            $drivespace = Get-WmiObject win32_logicaldisk -Computer $Computer | select @{Label='Drive';Expression={$_.DeviceID}}, @{LABEL='Free';EXPRESSION={"{0:N2}" -f($_.freespace/1GB)} },@{LABEL='Total';EXPRESSION={"{0:N2}" -f($_.Size/1GB)} } | Out-String 
            $cpu = gwmi Win32_Processor  -computername $computer
            $username = gci "\\$computer\c$\Users" | Sort-Object LastWriteTime -Descending | Select Name, LastWriteTime -first 1
            $totalMemory = [math]::round($Hardware.TotalPhysicalMemory/1024/1024/1024, 2)
            $lastBoot = $OS.ConvertToDateTime($OS.LastBootUpTime) 
 	       
            ## Invokes actual Hardware Information in Table ##   
                foreach ($Network in $Networks) {
                        $IPAddress  = $Network.IpAddress[0]
                        $MACAddress  = $Network.MACAddress
                        $systemBios = $Bios.serialnumber
                    $Obj = New-Object psobject -Property @{
                        'ComputerID' = $Computer
                        'Type' = if ($os.ProductType -eq 1){"Client"} elseif($os.ProductType -eq 3){"Server"} else {$null} 
                        'Model' = $Hardware.Model
                        'CPU Info' = $cpu.Name
                        'OS' = $OS.Caption
                        'Serial Number' = $systemBios
                        'IP Address' = $IPAddress
                        'MAC Address' = $MACAddress
                        'Drive Space - GB' = $driveSpace
                        'Total Physical Memory' = $totalMemory 
                        'Last Reboot' = $lastboot}}
                        $Objs += $Obj
                    }
                 
## Uncomment out if you want to make a new table ##
$Query = "CREATE TABLE InventoryDetail (ComputerID TEXT PRIMARY KEY, Type TEXT, Model TEXT, 'CPU Info' TEXT, OS TEXT, 'Serial Number' TEXT, 'IP Address' TEXT, 'MAC Address' TEXT, 'Drive Space - GB' TEXT, 'Total Physical Memory' TEXT, 'Last Reboot' TEXT)"
Invoke-SqliteQuery -DataSource $DataSource -Query $Query 


## Takes items pulled from object created and outputs them to datatable ##
$dtable = $Objs | Out-DataTable

Invoke-SQLiteBulkCopy -DataTable $dtable -DataSource $DataSource -Table InventoryDetail 
