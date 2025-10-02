# Simple script to apply soft colors to doa dzikir
$filePath = "quranicare\lib\screens\doa_dzikir_screen.dart"
$content = Get-Content $filePath -Raw

# Apply soft green color scheme
$content = $content -replace 'Color\(0xFF2D5A5A\)', 'Color(0xFF6B7D6A)'
$content = $content -replace 'Color\(0xFFF0F8F8\)', 'Color(0xFFF5F8F5)'
$content = $content -replace 'Color\(0xFFE8F5E8\)', 'Color(0xFFF5F8F5)'

$content | Set-Content $filePath
Write-Host "✅ Doa Dzikir colors updated to soft sage green theme!" -ForegroundColor Green