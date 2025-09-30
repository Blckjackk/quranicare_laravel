import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../services/daily_recap_service.dart';

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
  MonthlyMoodOverview? _monthlyOverview;
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
      final recap = await _dailyRecapService.getDailyRecap(date);
      setState(() {
        _dailyRecap = recap;
      });
    } catch (e) {
      print('Error loading daily mood data: $e');
      setState(() {
        _dailyRecap = null;
      });
    }
  }

  Future<void> _loadMonthlyData(int year, int month) async {
    final overview = await _dailyRecapService.getMonthlyOverview(year, month);
    setState(() {
      _monthlyOverview = overview;
    });
  }

  Future<void> _loadCalendarData(int year, int month) async {
    final overview = await _dailyRecapService.getMonthlyOverview(year, month);
    setState(() {
      _calendarMoodData = {};
      if (overview != null) {
        overview.calendarData.forEach((date, moodData) {
          _calendarMoodData[date] = moodData.moodScore;
        });
      }
    });
  }

  Color _getMoodColor(String moodType) {
    switch (moodType) {
      case 'senang': return const Color(0xFF10B981);
      case 'sedih': return const Color(0xFFEF4444);
      case 'biasa_saja': return const Color(0xFFF59E0B);
      case 'marah': return const Color(0xFFDC2626);
      case 'murung': return const Color(0xFF6B7280);
      default: return const Color(0xFF6B7280);
    }
  }

  Color _getCalendarMoodColor(double score) {
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
        backgroundColor: const Color(0xFFF8FAF8),
        appBar: AppBar(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          title: const Text('Daily Recap'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Daily Recap',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() => _showCalendar = !_showCalendar),
            icon: Icon(_showCalendar ? Icons.timeline : Icons.calendar_month),
            tooltip: _showCalendar ? 'Tampilkan Timeline' : 'Tampilkan Kalender',
          ),
        ],
      ),
      body: _showCalendar ? _buildCalendarView() : _buildTimelineView(),
    );
  }

  Widget _buildTimelineView() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateSelector(),
            const SizedBox(height: 20),
            if (_dailyRecap != null) ...[
              _buildDailyStatsCard(),
              const SizedBox(height: 16),
              _buildMoodEntriesCard(),
              const SizedBox(height: 16),
              _buildWeeklyContextCard(),
              const SizedBox(height: 16),
              _buildInsightsCard(),
            ] else ...[
              _buildNoDataCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView() {
    if (_monthlyOverview == null) {
      return const Center(child: Text('Data kalender tidak tersedia'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMonthlyHeader(),
          const SizedBox(height: 20),
          _buildMoodCalendar(),
          const SizedBox(height: 20),
          _buildMonthlyStats(),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: _selectDate,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _dailyRecap?.dateFormatted ?? DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_selectedDate),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      'Ketuk untuk mengubah tanggal',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyStatsCard() {
    final stats = _dailyRecap!.dailyStats;
    if (stats == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.mood, color: _getMoodColor(stats.dominantMood)),
                const SizedBox(width: 8),
                const Text(
                  'Ringkasan Hari Ini',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getMoodColor(stats.dominantMood).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getMoodColor(stats.dominantMood).withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    stats.dominantMoodEmoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stats.dominantMoodLabel,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: _getMoodColor(stats.dominantMood),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mood Score: ${stats.moodScore.toStringAsFixed(1)}/5.0',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodEntriesCard() {
    final entries = _dailyRecap!.moodEntries;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.timeline, color: Color(0xFF2E7D32)),
                SizedBox(width: 8),
                Text(
                  'Timeline Mood',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (entries.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Icon(Icons.mood_bad, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Belum ada catatan mood',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Mulai catat mood Anda hari ini!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              ...entries.asMap().entries.map((entry) {
                final index = entry.key;
                final moodEntry = entry.value;
                final isLast = index == entries.length - 1;
                
                return _buildMoodEntryItem(moodEntry, isLast);
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMoodEntryItem(MoodEntry entry, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _getMoodColor(entry.moodType),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  entry.moodEmoji,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Mood entry content
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getMoodColor(entry.moodType).withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getMoodColor(entry.moodType).withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      entry.moodLabel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _getMoodColor(entry.moodType),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getMoodColor(entry.moodType).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        entry.timeFormatted,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getMoodColor(entry.moodType),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    entry.notes!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyContextCard() {
    final weeklyContext = _dailyRecap!.weeklyContext;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.view_week, color: Color(0xFF2E7D32)),
                SizedBox(width: 8),
                Text(
                  'Konteks Mingguan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildWeeklyStatItem(
                    'Rata-rata Score',
                    weeklyContext.weeklyAverageScore.toStringAsFixed(1),
                    Icons.analytics,
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                Expanded(
                  child: _buildWeeklyStatItem(
                    'Total Entri',
                    weeklyContext.weeklyTotalEntries.toString(),
                    Icons.edit_calendar,
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                Expanded(
                  child: _buildWeeklyStatItem(
                    'Hari Aktif',
                    '${weeklyContext.daysWithRecords}/7',
                    Icons.calendar_month,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInsightsCard() {
    final insights = _dailyRecap!.insights;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.psychology, color: Color(0xFF2E7D32)),
                SizedBox(width: 8),
                Text(
                  'Insight & Rekomendasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Mood streak
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_fire_department, color: Colors.orange[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Streak: ${insights.moodStreak} hari',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[800],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Mood trend
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.trending_up, color: Colors.blue[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Trend Mood',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    insights.moodTrend.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Recommendations
            const Text(
              'Rekomendasi untuk Anda:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    insights.recommendations.message,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...insights.recommendations.suggestions.map((suggestion) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.green[600],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              suggestion,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.green[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.sentiment_neutral,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Data Mood',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mulai catat mood Anda untuk melihat recap harian dan insights yang menarik!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to mood tracking screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur mood tracking segera hadir!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Mulai Catat Mood'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Text(
              '${_monthlyOverview!.monthName} ${_monthlyOverview!.year}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tracking: ${_monthlyOverview!.summary.trackingPercentage.toStringAsFixed(1)}%',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodCalendar() {
    final daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Days of week header
            Row(
              children: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
                  .map((day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            
            // Calendar grid
            ...List.generate((daysInMonth + firstWeekday - 1) ~/ 7 + 1, (weekIndex) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: List.generate(7, (dayIndex) {
                    final dayNumber = weekIndex * 7 + dayIndex + 1 - firstWeekday + 1;
                    
                    if (dayNumber < 1 || dayNumber > daysInMonth) {
                      return const Expanded(child: SizedBox(height: 40));
                    }
                    
                    final dateKey = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${dayNumber.toString().padLeft(2, '0')}';
                    final moodData = _monthlyOverview?.calendarData[dateKey];
                    final isToday = dayNumber == DateTime.now().day && 
                                   _selectedDate.month == DateTime.now().month && 
                                   _selectedDate.year == DateTime.now().year;
                    
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (moodData != null) {
                            setState(() {
                              _selectedDate = DateTime(_selectedDate.year, _selectedDate.month, dayNumber);
                              _showCalendar = false;
                            });
                            _loadData();
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          height: 40,
                          decoration: BoxDecoration(
                            color: moodData != null 
                                ? _getCalendarMoodColor(moodData.moodScore)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: isToday 
                                ? Border.all(color: const Color(0xFF2E7D32), width: 2)
                                : moodData != null 
                                    ? Border.all(color: Colors.white, width: 1)
                                    : Border.all(color: Colors.grey[300]!, width: 1),
                          ),
                          child: Center(
                            child: moodData != null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        moodData.emoji,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        dayNumber.toString(),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    dayNumber.toString(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isToday ? const Color(0xFF2E7D32) : Colors.grey[600],
                                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyStats() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistik Bulanan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildMonthlyStatItem(
                    'Total Entri',
                    _monthlyOverview!.summary.totalEntries.toString(),
                    Icons.edit_note,
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                Expanded(
                  child: _buildMonthlyStatItem(
                    'Rata-rata Score',
                    _monthlyOverview!.summary.averageScore.toStringAsFixed(1),
                    Icons.analytics,
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                Expanded(
                  child: _buildMonthlyStatItem(
                    'Hari Tercatat',
                    '${_monthlyOverview!.summary.daysWithRecords}/${_monthlyOverview!.summary.totalDays}',
                    Icons.calendar_month,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            const Text(
              'Distribusi Mood',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            ..._monthlyOverview!.moodDistribution.entries.map((entry) {
              final percentage = _monthlyOverview!.summary.totalEntries > 0 
                  ? (entry.value / _monthlyOverview!.summary.totalEntries * 100)
                  : 0.0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _getMoodColor(entry.key),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          _getMoodEmoji(entry.key),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getMoodLabel(entry.key),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Helper methods for mood display
  String _getMoodEmoji(String moodType) {
    switch (moodType) {
      case 'senang': return '😊';
      case 'sedih': return '😢';
      case 'biasa_saja': return '😐';
      case 'marah': return '😡';
      case 'murung': return '😟';
      default: return '😐';
    }
  }

  String _getMoodLabel(String moodType) {
    switch (moodType) {
      case 'senang': return 'Senang';
      case 'sedih': return 'Sedih';
      case 'biasa_saja': return 'Biasa Saja';
      case 'marah': return 'Marah';
      case 'murung': return 'Murung';
      default: return 'Tidak Diketahui';
    }
  }
}

