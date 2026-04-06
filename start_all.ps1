$ErrorActionPreference = "Stop"

$scriptDir = $PSScriptRoot
$backendDir = Join-Path $scriptDir "backend"
$logDir = Join-Path $scriptDir "logs"

if (-not (Test-Path -Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

Write-Host "============================="
Write-Host " ORCHESTRIX - STARTING UP"
Write-Host "============================="

if (-not (Test-Path -Path (Join-Path $backendDir ".env"))) {
    Copy-Item -Path (Join-Path $backendDir ".env.example") -Destination (Join-Path $backendDir ".env")
    Write-Host "Created .env from template."
}

if (-not (Test-Path -Path (Join-Path $backendDir "venv"))) {
    Write-Host "Creating virtual environment..."
    python -m venv (Join-Path $backendDir "venv")
}

$envPath = Join-Path $backendDir "venv\Scripts\activate.ps1"
if (Test-Path -Path $envPath) {
    & $envPath
} else {
    Write-Warning "venv/Scripts/activate.ps1 not found."
}

Write-Host "Installing Python dependencies..."
Set-Location $backendDir
python -m pip install -r requirements.txt -q

Write-Host "Starting agents..."

$env:PYTHONPATH = $backendDir

# Start agents using Start-Process
Start-Process -FilePath "python" -ArgumentList "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8001" -WorkingDirectory (Join-Path $backendDir "agents\discovery")
Start-Process -FilePath "python" -ArgumentList "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8002" -WorkingDirectory (Join-Path $backendDir "agents\analysis")
Start-Process -FilePath "python" -ArgumentList "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8003" -WorkingDirectory (Join-Path $backendDir "agents\summary")
Start-Process -FilePath "python" -ArgumentList "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8004" -WorkingDirectory (Join-Path $backendDir "agents\citation")

$chatDir = Join-Path $backendDir "agents\chat"
if (Test-Path -Path $chatDir) {
    Start-Process -FilePath "python" -ArgumentList "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8005" -WorkingDirectory $chatDir
}

Start-Sleep -Seconds 3

Write-Host "Starting Orchestrator..."
Start-Process -FilePath "python" -ArgumentList "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000" -WorkingDirectory (Join-Path $backendDir "orchestrator")

Write-Host "All backend services started."
