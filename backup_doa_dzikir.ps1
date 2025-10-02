# PowerShell script to backup and create a clean modern UI version
$sourceFile = "quranicare\lib\screens\doa_dzikir_screen.dart"
$backupFile = "quranicare\lib\screens\doa_dzikir_screen_backup.dart"

# Create backup
Copy-Item $sourceFile $backupFile -Force

Write-Host "Backup created: $backupFile" -ForegroundColor Green
Write-Host "You can restore with: Copy-Item $backupFile $sourceFile -Force" -ForegroundColor Yellow