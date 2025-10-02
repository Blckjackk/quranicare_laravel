# Script to update Sakinah Tracker colors to soft sage green theme
$filePath = "quranicare\lib\screens\profile\sakinah_tracker_screen.dart"
$content = Get-Content $filePath -Raw

# Update to soft sage green theme
$content = $content -replace 'Color\(0xFFF0F8F8\)', 'Color(0xFFF5F8F5)'
$content = $content -replace 'Color\(0xFFE8F5E8\)', 'Color(0xFFF5F8F5)'

$content | Set-Content $filePath
Write-Host "✅ Sakinah Tracker colors updated to soft sage green theme!" -ForegroundColor Green