import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../services/daily_recap_service.dart';
import '../models/daily_mood_recap.dart';

class DailyRecapScreen extends StatefulWidget {
  const DailyRecapScreen({super.key});

  @override
  State<DailyRecapScreen> createState() => _DailyRecapScreenState();
}

class _DailyRecapScreenState extends State<DailyRecapScreen> {
  final DailyRecapService _dailyRecapService = DailyRecapService();
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  
  DailyMoodRecap? _dailyRecap;
  Map<String, double> _calendarMoodData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    await initializeDateFormatting('id', null);
    await _dailyRecapService.initialize();
    await _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    
    await Future.wait([
      _loadDailyMoodData(_selectedDate),
      _loadMonthlyData(_currentMonth.year, _currentMonth.month),
      _loadCalendarData(_currentMonth.year, _currentMonth.month),
    ]);
    
    setState(() => _isLoading = false);
  }

  Future<void> _loadDailyMoodData(DateTime date) async {
    try {
      final response = await _dailyRecapService.getDailyRecap(date);
      setState(() {
        if (response != null && response['success'] == true && response['data'] != null) {
          _dailyRecap = DailyMoodRecap.fromJson(response['data']);
        } else {
          _dailyRecap = null;
        }
      });
    } catch (e) {
      print('Error loading daily mood data: $e');
      setState(() {
        _dailyRecap = null;
      });
    }
  }

  Future<void> _loadMonthlyData(int year, int month) async {
    // Data sudah di-load di _loadCalendarData, tidak perlu disimpan terpisah
  }

  Future<void> _loadCalendarData(int year, int month) async {
    final overview = await _dailyRecapService.getMonthlyOverview(year, month);
    setState(() {
      _calendarMoodData = {};
      if (overview != null && overview['calendar_data'] != null) {
        final calendarData = overview['calendar_data'] as Map<String, dynamic>;
        calendarData.forEach((date, moodData) {
          if (moodData is Map<String, dynamic> && moodData['mood_score'] != null) {
            _calendarMoodData[date] = (moodData['mood_score'] as num).toDouble();
          }
        });
      }
    });
  }

  Color _getMoodColor(double score) {
    if (score >= 4.5) return const Color(0xFF10B981); // Green - very happy
    if (score >= 3.5) return const Color(0xFF84CC16); // Light green - happy
    if (score >= 2.5) return const Color(0xFFF59E0B); // Yellow - neutral
    if (score >= 1.5) return const Color(0xFFFF9500); // Orange - sad
    return const Color(0xFFEF4444); // Red - very sad
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF0F8F8),
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2D5A5A),
          elevation: 0,
          title: const Text(
            'Daily Recap',
            style: TextStyle(
              color: Color(0xFF2D5A5A),
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8FA68E)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F8),
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan gradasi seperti Sakinah Tracker
            _buildHeader(),
            const SizedBox(height: 20),
            
            // Calendar dengan mood indicators
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildMoodCalendar(),
                    const SizedBox(height: 24),
                    _buildDailyMoodSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF0F8F8),
            Color(0xFFE8F5E8),
          ],
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2D5A5A).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF2D5A5A),
                size: 20,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Daily Recap',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D5A5A),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 40), // Balance untuk back button
        ],
      ),
    );
  }

  Widget _buildMoodCalendar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D5A5A).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header kalender dengan dropdown
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8FA68E), Color(0xFF7A9B7A)],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<int>(
                  value: _currentMonth.month,
                  dropdownColor: const Color(0xFF8FA68E),
                  iconEnabledColor: Colors.white,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  underline: const SizedBox(),
                  items: List.generate(12, (index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child: Text(
                        DateFormat.MMMM('id').format(DateTime(2025, index + 1)),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }),
                  onChanged: (month) {
                    setState(() {
                      _currentMonth = DateTime(_currentMonth.year, month!, 1);
                    });
                    _loadMonthlyData(_currentMonth.year, _currentMonth.month);
                    _loadCalendarData(_currentMonth.year, _currentMonth.month);
                  },
                ),
                DropdownButton<int>(
                  value: _currentMonth.year,
                  dropdownColor: const Color(0xFF8FA68E),
                  iconEnabledColor: Colors.white,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  underline: const SizedBox(),
                  items: List.generate(10, (index) {
                    int year = 2020 + index;
                    return DropdownMenuItem(
                      value: year,
                      child: Text(
                        year.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }),
                  onChanged: (year) {
                    setState(() {
                      _currentMonth = DateTime(year!, _currentMonth.month, 1);
                    });
                    _loadMonthlyData(_currentMonth.year, _currentMonth.month);
                    _loadCalendarData(_currentMonth.year, _currentMonth.month);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Header hari dalam minggu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
                .map((day) => Container(
                      width: 35,
                      height: 35,
                      alignment: Alignment.center,
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748b),
                        ),
                      ),
                    ))
                .toList(),
          ),

          const SizedBox(height: 8),

          // Grid kalender
          ..._buildCalendarWeeks(),
        ],
      ),
    );
  }

  List<Widget> _buildCalendarWeeks() {
    List<Widget> weeks = [];
    DateTime firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    DateTime lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    
    int startWeekday = firstDay.weekday;
    int totalDays = lastDay.day;
    
    List<Widget> days = [];
    
    // Tambahkan container kosong untuk hari sebelum tanggal 1
    for (int i = 1; i < startWeekday; i++) {
      days.add(const SizedBox(width: 35, height: 35));
    }
    
    // Tambahkan hari-hari dalam bulan
    for (int day = 1; day <= totalDays; day++) {
      DateTime date = DateTime(_currentMonth.year, _currentMonth.month, day);
      bool isSelected = _isSameDay(date, _selectedDate);
      String dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      double? moodScore = _calendarMoodData[dateKey];
      
      days.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
            _loadDailyMoodData(date);
          },
          child: Container(
            width: 35,
            height: 35,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected 
                  ? const Color(0xFF8FA68E)
                  : moodScore != null 
                      ? _getMoodColor(moodScore).withOpacity(0.6)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected 
                  ? Border.all(color: Colors.white, width: 2)
                  : null,
            ),
            child: Text(
              day.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected 
                    ? Colors.white
                    : moodScore != null 
                        ? Colors.white
                        : const Color(0xFF64748b),
              ),
            ),
          ),
        ),
      );
    }
    
    // Kelompokkan hari-hari menjadi minggu
    for (int i = 0; i < days.length; i += 7) {
      List<Widget> week = days.sublist(i, (i + 7 > days.length) ? days.length : i + 7);
      while (week.length < 7) {
        week.add(const SizedBox(width: 35, height: 35));
      }
      weeks.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: week,
          ),
        ),
      );
    }
    
    return weeks;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildDailyMoodSection() {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2D5A5A).withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Row(
              children: [
                const Icon(
                  Icons.mood,
                  color: Color(0xFF8FA68E),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Mood ${DateFormat('dd MMMM', 'id').format(_selectedDate)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D5A5A),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),

            // Mood entries atau pesan kosong
            Expanded(
              child: _buildMoodContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodContent() {
    if (_dailyRecap == null || _dailyRecap!.moodEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_neutral,
              size: 64,
              color: const Color(0xFF8FA68E).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada catatan mood',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748b).withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mulai catat mood Anda di hari ini!',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF64748b).withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _dailyRecap!.moodEntries.length,
      itemBuilder: (context, index) {
        final moodEntry = _dailyRecap!.moodEntries[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAF8),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFF8FA68E).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Emoji mood
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getMoodColorFromType(moodEntry.moodType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: _getMoodColorFromType(moodEntry.moodType).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    moodEntry.moodEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Mood info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          moodEntry.moodLabel,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _getMoodColorFromType(moodEntry.moodType),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getMoodColorFromType(moodEntry.moodType).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            moodEntry.timeFormatted,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getMoodColorFromType(moodEntry.moodType),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (moodEntry.notes != null && moodEntry.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        moodEntry.notes!,
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF64748b).withOpacity(0.8),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getMoodColorFromType(String moodType) {
    switch (moodType) {
      case 'senang': return const Color(0xFF10B981);
      case 'sedih': return const Color(0xFFEF4444);
      case 'biasa_saja': return const Color(0xFFF59E0B);
      case 'marah': return const Color(0xFFDC2626);
      case 'murung': return const Color(0xFF6B7280);
      default: return const Color(0xFF6B7280);
    }
  }
}