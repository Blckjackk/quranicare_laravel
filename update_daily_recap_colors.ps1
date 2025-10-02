# Script to update Daily Recap colors to soft sage green theme
$filePath = "quranicare\lib\screens\daily_recap_screen.dart"
$content = Get-Content $filePath -Raw

# Update to soft sage green theme
$content = $content -replace 'Color\(0xFFF0F8F8\)', 'Color(0xFFF5F8F5)'
$content = $content -replace 'Color\(0xFF2D5A5A\)', 'Color(0xFF6B7D6A)'
$content = $content -replace 'Color\(0xFF8FA68E\)', 'Color(0xFF8FA68E)'
$content = $content -replace 'Color\(0xFF7A9B7A\)', 'Color(0xFF6B7D6A)'

$content | Set-Content $filePath
Write-Host "✅ Daily Recap colors updated to soft sage green theme!" -ForegroundColor Green