$LogFile = "C:\Script\CreateTask.log"

function Write-Log
{
    param([string]$Message)

    $Time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    Add-Content `
        -Path $LogFile `
        -Value "$Time - $Message"
}

Write-Log "========== START =========="

try
{
    # Startar PowerShell och kör GreenIT-scriptet
    $Action = New-ScheduledTaskAction `
        -Execute "powershell.exe" `
        -Argument "-ExecutionPolicy Bypass -File C:\VS\GreenIT.ps1"

    Write-Log "ScheduledTaskAction skapad"

    # Triggern gör att uppgiften körs varje dag klockan 20:00
    $Trigger = New-ScheduledTaskTrigger `
        -Daily `
        -At 20:00

    Write-Log "Trigger skapad för 20:00"

    # Registrerar den schemalagda uppgiften i Windows Aktivitetsschemaläggaren
    Register-ScheduledTask `
        -TaskName "GreenIT" `
        -Action $Action `
        -Trigger $Trigger `
        -Description "Automatisk energibesparing"

    Write-Log "Schemalagd uppgift registrerad"

    Write-Host "Schemalagd uppgift skapad."
}
catch
{
    Write-Log "FEL: $_"
}

Write-Log "========== END =========="