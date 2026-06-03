# Sökväg till filen som innehåller datornamn/IP-adresser
$ComputerList = ".\computers.txt"

# Sökväg till loggfilen
$LogFile = ".\Logs\GreenIT.log"

# Kontrollera om mappen Logs finns
if (!(Test-Path ".\Logs"))
{
    # Om den inte finns skapas den
    New-Item -ItemType Directory -Path ".\Logs"
}

# Funktion för att skriva meddelanden till loggfilen
function Write-Log
{
    # Funktionen tar emot en textsträng
    param([string]$Message)

    # Hämtar aktuellt datum och tid i ett läsbart format
    $Time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Skriver tidstämpel + meddelande till loggfilen
    Add-Content -Path $LogFile -Value "$Time - $Message"
}

# Skriver att programmet startat
Write-Log "========== START =========="

# Läser in alla datorer från computers.txt
$Computers = Get-Content $ComputerList

# Tom lista där resultat från inventeringen sparas
$Results = @()

# Loopa igenom varje dator i listan
foreach ($Computer in $Computers)
{
    # Visar aktuell dator i terminalen
    Write-Host "Kontrollerar $Computer..."

    # Skickar ett ping-test för att se om datorn svarar
    if (Test-Connection $Computer -Count 1 -Quiet)
    {
        try
        {
            # Hämtar operativsystemsinformation via CIM/WMI
            $OS = Get-CimInstance Win32_OperatingSystem -ComputerName $Computer

            # Hämtar generell datorinformation via CIM/WMI
            $ComputerInfo = Get-CimInstance Win32_ComputerSystem -ComputerName $Computer

            # Skapar ett objekt med information om datorn
            $Object = [PSCustomObject]@{
                Computer = $Computer                 # Datornamn
                Status = "Online"                    # Status
                User = $ComputerInfo.UserName        # Inloggad användare
                OS = $OS.Caption                     # Operativsystem
                LastBoot = $OS.LastBootUpTime        # Senaste uppstart
            }

            # Lägger till objektet i resultatlistan
            $Results += $Object

            # Loggar att datorn är online
            Write-Log "$Computer är online"
        }
        catch
        {
            # Om CIM-anropet misslyckas loggas felet
            Write-Log "$Computer CIM-fel"
        }
    }
    else
    {
        # Om datorn inte svarar på ping skapas ett objekt
        # som markerar datorn som offline
        $Results += [PSCustomObject]@{
            Computer = $Computer
            Status = "Offline"
            User = ""
            OS = ""
            LastBoot = ""
        }

        # Logga att datorn är offline
        Write-Log "$Computer är offline"
    }
}

# Exporterar inventeringsresultatet till CSV-fil
$Results | Export-Csv -Path ".\InventoryReport.csv" -NoTypeInformation

# Loggar att rapporten skapats
Write-Log "Rapport skapad"


Write-Host ""

# Visar meddelande till användaren
Write-Host "Klar!"

Write-Host ""

# Visar resultatet i tabellform i terminalen
$Results | Format-Table

# Loggar att programmet avslutats
Write-Log "========== END =========="


foreach ($Result in $Results)
{
    if ($Result.Status -eq "Online")
    {
        Stop-Computer `
            -ComputerName $Result.Computer `
            -Force
    }
}