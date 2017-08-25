param(
    [Parameter(Mandatory=$True,Position=1)]
    [int] $SampleInterval,

    [Parameter(Mandatory=$True)]
    [Int] $MaxSamples,

    [Parameter(Mandatory=$True)]
    [String] $DataSource
)

Import-Module PSSQLITE
        
$CPU = (Get-Counter -Counter "\Processor(_Total)\% Processor Time" -SampleInterval $SampleInterval -MaxSamples $MaxSamples)

$CpuTable = @()
foreach ($item in $CPU){

    $CpuTableRow = New-Object psobject -Property @{
        Time = $item.Timestamp.DateTime
        CPUUsage = $item.CounterSamples.CookedValue
    }
    $CpuTable += $CpuTableRow
}


$CpuTable | ConvertTo-Json