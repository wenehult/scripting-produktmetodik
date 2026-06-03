param(
    [switch]$LIVE
)

$ComputerList = ".\computers.txt"
$LogFolder = ".\Logs"
$LogFile = "$LogFolder\GreenIT.log"

$LocalComputer = $env:COMPUTERNAME

if (!(Test-Path $LogFolder))
{
    New-Item -ItemType Directory -Path $LogFolder | Out-Null
}

function Write-Log
{
    param([string]$Message)

    $Time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "$Time - $Message"
}

function ShutdownComputerSafe
{
    param([string]$ComputerName)

    try
    {
        Stop-Computer -ComputerName $ComputerName -Force -ErrorAction Stop
        Write-Host "$ComputerName stängdes av" -ForegroundColor Green
        Write-Log "$ComputerName stängdes av"
    }
    catch
    {
        Write-Host "$ComputerName kunde inte stängas av: $($_.Exception.Message)" -ForegroundColor Red
        Write-Log "$ComputerName kunde inte stängas av: $($_.Exception.Message)"
    }
}

Write-Log "========== START =========="

Import-Module ActiveDirectory -ErrorAction Stop

$ADComputers = Get-ADComputer -Filter * |
    Select-Object -ExpandProperty Name |
    Where-Object { $_ -ne $LocalComputer } |
    Sort-Object

$ADComputers | Set-Content $ComputerList
$Computers = Get-Content $ComputerList

$Results = @()

foreach ($Computer in $Computers)
{
    Write-Host "Kontrollerar $Computer..." -ForegroundColor Yellow

    if (Test-Connection $Computer -Count 1 -Quiet -ErrorAction SilentlyContinue)
    {
        try
        {
            $OS = Get-CimInstance Win32_OperatingSystem -ComputerName $Computer
            $ComputerInfo = Get-CimInstance Win32_ComputerSystem -ComputerName $Computer

            $Results += [PSCustomObject]@{
                Computer = $Computer
                Status   = "Online"
                User     = $ComputerInfo.UserName
                OS       = $OS.Caption
                LastBoot = $OS.LastBootUpTime
            }

            Write-Log "$Computer är online"

            if ($LIVE)
            {
                if ($Computer -eq $LocalComputer)
                {
                    Write-Host "SKIP: $Computer (this machine)" -ForegroundColor Yellow
                    continue
                }

                Write-Host "LIVE: stänger av $Computer..." -ForegroundColor Red
                ShutdownComputerSafe -ComputerName $Computer
            }
            else
            {
                Write-Host "TEST: $Computer skulle stängas av" -ForegroundColor Cyan
                Write-Log "$Computer skulle stängas av (TEST-läge)"
            }
        }
        catch
        {
            Write-Log "$Computer CIM-fel: $($_.Exception.Message)"
        }
    }
    else
    {
        $Results += [PSCustomObject]@{
            Computer = $Computer
            Status   = "Offline"
            User     = ""
            OS       = ""
            LastBoot = ""
        }

        Write-Host "$Computer är offline" -ForegroundColor DarkGray
        Write-Log "$Computer är offline"
    }
}

$Results | Export-Csv ".\InventoryReport.csv" -NoTypeInformation -Encoding UTF8

Write-Host "Klar!" -ForegroundColor Green
$Results | Format-Table -AutoSize

Write-Log "========== END =========="