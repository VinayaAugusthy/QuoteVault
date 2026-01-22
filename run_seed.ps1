# Load .env file and run seed script
$envFile = ".env"
if (-not (Test-Path $envFile)) {
    Write-Host "Error: .env file not found!" -ForegroundColor Red
    exit 1
}

# Read .env file and set environment variables
Get-Content $envFile | ForEach-Object {
    if ($_ -match '^\s*([^#][^=]+)=(.+)$') {
        $name = $matches[1].Trim()
        $value = $matches[2].Trim()
        # Remove quotes if present
        $value = $value -replace '^["''](.+)["'']$', '$1'
        [Environment]::SetEnvironmentVariable($name, $value, "Process")
        Write-Host "Loaded: $name" -ForegroundColor Green
    }
}

# Run the seed script
Write-Host "`nRunning seed script..." -ForegroundColor Cyan
dart run tool/seed_quotes.dart

