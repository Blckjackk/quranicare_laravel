# Script to modernize Doa Dzikir cards
$filePath = "quranicare\lib\screens\doa_dzikir_screen.dart"
$content = Get-Content $filePath -Raw

# Modernize card margins and shadows
$content = $content -replace 'margin: const EdgeInsets\.symmetric\(horizontal: 16, vertical: 8\)', 'margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)'
$content = $content -replace 'elevation: 3,', 'elevation: 0,'
$content = $content -replace 'Card\(', 'Container('
$content = $content -replace 'shape: RoundedRectangleBorder\([\s\S]*?borderRadius: BorderRadius\.circular\(12\),[\s\S]*?\),', 'decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFF6B7D6A).withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],),'

# Update card content padding and styling
$content = $content -replace 'padding: const EdgeInsets\.all\(16\)', 'padding: const EdgeInsets.all(20)'
$content = $content -replace 'fontSize: 16,', 'fontSize: 18,'
$content = $content -replace 'color: Color\(0xFF6B7D6A\),', 'color: Color(0xFF2D4538),'

$content | Set-Content $filePath
Write-Host "✅ Modern card design applied to Doa Dzikir!" -ForegroundColor Green