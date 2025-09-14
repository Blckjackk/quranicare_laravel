import 'package:flutter/material.dart';
import '../services/quran_service.dart';
import '../services/journal_service.dart' as journal;
import '../widgets/add_reflection_modal_simple.dart';
import '../widgets/reflection_list_widget.dart';

class AlQuranScreen extends StatefulWidget {
  const AlQuranScreen({super.key});

  @override
  State<AlQuranScreen> createState() => _AlQuranScreenState();
}

class _AlQuranScreenState extends State<AlQuranScreen> {
  List<SurahData> surahList = [];
  List<SurahData> filteredSurahList = [];
  bool isLoading = true;
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadSurahs();
  }

  Future<void> loadSurahs() async {
    try {
      setState(() {
        isLoading = true;
      });
      
      final surahs = await QuranService.getSurahs();
      setState(() {
        surahList = surahs;
        filteredSurahList = surahs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading surahs: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void filterSurahs(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredSurahList = surahList;
      } else {
        filteredSurahList = surahList.where((surah) {
          return surah.nameIndonesian.toLowerCase().contains(query.toLowerCase()) ||
                 surah.nameArabic.contains(query) ||
                 surah.nameLatin.toLowerCase().contains(query.toLowerCase()) ||
                 surah.number.toString().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2D5A5A), // Teal gelap
              Color(0xFF4A6741), // Green gelap
              Color(0xFFF0F8F8), // Light teal
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Modern Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Column(
                  children: [
                    // Back button dan title
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Al-Quran',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Hidayah & Petunjuk Hidup',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.bookmark_border, color: Colors.white),
                            onPressed: () {
                              // TODO: Navigate to bookmarks
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: filterSurahs,
                        decoration: InputDecoration(
                          hintText: 'Cari Surah...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: Colors.grey[400]),
                                  onPressed: () {
                                    searchController.clear();
                                    filterSurahs('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Stats cards
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF2D5A5A).withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.menu_book, color: Color(0xFF2D5A5A), size: 24),
                            const SizedBox(height: 8),
                            Text(
                              '${surahList.length}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D5A5A),
                              ),
                            ),
                            const Text(
                              'Total Surah',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF4A6741).withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.filter_vintage, color: Color(0xFF4A6741), size: 24),
                            const SizedBox(height: 8),
                            Text(
                              '${filteredSurahList.length}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A6741),
                              ),
                            ),
                            const Text(
                              'Hasil Pencarian',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Surah List
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: isLoading
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D5A5A)),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Memuat data Al-Quran...',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : filteredSurahList.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Tidak ada surah yang ditemukan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: filteredSurahList.length,
                              itemBuilder: (context, index) {
                                final surah = filteredSurahList[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 2,
                                  shadowColor: Colors.black.withOpacity(0.1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SurahDetailScreen(surah: surah),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          // Nomor surah dengan styling khusus
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFF2D5A5A), Color(0xFF4A6741)],
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${surah.number}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          // Info surah
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        surah.nameIndonesian,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w600,
                                                          color: Color(0xFF2D5A5A),
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      surah.nameArabic,
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.w500,
                                                        color: Color(0xFF4A6741),
                                                        fontFamily: 'Arabic',
                                                      ),
                                                      textDirection: TextDirection.rtl,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: surah.place.toLowerCase() == 'makkah' || surah.place.toLowerCase() == 'makkiyyah'
                                                            ? Colors.green.withOpacity(0.1)
                                                            : Colors.blue.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: Text(
                                                        surah.place,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: surah.place.toLowerCase() == 'makkah' || surah.place.toLowerCase() == 'makkiyyah'
                                                              ? Colors.green
                                                              : Colors.blue,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Icon(
                                                      Icons.list_alt,
                                                      size: 16,
                                                      color: Colors.grey[600],
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${surah.numberOfAyahs} ayat',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Arrow icon
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 16,
                                            color: Colors.grey[400],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SurahDetailScreen extends StatefulWidget {
  final SurahData surah;

  const SurahDetailScreen({super.key, required this.surah});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  List<AyahData> ayahs = [];
  bool isLoading = true;
  final journal.JournalService _journalService = journal.JournalService();

  @override
  void initState() {
    super.initState();
    loadAyahs();
  }

  Future<void> loadAyahs() async {
    try {
      setState(() {
        isLoading = true;
      });
      
      final response = await QuranService.getAyahs(widget.surah.number);
      setState(() {
        ayahs = response.ayahs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading ayahs: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddReflectionModal(AyahData ayah) {
    showDialog(
      context: context,
      builder: (context) => AddReflectionModal(
        ayahId: ayah.id,
        ayahText: ayah.textArabic,
        ayahTranslation: ayah.textIndonesian,
        onReflectionAdded: (reflection) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Refleksi berhasil ditambahkan'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _showAyahReflections(AyahData ayah) async {
    try {
      final reflectionData = await _journalService.getAyahReflections(ayah.id);
      
      if (!mounted) return;
      
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          expand: false,
          builder: (context, scrollController) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.book_outlined,
                      color: Colors.teal[600],
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Refleksi QS. ${widget.surah.nameIndonesian} : ${ayah.number}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[700],
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showAddReflectionModal(ayah);
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Tambah'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.teal[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Ayah reference
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.teal[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ayah.textArabic,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.8,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ayah.textIndonesian,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Reflections list
                Text(
                  'Refleksi Anda (${reflectionData['reflection_count']} refleksi)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                
                Expanded(
                  child: ReflectionListWidget(
                    reflections: reflectionData['reflections'],
                    onReflectionTap: (reflection) {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (context) => ReflectionDetailModal(
                          reflection: reflection,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading reflections: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2D5A5A),
              Color(0xFF4A6741),
              Color(0xFFF0F8F8),
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.surah.nameIndonesian,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${widget.surah.place} • ${widget.surah.numberOfAyahs} ayat',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          widget.surah.nameArabic,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontFamily: 'Arabic',
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: isLoading
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D5A5A)),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Memuat ayat-ayat...',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: ayahs.length,
                          itemBuilder: (context, index) {
                            final ayah = ayahs[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 2,
                              shadowColor: Colors.black.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Ayah number
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF2D5A5A), Color(0xFF4A6741)],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Ayat ${ayah.number}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Arabic text
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey[200]!),
                                      ),
                                      child: Text(
                                        ayah.textArabic,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          height: 2.0,
                                          fontFamily: 'Arabic',
                                          color: Color(0xFF2D5A5A),
                                        ),
                                        textAlign: TextAlign.right,
                                        textDirection: TextDirection.rtl,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Latin text
                                    if (ayah.textLatin?.isNotEmpty == true) ...[
                                      Text(
                                        ayah.textLatin!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey[600],
                                          height: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    // Indonesian translation
                                    Text(
                                      ayah.textIndonesian,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        height: 1.6,
                                        color: Color(0xFF4A6741),
                                      ),
                                    ),
                                    // Tafsir if available
                                    if (ayah.tafsirIndonesian?.isNotEmpty == true) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.blue[100]!),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Tafsir:',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blue[700],
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              ayah.tafsirIndonesian!,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.blue[600],
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    
                                    // Reflection buttons
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () => _showAddReflectionModal(ayah),
                                            icon: Icon(
                                              Icons.edit_note,
                                              size: 18,
                                              color: Colors.teal[600],
                                            ),
                                            label: Text(
                                              'Tulis Refleksi',
                                              style: TextStyle(
                                                color: Colors.teal[600],
                                                fontSize: 13,
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(color: Colors.teal[300]!),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () => _showAyahReflections(ayah),
                                            icon: Icon(
                                              Icons.visibility_outlined,
                                              size: 18,
                                              color: Colors.orange[600],
                                            ),
                                            label: Text(
                                              'Lihat Refleksi',
                                              style: TextStyle(
                                                color: Colors.orange[600],
                                                fontSize: 13,
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(color: Colors.orange[300]!),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}