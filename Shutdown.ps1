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