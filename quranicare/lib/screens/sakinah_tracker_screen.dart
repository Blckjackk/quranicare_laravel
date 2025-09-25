import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/mood_service.dart';
import '../widgets/mood_selector_widget.dart';

class SakinahTrackerScreen extends StatefulWidget {
  const SakinahTrackerScreen({super.key});

  @override
  State<SakinahTrackerScreen> createState() => _SakinahTrackerScreenState();
}

class _SakinahTrackerScreenState extends State<SakinahTrackerScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  final MoodService _moodService = MoodService();
  
  // Sample mood data - should come from API in real implementation
  final Map<DateTime, String> _moodData = {
    DateTime(2025, 7, 1): '😢', // Sedih
    DateTime(2025, 7, 2): '😟', // Murung  
    DateTime(2025, 7, 3): '😐', // Biasa saja
    DateTime(2025, 7, 4): '😟', // Murung
    DateTime(2025, 7, 5): '😊', // Senang
    DateTime(2025, 7, 6): '😊', // Senang
    DateTime(2025, 7, 7): '😢', // Sedih
    DateTime(2025, 7, 8): '😟', // Murung
    DateTime(2025, 7, 9): '😐', // Biasa saja
    DateTime(2025, 7, 10): '😟', // Murung
    DateTime(2025, 7, 11): '😊', // Senang
    DateTime(2025, 7, 12): '😟', // Murung
    DateTime(2025, 7, 13): '😊', // Senang
    DateTime(2025, 7, 14): '😢', // Sedih
    DateTime(2025, 7, 15): '😟', // Murung
    DateTime(2025, 7, 16): '😐', // Biasa saja
  };

  Color _getMoodColor(String emoji) {
    switch (emoji) {
      case '😢': return const Color(0xFFDC2626); // Sedih - merah
      case '😟': return const Color(0xFFEA580C); // Murung - orange
      case '😐': return const Color(0xFFF59E0B); // Biasa - kuning
      case '😊': return const Color(0xFF16A34A); // Senang - hijau
      case '😡': return const Color(0xFF7C2D12); // Marah - coklat
      default: return const Color(0xFF8FA68E);
    }
  }

  String _getMoodLabel(String emoji) {
    switch (emoji) {
      case '😢': return 'Sedih';
      case '😟': return 'Murung';
      case '😐': return 'Biasa Saja';
      case '😊': return 'Senang';
      case '😡': return 'Marah';
      default: return 'Unknown';
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
              Color(0xFFF0F8F8),
              Color(0xFFE8F5E8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
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
                        'Sakinah Tracker',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D5A5A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 40), // Balance for back button
                  ],
                ),
              ),

              // Calendar with Mood Emojis
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
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
                      // Calendar Header
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
                                    DateFormat.MMMM().format(DateTime(2025, index + 1)),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                );
                              }),
                              onChanged: (month) {
                                setState(() {
                                  _currentMonth = DateTime(_currentMonth.year, month!, 1);
                                });
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
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Weekdays header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
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

                      const SizedBox(height: 16),

                      // Calendar days with moods
                      Expanded(
                        child: Column(
                          children: _buildCalendarWeeks(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Selected Date Mood Info
              if (_moodData.containsKey(DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)))
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2D5A5A).withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _getMoodColor(_moodData[DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)]!).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            _moodData[DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)]!,
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE, dd MMMM yyyy', 'id').format(_selectedDate),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D5A5A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Perasaan: ${_getMoodLabel(_moodData[DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)]!)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: _getMoodColor(_moodData[DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)]!),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
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
    
    // Add empty containers for days before first day of month
    for (int i = 1; i < startWeekday; i++) {
      days.add(const SizedBox(width: 40, height: 40));
    }
    
    // Add days of the month
    for (int day = 1; day <= totalDays; day++) {
      DateTime date = DateTime(_currentMonth.year, _currentMonth.month, day);
      bool isSelected = _isSameDay(date, _selectedDate);
      String? moodEmoji = _moodData[DateTime(date.year, date.month, date.day)];
      
      days.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected 
                  ? const Color(0xFF8FA68E).withOpacity(0.3)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isSelected 
                  ? Border.all(color: const Color(0xFF8FA68E), width: 2)
                  : null,
            ),
            child: moodEmoji != null
                ? Text(
                    moodEmoji,
                    style: const TextStyle(fontSize: 24),
                  )
                : Text(
                    day.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? const Color(0xFF8FA68E)
                          : const Color(0xFF64748b),
                    ),
                  ),
          ),
        ),
      );
    }
    
    // Group days into weeks
    for (int i = 0; i < days.length; i += 7) {
      List<Widget> week = days.sublist(i, (i + 7 > days.length) ? days.length : i + 7);
      while (week.length < 7) {
        week.add(const SizedBox(width: 40, height: 40));
      }
      weeks.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
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
}