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
#Avstägning av Datorer som är online använd TEST efter Switch för att testa och LIVE när du vill stänga av.
param(
    [switch]$TEST
)
#Använder listan för att kolla datorer.
foreach ($Computer in $Computers)
{
    Write-Host "Kontrollerar $Computer..." -ForegroundColor Yellow
#Skickar en ping till datorerna för att kolla om dom är på.
    if (Test-Connection -ComputerName $Computer -Count 1 -Quiet)
    {
        Write-Log "$Computer är online"
        #Kollar om vi kör i live läge för att stänga av.
        if ($Live)
        {
            Write-Host "LIVE: stänger av $Computer..." -ForegroundColor Red
            Shutdown-ComputerSafe -ComputerName $Computer
        }
        else
        #Kollar om vi kör i TEST läge för att skicka meddelande.
        {
            Write-Host "TEST: $Computer skulle stängas av" -ForegroundColor Cyan
            Write-Log "$Computer skulle stängas av (TEST-läge)"
        }
    }
    else
    #Visar om datorn är offline, skriver till loggen.
    {
        Write-Host "$Computer är offline" -ForegroundColor DarkGray
        Write-Log "$Computer är offline"
    }
}

function Shutdown-ComputerSafe
{
    param([string]$ComputerName)

    try
    #Avstägnings kommandot.
    {
        Stop-Computer -ComputerName $ComputerName -Force -ErrorAction Stop
        Write-Host "$ComputerName stängdes av" -ForegroundColor Green
        Write-Log "$ComputerName stängdes av"
    }
    catch
    #Visar Resultatet Nedstägning.
    {
        Write-Host "$ComputerName kunde inte stängas av: $($_.Exception.Message)" -ForegroundColor Red
        Write-Log "$ComputerName kunde inte stängas av: $($_.Exception.Message)"
    }
}