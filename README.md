# GreenNet Power Manager

## Product Vision

GreenNet Power Manager är ett PowerShell-baserat verktyg för Grön IT. Syftet är att minska onödig energiförbrukning genom att identifiera datorer som är påslagna men inaktiva, logga informationen och vid behov schemalägga viloläge eller avstängning.

Produkten riktar sig till IT-administratörer, skolor, mindre företag och organisationer som vill automatisera enklare driftuppgifter och samtidigt arbeta mer hållbart.

---

## Problem

Många datorer lämnas påslagna efter arbetstid trots att de inte används. Detta leder till:

- Onödig energiförbrukning
- Högre elkostnader
- Större miljöpåverkan
- Mer manuellt arbete för IT-personal

Det kan vara tidskrävande för en administratör att manuellt kontrollera vilka datorer som är aktiva, inaktiva eller redo att stängas av.

---

## Lösning

GreenNet Power Manager använder PowerShell och WMI/CIM för att samla in information från datorer i ett nätverk. Verktyget kan kontrollera exempelvis datornamn, uptime, operativsystem och inloggad användare.

Baserat på den informationen kan verktyget markera datorer som verkar inaktiva och därefter antingen logga resultatet eller utföra en energisparande åtgärd, till exempel viloläge eller avstängning.

---

## Målgrupp

Produkten är tänkt för:

- IT-administratörer
- Skolor
- Mindre företag
- Organisationer som vill minska sin energiförbrukning
- Team som vill automatisera enklare nätverks- och driftuppgifter

---

## Viktigaste funktioner

- Inventera en eller flera datorer via WMI/CIM
- Visa datornamn, uptime, operativsystem och inloggad användare
- Identifiera datorer som verkar inaktiva
- Logga inventering och åtgärder till CSV-fil
- Stöd för säkert testläge, till exempel `-DryRun`
- Möjlighet att stänga av eller försätta datorn i viloläge
- Enkel demo som visar att lösningen fungerar

---

## Värde för användaren

GreenNet Power Manager gör det enklare att minska onödig energiförbrukning utan att IT-personal behöver kontrollera varje dator manuellt.

Genom loggning och testläge kan åtgärder granskas innan de genomförs. Det gör lösningen säkrare, mer transparent och enklare att använda i en verklig IT-miljö.

---

## Framgångskriterier

Projektet räknas som lyckat om verktyget:

- Kan köras som ett PowerShell-script eller en PowerShell-modul
- Kan hämta systeminformation via WMI/CIM
- Kan avgöra om en dator är kandidat för avstängning eller viloläge
- Kan logga resultat och åtgärder
- Kan demonstrera avstängning, viloläge eller `DryRun` på ett säkert sätt
- Är dokumenterat i denna README
- Har följts upp med sprint review och sprint retrospective

---

## Avgränsningar

I första versionen fokuserar vi på en fungerande prototyp. Produkten behöver inte vara färdig för en stor företagsmiljö.

Vi prioriterar att kunna visa en tydlig demo där inventering, loggning och energisparfunktion fungerar.

---

## Exempel på användning

Importera modulen:

```powershell
Import-Module .\GreenNetPowerManager.psm1
```

Hämta information om den lokala datorn:

```powershell
Get-GreenComputerInfo
```

Testa om datorn verkar vara inaktiv:

```powershell
Test-GreenIdleCandidate -MinUptimeHours 8
```

Kör i säkert testläge utan att stänga av datorn:

```powershell
Invoke-GreenPowerAction -Action Hibernate -DryRun
```

Visa loggfilen:

```powershell
Import-Csv .\logs\greenit-log.csv
```

---

## Föreslagen filstruktur

```text
GreenNetPowerManager/
│
├── GreenNetPowerManager.psm1
├── demo.ps1
├── README.md
├── sprint-reviews.md
├── sprint-retrospectives.md
└── logs/
    └── greenit-log.csv
```

---

## Scrum och arbetsmetod

Projektet genomförs med korta 1-dags-sprintar enligt en anpassad Scrum-modell. Varje sprint innehåller planering, genomförande, review och retrospective.

Arbetet hanteras i GitHub Projects där varje uppgift ska kopplas till en user story eller issue. Kort flyttas mellan `To Do`, `In Progress` och `Done` under arbetets gång.

---

## Kort sammanfattning

GreenNet Power Manager är en PowerShell-baserad lösning för Grön IT som hjälper IT-administratörer att hitta inaktiva datorer och minska energislöseri genom automatiserad inventering, loggning och säker avstängning eller viloläge.
