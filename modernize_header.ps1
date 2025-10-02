# Script to modernize Doa Dzikir header only
$filePath = "quranicare\lib\screens\doa_dzikir_screen.dart"
$content = Get-Content $filePath -Raw

# Replace just the AppBar with modern gradient header
$oldAppBar = @"
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F8F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6B7D6A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Doa dan Dzikir Ketenangan',
          style: TextStyle(
            color: Color(0xFF6B7D6A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
"@

$newAppBar = @"
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF8FA68E),
                Color(0xFF6B7D6A),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Doa & Dzikir\nKetenangan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
"@

$content = $content -replace [regex]::Escape($oldAppBar), $newAppBar

$content | Set-Content $filePath
Write-Host "✅ Modern gradient header applied to Doa Dzikir!" -ForegroundColor Green