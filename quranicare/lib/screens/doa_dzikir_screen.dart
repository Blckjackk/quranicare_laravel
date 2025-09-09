import 'package:flutter/material.dart';

class DoaDzikirScreen extends StatelessWidget {
  const DoaDzikirScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F8F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D5A5A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Doa dan Dzikir Ketenangan',
          style: TextStyle(
            color: Color(0xFF2D5A5A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: doaDzikirList.length,
                itemBuilder: (context, index) {
                  final item = doaDzikirList[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8FA68E),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DoaDzikirDetailScreen(doaDzikir: item),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2D5A5A).withOpacity(0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF2D5A5A),
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Color(0xFF8FA68E),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Show more indicator
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Lainnya',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF8FA68E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: const Color(0xFF8FA68E),
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2D5A5A).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.home, 'Home', false),
                _buildNavItem(1, Icons.book, 'Al Quran', false),
                _buildNavItem(2, Icons.chat_bubble, 'Qalbu Chat', false),
                _buildNavItem(3, Icons.person, 'Profil', false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF8FA68E) : const Color(0xFF999999),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? const Color(0xFF8FA68E) : const Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }
}

class DoaDzikirDetailScreen extends StatelessWidget {
  final DoaDzikirItem doaDzikir;

  const DoaDzikirDetailScreen({super.key, required this.doaDzikir});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F8F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D5A5A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Doa dan Dzikir Ketenangan',
          style: TextStyle(
            color: Color(0xFF2D5A5A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2D5A5A).withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  doaDzikir.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D5A5A),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 20),

              // Arabic text card
              if (doaDzikir.arabicText.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2D5A5A).withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    doaDzikir.arabicText,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D5A5A),
                      height: 2.0,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                ),

              const SizedBox(height: 16),

              // Transliteration
              if (doaDzikir.transliteration.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doaDzikir.transliteration,
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF2D5A5A),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        doaDzikir.meaning,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8FA68E),
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Explanation section
              if (doaDzikir.explanation.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2D5A5A).withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Penjelasan Makna',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D5A5A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        doaDzikir.explanation,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2D5A5A),
                          height: 1.6,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 100), // Space for bottom navigation
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2D5A5A).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.home, 'Home', false),
                _buildNavItem(1, Icons.book, 'Al Quran', false),
                _buildNavItem(2, Icons.chat_bubble, 'Qalbu Chat', false),
                _buildNavItem(3, Icons.person, 'Profil', false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF8FA68E) : const Color(0xFF999999),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? const Color(0xFF8FA68E) : const Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }
}

// Data model
class DoaDzikirItem {
  final String title;
  final String arabicText;
  final String transliteration;
  final String meaning;
  final String explanation;

  DoaDzikirItem({
    required this.title,
    required this.arabicText,
    required this.transliteration,
    required this.meaning,
    required this.explanation,
  });
}

// Sample data based on the mockups
final List<DoaDzikirItem> doaDzikirList = [
  DoaDzikirItem(
    title: 'Dzikir Al Matsurat Pagi',
    arabicText: '',
    transliteration: '',
    meaning: '',
    explanation: '',
  ),
  DoaDzikirItem(
    title: 'Dzikir Al Matsurat Sore',
    arabicText: '',
    transliteration: '',
    meaning: '',
    explanation: '',
  ),
  DoaDzikirItem(
    title: 'Doa Penenang Hati',
    arabicText: '',
    transliteration: '',
    meaning: '',
    explanation: '',
  ),
  DoaDzikirItem(
    title: 'Doa agar Dijauhkan dari Berbagai Keburukan',
    arabicText: '',
    transliteration: '',
    meaning: '',
    explanation: '',
  ),
  DoaDzikirItem(
    title: 'Doa agar Diberikan Petunjuk',
    arabicText: '',
    transliteration: '',
    meaning: '',
    explanation: '',
  ),
  DoaDzikirItem(
    title: 'Doa untuk Kesedihan yang Mendalam',
    arabicText: '',
    transliteration: '',
    meaning: '',
    explanation: '',
  ),
  DoaDzikirItem(
    title: 'Doa Meminta Ketenangan Hati',
    arabicText: '',
    transliteration: '',
    meaning: '',
    explanation: '',
  ),
  DoaDzikirItem(
    title: 'Doa agar Diberikan Cahaya Batin',
    arabicText: '',
    transliteration: '',
    meaning: '',
    explanation: '',
  ),
  DoaDzikirItem(
    title: 'Doa Nabi Yunus',
    arabicText: 'لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
    transliteration: 'Lā ilāha illā anta subḥānaka innī kuntu minaz-ẓālimīn(a)',
    meaning: 'Tidak ada tuhan selain Engkau. Maha Suci Engkau. Sesungguhnya aku termasuk orang-orang zalim.',
    explanation: 'Dari segi kesehatan mental, doa ini mengajarkan beberapa prinsip penting yang sejalan dengan terapi modern. Pertama, pengakuan diri akan kesalahan dengan "innī kuntu minadh-dhālimīn" ditunjukkan dalam kalimat "innī kuntu minadh dhālimīn" di mana Nabi Yunus mengakui kesalahannya. Kedua, konsep melepaskan kontrol berlebihan ditemukan dalam "laa ilāha illa anta subḥānaka" yang mengajarkan bahwa dalam kegelisahan sekalipun, masih ada jalan keluar melalui introspeksi, penyerahan diri, dan kepercayaan spiritual. Prinsip-prinsip ini terbukti efektif dalam membantu seseorang keluar dari depresi, kecemasan, dan krisis mental lainnya.\n\nDoa ini juga menunjukkan transformasi dari victim mentality menjadi personal responsibility, serta mempertahankan harapan bahkan dalam situasi yang tampak mustahil. Bagi kesehatan mental, doa Nabi Yunus mengajarkan bahwa dalam kegelisahan sekalipun, masih ada jalan keluar melalui introspeksi, jujur, penyerahan diri, dan kepercayaan spiritual. Prinsip-prinsip ini terbukti efektif dalam membantu seseorang keluar dari depresi, kecemasan, dan krisis mental lainnya.',
  ),
  DoaDzikirItem(
    title: 'Doa Nabi Adam',
    arabicText: '',
    transliteration: '',
    meaning: '',
    explanation: '',
  ),
  DoaDzikirItem(
    title: 'Doa Nabi Sulaiman',
    arabicText: '',
    transliteration: '',
    meaning: '',
    explanation: '',
  ),
];
