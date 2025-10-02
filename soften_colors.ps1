# PowerShell script to soften audio relax colors for better relaxation atmosphere
$filePath = "quranicare\lib\screens\audio_relax\audio_relax_screen.dart"

# Read the file content
$content = Get-Content $filePath -Raw

# Replace bright colors with softer, more muted tones for relaxation
$content = $content -replace 'Color\(0xFF7CB342\)', 'Color(0xFF8FA68E)'  # Soft sage green
$content = $content -replace 'Color\(0xFF689F38\)', 'Color(0xFF6B7D6A)'  # Muted olive green
$content = $content -replace 'Color\(0xFFE8F5E8\)', 'Color(0xFFF5F8F5)'  # Very soft mint background

# Write back to file
$content | Set-Content $filePath

Write-Host "Colors softened successfully!" -ForegroundColor Green
Write-Host "Bright greens replaced with softer, more relaxing tones" -ForegroundColor Cyan