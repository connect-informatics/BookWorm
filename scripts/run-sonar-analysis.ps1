#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Esegue analisi SonarQube locale usando User Secrets per il token.

.DESCRIPTION
    Questo script legge il token SonarQube da .NET User Secrets ed esegue
    l'analisi completa (begin -> build -> end).

.PARAMETER ProjectKey
    Chiave del progetto SonarQube (default: foxminchan_BookWorm)

.PARAMETER Organization
    Organizzazione SonarQube (default: foxminchan)

.PARAMETER BuildConfiguration
    Configurazione build (default: Release)

.EXAMPLE
    .\run-sonar-analysis.ps1
    .\run-sonar-analysis.ps1 -ProjectKey "my-project" -Organization "my-org"
#>

param(
    [string]$ProjectKey = "foxminchan_BookWorm",
    [string]$Organization = "foxminchan",
    [string]$BuildConfiguration = "Release"
)

$ErrorActionPreference = "Stop"

# Colors
function Write-Info { Write-Host "ℹ️  $args" -ForegroundColor Cyan }
function Write-Success { Write-Host "✅ $args" -ForegroundColor Green }
function Write-Error { Write-Host "❌ $args" -ForegroundColor Red }
function Write-Warning { Write-Host "⚠️  $args" -ForegroundColor Yellow }

Write-Info "SonarQube Local Analysis Script"
Write-Host ""

# Verifica che dotnet-sonarscanner sia installato
Write-Info "Verifying dotnet-sonarscanner installation..."
$scannerInstalled = dotnet tool list --global | Select-String "dotnet-sonarscanner"
if (-not $scannerInstalled) {
    Write-Error "dotnet-sonarscanner not installed. Run: dotnet tool install --global dotnet-sonarscanner"
    exit 1
}
Write-Success "dotnet-sonarscanner found"

# Leggi token da User Secrets
Write-Info "Reading SonarQube token from User Secrets..."
$appHostProject = "src/Aspire/BookWorm.AppHost/BookWorm.AppHost.csproj"

try {
    $secretsJson = dotnet user-secrets list --project $appHostProject --json | ConvertFrom-Json
    $sonarToken = $secretsJson.'Sonar:Token'
    
    if ([string]::IsNullOrWhiteSpace($sonarToken)) {
        Write-Error "Sonar:Token not found in User Secrets!"
        Write-Warning "Run: dotnet user-secrets set 'Sonar:Token' 'YOUR_TOKEN_HERE' --project $appHostProject"
        exit 1
    }
    
    Write-Success "Token loaded from User Secrets"
} catch {
    Write-Error "Failed to read User Secrets: $_"
    exit 1
}

# Step 1: Begin Analysis
Write-Info "Starting SonarQube analysis..."
Write-Host ""

dotnet-sonarscanner begin `
    /k:"$ProjectKey" `
    /o:"$Organization" `
    /d:sonar.token="$sonarToken" `
    /d:sonar.host.url="https://sonarcloud.io" `
    /s:"$PSScriptRoot/../SonarQube.Analysis.xml"

if ($LASTEXITCODE -ne 0) {
    Write-Error "SonarScanner begin failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}

Write-Success "SonarScanner begin completed"
Write-Host ""

# Step 2: Build
Write-Info "Building solution..."
dotnet build --configuration $BuildConfiguration --no-incremental

if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}

Write-Success "Build completed"
Write-Host ""

# Step 3: End Analysis
Write-Info "Finalizing SonarQube analysis..."
dotnet-sonarscanner end /d:sonar.token="$sonarToken"

if ($LASTEXITCODE -ne 0) {
    Write-Error "SonarScanner end failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}

Write-Success "SonarQube analysis completed successfully!"
Write-Host ""
Write-Info "View results at: https://sonarcloud.io/project/overview?id=$ProjectKey"
