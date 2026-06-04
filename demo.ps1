#Om skriptet startas med -LIVE kommer online-datorer
#att stängas av. Utan -LIVE körs endast ett testläge.
param(
    [switch]$LIVE
)
#Fil sökvägar
$ComputerList = ".\computers.txt"
$LogFolder = ".\Logs"
$LogFile = "$LogFolder\GreenIT.log"

#Hämtar datorns namn för att förhindra att localhost datorn stängs ner.
$LocalComputer = $env:COMPUTERNAME

#Skapar loggmappen om den inte redan finns.
if (!(Test-Path $LogFolder))
{
    New-Item -ItemType Directory -Path $LogFolder | Out-Null
}

#Fyller på loggfilen med information som datum och text.
function Write-Log
{
    param([string]$Message)

    $Time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "$Time - $Message"
}

#Shutdown commando försöker stänga av datorn om det inte går skickas meddelande till log och host om att det inte gick.
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

#Skapar mall för loggfilen och vilken infromation som ska finnas.
Write-Log "========== START =========="

#Hämtar information från AD
Import-Module ActiveDirectory -ErrorAction Stop

#Hämtar alla datorobjekt och tar bort den lokala datorn samt soterar listan i alfabetiskt ordning. 
$ADComputers = Get-ADComputer -Filter * |
    Select-Object -ExpandProperty Name |
    Where-Object { $_ -ne $LocalComputer } |
    Sort-Object
#Skapar en tempoär lista för datornamn och ip
$TempList = @()
#Går igenom varje dator som hämtats från AD.
#Försöker hitta IP genom DNS
#Spara ip och datornamn men hittar den inte ip spara den endast datornamn
foreach ($PC in $ADComputers)
{
    try
    {
        $IP = (Resolve-DnsName $PC -Type A -ErrorAction Stop |
            Select-Object -First 1 -ExpandProperty IPAddress)

        $TempList += "$PC,$IP"
    }
    catch
    {
        $TempList += "$PC,"
    }
}

$TempList | Set-Content $ComputerList

$Computers = Get-Content $ComputerList

#Inventerar datorerna i nätverket
$Results = @()
#Går igenom varje dator i inventeringslistan
foreach ($Line in $Computers)
{
    $Parts = $Line -split ","  #Delar upp raden i datornamn och IP-adress

    $Computer = $Parts[0] #Hämtar datornamnet

    if ($Parts.Count -gt 1) #Hämtar IP-adressen om den finns
    {
        $IP = $Parts[1]
    }
    else
    {
        $IP = ""  #Lämnar IP-adressen tom om den saknas
    }
   
    # Visar vilken dator som kontrolleras
    Write-Host "Kontrollerar $Computer..." -ForegroundColor Yellow

    # Kontrollerar om datorn är online
    if (Test-Connection $Computer -Count 1 -Quiet -ErrorAction SilentlyContinue)
    {
        try
        {
            $OS = Get-CimInstance Win32_OperatingSystem -ComputerName $Computer #Hämtar information om operativsystemet
            $ComputerInfo = Get-CimInstance Win32_ComputerSystem -ComputerName $Computer #Hämtar information om datorn och inloggad användare

            #Sparar informationen i inveteringsrapporten
            $Results += [PSCustomObject]@{
                Computer = $Computer
                IP       = $IP
                Status   = "Online"
                User     = $ComputerInfo.UserName
                OS       = $OS.Caption
                LastBoot = $OS.LastBootUpTime
            }

            # Skriver till loggen att datorn är online
            Write-Log "$Computer är online"

             # Om LIVE-läge används stängs datorn av
            if ($LIVE)
            {
                if ($Computer -eq $LocalComputer) # Säkerhetskontroll så att den lokala datorn inte stängs av
                {
                    Write-Host "SKIP: $Computer (this machine)" -ForegroundColor Yellow
                    continue
                }

                Write-Host "LIVE: stänger av $Computer..." -ForegroundColor Red #Visar att datorn stängs av
                ShutdownComputerSafe -ComputerName $Computer   #Anropar funktionen som stänger av datorn
            }
            else
            {
                #Testläge - visar bara vad som skulle ha hänt
                Write-Host "TEST: $Computer skulle stängas av" -ForegroundColor Cyan
                Write-Log "$Computer skulle stängas av (TEST-läge)"
            }
        }
        catch
        {
             # Loggar eventuella fel vid hämtning av datorinformation
            Write-Log "$Computer CIM-fel: $($_.Exception.Message)"
        }
    }
    else
    {
         # Sparar information om datorn om den är offline
        $Results += [PSCustomObject]@{
            Computer = $Computer
            IP       = $IP
            Status   = "Offline"
            User     = ""
            OS       = ""
            LastBoot = ""
        }

        Write-Host "$Computer är offline" -ForegroundColor DarkGray # Visar att datorn är offline
        Write-Log "$Computer är offline" # Skriver till loggen att datorn är offline
    }
}

# Exporterar inventeringsrapporten till en CSV-fil
$Results | Export-Csv ".\InventoryReport.csv" -NoTypeInformation -Encoding UTF8

# Visar att skriptet är klart
Write-Host "Klar!" -ForegroundColor Green
$Results | Format-Table -AutoSize

# Skriver slutmarkering i loggfilen
Write-Log "========== SLUT =========="
