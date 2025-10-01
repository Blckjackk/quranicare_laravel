import 'package:flutter/material.dart';
import '../../services/journal_service.dart';

class JurnalRefleksiScreen extends StatefulWidget {
  const JurnalRefleksiScreen({super.key});

  @override
  State<JurnalRefleksiScreen> createState() => _JurnalRefleksiScreenState();
}

class _JurnalRefleksiScreenState extends State<JurnalRefleksiScreen> {
  final JournalService _journalService = JournalService();
  
  int _currentTab = 0; // 0: Jurnal, 1: Riwayat Jurnal
  String _currentView = 'dashboard'; // 'dashboard', 'jurnal_perasaan', 'jurnal_alquran'
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // Backend integration variables
  List<JournalData> _journalHistory = [];
  List<AyahData> _availableAyahs = [];
  List<String> _suggestedTags = [];
  bool _isLoading = false;
  bool _isLoadingHistory = false;
  String _errorMessage = '';
  String _selectedMood = '';
  List<String> _selectedTags = [];

  // Al-Quran functionality
  String _selectedSurah = '';
  String _selectedAyat = '';
  AyahData? _selectedAyahData;

  @override
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoadingHistory = true;
    });

    try {
      // Load recent journal entries
      final recentJournals = await _journalService.getRecentReflections();
      // Load suggested tags
      final tags = await _journalService.getTagSuggestions();
      
      setState(() {
        _journalHistory = recentJournals;
        _suggestedTags = tags;
        _isLoadingHistory = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data jurnal: $e';
        _isLoadingHistory = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D5A5A)),
          onPressed: () {
            if (_currentView == 'dashboard') {
              Navigator.pop(context);
            } else {
              setState(() {
                _currentView = 'dashboard';
              });
            }
          },
        ),
        title: const Text(
          'Jurnal Refleksi',
          style: TextStyle(
            color: Color(0xFF2D5A5A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildCurrentView(),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case 'jurnal_perasaan':
        return _buildJurnalInput();
      case 'jurnal_alquran':
        return _buildJurnalAlQuranInput();
      default:
        return _buildJurnalDashboard();
    }
  }

  Widget _buildJurnalAlQuranInput() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Surah Dropdown
          GestureDetector(
            onTap: () => _showSurahPicker(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedSurah.isEmpty ? 'Pilih Surah' : _selectedSurah,
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedSurah.isEmpty 
                        ? const Color(0xFFBBBBBB) 
                        : const Color(0xFF2D5A5A),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF8FA68E),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          // Ayat Dropdown
          GestureDetector(
            onTap: () => _showAyatPicker(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedAyat.isEmpty ? 'Pilih Ayat' : 'Ayat $_selectedAyat',
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedAyat.isEmpty 
                        ? const Color(0xFFBBBBBB) 
                        : const Color(0xFF2D5A5A),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF8FA68E),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Label
          const Text(
            'Jurnal Refleksi Al-Quran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D5A5A),
            ),
          ),

          const SizedBox(height: 10),

          // Content Input
          Container(
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _contentController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: 'Tulis semua hal yang dirasakan dan berkaitan...',
                hintStyle: TextStyle(
                  color: Color(0xFFBBBBBB),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(20),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Save Button
          Center(
            child: GestureDetector(
              onTap: () {
                if (_selectedSurah.isEmpty || _selectedAyat.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mohon pilih Surah dan Ayat terlebih dahulu'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Save journal logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Jurnal Refleksi Al-Quran berhasil disimpan!'),
                    backgroundColor: Color(0xFF8FA68E),
                  ),
                );
                // Clear form and go back to dashboard
                _contentController.clear();
                setState(() {
                  _selectedSurah = '';
                  _selectedAyat = '';
                  _currentView = 'dashboard';
                });
              },
              child: Container(
                width: 120,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFF8FA68E),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8FA68E).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Simpan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Methods untuk functionality
  Future<void> _saveJournalReflection() async {
    if (_selectedSurah.isEmpty || _selectedAyat.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mohon lengkapi semua field'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // For demo purposes, using ayah ID based on simple calculation
      // In real app, you'd get this from a proper ayah selection
      int ayahId = int.parse(_selectedAyat); // Simplified for demo
      
      final journalData = await _journalService.createAyahReflection(
        ayahId: ayahId,
        title: 'Refleksi $_selectedSurah Ayat $_selectedAyat',
        content: _contentController.text,
        mood: _selectedMood.isEmpty ? null : _selectedMood,
        tags: _selectedTags.isEmpty ? null : _selectedTags,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Jurnal Refleksi Al-Quran berhasil disimpan!'),
          backgroundColor: Color(0xFF8FA68E),
        ),
      );
      
      // Clear form and refresh data
      _contentController.clear();
      setState(() {
        _selectedSurah = '';
        _selectedAyat = '';
        _selectedMood = '';
        _selectedTags.clear();
        _currentView = 'dashboard';
      });
      
      _loadInitialData(); // Refresh journal history
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan jurnal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveEmotionalJournal() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mohon lengkapi judul dan isi jurnal'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // For emotional journal, we can use a generic ayah ID or create separately
      final journalData = await _journalService.createAyahReflection(
        ayahId: 1, // Generic ayah for emotional journals
        title: _titleController.text,
        content: _contentController.text,
        mood: _selectedMood.isEmpty ? null : _selectedMood,
        tags: _selectedTags.isEmpty ? null : _selectedTags,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Jurnal Perasaan berhasil disimpan!'),
          backgroundColor: Color(0xFF8FA68E),
        ),
      );
      
      // Clear form and refresh data
      _titleController.clear();
      _contentController.clear();
      setState(() {
        _selectedMood = '';
        _selectedTags.clear();
        _currentView = 'dashboard';
      });
      
      _loadInitialData(); // Refresh journal history
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan jurnal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  final List<String> surahs = [
    'Al-Fatihah',
    'Al-Baqarah', 
    'Ali Imran',
    'An-Nisa',
    'Al-Maidah',
    'Al-An\'am',
    'Al-A\'raf',
    'Al-Anfal',
    'At-Taubah',
    'Yunus',
  ];

  void _showSurahPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SurahPickerModal(
        surahs: surahs,
        onSurahSelected: (surah) {
          setState(() {
            _selectedSurah = surah;
          });
        },
      ),
    );
  }

  void _showAyatPicker() {
    if (_selectedSurah.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih Surah terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show ayat picker (1-10 for demo)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Ayat'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 10,
            itemBuilder: (context, index) {
              final ayat = (index + 1).toString();
              return ListTile(
                title: Text('Ayat $ayat'),
                onTap: () {
                  setState(() {
                    _selectedAyat = ayat;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildJurnalInput() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Tulis Judul Jurnal Perasaan',
                hintStyle: TextStyle(
                  color: Color(0xFFBBBBBB),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Label
          const Text(
            'Jurnal Perasaan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D5A5A),
            ),
          ),

          const SizedBox(height: 10),

          // Content Input
          Container(
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _contentController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: 'Tulis semua hal yang dirasakan dan berkaitan...',
                hintStyle: TextStyle(
                  color: Color(0xFFBBBBBB),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(20),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Save Button
          Center(
            child: GestureDetector(
              onTap: () {
                // Save journal logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Jurnal berhasil disimpan!'),
                    backgroundColor: Color(0xFF8FA68E),
                  ),
                );
                // Clear form and go back to dashboard
                _titleController.clear();
                _contentController.clear();
                setState(() {
                  _currentView = 'dashboard';
                });
              },
              child: Container(
                width: 120,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFF8FA68E),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8FA68E).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Simpan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJurnalDashboard() {
    return Column(
      children: [
        // Tab Header
        Container(
          margin: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _currentTab = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _currentTab == 0 ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: _currentTab == 0 ? Colors.transparent : const Color(0xFF8FA68E),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Jurnal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _currentTab == 0 ? const Color(0xFF2D5A5A) : const Color(0xFF8FA68E),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _currentTab = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _currentTab == 1 ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: _currentTab == 1 ? Colors.transparent : const Color(0xFF8FA68E),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Riwayat Jurnal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _currentTab == 1 ? const Color(0xFF2D5A5A) : const Color(0xFF8FA68E),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: _currentTab == 0 ? _buildJurnalTabContent() : _buildRiwayatJurnalContent(),
        ),
      ],
    );
  }

  Widget _buildJurnalCard({
    required String title,
    required String description,
    required String buttonText,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
    bool emotions = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D5A5A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF8FA68E).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF8FA68E),
                  size: 30,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // Emotions (only for Jurnal Perasaan)
          if (emotions) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildEmotionIcon('😊', const Color(0xFF4CAF50)),
                const SizedBox(width: 8),
                _buildEmotionIcon('😐', const Color(0xFFFFA726)),
                const SizedBox(width: 8),
                _buildEmotionIcon('😢', const Color(0xFFEF5350)),
              ],
            ),
            const SizedBox(height: 15),
          ],

          // Action Button
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF8FA68E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionIcon(String emoji, Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildJurnalTabContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Jurnal Refleksi Al-Quran Card
          _buildJurnalCard(
            title: 'Jurnal Refleksi Al-Quran',
            description: 'Mari tuangkan makna sepenak untuk menumbuhkan makna firman Nya. Apa yang Anda dapatkan dari bacaan Al-Qur\'an hari ini?',
            buttonText: 'Buat Jurnal Refleksi Al Quran',
            color: const Color(0xFFE8F5E8),
            icon: Icons.menu_book,
            onTap: () {
              setState(() {
                _currentView = 'jurnal_alquran';
              });
            },
          ),

          const SizedBox(height: 20),

          // Jurnal Perasaan Card
          _buildJurnalCard(
            title: 'Jurnal Perasaan',
            description: 'Mari tuangkan waktu sejenak untuk merenungkan makna firman Nya. Apa yang Anda dapatkan dari bacaan Al-Qur\'an hari ini?',
            buttonText: 'Buat Jurnal Perasaan',
            color: const Color(0xFFE8F1F8),
            icon: Icons.favorite_border,
            emotions: true,
            onTap: () => setState(() => _currentView = 'jurnal_perasaan'),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRiwayatJurnalContent() {
    if (_isLoadingHistory) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8FA68E)),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: const Color(0xFF8FA68E).withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: TextStyle(
                color: const Color(0xFF2D5A5A).withOpacity(0.8),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadInitialData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8FA68E),
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_journalHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: const Color(0xFF8FA68E).withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada jurnal yang dibuat',
              style: TextStyle(
                color: const Color(0xFF2D5A5A).withOpacity(0.8),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mulai buat jurnal pertama Anda!',
              style: TextStyle(
                color: const Color(0xFF8FA68E).withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [], // TODO: Implement dynamic history display
      ),
    );
  }
  
  Widget _buildJournalHistoryCard(JournalEntry journal) {
    return GestureDetector(
      onTap: () {
        preview: 'Ayat ini, begitu menyegarkan saat dibaca. Perasaan balikan, "Allah lebih mengampuni begitu dalamnya...',
        content: 'Ayat ini, begitu menyegarkan saat dibaca. Perasaan balikan, "Allah lebih mengampuni begitu dalamnya mereka proaktif (di pasar ayah). Syukur, semua yang bahagia tidak lolos karena. Kaliman ini berdengu mengusahkan sebagian berkisar pengalahan makmami di bidangnya seperti syari, tidak ada satu kondisi syukur atau kata',
        date: DateTime.now().subtract(const Duration(days: 5)),
      ),
      JournalEntry(
        id: '3',
        title: 'Al-Ankabut Ayat 21',
        type: JournalType.alquran,
        surah: 'Al-Ankabut',
        ayat: '21',
        preview: 'Ayat ini, mengajak berpasangan tentulah kekuasaan untuk Allah Rahman. Dia menyerah saat yang...',
        content: 'Ayat ini, mengajak berpasangan tentulah kekuasaan untuk Allah Rahman. Dia menyerah saat yang kehidupan, dan merasakan atau yang lain kehidupan menghadapi berencana beresiko keglduhan dan kekayakamaan. Nya yang tak terbatas',
        date: DateTime.now().subtract(const Duration(days: 8)),
      ),
      JournalEntry(
        id: '4',
        title: 'Mengurai Benang Pikiran',
        type: JournalType.perasaan,
        surah: '',
        ayat: '',
        preview: 'Hari ini ada perasaan aneh yang menggangggu, seperti benang kusut yang perlu duurut. Bukan sedih...',
        content: 'Hari ini ada perasaan aneh yang menggangggu, seperti benang kusut yang perlu duurut. Bukan sedih, bukan juga bahagia mendalam. Rasih itu manusiaan dan seharusnya selalu berisi di pertimbangan jalan. melihat berbagai arah dan seteliti keadaan memilih karena penting.',
        date: DateTime.now().subtract(const Duration(days: 12)),
      ),
      JournalEntry(
        id: '5',
        title: 'Ngobrol Sama Diri Sendiri',
        type: JournalType.perasaan,
        surah: '',
        ayat: '',
        preview: 'Udah lama rasanya campur aduk ya. Kayak hati ini ga jelas sama diri sendiri, bisa nya coba...',
        content: 'Udah lama rasanya campur aduk ya. Kayak hati ini ga jelas sama diri sendiri, bisa nya coba udah lama dan langsat lah yang inest di kepale. Aku merasa, menarik yang tokier sampai seputar sendiri melegakan pra dan video hari sekarang aku meminta tolong atau pun cuman satu hal yang penting, naya aku tau keruan.',
        date: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: _journalHistory.map((journal) => _buildDynamicJournalHistoryCard(journal)).toList(),
      ),
    );
  */

  Widget _buildJournalHistoryCard(JournalEntry journal) {
    return GestureDetector(
      onTap: () {
        // Navigate to journal detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JournalDetailScreen(journal: journal),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: journal.type == JournalType.alquran 
            ? const Color(0xFFE8F5E8)
            : const Color(0xFFE8F1F8),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with Surah info (if Al-Quran journal)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    journal.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D5A5A),
                    ),
                  ),
                ),
                Text(
                  _formatDate(journal.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF8FA68E).withOpacity(0.8),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Preview content
            Text(
              journal.preview,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Journal type indicator at bottom right
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: journal.type == JournalType.alquran 
                      ? const Color(0xFF8FA68E).withOpacity(0.2)
                      : const Color(0xFF2D5A5A).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    journal.type == JournalType.alquran 
                      ? '${journal.surah} ${journal.ayat}'
                      : 'Refleksi',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: journal.type == JournalType.alquran 
                        ? const Color(0xFF8FA68E)
                        : const Color(0xFF2D5A5A),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Hari ini';
    } else if (difference == 1) {
      return '1 hari lalu';
    } else if (difference < 7) {
      return '$difference hari lalu';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '$weeks minggu lalu';
    } else {
      final months = (difference / 30).floor();
      return '$months bulan lalu';
    }
  }
}

// Surah Picker Modal (Image 4)
class SurahPickerModal extends StatefulWidget {
  final List<String> surahs;
  final Function(String) onSurahSelected;

  const SurahPickerModal({
    super.key,
    required this.surahs,
    required this.onSurahSelected,
  });

  @override
  State<SurahPickerModal> createState() => _SurahPickerModalState();
}

class _SurahPickerModalState extends State<SurahPickerModal> {
  String _selectedSurah = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFFF0F8F0),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 15, bottom: 20),
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFF8FA68E),
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),

          // Title
          const Text(
            'Pilih Surah',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D5A5A),
            ),
          ),

          const SizedBox(height: 20),

          // Surah List
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.surahs.length,
                      itemBuilder: (context, index) {
                        final surah = widget.surahs[index];
                        final isSelected = _selectedSurah == surah;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedSurah = surah;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected 
                                ? const Color(0xFF8FA68E).withOpacity(0.1)
                                : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected 
                                ? Border.all(color: const Color(0xFF8FA68E))
                                : null,
                            ),
                            child: Text(
                              surah,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected 
                                  ? const Color(0xFF8FA68E)
                                  : const Color(0xFF2D5A5A),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Simpan Button
                  GestureDetector(
                    onTap: () {
                      if (_selectedSurah.isNotEmpty) {
                        widget.onSurahSelected(_selectedSurah);
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      width: 120,
                      height: 45,
                      decoration: BoxDecoration(
                        color: _selectedSurah.isNotEmpty 
                          ? const Color(0xFF8FA68E)
                          : const Color(0xFFCCCCCC),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: _selectedSurah.isNotEmpty ? [
                          BoxShadow(
                            color: const Color(0xFF8FA68E).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ] : null,
                      ),
                      child: const Center(
                        child: Text(
                          'Simpan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final List<String> months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

// Data Models
enum JournalType {
  alquran,
  perasaan,
}

class JournalEntry {
  final String id;
  final String title;
  final JournalType type;
  final String surah;
  final String ayat;
  final String preview;
  final String content;
  final DateTime date;

  JournalEntry({
    required this.id,
    required this.title,
    required this.type,
    required this.surah,
    required this.ayat,
    required this.preview,
    required this.content,
    required this.date,
  });
}

// Journal Detail Screen
class JournalDetailScreen extends StatelessWidget {
  final JournalEntry journal;

  const JournalDetailScreen({
    super.key,
    required this.journal,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D5A5A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Jurnal Refleksi',
          style: TextStyle(
            color: Color(0xFF2D5A5A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Journal Title
            Text(
              journal.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D5A5A),
              ),
            ),

            const SizedBox(height: 8),

            // Date and Type
            Row(
              children: [
                Text(
                  _formatDate(journal.date),
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF8FA68E).withOpacity(0.8),
                  ),
                ),
                if (journal.type == JournalType.alquran) ...[
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8FA68E).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${journal.surah} ${journal.ayat}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8FA68E),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 24),

            // Journal Content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                journal.content,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2D5A5A),
                  height: 1.6,
                ),
                textAlign: TextAlign.justify,
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Hari ini';
    } else if (difference == 1) {
      return 'Kemarin';
    } else if (difference < 7) {
      return '$difference hari lalu';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '$weeks minggu lalu';
    } else {
      final months = (difference / 30).floor();
      return '$months bulan lalu';
    }
  }
}

// Dynamic Journal Detail Screen for backend data
class DynamicJournalDetailScreen extends StatelessWidget {
  final JournalData journal;

  const DynamicJournalDetailScreen({
    super.key,
    required this.journal,
  });

  @override
  Widget build(BuildContext context) {
    final isAlQuranJournal = journal.ayah != null;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D5A5A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Jurnal',
          style: TextStyle(
            color: Color(0xFF2D5A5A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Journal Title
            Text(
              journal.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D5A5A),
              ),
            ),

            const SizedBox(height: 12),

            // Date and Type Info
            Row(
              children: [
                Text(
                  _formatDate(journal.createdAt),
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF8FA68E).withOpacity(0.8),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isAlQuranJournal 
                        ? [const Color(0xFF8FA68E), const Color(0xFF2D5A5A)]
                        : [const Color(0xFF2D5A5A), const Color(0xFF8FA68E)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isAlQuranJournal ? 'Jurnal Al-Quran' : 'Jurnal Perasaan',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            // Al-Quran info if available
            if (journal.ayah != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8FA68E), Color(0xFF2D5A5A)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      journal.ayah!.surah?.nameIndonesian ?? 'Unknown Surah',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      journal.ayah!.textArabic,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: 'Arabic',
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      journal.ayah!.textIndonesian,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Journal Content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8FA68E).withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                journal.content,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2D5A5A),
                  height: 1.6,
                ),
                textAlign: TextAlign.justify,
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Hari ini';
    } else if (difference == 1) {
      return 'Kemarin';
    } else if (difference < 7) {
      return '$difference hari lalu';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '$weeks minggu lalu';
    } else {
      final months = (difference / 30).floor();
      return '$months bulan lalu';
    }
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'bahagia':
        return Colors.green;
      case 'sad':
      case 'sedih':
        return Colors.blue;
      case 'angry':
      case 'marah':
        return Colors.red;
      case 'calm':
      case 'tenang':
        return const Color(0xFF8FA68E);
      default:
        return Colors.grey;
    }
  }

  String _getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'bahagia':
        return '😊';
      case 'sad':
      case 'sedih':
        return '😢';
      case 'angry':
      case 'marah':
        return '😡';
      case 'calm':
      case 'tenang':
        return '😌';
      default:
        return '😐';
    }
  }
}
